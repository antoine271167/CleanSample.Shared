targetScope = 'resourceGroup'

param appServiceName string
param appServicePlanId string
param location string = resourceGroup().location

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
  }
}

output appServicePlanName string = appService.name
output appServicePlanId string = appService.id
