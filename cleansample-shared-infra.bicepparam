using 'cleansample-shared-infra.bicep'

var resourcesNameBase = readEnvironmentVariable('resourcesNameBase', '')

param resourceGroupName = '${toLower(resourcesNameBase)}-rg'
param logAnalyticsName = '${toLower(resourcesNameBase)}-la'
param appInsightName = '${toLower(resourcesNameBase)}-ai'
