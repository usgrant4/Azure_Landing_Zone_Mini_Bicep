param location string
param tags object
resource la 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'alz-la'
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}
output workspaceId string = la.id
