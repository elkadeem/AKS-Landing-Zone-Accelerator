param routeTableName string
param routeName string
param properties object

resource rt 'Microsoft.Network/routeTables@2023-11-01' existing = {
  name: routeTableName
}

resource rtroutes 'Microsoft.Network/routeTables/routes@2017-10-01' = {
  name: routeName
  parent: rt
  properties: properties
}
