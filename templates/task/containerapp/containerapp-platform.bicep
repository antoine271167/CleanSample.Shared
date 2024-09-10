targetScope = 'subscription'

param location string = 'westeurope'
param appNameBase string
param appSettings array = []
param envAppSettings array = []
param environmentName string

var allAppSettings = union(appSettings, envAppSettings)
var vnetName = '${toLower(appNameBase)}-vnet'
var resourceGroupName = '${toLower(appNameBase)}-rg'
var uamiName = '${toLower(appNameBase)}-uami'
var containerRegistryName = '${toLower(appNameBase)}-cr'
var keyVaultName = '${toLower(appNameBase)}-kv'
var logAnalyticsName = '${toLower(appNameBase)}-la'
var appInsightName = '${toLower(appNameBase)}-ai'
var containerAppEnvironmentName = '${toLower(appNameBase)}-acae'
var apiManagementName = '${toLower(appNameBase)}-apim'

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

module containerRegistryModule '../../../modules/containerregistry.bicep' = {
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

module appInsightsModule '../../../modules/appinsights.bicep' = {
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
    appInsightKey: appInsightsModule.outputs.InstrumentationKey
    infrastructureSubnetId: virtualNetworkModule.outputs.defaultSubnetId
    location: location
    envrionmentName: containerAppEnvironmentName
    laWorkspaceName: logAnalyticsName
    appSettings: allAppSettings
  }
}

module apiManagementModule '../../../modules/api-management.bicep' = {
  name: 'apiManagementModule'
  scope: resourceGroup
  params: {
    apimServiceName: apiManagementName
    location: location
    sku: 'Developer' // (Premium | Standard | Developer | Basic | Consumption)
    skuCount: 1
    publisherEmail: 'antoine@geboersjes.nl'
    publisherName: 'Antoine Geboers'
    publicIpAddressName: '${appNameBase}-publicip-${environmentName}'
    subnetName: virtualNetworkModule.outputs.apimSubnetName
    virtualNetworkName: virtualNetworkModule.name
  }
}
