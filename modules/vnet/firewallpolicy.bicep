param firewallPolicyName string = 'firewallPolicyName'
param location string
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'
@allowed([
  {
    tier: 'Standard'
  }
  {
    tier: 'Premium'
  }
])
param firewallPolicySku object = {
  tier: 'Standard'
}


resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    threatIntelMode: threatIntelMode
    intrusionDetection: {
      mode: 'Alert'
    }
    sku: firewallPolicySku
  }
}

output firewallPolicyId string = firewallPolicy.id
output firewallPolicyName string = firewallPolicy.name
