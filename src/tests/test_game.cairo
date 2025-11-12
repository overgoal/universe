// Integration tests for Game Starter functionality
#[cfg(test)]
mod tests {
    // Dojo imports
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait};
    
    // System imports
    use universe::systems::game::{game, IUniverseDispatcher, IUniverseDispatcherTrait};
    
    // Models imports
    use universe::models::universe_player::{UniversePlayer, m_UniversePlayer};
    use universe::models::user::{m_User, User, ZeroableUserTrait};
    use core::num::traits::Zero;
    
    fn namespace_def() -> NamespaceDef {
        NamespaceDef {
            namespace: "universe",
            resources: [
                TestResource::Model(m_UniversePlayer::TEST_CLASS_HASH),
                TestResource::Model(m_User::TEST_CLASS_HASH),
                TestResource::Contract(game::TEST_CLASS_HASH)
            ].span()
        }
    }
    
    fn contract_defs() -> Span<dojo_cairo_test::ContractDef> {
        [
            ContractDefTrait::new(@"universe", @"game")
                .with_writer_of([dojo::utils::bytearray_hash(@"universe")].span())
        ].span()
    }

    // Helper function to set up test environment
    fn setup() -> (dojo::world::WorldStorage, IUniverseDispatcher, starknet::ContractAddress) {
        // Initialize test environment
        let caller = starknet::contract_address_const::<0x123>();
        
        let ndef = namespace_def();
        let mut world = spawn_test_world(dojo::world::world::TEST_CLASS_HASH, array![ndef].span());
        
        // Ensures permissions and initializations are synced
        world.sync_perms_and_inits(contract_defs());
        
        // Get the game contract dispatcher
        let (contract_address, _) = world.dns(@"game").unwrap();
        let game_system = IUniverseDispatcher { contract_address };
        
        // Set caller address and block timestamp
        starknet::testing::set_contract_address(caller);
        starknet::testing::set_account_contract_address(caller);
        starknet::testing::set_block_timestamp(1736559000);
        
        (world, game_system, caller)
    }

    #[test]
    #[available_gas(30000000)]
    fn test_create_player() {
        // Setup test environment
        let (world, game_system, _caller) = setup();
        
        // Test creating a player with unique ID and appearance
        let player_id: felt252 = 0x123456789abcdef;
        
        // Check player doesn't exist before creation
        let player_before: UniversePlayer = world.read_model(player_id);
        assert(player_before.user_id == 0, 'Player should not exist yet');
        
        // Create player with appearance attributes
        let user_id: felt252 = 0x999;
        game_system.create_player(
            player_id,
            user_id,
            1,  // body_type
            2,  // skin_color
            0,  // beard_type
            1,  // hair_type
            1   // hair_color
        );
        
        // Verify player was created successfully
        let player: UniversePlayer = world.read_model(player_id);
        
        // Assertions
        assert(player.id == player_id, 'Player ID mismatch');
        assert(player.user_id != 0, 'User ID should be set');
        assert(player.created_at > 0, 'Created timestamp set');
        assert(player.fame == 0, 'Fame starts at 0');
        assert(player.charisma == 0, 'Charisma starts at 0');
        assert(player.stamina == 0, 'Stamina starts at 0');
        assert(player.strength == 0, 'Strength starts at 0');
        assert(player.agility == 0, 'Agility starts at 0');
        assert(player.intelligence == 0, 'Intel starts at 0');
        assert(player.universe_currency == 0, 'Currency starts at 0');
        assert(player.body_type == 1, 'Body type should be 1');
        assert(player.skin_color == 2, 'Skin color should be 2');
        assert(player.beard_type == 0, 'Beard type should be 0');
        assert(player.hair_type == 1, 'Hair type should be 1');
        assert(player.hair_color == 1, 'Hair color should be 1');
    }

    #[test]
    #[available_gas(30000000)]
    fn test_create_or_get_user_creates_new_user() {
        // Setup test environment with unique address to avoid conflicts
        let (world, game_system, _caller) = setup();
        let caller = starknet::contract_address_const::<0x999>();
        starknet::testing::set_contract_address(caller);
        starknet::testing::set_account_contract_address(caller);
        
        // Verify user doesn't exist before creation
        let user_before: User = world.read_model(caller);
        assert(user_before.created_at == 0, 'User should not exist yet');
        
        // Call create_or_get_user - should create new user
        let test_username: felt252 = 'TestPlayer123';
        let username = game_system.create_or_get_user(caller, test_username);
        
        // Verify user was created
        let user: User = world.read_model(caller);
        assert((@user).is_non_zero(), 'User should exist now');
        assert(user.owner == caller, 'Owner should be caller');
        assert(user.username == username, 'Username should match return');
        assert(user.created_at > 0, 'Created timestamp should be set');
        
        // Username should be the provided username
        assert(user.username == test_username, 'Username should match input');
    }

    #[test]
    #[available_gas(30000000)]
    fn test_create_or_get_user_returns_existing_user() {
        // Setup test environment with unique address
        let (world, game_system, _caller) = setup();
        let caller = starknet::contract_address_const::<0x888>();
        starknet::testing::set_contract_address(caller);
        starknet::testing::set_account_contract_address(caller);
        
        // Import User model for reading
        use universe::models::user::{User};
        
        // First call - creates user
        let test_username: felt252 = 'TestPlayer456';
        let username_first = game_system.create_or_get_user(caller, test_username);
        let user_first: User = world.read_model(caller);
        let created_at_first = user_first.created_at;
        
        // Wait a bit (simulate time passing)
        starknet::testing::set_block_timestamp(1736559100);
        
        // Second call - should return existing user (even with different username param)
        let different_username: felt252 = 'DifferentName';
        let username_second = game_system.create_or_get_user(caller, different_username);
        let user_second: User = world.read_model(caller);
        
        // Verify same user is returned with original username
        assert(username_first == username_second, 'Username should not change');
        assert(user_second.owner == caller, 'Owner should be same');
        assert(user_second.created_at == created_at_first, 'Created_at should not change');
        
        // Verify user was not recreated (created_at didn't change)
        assert(user_second.created_at == user_first.created_at, 'User should not be recreated');
        assert(user_second.username == test_username, 'Original username preserved');
    }

    #[test]
    #[available_gas(30000000)]
    fn test_create_or_get_user_multiple_addresses() {
        // Setup test environment
        let (world, game_system, _caller) = setup();
        
        // Create users for different addresses
        let address1 = starknet::contract_address_const::<0x111>();
        let address2 = starknet::contract_address_const::<0x222>();
        let address3 = starknet::contract_address_const::<0x333>();
        
        // Create first user
        starknet::testing::set_contract_address(address1);
        starknet::testing::set_account_contract_address(address1);
        let username1 = game_system.create_or_get_user(address1, 'Alice123');
        
        // Create second user
        starknet::testing::set_contract_address(address2);
        starknet::testing::set_account_contract_address(address2);
        let username2 = game_system.create_or_get_user(address2, 'Bob456');
        
        // Create third user
        starknet::testing::set_contract_address(address3);
        starknet::testing::set_account_contract_address(address3);
        let username3 = game_system.create_or_get_user(address3, 'Charlie789');
        
        // Verify all users exist and are different
        let user1: User = world.read_model(address1);
        let user2: User = world.read_model(address2);
        let user3: User = world.read_model(address3);
        
        assert((@user1).is_non_zero(), 'User 1 should exist');
        assert((@user2).is_non_zero(), 'User 2 should exist');
        assert((@user3).is_non_zero(), 'User 3 should exist');
        
        assert(user1.owner == address1, 'User 1 owner mismatch');
        assert(user2.owner == address2, 'User 2 owner mismatch');
        assert(user3.owner == address3, 'User 3 owner mismatch');
        
        assert(username1 != username2, 'Usernames should differ');
        assert(username2 != username3, 'Usernames should differ');
        assert(username1 != username3, 'Usernames should differ');
        
        assert(username1 == 'Alice123', 'Username 1 should match');
        assert(username2 == 'Bob456', 'Username 2 should match');
        assert(username3 == 'Charlie789', 'Username 3 should match');
    }

    #[test]
    #[available_gas(30000000)]
    fn test_create_or_get_user_idempotent() {
        // Setup test environment with unique address
        let (world, game_system, _caller) = setup();
        let caller = starknet::contract_address_const::<0x777>();
        starknet::testing::set_contract_address(caller);
        starknet::testing::set_account_contract_address(caller);
        
        // Call create_or_get_user multiple times with same and different usernames
        let username1 = game_system.create_or_get_user(caller, 'Player999');
        let username2 = game_system.create_or_get_user(caller, 'DifferentName1');
        let username3 = game_system.create_or_get_user(caller, 'DifferentName2');
        let username4 = game_system.create_or_get_user(caller, 'DifferentName3');
        
        // All calls should return the first username (user already exists)
        assert(username1 == username2, 'Username should be same');
        assert(username2 == username3, 'Username should be same');
        assert(username3 == username4, 'Username should be same');
        assert(username1 == 'Player999', 'Original username preserved');
        
        // Verify only one user exists
        let user: User = world.read_model(caller);
        assert((@user).is_non_zero(), 'User should exist');
        assert(user.username == username1, 'Username should match');
        assert(user.username == 'Player999', 'Username should be original');
    }
}