param firewallPolicyName string
param ruleCollectionGroupName string
param Priority int
param ruleCollections array

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' existing = {
  name: firewallPolicyName
}

resource firewallRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  parent: firewallPolicy
  name: ruleCollectionGroupName
  properties: {
    priority: Priority
    ruleCollections: ruleCollections
  }
}

output ruleCollectionGroupName string = firewallRuleCollectionGroup.name
output ruleCollectionGroupId string = firewallRuleCollectionGroup.id
