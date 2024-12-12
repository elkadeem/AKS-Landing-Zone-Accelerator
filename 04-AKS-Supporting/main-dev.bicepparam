using './main.bicep'

param rgName = 'rg-aks-dev-uksouth-001'
param location = 'uksouth'
param acrName = 'welkacraksdev001'
param enableAKVPurgeProtection = false
param keyvaultName = 'kv-aks-dev-uksouth-001'
param storageAccountName = 'welstaksdev001'
param storageAccountType = 'Standard_LRS'
param rgSpokevnetName = 'rg-spoke-dev-uksouth-01'
param vnetSpokeName = 'vnet-spoke-dev-uksouth-01'
param serviceepSubnetName = 'servicespe'
param keyVaultPrivateEndpointName = 'keyvault-pvt-ep'
param acrPrivateEndpointName = 'acr-pvt-ep'
param saPrivateEndpointName = 'sa-pvt-ep'
param privatednszonesSubscriptionId = 'd9d9fded-74d5-4968-85b0-13b4a37711c7'
param privatednszonesRGName = 'rg-spoke-dev-uksouth-01'
param aksIdentityName = 'aksdevIdentity'

