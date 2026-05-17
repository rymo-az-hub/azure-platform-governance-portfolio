#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",
    [Parameter(Mandatory = $false)]
    [string]$ResourceNamePrefix = "apg",
    [Parameter(Mandatory = $false)]
    [switch]$ConfirmDelete
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

$resourceGroups = @(
    "rg-$ResourceNamePrefix-$Environment-monitoring",
    "rg-$ResourceNamePrefix-$Environment-network",
    "rg-$ResourceNamePrefix-$Environment-workload-sample"
)

Write-Host "Teardown targets"
$resourceGroups | ForEach-Object { Write-Host "- $_" }
Write-Host ""

foreach ($resourceGroupName in $resourceGroups) {
    $exists = az group exists --name $resourceGroupName | ConvertFrom-Json

    if (-not $exists) {
        Write-Host "skip: $resourceGroupName does not exist"
        continue
    }

    Write-Host "Resources in $resourceGroupName"
    az resource list `
        --resource-group $resourceGroupName `
        --query "[].{name:name,type:type,location:location}" `
        --output table
}

if (-not $ConfirmDelete) {
    Write-Host ""
    Write-Host "Dry run only. Add -ConfirmDelete to delete the target resource groups."
    return
}

Write-Host ""
Write-Host "Deleting target resource groups..."

foreach ($resourceGroupName in $resourceGroups) {
    $exists = az group exists --name $resourceGroupName | ConvertFrom-Json

    if (-not $exists) {
        Write-Host "skip: $resourceGroupName does not exist"
        continue
    }

    Write-Host "delete: $resourceGroupName"
    az group delete --name $resourceGroupName --yes --no-wait
}

Write-Host ""
Write-Host "Delete requests were submitted. Check Azure Portal or run validation after a few minutes."
