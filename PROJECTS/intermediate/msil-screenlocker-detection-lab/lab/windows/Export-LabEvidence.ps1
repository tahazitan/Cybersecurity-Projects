#Requires -Version 5.1
<#
.SYNOPSIS
Collect genuine Windows Sysmon Operational events; export publication-safe fields.
#>
[CmdletBinding()]
param([string]$OutputPath = '.\evidence\local\sanitized-events.jsonl')
$ErrorActionPreference = 'Stop'
$startFile = Join-Path (Join-Path $env:LOCALAPPDATA 'MSILBlockerLab') 'run-start-utc.txt'
if (-not (Test-Path -LiteralPath $startFile)) { throw 'Run Invoke-BenignScenario.ps1 first.' }
$start = [datetime]::Parse((Get-Content -LiteralPath $startFile -Raw)).AddSeconds(-5)
$events = @(Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational'
    StartTime=$start
    Id=1,11,13
} -ErrorAction Stop)
$out = New-Object 'System.Collections.Generic.List[string]'
foreach ($evt in $events) {
    [xml]$xml = $evt.ToXml()
    $d = @{}
    foreach ($e in $xml.Event.EventData.Data) {
        if ($e.Name) { $d[[string]$e.Name] = [string]$e.'#text' }
    }
    if (($d.Values -join ' ') -notmatch 'MSILBlockerLab') { continue }
    $eventId = [int]$evt.Id
    $target = ''
    $kind = ''
    switch ($eventId) {
        1  { $kind='process'; $target=[System.IO.Path]::GetFileName([string]$d.Image) }
        11 { $kind='file'; $target='LAB_ARTIFACT\' + [System.IO.Path]::GetFileName([string]$d.TargetFilename) }
        13 {
            $kind='registry'
            if ($d.TargetObject -match '(?i)\\CurrentVersion\\Run\\MSILBlockerLab') {
                $target='HKCU\...\CurrentVersion\Run\MSILBlockerLab-SafeNoop'
            } else {
                $target='HKCU\Software\MSILBlockerLab\MSILBlockerLab-ScenarioTag'
            }
        }
    }
    $safe = [ordered]@{
        timestamp_utc=$evt.TimeCreated.ToUniversalTime().ToString('o')
        event_id=$eventId
        kind=$kind
        target=$target
        marker='MSILBlockerLab'
        source='Sysmon/Operational'
        capture_type='real_sysmon'
        record_id=[long]$evt.RecordId
    }
    $out.Add(($safe | ConvertTo-Json -Depth 4 -Compress))
}
$dest = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
[System.IO.File]::WriteAllLines($dest,$out,[System.Text.UTF8Encoding]::new($false))
Write-Host "Real Sysmon lab events exported: $($out.Count)"
Write-Host "Sanitized file: $dest"
if ($out.Count -eq 0) { Write-Warning 'No matching Sysmon events found. Inspect filters and service.' }
