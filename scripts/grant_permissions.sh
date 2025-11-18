#!/bin/bash

# Script to grant writer permissions to the game contract for all models
# Run this AFTER migration and BEFORE loading data
# Usage: ./scripts/grant_permissions.sh

set -e

echo "🔐 Granting writer permissions to game contract..."

# Configuration
PROFILE="sepolia"
WORLD_ADDRESS=$(grep "^world_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
ACCOUNT_ADDRESS=$(grep "^account_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
PRIVATE_KEY=$(grep "^private_key" dojo_${PROFILE}.toml | cut -d'"' -f2)

echo "World Address: $WORLD_ADDRESS"
echo "Account: $ACCOUNT_ADDRESS"
echo ""

# List of models that need writer permissions (with namespace prefix)
MODELS=(
    "universe-Club"
    "universe-Season"
    "universe-SeasonClub"
    "universe-UniversePlayer"
    "universe-OvergoalPlayer"
    "universe-SeasonPlayer"
    "universe-User"
)

# Grant writer permission for each model
for model in "${MODELS[@]}"; do
    echo "Granting WRITER permission on $model to universe-game..."
    
    sozo --profile $PROFILE auth grant writer \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        $model,universe-game
    
    echo "✅ Permission granted for $model"
    echo ""
done

echo "🎉 All permissions granted successfully!"
echo ""
echo "You can now run the setup scripts:"
echo "  ./scripts/00_setup_all.sh 10"

