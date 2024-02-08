# Demo: Deploying an Azure Solution Using AVM modules published in the Public Bicep Registry

Initially created by [ahmadabdalla](https://github.com/ahmadabdalla) and later adopted to use [Azure Verified Modules (AVM)](https://aka.ms/AVM).

## Architecture

![diagram](diagram.png)

## Description

This architecture deploys the following:

### Core Resource Group

Containing:

- Azure Virtual Network, with two subnets, one for workloads and one for Azure Bastion. The subnets are protected with Network Security Groups.
- Private DNS Zone for Azure Key Vault, and integrated into the Virtual Network
- A Public IP and Azure Bastion Host deployed into the Virtual Network subnet for Azure Bastion.

### Workload Resource Group

Containing:

- Azure Key Vault, with public network access disabled, and uses the Azure RBAC authorization model. It also has a Private Endpoint deployed into the Virtual Network workload subnet, and also linked to the Private DNS Zone for Azure Key Vault.
- An Azure Virtual Machine deployed into Virtual Network workload subnet, with a User Assigned Managed Identity that has the 'Secrets Officer' Role at the Azure Key Vault Scope.

## Deployment

:hourglass_flowing_sand: **Average Solution End to End Deployment time**: 20 minutes

- Open a Visual Studio Code session, clone the repository and then open up a VS Code session in the folder for the cloned repo.

:warning: Ensure you are logged into Azure using Azure PowerShell.

```powershell
Add-AzAccount -Subscription '<<your subscription name>>'
```

### Method (1) - `main.bicep` file

- Deploy the [main.bicep](main.bicep) by modifying the `identifier` parameter to something that is unique to your deployment (i.e. a 5 letter string). Additionally you can also change the `location` parameter to a different Azure region of your choice.

```powershell
New-AzDeployment -Location 'australiaeast' -deploymentname 'avmdemo' -TemplateFile '<<path to the repo>>\labs\lab02\main.bicep'
```

### Method (2) - `main.parameters.json` file

- Deploy the [main.parameters.json](main.parameters.json) by modifying the `identifier` parameter to something that is unique to your deployment (i.e. a 5 letter string). Additionally you can also change the `location` parameter to a different Azure region of your choice.

```powershell
New-AzDeployment -Location 'australiaeast' -deploymentname 'avmdemo' -TemplateFile '<<path to the repo>>\labs\lab02\main.bicep' -TemplateParameterFile '<<path to the repo>>\labs\lab02\main.parameters.json'
```

---

:information_source: In both deployment methods, a prompt will appear asking for the password for the Virtual Machine. This is the password for the `vmadmin` user on the Virtual Machine.

---

- The deployment will first deploy the [core.bicep](../lab02/childModules/core.bicep) file, which results in a Resource Group with the core resources inside it.
- The deployment will then deploy the the [workload.bicep](../lab02/childModules/workload.bicep), which results in another Resource Group with the workload resources inside it.

---

:warning: The Key Vault name contains a 3 letter string generated from the base time function. This is to ensure that the Key Vault name is unique. This means that the Key Vault name will be different for each deployment.

---

## Testing

Once the deployment is complete, navigate to the Virtual Machine blade, and connect via Azure Bastion.

- Provide your user name and password, which will then open up a new browser tab for the RDP over HTTPS session using Azure Bastion.

---

:information_source: The username for the Virtual Machine is `vmadmin` and the password is the one you used when deploying the template.

---

- Open up PowerShell on the Virtual Machine, and authenticate to Azure using the User Managed Identity for the Virtual Machine, then retrieve the Key Vault information

```powershell
Add-AzureRmAccount -Identity
$KeyVault = Get-AzureRmKeyVault
nslookup "$($KeyVault.VaultName).vault.azure.net"
```

- :white_check_mark: The returned value should be the Private IP address of the Key Vault. Meaning that the data plane traffic to this Key Vault is using the Virtual Network.

---

:information_source:**Note**: The reason Azure cmdlets work on this Virtual Machine is because Image of this VM contains a Visual Studio installation. However the cmdlets are using the legacy Azure RM modules and not the Az ones. But that is ok for our testing as it will have the necessary cmdlets needed to validate this demo.

---

- Next create a secret in the PowerShell session:

```powershell
$MyTestSecret = Read-Host -AsSecureString
```

- Next upload this secret to the Azure Key Vault:

```powershell
Set-AzureKeyVaultSecret -VaultName $KeyVault.VaultName -SecretName 'TestSecret' -SecretValue $MyTestSecret | Select-object Id, Name
```

- To retrieve the secret from the Key Vault

```powershell
Get-AzureKeyVaultSecret -VaultName $KeyVault.VaultName -SecretName 'TestSecret' | Select-Object SecretValueText
```

These data plane operations are only accessible from the Virtual Network

- To delete the demo resources, from your IDE where you deployed the template:

```powershell
Remove-AzResourceGroup -Name "rg-<<youridentifer>>-workload" -Force
Remove-AzResourceGroup -Name "rg-<<youridentifer>>-core" -Force
```

---

:warning: Ensure you delete the resources to avoid incurring costs.

---
