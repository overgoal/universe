// Starknet imports
use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

// Dojo imports
use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

// Models imports
use universe::models::universe_player::{UniversePlayer, UniversePlayerTrait, UniversePlayerAssert, ZeroableUniversePlayerTrait};
use universe::models::user::{User, UserTrait, UserAssert, ZeroableUserTrait};

// Helpers import
use universe::helpers::timestamp::Timestamp;

// Store struct
#[derive(Copy, Drop)]
pub struct Store {
    world: WorldStorage,
}

//Implementation of the `StoreTrait` trait for the `Store` struct
#[generate_trait]
pub impl StoreImpl of StoreTrait {
    fn new(world: WorldStorage) -> Store {
        Store { world: world }
    }

    // --------- UniversePlayer Getters ---------
    fn read_player_from_id(self: Store, player_id: felt252) -> UniversePlayer {
        self.world.read_model(player_id)
    }

    fn player_exists(self: Store, player_id: felt252) -> bool {
        let player: UniversePlayer = self.world.read_model(player_id);
        player.is_non_zero()
    }

    // --------- User Getters ---------
    fn read_user_from_address(self: Store, user_address: ContractAddress) -> User {
        self.world.read_model(user_address)
    }

    fn read_user(self: Store) -> User {
        let user_address = get_caller_address();
        self.world.read_model(user_address)
    }

    fn user_exists(self: Store, user_address: ContractAddress) -> bool {
        let user: User = self.world.read_model(user_address);
        // Check created_at instead of is_non_zero() because Dojo sets the key field (owner)
        // even for non-existent models, making is_non_zero() unreliable
        user.created_at > 0
    }

    // --------- Setters ---------
    fn write_player(mut self: Store, player: @UniversePlayer) {
        self.world.write_model(player)
    }
    
    fn write_user(mut self: Store, user: @User) {
        self.world.write_model(user)
    }
    
    // --------- New entities ---------
    fn create_player(
        mut self: Store, 
        player_id: felt252, 
        user_id: felt252,
        body_type: u8,
        skin_color: u8,
        beard_type: u8,
        hair_type: u8,
        hair_color: u8
    ) {
        let current_timestamp = get_block_timestamp();
        
        // Assert player doesn't already exist
        assert(!self.player_exists(player_id), 'Player already exists');

        // Create new player with starting attributes
        let new_player = UniversePlayerTrait::new(
            player_id,
            user_id,
            current_timestamp,
            0,     // fame
            0,     // charisma  
            0,     // stamina
            0,     // strength
            0,     // agility
            0,     // intelligence
            0,     // universe_currency
            body_type,
            skin_color,
            beard_type,
            hair_type,
            hair_color,
        );

        self.world.write_model(@new_player);
    }

    fn create_user(mut self: Store, username: felt252) {
        let caller = get_caller_address();
        let current_timestamp = get_block_timestamp();
        
        // Assert user doesn't already exist
        assert(!self.user_exists(caller), 'User already exists');
        
        // Create new user
        let new_user = UserTrait::new(caller, username, current_timestamp);
        
        self.world.write_model(@new_user);
    }

    fn create_user_with_address(mut self: Store, user_address: ContractAddress, username: felt252) {
        let current_timestamp = get_block_timestamp();
        
        // Assert user doesn't already exist
        assert(!self.user_exists(user_address), 'User already exists');
        
        // Create new user
        let new_user = UserTrait::new(user_address, username, current_timestamp);
        
        self.world.write_model(@new_user);
    }

    // --------- User Management ---------
    fn rename_user(mut self: Store, new_username: felt252) {
        // Read existing user for caller
        let mut user = self.read_user();
        user.assert_exists();
        assert(new_username != 0, 'Invalid username');
        
        // Update username
        user.username = new_username;
        
        self.world.write_model(@user);
    }

    fn rename_user_with_address(mut self: Store, user_address: ContractAddress, new_username: felt252) {
        // Read existing user
        let mut user = self.read_user_from_address(user_address);
        user.assert_exists();
        assert(new_username != 0, 'Invalid username');
        
        // Update username
        user.username = new_username;
        
        self.world.write_model(@user);
    }

    // --------- Player Management ---------
    fn update_player_attributes(mut self: Store, player_id: felt252, fame: u16, charisma: u16, stamina: u16, strength: u16, agility: u16, intelligence: u16) {
        let mut player = self.read_player_from_id(player_id);
        player.assert_exists();
        
        // Update attributes
        player.add_fame(fame);
        player.add_charisma(charisma);
        player.add_stamina(stamina);
        player.add_strength(strength);
        player.add_agility(agility);
        player.add_intelligence(intelligence);
        
        self.world.write_model(@player);
    }

    fn add_player_currency(mut self: Store, player_id: felt252, amount: u128) {
        let mut player = self.read_player_from_id(player_id);
        player.assert_exists();
        
        player.add_currency(amount);
        
        self.world.write_model(@player);
    }

    fn spend_player_currency(mut self: Store, player_id: felt252, amount: u128) {
        let mut player = self.read_player_from_id(player_id);
        player.assert_exists();
        
        player.spend_currency(amount);
        
        self.world.write_model(@player);
    }

    fn record_player_login(mut self: Store, player_id: felt252) {
        let mut player = self.read_player_from_id(player_id);
        player.assert_exists();
        
        let current_timestamp = get_block_timestamp();
        player.update_login_time(current_timestamp);
        
        self.world.write_model(@player);
    }
    
}