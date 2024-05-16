param identityName string
param location string = resourceGroup().location

resource azidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

output identityResourceId string = azidentity.id
output identityClientId string = azidentity.properties.clientId
output principalId string = azidentity.properties.principalId
