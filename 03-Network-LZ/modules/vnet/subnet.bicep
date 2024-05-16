param vnetName string
param subnetName string
param properties object

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: subnetName
  properties: properties
  parent: vnet
}

output subnetId string = subnet.id
