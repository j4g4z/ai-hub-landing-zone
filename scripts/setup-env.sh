#!/bin/bash
# setup-env.sh
# Configures the azd environment for the AI Hub Gateway Landing Zone deployment.
# Usage: ./scripts/setup-env.sh <subscription-id>

set -euo pipefail

SUBSCRIPTION_ID="${1:?Usage: $0 <subscription-id>}"
ENV_NAME="ailz-hub-dev-01"
LOCATION="canadaeast"

echo "🔐 Logging in to Azure..."
azd auth login

echo "⚙️  Configuring azd environment: $ENV_NAME"
azd env select "$ENV_NAME" 2>/dev/null || azd env new "$ENV_NAME"

azd env set AZURE_ENV_NAME        "$ENV_NAME"
azd env set AZURE_LOCATION        "$LOCATION"
azd env set AZURE_SUBSCRIPTION_ID "$SUBSCRIPTION_ID"

echo "✅ Environment configured. Run 'deploy-all.sh' to proceed with deployment."
