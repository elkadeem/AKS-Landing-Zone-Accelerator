param principalId string
param roleGuid string
param applicationGatewayName string

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-05-01' existing = {
  name: applicationGatewayName
}

resource role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleGuid)
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
  }
  scope: applicationGateway
}
