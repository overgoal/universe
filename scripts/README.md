# Overgoal Setup Scripts

This directory contains scripts to load initial data into the Dojo world for the Overgoal game.

## Prerequisites

Before running these scripts, ensure you have:

1. **Built and migrated the contracts:**
   ```bash
   cd universe
   sozo --profile sepolia build
   sozo --profile sepolia migrate
   ```

2. **Updated `dojo_sepolia.toml`** with the correct:
   - `world_address`
   - `account_address`
   - `private_key`

3. **Installed required tools:**
   - `jq` (for JSON processing)
   - `python3` (for UUID conversion)

## Scripts Overview

### 00_setup_all.sh (Master Script)
Runs all setup scripts in the correct order.

**Usage:**
```bash
# Load all data
./scripts/00_setup_all.sh

# Load only first 10 players (for testing)
./scripts/00_setup_all.sh 10
```

### Individual Scripts

#### 01_load_clubs.sh
Loads all clubs from `client/data/clubs.json`.

**Usage:**
```bash
./scripts/01_load_clubs.sh
```

#### 02_load_seasons.sh
Loads all seasons from `client/data/seasons.json`.

**Usage:**
```bash
./scripts/02_load_seasons.sh
```

#### 03_load_season_clubs.sh
Creates season_club entries linking all clubs to Season 1.

**Usage:**
```bash
./scripts/03_load_season_clubs.sh
```

#### 04_load_players.sh
Loads all players from `client/data/players.json`, creating:
- `universe_player` (with `user_id = 0` for unclaimed)
- `overgoal_player` (linked to universe_player)
- `season_player` (linked to Season 1 and appropriate season_club)

**Usage:**
```bash
# Load all players
./scripts/04_load_players.sh

# Load only first 10 players (for testing)
./scripts/04_load_players.sh 10
```

## Execution Order

**Important:** Scripts must be run in this order:
1. Clubs (01)
2. Seasons (02)
3. Season Clubs (03)
4. Players (04)

The master script (`00_setup_all.sh`) handles this automatically.

## Data Flow

```
clubs.json → Clubs
seasons.json → Seasons
                ↓
         Season Clubs (Season 1 + All Clubs)
                ↓
players.json → Universe Players (user_id = 0)
                ↓
           Overgoal Players
                ↓
           Season Players (Season 1 + Season Clubs)
```

## Player ID Mapping

- `linkID` from `players.json` is converted from UUID to felt252
- This felt252 is used as:
  - `UniversePlayer.id`
  - `OvergoalPlayer.id`
  - `OvergoalPlayer.universe_player_id`
  - `SeasonPlayer.overgoal_player_id`

## Testing

For testing, use the limit parameter to load only a subset of players:

```bash
# Test with 3 players
./scripts/00_setup_all.sh 3
```

## Troubleshooting

### Script fails with "permission denied"
```bash
chmod +x scripts/*.sh
```

### "jq: command not found"
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

### "python3: command not found"
Install Python 3 for your system.

### Nonce errors
Wait a few seconds between script executions or add `sleep` commands between steps.

### Transaction failures
Check that:
- World address is correct in `dojo_sepolia.toml`
- Account has enough funds
- Contracts are properly deployed

## Verification

After running the scripts, you can verify the data was loaded correctly using the Torii GraphQL endpoint or by querying the models directly.

## Notes

- All players are created with `user_id = 0` (unclaimed)
- Players can be claimed through the `/claim/:player_id` flow
- Season 1 prize pool starts at 0 and increases by 1000 for each claimed player
- Timestamps in `players.json` are in milliseconds and converted to seconds for the contract

