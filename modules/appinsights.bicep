@description('Application Insights name')
param appInsightName string
param laWorkspaceId string
param location string = resourceGroup().location
param appNameBase string = ''

var tags = appNameBase == ''
  ? {}
  : {
      'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${appNameBase}': 'Resource'
    }

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: laWorkspaceId
  }
  tags: tags
}

output InstrumentationKey string = appInsights.properties.InstrumentationKey
output ConnectionString string = appInsights.properties.ConnectionString
