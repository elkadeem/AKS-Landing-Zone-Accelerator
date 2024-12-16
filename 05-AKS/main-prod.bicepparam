using './main.bicep'

param rgName = 'rg-aks-prod-weurope-01'
param location = 'westeurope'
param aksIdentityName = 'sdevIdentityprod'
param privateDNSZoneAKSName = ''
param privateDNSZoneAKSNameSubscriptionId = 'e7fe8544-3beb-41e8-b5ea-3bb0de3f7f69'
param privateDNSZoneAKSNameResourceGroup = 'rg-private-dns-zones'
param akslaworkspaceName = 'log-prod-weurope-001'
param aksvnetName = 'vnet-aks-prod-weurope-01'
param vnetspokeRGName = 'rg-aks-prod-weurope-01'
param akssubnetName = 'AKS-prod'
param aksAppGatewayName = 'agw-prod-weurope-01'
param rtAppGWSubnetName = 'rt-agw-prod-weurope-01'
param rtaksName = 'rt-aks-prod-weurope-01'
param aksClusterName = 'aks-prod-weurope-001'
param kubernetesVersion = '1.30.6'
param skuName = 'Base'
param skuTier = 'Standard'
param aksadminGroupaccessprincipalId = 'e748c542-5434-417a-a4a5-2d125ce84d54'
param aksusersgroupaccessprincipalId = '758418a2-9431-45d7-90d6-9773b859b9f2'
param enableAzurePolicy = true
param enableOMSAgent = true
param enableIngressApplicationGateway = false
param availabilityZones = [
  1 
  2 
  3
]
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
param aksPodCidr = '10.122.0.0/16'
param aksServiceCidr = '192.168.121.0/24'
param aksDnsServiceIP = '192.168.121.10'
param aksNetworkPolicy = 'azure'
param aksOutboundType = 'userDefinedRouting'

param aksSystemPoolVMSize = 'Standard_D2as_v6'
param aksSystemPoolNodesCount = 3
param aksSystemPoolNodeMin = 3
param aksSystemPoolNodeMax=3
param aksUserPoolVMSize = 'Standard_D2as_v6'
param aksUserPoolNodesCount = 3
param aksUserPoolNodeMin = 3
param aksUserPoolNodeMax= 3

param acrName = 'rafedacrprod001'
param keyvaultName3 = 'akv-aks-prod-weurope-001'
