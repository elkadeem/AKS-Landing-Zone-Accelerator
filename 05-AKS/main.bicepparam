using './main.bicep'

param rgName = 'rg-aks-dev-uksouth-001'
param location = 'uksouth'
param aksIdentityName = 'aksdevIdentity'
param privateDNSZoneAKSName = ''
param privateDNSZoneAKSNameSubscriptionId = '7c22d273-6ab6-4aa8-802e-e7a993cb2eae'
param privateDNSZoneAKSNameResourceGroup = 'rg-private-dns-zones'
param akslaworkspaceName = 'log-dev-uksouth-001'
param aksvnetName = 'vnet-spoke-dev-uksouth-01'
param vnetspokeRGName = 'rg-spoke-dev-uksouth-01'
param akssubnetName = 'AKS'
param aksAppGatewayName = 'agw-dev-uksouth-01'
param rtAppGWSubnetName = 'AppGWSubnet'
param rtaksName = 'rt-aks-dev-uksouth-01'
param aksClusterName = 'aks-dev-uksouth-001'
param kubernetesVersion = '1.28.9'
param skuName = 'Base'
param skuTier = 'Standard'
param aksadminGroupaccessprincipalId = '0a2a105e-d84a-4af3-9413-7c1b2a8b83ae'
param aksusersgroupaccessprincipalId = '2aa14dab-4397-4d66-9c19-a497be431638'
param enableAzurePolicy = true
param enableOMSAgent = true
param enableIngressApplicationGateway = true
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
param aksNetworkPolicy = 'calico'
param aksOutboundType = 'loadBalancer'

param aksSystemPoolVMSize = 'Standard_D4d_v4'
param aksSystemPoolNodesCount = 3
param aksUserPoolVMSize = 'Standard_D4d_v4'
param aksUserPoolNodesCount = 3

param acrName = 'welkacraksdev001'
param keyvaultName = 'kv-aks-dev-uksouth-003'
