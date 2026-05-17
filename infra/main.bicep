targetScope = 'subscription'

@description('Deployment location.')
param location string = 'japaneast'

@description('Environment name. Example: dev, test, prod, sandbox.')
param environment string

@description('Resource name prefix.')
param resourceNamePrefix string = 'apg'

@description('Owner tag value.')
param owner string

@description('CostCenter tag value.')
param costCenter string

@description('Workload tag value.')
param workload string = 'platform-governance'

@description('ManagedBy tag value.')
param managedBy string = 'iac'

@description('Allowed Azure regions for policy baseline.')
param allowedLocations array = [
  'japaneast'
  'japanwest'
]

@description('Log Analytics Workspace SKU.')
param logAnalyticsSku string = 'PerGB2018'

@description('Log Analytics Workspace retention days.')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionInDays int = 30

@description('Enable policy assignments.')
param enablePolicyAssignments bool = true

@description('Enable sample RBAC assignment. Keep false unless principalId is provided.')
param enableRbacAssignments bool = false

@description('Sample principal ID for RBAC assignment. Do not commit real production IDs.')
param principalId string = ''

var commonTags = {
  Environment: environment
  Owner: owner
  CostCenter: costCenter
  Workload: workload
  ManagedBy: managedBy
}

var monitoringResourceGroupName = 'rg-${resourceNamePrefix}-${environment}-monitoring'
var networkResourceGroupName = 'rg-${resourceNamePrefix}-${environment}-network'
var workloadResourceGroupName = 'rg-${resourceNamePrefix}-${environment}-workload-sample'
var logAnalyticsWorkspaceName = 'law-${resourceNamePrefix}-${environment}-monitoring'
var vnetName = 'vnet-${resourceNamePrefix}-${environment}-shared'

module rgMonitoring 'modules/resource-groups/main.bicep' = {
  name: 'rg-monitoring'
  params: {
    name: monitoringResourceGroupName
    location: location
    tags: union(commonTags, {
      Workload: 'platform-monitoring'
    })
  }
}

module rgNetwork 'modules/resource-groups/main.bicep' = {
  name: 'rg-network'
  params: {
    name: networkResourceGroupName
    location: location
    tags: union(commonTags, {
      Workload: 'platform-network'
    })
  }
}

module rgWorkloadSample 'modules/resource-groups/main.bicep' = {
  name: 'rg-workload-sample'
  params: {
    name: workloadResourceGroupName
    location: location
    tags: union(commonTags, {
      Workload: 'sample-workload'
    })
  }
}

module monitoring 'modules/monitoring/main.bicep' = {
  name: 'monitoring-baseline'
  scope: resourceGroup(monitoringResourceGroupName)
  params: {
    location: location
    workspaceName: logAnalyticsWorkspaceName
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
    tags: union(commonTags, {
      Workload: 'platform-monitoring'
    })
  }
  dependsOn: [
    rgMonitoring
  ]
}

module network 'modules/network/main.bicep' = {
  name: 'network-baseline'
  scope: resourceGroup(networkResourceGroupName)
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: '10.10.0.0/16'
    subnetName: 'snet-shared'
    subnetPrefix: '10.10.1.0/24'
    tags: union(commonTags, {
      Workload: 'platform-network'
    })
  }
  dependsOn: [
    rgNetwork
  ]
}

module policy 'modules/policy/main.bicep' = if (enablePolicyAssignments) {
  name: 'policy-baseline'
  params: {
    location: location
    policyNamePrefix: '${resourceNamePrefix}-${environment}'
    requiredTagNames: [
      'Environment'
      'Owner'
      'CostCenter'
      'Workload'
      'ManagedBy'
    ]
    allowedLocations: allowedLocations
    tagPolicyEffect: 'Audit'
    locationPolicyEffect: 'Audit'
    publicIpPolicyEffect: 'Audit'
  }
}

module rbac 'modules/rbac/main.bicep' = if (enableRbacAssignments && !empty(principalId)) {
  name: 'rbac-baseline'
  params: {
    principalId: principalId
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    roleAssignmentDescription: 'Sample Reader assignment for validation. Replace with approved group principal in real environments.'
  }
}

output monitoringResourceGroupName string = monitoringResourceGroupName
output networkResourceGroupName string = networkResourceGroupName
output workloadResourceGroupName string = workloadResourceGroupName
output logAnalyticsWorkspaceName string = logAnalyticsWorkspaceName
output vnetName string = vnetName
