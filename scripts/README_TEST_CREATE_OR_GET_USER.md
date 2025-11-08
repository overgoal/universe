# Testing create_or_get_user Functionality

This directory contains scripts to manually test the `create_or_get_user` function, since automated tests cannot reliably verify it works correctly.

## ⚠️ Why Manual Testing?

The automated tests (`sozo test`) pass but are **misleading**:
- They only verify the function can be called without crashing
- They only verify it returns consistent results (even if wrong)
- They do NOT verify users are actually created
- They do NOT verify valid usernames are returned

The function appears to return `0` for usernames in the test environment, suggesting a permissions issue or test environment limitation.

## 🚀 How to Test

### Prerequisites

1. Make sure Katana is running:
   ```bash
   katana --config katana.toml
   ```

2. Deploy the universe contracts:
   ```bash
   cd universe
   sozo build
   sozo migrate
   ```

### Step 1: Execute create_or_get_user

Run the test script that calls `create_or_get_user` for multiple addresses:

```bash
cd universe
./scripts/test_create_or_get_user.sh
```

This script will:
- Call `create_or_get_user` for 3 different test addresses
- Call it twice for the first address (to test the "get existing" path)
- Submit all transactions to Katana
- Wait for transactions to be processed

**Expected output:**
```
🧪 Testing create_or_get_user functionality...

✅ Found game contract: 0x...
📝 Test 1: Creating user for address 0x1234...
✅ Transaction submitted: 0x...
📝 Test 2: Calling again for same address (should return existing)
✅ Transaction submitted: 0x...
📝 Test 3: Creating user for different address 0xfedc...
✅ Transaction submitted: 0x...
📝 Test 4: Creating user for third address 0xaaaa...
✅ Transaction submitted: 0x...

✅ All transactions submitted successfully!
📊 Now run ./scripts/verify_users.sh to check if users were created correctly
```

### Step 2: Verify Users Were Created

Run the verification script to check storage:

```bash
./scripts/verify_users.sh
```

This script will:
- Query the `User` model for each test address
- Verify users exist in storage
- Validate owner addresses match
- Validate usernames are non-zero
- Validate created_at timestamps are set
- Display all user data in human-readable format

**Expected output if working correctly:**
```
🔍 Verifying users in storage...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Test 1: Checking user for address 0x1234...

User found in storage:
  Owner:      0x1234567890abcdef1234567890abcdef12345678
  Username:   0x1234567890abcdef1234567890abcdef12345678
  Created At: 0x67890abc

✅ PASSED: User is valid
   Username (hex): 0x1234567890abcdef1234567890abcdef12345678
   Username (dec): 104059...
   Created at:     0x67890abc

[... similar for Test 2 and Test 3 ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Test 1: PASSED
✅ Test 2: PASSED
✅ Test 3: PASSED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 3 passed, 0 failed

🎉 All tests PASSED! create_or_get_user works correctly!
```

## 🔍 What to Check

### ✅ Success Indicators

1. **Users exist in storage** - `sozo model get User <address>` returns data
2. **Usernames are non-zero** - Username field contains the address as felt252
3. **Timestamps are set** - `created_at` is greater than 0
4. **Owners match** - Owner field matches the input address
5. **Idempotency works** - Calling twice for same address doesn't create duplicate

### ❌ Failure Indicators

1. **"Model not found"** - User wasn't created in storage
2. **Username is 0x0** - Function returned zero instead of valid username
3. **created_at is 0** - Timestamp wasn't set during creation
4. **Owner mismatch** - Wrong address stored
5. **Transaction fails** - Function threw an error

## 🐛 Troubleshooting

### Users Not Found in Storage

**Possible causes:**
- Permissions issue - game contract doesn't have write access to User model
- Function is failing silently
- Katana state was reset

**Solutions:**
1. Check permissions in `dojo_dev.toml`:
   ```toml
   [writers]
   "universe-User" = ["universe-game"]
   ```

2. Restart fresh:
   ```bash
   # Kill Katana
   pkill -f katana
   
   # Restart and redeploy
   katana --config katana.toml &
   sozo clean
   sozo build
   sozo migrate
   ```

3. Check for errors in Katana logs

### Username is Zero

**Possible causes:**
- `ContractAddress` to `felt252` conversion failing
- Function returning early without setting username
- Storage write failing

**Solutions:**
1. Check the implementation in `universe/src/systems/game.cairo`
2. Add debug logging to the function
3. Verify the conversion: `let username: felt252 = user_address.into();`

### Transaction Fails

**Possible causes:**
- Invalid address format
- Gas limit too low
- Contract not deployed

**Solutions:**
1. Verify contract is deployed: `sozo model get User 0x0`
2. Check Katana is running: `curl http://localhost:5050`
3. Increase gas limit in transaction

## 📝 Test Addresses

The scripts use these hardcoded test addresses:
- `0x1234567890abcdef1234567890abcdef12345678`
- `0xfedcba0987654321fedcba0987654321fedcba09`
- `0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`

You can modify these in both scripts if needed.

## 🔄 Clean Up

To reset and test again:

```bash
# Kill Katana
pkill -f katana

# Restart fresh
katana --config katana.toml &

# Redeploy
sozo clean
sozo build
sozo migrate

# Run tests again
./scripts/test_create_or_get_user.sh
./scripts/verify_users.sh
```

## 📊 Integration with Client

Once verified working, the client-side hook (`useCreateOrGetUser.tsx`) should work correctly:

```typescript
import { useCreateOrGetUser } from '../dojo/hooks/useCreateOrGetUser';

function MyComponent() {
  const { isCreating, error, username } = useCreateOrGetUser();
  
  // username will be populated after wallet connection
  // and create_or_get_user is called automatically
}
```

The hook uses Cartridge's `lookupAddresses` to convert the felt252 username back to a human-readable Cartridge username.

