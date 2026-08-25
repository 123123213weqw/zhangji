import importlib.util
from pathlib import Path
import unittest
from unittest import mock


MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "handheld.py"
SPEC = importlib.util.spec_from_file_location("handheld_tool", MODULE_PATH)
assert SPEC and SPEC.loader
handheld = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(handheld)


class MacTests(unittest.TestCase):
    def test_canonical_mac_pads_macos_arp_octets(self):
        self.assertEqual(
            handheld.canonical_mac("c:c6:55:1a:74:7e"),
            "0c:c6:55:1a:74:7e",
        )

    def test_canonical_mac_accepts_dashes(self):
        self.assertEqual(
            handheld.canonical_mac("0C-C6-55-1A-74-7E"),
            "0c:c6:55:1a:74:7e",
        )

    def test_invalid_mac_is_rejected(self):
        with self.assertRaises(ValueError):
            handheld.canonical_mac("not-a-mac")


class ArpTests(unittest.TestCase):
    @mock.patch.object(handheld.platform, "system", return_value="Darwin")
    @mock.patch.object(handheld, "run_capture")
    def test_parse_macos_arp(self, run_capture, _system):
        run_capture.return_value = (
            "? (192.168.10.225) at c:c6:55:1a:74:7e on en0 ifscope [ethernet]\n"
            "? (192.168.10.9) at (incomplete) on en0 ifscope [ethernet]"
        )
        self.assertEqual(
            handheld.arp_entries("en0"),
            {"0c:c6:55:1a:74:7e": "192.168.10.225"},
        )

    @mock.patch.object(handheld.platform, "system", return_value="Linux")
    @mock.patch.object(handheld, "run_capture")
    def test_parse_linux_neighbor(self, run_capture, _system):
        run_capture.return_value = (
            "192.168.10.225 dev wlan0 lladdr 0c:c6:55:1a:74:7e REACHABLE"
        )
        self.assertEqual(
            handheld.arp_entries("wlan0"),
            {"0c:c6:55:1a:74:7e": "192.168.10.225"},
        )


if __name__ == "__main__":
    unittest.main()
