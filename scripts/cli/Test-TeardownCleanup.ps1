#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Environment = "sandbox",

    [Parameter(Mandatory = $false)]
    [string]$ResourceNamePrefix = "apg",

    [Parameter(Mandatory = $false)]
    [switch]$ShowSensitive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Get-SafeResourceId {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Value,

        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    if ($ShowSensitive -or [string]::IsNullOrWhiteSpace($SubscriptionId)) {
        return $Value
    }

    return $Value.Replace($SubscriptionId, "<subscription-id>")
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

$account = az account show --output json | ConvertFrom-Json
$subscriptionId = [string]$account.id

$resourceGroupPrefix = "rg-$ResourceNamePrefix-$Environment"
$policyNamePrefix = "$ResourceNamePrefix-$Environment"

Write-Host "Teardown cleanup validation"
Write-Host "Environment: $Environment"
Write-Host "Resource name prefix: $ResourceNamePrefix"
Write-Host "Resource group prefix: $resourceGroupPrefix"
Write-Host "Policy name prefix: $policyNamePrefix"
Write-Host ""

if (-not $ShowSensitive) {
    Write-Host "Sensitive values are masked by default. Add -ShowSensitive for local troubleshooting only."
    Write-Host ""
}

$remainingResourceGroups = az group list `
    --query "[?starts_with(name, '$resourceGroupPrefix')].{name:name,location:location,provisioningState:properties.provisioningState}" `
    --output json | ConvertFrom-Json

$remainingPolicyAssignments = az policy assignment list `
    --query "[?starts_with(name, '$policyNamePrefix')].{name:name,scope:scope}" `
    --output json | ConvertFrom-Json

$remainingPolicyDefinitions = az policy definition list `
    --query "[?starts_with(name, '$policyNamePrefix')].{name:name,policyType:policyType}" `
    --output json | ConvertFrom-Json

Write-Host "Remaining resource groups"
if (@($remainingResourceGroups).Count -gt 0) {
    $remainingResourceGroups | Format-Table -AutoSize
}
else {
    Write-Host "OK: no remaining resource groups"
}

Write-Host ""
Write-Host "Remaining policy assignments"
if (@($remainingPolicyAssignments).Count -gt 0) {
    $remainingPolicyAssignments | ForEach-Object {
        [pscustomobject]@{
            name  = $_.name
            scope = Get-SafeResourceId -Value ([string]$_.scope) -SubscriptionId $subscriptionId
        }
    } | Format-Table -AutoSize
}
else {
    Write-Host "OK: no remaining policy assignments"
}

Write-Host ""
Write-Host "Remaining policy definitions"
if (@($remainingPolicyDefinitions).Count -gt 0) {
    $remainingPolicyDefinitions | Format-Table -AutoSize
}
else {
    Write-Host "OK: no remaining policy definitions"
}

$remainingCount = 0
$remainingCount += @($remainingResourceGroups).Count
$remainingCount += @($remainingPolicyAssignments).Count
$remainingCount += @($remainingPolicyDefinitions).Count

Write-Host ""
if ($remainingCount -eq 0) {
    Write-Host "Cleanup validation succeeded. No teardown targets remain."
    exit 0
}

Write-Host "Cleanup validation failed. Remaining teardown targets were found."
exit 1
