targetScope = 'resourceGroup'

param appServicePlanName string
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id
