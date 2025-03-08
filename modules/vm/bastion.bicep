param bastionName string
param bastionipId string
param subnetId string
param location string = resourceGroup().location

resource bastion 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: bastionipId
          }
        }
      }
    ]
  }
}
