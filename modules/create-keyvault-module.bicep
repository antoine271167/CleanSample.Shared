targetScope = 'resourceGroup'

// If specified, we assume the function app requires access to the keyvault.
param functionAppName string = ''
param keyVaultName string
param location string = resourceGroup().location

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = if (functionAppName != '') {
  name: functionAppName
}

var tenantId = tenant().tenantId

var accessPolicies = functionAppName == '' ? [] : [ {
    tenantId: tenantId
    objectId: functionApp.identity.principalId
    permissions: { secrets: [ 'get' ] }
  } ]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: accessPolicies
  }
}

output keyVaultName string = keyVault.name
