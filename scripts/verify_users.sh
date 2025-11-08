#!/bin/bash

# Script to verify that users were created correctly
# Checks storage and validates usernames

set -e

echo "🔍 Verifying users in storage..."
echo ""

# Test addresses (same as in test_create_or_get_user.sh)
TEST_ADDR_1="0x1234567890abcdef1234567890abcdef12345678"
TEST_ADDR_2="0xfedcba0987654321fedcba0987654321fedcba09"
TEST_ADDR_3="0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Array to track results
declare -a RESULTS

# Function to check a user
check_user() {
    local address=$1
    local test_num=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Test $test_num: Checking user for address $address"
    echo ""
    
    # Query the user model
    USER_DATA=$(sozo model get User $address 2>&1)
    
    # Check if user exists
    if echo "$USER_DATA" | grep -q "Model not found"; then
        echo "❌ FAILED: User NOT FOUND in storage"
        RESULTS[$test_num]="FAILED"
        return 1
    fi
    
    # Extract fields (handle spaces and commas)
    OWNER=$(echo "$USER_DATA" | grep "owner" | awk -F':' '{print $2}' | tr -d ' ,' | tr -d '\n')
    USERNAME=$(echo "$USER_DATA" | grep "username" | awk -F':' '{print $2}' | tr -d ' ,' | tr -d '\n')
    CREATED_AT=$(echo "$USER_DATA" | grep "created_at" | awk -F':' '{print $2}' | tr -d ' ,' | tr -d '\n')
    
    echo "User found in storage:"
    echo "  Owner:      $OWNER"
    echo "  Username:   $USERNAME"
    echo "  Created At: $CREATED_AT"
    echo ""
    
    # Validate owner matches (normalize both to remove leading zeros for comparison)
    OWNER_NORMALIZED=$(echo "$OWNER" | sed 's/^0x0*/0x/')
    ADDR_NORMALIZED=$(echo "$address" | sed 's/^0x0*/0x/')
    
    if [ "$OWNER_NORMALIZED" != "$ADDR_NORMALIZED" ]; then
        echo "❌ FAILED: Owner mismatch!"
        echo "   Expected: $address"
        echo "   Got:      $OWNER"
        RESULTS[$test_num]="FAILED"
        return 1
    fi
    
    # Note: Username being zero is OK since it comes from Cartridge Controller
    # In this test we're not using the controller, so username will be 0x0
    if [ "$USERNAME" == "0x0" ] || [ "$USERNAME" == "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
        echo "⚠️  Username is zero (expected - not using Cartridge Controller in this test)"
    fi
    
    # Validate created_at is not zero
    if [ "$CREATED_AT" == "0x0" ] || [ "$CREATED_AT" == "0" ] || [ -z "$CREATED_AT" ]; then
        echo "❌ FAILED: Created timestamp is zero or empty!"
        RESULTS[$test_num]="FAILED"
        return 1
    fi
    
    # Convert username from hex to decimal for display
    USERNAME_DEC=$(printf "%d" $USERNAME 2>/dev/null || echo "N/A")
    
    echo "✅ PASSED: User is valid"
    echo "   Username (hex): $USERNAME"
    echo "   Username (dec): $USERNAME_DEC"
    echo "   Created at:     $CREATED_AT"
    RESULTS[$test_num]="PASSED"
    echo ""
}

# Check all test users
check_user "$TEST_ADDR_1" 1
check_user "$TEST_ADDR_2" 2
check_user "$TEST_ADDR_3" 3

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASSED=0
FAILED=0

for i in 1 2 3; do
    if [ "${RESULTS[$i]}" == "PASSED" ]; then
        echo "✅ Test $i: PASSED"
        ((PASSED++))
    else
        echo "❌ Test $i: FAILED"
        ((FAILED++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total: $PASSED passed, $FAILED failed"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests PASSED! create_or_get_user works correctly!"
    exit 0
else
    echo "⚠️  Some tests FAILED. create_or_get_user may have issues."
    exit 1
fi

