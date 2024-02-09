targetScope = 'subscription'

param location string = 'westeurope'
param resourcesName string

var resourceGroupName = '${toLower(resourcesName)}-rg'

module createAppInsights '../resources/appinsights/create-appinsights.bicep' = {
  name: 'createAppInsights'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    resourcesName: resourcesName
  }
}
