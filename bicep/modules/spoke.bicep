param location string
param cidr string
param tags object
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'spoke-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ cidr ] }
    subnets: [
      { name: 'app'; properties: { addressPrefix: '10.101.0.0/25' } }
      { name: 'data'; properties: { addressPrefix: '10.101.0.128/25' } }
    ]
  }
}
output vnetId string = vnet.id
