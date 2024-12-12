param privateEndpointName string
param subnetid string
param privateLinkServiceConnections array
param location string = resourceGroup().location

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetid
    }
    privateLinkServiceConnections: privateLinkServiceConnections
  }
}

output privateEndpointId string = privateEndpoint.id
