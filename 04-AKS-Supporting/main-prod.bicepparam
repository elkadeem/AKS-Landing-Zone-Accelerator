using './main.bicep'

param rgName = 'rg-aks-prod-weurope-01'
param location = 'westeurope'
param acrName = 'rafedacrprod001'
param enableAKVPurgeProtection = true
param keyvaultName = 'akv-aks-prod-weurope-001'
param storageAccountName = 'rafedsaaksprod001'
param storageAccountType = 'Standard_LRS'
param rgSpokevnetName = 'rg-aks-prod-weurope-01'
param vnetSpokeName = 'vnet-aks-prod-weurope-01'
param serviceepSubnetName = 'servicespe-prod'
param keyVaultPrivateEndpointName = 'keyvault-prod-pvt-ep'
param acrPrivateEndpointName = 'acr-prod-pvt-ep'
param saPrivateEndpointName = 'sa-prod-pvt-ep'
param privatednszonesSubscriptionId = 'e7fe8544-3beb-41e8-b5ea-3bb0de3f7f69'
param privatednszonesRGName = 'rg-aks-prod-weurope-01'
param aksIdentityName = 'aksdevIdentityprod'

