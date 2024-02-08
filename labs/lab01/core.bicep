@description('Optional. The location to deploy resources to.')
param location string

@maxLength(7)
@description('Optional. Unique identifier for the deployment. Will appear in resource names. Must be 7 characters or less.')
param identifier string

module keyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  name: '${uniqueString(deployment().name)}-kv'
  params: {
    name: '${identifier}-kv-fsdg'
    location: location
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    accessPolicies: []
    keys: [
      {
        name: 'keyEncryptionKey'
        kty: 'RSA'
      }
    ]
    roleAssignments: [
      {
        principalId: managedIdentity.outputs.principalId
        roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424') // Key Vault Crypto User
        principalType: 'ServicePrincipal'
      }
    ]
    // privateEndpoints: [
    //   {
    //     privateDnsZoneResourceIds: [
    //       privateDNSZone.outputs.resourceId
    //     ]
    //     service: 'vault'
    //     subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
    //   }
    // ]
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: '${uniqueString(deployment().name)}-vnet'
  params: {
    name: '${identifier}-vnet'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        addressPrefix: '10.0.1.0/24'
        name: 'default'
      }
    ]
  }
}

module privateDNSZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name: '${uniqueString(deployment().name)}-pdnsz'
  params: {
    name: 'privatelink.vaultcore.azure.net'
    location: 'global'
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
      }
    ]
  }
}

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.1.2' = {
  name: '${uniqueString(deployment().name)}-mi'
  params: {
    name: '${identifier}-mi'
    location: location
  }
}

@description('The resource ID of the created Virtual Network Subnet.')
output subnetResourceId string = virtualNetwork.outputs.subnetResourceIds[0]

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.outputs.principalId

@description('The resource ID of the created Managed Identity.')
output managedIdentityResourceId string = managedIdentity.outputs.resourceId

@description('The resource ID of the created Private DNS Zone.')
output privateDNSZoneResourceId string = privateDNSZone.outputs.resourceId

@description('The resource ID of the created Key Vault.')
output keyVaultResourceId string = keyVault.outputs.resourceId
