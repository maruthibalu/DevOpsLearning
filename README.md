# Azure VM with Terraform and GitHub Actions

This repo provisions an Ubuntu Linux VM in Azure using Terraform and runs Terraform from GitHub Actions using OpenID Connect (OIDC).

## What gets created

- Resource Group
- Virtual Network and Subnet
- Network Security Group (SSH on port 22)
- Public IP and Network Interface
- Linux Virtual Machine

## Prerequisites

- Azure subscription
- GitHub repository containing this code
- Terraform 1.6+ (for local runs)
- An SSH public key (for example, `id_rsa.pub`)

## 1) Configure Azure identity for GitHub OIDC

Create an Entra ID app registration (service principal), then add a federated credential for your GitHub repo.

Recommended federated credential values:

- Issuer: `https://token.actions.githubusercontent.com`
- Audience: `api://AzureADTokenExchange`
- Subject: use the exact immutable *subject claim* value for the branch or
  event you want to allow. Copy it from the repository's GitHub Actions OIDC
  settings/API, or from the workflow log's "Federated token details" output.

This repository uses GitHub's immutable OIDC subject format, which includes the
repository owner ID and repository ID. Azure login fails with `AADSTS700213` if
the federated credential is configured with the legacy subject format
(`repo:<ORG>/<REPO>:...`) instead of the exact immutable subject emitted by the
workflow.

Grant the service principal at least `Contributor` role on your target subscription or resource group.

## 2) Add GitHub secrets and variables

Repository secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TF_VAR_ADMIN_SSH_PUBLIC_KEY` (the full SSH public key string)

Optional repository variables:

- `TF_VAR_PREFIX`
- `TF_VAR_LOCATION`
- `TF_VAR_ADMIN_USERNAME`
- `TF_VAR_ALLOWED_SSH_CIDR` (set this to your IP/CIDR for better security)

## 3) Run with GitHub Actions

Use the workflow in Actions named "Terraform Azure VM":

- Pull request or push to `main` runs `plan`
- Manual run (`workflow_dispatch`) supports:
  - `plan`
  - `apply`
  - `destroy`

## 4) Run locally (optional)

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

After apply:

```powershell
terraform output public_ip_address
terraform output ssh_command
```

## Security note

Default `allowed_ssh_cidr` is `0.0.0.0/0` for quick start. Restrict this to your own public IP range in production.
