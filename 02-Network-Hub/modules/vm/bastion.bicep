param bastionName string
param bastionipId string
param subnetId string
param location string = resourceGroup().location

resource bastion 'Microsoft.Network/bastionHosts@2023-11-01' = {
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
