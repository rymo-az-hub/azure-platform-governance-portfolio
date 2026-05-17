targetScope = 'resourceGroup'

@description('Deployment location.')
param location string = resourceGroup().location

@description('Virtual network name.')
param vnetName string

@description('Virtual network address prefix.')
param addressPrefix string = '10.10.0.0/16'

@description('Subnet name.')
param subnetName string = 'snet-shared'

@description('Subnet address prefix.')
param subnetPrefix string = '10.10.1.0/24'

@description('Resource tags.')
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
