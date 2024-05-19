using './main.bicep'

param rgName = 'rg-aks-dev-uksouth-001'
param location = 'uksouth'
param aksIdentityName = 'aksdevIdentity'
param privateDNSZoneAKSName = ''
param privateDNSZoneAKSNameSubscriptionId = '7c22d273-6ab6-4aa8-802e-e7a993cb2eae'
param privateDNSZoneAKSNameResourceGroup = 'rg-spoke-dev-uksouth-01'
param akslaworkspaceName = 'log-dev-uksouth-001'
param aksvnetName = 'vnet-spoke-dev-uksouth-01'
param vnetspokeRGName = 'rg-spoke-dev-uksouth-01'
param akssubnetName = 'AKS'
param aksAppGatewayName = 'agw-dev-uksouth-01'
param rtAppGWSubnetName = 'AppGWSubnet'
param rtaksName = 'rt-aks-dev-uksouth-01'
param aksClusterName = 'aks-dev-uksouth-001'
param kubernetesVersion = '1.28.9'
param aksSKU = {
  name: 'Base'
  tier: 'Free'
}
param aksadminGroupaccessprincipalId = '0a2a105e-d84a-4af3-9413-7c1b2a8b83ae'
param aksusersgroupaccessprincipalId = '2aa14dab-4397-4d66-9c19-a497be431638'
param enableAzurePolicy = true
param enableOMSAgent = true
param enableIngressApplicationGateway = true
param availabilityZones = []
param enableAutoScaling = true
param enableWorkloadIdentity = true
param autoScalingProfile = {}
param networkPlugin = 'azure'
param acrName = 'welkacraksdev001'
param keyvaultName = 'kv-aks-dev-uksouth-002'

