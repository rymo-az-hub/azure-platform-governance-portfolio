#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

Write-Host "Repository root: $repoRoot"

$azVersion = az version --output json | ConvertFrom-Json
Write-Host "Azure CLI version: $($azVersion.'azure-cli')"

$account = $null

try {
    $account = az account show --output json | ConvertFrom-Json
}
catch {
    Write-Host "Azure CLI is not logged in. Starting az login..."
    az login | Out-Null
    $account = az account show --output json | ConvertFrom-Json
}

if ($SubscriptionId) {
    Write-Host "Setting subscription: $SubscriptionId"
    az account set --subscription $SubscriptionId
    $account = az account show --output json | ConvertFrom-Json
}

Write-Host ""
Write-Host "Current Azure context"
Write-Host "Subscription Name: $($account.name)"
Write-Host "Subscription ID  : $($account.id)"
Write-Host "Tenant ID        : $($account.tenantId)"
Write-Host "User             : $($account.user.name)"
