param containerAppsEnvName string
param location string
param sqlServerName string
param sqlDatabaseName string
param sqlAdminLogin string
param sqlAdminLoginPassword string

resource cappsEnv 'Microsoft.Web/kubeEnvironments@2021-03-01' existing = {
  name: containerAppsEnvName
}

resource bootstrapper 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'bootstrapper'
  location: location
  properties: {
    kubeEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'bootstrapper'
          image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-bootstrapper:latest'
          env: [
            {
              name: 'reddog-sql'
              secretRef: 'reddog-sql'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
      }
      dapr: {
        enabled: true
        appId: 'bootstrapper'
      }
    }
    configuration: {
      secrets: [
        {
          name: 'reddog-sql'
          value: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
    }
  }
}
