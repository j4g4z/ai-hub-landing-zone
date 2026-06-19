#!/bin/bash
# deploy-all.sh
# Full deployment script for the AI Hub Gateway Landing Zone.
# Prerequisites: run setup-env.sh first, and ensure the base accelerator repo is cloned.
# Usage: ./scripts/deploy-all.sh <path-to-accelerator-repo>

set -euo pipefail

ACCELERATOR_PATH="${1:?Usage: $0 <path-to-ai-hub-gateway-solution-accelerator>}"
INFRA_PATH="$ACCELERATOR_PATH/bicep/infra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Step 1: Deploy Networking"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cp -r networking-only/ "$INFRA_PATH/"

az deployment sub create \
  --name aihub-networking \
  --location canadacentral \
  --template-file "$INFRA_PATH/networking-only/main.bicep" \
  --parameters "$INFRA_PATH/networking-only/main.bicepparam"

echo "Saving VNET outputs..."
VNET_NAME=$(az deployment sub show \
  --name aihub-networking \
  --query properties.outputs.vnetName.value -o tsv)

VNET_RG=$(az deployment sub show \
  --name aihub-networking \
  --query properties.outputs.vnetRG.value -o tsv)

azd env set VNET_NAME         "$VNET_NAME"
azd env set EXISTING_VNET_RG  "$VNET_RG"
azd env set USE_EXISTING_VNET true

echo "VNET_NAME=$VNET_NAME, VNET_RG=$VNET_RG"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Step 2: Deploy AI Hub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cp main.bicep "$INFRA_PATH/"
cp main.bicepparam "$INFRA_PATH/"

cd "$ACCELERATOR_PATH"
azd up

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Step 3: Deploy Access Contracts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cp -r contracts/ "$INFRA_PATH/citadel-access-contracts/"

echo "⚠️  Please update placeholder values in the contract file before continuing."
echo "   File: $INFRA_PATH/citadel-access-contracts/contracts/demo-1/dev/main.bicepparam"
read -rp "Press ENTER once values are updated..."

az deployment sub create \
  --name demo-1-dev \
  --location canadacentral \
  --template-file "$INFRA_PATH/citadel-access-contracts/main.bicep" \
  --parameters "$INFRA_PATH/citadel-access-contracts/contracts/demo-1/dev/main.bicepparam"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Deployment complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Test your endpoint (from within the VNET):"
echo ""
echo "  curl -X POST \"https://{your-apim-instance}.azure-api.net/models/chat/completions?api-version=2024-08-01-preview\" \\"
echo "    -H \"api-key: {api-key-from-key-vault}\" \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"model\":\"gpt-4o\",\"messages\":[{\"role\":\"user\",\"content\":\"hello\"}]}'"
