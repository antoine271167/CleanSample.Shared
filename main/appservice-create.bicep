targetScope = 'subscription'

param location string = 'westeurope'
param appName string
param appSettings array = []
param envAppSettings array = []

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${toLower(appName)}-rg'
  location: location
}

module appServicePlanModule '../modules/create-appserviceplan-module.bicep' = {
  name: 'appServicePlanModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    appServicePlanName: '${toLower(appName)}-sp'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' existing = {
  name: '${toLower(appName)}-sp'
  scope: resourceGroup
}

module appServiceModule '../modules/create-appservice-module.bicep' = {
  name: 'appServiceModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    appServiceName: '${toLower(appName)}-as'
    appServicePlanId: appServicePlan.id
    appSettings: union(appSettings, envAppSettings)
  }
}