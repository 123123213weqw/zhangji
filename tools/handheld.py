#!/usr/bin/env python3
"""Discover and operate the configured handheld over the current local network.

The implementation intentionally uses only Python's standard library and common
system commands.  The handheld is identified by MAC address instead of a DHCP
address, so the same repository continues to work when the Wi-Fi subnet changes.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import ipaddress
import json
import math
import os
from pathlib import Path
import platform
import re
import shlex
import socket
import subprocess
import sys
import time
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "config" / "handheld.json"
STATE_PATH = ROOT / ".cache" / "handheld.json"


class HandheldError(RuntimeError):
    """Expected operational error with a useful user-facing message."""


def run_capture(command: list[str], timeout: float = 5.0) -> str:
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return ""
    return result.stdout.strip()


def canonical_mac(value: str) -> str:
    """Normalize both 0c:c6:... and macOS arp's c:c6:... representation."""
    parts = re.split(r"[:-]", value.strip().lower())
    if len(parts) != 6:
        raise ValueError(f"invalid MAC address: {value}")
    try:
        return ":".join(f"{int(part, 16):02x}" for part in parts)
    except ValueError as exc:
        raise ValueError(f"invalid MAC address: {value}") from exc


def load_config() -> dict[str, Any]:
    try:
        config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise HandheldError(f"配置文件不存在：{CONFIG_PATH}") from exc
    except json.JSONDecodeError as exc:
        raise HandheldError(f"配置文件格式错误：{exc}") from exc

    overrides: dict[str, tuple[str, Any]] = {
        "HANDHELD_MAC": ("mac", str),
        "HANDHELD_USER": ("user", str),
        "HANDHELD_SSH_PORT": ("ssh_port", int),
        "HANDHELD_IDENTITY_FILE": ("identity_file", str),
    }
    for env_name, (key, converter) in overrides.items():
        if os.environ.get(env_name):
            config[key] = converter(os.environ[env_name])

    required = ("mac", "user", "ssh_port")
    missing = [key for key in required if not config.get(key)]
    if missing:
        raise HandheldError(f"配置缺少字段：{', '.join(missing)}")
    config["mac"] = canonical_mac(str(config["mac"]))
    return config


def default_network() -> tuple[str, ipaddress.IPv4Network, str]:
    override = os.environ.get("HANDHELD_NETWORK")
    system = platform.system()

    if system == "Darwin":
        route = run_capture(["/sbin/route", "-n", "get", "default"])
        match = re.search(r"^\s*interface:\s*(\S+)", route, re.MULTILINE)
        if not match:
            raise HandheldError("无法确定当前默认网络接口")
        interface = match.group(1)
        address = run_capture(["/usr/sbin/ipconfig", "getifaddr", interface])
        netmask = run_capture(
            ["/usr/sbin/ipconfig", "getoption", interface, "subnet_mask"]
        ) or "255.255.255.0"
        if not address:
            raise HandheldError(f"接口 {interface} 没有 IPv4 地址")
        network = ipaddress.ip_network(override or f"{address}/{netmask}", strict=False)
        return interface, network, address

    route = run_capture(["ip", "-4", "route", "get", "1.1.1.1"])
    interface_match = re.search(r"\bdev\s+(\S+)", route)
    source_match = re.search(r"\bsrc\s+(\d+(?:\.\d+){3})", route)
    if not interface_match or not source_match:
        raise HandheldError("无法确定当前默认网络接口")
    interface = interface_match.group(1)
    address = source_match.group(1)
    address_info = run_capture(["ip", "-4", "-o", "addr", "show", "dev", interface])
    cidr_match = re.search(r"\binet\s+(\d+(?:\.\d+){3}/\d+)", address_info)
    if not cidr_match and not override:
        raise HandheldError(f"无法读取接口 {interface} 的网络地址")
    network = ipaddress.ip_network(override or cidr_match.group(1), strict=False)
    return interface, network, address


def arp_entries(interface: str | None = None) -> dict[str, str]:
    """Return canonical MAC -> IPv4 from the platform neighbor table."""
    entries: dict[str, str] = {}
    if platform.system() == "Darwin":
        output = run_capture(["/usr/sbin/arp", "-an"])
        for match in re.finditer(
            r"\((\d+(?:\.\d+){3})\)\s+at\s+([0-9a-fA-F:-]+)", output
        ):
            try:
                entries[canonical_mac(match.group(2))] = match.group(1)
            except ValueError:
                pass
        return entries

    command = ["ip", "neigh", "show"]
    if interface:
        command.extend(["dev", interface])
    output = run_capture(command)
    for line in output.splitlines():
        match = re.search(
            r"^(\d+(?:\.\d+){3}).*\blladdr\s+([0-9a-fA-F:-]+)", line
        )
        if match:
            try:
                entries[canonical_mac(match.group(2))] = match.group(1)
            except ValueError:
                pass
    return entries


