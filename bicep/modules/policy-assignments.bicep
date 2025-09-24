param scope string
param requiredTags array
param allowedLocations array

resource builtinAllowed 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'e56962a6-4747-49cd-b67b-bf8b01975c4c' // Allowed locations
}

resource assignAllowed 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'allowed-locations'
  scope: scope
  properties: {
    policyDefinitionId: builtinAllowed.id
    parameters: { listOfAllowedLocations: { value: allowedLocations } }
  }
}

resource requireTags 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-tags'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Require specific tags'
    policyRule: {
      if: { field: 'type'; equals: 'Microsoft.Resources/subscriptions/resourceGroups' }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f1a07417-d97a-45cb-824c-7a7467783830')
          ]
          operations: [
            for t in requiredTags: {
              operation: 'addOrReplace'
              field: concat('tags[', t, ']')
              value: '[' + t + ']'
            }
          ]
        }
      }
    }
    parameters: { for t in requiredTags: t: { type: 'String' } }
  }
}

resource assignRequireTags 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'require-tags-assign'
  scope: scope
  properties: {
    policyDefinitionId: requireTags.id
    parameters: { for t in requiredTags: t: { value: t } }
  }
}
