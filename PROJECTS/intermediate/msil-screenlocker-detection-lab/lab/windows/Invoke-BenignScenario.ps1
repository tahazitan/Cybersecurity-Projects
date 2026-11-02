#Requires -Version 5.1
<#
.SYNOPSIS
Generate actual Windows process, file and registry events using harmless lab markers.
.NOTES
Execute only inside a disposable authorized Windows VM. No malware or locking.
#>
[CmdletBinding()]
param([switch]$TestRunKey)
$ErrorActionPreference = 'Stop'
$tag = 'MSILBlockerLab'
$root = Join-Path $env:LOCALAPPDATA $tag
$run = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$name = 'MSILBlockerLab-SafeNoop'
$key = 'HKCU:\Software\MSILBlockerLab'
$now = (Get-Date).ToUniversalTime()
New-Item -ItemType Directory -Force -Path $root | Out-Null
$now.ToString('o') | Set-Content -LiteralPath (Join-Path $root 'run-start-utc.txt') -Encoding ASCII
Write-Host "Start UTC: $($now.ToString('o'))"
try {
    $cmd = Join-Path $env:SystemRoot 'System32\cmd.exe'
    $child = Start-Process -FilePath $cmd -ArgumentList '/d','/c','echo MSILBlockerLab-safe-child-process' -Wait -PassThru -NoNewWindow
    if ($child.ExitCode -ne 0) { throw 'Harmless child process failed' }
    ('MSILBlockerLab benign artifact UTC ' + $now.ToString('o')) |
        Set-Content -LiteralPath (Join-Path $root 'MSILBlockerLab-demo-artifact.txt') -Encoding UTF8
    New-Item -Path $key -Force | Out-Null
    New-ItemProperty -Path $key -Name 'MSILBlockerLab-ScenarioTag' -PropertyType String -Value 'benign-training' -Force | Out-Null
    if ($TestRunKey) {
        $noop = '"' + $cmd + '" /d /c exit 0'
        New-ItemProperty -Path $run -Name $name -PropertyType String -Value $noop -Force | Out-Null
        Start-Sleep -Seconds 2
    }
    Write-Host 'Benign event generation completed. Export events next.'
}
finally {
    if ($TestRunKey) {
        Remove-ItemProperty -Path $run -Name $name -ErrorAction SilentlyContinue
    }
}
