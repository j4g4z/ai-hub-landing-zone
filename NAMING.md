# Naming Conventions — AI Hub Landing Zone

This deployment follows the naming convention provided by **Evan Nelson** (Customer architect). All resources, parameter values, and helper scripts in this repo MUST conform to these rules.

> Authoritative reference: [Microsoft Cloud Adoption Framework — Resource Naming](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

---

## Canonical Format

```
az-<type>-<solution>-<env>-<ordinal>
```

| Token | Description | Example |
|---|---|---|
| `az-` | Fixed prefix | `az-` |
| `<type>` | Resource-type abbreviation (lowercase) | `vnet`, `apim`, `kv`, `cosmos`, `pep`, `rg`, `foundry` |
| `<solution>` | Solution / workload identifier (PascalCase or lowercase) | `ailz`, `ITWebCollaboration` |
| `<env>` | Environment token | `sandbox` \| `dev` \| `prod` |
| `<ordinal>` | 2-digit zero-padded instance number | `01`, `02`, `03` |

---

## Validation Regex

```regex
^az-[a-z0-9]+-[A-Za-z0-9-]+-(sandbox|dev|prod)-\d{2}$
```

---

## Special-Case Rules

### Storage Accounts
Storage account names must be **lowercase, 3–24 chars, alphanumeric only** (no dashes).

```regex
^[a-z0-9]{3,24}$
```

Generator pattern: `azst<solution><ordinal>` — truncate `<solution>` to 18 chars max.

| Example |
|---|
| `azstailzdev01` |
| `azstitwebcollab01` |

### Private Endpoints
Use the `pep` type abbreviation, with the **upstream resource type** as a secondary qualifier:

```
az-pep-<upstreamType>-<solution>-<env>-<ordinal>
```

| Example |
|---|
| `az-pep-apim-ailz-dev-01` |
| `az-pep-kv-ailz-dev-01` |
| `az-pep-cosmos-ailz-dev-01` |

> **Exception:** AI Foundry private endpoints are owned and named by the AVM pattern internally — do not override.

### Network Resource Group
When `resourceGroup.network.useSeparateResourceGroup = true`:

```
az-rg-network-<solution>-<env>-<ordinal>
```

---

## Names Used in This Deployment

| Resource | Canada Central (Primary) | Canada East (Secondary) |
|---|---|---|
| Main resource group | `az-rg-ailz-dev-01` | — |
| Network resource group | `az-rg-network-ailz-dev-01` | — |
| VNET | `az-vnet-ailz-dev-01` | — |
| APIM (AI Hub Gateway) | `az-apim-ailz-dev-01` | — |
| Key Vault | `az-kv-ailz-dev-01` | — |
| Cosmos DB | `az-cosmos-ailz-dev-01` | — |
| AI Foundry — primary | `az-foundry-ailz-cac-dev-01` | — |
| AI Foundry — secondary | — | `az-foundry-ailz-cae-dev-01` |
| Storage account | `azstailzdev01` | — |
| Private Endpoint — APIM | `az-pep-apim-ailz-dev-01` | — |
| Private Endpoint — Key Vault | `az-pep-kv-ailz-dev-01` | — |
| Private Endpoint — Cosmos | `az-pep-cosmos-ailz-dev-01` | — |

> Region suffix (`cac`/`cae`) is appended to the **solution** token for region-specific resources (e.g., dual-region Foundry).

---

## Private Endpoint Network Inputs (canonical)

The repository synthesises private endpoints through `templates/patterns/private-endpoints.bicep` using these canonical inputs:

| Input | Purpose |
|---|---|
| `resourceGroup.network.privateEndpointsEnabled` | Master toggle |
| `resourceGroup.network.privateEndpointSubnetId` | Subnet to place PEs in |
| `resourceGroup.network.privateDnsZoneIds` | DNS zone associations |
| `resourceGroup.network.resourceGroupName` | Network RG name |
| `resourceGroup.network.useSeparateResourceGroup` | Place PEs in network RG vs. resource RG |

---

## Helper Functions (PowerShell)

```powershell
function New-RepoName {
  param(
    [string]$TypeAbbr,
    [string]$Solution,
    [string]$Env,
    [int]$Ordinal = 1
  )
  $ordinal = '{0:00}' -f $Ordinal
  return "az-$TypeAbbr-$Solution-$Env-$ordinal"
}

function New-StorageName {
  param(
    [string]$Solution,
    [int]$Ordinal = 1
  )
  $base = ($Solution -replace '[^a-zA-Z0-9]','').ToLower()
  if ($base.Length -gt 18) { $base = $base.Substring(0,18) }
  $suffix = '{0:00}' -f $Ordinal
  $candidate = "azst${base}$suffix"
  if ($candidate.Length -gt 24) { $candidate = $candidate.Substring(0,24) }
  return $candidate
}

function New-NetworkResourceGroupName {
  param(
    [string]$Solution,
    [string]$Env,
    [int]$Ordinal = 1
  )
  $ordinal = '{0:00}' -f $Ordinal
  return "az-rg-network-$Solution-$Env-$ordinal"
}
```

---

## CI Validation (recommended)

Add a lint step that:
1. Runs the regex checks against all `*.bicepparam` files.
2. Validates storage-account names against `^[a-z0-9]{3,24}$`.
3. Fails the build on any violation.

---

## Maintenance

- Any deviation from these rules must be documented inline at the call-site and noted in `README.md` under "Known Deviations".
- If Microsoft's canonical abbreviation list updates, refresh the table above and bump the version footer.

*Version: 1.0 — June 2026 — based on Evan Nelson's SKILL.md*
