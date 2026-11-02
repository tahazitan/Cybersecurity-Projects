import sys
import tempfile
import unittest
from datetime import timedelta
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from detect_events import read_jsonl, investigate

class DetectionTests(unittest.TestCase):
    def setUp(self):
        self.events = read_jsonl(ROOT / "tests/fixtures/synthetic_sysmon.jsonl")

    def test_fixture_detection(self):
        r = investigate(self.events)
        self.assertTrue(r["detected"])
        self.assertEqual(r["severity"], "medium")
        self.assertEqual(r["capture_types"], ["synthetic_fixture"])

    def test_incomplete_does_not_alert(self):
        self.assertFalse(investigate(self.events[:2])["detected"])

    def test_large_time_gap_does_not_alert(self):
        other = [dict(e) for e in self.events]
        other[2]["_datetime"] += timedelta(minutes=11)
        self.assertFalse(investigate(other)["detected"])

    def test_run_key_escalation(self):
        other = [dict(e) for e in self.events]
        other[2]["target"] = "HKCU\\...\\CurrentVersion\\Run\\MSILBlockerLab-SafeNoop"
        r = investigate(other)
        self.assertTrue(r["detected"])
        self.assertEqual(r["severity"], "high")

    def test_no_matching_marker(self):
        with tempfile.TemporaryDirectory() as folder:
            p = Path(folder) / "other.jsonl"
            p.write_text('{"marker":"OTHER","source":"Sysmon/Operational","event_id":1,"timestamp_utc":"2026-11-02T15:00:00Z"}\n', encoding="utf-8")
            self.assertEqual(read_jsonl(p), [])

    def test_bad_input_line(self):
        with tempfile.TemporaryDirectory() as folder:
            p = Path(folder) / "bad.jsonl"
            p.write_text("{not json}\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "line 1"):
                read_jsonl(p)

    def test_xml_well_formed(self):
        for path in ("lab/sysmon/sysmon-lab.xml", "lab/wazuh/local_rules.xml"):
            with self.subTest(path=path):
                ET.parse(ROOT / path)

if __name__ == "__main__":
    unittest.main()
