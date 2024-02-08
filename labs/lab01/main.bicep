targetScope = 'subscription'

metadata name = 'Using Customer-Managed-Keys with User-Assigned identity'
metadata description = 'This instance deploys the module using Customer-Managed-Keys using a User-Assigned Identity to access the Customer-Managed-Key secret.'

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${identifier}-core-rg'
  location: location
}

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${identifier}-workload-rg'
  location: location
}

module core 'core.bicep' = {
  scope: coreResourceGroup
  name: '${uniqueString(deployment().name, location)}-core'
  params: {
    location: location
    identifier: identifier
  }
}

module testDeployment 'br/public:avm/res/storage/storage-account:0.5.0' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-${identifier}'
  params: {
    location: location
    name: '${identifier}saasdsg'
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: core.outputs.subnetResourceId
        privateDnsZoneResourceIds: [
          core.outputs.privateDNSZoneResourceId
        ]
      }
    ]
    blobServices: {
      containers: [
        {
          name: '${identifier}container'
          publicAccess: 'None'
        }
      ]
    }
    managedIdentities: {
      userAssignedResourceIds: [
        core.outputs.managedIdentityResourceId
      ]
    }
    customerManagedKey: {
      keyName: 'keyEncryptionKey'
      keyVaultResourceId: core.outputs.keyVaultResourceId
      userAssignedIdentityResourceId: core.outputs.managedIdentityResourceId
    }
  }
}
