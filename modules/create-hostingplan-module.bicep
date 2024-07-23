targetScope = 'resourceGroup'

param hostingPlanName string
param location string = resourceGroup().location

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

output hostingPlanName string = hostingPlan.name
output hostingPlanId string = hostingPlan.id
