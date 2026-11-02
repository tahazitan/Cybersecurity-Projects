"""Validate provenance and consistency of a real (sanitized) Sysmon sample."""
import sys
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'src'))
from detect_events import investigate,read_jsonl

class RealCaptureTests(unittest.TestCase):
    def setUp(self):
        self.path=ROOT/'evidence/public/windows-real-sysmon-sanitized-2026-11-02.jsonl'
        self.events=read_jsonl(self.path)

    def test_expected_events(self):
        self.assertEqual(len(self.events),6)
        self.assertEqual({x['event_id'] for x in self.events},{1,11,13})
        self.assertEqual({x['capture_type'] for x in self.events},{'real_sysmon'})

    def test_unique_sysmon_record_ids(self):
        self.assertEqual(len({e['record_id'] for e in self.events}),len(self.events))

    def test_real_correlation(self):
        result=investigate(self.events)
        self.assertTrue(result['detected'])
        self.assertEqual(result['severity'],'high')
        self.assertTrue(result['optional_run_key_observed'])
        self.assertEqual(result['capture_types'],['real_sysmon'])

    def test_sanitized_fields(self):
        expected={'timestamp_utc','event_id','kind','target','marker','source','capture_type','record_id','_datetime'}
        for event in self.events:
            self.assertEqual(set(event),expected)

if __name__=='__main__':
    unittest.main()