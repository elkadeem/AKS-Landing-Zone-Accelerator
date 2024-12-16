using './main.bicep'

param rgName = 'rg-aks-staging-weurope-01'
param location = 'westeurope'
param aksIdentityName = 'aksdevIdentity'
param privateDNSZoneAKSName = ''
param privateDNSZoneAKSNameSubscriptionId = 'e7fe8544-3beb-41e8-b5ea-3bb0de3f7f69'
param privateDNSZoneAKSNameResourceGroup = 'rg-aks-staging-weurope-01'
param akslaworkspaceName = 'log-staging-weurope-001'
param aksvnetName = 'vnet-aks-staging-weurope-01'
param vnetspokeRGName = 'rg-aks-staging-weurope-01'
param akssubnetName = 'AKS'
param aksAppGatewayName = 'agw-staging-weurope-01'
param rtAppGWSubnetName = 'rt-agw-staging-weurope-01'
param rtaksName = 'rt-aks-staging-weurope-01'
param aksClusterName = 'aks-staging-weurope-001'
param kubernetesVersion = '1.30.6'
param skuName = 'Base'
param skuTier = 'Standard'
param aksadminGroupaccessprincipalId = 'f333f856-6e90-4b74-94ae-45afb8e2451a'
param aksusersgroupaccessprincipalId = '4ce4970a-d07e-4c2a-91ba-d9b68f3f752a'
param enableAzurePolicy = true
param enableOMSAgent = true
param enableIngressApplicationGateway = false
param availabilityZones = []
param enableAutoScaling = true
param enableWorkloadIdentity = true
param autoScalingProfile = {
  'balance-similar-node-groups': 'false'
  expander: 'random'
  'max-empty-bulk-delete': '10'
  'max-graceful-termination-sec': '600'
  'max-node-provision-time': '15m'
  'max-total-unready-percentage': '45'
  'new-pod-scale-up-delay': '0s'
  'ok-total-unready-count': '3'
  'scale-down-delay-after-add': '10m' 
  'scale-down-delay-after-delete': '10s'
  'scale-down-delay-after-failure': '3m' 
  'scale-down-unneeded-time': '10m'
  'scale-down-unready-time': '20m'
  'scale-down-utilization-threshold': '0.5'
  'scan-interval': '10s'
  'skip-nodes-with-local-storage': 'false'
  'skip-nodes-with-system-pods': 'true'
}
param aksNetworkPlugin = 'azure'
param aksNetworkPluginMode = 'overlay'
param aksPodCidr = '10.121.0.0/16'
param aksServiceCidr = '192.168.121.0/24'
param aksDnsServiceIP = '192.168.121.10'
param aksNetworkPolicy = 'azure'
param aksOutboundType = 'userDefinedRouting'

param aksSystemPoolVMSize = 'Standard_D2as_v6'
param aksSystemPoolNodesCount = 3
param aksUserPoolVMSize = 'Standard_D2as_v6'
param aksUserPoolNodesCount = 3

param acrName = 'rafedacrstg001'
param keyvaultName = 'akv-aks-stg-weurope-001'
