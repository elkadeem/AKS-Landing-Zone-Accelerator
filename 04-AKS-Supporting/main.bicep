targetScope = 'subscription'

param rgName string
param location string = deployment().location
param acrName string = 'eslzacr${uniqueString('acrvws', utcNow('u'))}'
param keyvaultName string = 'eslz-kv-${uniqueString('acrvws', utcNow('u'))}'
param storageAccountName string = 'eslzsa${uniqueString('aks', utcNow('u'))}'
param storageAccountType string
param rgSpokevnetName string
param vnetSpokeName string
param serviceepSubnetName string
param keyVaultPrivateEndpointName string
param acrPrivateEndpointName string
param saPrivateEndpointName string

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
  rgName: rgName
  location: location
  }
}


module acr 'modules/acr/acr.bicep' = {
  scope: resourceGroup(rg.name)
  name: acrName
  params: {
    location: location
    acrName: acrName
    acrSkuName: 'Premium'
  }
}


module keyvault 'modules/keyvault/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: keyvaultName
  params: {
    location: location
    keyVaultsku: 'Standard'
    name: keyvaultName
    tenantId: subscription().tenantId
  }
}


module storage 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: storageAccountName
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
  }
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  scope: resourceGroup(rgSpokevnetName)
  name: '${vnetSpokeName}/${serviceepSubnetName}'
}

module privateEndpointKeyVault 'modules/vnet/privateendpoint.bicep' = {
  scope: resourceGroup(rg.name)
  name: keyVaultPrivateEndpointName
  params: {
    location: location
    privateLinkServiceConnections: [
      {
        name: '${keyVaultPrivateEndpointName}-conn'
        privateLinkServiceId: keyvault.outputs.keyvaultId
        groupIds: [
          'Vault'
        ]
      }
    ]
    privateEndpointName: keyVaultPrivateEndpointName
    subnetid: servicesSubnet.id
  }
}


module privateEndpointAcr 'modules/vnet/privateendpoint.bicep' = {
  scope: resourceGroup(rg.name)
  name: acrPrivateEndpointName
  params: {
    location: location
    privateLinkServiceConnections: [
      {
        name: '${acrPrivateEndpointName}-conn'
        privateLinkServiceId: keyvault.outputs.keyvaultId
        groupIds: [
          'registry'
        ]
      }
    ]
    privateEndpointName: acrPrivateEndpointName
    subnetid: servicesSubnet.id
  }
}

module privateEndpointSA 'modules/vnet/privateendpoint.bicep' = {
  scope: resourceGroup(rg.name)
  name: saPrivateEndpointName
  params: {
    location: location
    privateLinkServiceConnections: [
      {
        name: '${saPrivateEndpointName}-conn'
        privateLinkServiceId: storage.outputs.storageAccountId
        groupIds: [
          'file'
        ]
      }
    ]
    privateEndpointName: saPrivateEndpointName
    subnetid: servicesSubnet.id
  }
}
