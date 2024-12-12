targetScope = 'subscription'

param rgName string
param vnetHubName string
param hubVnetAddressPrefixes array
param hubSubnets array
// Policy parameters
param firewallPolicyName string
param threatIntelMode string 
param firewallPolicySku object
param applicationRuleCollectionName string
param applicationRuleCollectionPriority int
param applicationsRuleCollections array
param networkRuleCollectionName string
param networkRuleCollectionPriority int
param networksRuleCollections array
param azfwName string
param rtVMSubnetname string
param location string = deployment().location
param availabilityZones array

// Create a resource group
module rg '../modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    location: location
    rgName: rgName
  }
}

// Create a virtual network
module vnetHub '../modules/vnet/vnet.bicep' = {
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
}

// Create a public IP address for the Azure Firewall
module publicipfw '../modules/vnet/publicip.bicep' = {
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
}

// Create a public IP address for the Azure Firewall management
module publicipfwmanagement '../modules/vnet/publicip.bicep' = {
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
}

// Get the subnets for the Azure Firewall
resource subnetFw 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  scope: resourceGroup(rgName)
  name: '${vnetHub.name}/AzureFirewallSubnet'  
}

// Get the subnets for the Azure Firewall management
resource subnetFwManagement 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  scope: resourceGroup(rgName)
  name: '${vnetHub.name}/AzureFirewallManagementSubnet'
}

// Create firewall Policy
module firewallPolicy '../modules/vnet/firewallpolicy.bicep' = {
  scope: resourceGroup(rg.name)
  name: firewallPolicyName
  params: {
    firewallPolicyName: firewallPolicyName
    location: location
    firewallPolicySku: firewallPolicySku
    threatIntelMode: threatIntelMode
  }
}

// Create firewall rule collection group
module ruleCollectionApplicationRules '../modules/vnet/firewallRuleCollectionGroup.bicep' = {
  scope: resourceGroup(rg.name)
  name: applicationRuleCollectionName
  params: {
    firewallPolicyName: firewallPolicy.name
    ruleCollectionGroupName: applicationRuleCollectionName
    Priority: applicationRuleCollectionPriority
    ruleCollections: applicationsRuleCollections
  }
}

// Create firewall rule collection group
module ruleCollectionNetworkRules '../modules/vnet/firewallRuleCollectionGroup.bicep' = {
  scope: resourceGroup(rg.name)
  name: networkRuleCollectionName
  params: {
    firewallPolicyName: firewallPolicy.name
    ruleCollectionGroupName: networkRuleCollectionName
    Priority: networkRuleCollectionPriority
    ruleCollections: networksRuleCollections
  }
}

module azfirewall '../modules/vnet/firewall.bicep' = {
  scope: resourceGroup(rg.name)
  name: azfwName
  params: {
    availabilityZones: availabilityZones
    location: location 
    fwname: azfwName
    firewallPolicyId: firewallPolicy.outputs.firewallPolicyId
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
  }
}


module publicipbastion '../modules/vnet/publicip.bicep' = {
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
}

resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  scope: resourceGroup(rg.name)
  name: '${vnetHub.name}/AzureBastionSubnet'  
}

module bastion '../modules/vm/bastion.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'bastion'
  params: {
    location: location
    bastionName: 'bastion'
    subnetId: subnetbastion.id
    bastionipId: publicipbastion.outputs.publicipId   
  }
}

module routetable '../modules/vnet/routetable.bicep' = {
  scope: resourceGroup(rg.name)
  name: rtVMSubnetname
  params: {
    location: location
    rtName: rtVMSubnetname    
  }
}

module routetableroutes '../modules/vnet/routetableroutes.bicep' = {
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
