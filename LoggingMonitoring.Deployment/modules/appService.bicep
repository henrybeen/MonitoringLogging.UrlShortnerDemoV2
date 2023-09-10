param discriminator string
param location string

param applicationInsightsInstrumentationKey string
param cosmosDbAccountUri string
param cosmosDbDatabaseName string
param cosmosDbContainerName string

param managedIdentityResourceId string
param managedIdentityClientId string

param logAnalyticsWorkspaceId string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'todoapi-${discriminator}'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: 'todoapi-${discriminator}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|6.0'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
}

resource appServiceConfiguration 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsInstrumentationKey
    CosmosDb__AccountUri: cosmosDbAccountUri
    CosmosDb__DatabaseName: cosmosDbDatabaseName
    CosmosDb__ContainerName: cosmosDbContainerName
    CosmosDb__TenantId: subscription().tenantId
    CosmosDb__ManagedIdentityClientId: managedIdentityClientId
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'diagnosticsettings'
  scope: appService
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        timeGrain: 'string'
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

