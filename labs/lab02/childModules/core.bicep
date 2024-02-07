targetScope = 'subscription'

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string = 'avmdemo'

@description('Optional. The core Resource Group name.')
param  resourceGroupNameCore string = 'rg-${identifier}-core'

@description('Optional. The location for all resources.')
param location string = deployment().location

// Resource Group

// Azure Bastion Network Security Group

// Default Subnet Network Security Group

// Virtual Network

// Azure Bastion - Public IP

// Azure Bastion

// Private DNS Zone for Azure Key Vault


// Outputs
// output workloadSubnetResourceId string = 
// output privateDnsZoneKeyVaultResourceId string =
