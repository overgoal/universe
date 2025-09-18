// Integration tests for Game Starter functionality
#[cfg(test)]
mod tests {
    // Test utilities
    use full_starter_react::tests::utils::utils::{
        PLAYER, cheat_caller_address, create_game_system, create_test_world,
    };
    
    // System imports
    use full_starter_react::systems::game::{IGameDispatcherTrait};
    
    // Models imports
    use full_starter_react::models::player::{Player};
    
    // Dojo imports
    #[allow(unused_imports)]
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo::model::{ModelStorage};
    
    
    #[test]
    #[available_gas(40000000)]
    fn test_create_player() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Test creating a player
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        // Verify player was created successfully
        let player: Player = world.read_model(player_id);
        
        // Basic player validation
        assert(player.id == player_id, 'Player ID should match');
        assert(player.user_id != 0, 'Player should have user_id');
        assert(player.created_at > 0, 'Player should have created_at');
        assert(player.fame == 0, 'Player starts with 0 fame');
        assert(player.charisma == 0, 'Player starts with 0 charisma');
        assert(player.stamina == 0, 'Player starts with 0 stamina');
        assert(player.intelligence == 0, 'Player starts with 0 intelligence');
        assert(player.leadership == 0, 'Player starts with 0 leadership');
        assert(player.universe_currency == 0, 'Player starts with 0 currency');
    }
    
    #[test]
    #[available_gas(40000000)]
    fn test_update_player_attributes() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Create a player first
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        // Update player attributes
        game_system.update_attributes(player_id, 10, 15, 20, 25, 30);
        
        // Verify player state after attribute update
        let player: Player = world.read_model(player_id);
        
        assert(player.fame == 10, 'Fame should be 10');
        assert(player.charisma == 15, 'Charisma should be 15');
        assert(player.stamina == 20, 'Stamina should be 20');
        assert(player.intelligence == 25, 'Intelligence should be 25');
        assert(player.leadership == 30, 'Leadership should be 30');
    }
    
    #[test]
    #[available_gas(40000000)]
    fn test_add_currency() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Create a player first
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        // Add currency
        game_system.add_currency(player_id, 1000);
        
        // Verify player state after adding currency
        let player: Player = world.read_model(player_id);
        
        assert(player.universe_currency == 1000, 'Currency should be 1000');
    }
    
    #[test]
    #[available_gas(40000000)]
    fn test_spend_currency() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Create a player first
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        // Add currency first
        game_system.add_currency(player_id, 1000);
        
        // Spend some currency
        game_system.spend_currency(player_id, 300);
        
        // Verify player state after spending currency
        let player: Player = world.read_model(player_id);
        
        assert(player.universe_currency == 700, 'Currency should be 700');
    }
    
    #[test]
    #[available_gas(40000000)]
    fn test_record_login() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Create a player first
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        let initial_player: Player = world.read_model(player_id);
        let initial_login_time = initial_player.last_login_at;
        
        // Record login
        game_system.record_login(player_id);
        
        // Verify login time was updated
        let updated_player: Player = world.read_model(player_id);
        
        assert(updated_player.last_login_at >= initial_login_time, 'Login time should be updated');
    }
    
    #[test]
    #[available_gas(80000000)]
    fn test_complete_player_flow() {
        // Create test environment
        let world = create_test_world();
        let game_system = create_game_system(world);
        
        // Set the caller address for the test
        cheat_caller_address(PLAYER());
        
        // Create a player
        let player_id: felt252 = 0x123;
        game_system.create_player(player_id);
        
        // Perform various actions
        game_system.update_attributes(player_id, 50, 40, 60, 70, 55);  // Update attributes
        game_system.add_currency(player_id, 10000);   // Add currency
        game_system.spend_currency(player_id, 3000);  // Spend some currency
        game_system.record_login(player_id);          // Record login
        
        // Verify final state
        let player: Player = world.read_model(player_id);
        
        assert(player.fame == 50, 'Should have 50 fame');
        assert(player.charisma == 40, 'Should have 40 charisma');
        assert(player.stamina == 60, 'Should have 60 stamina');
        assert(player.intelligence == 70, 'Should have 70 intelligence');
        assert(player.leadership == 55, 'Should have 55 leadership');
        assert(player.universe_currency == 7000, 'Should have 7000 currency');
    }
   
   
}