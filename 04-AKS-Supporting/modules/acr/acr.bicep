param acrName string
param acrSkuName string
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSkuName
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Disabled'
  }
}

output acrid string = acr.id
