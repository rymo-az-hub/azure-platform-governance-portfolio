targetScope = 'resourceGroup'

@description('Deployment location.')
param location string = resourceGroup().location

@description('Log Analytics Workspace name.')
param workspaceName string

@description('Log Analytics Workspace SKU.')
param sku string = 'PerGB2018'

@description('Log retention days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Resource tags.')
param tags object

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output workspaceName string = workspace.name
output workspaceId string = workspace.id
output customerId string = workspace.properties.customerId
