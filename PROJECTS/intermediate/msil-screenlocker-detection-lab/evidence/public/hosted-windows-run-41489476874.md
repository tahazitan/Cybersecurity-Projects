# Genuine Windows Sysmon Evidence: GitHub-Hosted Runner

- **UTC date:** 2026-11-02
- **Execution environment:** GitHub Actions hosted runner, Microsoft Windows Server 2022
- **GitHub Actions run:** https://github.com/tahazitan/Cybersecurity-Projects/actions/runs/41489476874
- **Job ID:** 125428387097
- **Evidence artifact:** `real-sysmon-sanitized` (artifact ID `13163366815`, retention 7 days)
- **Evidence provenance:** Actual Sysmon/Operational events from harmless PowerShell activity on a disposable Windows runner. **No malicious sample executed.**
- **Sysmon executable signature:** Verified as `Microsoft Windows Publisher`.
- **Windows .NET 8 demo:** Source build passed. Demo GUI **not executed** in this hosted run.
- **Offline Python tests:** 7 passed.

## Validated observations
| Observed property | Verified outcome |
|---|---|
| Sanitized Sysmon events | **6 real records** |
| Sysmon EID 1 (Process Create) | **Observed** |
| Sysmon EID 11 (File Create) | **Observed** |
| Sysmon EID 13 (Registry Value Set) | **Observed** |
| EID 1+11+13 within 600 sec | **Correlation succeeded** |
| Safe Run-key analogue | **Observed and removed** |
| Synthetic detection severity label | **HIGH** |
| JSON provenance label | `real_sysmon` |
| Windows Actions outcome | **success** |

## Interpretation and limits
The correlation finding means three selected Windows event types occurred close together with the distinctive lab marker. It does **not** prove malware, ransomware, or attacker activity. `HIGH` is a rule-based training severity, not an actual incident severity. Sysmon config and Wazuh custom rules are lab prototypes, not general-purpose ransomware detection. **No Wazuh manager alert was validated** in this run. The Mac did not run a Windows VM.

## How to independently reproduce
1. Check out the branch `lab/msil-screenlocker-detection` in `tahazitan/Cybersecurity-Projects`.
2. Open the workflow `.github/workflows/msil-screenlocker-sysmon.yml` and the run linked above.
3. Inspect the Windows job logs for `Real Sysmon lab events exported: 6`, `Observed real Sysmon Event IDs: 1, 11, 13`, `capture_types: [real_sysmon]`, and `PASS: correlated genuine Windows Sysmon`.
4. Download the sanitized artifact while retained, verify it contains 6 event JSONL records with unique Windows event record IDs; compare the correlation result to the job log.
5. On a separate Windows VM, repeat scenario with official Sysmon, retain screenshots with redacted personal/host details.

**Researcher:** Taha Zitane