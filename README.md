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
- Subject examples:
  - `repo:<ORG>/<REPO>:ref:refs/heads/main`
  - `repo:<ORG>/<REPO>:pull_request`

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

Terraform state bootstrap variables:

- `TF_STATE_STORAGE_ACCOUNT` (optional; defaults to `tfstate1304953421`)
- `TF_STATE_RESOURCE_GROUP` (optional; defaults to `rg-terraform-state`)
- `TF_STATE_CONTAINER` (optional; defaults to `tfstate`)
- `TF_STATE_LOCATION` (optional; defaults to `TF_VAR_LOCATION`, then `eastus`)

## 3) Bootstrap Terraform state storage

Before configuring the Terraform Azure Blob backend, run the manually triggered
workflow named **Bootstrap Terraform State Storage**.

The OIDC service principal needs these temporary bootstrap permissions:

- `Contributor` on the subscription or target resource group, to create storage.
- `Role Based Access Control Administrator` on the subscription or target
  resource group, to grant the data-plane role.

The workflow creates a private `StorageV2` account with HTTPS-only access,
TLS 1.2 minimum, public blob access disabled, and shared-key access disabled.
It creates the state container and grants the service principal identified by
`AZURE_CLIENT_ID` the `Storage Blob Data Contributor` role at container scope.

After the workflow succeeds, remove any bootstrap permissions that are no
longer needed. The container-scoped data role must remain for Terraform.

## 4) Run with GitHub Actions

Use the workflow in Actions named "Terraform Azure VM":

- Pull request or push to `main` runs `plan`
- Manual run (`workflow_dispatch`) supports:
  - `plan`
  - `apply`
  - `destroy`

## 5) Test OIDC with Python

Run the workflow named **Test Azure OIDC with Python** from the GitHub Actions
tab. It performs a read-only connectivity test:

1. GitHub requests an OIDC token.
2. `azure/login` exchanges it for Azure credentials.
3. Python uses `AzureCliCredential` to read the configured subscription.
4. Python lists the resource groups visible to the service principal.

The workflow does not create, update, or delete Azure resources. A successful
run prints `OIDC authentication succeeded`, the subscription name, and the
number of visible resource groups.

If login fails, confirm that the federated credential subject matches
`repo:maruthibalu/DevOpsLearning:ref:refs/heads/main`. Also confirm that the
three Azure repository secrets are configured and that the service principal
has at least the `Reader` role at the target scope.

## 6) Run locally (optional)

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
