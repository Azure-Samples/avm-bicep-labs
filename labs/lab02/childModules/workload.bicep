targetScope = 'subscription'

param identifier string = 'avmdemo'
param resourceGroupNameWorkload string = 'rg-${identifier}-workload'

@secure()
param virtualMachinePassword string

param subnetResourceId string
param privateDnsZoneKeyVaultResourceId string

// Resource Group
module resourceGroup 'br/public:avm/res/resources/resource-group:0.2.2' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupNameWorkload
  }
}

// Key Vault
module keyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  scope: az.resourceGroup(resourceGroupNameWorkload)
  name: '${uniqueString(deployment().name)}-kv'
  params: {
    name: 'kv-${identifier}'
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        principalId: virtualMachine.outputs.systemAssignedMIPrincipalId
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
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    enableSoftDelete: false
    enablePurgeProtection: false
  }
}

// Virtual Machine
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.1' = {
  scope: az.resourceGroup(resourceGroupNameWorkload)
  name: '${uniqueString(deployment().name)}-vm'
  params: {
    name: 'vm-${identifier}'
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
      systemAssigned: true
    }
  }
  dependsOn: [
    resourceGroup
  ]
}
