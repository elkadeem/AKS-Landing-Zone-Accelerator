targetScope = 'subscription'
param location string = deployment().location
param rgName string

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: rgName
  location: location
  properties: {
  
  }
}

output rgId string = rg.id
output rgName string = rg.name
