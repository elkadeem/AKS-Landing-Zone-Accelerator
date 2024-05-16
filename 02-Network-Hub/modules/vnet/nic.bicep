param subnetid string
param location string = resourceGroup().location
param nicName string

resource vmnic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetid
          }
        }
      }
    ]
  }
}

output nicId string = vmnic.id
output nicName string = vmnic.name
