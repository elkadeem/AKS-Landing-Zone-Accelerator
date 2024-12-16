targetScope = 'subscription'


param rgName string
param location string = deployment().location
param aksIdentityName string
param privateDNSZoneAKSName string
param privateDNSZoneAKSNameSubscriptionId string
param privateDNSZoneAKSNameResourceGroup string
param akslaworkspaceName string
param aksvnetName string
param vnetspokeRGName string
param akssubnetName string
param aksAppGatewayName string
param rtAppGWSubnetName string
param rtaksName string

param aksClusterName string
param kubernetesVersion string
@description('Optional. Name of a managed cluster SKU.')
@allowed([
  'Base'
  'Automatic'
])

param skuName string = 'Base'

@description('Optional. Tier of a managed cluster SKU.')
@allowed([
  'Free'
  'Premium'
  'Standard'
])

param skuTier string = 'Standard'
param aksadminGroupaccessprincipalId string
param aksusersgroupaccessprincipalId string
param enableAzurePolicy bool = true
param enableOMSAgent bool = true
param enableIngressApplicationGateway bool = true
param availabilityZones array = []
param enableAutoScaling bool = true
param enableWorkloadIdentity bool = true
param autoScalingProfile object
@allowed([
  'azure'
  'kubenet'
])
param aksNetworkPlugin string = 'azure'
@description('Optional. Network plugin mode used for building the Kubernetes network. Not compatible with kubenet network plugin.')
@allowed([
  'overlay'
])
param aksNetworkPluginMode string?
param aksPodCidr string?
param aksServiceCidr string
param aksDnsServiceIP string
param aksNetworkPolicy string = 'calico'

param aksSystemPoolVMSize string = 'Standard_D4d_v4'
param aksSystemPoolNodesCount int = 3
param aksSystemPoolNodeMin = 1
param aksSystemPoolNodeMax=3
param aksUserPoolVMSize string = 'Standard_D4d_v4'
param aksUserPoolNodesCount int = 3
param aksUserPoolNodeMin = 1
param aksUserPoolNodeMax= 3


param acrName string
param keyvaultName string

@description('Optional. Specifies outbound (egress) routing method.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
  'managedNATGateway'
  'userAssignedNATGateway'
])
param aksOutboundType string = 'loadBalancer'
param aksEnableWebRoutingAddOn bool = true
param aksWebRoutingAddOnDnsZoneResourceIds array?
param enableDnsZoneContributorRoleAssignment bool = false

var aksInfrastractureRGName = 'rg-${aksClusterName}-${toLower(location)}-aksInfra'
var akskubenetpodcidr = '10.122.0.0/16'
var ipdelimiters = [
  '.'
  '/'
]

var privateDNSZoneAKSSuffixes = {
  AzureCloud: '.azmk8s.io'
  AzureUSGovernment: '.cx.aks.containerservice.azure.us'
  AzureChinaCloud: '.cx.prod.service.azk8s.cn'
  AzureGermanCloud: '' //TODO: what is the correct value here?
}

var aksprivateDNSZone = !empty(privateDNSZoneAKSName)? privateDNSZoneAKSName : 'privatelink.${toLower(location)}${privateDNSZoneAKSSuffixes[environment().name]}'

module rg '../modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
  }
}

resource aksIdentity  'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(rg.name)
  name: aksIdentityName
}

module aksPodIdentityRole '../modules/Identity/role.bicep' = {
  name: 'aksPodIdentityRole'
  scope: resourceGroup(rg.name)
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: 'f1a07417-d97a-45cb-824c-7a7467783830' //Managed Identity Operator
  }
}


resource privatednsAKSZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(privateDNSZoneAKSNameSubscriptionId, privateDNSZoneAKSNameResourceGroup)
  name: aksprivateDNSZone
}

module aksPolicy '../modules/policy/policy.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksPolicy'  
  params: {
    location: location    
  }
}

module akslaworkspace '../modules/laworkspace/la.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksworkspace'
  params: {
    location: location
    workspaceName: akslaworkspaceName
  }
}

