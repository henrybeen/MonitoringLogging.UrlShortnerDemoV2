param discriminator string
param location string = resourceGroup().location

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    discriminator: discriminator
    location: location
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    discriminator: discriminator
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module managedIdentity 'modules/managedIdentity.bicep' = {
  name: 'managedIdentityDeployment'
  params: {
    discriminator: discriminator
    location: location
  }
}

module cosmosDb 'modules/cosmosdb.bicep' = {
  name: 'cosmosDbDeployment'
  params: {
    discriminator: discriminator
    location: location
    managedIdentityPrincipalId: managedIdentity.outputs.managedIdentityPrincipalId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    discriminator: discriminator
    location: location
    applicationInsightsInstrumentationKey: applicationInsights.outputs.applicationInsightsInstrumentationKey
    cosmosDbAccountUri: cosmosDb.outputs.cosmosDbAccountUri
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDbContainerName: cosmosDb.outputs.cosmosDbContainerName
    managedIdentityResourceId: managedIdentity.outputs.managedIdentityResourceId
    managedIdentityClientId: managedIdentity.outputs.managedIdentityClientId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}