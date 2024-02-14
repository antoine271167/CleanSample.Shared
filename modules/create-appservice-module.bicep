targetScope = 'resourceGroup'

param appServiceName string
param appServicePlanId string
param location string = resourceGroup().location
param appSettings array = []

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: union(appSettings, [
          {
            name: 'SomeAppSetting'
            value: 'SomeAppSettingValue'
          }
        ])
    }
  }
}

output appServicePlanName string = appService.name
output appServicePlanId string = appService.id
