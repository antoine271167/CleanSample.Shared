@description('Name of the Azure Container App environment')
param envrionmentName string
param location string = resourceGroup().location
param appInsightKey string
param infrastructureSubnetId string
param laWorkspaceName string
param appSettings array = []

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: laWorkspaceName
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: envrionmentName
  location: location
  dependsOn: [
    logAnalytics
  ]
  properties: {
    daprAIInstrumentationKey: appInsightKey
    vnetConfiguration: {
      internal: true
      infrastructureSubnetId: infrastructureSubnetId
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

output staticIp string = environment.properties.staticIp
