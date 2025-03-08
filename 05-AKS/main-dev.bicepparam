using './main.bicep'

param rgName = 'rg-spoke-dev-uksouth-01'
param location = 'uksouth'
param aksIdentityName = 'aksdevIdentity'
param privateDNSZoneAKSName = ''
param privateDNSZoneAKSNameSubscriptionId = 'd9d9fded-74d5-4968-85b0-13b4a37711c7'
param privateDNSZoneAKSNameResourceGroup = 'rg-private-dns-zones'
param akslaworkspaceName = 'log-dev-uksouth-001'
param aksvnetName = 'vnet-spoke-dev-uksouth-01'
param vnetspokeRGName = 'rg-spoke-dev-uksouth-01'
param akssubnetName = 'AKS'
param aksAppGatewayName = 'agw-dev-uksouth-01'
param rtAppGWSubnetName = 'rt-agw-dev-uksouth-01'
param rtaksName = 'rt-aks-dev-uksouth-01'
param aksClusterName = 'aks-dev-uksouth-001'
param kubernetesVersion = '1.30.6'
param skuName = 'Base'
param skuTier = 'Standard'
param aksadminGroupaccessprincipalId = '9e5ecd43-d840-4364-a5f2-72ac19390017'
param aksusersgroupaccessprincipalId = '63f6da8f-f001-4123-9b8e-de2dfab5c772'
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
param aksPodCidr = '172.50.0.0/16'
param aksServiceCidr = '192.168.100.0/24'
param aksDnsServiceIP = '192.168.100.10'
param aksNetworkPolicy = 'azure'
param aksOutboundType = 'userDefinedRouting'

param aksSystemPoolVMSize = 'Standard_D4d_v4'
param aksSystemPoolNodesCount = 3
param aksUserPoolVMSize = 'Standard_D4d_v4'
param aksUserPoolNodesCount = 3

param acrName = 'welkacraksdev001'
param keyvaultName = 'kv-aks-dev-uksouth-001'
