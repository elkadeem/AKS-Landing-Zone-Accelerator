targetScope = 'subscription'

param rgName string
param vnetSubnetname string
param vmsize string
param location string = deployment().location
@secure()
param adminUsername string
@secure()
param adminPassword string

resource subnetVM 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  scope: resourceGroup(rgName)
  name: vnetSubnetname
}

module jumbBox 'modules/vm/virtualmachine.bicep' = {
  scope: resourceGroup(rgName)
  name: 'jumbBox'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: subnetVM.id
    vmname: 'jumbBox'
    vmSize: vmsize
    location: location
  }
}
