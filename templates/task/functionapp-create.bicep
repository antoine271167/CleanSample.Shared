targetScope = 'subscription'

param location string = 'westeurope'
param appName string

var resourceGroupName = '${toLower(appName)}-rg'
var hostingPlanName = '${toLower(appName)}-hp'
var functionAppName = '${toLower(appName)}-fa'
var keyVaultName = '${toLower(appName)}-kv'
var storageAccountName = '${toLower(appName)}-sa'

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

module keyVaultModule '../../modules/create-keyvault-module.bicep' = {
  name: 'keyVaultModule'
  scope: resourceGroup
  params: {
    functionAppName: functionAppName
    keyVaultName: keyVaultName
  }
}

module appInsightsModule '../../modules/create-appinsights-module.bicep' = {
  name: 'appInsightsModule'
  scope: resourceGroup
  params: {
    appName: appName
  }
}

module storageAccountModule '../../modules/create-storageaccount-module.bicep' = {
  name: 'storageAccountModule'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccountName
  }
}

module functionAppModule '../../modules/create-functionapp-module.bicep' = {
  name: 'functionAppModule'
  scope: resourceGroup
  params: {
    functionAppName: functionAppName
    hostingPlanName: hostingPlanName
    keyVaultName: keyVaultName
    appInsightsName: appInsightsModule.outputs.applicationInsightsName
    storageAccountName: storageAccountName
  }
}
