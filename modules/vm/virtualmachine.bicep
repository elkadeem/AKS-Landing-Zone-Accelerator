param vmname string
param subnetId string
param vmSize string
param location string = resourceGroup().location
@secure()
param adminUsername string
@secure()
param adminPassword string
param imageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}
module vmnic '../vnet/nic.bicep' = {
  name: '${vmname}-nic'
  params: {
    nicName: '${vmname}-nic'
    location: location
    subnetid: subnetId
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminUsername
      adminPassword: adminPassword            
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmnic.outputs.nicId
        }
      ]
    }
  }
}

output vmId string = vm.id
output vmName string = vm.name
