param functionAppName string
param hostingPlanName string
param keyVaultName string
param appInsightsName string
param storageAccountName string
param location string = resourceGroup().location
param appSettings array = []

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' existing = {
  name: hostingPlanName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: toLower(replace(storageAccountName, '-', ''))
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
    hostingPlan
    keyVault
  ]
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    siteConfig: {
      appSettings: union(appSettings, [
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
            value: 'dotnet-isolated'
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
