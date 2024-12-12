targetScope = 'subscription'

param rgName string
param location string = deployment().location
// vnet spoke parameters
param vnteSpokeName string
param vnetSpokeAddressPrefixes array
param vnetSpokeSubnets array
//param dhcpOptions object

param nsgAKSName string
param rtAKSSubnetname string
param firewallIP string

param hubVnetName string
param hubSubscriptionId string
param hubResourceGroupName string

param appgwpipName string
param appgwsubnetName string
param appgwName string
param availabilityZones array
param appgwAutoScale object
param nsgappgwName string
param appgwroutetableName string

var privateDNSZoneAKSSuffixes = {
  AzureCloud: '.azmk8s.io'
  AzureUSGovernment: '.cx.aks.containerservice.azure.us'
  AzureChinaCloud: '.cx.prod.service.azk8s.cn'
  AzureGermanCloud: '' //TODO: what is the correct value here?
}

module rg '../modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    location: location
    rgName: rgName
  }
}

module vnetSpoke '../modules/vnet/vnet.bicep' = {
  name: vnteSpokeName
  scope: resourceGroup(rgName)
  params: {
    vnetName: vnteSpokeName
    location: location
    vnetAddressSpace:{
      addressPrefixes: vnetSpokeAddressPrefixes 
    }    
    subnets: vnetSpokeSubnets
    //dhcpOptions: dhcpOptions
  }
  dependsOn: [
    rg
  ]
}

module nsgAKS '../modules/vnet/nsg.bicep' = {
  name: nsgAKSName
  scope: resourceGroup(rgName)
  params: {
    nsgName: nsgAKSName
    location: location 
    secuirtyRules: []   
  }
  dependsOn: [
    rg
  ]
}

module routetable '../modules/vnet/routetable.bicep' = {
  name: rtAKSSubnetname
  scope: resourceGroup(rgName)
  params: {
    rtName: rtAKSSubnetname
    location: location
  }
  dependsOn: [
    rg
  ]
}

module routetableroutes '../modules/vnet/routetableroutes.bicep' = {
  scope: resourceGroup(rgName)
  name: 'aks-to-internet'
  params: {
    routeName: 'aks-to-internet'
    routeTableName: rtAKSSubnetname
    properties: {
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: firewallIP
      addressPrefix: '0.0.0.0/0'
    }
  }
  dependsOn: [
    routetable
  ]
}


resource vnethub 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVnetName
}


module vnetperringhub '../modules/vnet/vnetpeering.bicep' = {
  name: 'vnetpeeringhub'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    peeringName: 'Hub-to-Spoke'
    vnetName: vnethub.name
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnetSpoke.outputs.vnetId
      }
    }
  }
  dependsOn: [
    vnethub
  ]
}

module vnetperringspoke '../modules/vnet/vnetpeering.bicep' = {
  name: 'vnetpeeringspoke'
  scope: resourceGroup(rgName)
  params: {
    peeringName: 'Spoke-to-Hub'
    vnetName: vnetSpoke.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnethub.id
      }
    }
  }
  dependsOn: [
    vnethub
  ]
}

// Private DNS Zone for ACR
module privatednsACRZone '../modules/vnet/privatednszone.bicep' = {
  name: 'privatednsACRZone'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: 'privatelink${environment().suffixes.acrLoginServer}'  
  }
  dependsOn: [
    rg
  ]
}

module privatednsACRLink '../modules/vnet/privatednslink.bicep' = {
  name: 'privatednsACRLink'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetName: vnethub.name
    vnetId: vnethub.id
  }
  dependsOn: [
    vnethub
  ]
}

// Private DNS Zone for KeyVault

module privatednsvalutZone '../modules/vnet/privatednszone.bicep' = {
  name: 'privatednsvalutZone'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: 'privatelink.vaultcore.azure.net'  
  }
  dependsOn: [
    rg
  ]
}

module privatednsVaultLink '../modules/vnet/privatednslink.bicep' = {
  name: 'privatednsVaultLink'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: privatednsvalutZone.outputs.privateDNSZoneName
    vnetName: vnethub.name
    vnetId: vnethub.id
  }
  dependsOn: [    
    vnethub
  ]
}


// Private DNS Zone for Storage Account
module privatednsStorageAccountZone '../modules/vnet/privatednszone.bicep' = {
  name: 'privatednsSAZone'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: 'privatelink.file.${environment().suffixes.storage}'  
  }
  dependsOn: [
    rg
  ]
}

module privatednsStorageAccounttLink '../modules/vnet/privatednslink.bicep' = {
  name: 'privatednsSALink'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: privatednsStorageAccountZone.outputs.privateDNSZoneName
    vnetName: vnethub.name
    vnetId: vnethub.id
  }
  dependsOn: [    
    vnethub
  ]
}

// Private DNS Zone for AKS
module privatednsAKSZone '../modules/vnet/privatednszone.bicep' = {
  name: 'privatednsaksZone'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: 'privatelink.${toLower(location)}${privateDNSZoneAKSSuffixes[environment().name]}'  
  }
  dependsOn: [
    rg
  ]
}

module privatednsAKSLink '../modules/vnet/privatednslink.bicep' = {
  name: 'privatednsAKSLink'
  scope: resourceGroup(rgName)
  params: {
    privateDNSZoneName: privatednsAKSZone.outputs.privateDNSZoneName
    vnetName: vnethub.name
    vnetId: vnethub.id
  }
  dependsOn: [    
    vnethub
  ]
}


module publicipappgw '../modules/vnet/publicip.bicep' = {
  scope: resourceGroup(rgName)
  name: appgwpipName
  params: {
    availabilityZones: availabilityZones 
    location: location
    publicipName: appgwpipName
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

resource appgwsubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  scope: resourceGroup(rgName)
  name: '${vnteSpokeName}/${appgwsubnetName}' 
}


module appgw '../modules/vnet/applicationgateway.bicep' = {
  scope: resourceGroup(rgName)
  name: appgwName
  params: {
    appgwAutoScale: appgwAutoScale
    appgwname: appgwName
    appgwpip: publicipappgw.outputs.publicipId
    subnetId: appgwsubnet.id
  }
  dependsOn: [
    appgwsubnet
  ]
}


module nsgappgwsubnet '../modules/vnet/nsg.bicep' = {
  name: nsgappgwName
  scope: resourceGroup(rgName)
  params: {
    nsgName: nsgappgwName
    location: location 
    secuirtyRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowControlPlaneV1SKU'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65503-65534'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowControlPlaneV2SKU'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHealthProbes'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]   
  }
  dependsOn: [
    rg
  ]
}

module appgwroutetable '../modules/vnet/routetable.bicep' = {
  name: appgwroutetableName
  scope: resourceGroup(rgName)
  params: {
    rtName: appgwroutetableName
    location: location
  }
  dependsOn: [
    rg
  ]
}
