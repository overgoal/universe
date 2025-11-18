#!/bin/bash

# Script to load seasons from client/data/seasons.json into the Dojo world
# Usage: ./scripts/02_load_seasons.sh

set -e

echo "📅 Loading seasons into Dojo world..."

# Configuration
PROFILE="sepolia"
WORLD_ADDRESS=$(grep "^world_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
ACCOUNT_ADDRESS=$(grep "^account_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
PRIVATE_KEY=$(grep "^private_key" dojo_${PROFILE}.toml | cut -d'"' -f2)

echo "World Address: $WORLD_ADDRESS"
echo "Account: $ACCOUNT_ADDRESS"
echo ""

# Read seasons from JSON and create them
jq -c '.[]' ../client/data/seasons.json | while read season; do
    season_id=$(echo $season | jq -r '.id')
    season_name=$(echo $season | jq -r '.name')
    start_date=$(echo $season | jq -r '.start_date')
    end_date=$(echo $season | jq -r '.end_date')
    prize_pool=$(echo $season | jq -r '.prize_pool')
    
    echo "Creating season: ID=$season_id, Name=$season_name"
    echo "  Start: $start_date, End: $end_date, Prize Pool: $prize_pool"
    
    # Execute create_season
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_season $season_id str:"$season_name" $start_date $end_date $prize_pool
    
    echo "✅ Season created: $season_name"
    echo ""
done

echo "🎉 All seasons loaded successfully!"

