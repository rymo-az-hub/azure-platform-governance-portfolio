targetScope = 'subscription'

@description('Principal ID to assign the role to. Use group principal IDs in real environments.')
param principalId string

@description('Built-in or custom role definition ID. Default is Reader.')
param roleDefinitionId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

@description('Optional description for the role assignment.')
param roleAssignmentDescription string = 'Sample role assignment for validation.'

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionResourceId
    description: roleAssignmentDescription
  }
}

output roleAssignmentId string = roleAssignment.id
