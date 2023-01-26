param location string = resourceGroup().location
param tag string

/*
* User assigned identity used for the frontend container app.
* This will need to get assigned the AcrPull permission on the container registry to be able to pull images
*/
resource userAssignedIdentityFrontend 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-kdg-demo-frontend-01'
  location: location
}

/*
* Container app environment, used as a cluster to host Container Apps on.
* This is an existing resource that is setup via another deployment, which can be used to retrieve properties like id's.
* Here it is used to link a new Container App to this Container App Environment.
*/
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: 'cae-kdg-demo-01'
}

/*
* Container App hosting the frontend (ServerSide Blazor) application.
*/
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

/*
* Pass the address of the frontend application as output parameter so it can be used by following steps in deployment pipeline.
* In this case, it is passed as value to the Helm chart that will deploy the custom scaler so it can retrieve the number of sessions.
*/
output frontendFqdn string = containerAppFrontend.properties.configuration.ingress.fqdn
