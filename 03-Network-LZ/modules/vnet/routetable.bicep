param rtName string
param location string = resourceGroup().location

resource rt 'Microsoft.Network/routeTables@2023-11-01' = {
  name: rtName
  location: location
}

output rtId string = rt.id
