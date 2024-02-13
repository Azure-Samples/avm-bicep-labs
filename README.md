---
page_type: sample
languages:
  - bicep
name: Introduction to using Azure Verified Modules for Bicep
description: A walk through lab demonstrating how to use the Azure Verified Modules for Bicep.
products:
  - azure
urlFragment: avm-bicep-labs
---

# Introduction to using Azure Verified Modules for Bicep

This repository provides lab-based samples that demonstrates how to use the Azure Verified Modules for Bicep. This repository contains full working lab solutions (lab01, lab02, ...), but you should follow the steps in the lab to understand how it fits together.

## Content

| File/folder       | Description                                |
| ----------------- | ------------------------------------------ |
| `labs`            | The files for the lab.                     |
| `.gitignore`      | Define what to ignore at commit time.      |
| `CHANGELOG.md`    | List of changes to the sample.             |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md`       | This README file.                          |
| `LICENSE.md`      | The license for the sample.                |

### Prerequisites

- Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- Azure PowerShell: [Download](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.1.0)
- An Azure Subscription: [Free Account](https://azure.microsoft.com/en-gb/free/search/)
- Visual Studio Code: [Download](https://code.visualstudio.com/Download)
  - Bicep Extension: [Download](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

### Quickstart

The instructions for these samples are in the form of Labs. Follow along with them to get up and running.

## Demo / Lab

### Part 0 - Get the lab files

In this part, we are going to get a local copy of the lab files for use in the rest of the lab.

1. Create a new root folder for the lab in a location of your choice.
2. Open a terminal and navigate to the new folder.
3. Run `git clone https://github.com/Azure-Samples/avm-bicep-labs` to clone the lab files into the new folder; they will be in a subfolder called `avm-bicep-labs`.

### Lab 01 - Demo: Deploying a Storage Account + Customer Managed Key Solution Using AVM modules published in the Public Bicep Registry

##### Architecture

![diagram](labs/lab01/diagram.png)

#### Description

This architecture deploys the following:

#### Core Resource Group

Containing:

- Azure Virtual Network, with one subnet.
- Private DNS Zone for Azure Key Vault, and integrated into the Virtual Network.

### Workload Resource Group

Containing:

- Azure Key Vault, with public network access disabled, and uses the Azure RBAC authorization model. It also has a Private Endpoint deployed into the Virtual Network workload subnet, and also linked to the Private DNS Zone for Azure Key Vault.
- Storage Account, with public network access disabled, and uses the Customer Managed Key feature to protect the data at rest. It also has a Private Endpoint deployed into the Virtual Network workload subnet, and also linked to the Private DNS Zone for Azure Storage.

## Deployment

:hourglass_flowing_sand: **Average Solution End to End Deployment time**: 10 minutes

- Open a Visual Studio Code session, clone the repository and then open up a VS Code session in the folder for the cloned repo.

:warning: Ensure you are logged into Azure using the Azure CLI.

```shell
az login
az account set --subscription '<<your subscription name>>'
```

### Method (1) - `main.bicep` file

- Deploy the [main.bicep](main.bicep) by modifying the `identifier` parameter to something that is unique to your deployment (i.e. a 5 letter string). Additionally you can also change the `location` parameter to a different Azure region of your choice.

```powershell
az deployment sub create --location 'australiaeast' --name 'lab01' --template-file '<<path to the repo>>/labs/lab01/main.bicep' --verbose
```

### Method (2) - `main.parameters.json` file

- Deploy the [main.parameters.json](main.parameters.json) by modifying the `identifier` parameter to something that is unique to your deployment (i.e. a 5 letter string). Additionally you can also change the `location` parameter to a different Azure region of your choice.

```powershell
az deployment sub create --location 'australiaeast' --name 'lab01' --template-file '<<path to the repo>>/labs/lab01/main.bicep' --parameters '<<path to the repo>>/labs/lab01/main.parameters.json' --verbose
```

---

### Lab 02 - Demo: Deploying an Azure Solution Using AVM modules published in the Public Bicep Registry

Initially created by [ahmadabdalla](https://github.com/ahmadabdalla) and later adopted to use [Azure Verified Modules (AVM)](https://aka.ms/AVM).

### Architecture

![diagram](labs/lab02/diagram.png)

### Description

This architecture deploys the following:

#### Core Resource Group

Containing:

- Azure Virtual Network, with two subnets, one for workloads and one for Azure Bastion. The subnets are protected with Network Security Groups.
- Private DNS Zone for Azure Key Vault, and integrated into the Virtual Network
- A Public IP and Azure Bastion Host deployed into the Virtual Network subnet for Azure Bastion.

#### Workload Resource Group

Containing:

- Azure Key Vault, with public network access disabled, and uses the Azure RBAC authorization model. It also has a Private Endpoint deployed into the Virtual Network workload subnet, and also linked to the Private DNS Zone for Azure Key Vault.
- An Azure Virtual Machine deployed into Virtual Network workload subnet, with a User Assigned Managed Identity that has the 'Secrets Officer' Role at the Azure Key Vault Scope.

### Deployment

:hourglass_flowing_sand: **Average Solution End to End Deployment time**: 20 minutes

- Open a Visual Studio Code session, clone the repository and then open up a VS Code session in the folder for the cloned repo.

:warning: Ensure you are logged into Azure using Azure PowerShell.

```powershell
Add-AzAccount -Subscription '<<your subscription name>>'
```

#### Method (1) - `main.bicep` file

- Deploy the [main.bicep](main.bicep) by modifying the `identifier` parameter to something that is unique to your deployment (i.e. a 5 letter string). Additionally you can also change the `location` parameter to a different Azure region of your choice.

```powershell
New-AzDeployment -Location 'australiaeast' -deploymentname 'avmdemo' -TemplateFile '<<path to the repo>>\labs\lab02\main.bicep'
```

#### Method (2) - `main.parameters.json` file

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

### Testing

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
