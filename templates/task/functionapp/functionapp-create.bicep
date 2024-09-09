targetScope = 'subscription'

param location string = 'westeurope'
param appNameBase string
param appSettings array = []
param envAppSettings array = []
var allAppSettings = union(appSettings, envAppSettings)

var resourceGroupName = '${toLower(appNameBase)}-rg'
var hostingPlanName = '${toLower(appNameBase)}-hp'
var functionAppName = '${toLower(appNameBase)}-fa'
var keyVaultName = '${toLower(appNameBase)}-kv'
var storageAccountName = '${toLower(appNameBase)}-sa'
var logAnalyticsName = '${toLower(appNameBase)}-la'
var appInsightName = '${toLower(appNameBase)}-ai'

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

module logAnalyticsModule '../../../modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  scope: resourceGroup
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
  }
}

module appInsightsModule '../../../modules/appinsights.bicep' = {
  name: 'appInsightsModule'
  scope: resourceGroup
  params: {
    appInsightName: appInsightName
    location: location
    laWorkspaceId: logAnalyticsModule.outputs.laWorkspaceId
  }
}

module storageAccountModule '../../../modules/storageaccount.bicep' = {
  name: 'storageAccountModule'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccountName
  }
}

module functionAppModule '../../../modules/functionapp.bicep' = {
  name: 'functionAppModule'
  scope: resourceGroup
  params: {
    functionAppName: functionAppName
    hostingPlanName: hostingPlanName
    keyVaultName: keyVaultName
    appInsightsName: appInsightName
    storageAccountName: storageAccountName
    appSettings: allAppSettings
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  scope: resourceGroup
  name: functionAppName
}

module keyVaultModule '../../../modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  scope: resourceGroup
  params: {
    keyVaultName: keyVaultName
    objectId: functionApp.identity.principalId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    keysPermissions: [
      'get'
      'list'
    ]
    secretsPermissions: [
      'get'
      'list'
    ]
    location: location
    skuName: 'standard'
  }
}
