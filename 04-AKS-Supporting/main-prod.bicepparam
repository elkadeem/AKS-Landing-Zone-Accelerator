using './main.bicep'

param rgName = 'rg-aks-prod-weurope-01'
param location = 'westeurope'
param acrName = ''
param enableAKVPurgeProtection = true
param keyvaultName = 'akv-aks-prod-weurope-001'
param storageAccountName = ''
param storageAccountType = 'Standard_LRS'
param rgSpokevnetName = 'rg-aks-prod-weurope-01'
param vnetSpokeName = 'vnet-aks-prod-weurope-01'
param serviceepSubnetName = 'servicespe-prod'
param keyVaultPrivateEndpointName = 'keyvault-prod-pvt-ep'
param acrPrivateEndpointName = 'acr-prod-pvt-ep'
param saPrivateEndpointName = 'sa-prod-pvt-ep'
param privatednszonesSubscriptionId = ''
param privatednszonesRGName = 'rg-private-dns-zones'
param aksIdentityName = 'aksdevIdentityprod'

