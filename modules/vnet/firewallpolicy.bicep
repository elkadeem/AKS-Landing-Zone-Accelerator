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
param threatIntelWhitelist object = {
  fqdns: []
  ipAddresses: []
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {    
    threatIntelMode: threatIntelMode    
    sku: firewallPolicySku
    threatIntelWhitelist: threatIntelWhitelist
  }
}

output firewallPolicyId string = firewallPolicy.id
output firewallPolicyName string = firewallPolicy.name
