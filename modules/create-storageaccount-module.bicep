targetScope = 'resourceGroup'

param storageAccountName string
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  #disable-next-line BCP334 // giving a warning if a parameter could be shorther than the minimum length
  name: toLower(replace(storageAccountName, '-', ''))
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
