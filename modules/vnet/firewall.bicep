param fwname string
param fwipConfigurations array
param fwipManagementConfigurations object
param fwapplicationRuleCollections array = []
param fwnetworkRuleCollections array = []
param fwnatRuleCollections array = []
param location string = resourceGroup().location
param availabilityZones array
param firewallPolicyId string

resource firewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
  name: fwname
  location: location
  zones: !empty(availabilityZones) ? availabilityZones : null
  properties: {
    sku: { 
      name: 'AZFW_VNet'
      tier: 'Standard' 
    }
    ipConfigurations: fwipConfigurations
    managementIpConfiguration: fwipManagementConfigurations
    //applicationRuleCollections: fwapplicationRuleCollections
    //networkRuleCollections: fwnetworkRuleCollections
    //natRuleCollections: fwnatRuleCollections
    firewallPolicy: {
      id: firewallPolicyId
    }
    //additionalProperties: {
    //  'Network.DNS.EnableProxy': 'True'
    //}
  }
}

output fwPrivateIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output fwName string = firewall.name
