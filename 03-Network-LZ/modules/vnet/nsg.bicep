param nsgName string
param secuirtyRules array
param location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: secuirtyRules
  }
}

output nsgId string = nsg.id
