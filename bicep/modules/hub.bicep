param location string
param cidr string
param tags object
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'hub-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ cidr ] }
    subnets: [
      { name: 'AzureFirewallSubnet', properties: { addressPrefix: '10.100.0.0/26' } }
      { name: 'shared-services', properties: { addressPrefix: '10.100.0.64/26' } }
    ]
  }
}
output vnetId string = vnet.id
