#!/bin/bash

# Script to verify data in Torii GraphQL endpoint
# Usage: ./scripts/verify_data.sh [torii_url]
# Default: http://localhost:8080/graphql

set -e

TORII_URL="${1:-http://localhost:8080/graphql}"

echo "🔍 Verifying data in Torii..."
echo "Torii URL: $TORII_URL"
echo ""

# Function to run GraphQL query
run_query() {
    local query="$1"
    local description="$2"
    
    echo "📊 $description"
    curl -s -X POST "$TORII_URL" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$query\"}" | jq '.'
    echo ""
}

# Check all available models
echo "═══════════════════════════════════════"
echo "  Available Models"
echo "═══════════════════════════════════════"
run_query 'query { __type(name: \"World__Query\") { fields { name } } }' "All available models"

# Check Clubs
echo "═══════════════════════════════════════"
echo "  Clubs"
echo "═══════════════════════════════════════"
run_query 'query { universeClubModels { totalCount edges { node { id name } } } }' "Total clubs and first few"

# Check Seasons
echo "═══════════════════════════════════════"
echo "  Seasons"
echo "═══════════════════════════════════════"
run_query 'query { universeSeasonModels { totalCount edges { node { id name start_date end_date prize_pool } } } }' "All seasons"

# Check Season Clubs
echo "═══════════════════════════════════════"
echo "  Season Clubs (Season 1)"
echo "═══════════════════════════════════════"
run_query 'query { universeSeasonClubModels(first: 20) { totalCount edges { node { id season_id club_id } } } }' "Season clubs for Season 1"

# Check Universe Players
echo "═══════════════════════════════════════"
echo "  Universe Players"
echo "═══════════════════════════════════════"
run_query 'query { universeUniversePlayerModels(first: 5) { totalCount edges { node { id user_id fame charisma stamina } } } }' "Total players and first 5"

# Check Overgoal Players
echo "═══════════════════════════════════════"
echo "  Overgoal Players"
echo "═══════════════════════════════════════"
run_query 'query { universeOvergoalPlayerModels(first: 5) { totalCount edges { node { id universe_player_id player_name player_category energy speed } } } }' "Total overgoal players and first 5"

# Check Season Players
echo "═══════════════════════════════════════"
echo "  Season Players"
echo "═══════════════════════════════════════"
run_query 'query { universeSeasonPlayerModels(first: 5) { totalCount edges { node { id season_id season_club_id overgoal_player_id } } } }' "Total season players and first 5"

# Check Users
echo "═══════════════════════════════════════"
echo "  Users"
echo "═══════════════════════════════════════"
run_query 'query { universeUserModels { totalCount edges { node { owner username created_at } } } }' "All users"

# Check specific player (first player from JSON)
echo "═══════════════════════════════════════"
echo "  Specific Player Check"
echo "═══════════════════════════════════════"
PLAYER_ID="0x53c626271e1142d98a998e5cdd8c68c1"
echo "Checking player: $PLAYER_ID (Oliver Thompson)"
run_query "query { universeUniversePlayerModels(where: { id: \"$PLAYER_ID\" }) { edges { node { id user_id fame charisma stamina strength agility intelligence } } } }" "Universe Player details"
run_query "query { universeOvergoalPlayerModels(where: { id: \"$PLAYER_ID\" }) { edges { node { id universe_player_id player_name player_category player_description energy speed leadership pass shoot freekick } } } }" "Overgoal Player details"

echo "═══════════════════════════════════════"
echo "  ✅ Verification Complete!"
echo "═══════════════════════════════════════"
echo ""
echo "Summary:"
echo "- Run this script anytime to verify data in Torii"
echo "- Default URL: http://localhost:8080/graphql"
echo "- For Sepolia: ./scripts/verify_data.sh https://your-torii-url/graphql"
echo ""

