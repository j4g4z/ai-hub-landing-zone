// main.bicepparam — Access contract parameters for demo-1/dev
// Follows the AI LZ naming convention — see ../../../NAMING.md
// Update placeholder subscription IDs before deploying.

using 'main.bicep'

// ── APIM (lines 8-10) ────────────────────────────────────────────────────────
param apimSubscriptionId    = '<your-apim-subscription-id>'  // line 8
param apimResourceGroupName = 'az-rg-ailz-dev-01'            // line 9
param apimName              = 'az-apim-ailz-dev-01'          // line 10

// ── Key Vault (lines 14-16) ──────────────────────────────────────────────────
param keyVaultSubscriptionId    = '<your-keyvault-subscription-id>'  // line 14
param keyVaultResourceGroupName = 'az-rg-ailz-dev-01'                // line 15
param keyVaultName              = 'az-kv-ailz-dev-01'                // line 16
