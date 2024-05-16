param vnetName string
param peeringName string
param properties object

resource peering 'Microsoft.Databricks/workspaces/virtualNetworkPeerings@2023-02-01' = {
  name: '${vnetName}/${peeringName}'
  properties: properties
}
