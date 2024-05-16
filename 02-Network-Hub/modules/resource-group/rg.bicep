targetScope = 'subscription'
param location string = deployment().location
param rgName string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

output rgId string = rg.id
output rgName string = rg.name
