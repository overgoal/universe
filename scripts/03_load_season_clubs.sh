#!/bin/bash

# Script to create season_clubs linking all clubs to Season 1
# Usage: ./scripts/03_load_season_clubs.sh

set -e

echo "🔗 Creating season_clubs for Season 1..."

# Configuration
PROFILE="sepolia"
WORLD_ADDRESS=$(grep "^world_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
ACCOUNT_ADDRESS=$(grep "^account_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
PRIVATE_KEY=$(grep "^private_key" dojo_${PROFILE}.toml | cut -d'"' -f2)

echo "World Address: $WORLD_ADDRESS"
echo "Account: $ACCOUNT_ADDRESS"
echo ""

# Season 1 ID
SEASON_ID="0x1"

# Read clubs from JSON and create season_clubs
jq -c '.[]' ../client/data/clubs.json | while read club; do
    club_id=$(echo $club | jq -r '.id')
    club_name=$(echo $club | jq -r '.name')
    
    # Convert club_id to hex (felt252)
    club_id_hex=$(printf "0x%x" $club_id)
    
    # Create a unique season_club_id by combining season_id and club_id
    # season_club_id = season_id * 1000 + club_id
    season_club_id=$((0x1 * 1000 + club_id))
    season_club_id_hex=$(printf "0x%x" $season_club_id)
    
    echo "Creating season_club: ID=$season_club_id_hex, Season=$SEASON_ID, Club=$club_id_hex ($club_name)"
    
    # Execute create_season_club
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_season_club $season_club_id_hex $SEASON_ID $club_id_hex
    
    echo "✅ SeasonClub created for: $club_name"
    echo ""
done

echo "🎉 All season_clubs created successfully!"

