# LinkedIn post draft | Windows Sysmon Blue-Team Lab (verified)

I built and validated a personal Windows security detection lab focused on **process, file, and registry telemetry**. 🛡️

The engineering workflow:
• Generated safe Windows behavior with PowerShell.
• Captured **6 genuine Sysmon events** on a GitHub-hosted Windows Server 2022 runner, including **Event IDs 1, 11, and 13**.
• Used a Python correlation engine to detect the tagged event sequence within a 600-second window.
• Built a small educational .NET application (source compiled successfully).
• Prepared Wazuh custom detection rules and documented the investigation workflow.

**Evidence:** GitHub Actions run #41489476874 passed; the sanitized artifact and repeatable source code are linked in the repository.

This is a **benign detection-engineering experiment**, not a ransomware infection or malware sample analysis. The Wazuh integration remains a separate validation milestone.

🔗 Project: https://github.com/tahazitan/Cybersecurity-Projects/tree/lab/msil-screenlocker-detection/PROJECTS/intermediate/msil-screenlocker-detection-lab
🔎 Verified Windows test: https://github.com/tahazitan/Cybersecurity-Projects/actions/runs/41489476874

#Cybersecurity #DetectionEngineering #BlueTeam #Sysmon #WindowsSecurity #Wazuh #Python