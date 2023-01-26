param location string = 'westeurope'

// Container Registry
param acr string = 'kdgdemo01'
param acrSku string = 'Basic'
param acrIsAdminEnabled bool = true

// Log Analytics
param la string = 'la-kdg-demo-01'
param laSku string = 'PerGB2018'
param laRetentionInDays int = 90
param laDailyQuotaInGb int = 5

// Container App Environment
param cae string = 'cae-kdg-demo-01'
param caeLogDestination string = 'log-analytics'

// Azure Kubernetes Services
param aks string = 'aks-kdg-demo-01'
param aksAgentPool string = 'main'
param aksMinAgentCount int = 1
param aksMaxAgentCount int = 5
param aksVmSku string = 'Standard_D4ads_v5'
param aksOsDiskSize int = 0 // Default to vmSku's disk size
param aksEnableAutoscaling bool = true
param aksAdminUser string = 'agentpool'
param aksSshPublicKey string
param aksEnableIngressController bool = true

/*
* Infrastructure resources
*/

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acr
  location: location
  sku: {
    name: 'Basic'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'la-kdg-demo-01'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    workspaceCapping: {
      dailyQuotaGb: 5
    }
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: 'cae-kdg-demo-01'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource azureKubernetesServices 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: aks
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aks
    agentPoolProfiles: [
      {
        name: aksAgentPool
        osDiskSizeGB: aksOsDiskSize
        count: aksMinAgentCount
        minCount: aksMinAgentCount
        maxCount: aksMaxAgentCount
        vmSize: aksVmSku
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: aksEnableAutoscaling
      }
    ]
    linuxProfile: {
      adminUsername: aksAdminUser
      ssh: {
        publicKeys: [
          {
            keyData: aksSshPublicKey
          }
        ]
      }
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: aksEnableIngressController
      }
    }
  }
}
