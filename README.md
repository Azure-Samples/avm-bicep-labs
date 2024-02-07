# Introduction to using Azure Verified Modules for Bicep

This repository provides lab-based samples that demonstrates how to use the Azure Verified Modules for Bicep. This repository contains full working lab solutions (lab01, lab02, ...), but you should follow the steps in the lab to understand how it fits together.

## Content

| File/folder | Description |
|-------------|-------------|
| `labs` | The files for the lab. |
| `.gitignore` | Define what to ignore at commit time. |
| `CHANGELOG.md` | List of changes to the sample. |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md` | This README file. |
| `LICENSE.md` | The license for the sample. |

### Prerequisites

- Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- An Azure Subscription: [Free Account](https://azure.microsoft.com/en-gb/free/search/)

### Quickstart

The instructions for these samples are in the form of Labs. Follow along with them to get up and running.

## Demo / Lab

### Part 0 - Get the lab files

In this part, we are going to get a local copy of the lab files for use in the rest of the lab.

1. Create a new root folder for the lab in a location of your choice.
2. Open a terminal and navigate to the new folder.
3. Run `git clone https://github.com/Azure-Samples/avm-bicep-labs` to clone the lab files into the new folder; they will be in a subfolder called `avm-bicep-labs`.

Your file structure should now look like this:

```plaintext
📂avm-bicep-labs
┣ 📂lab01
┃ ┣ 📜main.bicep
┃ ┗ 📜dependencies.bicep
┗ 📂lab02
┃ ┣ 📜locals.bicep
┃ ┗ 📜main.bicep
┣ 📜.gitignore
┗ 📜README.md
```

### Lab 01 - Base files and resources
In this part, we are going to set up our Bicep root module and deploy an Azure Resource Group ready for the rest of the lab.

Create a new folder under your lab folder called avm-lab.
Copy the files from the part 1 folder into the avm-lab folder.
powershell
Copy code
# Run from the avm-lab folder
copy ../avm-terraform-labs/labs/part01-base/* .
Your file structure should look like this:

plaintext
Copy code
📂my-lab-folder
┣ 📂avm-lab
┃ ┣ 📜.gitignore
┃ ┣ 📜locals.bicep
┃ ┣ 📜main.bicep
┃ ┣ 📜outputs.bicep
┃ ┣ 📜terraform.bicep
┃ ┗ 📜variables.bicep
┗ 📂avm-terraform-labs
Open Visual Studio Code and open the avm-lab folder. Hint: code .
Examine the main.bicep file and other bicep files.
// Continue adding instructions for subsequent parts similarly
