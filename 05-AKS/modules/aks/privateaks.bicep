param aksName string
param kubernetesVersion string
param location string = resourceGroup().location
param aksIdentity object
param aksSKU object = {
  name: 'Basic'
  tier: 'Free'
}
param aksadminGroupObjectIDs array
param enableAzurePolicy bool = true
param enableOMSAgent bool = true
param logAnalyticsWorkspaceResourceID string
param applicationGatewayResourceId string
param enableIngressApplicationGateway bool = true

param availabilityZones array = []
param enableAutoScaling bool = false
param aksSubnetId string
param aksPrivateDNSZone string
param enableWorkloadIdentity bool = true

param autoScalingProfile object
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'azure'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location  
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: aksIdentity
  }
  sku: aksSKU
  properties: {
    kubernetesVersion: kubernetesVersion
    nodeResourceGroup: 'rg-${aksName}-${toLower(location)}-aksInfra'
    dnsPrefix: '${toLower(aksName)}aks'
    autoScalerProfile: enableAutoScaling? autoScalingProfile : null
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: aksadminGroupObjectIDs
      tenantID: subscription().tenantId
    }
    networkProfile: networkPlugin == 'azure'? {
      networkPlugin: 'azure'
      outboundType: 'userDefinedRouting'
      serviceCidr: '192.168.100.0/24'
      dnsServiceIP: '192.168.100.10'
      networkPolicy: 'calico'
    } : {
      networkPlugin: 'kubenet'
      outboundType: 'userDefinedRouting'
      serviceCidr: '192.168.100.0/24'
      dnsServiceIP: '192.168.100.10'
      networkPolicy: 'calico'
      podCidr: '172.17.0.0/16'
    }
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: enableOMSAgent? {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
        }
      } : {
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
      azureKeyVaultSecretsProvider: {
        enabled: true
      }
    }
    agentPoolProfiles: [
      {
        name: 'defaultpool'
        count: 3
        availabilityZones: !empty(availabilityZones)? availabilityZones : null
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? 1 : null
        maxCount: enableAutoScaling ? 3 : null
        mode: 'System'
        osDiskSizeGB: 30
        vmSize: 'Standard_D4d_v4'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: aksSubnetId
        enableEncryptionAtHost: true
      }
    ]
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
  }
}


output kubletetIdentity string = aks.properties.identityProfile.kubeletidentity.objectId
output ingressIdentity string = aks.properties.addonProfiles.ingressApplicationGateway.identity.objectId
output keyVaultaddonIdentity string = aks.properties.addonProfiles.azureKeyVaultSecretsProvider.identity.objectId
output oidcIdentity string = aks.properties.oidcIssuerProfile.issuerURL
