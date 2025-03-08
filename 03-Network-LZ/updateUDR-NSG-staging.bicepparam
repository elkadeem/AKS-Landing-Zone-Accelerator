using './updateUDR-NSG.bicep'

param spokeVnetName = 'vnet-aks-staging-weurope-01'
param aksVNetSubnetName = 'AKS'
param rtAKSSubnetName = 'rt-aks-staging-weurope-01'
param rgName = 'rg-aks-staging-weurope-01'
param nsgAKSName = 'nsg-aks-staging-weurope-01'
param appGatewaySubnetName = 'AppGWSubnet'
param nsgAppGWName = 'nsg-agw-staging-weurope-01'
param rtAppGWSubnetName = 'rt-agw-staging-weurope-01'

