param discriminator string
param location string

param managedIdentityPrincipalId string
param logAnalyticsWorkspaceId string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  location: location
  name: 'tododb-${discriminator}'
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    disableKeyBasedMetadataWriteAccess: true
    enableAutomaticFailover: false
    locations: [
      {
        isZoneRedundant: false
        locationName: location
      }
    ]
  }
}

var readWriteRoleDefinitionId = guid(cosmosDbAccount.name, 'ReadWriteRole')

resource cosmosReadWriteRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-03-01-preview' = {
  parent: cosmosDbAccount
  name: readWriteRoleDefinitionId
  properties: {
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
        ]
        notDataActions: []
      }
    ]
    roleName: 'Reader Writer'
    type: 'CustomRole'
  }
}

var personalAccountId = 'e66a1b1e-c8ae-4d6f-b5d1-5ef6337c2b88'

resource cosmosDbAccountPersonalAccess 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  parent: cosmosDbAccount
  name: guid(personalAccountId, cosmosDbAccount.id)
  properties: {
    principalId: personalAccountId
    scope: cosmosDbAccount.id
    roleDefinitionId: cosmosReadWriteRoleDefinition.id
  }
}

resource cosmosDbAccountManagedIdentityAccess 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  parent: cosmosDbAccount
  name: guid(managedIdentityPrincipalId, cosmosDbAccount.id)
  properties: {
    principalId: managedIdentityPrincipalId
    scope: cosmosDbAccount.id
    roleDefinitionId: cosmosReadWriteRoleDefinition.id
  }
}

var databaseName = 'tododb'

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  parent: cosmosDbAccount
  location: location
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

var containerName = 'todos'

resource cosmosDBContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
  parent: cosmosDbDatabase
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
    options: {
      throughput: 400
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'diagnosticsettings'
  scope: cosmosDbAccount
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
        timeGrain: 'string'
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

output cosmosDbAccountUri string = 'https://${cosmosDbAccount.name}.documents.azure.com:443/'
output cosmosDbDatabaseName string = databaseName
output cosmosDbContainerName string = containerName
