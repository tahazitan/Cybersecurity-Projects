# Windows Screen-Locker Behavior Detection Lab

**Personal Blue-Team Engineering Project** | Windows · Sysmon · Python · Wazuh (optional) · .NET (optional)

> **Status (2026-11-02):** Code & synthetic unit tests validated on an Intel Mac. Real Windows Sysmon capture and Wazuh alerts are **not yet validated**. No real malware sample was used.

## Research question
Can a defensive pipeline capture and correlate process creation (Sysmon EID 1), marker-file creation (EID 11), and registry value changes (EID 13) from a **harmless training application**?

The inspiration is the generic AV label `Trojan-Ransom.MSIL.Blocker.gen`. The AV family label alone does not establish the behavior of any individual sample or confirm any attack occurred today.

## Architecture
```mermaid
flowchart LR
  A[Windows VM: harmless activity] --> B[Sysmon EIDs 1, 11, 13]
  B --> C[Sanitized JSONL exporter]
  C --> D[Python correlation]
  B --> E[Optional Wazuh Agent & SIEM]
  D --> F[Incident report & verified evidence]
  E --> F
```

## Current offline validation (runs on macOS)
```bash
python3 -m unittest discover -s tests -v
python3 src/detect_events.py tests/fixtures/synthetic_sysmon.jsonl
```
The provided JSONL is **synthetic fixture data**, not real malware telemetry.

## Windows lab setup (pending VM)
1. Use an isolated Windows 10/11 VM. Install Sysmon from [Microsoft Sysinternals](https://learn.microsoft.com/sysinternals/downloads/sysmon), and inspect its schema: `Sysmon64.exe -s`.
2. In elevated PowerShell: `.\Sysmon64.exe -accepteula -i .\lab\sysmon\sysmon-lab.xml`.
3. Run `.\lab\windows\Invoke-BenignScenario.ps1` (optional reversible Run-key test: `-TestRunKey`).
4. Export genuine Sysmon telemetry: `.\lab\windows\Export-LabEvidence.ps1 -OutputPath .\evidence\local\events.jsonl`.
5. Analyze: `py -3 .\src\detect_events.py .\evidence\local\events.jsonl`. Compare observed events with Event Viewer.
6. Only after verified evidence, install Wazuh agent/manager and test custom rules.

## Security and claims
No encryption, screen lock, C2, credential access, malware execution or persistence retained. Tagged behaviors are safe analogues, not an actual ransomware signature. The real exporter intentionally strips user identities, hostnames, full command lines, and internal IPs. Raw evidence stays local and is gitignored. Validate all claims and screenshots before sharing.

**Hardware note:** On the connected 16 GB Intel Mac, VirtualBox and Docker are installed but no Windows VM is present and only ~16 GiB disk was free at setup time. Windows deployment must wait for enough free storage or an external lab disk.

**License:** MIT. Reproducible teaching and detection engineering only.
