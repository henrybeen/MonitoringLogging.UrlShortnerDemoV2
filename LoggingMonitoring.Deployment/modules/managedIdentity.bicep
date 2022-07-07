param discriminator string
param location string

resource functionIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'apiIdentity-${discriminator}'
  location: location
}

output managedIdentityResourceId string = functionIdentity.id
output managedIdentityPrincipalId string = functionIdentity.properties.principalId
output managedIdentityClientId string = functionIdentity.properties.clientId
