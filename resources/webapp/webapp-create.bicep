targetScope = 'resourceGroup'

param location string = resourceGroup().location
param appName string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${toLower(appName)}-sp'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: '${toLower(appName)}-as'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
  }
}
