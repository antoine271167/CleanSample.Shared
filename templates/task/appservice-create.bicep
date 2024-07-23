targetScope = 'subscription'

param location string = 'westeurope'
param appName string
param appSettings array = []
param envAppSettings array = []

var resourceGroupName = '${toLower(appName)}-rg'
var hostingPlanName = '${toLower(appName)}-hp'
var appServiceName = '${toLower(appName)}-as'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module hostingPlanModule '../../modules/create-hostingplan-module.bicep' = {
  name: 'hostingPlanModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    hostingPlanName: hostingPlanName
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' existing = {
  name: hostingPlanName
  scope: resourceGroup
}

module appServiceModule '../../modules/create-appservice-module.bicep' = {
  name: 'appServiceModule'
  scope: resourceGroup
  dependsOn: [
    hostingPlan
  ]
  params: {
    location: resourceGroup.location
    appServiceName: appServiceName
    appServicePlanId: hostingPlan.id
    appSettings: union(appSettings, envAppSettings)
  }
}
