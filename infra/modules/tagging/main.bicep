targetScope = 'subscription'

@description('Environment tag value.')
param environment string

@description('Owner tag value.')
param owner string

@description('CostCenter tag value.')
param costCenter string

@description('Workload tag value.')
param workload string

@description('ManagedBy tag value.')
param managedBy string = 'iac'

@description('Additional tags.')
param additionalTags object = {}

var commonTags = {
  Environment: environment
  Owner: owner
  CostCenter: costCenter
  Workload: workload
  ManagedBy: managedBy
}

output tags object = union(commonTags, additionalTags)
