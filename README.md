# AI Hub Gateway Landing Zone

A deployment guide and reference implementation for the **Azure AI Hub Gateway Solution Accelerator** — adapted for the CSA West team. This repo isolates the networking layer from the hub deployment, making it easier to integrate with existing customer VNETs, Subnets, and NSGs.

> Based on the [`ai-hub-gateway-solution-accelerator`](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1) (citadel-v1 branch).

## 📋 Naming Convention

**All resources in this deployment follow the canonical naming convention defined in [`NAMING.md`](./NAMING.md).** Review it before adding or modifying any resource name or `.bicepparam` value.

## 🌎 Regional Strategy

| Region | Role | Rationale |
|---|---|---|
| **Canada Central** | 🎯 Primary — AI LZ + primary AI Foundry | Availability Zones; S2S connectivity termination |
| **Canada East** | 🔁 Secondary — complementary AI Foundry | Model availability gaps; capacity/networking fallback; Canadian data residency preserved |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Customer VNET                      │
│  ┌────────────┐    ┌──────────────────────────────┐  │
│  │  Subnets   │    │   AI Hub Gateway (APIM)      │  │
│  │  NSGs      │───▶│   Azure OpenAI / AI Services │  │
│  └────────────┘    │   Key Vault (API Keys)       │  │
│                    │   CosmosDB (usage tracking)  │  │
│                    └──────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
         │
         ▼
  Access Contracts (citadel-v1)
  Controls per-team/per-model access via APIM policies
```

---

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- An Azure subscription with Contributor access
- Access to the `ai-hub-gateway-solution-accelerator` repo (citadel-v1 branch)

---

## Deployment Steps

### 1. Clone the Base Accelerator

```bash
git clone https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator.git
cd ai-hub-gateway-solution-accelerator
git checkout citadel-v1
```

---

### 2. Configure Azure Developer CLI Environment

```bash
azd auth login
azd env select ailz-hub-dev-01

# Set required environment variables
azd env set AZURE_ENV_NAME      ailz-dev-01
azd env set AZURE_LOCATION      canadacentral
azd env set AZURE_SUBSCRIPTION_ID <your-subscription-id>
```

---

### 3. Deploy Networking (Isolated)

> 💡 This step is isolated so customers with existing VNET/Subnet/NSG infrastructure can skip or adapt it.

Unzip `networking-only.zip` into:
```
ai-hub-gateway-solution-accelerator/bicep/infra/
```

Then deploy:
```bash
cd ai-hub-gateway-solution-accelerator/bicep/infra/networking-only

az deployment sub create \
  --name aihub-networking \
  --location canadacentral \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Save the VNET outputs for the next step:
```bash
cd ai-hub-gateway-solution-accelerator

VNET_NAME=$(az deployment sub show \
  --name aihub-networking \
  --query properties.outputs.vnetName.value -o tsv)

VNET_RG=$(az deployment sub show \
  --name aihub-networking \
  --query properties.outputs.vnetRG.value -o tsv)

azd env set VNET_NAME          "$VNET_NAME"
azd env set EXISTING_VNET_RG   "$VNET_RG"
azd env set USE_EXISTING_VNET  true
```

---

### 4. Deploy the AI Hub

Copy the provided `main.bicep` and `main.bicepparam` into:
```
ai-hub-gateway-solution-accelerator/bicep/infra/
```

Then run:
```bash
azd up
```

> This deploys APIM, Azure OpenAI, Key Vault, CosmosDB, and supporting resources.

---

### 5. Deploy Access Contracts

Unzip `contracts.zip` into:
```
ai-hub-gateway-solution-accelerator/bicep/infra/citadel-access-contracts/
```

Edit the contract file and replace the following placeholder values:

| Line | Field | Description |
|------|-------|-------------|
| 8 | `apim.subscriptionId` | Azure Subscription ID where APIM lives |
| 9 | `apim.resourceGroupName` | Resource Group containing APIM |
| 10 | `apim.name` | APIM instance name |
| 14 | `keyVault.subscriptionId` | Azure Subscription ID where Key Vault lives |
| 15 | `keyVault.resourceGroupName` | Resource Group containing Key Vault |
| 16 | `keyVault.name` | Key Vault name |

Deploy the contract:
```bash
az deployment sub create \
  --name demo-1-dev \
  --location canadacentral \
  --template-file main.bicep \
  --parameters contracts/demo-1/dev/main.bicepparam
```

---

### 6. Test the Endpoint

> ⚠️ **Important:** You must test from **within the VNET**, or via a VNET Gateway. Direct public access is blocked by design.

```bash
curl -X POST "https://{your-apim-instance}.azure-api.net/models/chat/completions?api-version=2024-08-01-preview" \
  -H "api-key: {api-key-from-key-vault}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "hello"}]
  }'
```

---

## Repository Structure

```
ai-hub-landing-zone/
├── networking-only/
│   ├── main.bicep              # Networking-only Bicep template
│   └── main.bicepparam         # Networking parameters
├── contracts/
│   └── demo-1/
│       └── dev/
│           └── main.bicepparam # Access contract parameters for demo-1/dev
├── scripts/
│   ├── setup-env.sh            # Helper: configure azd environment
│   └── deploy-all.sh           # Helper: full deployment script
├── main.bicep                  # Main hub Bicep template
├── main.bicepparam             # Main hub parameters
└── README.md
```

---

## Key Differences from the Base Accelerator

| Change | Reason |
|--------|--------|
| Isolated networking deployment | Customers typically have existing VNETs/NSGs |
| CosmosDB fix applied | Resolves deployment errors seen with the base fork |
| Access contracts included | Enables per-team/per-model access control via APIM |

---

## Next Steps / Operationalizing the LZ

> 🚧 This is the area the team is actively working on. Key questions to address:
> - How do we onboard new teams/contracts without re-deploying the hub?
> - How do we handle key rotation in Key Vault?
> - What's the monitoring/alerting story via CosmosDB + APIM analytics?
> - How do we integrate this with customer-managed private DNS zones?

---

## References

- [AI Hub Gateway Solution Accelerator (citadel-v1)](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1)
- [Azure API Management docs](https://learn.microsoft.com/en-us/azure/api-management/)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