resource akssubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  scope: resourceGroup(vnetspokeRGName)
  name: '${aksvnetName}/${akssubnetName}'
}

resource appGateway 'Microsoft.Network/applicationGateways@2024-05-01' existing = if (enableIngressApplicationGateway) {
  scope: resourceGroup(vnetspokeRGName)
  name: aksAppGatewayName
}

module aks '../modules/aks/privateaks.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aks-cluster'
  params: {
    autoScalingProfile: autoScalingProfile
    enableAutoScaling: enableAutoScaling
    aksInfrastractureRGName: aksInfrastractureRGName
    location: location
    aksadminGroupObjectIDs: [
      aksadminGroupaccessprincipalId
    ]
    aksName: aksClusterName
    kubernetesVersion: kubernetesVersion
    networkPlugin: aksNetworkPlugin
    networkPluginMode:  aksNetworkPluginMode
    podCidr: aksPodCidr
    serviceCidr: aksServiceCidr
    dnsServiceIP: aksDnsServiceIP
    networkPolicy: aksNetworkPolicy
    outboundType: aksOutboundType
    logAnalyticsWorkspaceResourceID: akslaworkspace.outputs.laworkspaceId
    aksPrivateDNSZone: privatednsAKSZone.id    
    aksSKU: {
      name: skuName
      tier: skuTier
    }
    aksIdentity: {
      '${aksIdentity.id}': {}
    }
    applicationGatewayResourceId: enableIngressApplicationGateway? appGateway.id : ''
    enableAzurePolicy: enableAzurePolicy
    enableOMSAgent: enableOMSAgent
    enableIngressApplicationGateway: enableIngressApplicationGateway
    enableWorkloadIdentity: enableWorkloadIdentity
    agentPoolProfiles: [
      {
        name: 'defaultpool'
        count: aksSystemPoolNodesCount
        availabilityZones: !empty(availabilityZones) ? availabilityZones : null
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? aksSystemPoolNodeMin : null
        maxCount: enableAutoScaling ? aksSystemPoolNodeMax : null
        mode: 'System'
        osDiskSizeGB: 30
        vmSize: aksSystemPoolVMSize
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: akssubnet.id
        enableEncryptionAtHost: true
      }
      {
        name: 'userpool'
        count: aksUserPoolNodesCount
        availabilityZones: !empty(availabilityZones) ? availabilityZones : null
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? aksUserPoolNodeMin : null
        maxCount: enableAutoScaling ? aksUserPoolNodeMax : null
        mode: 'User'
        osDiskSizeGB: 60
        vmSize: aksUserPoolVMSize
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: akssubnet.id
        enableEncryptionAtHost: true
      }
    ]
    enableWebRoutingAddOn: aksEnableWebRoutingAddOn
    webRoutingAddOnDnsZoneResourceIds: aksWebRoutingAddOnDnsZoneResourceIds
  }
  dependsOn: [    
    aksIdentity
    aksPodIdentityRole
    aksPolicy   
    akssubnet
    appGateway
  ]
}


module aksRouteTableRole '../modules/Identity/rtrole.bicep' = {
  scope: resourceGroup(vnetspokeRGName)
  name: 'aksRouteTableRole'
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
    rtName: rtaksName
  }
}

module acraksaccess '../modules/Identity/acrrole.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acraksaccess'
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
    acrName: acrName
  }
}

module akspvtNetworkContributor '../modules/Identity/networkcontributorrole.bicep' = {
  scope: resourceGroup(vnetspokeRGName)
  name: 'akspvtNetworkContributor'
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
    vnetName: aksvnetName
  }
}


module aksPvtDNSContributor '../modules/Identity/pvtdnscontribrole.bicep' = {
  scope: resourceGroup(privateDNSZoneAKSNameSubscriptionId, privateDNSZoneAKSNameResourceGroup)
  name: 'aksPvtDNSContributor'
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f' //Private DNS Zone Contributor
    pvtdnsAKSZoneName: privatednsAKSZone.name
  }
  dependsOn: [    
    privatednsAKSZone
  ]
}

