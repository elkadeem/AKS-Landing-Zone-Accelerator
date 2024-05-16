targetScope = 'subscription'

param rgName string
param vnetHubName string
param hubVnetAddressPrefixes array
param hubSubnets array
param azfwName string
param rtVMSubnetname string
param fwApplicationRuleCollections array
param fwNetworkRuleCollections array
param fwNatRuleCollections array
param location string = deployment().location
param availabilityZones array


module rg  'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    location: location
    rgName: rgName
  }
}

module vnetHub 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: vnetHubName
  params: {
    location: location
    vnetName: vnetHubName
    vnetAddressSpace: {
      addressPrefixes: hubVnetAddressPrefixes
    }
    subnets: hubSubnets
  }
  dependsOn: [
    rg
  ]
}

module publicipfw 'modules/vnet/publicip.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${azfwName}-pip'
  params: {
    availabilityZones: availabilityZones
    publicipName: '${azfwName}-pip'
    publicipproperties: {
      publicIPAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
      tier: 'Regional'
    }
  }
  dependsOn: [
    rg
  ]
}


module publicipfwmanagement 'modules/vnet/publicip.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${azfwName}-pip-management'
  params: {
    availabilityZones: availabilityZones
    publicipName: '${azfwName}-pip-management'
    publicipproperties: {
      publicIPAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
      tier: 'Regional'
    }
  }
  dependsOn: [
    rg
  ]
}


resource subnetFw 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  scope: resourceGroup(rgName)
  name: '${vnetHub.name}/AzureFirewallSubnet'  
}

resource subnetFwManagement 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  scope: resourceGroup(rgName)
  name: '${vnetHub.name}/AzureFirewallManagementSubnet'
}

module azfirewall 'modules/vnet/firewall.bicep' = {
  scope: resourceGroup(rg.name)
  name: azfwName
  params: {
    availabilityZones: availabilityZones
    location: location 
    fwname: azfwName
    fwipConfigurations: [
      {
        name: 'AZFW-PIP'
        properties: {
          subnet: {
            id: subnetFw.id
          }
          publicIPAddress: {
            id: publicipfw.outputs.publicipId
          }
        }
      }      
    ]
    fwipManagementConfigurations: {
      name: 'AZFW-PIP-Management'
      properties: {
        subnet: {
          id: subnetFwManagement.id
        }
        publicIPAddress: {
          id: publicipfwmanagement.outputs.publicipId
        }
      }
    }
    fwapplicationRuleCollections: fwApplicationRuleCollections
    fwnetworkRuleCollections: fwNetworkRuleCollections
    fwnatRuleCollections: fwNatRuleCollections
  }
  dependsOn: [
    rg
    vnetHub
    publicipfw
    publicipfwmanagement  
  ]
}


module publicipbastion 'modules/vnet/publicip.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'publicip-bastion'
  params: {    
    availabilityZones: []
    publicipName: 'publicip-bastion'
    publicipproperties: {
      publicIPAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
      tier: 'Regional'
    }
  }
  dependsOn: [
    rg
  ]
}

resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  scope: resourceGroup(rg.name)
  name: '${vnetHub.name}/AzureBastionSubnet'  
}

module bastion 'modules/vm/bastion.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'bastion'
  params: {
    location: location
    bastionName: 'bastion'
    subnetId: subnetbastion.id
    bastionipId: publicipbastion.outputs.publicipId   
  }
  dependsOn: [
    rg
    vnetHub
    publicipbastion
  ]
}

module routetable 'modules//vnet/routetable.bicep' = {
  scope: resourceGroup(rg.name)
  name: rtVMSubnetname
  params: {
    location: location
    rtName: rtVMSubnetname    
  }
  dependsOn: [
    rg
  ]
}

module routetableroutes 'modules/vnet/routetableroutes.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vm-to-internet-routes'
  params: {
    routeName: 'vm-to-internet-routes'
    routeTableName: routetable.name
    properties: {
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: azfirewall.outputs.fwPrivateIP
        addressPrefix: '0.0.0.0/0'
    }
  }
}
