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
param privatednszonesSubscriptionId string = subscription().subscriptionId
param privatednszonesRGName string = rgName
param privateDNSZoneACRName string = 'privatelink${environment().suffixes.acrLoginServer}'
param privateDNSZoneKVName string = 'privatelink.vaultcore.azure.net'
param privateDNSZoneSAName string = 'privatelink.file.${environment().suffixes.storage}'
param aksIdentityName string = 'aksIdentity'


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

resource privateDNSZoneACR 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(privatednszonesSubscriptionId, privatednszonesRGName)
  name: privateDNSZoneACRName
}

module privateEndpointACRDNSSetting 'modules/vnet/privatednszonegroups.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acr-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneACR.id
    privateEndpointName: privateEndpointAcr.name
  }
}

resource privateDNSZoneKV 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(privatednszonesSubscriptionId, privatednszonesRGName)
  name: privateDNSZoneKVName
}

module privateEndpointKVDNSSetting 'modules/vnet/privatednszonegroups.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'kv-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneKV.id
    privateEndpointName: privateEndpointKeyVault.name
  }
}


resource privateDNSZoneSA 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(privatednszonesSubscriptionId, privatednszonesRGName)
  name: privateDNSZoneSAName
}

module privateEndpointSADNSSetting 'modules/vnet/privatednszonegroups.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'sa-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneSA.id
    privateEndpointName: privateEndpointSA.name
  }
}

module aksIdentity 'modules//identity/userassignidentity.bicep' = {
  scope: resourceGroup(rg.name)
  name: aksIdentityName
  params: {
    location: location
    identityName: aksIdentityName
  }
}

output acrName string = acr.name
output keyvaultName string = keyvault.name
