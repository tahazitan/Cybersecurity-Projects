# Reproducible Windows and Wazuh setup

## Prerequisites
- A disposable Windows 10/11 x64 VM (4-6 GB RAM) with an isolated or host-only network.
- Sufficient disk space. The connected Mac had ~16 GiB free during preparation; do not force a VM install into that space.
- Windows Administrator access to install Microsoft Sysmon (download from https://learn.microsoft.com/sysinternals/downloads/sysmon).
- Wazuh Linux manager/indexer/dashboard on separate infrastructure when feasible. Do not deploy a high-memory Wazuh stack on a nearly-full Mac.

## Stage A: real Sysmon capture
1. Snapshot VM and copy this repository into it.
2. Inspect the *installed* Sysmon config schema with `Sysmon64.exe -s`; adjust lab/sysmon/sysmon-lab.xml schemaversion when needed.
3. Run elevated PowerShell in repo root:
   ```powershell
   .\Sysmon64.exe -accepteula -i .\lab\sysmon\sysmon-lab.xml
   Get-WinEvent -ListLog Microsoft-Windows-Sysmon/Operational
   .\lab\windows\Invoke-BenignScenario.ps1
   .\lab\windows\Export-LabEvidence.ps1 -OutputPath .\evidence\local\events.jsonl
   py -3 .\src\detect_events.py .\evidence\local\events.jsonl
   ```
4. Verify actual Sysmon Event IDs 1, 11, 13 in Event Viewer, then corroborate sanitized exporter results. Redact screenshots before publishing.
5. Optional reversible persistence analogue: `.\lab\windows\Invoke-BenignScenario.ps1 -TestRunKey`. Do not use on a production endpoint. Confirm Run value removed.
6. Cleanup known marker artifacts: `.\lab\windows\Cleanup-LabArtifacts.ps1`.

## Stage B: optional .NET managed-code static analysis
Build only inside the Windows VM with .NET 8 SDK:
```powershell
dotnet build .\lab\dotnet\MSILBlockerLab.Demo\MSILBlockerLab.Demo.csproj -c Release
```
Launch the demo exe normally (it has a close button), inspect the executable's IL/metadata using ILSpy, then capture a new Sysmon run. **This is your own benign software, not a recovered Trojan.**

## Stage C: optional Wazuh
1. On an appropriately resourced Linux Wazuh host, deploy manager/indexer/dashboard using official Wazuh docs for your installed version.
2. Enroll Windows VM as an agent. Verify agent is Active.
3. Add lab/wazuh/windows-agent-snippet.xml localfile element inside the agent's ossec.conf, restart agent.
4. Merge the `group` from lab/wazuh/local_rules.xml into Wazuh manager's local_rules.xml; preserve existing groups/rules and restart manager.
5. Re-run the benign scenario. Check original Sysmon Events and correlate matching Wazuh alerts for custom IDs 100201-100204.
6. Save screenshot with alert ID, observed time, EID, and redacted host/user metadata. Wazuh rule XML validity alone does not establish compatibility with a running manager.

## Troubleshooting
- If `0` records, check installed Sysmon service, active config, event channel, StartTime timezone, and filter field spelling.
- Event ID 13 requires RegistryEvent rule; registry value update must occur *after* Sysmon install.
- Event ID 1 requires command-line marker visibility; event channel ingestion needs proper agent config.
- Never weaken endpoint security protections on your primary macOS machine.
