targetScope = 'subscription'

metadata name = 'Using Customer-Managed-Keys with User-Assigned identity'
metadata description = 'This instance deploys the module using Customer-Managed-Keys using a User-Assigned Identity to access the Customer-Managed-Key secret.'

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string = 'lab01'

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${identifier}-storage.storageaccounts-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module coreResourceGroup 'core.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-core'
  params: {
    location: location
    identifier: identifier
  }
}

module testDeployment 'br/public:avm/res/storage/storage-account:0.5.0' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-${identifier}'
  params: {
    location: location
    name: '${identifier}-sa'
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: coreResourceGroup.outputs.subnetResourceId
        privateDnsZoneResourceIds: [
          coreResourceGroup.outputs.privateDNSZoneResourceId
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
        coreResourceGroup.outputs.managedIdentityResourceId
      ]
    }
    customerManagedKey: {
      keyName: 'keyEncryptionKey'
      keyVaultResourceId: coreResourceGroup.outputs.keyVaultResourceId
      userAssignedIdentityResourceId: coreResourceGroup.outputs.managedIdentityResourceId
    }
  }
}
