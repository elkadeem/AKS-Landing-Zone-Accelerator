using './main.bicep'

param rgName = 'rg-spoke-dev-uksouth-01'
param vnteSpokeName = 'vnet-spoke-dev-uksouth-01'
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
param nsgAKSName = 'nsg-aks-dev-uksouth-01'
param rtAKSSubnetname = 'rt-aks-dev-uksouth-01'
param firewallIP = '10.0.1.4'

param hubSubscriptionId = 'd9d9fded-74d5-4968-85b0-13b4a37711c7'
param hubResourceGroupName = 'rg-hub-dev-uksouth-01'
param hubVnetName = 'vnet-hub-dev-uksouth-01'


param appgwpipName = 'pip-agw-dev-uksouth-01'
param appgwsubnetName = 'AppGWSubnet'
param appgwName = 'agw-dev-uksouth-01'
param availabilityZones = []
param appgwAutoScale = {
  minCapacity: 1
  maxCapacity: 2
}
param nsgappgwName = 'nsg-agw-dev-uksouth-01'
param appgwroutetableName = 'rt-agw-dev-uksouth-01'

