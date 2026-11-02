# Evidence checklist for publication

- [x] Repo structure initialized on macOS
- [x] Offline unit tests pass on connected Mac (7 tests)
- [x] Correlator runs on labeled synthetic fixtures
- [x] Sysmon and Wazuh XML well-formed
- [ ] Disposable Windows VM created and snapshotted
- [ ] Sysmon binary version recorded
- [ ] First real EID 1 observed with actual event record ID
- [ ] First real EID 11 observed with actual event record ID
- [ ] First real EID 13 observed with actual event record ID
- [ ] Sanitized real_sysmon JSONL export generated
- [ ] Python multi-event correlation verified against same run
- [ ] Wazuh manager and Windows agent versions recorded
- [ ] Wazuh custom rules validated via actual alert
- [ ] Screenshots redacted, filenames labeled and saved under evidence/public/
- [ ] Incident report completed with explicit limits
- [ ] LinkedIn post updated with only verified metrics

**Never treat synthetic fixtures, XML parsing or unit tests as proof of endpoint telemetry or a real ransomware campaign.**
