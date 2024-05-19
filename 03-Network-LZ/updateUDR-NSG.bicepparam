using './updateUDR-NSG.bicep'

param spokeVnetName = 'vnet-spoke-dev-uksouth-01'
param aksVNetSubnetName = 'AKS'
param rtAKSSubnetName = 'rt-aks-dev-uksouth-01'
param rgName = 'rg-spoke-dev-uksouth-01'
param nsgAKSName = 'nsg-aks-dev-uksouth-01'
param appGatewaySubnetName = 'AppGWSubnet'
param nsgAppGWName = 'nsg-agw-dev-uksouth-01'
param rtAppGWSubnetName = 'rt-agw-dev-uksouth-01'

