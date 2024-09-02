targetScope = 'subscription'

param location string = 'westeurope'
param appNameBase string

var vnetName = '${toLower(appNameBase)}-vnet'
var resourceGroupName = '${toLower(appNameBase)}-rg'
var uamiName = '${toLower(appNameBase)}-uami'
var containerRegistryName = '${toLower(appNameBase)}-cr'
var keyVaultName = '${toLower(appNameBase)}-kv'
var logAnalyticsName = '${toLower(appNameBase)}-la'
var appInsightName = '${toLower(appNameBase)}-ai'
var containerAppEnvironmentName = '${toLower(appNameBase)}-acae'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module virtualNetworkModule '../../../modules/virtual-network.bicep' = {
  name: 'virtualNetworkModule'
  scope: resourceGroup
  params: {
    vnetName: vnetName
    location: location    
  }
}

module uamiModule '../../../modules/userassigned-managedidentity.bicep' = {
  name: 'uamiModule'
  scope: resourceGroup
  params: {
    uamiName: uamiName
    location: location
  }
}

module containerRegistryModule  '../../../modules/containerregistry.bicep' = {
  name: 'containerRegistryModule'
  scope: resourceGroup
  params: {
    location: location
    registryName: containerRegistryName
    skuName: 'Basic'
    userAssignedIdentityPrincipalId: uamiModule.outputs.principalId
    adminUserEnabled: false
  }
}

module keyVaultModule '../../../modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  scope: resourceGroup
  params: {
    keyVaultName: keyVaultName
    objectId: uamiModule.outputs.principalId
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

module logAnalyticsModule '../../../modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  scope: resourceGroup
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
  }
}

module appInsights '../../../modules/appinsights.bicep' = {
  name: 'appInsightsModule'
  scope: resourceGroup
  params: {
    appInsightName: appInsightName
    location: location
    laWorkspaceId: logAnalyticsModule.outputs.laWorkspaceId
  }
}

module acaEnvironmentModule '../../../modules/containerapp-environment.bicep' = {
  name: 'acaEnvironmentModule'
  scope: resourceGroup
  params: {
    appInsightKey: appInsights.outputs.InstrumentationKey
    infrastructureSubnetId: virtualNetworkModule.outputs.defaultSubnetId
    location: location
    envrionmentName: containerAppEnvironmentName
    laWorkspaceName: logAnalyticsName
  }
}
