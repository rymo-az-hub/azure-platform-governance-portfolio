using '../main.bicep'

param location = 'japaneast'
param environment = 'sandbox'
param resourceNamePrefix = 'apg'
param owner = 'platform-team'
param costCenter = 'cc-0001'
param workload = 'platform-governance'
param managedBy = 'iac'
param allowedLocations = [
  'japaneast'
]
param logAnalyticsSku = 'PerGB2018'
param logAnalyticsRetentionInDays = 30
param logAnalyticsPublicNetworkAccessForIngestion = 'Enabled'
param logAnalyticsPublicNetworkAccessForQuery = 'Enabled'
param enablePolicyAssignments = true
param enableRbacAssignments = false
param principalId = ''
