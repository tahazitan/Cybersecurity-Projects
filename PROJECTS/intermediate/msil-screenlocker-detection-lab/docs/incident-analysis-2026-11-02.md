# Windows Sysmon Detection Engineering | Case Study 001

**Analyst:** Taha Zitane  
**Case:** MSIL-LAB-001  
**Date:** 2026-11-02 (UTC)  
**Platform:** Microsoft Windows Server 2022, disposable GitHub-hosted runner  
**Status:** Completed benign-behavior telemetry validation; Wazuh integration pending

## Executive summary

A safe PowerShell training script was executed to generate a distinctive process, file creation, and registry modification sequence. Microsoft-signed Sysmon recorded **6 events** in the **Microsoft-Windows-Sysmon/Operational** channel; a Python correlation engine matched process, file, and registry events within a **600-second detection window**. No malware sample was acquired or executed. This was not an actual ransomware incident.

## Evidence provenance

- [GitHub Actions run #41489476874](https://github.com/tahazitan/Cybersecurity-Projects/actions/runs/41489476874), job 125428387097, **success**
- Signed Sysmon binary publisher: **Microsoft Windows Publisher**
- Sanitized records: [windows-real-sysmon-sanitized-2026-11-02.jsonl](../evidence/public/windows-real-sysmon-sanitized-2026-11-02.jsonl)
- Correlation output: [windows-real-detection-2026-11-02.json](../evidence/public/windows-real-detection-2026-11-02.json)
- Source activity: [Invoke-BenignScenario.ps1](../lab/windows/Invoke-BenignScenario.ps1)
- Sensor policy: [sysmon-lab.xml](../lab/sysmon/sysmon-lab.xml)

## Observed timeline (UTC)

| Time | Sysmon event | Record ID | Sanitized behavior |
|---|---|---:|---|
| 17:16:30.1305109 | EID 11 | 4 | Training folder path observed |
| 17:16:30.1371601 | EID 11 | 5 | `run-start-utc.txt` created |
| 17:16:30.1473210 | EID 1 | 6 | `cmd.exe` process created with lab marker |
| 17:16:30.1559164 | EID 11 | 8 | `MSILBlockerLab-demo-artifact.txt` created |
| 17:16:30.1604477 | EID 13 | 10 | HKCU training registry value set |
| 17:16:30.1627952 | EID 13 | 11 | HKCU Run-key safe no-op value set |

The test script removes the optional no-op Run-key value after a brief interval, and its cleanup script clears known training marker artifacts. Windows runner is ephemeral.

## Detection engineering

The Python detector selects events marked `source=Sysmon/Operational` and `marker=MSILBlockerLab` and requires an event of each type (1, 11, 13) within 600 seconds. The observed no-op Run-key test increases the **training severity** to HIGH. This proves the fixture sequence was correlated, **not** that a malicious binary was detected.

### ATT&CK-inspired references (analogy only)

- **T1059.001 | PowerShell:** Scripted process and local changes are visible in Windows telemetry.
- **T1547.001 | Registry Run Keys / Startup Folder:** A reversible HKCU Run value demonstrates a persistence-related monitoring point. No functional malicious persistence was installed.

No attacker technique was observed: these mappings are labels for an educational exercise, not threat attribution.

## Limitations and likely false positives

- A matching lab marker is an artificial correlation aid; this is **not a general-purpose ransomware detector**.
- Ordinary software installers and update agents often create processes, files, and registry values close together.
- Correlation is time-window and marker-based, not tied by ProcessGuid/ParentProcessGuid.
- The .NET WinForms demonstration compiled, but its GUI was not executed on the hosted runner.
- Wazuh rules were checked for XML well-formedness only, not tested on an actual Wazuh manager.
- No packet captures, command-and-control activity, encryption, malware sample, or independent IOC analysis exists.

## Next engineering milestones

1. Add ProcessGuid/parent chain linkage and a negative-control benign software scenario.
2. Deploy Wazuh manager and Windows agent on a sufficiently resourced lab environment, validate rules 100201–100204 with real alerts.
3. Reproduce inside isolated Windows VM and capture redacted screenshots from Event Viewer and Wazuh dashboard.
4. Record actual false-positive findings and response decisions.

**Conclusion:** This project establishes a tested workflow from benign Windows activity to real Sysmon event collection, sanitized evidence, and automated Python correlation. It does not establish malware attribution or real-world detection effectiveness.