module vmContributorRole '../modules/Identity/role.bicep' = {
  scope: resourceGroup(aksInfrastractureRGName)
  name: 'vmContributor'
  params: {
    principalId: aksIdentity.properties.principalId
    roleGuid: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' //Virtual Machine Contributor
  }
  dependsOn: [
    aks
  ]
}

module aksuseraccess '../modules/Identity/role.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksuseraccess'
  params: {
    principalId: aksusersgroupaccessprincipalId
    roleGuid: '4abbcc35-e782-43d8-92c5-2d3f1bd2253f' //Azure Kubernetes Service Cluster User Role
  }
}

module aksadminaccess '../modules/Identity/role.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksadminaccess'
  params: {
    principalId: aksadminGroupaccessprincipalId
    roleGuid: '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8' //Azure Kubernetes Service Cluster Admin Role
  }
}

module appGatewayContributorRole '../modules/Identity/role.bicep' = if (enableIngressApplicationGateway) {
  scope: resourceGroup(vnetspokeRGName)
  name: 'appGatewayContributor'
  params: {
    principalId: aks.outputs.ingressIdentity
    roleGuid: 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Application Gateway Contributor
  }
}

module appGatewayReaderRole '../modules/Identity/role.bicep' = if (enableIngressApplicationGateway) {
  scope: resourceGroup(vnetspokeRGName)
  name: 'appGatewayReader'
  params: {
    principalId: aks.outputs.ingressIdentity
    roleGuid: 'acdd72a7-3385-48ef-bd42-f606fba81ae7' //Reader
  }
}

module keyvaultAccessPolicy '../modules/keyvault/keyvaultaccesspolicy.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'keyvaultAccessPolicy'
  params: {
    aksuseraccessprincipalId: aks.outputs.keyVaultaddonIdentity
    vaultName: keyvaultName
    keyvaultManagedIdentityObjectId: aksusersgroupaccessprincipalId
  }
}

resource rtAppGW  'Microsoft.Network/routeTables@2024-05-01' existing = {
  scope: resourceGroup(vnetspokeRGName)
  name: rtAppGWSubnetName
}

module appgwroutetableroutes '../modules/vnet/routetableroutes.bicep' = [for i in range(0, 3): if (aksNetworkPlugin == 'kebenet') {
  scope: resourceGroup(vnetspokeRGName)
  name: 'aks-vmss-appgw-pod-node-${i}'
  params: {
    properties: {
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '${split(akssubnet.properties.addressPrefix, ipdelimiters)[0]}.${split(akssubnet.properties.addressPrefix, ipdelimiters)[1]}.${int(split(akssubnet.properties.addressPrefix, ipdelimiters)[2])}.${int(split(akssubnet.properties.addressPrefix, ipdelimiters)[3]) + i + 4}'
      addressPrefix: '${split(akskubenetpodcidr, ipdelimiters)[0]}.${split(akskubenetpodcidr, ipdelimiters)[1]}.${int(split(akskubenetpodcidr, ipdelimiters)[2]) + i}.${split(akskubenetpodcidr, ipdelimiters)[3]}/${split(akskubenetpodcidr, ipdelimiters)[4]}'
    }
    routeName: 'aks-vmss-appgw-pod-node-${i}'
    routeTableName: rtAppGW.name
  }
}]


module dnsZoneRoleAssignment '../modules/identity/webroutingdnsroleassignment.bicep' =  [for dnsZoneResourceId in (aksWebRoutingAddOnDnsZoneResourceIds ?? []): if(enableDnsZoneContributorRoleAssignment && aksEnableWebRoutingAddOn) {
  scope: resourceGroup(dnsZoneResourceId)
  name: 'dnsZoneRoleAssignment'
  params: {
    principalId: aks.outputs.webRoutingIdentity
    roleGuid: 'b24988ac-6180-42a0-ab88-20f7382dd24c' //DNS Zone Contributor
    dnsZoneResourceId: dnsZoneResourceId
  }
}]
