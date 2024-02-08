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
module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.1.2' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name)}-umi'
  params: {
    name: 'umi-${identifier}'
    location: location
  }
}

// Key Vault
module keyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name)}-kv'
  params: {
    name: 'kv-${identifier}-${substring(uniqueString(baseTime), 0, 3)}'
    location: location
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        principalId: userAssignedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          privateDnsZoneKeyVaultResourceId
        ]
        service: 'vault'
        subnetResourceId: subnetResourceId
      }
    ]
    enableSoftDelete: false
    enablePurgeProtection: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

// Virtual Machine
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.1' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name)}-vm'
  params: {
    name: 'vm-${identifier}'
    location: location
    computerName: 'vm-${identifier}'
    adminUsername: 'vmadmin'
    imageReference: {
      publisher: 'microsoftvisualstudio'
      offer: 'visualstudio2022'
      sku: 'vs-2022-comm-latest-ws2022'
      version: 'latest'
    }
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_DS1_v2'
    adminPassword: virtualMachinePassword
    managedIdentities: {
      userAssignedResourceIds: [
        userAssignedIdentity.outputs.resourceId
      ]
    }
    encryptionAtHost: false
  }
}
