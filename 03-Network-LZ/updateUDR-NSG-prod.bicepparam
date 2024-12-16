using './updateUDR-NSG.bicep'

param rgName = 'rg-aks-prod-weurope-01'
param spokeVnetName = 'vnet-aks-prod-weurope-01'
param aksVNetSubnetName = 'AKS-prod'
param rtAKSSubnetName = 'rt-aks-prod-weurope-01'
param nsgAKSName = 'nsg-aks-prod-weurope-01'
param appGatewaySubnetName = 'AppGWSubnet'
param nsgAppGWName = 'nsg-agw-prod-weurope-01'
param rtAppGWSubnetName = 'rt-agw-prod-weurope-01'

