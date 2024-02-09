targetScope = 'resourceGroup'

param location string = resourceGroup().location
param appName string
param sharedResourcesName string
param appSettings array = []
param envAppSettings array = []

var functionAppName = '${toLower(appName)}-fa'
var hostingPlanName = '${toLower(appName)}-hp'
var appInsightsName = '${toLower(sharedResourcesName)}-ai'
var storageAccountName = '${replace(toLower(appName), '-', '')}sa'
var keyVaultName = '${toLower(appName)}-kv'
var sharedResourceGroup = '${toLower(sharedResourcesName)}-rg'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  #disable-next-line BCP334
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(sharedResourceGroup)
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

module createKeyVaultNew '../modules/create-keyvault.bicep' = {
  name: 'createKeyVaultNew'
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource storageAccountSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'StorageAccount-ConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    keyVault
  ]
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    siteConfig: {
      appSettings: union(appSettings, envAppSettings, [
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: appInsights.properties.InstrumentationKey
          }
          {
            name: 'AzureWebJobsStorage'
            value: '@Microsoft.KeyVault(SecretUri=${storageAccountSecret.properties.secretUriWithVersion})'
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'dotnet'
          }
          {
            name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
            value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' }
          {
            name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
            value: 'true'
          }
          {
            name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
            value: '3'
          }
          {
            name: 'WEBSITE_RUN_FROM_PACKAGE'
            value: '1'
          }
          {
            name: 'WEBSITE_TIME_ZONE'
            value: 'W. Europe Standard Time'
          }
        ])
    }
  }
}

module createAppInsights '../modules/create-appinsights.bicep' = {
  name: 'createAppInsights'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    location: location
    resourcesName: sharedResourcesName
    functionAppName: functionAppName
  }
}

module createKeyVault '../modules/create-keyvault.bicep' = {
  name: 'createKeyVault'
  dependsOn: [
    keyVault
    functionApp
  ]
  params: {
    location: location
    keyVaultName: keyVaultName
    functionAppName: functionAppName
  }
}
