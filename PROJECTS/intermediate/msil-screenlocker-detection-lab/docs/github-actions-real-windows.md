# Actual Windows telemetry without a local VM

When Windows is unavailable on your Mac, a disposable **GitHub-hosted Windows 2022 runner** can generate **genuine Sysmon telemetry** using only benign training actions. This runs on GitHub's computer, not on your Mac or a production endpoint.

## Windows workflow
- Workflow: .github/workflows/hosted-windows-sysmon.yml
- Validation: offline Python tests, .NET source compilation, download of Microsoft-signed Sysmon64.exe, real Event IDs 1 / 11 / 13, sanitized export and correlation.
- Guard: entrypoint checks GITHUB_ACTIONS=true, RUNNER_ENVIRONMENT=github-hosted, and administrator rights.
- Expected evidence: a GitHub Actions job log plus a 7-day sanitized JSONL and JSON artifact.
- **Not** a malware infection, independent ransomware classification, or real Wazuh manager integration.
- Important: verify the run status and artifact before making any real capture claim.

## Publishing options
The standalone repo workflow works on push to its own repo. If this project is nested under another repo, copy and adjust the workflow to the parent repo's .github/workflows location, including all working directories. The parent repository may have other workflows that run on push or pull requests.

When a run succeeds:
1. Record the run URL and runner OS in evidence/public/.
2. Download only the sanitized artifact, confirm capture_type=real_sysmon, and check each EID and record ID.
3. Update docs/validation-checklist.md and the case report.
4. Label evidence from hosted runner, rather than from a local VM.
