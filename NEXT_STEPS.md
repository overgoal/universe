# Next Steps for Overgoal Claim Implementation

## ✅ Completed (Phases 1-3)

### Phase 1: Data Models
- ✅ Fixed `UniversePlayer` model to allow `user_id = 0` for unclaimed players
- ✅ Expanded `hair_color` range from 0-1 to 0-4
- ✅ Added `player_category`, `player_name`, `player_description` to `OvergoalPlayer`
- ✅ Removed `user_id` from `players.json`
- ✅ Updated all model tests

### Phase 2: Cairo Contracts
- ✅ Updated `create_or_get_user` to update timestamps
- ✅ Implemented `claim_player` method with proper validation
- ✅ Added `create_club`, `create_season` methods
- ✅ Added `create_season_club`, `create_universe_player`, `create_overgoal_player`, `create_season_player` methods
- ✅ Updated store with all necessary methods

### Phase 3: Setup Scripts
- ✅ Created `01_load_clubs.sh`
- ✅ Created `02_load_seasons.sh`
- ✅ Created `03_load_season_clubs.sh`
- ✅ Created `04_load_players.sh` (with limit parameter for testing)
- ✅ Created `00_setup_all.sh` master script
- ✅ Created comprehensive README for scripts

## 🔄 Required: Build and Deploy

**IMPORTANT:** Before proceeding, you must rebuild and redeploy the contracts:

```bash
cd universe

# Build the contracts
sozo --profile sepolia build

# Migrate (deploy) the contracts
sozo --profile sepolia migrate
```

After migration, update `dojo_sepolia.toml` with the new `world_address` if it changed.

## 🔐 Required: Grant Permissions

After migration, grant writer permissions to the game contract:

```bash
cd universe

# Grant all necessary permissions
./scripts/grant_permissions.sh
```

This grants the `universe-game` contract WRITER permissions on all models (Club, Season, SeasonClub, UniversePlayer, OvergoalPlayer, SeasonPlayer, User).

## 🚀 Next: Run Setup Scripts

Once permissions are granted, load the initial data:

```bash
cd universe

# Option 1: Load all data (recommended for production)
./scripts/00_setup_all.sh

# Option 2: Load only first 10 players (recommended for testing)
./scripts/00_setup_all.sh 10
```

## 📋 Remaining Tasks

### Phase 4: Update Client TypeScript
- [ ] Regenerate TypeScript bindings from new contracts
- [ ] Update `client/src/dojo/contracts.gen.ts` with new methods:
  - `claim_player`
  - `create_club`, `create_season`, `create_season_club`
  - `create_universe_player`, `create_overgoal_player`, `create_season_player`
- [ ] Update `client/src/dojo/bindings.ts` with new model interfaces:
  - `Club`, `Season`, `SeasonClub`, `OvergoalPlayer`, `SeasonPlayer`
- [ ] Update Zustand store (`client/src/zustand/store.ts`) with new model types

### Phase 5: Create Client Components
- [ ] Create `/claim/:player_id` route
- [ ] Create `ClaimScreen.tsx` component
- [ ] Create `useClaimPlayer.tsx` hook with:
  - Cartridge Controller connection
  - `create_or_get_user` call
  - `claim_player` call
  - Success/error handling
  - Navigation after success
- [ ] Add "Mint successful!" popup
- [ ] Load player data after successful claim

### Phase 6: Testing and Documentation
- [ ] Create debug script to query and display model data
- [ ] Add comprehensive console.log statements for debugging
- [ ] Update `claim.md` with implementation notes
- [ ] Test complete claim flow:
  - Connect wallet
  - Claim unclaimed player
  - Try to claim already-claimed player (should show error)
  - Try to claim own player again (should succeed)
  - Verify prize pool increases

## 🐛 Known Issues to Address

1. **UUID to felt252 Conversion**: The `04_load_players.sh` script uses Python to convert UUIDs to felt252. Ensure Python 3 is available on the deployment environment.

2. **Transaction Nonce**: If you encounter nonce errors during setup, add delays between script executions or run scripts individually.

3. **Gas Limits**: Loading all players may require significant gas. Consider loading in batches if needed.

## 📊 Data Verification

After running setup scripts, verify data was loaded correctly:

1. **Check Torii GraphQL endpoint** for loaded models
2. **Query specific models** to verify relationships
3. **Test claim flow** with a test player

## 🔍 Debugging Tools Needed

Create a script to inspect model data (as mentioned in `claim.md`):

```bash
# Example: scripts/inspect_models.sh
# Should query and display:
# - All clubs
# - All seasons
# - All season_clubs
# - Sample universe_players (first 5)
# - Sample overgoal_players (first 5)
# - Sample season_players (first 5)
```

## 📝 Notes

- All timestamps in contracts use seconds (u64)
- `linkID` from `players.json` is used as `UniversePlayer.id`
- Season 1 ID is `0x1`
- Prize pool increases by 1000 for each claimed player
- Players start with `user_id = 0` (unclaimed)
- After claim, `user_id` is set to the caller's address

## 🆘 If You Need Help

If you encounter issues:
1. Check `universe/scripts/README.md` for troubleshooting
2. Verify contract deployment with `sozo --profile sepolia model list`
3. Check Torii logs for indexing issues
4. Verify account has sufficient funds for transactions

