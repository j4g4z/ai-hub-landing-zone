// main.bicepparam — Networking-only deployment parameters
// Follows the AI LZ naming convention — see ../NAMING.md
// Update CIDR ranges to fit your environment before deploying.

using 'main.bicep'

// ── Environment ──────────────────────────────────────────────────────────────
param environmentName = 'ailz-dev-01'
param location        = 'canadacentral'  // Primary region (AZ-enabled, S2S termination)

// ── Resource naming (per NAMING.md) ──────────────────────────────────────────
param networkResourceGroupName = 'az-rg-network-ailz-dev-01'
param vnetName                 = 'az-vnet-ailz-dev-01'

// ── VNET addressing ──────────────────────────────────────────────────────────
param vnetAddressPrefix  = '10.0.0.0/16'
param apimSubnetPrefix   = '10.0.1.0/24'
param peSubnetPrefix     = '10.0.2.0/24'  // Private Endpoints
param appSubnetPrefix    = '10.0.3.0/24'  // App Services / Functions
