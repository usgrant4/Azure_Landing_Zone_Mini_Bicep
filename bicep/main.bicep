param env string = 'dev'
param location string = resourceGroup().location
param tags object = { env: env, owner: 'platform' }
param hubCidr string = '10.100.0.0/24'
param spokeCidr string = '10.101.0.0/24'

module hub './modules/hub.bicep' = {
  name: 'hub'
  params: { location: location, cidr: hubCidr, tags: tags }
}
module spoke './modules/spoke.bicep' = {
  name: 'spoke'
  params: { location: location, cidr: spokeCidr, tags: tags }
}
module peer './modules/peering.bicep' = {
  name: 'peer'
  params: { hubVnetId: hub.outputs.vnetId, spokeVnetId: spoke.outputs.vnetId }
}
module la './modules/log-analytics.bicep' = {
  name: 'la'
  params: { location: location, tags: tags }
}
module diag './modules/diag-settings.bicep' = {
  name: 'diag'
  params: { laId: la.outputs.workspaceId }
}
module pol './modules/policy-assignments.bicep' = {
  name: 'pol'
  params: { scope: resourceGroup().id, requiredTags: [ 'env', 'owner' ], allowedLocations: [ location ] }
}
