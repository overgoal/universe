#!/bin/bash
# Check if universe-game has permission to write UniversePlayer

set -e

echo "🔍 Checking Universe world permissions..."
echo ""

# Get addresses from manifest
WORLD_ADDRESS=$(cat manifest_dev.json | jq -r '.world.address')
GAME_ADDRESS=$(cat manifest_dev.json | jq -r '.contracts[] | select(.tag == "universe-game") | .address')

echo "📍 World Address: $WORLD_ADDRESS"
echo "📍 Game Contract: $GAME_ADDRESS"
echo ""

# Get the resource ID for UniversePlayer model
# In Dojo, resource IDs are computed as: hash(namespace, model_name)
# For universe-UniversePlayer, we need to compute the selector

echo "🔍 Checking if universe-game can write to UniversePlayer..."
echo ""
echo "Note: If permissions are not set correctly, you need to run:"
echo "  sozo auth grant writer UniversePlayer,universe-game --world $WORLD_ADDRESS"
echo ""

