# 掌机 Coding Agent Wi-Fi Bridge

这是一个面向 Coding Agent 的零依赖连接仓库。Agent 打开仓库后会根据
`AGENTS.md` 自动使用统一入口发现并操作掌机，不需要记忆 DHCP 地址。

## 工作方式

1. 读取 Mac 或 Linux 当前默认网络。
2. 根据掌机 MAC 地址扫描邻居表，IP 改变后仍能识别同一设备。
3. 使用仓库外的专用 SSH 密钥连接。
4. 为 Coding Agent 提供稳定、可审计的发现、执行和文件传输接口。

仓库不保存密码或私钥。

## 快速使用

```bash
# 查看掌机 IP
./handheld discover

# Agent 友好的结构化状态
./handheld status --json

# 执行命令
./handheld exec -- uname -a
./handheld exec -- df -h

# 打开终端
./handheld shell

# 文件传输
./handheld push ./example.txt /home/ark/example.txt
./handheld pull /home/ark/example.txt ./example.downloaded.txt
```

## Coding Agent 接入

无需安装全局 Skill。将 Coding Agent 的工作目录设为本仓库即可：根目录的
`AGENTS.md` 会要求 Agent 先运行 `./handheld status --json`，再通过统一 CLI
操作掌机。

## Dora 掌机按钮模拟

仓库包含一个 `640x480` 的 Dora SSR 按钮实验环境。它把三种输入统一为
同一组游戏 Action：电脑键盘、屏幕虚拟手柄、R36S 物理按键。

```bash
./dora-lab
```

这一条命令会自动启动 Dora，直接运行仓库内已经构建好的模拟器，不需要打开
Web IDE。Coding Agent 修改
源码后使用 `./dora-lab dev` 自动重新编译。需要排错时再使用
`./dora-lab status` 或 `./dora-lab log`。

无需鼠标逐个点击：运行 `./dora-lab keys` 可以随时查看键盘映射，键盘、
屏幕按钮和真实手柄可以同时使用。

实现位于 `dora/ButtonLab/`。虚拟按钮直接调用 Dora `InputManager` 的
`emitButtonDown` / `emitButtonUp` / `emitAxis`，因此不是图片演示，而是会
真正进入游戏输入管线的按钮模拟器。

## Coding Agent 自主调试 Skill

仓库内置 `skills/dora-handheld-dev/SKILL.md`。Coding Agent 会通过根目录
`AGENTS.md` 读取它：先按原生电脑游戏方式完成键盘、鼠标、窗口和玩法开发，
再单独增加 R36S 输入与 640×480 UI 适配。只有电脑版本验证通过或明确要求
时，才进入掌机适配和真机检查。

其他 Dora 项目不必复制脚本，通过环境变量指定目录即可：

```bash
DORA_PROJECT=/absolute/path/to/game ./dora-lab dev
```

## 配置

设备配置位于 `config/handheld.json`：

```json
{
  "name": "darkosre-r36",
  "mac": "0c:c6:55:1a:74:7e",
  "user": "ark",
  "ssh_port": 22,
  "identity_file": "~/.ssh/id_ed25519_zhangji"
}
```

临时覆盖配置时可使用环境变量：

```bash
HANDHELD_IP=192.168.10.225 ./handheld status --json
HANDHELD_NETWORK=192.168.10.0/24 ./handheld discover --scan
HANDHELD_MAC=0c:c6:55:1a:74:7e ./handheld discover
```

## 首次准备

当前机器已经完成以下配置：

- 专用密钥：`~/.ssh/id_ed25519_zhangji`
- 掌机已安装对应公钥
- 掌机 SSH 已设为开机启动

在新电脑接入此仓库时，需要生成新的 SSH 密钥并将公钥添加到掌机的
`/home/ark/.ssh/authorized_keys`。私钥不得加入仓库。

## 故障判断

- `discover` 失败：掌机不在当前 Wi-Fi、未开机，或网络启用了客户端隔离。
- `ssh_open=false`：在 ArkOS 中打开 **Options -> Enable Remote Services**。
- `ssh_authenticated=false`：检查 `identity_file` 以及远端
  `authorized_keys`。
- 首次主动扫描通常需要数秒；命中邻居缓存时会立即返回。
