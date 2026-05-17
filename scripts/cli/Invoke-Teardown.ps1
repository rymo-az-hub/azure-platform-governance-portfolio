#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Environment = "sandbox",

    [Parameter(Mandatory = $false)]
    [string]$ResourceNamePrefix = "apg",

    [Parameter(Mandatory = $false)]
    [switch]$IncludePolicyCleanup,

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

$policyNamePrefix = "$ResourceNamePrefix-$Environment"
$policyAssignments = @(
    "$policyNamePrefix-require-environment",
    "$policyNamePrefix-require-owner",
    "$policyNamePrefix-require-costcenter",
    "$policyNamePrefix-require-workload",
    "$policyNamePrefix-require-managedby",
    "$policyNamePrefix-allowed-locations",
    "$policyNamePrefix-audit-public-ip"
)

$policyDefinitions = @(
    "$policyNamePrefix-require-tag",
    "$policyNamePrefix-allowed-locations",
    "$policyNamePrefix-audit-public-ip"
)

Write-Host "Teardown targets"
Write-Host "Environment: $Environment"
Write-Host "Resource name prefix: $ResourceNamePrefix"
Write-Host ""

Write-Host "Resource Groups"
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

if ($IncludePolicyCleanup) {
    Write-Host ""
    Write-Host "Policy Assignments"

    foreach ($assignmentName in $policyAssignments) {
        $assignmentExists = $true

        try {
            az policy assignment show --name $assignmentName --output none
        }
        catch {
            $assignmentExists = $false
        }

        if ($assignmentExists) {
            Write-Host "- $assignmentName"
        }
        else {
            Write-Host "skip: $assignmentName does not exist"
        }
    }

    Write-Host ""
    Write-Host "Policy Definitions"

    foreach ($definitionName in $policyDefinitions) {
        $definitionExists = $true

        try {
            az policy definition show --name $definitionName --output none
        }
        catch {
            $definitionExists = $false
        }

        if ($definitionExists) {
            Write-Host "- $definitionName"
        }
        else {
            Write-Host "skip: $definitionName does not exist"
        }
    }
}

if (-not $ConfirmDelete) {
    Write-Host ""
    Write-Host "Dry run only. Add -ConfirmDelete to delete the target resource groups."

    if ($IncludePolicyCleanup) {
        Write-Host "Policy cleanup is also dry run only. Add -ConfirmDelete to delete the listed policy assignments and definitions."
    }

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

if ($IncludePolicyCleanup) {
    Write-Host ""
    Write-Host "Deleting policy assignments..."

    foreach ($assignmentName in $policyAssignments) {
        try {
            az policy assignment delete --name $assignmentName
            Write-Host "deleted assignment: $assignmentName"
        }
        catch {
            Write-Host "skip or failed assignment cleanup: $assignmentName"
        }
    }

    Write-Host ""
    Write-Host "Deleting policy definitions..."

    foreach ($definitionName in $policyDefinitions) {
        try {
            az policy definition delete --name $definitionName
            Write-Host "deleted definition: $definitionName"
        }
        catch {
            Write-Host "skip or failed definition cleanup: $definitionName"
        }
    }
}

Write-Host ""
Write-Host "Delete requests were submitted. Check Azure Portal or run validation after a few minutes."
