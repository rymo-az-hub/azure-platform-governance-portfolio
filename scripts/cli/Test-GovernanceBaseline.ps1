#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",
    [Parameter(Mandatory = $false)]
    [string]$ResourceNamePrefix = "apg"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

$monitoringResourceGroupName = "rg-$ResourceNamePrefix-$Environment-monitoring"
$networkResourceGroupName = "rg-$ResourceNamePrefix-$Environment-network"
$workloadResourceGroupName = "rg-$ResourceNamePrefix-$Environment-workload-sample"
$workspaceName = "law-$ResourceNamePrefix-$Environment-monitoring"

Write-Host "Validation target"
Write-Host "Monitoring RG: $monitoringResourceGroupName"
Write-Host "Network RG   : $networkResourceGroupName"
Write-Host "Workload RG  : $workloadResourceGroupName"
Write-Host "Workspace    : $workspaceName"
Write-Host ""

Write-Host "Current Azure account"
az account show --query "{subscription:name, subscriptionId:id, tenantId:tenantId, user:user.name}" --output table

Write-Host ""
Write-Host "Resource groups"
az group list `
    --query "[?name=='$monitoringResourceGroupName' || name=='$networkResourceGroupName' || name=='$workloadResourceGroupName'].{name:name,location:location,tags:tags}" `
    --output table

Write-Host ""
Write-Host "Log Analytics Workspace"
az monitor log-analytics workspace show `
    --resource-group $monitoringResourceGroupName `
    --workspace-name $workspaceName `
    --query "{name:name,location:location,sku:sku.name,retentionInDays:retentionInDays}" `
    --output table

Write-Host ""
Write-Host "Policy assignments"
az policy assignment list `
    --query "[?contains(name, '$ResourceNamePrefix-$Environment')].{name:name,displayName:displayName,scope:scope}" `
    --output table

Write-Host ""
Write-Host "Role assignments for current subscription"
az role assignment list `
    --query "[0:10].{principalName:principalName,roleDefinitionName:roleDefinitionName,scope:scope}" `
    --output table
