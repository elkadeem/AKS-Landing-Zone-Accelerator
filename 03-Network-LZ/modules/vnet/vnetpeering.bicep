param vnetName string
param peeringName string
param properties object

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: '${vnetName}/${peeringName}'
  properties: properties
}
