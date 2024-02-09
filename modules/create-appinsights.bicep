targetScope = 'resourceGroup'

param location string = resourceGroup().location
param resourcesName string
param functionAppName string = ''

var logAnalyticsWorkspaceName = '${toLower(resourcesName)}-la'
var applicationInsightsName = '${toLower(resourcesName)}-ai'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  #disable-next-line BCP334
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 31
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

var tags = functionAppName == '' ? {} : {
  'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${functionAppName}': 'Resource'
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: tags
}

output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output applicationInsightsName string = applicationInsights.name
