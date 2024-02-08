targetScope = 'subscription'

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string = 'avmdemo'

@description('Optional. The core Resource Group name.')
param resourceGroupNameCore string = 'rg-${identifier}-core'

@description('Optional. The Workload Resource Group name.')
param resourceGroupNameWorkload string = 'rg-${identifier}-workload'

@description('Optional. The location for all resources.')
param location string = 'westeurope'

@description('Required. The password for the virtual machine.')
@secure()
param virtualMachinePassword string

// Core Resource Group

module coreResourceGroup 'childModules/core.bicep' = {
  name: '${uniqueString(deployment().name)}-core'
  params: {
    resourceGroupNameCore: resourceGroupNameCore
    identifier: identifier
    location: location
  }
}

// Workload Resource Group

module workloadResourceGroup 'childModules/workload.bicep' = {
  name: '${uniqueString(deployment().name)}-workload'
  params: {
    resourceGroupNameWorkload: resourceGroupNameWorkload
    privateDnsZoneKeyVaultResourceId: coreResourceGroup.outputs.privateDnsZoneKeyVaultResourceId
    subnetResourceId: coreResourceGroup.outputs.workloadSubnetResourceId
    logAnalyticsWorkspaceResourceId: coreResourceGroup.outputs.logAnalyticsWorkspaceResourceId
    virtualMachinePassword: virtualMachinePassword
    identifier: identifier
    location: location
  }
}
