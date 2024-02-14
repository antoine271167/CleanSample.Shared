targetScope = 'subscription'

param location string = 'westeurope'
param appName string
param appSettings array = []
param envAppSettings array = []

var resourceGroupName = '${toLower(appName)}-rg'
var appServicePlanName = '${toLower(appName)}-sp'
var appServiceName = '${toLower(appName)}-as'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module appServicePlanModule '../modules/create-appserviceplan-module.bicep' = {
  name: 'appServicePlanModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    appServicePlanName: appServicePlanName
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' existing = {
  name: appServicePlanName
  scope: resourceGroup
}

module appServiceModule '../modules/create-appservice-module.bicep' = {
  name: 'appServiceModule'
  scope: resourceGroup
  dependsOn: [
    appServicePlan
  ]
  params: {
    location: resourceGroup.location
    appServiceName: appServiceName
    appServicePlanId: appServicePlan.id
    appSettings: union(appSettings, envAppSettings)
  }
}
