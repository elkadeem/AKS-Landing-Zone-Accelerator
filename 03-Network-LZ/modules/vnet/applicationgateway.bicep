param appgwname string
param subnetId string
param appgwpip string
param location string = resourceGroup().location
param availabilityZones array = []
param appgwAutoScale object

var frontendIPConfiugrationName = 'appGatewayFrontendIP'
var frontendport = 'appGatewayFrontendPort'
var backendpoolname = 'appGatewayBackendPool'
var backendhttpsettingsname = 'appGatewayBackendHttpSettings'
var httpListenerName = 'appGatewayHttpListener'

resource appgw 'Microsoft.Network/applicationGateways@2023-11-01' = {
 name: appgwname
 location: location
 zones: !empty(availabilityZones)? availabilityZones : null
 properties:{
  sku: {
    tier: 'Standard_v2'
    name: 'Standard_v2'
    capacity: empty(appgwAutoScale)? 2 : null
  }
  autoscaleConfiguration: !empty(appgwAutoScale)? appgwAutoScale : null
  gatewayIPConfigurations: [
    {
      name: 'appGateway-Ip-Config'
      properties: {
        subnet: {
          id: subnetId
        }        
      }
    }
  ]
  frontendIPConfigurations: [
    {
      name: frontendIPConfiugrationName
      properties: {
        publicIPAddress: {
          id: appgwpip
        }
      }
    }
  ]
  frontendPorts: [
    {
      name: frontendport
      properties: {
        port: 80
      }
    }
  ]
  backendAddressPools: [
    {
      name: backendpoolname     
    }
  ]
  backendHttpSettingsCollection: [
    {
      name: backendhttpsettingsname
      properties: {
        cookieBasedAffinity: 'Disabled'
        path: '/'
        port: 80
        protocol: 'Http'
        requestTimeout: 60
      }
    }
  ]
  httpListeners: [
    {
      name: httpListenerName
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwname, frontendIPConfiugrationName)
        }
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwname, frontendport)
        }
        protocol: 'Http'
      }
    }
  ]
  requestRoutingRules: [
    {
      name: 'appGatewayRule'
      properties: {
        ruleType: 'Basic'
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwname, httpListenerName)
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwname, backendpoolname)
        }
        backendHttpSettings: {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgwname, backendhttpsettingsname)
        }
      }
    }
  ]
 }
}
