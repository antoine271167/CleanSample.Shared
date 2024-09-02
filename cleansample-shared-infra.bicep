targetScope = 'subscription'

param location string = 'westeurope'
param resourceGroupName string
param logAnalyticsName string
param appInsightName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module logAnalyticsModule 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  scope: resourceGroup
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
  }
}

module appInsightsModule 'modules/appinsights.bicep' = {
  name: 'appInsightsModule'
  scope: resourceGroup
  params: {
    appInsightName: appInsightName
    location: location
    laWorkspaceId: logAnalyticsModule.outputs.laWorkspaceId
  }
}
