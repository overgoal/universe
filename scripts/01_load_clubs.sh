#!/bin/bash

# Script to load clubs from client/data/clubs.json into the Dojo world
# Usage: ./scripts/01_load_clubs.sh

set -e

echo "🏟️  Loading clubs into Dojo world..."

# Configuration
PROFILE="sepolia"
WORLD_ADDRESS=$(grep "^world_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
ACCOUNT_ADDRESS=$(grep "^account_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
PRIVATE_KEY=$(grep "^private_key" dojo_${PROFILE}.toml | cut -d'"' -f2)

echo "World Address: $WORLD_ADDRESS"
echo "Account: $ACCOUNT_ADDRESS"
echo ""

# Read clubs from JSON and create them
jq -c '.[]' ../client/data/clubs.json | while read club; do
    club_id=$(echo $club | jq -r '.id')
    club_name=$(echo $club | jq -r '.name')
    
    echo "Creating club: ID=$club_id, Name=$club_name"
    
    # Convert club_id to hex (felt252)
    club_id_hex=$(printf "0x%x" $club_id)
    
    # Execute create_club
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_club $club_id_hex str:"$club_name"
    
    echo "✅ Club created: $club_name"
    echo ""
done

echo "🎉 All clubs loaded successfully!"
