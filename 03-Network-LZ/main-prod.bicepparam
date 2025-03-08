using './main.bicep'

param rgName = 'rg-aks-prod-weurope-01'
param vnteSpokeName = 'vnet-aks-prod-weurope-01'
param vnetSpokeAddressPrefixes = ['172.23.0.0/16']
param vnetSpokeSubnets = [
  {
    name: 'vmsubnet-prod'
    properties: {
      addressPrefix: '172.23.0.0/24'
    }
  }
  {
    name: 'AKS-prod'
    properties: {
      addressPrefix: '172.23.1.0/24'
    }
  }  
  {
    name: 'datasubnet-prod'
    properties: {
      addressPrefix: '172.23.2.0/24'
    }
  }
  {
    name: 'AppGWSubnet-prod'
    properties: {
      addressPrefix: '172.23.3.0/24'
    }
  }  
  {
    name: 'servicespe-prod'
    properties: {
      addressPrefix: '172.23.4.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
    }
  }
]

//param dhcpOptions = {
  // dnsServers: ['10.0.1.4'] // firewall private IP address if it is DNS server
//}
param nsgAKSName = 'nsg-aks-prod-weurope-01'
param rtAKSSubnetname = 'rt-aks-prod-weurope-01'
param firewallIP = ''

param hubSubscriptionId = ''
param hubResourceGroupName = ''
param hubVnetName = ''


param appgwpipName = 'pip-agw-prod-weurope-01'
param appgwsubnetName = 'AppGWSubnet-prod'
param appgwName = 'agw-prod-weurope-01'
param availabilityZones = [
  1
  2
  3
]


param appgwAutoScale = {
  minCapacity: 1
  maxCapacity: 2
}
param nsgappgwName = 'nsg-agw-prod-weurope-01'
param appgwroutetableName = 'rt-agw-prod-weurope-01'

param dnsZonesrgName = 'rg-private-dns-zones'
param dnsZonesresourceGroupSubscriptionId = ''

