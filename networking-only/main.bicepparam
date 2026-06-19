// main.bicepparam — Networking-only deployment parameters
// Update these values to match your environment before deploying.

using 'main.bicep'

param environmentName = 'ailz-hub-dev-01'
param location       = 'canadaeast'

// VNET configuration — update CIDR ranges to fit your addressing scheme
param vnetAddressPrefix  = '10.0.0.0/16'
param apimSubnetPrefix   = '10.0.1.0/24'
param peSubnetPrefix     = '10.0.2.0/24'  // Private Endpoints
param appSubnetPrefix    = '10.0.3.0/24'  // App Services / Functions
