param routeTableName string
param routeName string
param properties object

resource rt 'Microsoft.Network/routeTables@2024-05-01' existing = {
  name: routeTableName
}

resource rtroutes 'Microsoft.Network/routeTables/routes@2024-05-01' = {
  name: routeName
  parent: rt
  properties: properties
}
