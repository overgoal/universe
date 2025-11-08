#!/bin/bash

# Script to manually test create_or_get_user functionality
# This calls the function via sozo execute and verifies it works

set -e

echo "🧪 Testing create_or_get_user functionality..."
echo ""

# Test addresses
TEST_ADDR_1="0x1234567890abcdef1234567890abcdef12345678"
TEST_ADDR_2="0xfedcba0987654321fedcba0987654321fedcba09"
TEST_ADDR_3="0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Get the game contract address
GAME_ADDRESS=$(cat manifest_dev.json | jq -r '.contracts[] | select(.tag == "universe-game") | .address')

if [ -z "$GAME_ADDRESS" ] || [ "$GAME_ADDRESS" == "null" ]; then
    echo "❌ Error: Could not find universe-game contract address"
    exit 1
fi

echo "✅ Found game contract: $GAME_ADDRESS"
echo ""

# Test 1: Create user for first address
echo "📝 Test 1: Creating user for address $TEST_ADDR_1"
echo "Executing: sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_1"
RESULT_1=$(sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_1 2>&1)

if echo "$RESULT_1" | grep -q "Transaction hash"; then
    TX_HASH_1=$(echo "$RESULT_1" | grep "Transaction hash" | awk '{print $NF}')
    echo "✅ Transaction submitted: $TX_HASH_1"
else
    echo "❌ Failed to execute transaction"
    echo "$RESULT_1"
    exit 1
fi

echo "⏳ Waiting for transaction to be processed..."
sleep 3
echo ""

# Test 2: Call again for same address (should return existing user)
echo "📝 Test 2: Calling again for same address (should return existing)"
echo "Executing: sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_1"
RESULT_2=$(sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_1 2>&1)

if echo "$RESULT_2" | grep -q "Transaction hash"; then
    TX_HASH_2=$(echo "$RESULT_2" | grep "Transaction hash" | awk '{print $NF}')
    echo "✅ Transaction submitted: $TX_HASH_2"
else
    echo "❌ Failed to execute transaction"
    echo "$RESULT_2"
    exit 1
fi

echo "⏳ Waiting for transaction to be processed..."
sleep 3
echo ""

# Test 3: Create user for second address
echo "📝 Test 3: Creating user for different address $TEST_ADDR_2"
echo "Executing: sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_2"
RESULT_3=$(sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_2 2>&1)

if echo "$RESULT_3" | grep -q "Transaction hash"; then
    TX_HASH_3=$(echo "$RESULT_3" | grep "Transaction hash" | awk '{print $NF}')
    echo "✅ Transaction submitted: $TX_HASH_3"
else
    echo "❌ Failed to execute transaction"
    echo "$RESULT_3"
    exit 1
fi

echo "⏳ Waiting for transaction to be processed..."
sleep 3
echo ""

# Test 4: Create user for third address
echo "📝 Test 4: Creating user for third address $TEST_ADDR_3"
echo "Executing: sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_3"
RESULT_4=$(sozo execute $GAME_ADDRESS create_or_get_user $TEST_ADDR_3 2>&1)

if echo "$RESULT_4" | grep -q "Transaction hash"; then
    TX_HASH_4=$(echo "$RESULT_4" | grep "Transaction hash" | awk '{print $NF}')
    echo "✅ Transaction submitted: $TX_HASH_4"
else
    echo "❌ Failed to execute transaction"
    echo "$RESULT_4"
    exit 1
fi

echo "⏳ Waiting for transaction to be processed..."
sleep 3
echo ""

echo "✅ All transactions submitted successfully!"
echo ""
echo "📊 Now run ./scripts/verify_users.sh to check if users were created correctly"

