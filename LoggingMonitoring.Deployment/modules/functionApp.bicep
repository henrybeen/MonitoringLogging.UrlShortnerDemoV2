param discriminator string
param location string
param applicationInsightsInstrumentationKey string
param storageAccountConnectionString string

resource functionPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'todoapi-load-${discriminator}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'todoapi-load-gen${discriminator}'
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }

  resource functionAppConfiguration 'config@2021-02-01' = {
    name: 'appsettings'
    properties: {
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      WEBSITE_TIME_ZONE: 'W. Europe Standard Time'
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsInstrumentationKey
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
      WEBSITE_CONTENTSHARE: 'function-package'
      WEBSITE_RUN_FROM_PACKAGE: '1'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      AzureWebJobsStorage: storageAccountConnectionString
      AzureWebJobsDashboard: storageAccountConnectionString
    }
  }
}
