targetScope = 'subscription'

@description('Location used for policy assignment metadata.')
param location string = deployment().location

@description('Policy name prefix.')
param policyNamePrefix string

@description('Required tag names.')
param requiredTagNames array

@description('Allowed Azure locations.')
param allowedLocations array

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
@description('Policy effect for required tag policy.')
param tagPolicyEffect string = 'Audit'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
@description('Policy effect for allowed location policy.')
param locationPolicyEffect string = 'Audit'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
@description('Policy effect for public IP policy.')
param publicIpPolicyEffect string = 'Audit'

var requiredTagPolicyName = '${policyNamePrefix}-require-tag'
var allowedLocationPolicyName = '${policyNamePrefix}-allowed-locations'
var publicIpPolicyName = '${policyNamePrefix}-audit-public-ip'

resource requiredTagPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: requiredTagPolicyName
  properties: {
    displayName: 'Require specified tag on resources'
    description: 'Audit or deny resources that do not have the specified tag.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
      source: 'azure-platform-governance-portfolio'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'Name of the required tag.'
        }
      }
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          displayName: 'Effect'
          description: 'Policy effect.'
        }
      }
    }
    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
        exists: 'false'
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

resource requiredTagAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for tagName in requiredTagNames: {
  name: '${policyNamePrefix}-require-${toLower(tagName)}'
  location: location
  properties: {
    displayName: 'Require tag: ${tagName}'
    description: 'Audit resources without the ${tagName} tag.'
    policyDefinitionId: requiredTagPolicy.id
    enforcementMode: 'Default'
    parameters: {
      tagName: {
        value: tagName
      }
      effect: {
        value: tagPolicyEffect
      }
    }
  }
}]

resource allowedLocationPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: allowedLocationPolicyName
  properties: {
    displayName: 'Allowed locations for resources'
    description: 'Audit or deny resources deployed outside allowed Azure locations.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'General'
      source: 'azure-platform-governance-portfolio'
    }
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
          description: 'List of allowed Azure locations.'
        }
      }
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          displayName: 'Effect'
          description: 'Policy effect.'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '[parameters(\'allowedLocations\')]'
          }
          {
            field: 'location'
            notEquals: 'global'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

resource allowedLocationAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyNamePrefix}-allowed-locations'
  location: location
  properties: {
    displayName: 'Allowed locations'
    description: 'Audit resources outside approved Azure locations.'
    policyDefinitionId: allowedLocationPolicy.id
    enforcementMode: 'Default'
    parameters: {
      allowedLocations: {
        value: allowedLocations
      }
      effect: {
        value: locationPolicyEffect
      }
    }
  }
}

resource publicIpPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: publicIpPolicyName
  properties: {
    displayName: 'Audit Public IP resources'
    description: 'Audit creation of Public IP resources.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Network'
      source: 'azure-platform-governance-portfolio'
    }
    parameters: {
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          displayName: 'Effect'
          description: 'Policy effect.'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Network/publicIPAddresses'
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

resource publicIpAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyNamePrefix}-audit-public-ip'
  location: location
  properties: {
    displayName: 'Audit Public IP resources'
    description: 'Audit Public IP resources to make internet exposure visible.'
    policyDefinitionId: publicIpPolicy.id
    enforcementMode: 'Default'
    parameters: {
      effect: {
        value: publicIpPolicyEffect
      }
    }
  }
}

output requiredTagPolicyId string = requiredTagPolicy.id
output allowedLocationPolicyId string = allowedLocationPolicy.id
output publicIpPolicyId string = publicIpPolicy.id
