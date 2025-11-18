#!/bin/bash

# Script to load players from client/data/players.json
# Creates universe_players, overgoal_players, and season_players
# Usage: ./scripts/04_load_players.sh [limit]
# Example: ./scripts/04_load_players.sh 10  (loads only first 10 players)

set -e

echo "⚽ Loading players into Dojo world..."

# Configuration
PROFILE="sepolia"
WORLD_ADDRESS=$(grep "^world_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
ACCOUNT_ADDRESS=$(grep "^account_address" dojo_${PROFILE}.toml | cut -d'"' -f2)
PRIVATE_KEY=$(grep "^private_key" dojo_${PROFILE}.toml | cut -d'"' -f2)

# Optional limit parameter (for testing)
LIMIT=${1:-0}

echo "World Address: $WORLD_ADDRESS"
echo "Account: $ACCOUNT_ADDRESS"
if [ $LIMIT -gt 0 ]; then
    echo "Limit: Loading only first $LIMIT players"
fi
echo ""

# Season 1 ID
SEASON_ID="0x1"

# Counter
count=0

SKIP_COUNT=118

# Read players from JSON
jq -c '.[]' ../client/data/players.json | while read player; do
    count=$((count + 1))
    
    # Skip already processed players
    if [ $count -le $SKIP_COUNT ]; then
        continue
    fi
    
    # Check limit
    if [ $LIMIT -gt 0 ] && [ $count -gt $LIMIT ]; then
        echo "Reached limit of $LIMIT players. Stopping."
        break
    fi
    
    # Extract player data
    link_id=$(echo $player | jq -r '.linkID')
    player_name=$(echo $player | jq -r '.player_name')
    team_id=$(echo $player | jq -r '.team_id')
    
    echo "[$count] Processing player: $player_name (linkID: $link_id, team: $team_id)"
    
    # Convert UUID linkID to felt252 (using Python for UUID to int conversion)
    player_id_hex=$(python3 -c "import uuid; print(hex(uuid.UUID('$link_id').int))")
    
    # Extract universe_player fields
    created_at=$(echo $player | jq -r '.created_at')
    # Convert milliseconds to seconds
    created_at=$((created_at / 1000))
    
    fame=$(echo $player | jq -r '.fame')
    charisma=$(echo $player | jq -r '.charisma')
    stamina=$(echo $player | jq -r '.stamina')
    strength=$(echo $player | jq -r '.strength')
    agility=$(echo $player | jq -r '.agility')
    intelligence=$(echo $player | jq -r '.intelligence')
    universe_currency=$(echo $player | jq -r '.universe_currency')
    body_type=$(echo $player | jq -r '.body_type')
    skin_color=$(echo $player | jq -r '.skin_color')
    beard_type=$(echo $player | jq -r '.beard_type')
    hair_type=$(echo $player | jq -r '.hair_type')
    hair_color=$(echo $player | jq -r '.hair_color')
    
    # Extract overgoal_player fields
    energy=$(echo $player | jq -r '.energy')
    speed=$(echo $player | jq -r '.speed')
    leadership=$(echo $player | jq -r '.leadership')
    pass=$(echo $player | jq -r '.pass')
    shoot=$(echo $player | jq -r '.shoot')
    freekick=$(echo $player | jq -r '.freekick')
    visor_type=$(echo $player | jq -r '.visor_type')
    visor_color=$(echo $player | jq -r '.visor_color')
    player_category=$(echo $player | jq -r '.player_category')
    player_description=$(echo $player | jq -r '.player_description')
    
    echo "  Creating universe_player..."
    # Create universe_player
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_universe_player $player_id_hex $created_at $fame $charisma $stamina $strength $agility $intelligence $universe_currency $body_type $skin_color $beard_type $hair_type $hair_color
    
    echo "  Creating overgoal_player..."
    # Create overgoal_player (using same ID as universe_player for simplicity)
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_overgoal_player $player_id_hex $player_id_hex $energy $speed $leadership $pass $shoot $freekick $visor_type $visor_color str:"$player_category" str:"$player_name" str:"$player_description"
    
    # Calculate season_club_id (season_id * 1000 + club_id)
    season_club_id=$((0x1 * 1000 + team_id))
    season_club_id_hex=$(printf "0x%x" $season_club_id)
    
    # Create a unique season_player_id (we'll use player_id + season offset)
    # season_player_id = player_id (we can reuse since it's already unique)
    season_player_id_hex=$player_id_hex
    
    echo "  Creating season_player (linking to season $SEASON_ID, club $team_id)..."
    # Create season_player
    sozo --profile $PROFILE execute \
        --account-address $ACCOUNT_ADDRESS \
        --private-key $PRIVATE_KEY \
        --wait \
        universe-game create_season_player $season_player_id_hex $SEASON_ID $season_club_id_hex $player_id_hex
    
    echo "✅ Player created: $player_name"
    echo ""
done

echo "🎉 All players loaded successfully!"

