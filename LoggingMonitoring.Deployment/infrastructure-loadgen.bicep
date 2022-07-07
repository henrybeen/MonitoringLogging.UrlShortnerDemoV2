param discriminator string
param location string = resourceGroup().location
param applicationInsightsInstrumentationKey string

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    discriminator: discriminator
    location: location
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionAppDeployment'
  params: {
    discriminator: discriminator
    location: location
    applicationInsightsInstrumentationKey: applicationInsightsInstrumentationKey
    storageAccountConnectionString: storageAccount.outputs.storageAccountConnectionString
  }
}
