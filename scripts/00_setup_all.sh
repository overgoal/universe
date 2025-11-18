#!/bin/bash

# Master script to run all setup scripts in order
# Usage: ./scripts/00_setup_all.sh [player_limit]
# Example: ./scripts/00_setup_all.sh 10  (loads only first 10 players)

set -e

echo "🚀 Starting complete Overgoal setup..."
echo "========================================"
echo ""

PLAYER_LIMIT=${1:-0}

# Step 1: Load clubs
echo "Step 1/5: Loading clubs..."
./scripts/01_load_clubs.sh
echo ""

# Step 2: Load seasons
echo "Step 2/5: Loading seasons..."
./scripts/02_load_seasons.sh
echo ""

# Step 3: Create season_clubs
echo "Step 3/5: Creating season_clubs..."
./scripts/03_load_season_clubs.sh
echo ""

# Step 4: Load players
echo "Step 4/5: Loading players..."
if [ $PLAYER_LIMIT -gt 0 ]; then
    ./scripts/04_load_players.sh $PLAYER_LIMIT
else
    ./scripts/04_load_players.sh
fi
echo ""

echo "========================================"
echo "🎉 Complete setup finished successfully!"
echo ""
echo "Summary:"
echo "- Clubs: Loaded from client/data/clubs.json"
echo "- Seasons: Loaded from client/data/seasons.json"
echo "- Season Clubs: Created for Season 1"
if [ $PLAYER_LIMIT -gt 0 ]; then
    echo "- Players: Loaded first $PLAYER_LIMIT from client/data/players.json"
else
    echo "- Players: Loaded all from client/data/players.json"
fi
echo ""
echo "You can now test the claim flow!"

