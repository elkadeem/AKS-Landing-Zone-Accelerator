targetScope = 'subscription'

param rgName string
param location string = deployment().location

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



