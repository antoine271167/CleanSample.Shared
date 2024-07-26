targetScope = 'resourceGroup'

param storageAccountName string
param location string = resourceGroup().location

var formattedStorageAccountName = toLower(replace(storageAccountName, '-', ''))

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  #disable-next-line BCP334 // giving a warning if a parameter could be shorther than the minimum length
  name: formattedStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
