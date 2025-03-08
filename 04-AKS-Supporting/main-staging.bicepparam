using './main.bicep'

param rgName = 'rg-aks-staging-weurope-01'
param location = 'westeurope'
param acrName = ''
param enableAKVPurgeProtection = false
param keyvaultName = 'akv-aks-stg-weurope-001'
param storageAccountName = ''
param storageAccountType = 'Standard_LRS'
param rgSpokevnetName = 'rg-aks-staging-weurope-01'
param vnetSpokeName = 'vnet-aks-staging-weurope-01'
param serviceepSubnetName = 'servicespe'
param keyVaultPrivateEndpointName = 'keyvault-pvt-ep'
param acrPrivateEndpointName = 'acr-pvt-ep'
param saPrivateEndpointName = 'sa-pvt-ep'
param privatednszonesSubscriptionId = ''
param privatednszonesRGName = 'rg-private-dns-zones'
param aksIdentityName = 'aksdevIdentity'

