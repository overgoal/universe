#!/bin/bash

# Script to query all users from Torii GraphQL and decode them to human-readable format

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Querying All Users from Torii${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Torii GraphQL endpoint
TORII_URL="http://localhost:8080/graphql"

# Check if Torii is running
if ! curl -s "$TORII_URL" > /dev/null 2>&1; then
    echo -e "${RED}Error: Torii is not running at $TORII_URL${NC}"
    echo "Please start Torii first with: torii --world <world_address>"
    exit 1
fi

echo -e "${BLUE}Fetching users from Torii...${NC}"
echo ""

# GraphQL query to get all users
QUERY='{
  "query": "query { universeUserModels { edges { node { owner username created_at } } } }"
}'

# Execute GraphQL query
RESPONSE=$(curl -s -X POST "$TORII_URL" \
  -H "Content-Type: application/json" \
  -d "$QUERY")

# Check if response contains errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    echo -e "${RED}GraphQL Error:${NC}"
    echo "$RESPONSE" | jq '.errors'
    exit 1
fi

# Parse and display users
USER_COUNT=$(echo "$RESPONSE" | jq '.data.universeUserModels.edges | length')

if [ "$USER_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No users found in the world.${NC}"
    exit 0
fi

echo -e "${GREEN}Found $USER_COUNT user(s):${NC}"
echo ""
echo "========================================"

# Function to decode felt252 to ASCII string
decode_felt_to_string() {
    local felt=$1
    # Remove 0x prefix and leading zeros
    felt=${felt#0x}
    felt=$(echo "$felt" | sed 's/^0*//')
    
    # If empty after removing zeros, return empty string
    if [ -z "$felt" ]; then
        echo ""
        return
    fi
    
    # Convert hex to ASCII
    echo "$felt" | xxd -r -p 2>/dev/null || echo "[decode error]"
}

# Function to convert hex timestamp to human-readable date
decode_timestamp() {
    local hex_ts=$1
    # Convert hex to decimal
    local dec_ts=$((hex_ts))
    
    # Convert to human-readable date (works on both Linux and macOS)
    if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        date -d "@$dec_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$dec_ts"
    else
        # BSD date (macOS)
        date -r "$dec_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$dec_ts"
    fi
}

# Iterate through users and display them
echo "$RESPONSE" | jq -r '.data.universeUserModels.edges[] | @json' | while read -r user; do
    OWNER=$(echo "$user" | jq -r '.node.owner')
    USERNAME_FELT=$(echo "$user" | jq -r '.node.username')
    CREATED_AT=$(echo "$user" | jq -r '.node.created_at')
    
    # Decode username from felt252 to string
    USERNAME_DECODED=$(decode_felt_to_string "$USERNAME_FELT")
    
    # Decode timestamp
    CREATED_AT_READABLE=$(decode_timestamp "$CREATED_AT")
    
    echo -e "${GREEN}User:${NC}"
    echo "  Address:        $OWNER"
    echo "  Username (hex): $USERNAME_FELT"
    echo "  Username:       ${YELLOW}$USERNAME_DECODED${NC}"
    echo "  Created At:     $CREATED_AT_READABLE"
    echo "========================================"
done

echo ""
echo -e "${GREEN}Total users: $USER_COUNT${NC}"
echo ""

