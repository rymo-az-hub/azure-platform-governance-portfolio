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

$monitoringResourceGroupName = "rg-$ResourceNamePrefix-$Environment-monitoring"
$networkResourceGroupName = "rg-$ResourceNamePrefix-$Environment-network"
$workloadResourceGroupName = "rg-$ResourceNamePrefix-$Environment-workload-sample"
$workspaceName = "law-$ResourceNamePrefix-$Environment-monitoring"
$vnetName = "vnet-$ResourceNamePrefix-$Environment-shared"
$namePrefix = "$ResourceNamePrefix-$Environment"

$account = az account show --output json | ConvertFrom-Json
$subscriptionId = [string]$account.id

$signedInUser = $null
try {
    $signedInUser = az ad signed-in-user show --query "{displayName:displayName,userPrincipalName:userPrincipalName,id:id}" --output json | ConvertFrom-Json
}
catch {
    $signedInUser = $null
}

Write-Host "Validation target"
Write-Host "Monitoring RG: $monitoringResourceGroupName"
Write-Host "Network RG   : $networkResourceGroupName"
Write-Host "Workload RG  : $workloadResourceGroupName"
Write-Host "Workspace    : $workspaceName"
Write-Host "VNet         : $vnetName"
Write-Host ""

Write-Host "Current Azure account"
[pscustomobject]@{
    Subscription   = Get-SafeValue -Value $account.name -MaskedValue "<subscription-name>"
    SubscriptionId = Get-SafeValue -Value $subscriptionId -MaskedValue "<subscription-id>"
    TenantId       = Get-SafeValue -Value ([string]$account.tenantId) -MaskedValue "<tenant-id>"
    User           = Get-SafeValue -Value ([string]$account.user.name) -MaskedValue "<signed-in-user>"
} | Format-Table -AutoSize

if (-not $ShowSensitive) {
    Write-Host "Sensitive values are masked by default. Add -ShowSensitive for local troubleshooting only."
}

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
$policyAssignments = az policy assignment list `
    --query "[?contains(name, '$namePrefix')].{name:name,displayName:displayName,scope:scope,enforcementMode:enforcementMode}" `
    --output json | ConvertFrom-Json

$policyAssignments | ForEach-Object {
    [pscustomobject]@{
        name            = $_.name
        displayName     = $_.displayName
        scope           = Get-SafeResourceId -Value ([string]$_.scope) -SubscriptionId $subscriptionId
        enforcementMode = $_.enforcementMode
    }
} | Format-Table -AutoSize

Write-Host ""
Write-Host "Policy states"
try {
    $policyStates = az policy state list `
        --query "[?contains(policyAssignmentName, '$namePrefix')].{assignment:policyAssignmentName,resource:resourceId,state:complianceState}" `
        --output json | ConvertFrom-Json

    $policyStates | ForEach-Object {
        [pscustomobject]@{
            assignment = $_.assignment
            resource   = Get-SafeResourceId -Value ([string]$_.resource) -SubscriptionId $subscriptionId
            state      = $_.state
        }
    } | Format-Table -AutoSize
}
catch {
    Write-Host "Policy state could not be retrieved. This can occur depending on evaluation timing or permissions."
}

Write-Host ""
Write-Host "Role assignments for current signed-in user"
if ($null -eq $signedInUser -or [string]::IsNullOrWhiteSpace([string]$signedInUser.id)) {
    Write-Host "Signed-in user objectId could not be retrieved. Role assignment validation is skipped."
}
else {
    $roleAssignments = az role assignment list `
        --assignee ([string]$signedInUser.id) `
        --scope "/subscriptions/$subscriptionId" `
        --include-inherited `
        --output json | ConvertFrom-Json

    $roleAssignments | ForEach-Object {
        [pscustomobject]@{
            principalName      = Get-SafeValue -Value ([string]$_.principalName) -MaskedValue "<signed-in-user>"
            roleDefinitionName = $_.roleDefinitionName
            scope              = Get-SafeResourceId -Value ([string]$_.scope) -SubscriptionId $subscriptionId
        }
    } | Format-Table -AutoSize
}