def ping_command(address: str, timeout_ms: int) -> list[str]:
    if platform.system() == "Darwin":
        return ["/sbin/ping", "-n", "-c", "1", "-W", str(timeout_ms), address]
    return [
        "ping",
        "-n",
        "-c",
        "1",
        "-W",
        str(max(1, math.ceil(timeout_ms / 1000))),
        address,
    ]


def ping_one(address: str, timeout_ms: int) -> None:
    try:
        subprocess.run(
            ping_command(address, timeout_ms),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=max(1.5, timeout_ms / 1000 + 1),
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass


def cached_ip() -> str | None:
    try:
        state = json.loads(STATE_PATH.read_text(encoding="utf-8"))
        return str(ipaddress.ip_address(state["ip"]))
    except (FileNotFoundError, KeyError, ValueError, json.JSONDecodeError):
        return None


def save_state(ip: str, interface: str, network: ipaddress.IPv4Network) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    state = {
        "ip": ip,
        "interface": interface,
        "network": str(network),
        "discovered_at": int(time.time()),
    }
    temporary = STATE_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    temporary.replace(STATE_PATH)


def candidate_from_neighbors(
    mac: str, interface: str, network: ipaddress.IPv4Network
) -> str | None:
    candidate = arp_entries(interface).get(mac)
    if candidate and ipaddress.ip_address(candidate) in network:
        return candidate
    return None


def scan_network(
    network: ipaddress.IPv4Network,
    local_ip: str,
    timeout_ms: int,
    workers: int,
    max_hosts: int,
) -> None:
    hosts = [str(host) for host in network.hosts() if str(host) != local_ip]
    if len(hosts) > max_hosts:
        raise HandheldError(
            f"当前网段有 {len(hosts)} 个地址，超过安全扫描上限 {max_hosts}；"
            "请设置 HANDHELD_NETWORK 缩小范围"
        )
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        list(executor.map(lambda host: ping_one(host, timeout_ms), hosts))


def discover(config: dict[str, Any], force_scan: bool = False) -> dict[str, Any]:
    interface, network, local_ip = default_network()
    mac = config["mac"]

    if os.environ.get("HANDHELD_IP"):
        ip = str(ipaddress.ip_address(os.environ["HANDHELD_IP"]))
        save_state(ip, interface, network)
        return {
            "name": config.get("name", "handheld"),
            "ip": ip,
            "mac": mac,
            "interface": interface,
            "network": str(network),
            "source": "environment",
        }

    if not force_scan:
        ip = candidate_from_neighbors(mac, interface, network)
        if ip:
            save_state(ip, interface, network)
            return {
                "name": config.get("name", "handheld"),
                "ip": ip,
                "mac": mac,
                "interface": interface,
                "network": str(network),
                "source": "neighbor-cache",
            }

        old_ip = cached_ip()
        if old_ip and ipaddress.ip_address(old_ip) in network:
            ping_one(old_ip, int(config.get("scan_timeout_ms", 180)))
            ip = candidate_from_neighbors(mac, interface, network)
            if ip:
                save_state(ip, interface, network)
                return {
                    "name": config.get("name", "handheld"),
                    "ip": ip,
                    "mac": mac,
                    "interface": interface,
                    "network": str(network),
                    "source": "state-cache",
                }

    scan_network(
        network,
        local_ip,
        int(config.get("scan_timeout_ms", 180)),
        int(config.get("scan_workers", 64)),
        int(config.get("max_scan_hosts", 1024)),
    )
    ip = candidate_from_neighbors(mac, interface, network)
    if not ip:
        raise HandheldError(
            f"未在 {network} 找到掌机（MAC {mac}）。请确认掌机已连接同一 Wi-Fi。"
        )
    save_state(ip, interface, network)
    return {
        "name": config.get("name", "handheld"),
        "ip": ip,
        "mac": mac,
        "interface": interface,
        "network": str(network),
        "source": "active-scan",
    }


def identity_path(config: dict[str, Any]) -> str | None:
    value = config.get("identity_file")
    if not value:
        return None
    return str(Path(str(value)).expanduser())


def ssh_options(config: dict[str, Any], scp: bool = False) -> list[str]:
    options: list[str] = []
    port_flag = "-P" if scp else "-p"
    options.extend([port_flag, str(config["ssh_port"])])
    key = identity_path(config)
    if key:
        options.extend(["-i", key])
    options.extend(["-o", "BatchMode=yes"])
    options.extend(["-o", "ConnectTimeout=6"])
    options.extend(["-o", "StrictHostKeyChecking=accept-new"])
    if config.get("host_key_alias"):
        options.extend(["-o", f"HostKeyAlias={config['host_key_alias']}"])
    return options


def ssh_target(config: dict[str, Any], ip: str) -> str:
    return f"{config['user']}@{ip}"


def tcp_open(ip: str, port: int, timeout: float = 1.5) -> bool:
    try:
        with socket.create_connection((ip, port), timeout=timeout):
            return True
    except OSError:
        return False


def remote_command(
    config: dict[str, Any], ip: str, command: Iterable[str], capture: bool = False
) -> subprocess.CompletedProcess[str]:
    argv = ["ssh", *ssh_options(config), ssh_target(config, ip)]
    command = list(command)
    if command:
        argv.append(shlex.join(command))
    return subprocess.run(
        argv,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        check=False,
    )


def print_payload(payload: dict[str, Any], as_json: bool) -> None:
    if as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return
    for key, value in payload.items():
        print(f"{key}={value}")


def command_discover(args: argparse.Namespace, config: dict[str, Any]) -> int:
    result = discover(config, force_scan=args.scan)
    if args.json:
        print_payload(result, True)
    else:
        print(result["ip"])
    return 0


def command_status(args: argparse.Namespace, config: dict[str, Any]) -> int:
    result = discover(config, force_scan=args.scan)
    ip = result["ip"]
    result["online"] = True
    result["ssh_open"] = tcp_open(ip, int(config["ssh_port"]))
    result["ssh_authenticated"] = False
    if result["ssh_open"]:
        probe = remote_command(config, ip, ["hostname"], capture=True)
        result["ssh_authenticated"] = probe.returncode == 0
        if probe.returncode == 0:
            result["remote_hostname"] = probe.stdout.strip()
        elif probe.stderr:
            result["ssh_error"] = probe.stderr.strip().splitlines()[-1]
    print_payload(result, args.json)
    return 0 if result["ssh_authenticated"] else 3


def command_exec(args: argparse.Namespace, config: dict[str, Any]) -> int:
    if not args.command:
        raise HandheldError("缺少远程命令；示例：./handheld exec -- uname -a")
    result = discover(config)
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    return remote_command(config, result["ip"], command).returncode


def command_shell(_args: argparse.Namespace, config: dict[str, Any]) -> int:
    result = discover(config)
    argv = ["ssh", *ssh_options(config), ssh_target(config, result["ip"])]
    os.execvp(argv[0], argv)
    return 127


def command_copy(args: argparse.Namespace, config: dict[str, Any], pull: bool) -> int:
    result = discover(config)
    target = ssh_target(config, result["ip"])
    source = f"{target}:{args.source}" if pull else args.source
    destination = args.destination if pull else f"{target}:{args.destination}"
    argv = ["scp", *ssh_options(config, scp=True)]
    if args.recursive:
        argv.append("-r")
    argv.extend([source, destination])
    return subprocess.run(argv, check=False).returncode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="handheld",
        description="按 MAC 自动发现并连接 Wi-Fi 掌机",
    )
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    discover_parser = subparsers.add_parser("discover", help="发现掌机当前 IP")
    discover_parser.add_argument("--json", action="store_true")
    discover_parser.add_argument("--scan", action="store_true", help="忽略缓存并扫描")
    discover_parser.set_defaults(handler=command_discover)

    status_parser = subparsers.add_parser("status", help="检查发现、SSH 和认证状态")
    status_parser.add_argument("--json", action="store_true")
    status_parser.add_argument("--scan", action="store_true", help="忽略缓存并扫描")
    status_parser.set_defaults(handler=command_status)

    exec_parser = subparsers.add_parser("exec", help="执行远程命令")
    exec_parser.add_argument("command", nargs=argparse.REMAINDER)
    exec_parser.set_defaults(handler=command_exec)

    shell_parser = subparsers.add_parser("shell", help="打开交互式 SSH")
    shell_parser.set_defaults(handler=command_shell)

    push_parser = subparsers.add_parser("push", help="复制本机文件到掌机")
    push_parser.add_argument("-r", "--recursive", action="store_true")
    push_parser.add_argument("source")
    push_parser.add_argument("destination")
    push_parser.set_defaults(
        handler=lambda args, cfg: command_copy(args, cfg, pull=False)
    )

    pull_parser = subparsers.add_parser("pull", help="从掌机复制文件到本机")
    pull_parser.add_argument("-r", "--recursive", action="store_true")
    pull_parser.add_argument("source")
    pull_parser.add_argument("destination")
    pull_parser.set_defaults(
        handler=lambda args, cfg: command_copy(args, cfg, pull=True)
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        config = load_config()
        return int(args.handler(args, config))
    except HandheldError as exc:
        print(f"错误：{exc}", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print("已取消。", file=sys.stderr)
        return 130


if __name__ == "__main__":
    raise SystemExit(main())
