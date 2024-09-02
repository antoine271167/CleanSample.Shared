targetScope = 'subscription'

param location string = 'westeurope'
param appNameBase string
param appSettings array = []
param envAppSettings array = []

var resourceGroupName = '${toLower(appNameBase)}-rg'
var hostingPlanName = '${toLower(appNameBase)}-hp'
var appServiceName = '${toLower(appNameBase)}-as'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module hostingPlanModule '../../../modules/hostingplan.bicep' = {
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

module appServiceModule '../../../modules/appservice.bicep' = {
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
