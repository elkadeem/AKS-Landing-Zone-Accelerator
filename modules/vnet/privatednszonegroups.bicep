param privateEndpointName string
param privateDNSZoneId string


resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
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
