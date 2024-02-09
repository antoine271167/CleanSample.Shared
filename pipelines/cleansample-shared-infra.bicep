targetScope = 'subscription'

param location string = 'westeurope'
param resourcesName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${toLower(resourcesName)}-rg'
  location: location
}

module createAppInsightsModule '../modules/create-appinsights.bicep' = {
  name: 'createAppInsights'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    resourcesName: resourcesName
  }
}
