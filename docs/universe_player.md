# UniversePlayer Model

## Purpose

`UniversePlayer` is a Dojo Model in an ECS world built with Cairo. It defines the storage layout for base player entities in the Universe game system. Each entity stores a unique identifier, foreign key reference to a User, timestamps for tracking activity, core gameplay attributes (fame, charisma, stamina, intelligence, leadership, strength, agility), universe currency, and appearance customization options.

This model serves as the foundation for game-specific player extensions like OvergoalPlayer, which adds football-specific attributes.

## Engine / Language

- **Engine**: Dojo (on Starknet)
- **Language**: Cairo
- **Storage types available**: `felt252`, `u8`, `u16`, `u64`, `u128`

## Field Specifications

### Primary Key
- **`id`** — Primary key. Stored as a `felt252`, representing a unique immutable identifier for this player entity. Generated either on-chain or off-chain and hashed to fit in a felt. Immutable after creation.

### Foreign Key
- **`user_id`** — Foreign key to `User.owner`. Stored as a `felt252`. Indexed for 1→N lookups to enable multiple players per user account. References the User model's owner field.

### Timestamps
- **`created_at`** — Stored as a `u64` representing Unix epoch time in seconds (UTC). Set once on creation and never changed.
- **`last_updated_at`** — Stored as a `u64` representing Unix epoch time in seconds (UTC). Bumped on any persisted change to track recent activity.
- **`last_login_at`** — Stored as a `u64` representing Unix epoch time in seconds (UTC). Set on login/session start to track user engagement.

### Core Attributes
- **`fame`** — Stored as a `u16` (0–65535). Core gameplay attribute representing player reputation or renown.
- **`charisma`** — Stored as a `u16` (0–65535). Core gameplay attribute affecting social interactions and influence.
- **`stamina`** — Stored as a `u16` (0–65535). Core gameplay attribute affecting endurance and physical activities.
- **`strength`** — Stored as a `u16` (0–65535). Core gameplay attribute affecting physical power and capability.
- **`agility`** — Stored as a `u16` (0–65535). Core gameplay attribute affecting speed and nimbleness.
- **`intelligence`** — Stored as a `u16` (0–65535). Core gameplay attribute affecting learning, strategy, and mental challenges.

### Currency
- **`universe_currency`** — Stored as a `u128` providing large on-chain balance headroom for in-game economy transactions.

### Appearance Customization
- **`body_type`** — Stored as a `u8` (0, 1, or 2). Player's body type for visual customization.
- **`skin_color`** — Stored as a `u8` (0, 1, or 2). Player's skin color for visual customization.
- **`beard_type`** — Stored as a `u8` (0 or 1). Beard type for visual customization (0 = no beard, 1 = beard).
- **`hair_type`** — Stored as a `u8` (0, 1, or 2). Hair style for visual customization.
- **`hair_color`** — Stored as a `u8` (0 or 1). Hair color for visual customization.

## Keys and Indexes

- **Primary key**: `id` (felt252)
- **Foreign key**: `user_id` references `User.owner`
- **Recommended indexes**: `user_id` for 1→N lookups, `last_login_at` for activity queries
- **Uniqueness**: `id` must be unique, `user_id` allows multiple players per user

## Encoding and Validation

- **`id`**: Represented as a single felt252. Do not store raw UUID bytes; use hash or integer form. Must be non-zero.
- **`user_id`**: Must reference a valid `User.owner`. Cannot be zero.
- **`created_at`**: Must be greater than 0 and set to the current timestamp on creation.
- **`last_updated_at`**: Must be greater than or equal to `created_at`. Updated on any field changes.
- **`last_login_at`**: Must be greater than or equal to `created_at`. Updated on session activity.
- **`fame`, `charisma`, `stamina`, `strength`, `agility`, `intelligence`**: Valid range 0–65535 (u16 bounds).
- **`universe_currency`**: Valid range 0–2^128-1, allowing for large economic values.
- **`body_type`, `skin_color`**: Valid values 0, 1, or 2 (u8).
- **`beard_type`**: Valid values 0 or 1 (u8).
- **`hair_type`**: Valid values 0, 1, or 2 (u8).
- **`hair_color`**: Valid values 0 or 1 (u8).

## Invariants

- `id` never changes once set.
- `user_id` never changes once set (permanent link to User).
- `created_at` never changes once set.
- `last_updated_at` >= `created_at` and is updated on any field modification.
- `last_login_at` >= `created_at` and tracks user session activity.
- All attribute values (fame, charisma, etc.) must stay within u16 bounds.
- `universe_currency` must stay within u128 bounds.
- Appearance values must stay within their specified ranges.

## Dojo Implementation Details

- **Derives**: `Copy`, `Drop`, `Serde`, `IntrospectPacked`, `Debug`
- **Uses** `#[dojo::model]` attribute
- **Implements** `ZeroableUniversePlayerTrait` for `Zero<UniversePlayer>` trait with `zero()`, `is_zero()`, `is_non_zero()`
- **Implements** `UniversePlayerAssert` trait with `assert_exists()` and `assert_not_exists()`
- **Zero check**: Uses `user_id` and `created_at` to determine if player exists (`user_id == 0 && created_at == 0`)

