using './main.bicep'

param rgName = 'rg-aks-staging-weurope-01'
param vnteSpokeName = 'vnet-aks-staging-weurope-01'
param vnetSpokeAddressPrefixes = ['172.17.0.0/16']
param vnetSpokeSubnets = [
  {
    name: 'vmsubnet'
    properties: {
      addressPrefix: '172.17.0.0/24'
    }
  }
  {
    name: 'AKS'
    properties: {
      addressPrefix: '172.17.1.0/24'
    }
  }  
  {
    name: 'datasubnet'
    properties: {
      addressPrefix: '172.17.2.0/24'
    }
  }
  {
    name: 'AppGWSubnet'
    properties: {
      addressPrefix: '172.17.3.0/24'
    }
  }  
  {
    name: 'servicespe'
    properties: {
      addressPrefix: '172.17.4.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
    }
  }
]

//param dhcpOptions = {
  // dnsServers: ['10.0.1.4'] // firewall private IP address if it is DNS server
//}
param nsgAKSName = 'nsg-aks-staging-weurope-01'
param rtAKSSubnetname = 'rt-aks-staging-weurope-01'
param firewallIP = '10.10.50.4'

param hubSubscriptionId = 'e7fe8544-3beb-41e8-b5ea-3bb0de3f7f69'
param hubResourceGroupName = 'TTCDR-Migrated'
param hubVnetName = 'TTCDR'


param appgwpipName = 'pip-agw-staging-weurope-01'
param appgwsubnetName = 'AppGWSubnet'
param appgwName = 'agw-staging-weurope-01'
param availabilityZones = []
param appgwAutoScale = {
  minCapacity: 1
  maxCapacity: 2
}
param nsgappgwName = 'nsg-agw-staging-weurope-01'
param appgwroutetableName = 'rt-agw-staging-weurope-01'

