param privateEndpointName string
param privateDNSZoneId string


resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: '${privateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${privateEndpointName}-config'
        properties: {
          privateDnsZoneId: privateDNSZoneId          
        }        
      }
    ]
  }
}
