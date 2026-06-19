// main.bicepparam — Access contract parameters for demo-1/dev
// Update ALL placeholder values before deploying.

using 'main.bicep'

// ── APIM (lines 8-10) ────────────────────────────────────────────────────────
param apimSubscriptionId    = '<your-apim-subscription-id>'      // line 8
param apimResourceGroupName = '<your-apim-resource-group>'       // line 9
param apimName              = '<your-apim-instance-name>'        // line 10

// ── Key Vault (lines 14-16) ──────────────────────────────────────────────────
param keyVaultSubscriptionId    = '<your-keyvault-subscription-id>'   // line 14
param keyVaultResourceGroupName = '<your-keyvault-resource-group>'    // line 15
param keyVaultName              = '<your-keyvault-name>'              // line 16
