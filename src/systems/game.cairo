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
    fn claim_player(ref self: T, player_id: felt252) -> bool;
    
    // --------- Setup methods for initial data loading ---------
    fn create_club(ref self: T, club_id: felt252, name: ByteArray);
    fn create_season(ref self: T, season_id: felt252, name: ByteArray, start_date: u64, end_date: u64, prize_pool: u128);
    fn create_season_club(ref self: T, season_club_id: felt252, season_id: felt252, club_id: felt252);
    fn create_universe_player(
        ref self: T,
        player_id: felt252,
        created_at: u64,
        fame: u16,
        charisma: u16,
        stamina: u16,
        strength: u16,
        agility: u16,
        intelligence: u16,
        universe_currency: u128,
        body_type: u8,
        skin_color: u8,
        beard_type: u8,
        hair_type: u8,
        hair_color: u8
    );
    fn create_overgoal_player(
        ref self: T,
        overgoal_player_id: felt252,
        universe_player_id: felt252,
        energy: u16,
        speed: u16,
        leadership: u16,
        pass: u16,
        shoot: u16,
        freekick: u16,
        visor_type: u8,
        visor_color: u8,
        player_category: ByteArray,
        player_name: ByteArray,
        player_description: ByteArray
    );
    fn create_season_player(
        ref self: T,
        season_player_id: felt252,
        season_id: felt252,
        season_club_id: felt252,
        overgoal_player_id: felt252
    );
}

#[dojo::contract]
pub mod game {
    // Local import
    use super::{IUniverse};
    use starknet::ContractAddress;



    // Store import
    use universe::store::{StoreTrait};



    // Models import
    use universe::models::universe_player::{UniversePlayerAssert, UniversePlayerTrait};
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
                // User exists - update timestamps
                store.update_user_timestamps(user_address);
                
                let user = store.read_user_from_address(user_address);
                return user.username;
            }
            
            // User doesn't exist, create with provided username
            store.create_user_with_address(user_address, username);
            
            return username;
        }

        // Method to claim a player for the calling user
        fn claim_player(ref self: ContractState, player_id: felt252) -> bool {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            let caller = starknet::get_caller_address();
            
            // Get the player
            let mut player = store.read_player_from_id(player_id);
            
            // Validate player exists
            player.assert_exists();
            
            // Check if player is already claimed
            if player.user_id != 0 {
                // Player is claimed - check if it's by this user
                if player.user_id == caller.into() {
                    // Already claimed by this user - return success
                    return true;
                } else {
                    // Claimed by another user - panic with error
                    assert(false, 'Player already minted!');
                    return false;
                }
            }
            
            // Player is unclaimed - assign to caller
            player.user_id = caller.into();
            
            // Update timestamps
            let current_timestamp = starknet::get_block_timestamp();
            player.update_login_time(current_timestamp);
            
            // Write updated player
            store.write_player(@player);
            
            // Update season 1 prize pool (+1000)
            store.increase_season_prize_pool(0x1, 1000);
            
            return true;
        }

        // Method to create a club (for initial setup)
        fn create_club(ref self: ContractState, club_id: felt252, name: ByteArray) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_club(club_id, name);
        }

        // Method to create a season (for initial setup)
        fn create_season(ref self: ContractState, season_id: felt252, name: ByteArray, start_date: u64, end_date: u64, prize_pool: u128) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_season(season_id, name, start_date, end_date, prize_pool);
        }

        // Method to create a season_club (for initial setup)
        fn create_season_club(ref self: ContractState, season_club_id: felt252, season_id: felt252, club_id: felt252) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_season_club(season_club_id, season_id, club_id);
        }

        // Method to create a universe_player (for initial setup)
        fn create_universe_player(
            ref self: ContractState,
            player_id: felt252,
            created_at: u64,
            fame: u16,
            charisma: u16,
            stamina: u16,
            strength: u16,
            agility: u16,
            intelligence: u16,
            universe_currency: u128,
            body_type: u8,
            skin_color: u8,
            beard_type: u8,
            hair_type: u8,
            hair_color: u8
        ) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_universe_player(
                player_id,
                created_at,
                fame,
                charisma,
                stamina,
                strength,
                agility,
                intelligence,
                universe_currency,
                body_type,
                skin_color,
                beard_type,
                hair_type,
                hair_color
            );
        }

        // Method to create an overgoal_player (for initial setup)
        fn create_overgoal_player(
            ref self: ContractState,
            overgoal_player_id: felt252,
            universe_player_id: felt252,
            energy: u16,
            speed: u16,
            leadership: u16,
            pass: u16,
            shoot: u16,
            freekick: u16,
            visor_type: u8,
            visor_color: u8,
            player_category: ByteArray,
            player_name: ByteArray,
            player_description: ByteArray
        ) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_overgoal_player(
                overgoal_player_id,
                universe_player_id,
                energy,
                speed,
                leadership,
                pass,
                shoot,
                freekick,
                visor_type,
                visor_color,
                player_category,
                player_name,
                player_description
            );
        }

        // Method to create a season_player (for initial setup)
        fn create_season_player(
            ref self: ContractState,
            season_player_id: felt252,
            season_id: felt252,
            season_club_id: felt252,
            overgoal_player_id: felt252
        ) {
            let mut world = self.world(@"universe");
            let store = StoreTrait::new(world);
            
            store.create_season_player(
                season_player_id,
                season_id,
                season_club_id,
                overgoal_player_id
            );
        }

    }
}