// Interface definition
use starknet::ContractAddress;

#[starknet::interface]
pub trait IUniverse<T> {
    // --------- Core gameplay methods ---------
    fn create_player(
        ref self: T, 
        player_id: felt252,
        user_id: felt252,
        body_type: u8,
        skin_color: u8,
        beard_type: u8,
        hair_type: u8,
        hair_color: u8
    );
    fn update_attributes(ref self: T, player_id: felt252, fame: u16, charisma: u16, stamina: u16, strength: u16, agility: u16, intelligence: u16);
    fn add_currency(ref self: T, player_id: felt252, amount: u128);
    fn spend_currency(ref self: T, player_id: felt252, amount: u128);
    fn record_login(ref self: T, player_id: felt252);
    fn assign_user(ref self: T, player_id: felt252, user_id: felt252);
    fn create_or_get_user(ref self: T, user_address: ContractAddress, username: felt252) -> felt252;
}

#[dojo::contract]
pub mod game {
    // Local import
    use super::{IUniverse};
    use starknet::ContractAddress;



    // Store import
    use universe::store::{StoreTrait};



    // Models import
    use universe::models::universe_player::{UniversePlayerAssert};
    use universe::models::user::{UserAssert};



    // Dojo Imports
    #[allow(unused_imports)]
    use dojo::model::{ModelStorage};
    #[allow(unused_imports)]
    use dojo::world::{WorldStorage, WorldStorageTrait};
    #[allow(unused_imports)]
    use dojo::event::EventStorage;



    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    // Constructor
    fn dojo_init(ref self: ContractState) {}

    // Implementation of the interface methods
    #[abi(embed_v0)]
    impl GameImpl of IUniverse<ContractState> {
        
        // Method to create a new player
        fn create_player(
            ref self: ContractState, 
            player_id: felt252,
            user_id: felt252,
            body_type: u8,
            skin_color: u8,
            beard_type: u8,
            hair_type: u8,
            hair_color: u8
        ) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);

            // Create new player
            store.create_player(player_id, user_id, body_type, skin_color, beard_type, hair_type, hair_color);
        }

        // Method to update player attributes
        fn update_attributes(ref self: ContractState, player_id: felt252, fame: u16, charisma: u16, stamina: u16, strength: u16, agility: u16, intelligence: u16) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);

            // Update player attributes
            store.update_player_attributes(player_id, fame, charisma, stamina, strength, agility, intelligence);
        }

        // Method to add currency to player
        fn add_currency(ref self: ContractState, player_id: felt252, amount: u128) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
           
            // Add currency
            store.add_player_currency(player_id, amount);
        }

        // Method to spend player currency
        fn spend_currency(ref self: ContractState, player_id: felt252, amount: u128) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);

            // Spend currency
            store.spend_player_currency(player_id, amount);
        }

        // Method to record player login
        fn record_login(ref self: ContractState, player_id: felt252) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);

            // Record login
            store.record_player_login(player_id);
        }

        // Method to assign a user to a player
        fn assign_user(ref self: ContractState, player_id: felt252, user_id: felt252) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);

            // Get the player
            let mut player = store.read_player_from_id(player_id);
            
            // Validate player exists
            player.assert_exists();
            
            // Update user_id
            player.user_id = user_id;
            
            // Write back to storage
            store.write_player(@player);
        }

        // Method to create or get a user
        fn create_or_get_user(ref self: ContractState, user_address: ContractAddress, username: felt252) -> felt252 {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            // Check if user already exists
            if store.user_exists(user_address) {
                let user = store.read_user_from_address(user_address);
                return user.username;
            }
            
            // User doesn't exist, create with provided username
            store.create_user_with_address(user_address, username);
            
            return username;
        }

    }
}