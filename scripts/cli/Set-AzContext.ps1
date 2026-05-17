#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [switch]$ShowSensitive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Get-SafeValue {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$MaskedValue
    )

    if ($ShowSensitive) {
        return $Value
    }

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    return $MaskedValue
}

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
    $subscriptionDisplay = Get-SafeValue -Value $SubscriptionId -MaskedValue "<subscription-id>"
    Write-Host "Setting subscription: $subscriptionDisplay"
    az account set --subscription $SubscriptionId
    $account = az account show --output json | ConvertFrom-Json
}

Write-Host ""
Write-Host "Current Azure context"
Write-Host "Subscription Name: $(Get-SafeValue -Value $account.name -MaskedValue '<subscription-name>')"
Write-Host "Subscription ID  : $(Get-SafeValue -Value $account.id -MaskedValue '<subscription-id>')"
Write-Host "Tenant ID        : $(Get-SafeValue -Value $account.tenantId -MaskedValue '<tenant-id>')"
Write-Host "User             : $(Get-SafeValue -Value $account.user.name -MaskedValue '<signed-in-user>')"

if (-not $ShowSensitive) {
    Write-Host ""
    Write-Host "Sensitive values are masked by default. Add -ShowSensitive for local troubleshooting only."
}
