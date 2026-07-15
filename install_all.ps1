
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

Write-Log "===== setup start (Root: $Root) ====="

. (Join-Path $Root 'scripts\install_sdk.ps1')
. (Join-Path $Root 'scripts\install_program.ps1')
. (Join-Path $Root 'scripts\install_addition.ps1')

Write-Log "===== setup end ====="

Write-Host ""
Write-Host "all setup is closed. Log File: $logFile"

### RESTART ###
Write-Log "Restart"
Start-Sleep -Seconds 10
Restart-Computer -Force
