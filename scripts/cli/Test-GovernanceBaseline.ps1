#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Environment = "sandbox",

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
$vnetName = "vnet-$ResourceNamePrefix-$Environment-shared"
$namePrefix = "$ResourceNamePrefix-$Environment"

Write-Host "Validation target"
Write-Host "Monitoring RG: $monitoringResourceGroupName"
Write-Host "Network RG   : $networkResourceGroupName"
Write-Host "Workload RG  : $workloadResourceGroupName"
Write-Host "Workspace    : $workspaceName"
Write-Host "VNet         : $vnetName"
Write-Host ""

Write-Host "Current Azure account"
az account show --query "{subscription:name, subscriptionId:id, tenantId:tenantId, user:user.name}" --output table

Write-Host ""
Write-Host "Resource groups"
az group list `
    --query "[?name=='$monitoringResourceGroupName' || name=='$networkResourceGroupName' || name=='$workloadResourceGroupName'].{name:name,location:location,tags:tags}" `
    --output table

Write-Host ""
Write-Host "Resource group tags"
foreach ($resourceGroupName in @($monitoringResourceGroupName, $networkResourceGroupName, $workloadResourceGroupName)) {
    Write-Host "- $resourceGroupName"
    az group show `
        --name $resourceGroupName `
        --query "{name:name,location:location,tags:tags}" `
        --output jsonc
}

Write-Host ""
Write-Host "Log Analytics Workspace"
az monitor log-analytics workspace show `
    --resource-group $monitoringResourceGroupName `
    --workspace-name $workspaceName `
    --query "{name:name,location:location,sku:sku.name,retentionInDays:retentionInDays,tags:tags}" `
    --output jsonc

Write-Host ""
Write-Host "Virtual Network"
az network vnet show `
    --resource-group $networkResourceGroupName `
    --name $vnetName `
    --query "{name:name,location:location,addressSpace:addressSpace.addressPrefixes,subnets:subnets[].name,tags:tags}" `
    --output jsonc

Write-Host ""
Write-Host "Policy definitions"
az policy definition list `
    --query "[?contains(name, '$namePrefix')].{name:name,policyType:policyType,mode:mode}" `
    --output table

Write-Host ""
Write-Host "Policy assignments"
az policy assignment list `
    --query "[?contains(name, '$namePrefix')].{name:name,displayName:displayName,scope:scope,enforcementMode:enforcementMode}" `
    --output table

Write-Host ""
Write-Host "Policy states"
try {
    az policy state list `
        --query "[?contains(policyAssignmentName, '$namePrefix')].{assignment:policyAssignmentName,resource:resourceId,state:complianceState}" `
        --output table
}
catch {
    Write-Host "Policy state could not be retrieved. This can occur depending on evaluation timing or permissions."
}

Write-Host ""
Write-Host "Role assignments for current subscription"
az role assignment list `
    --query "[0:10].{principalName:principalName,roleDefinitionName:roleDefinitionName,scope:scope}" `
    --output table
