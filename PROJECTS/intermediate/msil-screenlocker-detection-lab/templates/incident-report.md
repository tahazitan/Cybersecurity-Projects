# Incident investigation report (educational simulation)

**Case ID:** MSIL-LAB-001
**Status:** Pending real Windows capture
**Date:** TBD
**Researcher:** Taha Zitane
**Environment:** VM OS/version and Sysmon version to be recorded

## Executive summary
Investigated an intentionally harmless process/file/registry test sequence. This report is not about a confirmed ransomware intrusion.

## Evidence
| UTC time | Event ID | Sensor | What was observed | Redacted evidence |
|---|---:|---|---|---|
| TBD | 1 | Sysmon | Child process with lab marker | TBD |
| TBD | 11 | Sysmon | Marker file created | TBD |
| TBD | 13 | Sysmon | HKCU marker value set | TBD |

## Detection logic
EIDs 1, 11, 13 correlated within a 600-second window using marker-only logic. Wazuh alert IDs are pending validation.

## Impact and containment
No malware executed, no user files encrypted, no screen locking. All lab actions conducted inside an authorized VM.

## Limitations
No recovered Trojan sample, independent IOC attribution, real attack, production detection precision/recall, or threat actor campaign evidence.

## Future improvements
Collect real Sysmon data, validate Wazuh integration, add process-GUID correlation, evaluate false positives on ordinary system activity, publish sanitized evidence.
