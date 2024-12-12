param privateDNSZoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: 'global'
}

output privateDNSZoneId string = privateDnsZone.id
output privateDNSZoneName string = privateDnsZone.name
