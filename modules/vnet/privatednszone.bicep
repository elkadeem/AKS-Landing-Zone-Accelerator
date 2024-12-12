param privateDNSZoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDNSZoneName
  location: 'global'
}

output privateDNSZoneId string = privateDnsZone.id
output privateDNSZoneName string = privateDnsZone.name
