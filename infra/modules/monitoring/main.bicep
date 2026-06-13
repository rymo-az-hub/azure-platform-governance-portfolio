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

@allowed([
  'Enabled'
  'Disabled'
])
@description('Public network access for ingestion.')
param publicNetworkAccessForIngestion string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Public network access for query.')
param publicNetworkAccessForQuery string = 'Enabled'

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
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

output workspaceName string = workspace.name
output workspaceId string = workspace.id
