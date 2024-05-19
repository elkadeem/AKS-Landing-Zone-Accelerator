param aksName string
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

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: aksIdentity
  }
  sku: aksSKU
  properties: {
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: aksadminGroupObjectIDs
      tenantID: subscription().tenantId
    }
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: {
        enabled: enableOMSAgent
        config: {
          logAnalyticsWorkspaceResourceID: enableOMSAgent ? logAnalyticsWorkspaceResourceID : null
        }
      }
      ingressApplicationGateway: enableIngressApplicationGateway
        ? {
            enabled: false
            config: {
              applicationGatewayId: applicationGatewayResourceId
              effectiveApplicationGatewayId: applicationGatewayResourceId
            }
          }
        : {
            enabled: false
          }
    }
  }
}
