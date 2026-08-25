from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "games" / "Starfall"


class StarfallPackageTests(unittest.TestCase):
    def test_source_and_runtime_entries_are_packaged(self):
        for name in ("init.ts", "init.lua", "handheld.ts", "handheld.lua"):
            with self.subTest(name=name):
                self.assertTrue((GAME / name).is_file())

    def test_desktop_and_handheld_input_providers_are_isolated(self):
        desktop = (GAME / "Script" / "Input" / "Desktop.ts").read_text()
        handheld = (GAME / "Script" / "Input" / "Handheld.ts").read_text()
        self.assertIn("onKeyDown", desktop)
        self.assertIn("onMouseMove", desktop)
        self.assertNotIn("ButtonName", desktop)
        self.assertIn("ButtonName.A", handheld)
        self.assertIn("AxisName.LeftX", handheld)
        self.assertNotIn("KeyName", handheld)

    def test_handheld_profile_is_640_by_480(self):
        profiles = (GAME / "Script" / "TargetProfile.ts").read_text()
        self.assertIn('kind: "desktop"', profiles)
        self.assertIn('kind: "handheld"', profiles)
        self.assertIn("width: 640", profiles)
        self.assertIn("height: 480", profiles)


if __name__ == "__main__":
    unittest.main()
