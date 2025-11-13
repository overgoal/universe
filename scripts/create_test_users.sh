#!/bin/bash

# Script to create test users from players.json
# This script reads the first 3 players from the JSON file and calls create_or_get_user

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Creating Test Users from players.json${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Please install it first:${NC}"
    echo "  brew install jq"
    exit 1
fi

# Path to players.json (relative to universe directory)
PLAYERS_JSON="../client/public/players.json"

# Check if players.json exists
if [ ! -f "$PLAYERS_JSON" ]; then
    echo -e "${RED}Error: players.json not found at $PLAYERS_JSON${NC}"
    exit 1
fi

# Read first 3 players and extract their names
echo -e "${BLUE}Reading first 3 players from players.json...${NC}"
echo ""

# Loop through first 3 players
for i in 0 1 2; do
    # Extract player name from JSON
    PLAYER_NAME=$(jq -r ".[$i].player_name" "$PLAYERS_JSON")
    
    # Generate a random address (using user_id as seed for consistency)
    USER_ID=$(jq -r ".[$i].user_id" "$PLAYERS_JSON")
    # Create a deterministic address based on user_id
    ADDRESS=$(printf "0x%064x" $((0x1000000000000000000000000000000 + USER_ID)))
    
    # Convert player name to felt252 format (short string)
    # For Cairo felt252, we need to convert the string to hex
    # Note: This is a simplified conversion - Cairo short strings are limited to 31 characters
    USERNAME_FELT=$(echo -n "$PLAYER_NAME" | xxd -p | tr -d '\n')
    USERNAME_FELT="0x$USERNAME_FELT"
    
    echo -e "${GREEN}Player $((i+1)):${NC}"
    echo "  Name: $PLAYER_NAME"
    echo "  Address: $ADDRESS"
    echo "  Username (felt): $USERNAME_FELT"
    echo ""
    
    # Call sozo execute to create or get user
    echo -e "${BLUE}Executing create_or_get_user...${NC}"
    
    sozo execute --world 0x073f377bcb4cee2e458351fee0d6ccb0eec3f4031de4fb990b45b03572ba84cd \
        game create_or_get_user \
        $ADDRESS $USERNAME_FELT \
        --wait
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ User created/retrieved successfully${NC}"
    else
        echo -e "${RED}✗ Failed to create/retrieve user${NC}"
    fi
    
    echo ""
    echo "---"
    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Test users creation completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "You can verify the users were created by checking the world state:"
echo "  sozo model get User <address>"

