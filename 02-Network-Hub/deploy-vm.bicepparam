using './deploy-vm.bicep'

param rgName = 'rg-hub-dev-uksouth-01'
param vnetName = 'vnet-hub-dev-uksouth-01'
param vnetSubnetname = 'vmsubnet'
param vmsize = 'Standard_B2ms'
param location = 'uksouth'
param adminUsername = 'azureuser'
param adminPassword = readEnvironmentVariable('vmAdminPassword', 'P@ssword@123')

