# LinkedIn post draft (update after VM validation)

I am building a hands-on Windows security monitoring lab focused on .NET process telemetry and behavioral detection engineering.

My current implementation includes:
- A harmless Windows activity generator covering process, file and registry events.
- Sysmon collection rules for Event IDs 1, 11 and 13.
- A Python correlation engine and custom Wazuh rule definitions.
- An offline test suite: **7/7 tests passed on my Intel Mac** using clearly labeled synthetic fixtures.

**Next validation milestone:** capture and investigate genuine Sysmon events in an isolated Windows VM, then verify Wazuh manager alerts and publish sanitized screenshots.

This is a personal Blue-Team engineering exercise, not analysis of a live ransomware infection or a confirmed malware sample.

#Cybersecurity #BlueTeam #Sysmon #Wazuh #WindowsSecurity #ThreatDetection #DetectionEngineering #Python
