# User Model

## Purpose

`User` is a Dojo Model in an ECS world built with Cairo. It defines the storage layout for player accounts in the game. Each entity that has this model will store a contract address identifier, a display username, and the timestamp of when it was created.

## Engine / Language

- **Engine**: Dojo (on Starknet)
- **Language**: Cairo
- **Storage types available**: `ContractAddress`, `felt252`, `u64`

## Field Specifications

### Primary Key
- **`owner`** — Primary key. Stored as a `ContractAddress`, representing the account that owns this user profile. Follows Dojo convention of using ContractAddress as entity keys. Immutable after creation.

### User Information
- **`username`** — Stored as a `felt252` short string (≤31 ASCII chars). Case-insensitive by convention. Should be unique across all User models.

### Timestamps
- **`created_at`** — Stored as a `u64` representing Unix epoch time in seconds (UTC). Set once on creation and never changed.

## Keys and Indexes

- **Primary key**: `owner` (ContractAddress)
- **Recommended index**: `username` for fast lookups
- **Uniqueness**: `owner` and `username` must be unique, enforced by system logic

## Encoding and Validation

- **`owner`**: Must be a valid non-zero ContractAddress. Uses Dojo's standard entity keying pattern.
- **`username`**: Must be ≤31 characters, contain only [a-z0-9_.], and be normalized to lowercase before storage.
- **`created_at`**: Must be greater than 0 and set to the current timestamp on creation.

## Invariants

- `owner` never changes once set.
- `created_at` never changes once set.
- `username` can change only via a dedicated rename system and must remain unique.

## Dojo Implementation Details

- **Derives**: `Copy`, `Drop`, `Serde`, `IntrospectPacked`, `Debug`
- **Uses** `#[dojo::model]` attribute
- **Implements** `ZeroableUserTrait` for `Zero<User>` trait with `zero()`, `is_zero()`, `is_non_zero()`
- **Implements** `UserAssert` trait with `assert_exists()` and `assert_not_exists()`
- **Additional traits**: `UserHelpers` for utility functions (same user check, timestamp comparisons)

## Typical Systems

### User Management
- **`create_user(username)`**: Creates user for caller address with current timestamp.
- **`create_user_with_address(owner, username)`**: Creates user for specific address.
- **`create_or_get_user(owner, username)`**: Creates user if not exists, returns existing username if exists.
- **`rename_user(new_username)`**: Updates username for caller while preserving uniqueness.
- **`rename_user_with_address(owner, new_username)`**: Updates username for specific address.
- **`user_exists(owner)`**: Checks if a user is registered using `is_non_zero()`.

### Validation
- **`is_valid()`**: Checks if user has valid non-zero values.
- **`assert_exists()`**: Asserts that user exists (panics if not).
- **`assert_not_exists()`**: Asserts that user doesn't exist (panics if exists).

### Helper Functions
- **`is_same_user(user1, user2)`**: Checks if two users have the same owner.
- **`created_after(timestamp)`**: Checks if user was created after a specific time.
- **`created_before(timestamp)`**: Checks if user was created before a specific time.
- **`display_info()`**: Returns formatted user information for debugging.

## Store Operations

- **`read_user()`**: Reads user for caller address
- **`read_user_from_address(owner)`**: Reads user for specific address
- **`write_user(user)`**: Writes user to storage
- **`create_user_with_address(owner, username)`**: Creates and stores new user with validation

## Relationships

- **One-to-Many with UniversePlayer**: A user can have multiple players (via `user_id` foreign key)
- **Referenced by**: `UniversePlayer.user_id`, `OvergoalPlayer` (indirect via UniversePlayer)

## Example

An entity with owner address `0xabc123` might have a `User` model with:

```
owner = 0xabc123 (ContractAddress)
username = "matias" (felt252)
created_at = 1736559000 (u64) // Unix timestamp
```

## Username Encoding

Usernames are stored as `felt252` short strings:
- Maximum length: 31 ASCII characters
- Recommended characters: lowercase letters, numbers, underscore, dot [a-z0-9_.]
- Case-insensitive by convention (normalize to lowercase before storage)
- Example: "player_one" → stored as felt252 representation

## Reasoning Hints for Assistant

- Always use `ContractAddress` for the primary key (`owner` field) to match Dojo conventions.
- For time values, use `u64` with Unix epoch seconds.
- Username stored as `felt252` short string (≤31 chars).
- Follow the Zero trait pattern for existence checking (`is_zero`/`is_non_zero`).
- Use `assert_exists()` and `assert_not_exists()` for validation in systems.
- Import constants module and use `ZERO_ADDRESS()` for zero values.
- Validate username uniqueness before creating or renaming users.
- Use helper functions for common operations (timestamp comparisons, user equality).

## Non-Goals

- No authentication or key management (handled by wallet/Cartridge Controller).
- No personally identifiable information beyond the public username.
- No lists, collections, or nested structures in this core model.
- No UUID or felt252 identifiers - use ContractAddress for Dojo compatibility.
- No password or private data storage.
- No email or contact information.

## Testing

All 8 unit tests for User model pass:
- Constructor validation (owner, username, timestamp)
- Zero value checks
- Assert traits (exists/not exists)
- Helper functions (same user, created after/before)
- Invalid owner, username, and timestamp handling

## Security Considerations

- Username uniqueness must be enforced at the system level
- Username changes should be carefully controlled (frequency limits, validation)
- Owner address is immutable - represents permanent account ownership
- No sensitive data should be stored in the username field

