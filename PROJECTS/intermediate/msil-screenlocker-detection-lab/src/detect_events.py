#!/usr/bin/env python3
"""Educational correlator for sanitized Sysmon JSONL exports, not malware attribution."""
from __future__ import annotations
import argparse
from datetime import datetime, timezone, timedelta
import json
from pathlib import Path

TAG = "MSILBlockerLab"
REQUIRED = {1, 11, 13}

def read_jsonl(path):
    events = []
    for lineno, line in enumerate(Path(path).read_text(encoding="utf-8-sig").splitlines(), 1):
        if not line.strip():
            continue
        try:
            r = json.loads(line)
            if not isinstance(r, dict):
                raise ValueError("expected a JSON object")
            if r.get("marker") != TAG or r.get("source") != "Sysmon/Operational":
                continue
            if type(r.get("event_id")) is not int or r["event_id"] not in REQUIRED:
                continue
            r["_datetime"] = datetime.fromisoformat(r["timestamp_utc"].replace("Z", "+00:00")).astimezone(timezone.utc)
            events.append(r)
        except (TypeError, KeyError, ValueError) as exc:
            raise ValueError(f"Invalid event at line {lineno}: {exc}") from exc
    return sorted(events, key=lambda e: e["_datetime"])

def investigate(events, window_seconds=600):
    if window_seconds <= 0:
        raise ValueError("window_seconds must be positive")
    for i, first in enumerate(events):
        end = first["_datetime"] + timedelta(seconds=window_seconds)
        matching = [x for x in events[i:] if x["_datetime"] <= end]
        ids = {e["event_id"] for e in matching}
        if REQUIRED.issubset(ids):
            runkey = any(e["event_id"] == 13 and "CurrentVersion\\Run\\MSILBlockerLab" in e.get("target", "") for e in matching)
            return {
                "detected": True, "severity": "high" if runkey else "medium",
                "explanation": "Tagged benign lab behaviors correlated; NOT a ransomware finding.",
                "first_timestamp_utc": first["_datetime"].isoformat(),
                "event_ids": sorted(ids), "optional_run_key_observed": runkey,
                "capture_types": sorted({e.get("capture_type", "unknown") for e in matching}),
                "records_in_window": len(matching)
            }
    return {"detected": False, "severity": "none", "records_analyzed": len(events),
            "capture_types": sorted({e.get("capture_type", "unknown") for e in events})}

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("input", type=Path)
    p.add_argument("--window-seconds", type=int, default=600)
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    result = json.dumps(investigate(read_jsonl(a.input), a.window_seconds), indent=2)
    print(result)
    if a.output:
        a.output.parent.mkdir(parents=True, exist_ok=True)
        a.output.write_text(result + "\n", encoding="utf-8")