## Typical Systems

### Player Creation
- **`create_player(id, user_id, appearance_attrs, initial_attributes)`**: Creates player for a user with starting attribute values and appearance.

### Attribute Management
- **`add_fame(id, amount)`**: Adds to fame attribute and updates timestamp.
- **`add_charisma(id, amount)`**: Adds to charisma attribute and updates timestamp.
- **`add_stamina(id, amount)`**: Adds to stamina attribute and updates timestamp.
- **`add_strength(id, amount)`**: Adds to strength attribute and updates timestamp.
- **`add_agility(id, amount)`**: Adds to agility attribute and updates timestamp.
- **`add_intelligence(id, amount)`**: Adds to intelligence attribute and updates timestamp.

### Currency Management
- **`add_currency(id, amount)`**: Safely adds to universe_currency balance.
- **`spend_currency(id, amount)`**: Safely deducts from universe_currency with balance checks.

### Activity Tracking
- **`record_login(id)`**: Updates last_login_at timestamp for activity tracking.
- **`update_timestamp(id)`**: Updates last_updated_at timestamp.

### Queries
- **`player_exists(id)`**: Checks if a player is registered using `is_non_zero()`.

## Store Operations

- **`read_player_from_id(id)`**: Reads player by primary key
- **`read_players_by_user(user_id)`**: Reads all players for a specific user
- **`write_player(player)`**: Writes player to storage
- **`create_player(...)`**: Creates and stores new player with validation

## Relationships

- **Many-to-One with User**: Multiple players can belong to one user account
- **One-to-One with OvergoalPlayer**: UniversePlayer can be extended with OvergoalPlayer for football-specific attributes
- **Referenced by**: `OvergoalPlayer.universe_player_id`

## Example

A player entity with ID `0xdef456` might have a `UniversePlayer` model with:

```
id = 0xdef456 (felt252)
user_id = 0xabc123 (felt252, references User.owner)
created_at = 1736559000 (u64)
last_updated_at = 1736559500 (u64)
last_login_at = 1736559400 (u64)
fame = 150 (u16)
charisma = 200 (u16)
stamina = 180 (u16)
strength = 140 (u16)
agility = 160 (u16)
intelligence = 220 (u16)
universe_currency = 50000000000000000000 (u128)
body_type = 1 (u8)
skin_color = 2 (u8)
beard_type = 0 (u8)
hair_type = 1 (u8)
hair_color = 1 (u8)
```

## Appearance Values

### Body Type (0-2)
- **0**: Athletic build
- **1**: Average build
- **2**: Strong build

### Skin Color (0-2)
- **0**: Light
- **1**: Medium
- **2**: Dark

### Beard Type (0-1)
- **0**: No beard
- **1**: Beard

### Hair Type (0-2)
- **0**: Short
- **1**: Medium
- **2**: Long

### Hair Color (0-1)
- **0**: Dark
- **1**: Light

## Reasoning Hints for Assistant

- Use `felt252` for the primary key (`id` field) to allow flexible identifier generation.
- Use `felt252` for `user_id` foreign key to reference `User.owner` field.
- For time values, use `u64` with Unix epoch seconds.
- Use `u16` for gameplay attributes to provide good range while conserving storage.
- Use `u128` for currency to handle large economic values without overflow.
- Use `u8` for appearance options to save storage (small range of options).
- Follow the Zero trait pattern for existence checking (`is_zero`/`is_non_zero`).
- Use `assert_exists()` and `assert_not_exists()` for validation in systems.
- Always update `last_updated_at` when modifying any player data.
- Import constants module and use appropriate zero values.
- Validate that `user_id` references an existing User before creating player.

## Non-Goals

- No authentication or key management (handled by User model).
- No game-specific attributes (handled by extension models like OvergoalPlayer).
- No lists, collections, or nested structures in this core model.
- No direct ContractAddress usage for primary key - use felt252 for flexibility.
- No detailed match history or game-specific stats.

## Testing

All 11 unit tests for UniversePlayer model pass:
- Constructor validation (ID, user_id, timestamp)
- Invalid parameter handling (zero ID, zero user_id, zero timestamp)
- Zero value checks
- Currency operations (add/spend with validation)
- Insufficient currency handling
- Attribute operations (all six attributes)
- Assert traits (exists/not exists)
- Timestamp updates on modifications
- Login time updates

## Extension Pattern

UniversePlayer serves as a base model that can be extended by game-specific models:

1. **Create UniversePlayer** with core attributes and appearance
2. **Create game-specific player** (e.g., OvergoalPlayer) that references UniversePlayer via `universe_player_id`
3. **Game-specific model** adds specialized attributes (e.g., football skills, energy, injuries)
4. **Both models** exist in the same Universe world for easy access

This pattern allows:
- Reusable base player data across different game modes
- Separation of concerns (core vs game-specific)
- Flexible player management (one user → many players → many game modes)

