using './main.bicep'

param rgName = 'rg-hub-dev-uksouth-01'
param vnetHubName = 'vnet-hub-dev-uksouth-01'
param hubVnetAddressPrefixes = [
  '10.0.0.0/16'
]
param hubSubnets = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: '10.0.1.0/26'
    }
  }
  {
    name: 'AzureFirewallManagementSubnet'
    properties: {
      addressPrefix: '10.0.4.0/26'
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: '10.0.2.0/27'
    }
  }
  {
    name: 'vmsubnet'
    properties: {
      addressPrefix: '10.0.3.0/24'
    }
  }
]
param azfwName = 'azfw-hub-dev-uksouth-01'
param rtVMSubnetname = 'rt-vm-subnet'
param fwApplicationRuleCollections = [
  {
    name: 'Helper-tools'
    properties: {
      priority: 101
      action: {
        type: 'Allow'
      }
      rules: [
        {
          name: 'Allow-ifconfig'
          protocols: [
            {
              protocolType: 'Http'
              port: 80
            }
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          sourceAddresses: ['10.1.1.0/24']
          targetFqdns: [
            'ifconfig.co'
            'api.snapcraft.io'
            'jsonip.com'
            'kubernaut.io'
            'motd.ubuntu.com'
          ]
        }
      ]
    }
  }
  {
    name: 'AKS-egress-application'
    properties: {
      priority: 102
      action: {
        type: 'Allow'
      }
      rules: [
        {
          name: 'AKS-Egress'
          protocols: [
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          sourceAddresses: ['10.1.1.0/24']
          targetFqdns: [
            '*.azmk8s.io'
            'aksrepos.azurecr.io'
            '*.blob.core.windows.net'
            '*.cdn.mscr.io'
            '*.opinsights.azure.com'
            '*.monitoring.azure.com'
          ]
        }
        {
          name: 'Registries'
          protocols: [
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          sourceAddresses: ['10.1.1.0/24']
          targetFqdns: [
            '*.azurecr.io'
            '*.gcr.io'
            '*.docker.io'
            'quay.io'
            '*.quay.io'
            '*.cloudfront.net'
            'production.cloudflare.docker.com'
          ]
        }
        {
          name: 'Additional-Usefull-Address'
          protocols: [
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          sourceAddresses: ['10.1.1.0/24']
          targetFqdns: [
            'grafana.net'
            'grafana.com'
            'stats.grafana.org'
            'github.com'
            'charts.bitnami.com'
            'raw.githubusercontent.com'
            '*.letsencrypt.org'
            'usage.projectcalico.org'
            'vortex.data.microsoft.com'
          ]
        }
        {
          name: 'AKS-FQDN-TAG'
          protocols: [
            {
              protocolType: 'Http'
              port: 80
            }
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          sourceAddresses: ['10.1.1.0/24']
          targetFqdns: []
          fqdnTags: ['AzureKubernetesService']
        }
      ]
    }
  }
]
param fwNetworkRuleCollections = [
  {
    name: 'AKS-egress'
    properties: {
      priority: 100
      action: {
        type: 'Allow'
      }
      rules: [
        {
          name: 'NTP'
          protocols: ['UDP']
          sourceAddresses: ['10.1.1.0/24']
          destinationAddresses: ['*']
          destinationPorts: ['123']
        }
        {
          name: 'APITCP'
          protocols: ['TCP']
          sourceAddresses: ['10.1.1.0/24']
          destinationAddresses: ['*']
          destinationPorts: ['900']
        }
        {
          name: 'APIUDP'
          protocols: ['UDP']
          sourceAddresses: ['10.1.1.0/24']
          destinationAddresses: ['*']
          destinationPorts: ['1194']
        }
      ]
    }
  }
]
param fwNatRuleCollections = []
param location = 'uksouth'
param availabilityZones = []
