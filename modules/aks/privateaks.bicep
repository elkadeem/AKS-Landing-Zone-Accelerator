param aksName string
param kubernetesVersion string
param location string = resourceGroup().location
param aksIdentity object
param aksSKU object

param aksadminGroupObjectIDs array
param enableAzurePolicy bool = true
param enableOMSAgent bool = true
param logAnalyticsWorkspaceResourceID string
param applicationGatewayResourceId string
param enableIngressApplicationGateway bool = true
param enableAutoScaling bool = false
param aksPrivateDNSZone string
param enableWorkloadIdentity bool = true
param aksInfrastractureRGName string

param autoScalingProfile object
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'azure'
@description('Optional. Network plugin mode used for building the Kubernetes network. Not compatible with kubenet network plugin.')
@allowed([
  'overlay'
])
param networkPluginMode string?
param podCidr string?
param serviceCidr string
param dnsServiceIP string
@description('Optional. Specifies the network policy used for building Kubernetes network. - calico or azure.')
@allowed([
  'azure'
  'calico'
  'cilium'
])
param networkPolicy string?
@description('Optional. Specifies outbound (egress) routing method.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
  'managedNATGateway'
  'userAssignedNATGateway'
])
param outboundType string = 'loadBalancer'
param agentPoolProfiles array

param enableWebRoutingAddOn bool = false
param webRoutingAddOnDnsZoneResourceIds array?

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: aksName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: aksIdentity
  }
  sku: aksSKU
  properties: {
    kubernetesVersion: kubernetesVersion
    nodeResourceGroup: aksInfrastractureRGName
    dnsPrefix: '${toLower(aksName)}aks'
    autoScalerProfile: enableAutoScaling ? autoScalingProfile : null
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: aksadminGroupObjectIDs
      tenantID: subscription().tenantId
    }
    networkProfile: {
      networkPlugin: networkPlugin
      networkPluginMode: networkPluginMode
      outboundType: outboundType
      podCidr: podCidr
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      networkPolicy: networkPolicy
      loadBalancerProfile: {
        backendPoolType: 'NodeIPConfiguration'
      }
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: enableOMSAgent
        ? {
            enabled: true
            config: {
              logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
            }
          }
        : {
            enabled: false
          }
      ingressApplicationGateway: enableIngressApplicationGateway
        ? {
            enabled: true
            config: {
              applicationGatewayId: applicationGatewayResourceId
              effectiveApplicationGatewayId: applicationGatewayResourceId
            }
          }
        : {
            enabled: false
          }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
    agentPoolProfiles: agentPoolProfiles
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: aksPrivateDNSZone
      enablePrivateClusterPublicFQDN: false
    }
    disableLocalAccounts: true
    enableRBAC: true
    securityProfile: {
      workloadIdentity: {
        enabled: enableWorkloadIdentity
      }
    }
    oidcIssuerProfile: {
      enabled: enableWorkloadIdentity
    }
    ingressProfile: {
      webAppRouting: {
        enabled: enableWebRoutingAddOn
        dnsZoneResourceIds: enableWebRoutingAddOn && !empty(webRoutingAddOnDnsZoneResourceIds)
          ? webRoutingAddOnDnsZoneResourceIds
          : null
      }
    }
  }
}

output kubletetIdentity string = aks.properties.identityProfile.kubeletidentity.objectId
output ingressIdentity string = enableIngressApplicationGateway
  ? aks.properties.addonProfiles.ingressApplicationGateway.identity.objectId
  : ''
output keyVaultaddonIdentity string = aks.properties.addonProfiles.azureKeyVaultSecretsProvider.identity.objectId
output oidcIdentity string = aks.properties.oidcIssuerProfile.issuerURL
output webRoutingIdentity string = enableWebRoutingAddOn
  ? aks.properties.ingressProfile.webAppRouting.identity.objectId
  : ''
