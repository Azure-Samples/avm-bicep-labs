targetScope = 'subscription'

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string = 'avmdemo'

@description('Optional. The Workload Resource Group name.')
param resourceGroupNameWorkload string = 'rg-${identifier}-workload'

@description('Optional. The location for all resources.')
param location string = deployment().location

@description('Required. The password for the virtual machine.')
@secure()
param virtualMachinePassword string

@description('Required. The subnet resource ID for the virtual machine.')
param subnetResourceId string

@description('Required. The private DNS zone resource ID for the Key Vault.')
param privateDnsZoneKeyVaultResourceId string

@description('Required. The Log Analytics workspace resource ID for the Key Vault.')
param logAnalyticsWorkspaceResourceId string

@description('Generated. Used as a basis for unique resource names.')
param baseTime string = utcNow('u')

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNameWorkload
  location: location
}

// User Assigned Identity

// Key Vault

// Virtual Machine
