param location string = resourceGroup().location
param tag string

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: 'cae-kdg-demo-01'
}

resource userAssignedIdentityFrontend 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-kdg-demo-frontend-01'
  location: location
}

resource containerAppFrontend 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'ca-kdg-demo-frontend-01'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityFrontend.id}': {} // Assign as primary identity
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        transport: 'http'
        targetPort: 80
      }
      registries: [
        {
          server: 'kdgdemo01.azurecr.io'
          identity: userAssignedIdentityFrontend.id // Use primary identity to authorize with container registry
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'kdg-demo-frontend'
          image: 'kdgdemo01.azurecr.io/kdg-demo-frontend:${tag}'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }

  }
}

output frontendFqdn string = containerAppFrontend.properties.configuration.ingress.fqdn
