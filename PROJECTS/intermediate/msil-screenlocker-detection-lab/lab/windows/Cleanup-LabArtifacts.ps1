#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'MSILBlockerLab-SafeNoop' -ErrorAction SilentlyContinue
$key = 'HKCU:\Software\MSILBlockerLab'
if (Test-Path $key) {
    Remove-ItemProperty -Path $key -Name 'MSILBlockerLab-ScenarioTag' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $key -Name 'MSILBlockerLab-DotNetTag' -ErrorAction SilentlyContinue
}
$root = Join-Path $env:LOCALAPPDATA 'MSILBlockerLab'
foreach ($name in @('MSILBlockerLab-demo-artifact.txt','MSILBlockerLab-dotnet-artifact.txt','run-start-utc.txt')) {
    $p = Join-Path $root $name
    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force }
}
Write-Host 'Lab marker artifacts removed; Sysmon evidence preserved.'
