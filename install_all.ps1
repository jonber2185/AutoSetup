
param(
    [string]$Root = (Split-Path -Path $PSScriptRoot -Parent)
)

# 관리자 권한
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Root `"$Root`""
    exit
}

$ErrorActionPreference = 'Continue'
$logFile = Join-Path $Root 'install_log.txt'
$sdkRoot = 'C:\SDK'

. (Join-Path $Root 'scripts\common.ps1')


Write-Host "Some registry changes and programs require a system restart to take full effect."
$reboot = Read-Host "Would you like to restart the system right after installation? (Y/N)"

Write-Log "===== setup start (Root: $Root) ====="

. (Join-Path $Root 'scripts\install_sdk.ps1')
. (Join-Path $Root 'scripts\install_program.ps1')
. (Join-Path $Root 'scripts\install_addition.ps1')

Write-Log "===== setup end ====="

Write-Log ""
Write-Log "all setup complete. Log File: $logFile"


### RESTART ###
if ($reboot -eq 'Y' -or $reboot -eq 'y') {
    Write-Log "Windows AutoSetup complete. System restarting in 10 seconds."
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}
