#Requires -Version 5.1
<#
.SYNOPSIS
Create real Windows Sysmon telemetry on a disposable GitHub-hosted runner.
.NOTES
No malware, no encryption, no screen lock. This is not a Wazuh validation.
#>
[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)
$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted') {
    throw 'This entrypoint is restricted to disposable GitHub-hosted runners.'
}
if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'Only x64 Windows supported'
}
if (-not [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Sysmon installation needs elevated privileges'
}
$runDir = Join-Path $env:RUNNER_TEMP 'msilblocker-sysmon'
New-Item -Path $runDir -ItemType Directory -Force | Out-Null
$zip = Join-Path $runDir 'Sysmon.zip'
$exe = Join-Path $runDir 'Sysmon64.exe'
$source = 'https://download.sysinternals.com/files/Sysmon.zip'
Write-Host "Fetching Microsoft Sysinternals Sysmon from $source"
Invoke-WebRequest -Uri $source -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $runDir -Force
if (-not (Test-Path -LiteralPath $exe)) { throw 'Missing Sysmon64.exe in official archive.' }
if ((Get-AuthenticodeSignature -FilePath $exe).Status -ne 'Valid') {
    throw 'Sysmon64.exe Authenticode signature verification failed.'
}
$publisher = (Get-AuthenticodeSignature -FilePath $exe).SignerCertificate.Subject
if ($publisher -notmatch 'Microsoft') { throw 'Expected Microsoft publisher signature.' }
Write-Host "Verified publisher: $publisher"
if (Get-Service -Name 'Sysmon64' -ErrorAction SilentlyContinue) {
    throw 'A Sysmon64 service already exists on this runner; refusing to modify it.'
}
try {
    $sysmonConfig = Join-Path $RepositoryRoot 'lab\sysmon\sysmon-lab.xml'
    & $exe -accepteula -i $sysmonConfig
    if ($LASTEXITCODE -ne 0) { throw "Sysmon install failed: $LASTEXITCODE" }
    Start-Sleep -Seconds 5
    if (-not (Get-Service -Name 'Sysmon64' -ErrorAction SilentlyContinue)) {
        throw 'Sysmon service not present after installation.'
    }
    Write-Host "Running a harmless Windows event-generation scenario..."
    & (Join-Path $RepositoryRoot 'lab\windows\Invoke-BenignScenario.ps1') -TestRunKey
    Start-Sleep -Seconds 4
    $output = Join-Path $RepositoryRoot 'evidence\local\windows-real-sysmon.jsonl'
    & (Join-Path $RepositoryRoot 'lab\windows\Export-LabEvidence.ps1') -OutputPath $output
    if (-not (Test-Path $output)) { throw 'Evidence exporter did not produce a file' }
    $rows = @(Get-Content $output | Where-Object { $_.Trim() })
    $ids = @($rows | ForEach-Object { (ConvertFrom-Json $_).event_id } | Sort-Object -Unique)
    Write-Host "Observed real Sysmon Event IDs: $($ids -join ', ')"
    foreach ($required in @(1,11,13)) {
        if ($ids -notcontains $required) { throw "Missing actual Sysmon event $required" }
    }
    $python = (Get-Command python).Source
    $report = Join-Path $RepositoryRoot 'evidence\local\windows-real-detection.json'
    & $python (Join-Path $RepositoryRoot 'src\detect_events.py') $output --output $report
    if ($LASTEXITCODE -ne 0) { throw 'Python correlator failed' }
    $parsed = Get-Content -LiteralPath $report -Raw | ConvertFrom-Json
    if (-not $parsed.detected) { throw 'No 600-second Sysmon sequence detected' }
    if ($parsed.capture_types -notcontains 'real_sysmon') { throw 'Exporter source label mismatch' }
    Write-Host 'PASS: correlated genuine Windows Sysmon EIDs 1, 11, 13. No real malware used.'
}
finally {
    if (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'lab\windows\Cleanup-LabArtifacts.ps1')) {
        & (Join-Path $RepositoryRoot 'lab\windows\Cleanup-LabArtifacts.ps1')
    }
}
