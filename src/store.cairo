// Starknet imports
use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

// Dojo imports
use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

// Models imports
use universe::models::universe_player::{UniversePlayer, UniversePlayerTrait, UniversePlayerAssert, ZeroableUniversePlayerTrait};
use universe::models::user::{User, UserTrait, UserAssert, ZeroableUserTrait};
use universe::models::season::{Season, SeasonTrait, SeasonAssert};
use universe::models::club::{Club, ClubTrait, AssertClubTrait};
use universe::models::season_club::{SeasonClub, SeasonClubTrait, SeasonClubAssert};
use universe::models::overgoal_player::{OvergoalPlayer, OvergoalPlayerTrait, OvergoalPlayerAssert};
use universe::models::season_player::{SeasonPlayer, SeasonPlayerTrait, SeasonPlayerAssert};

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

    // --------- Timestamp Management ---------
    fn update_user_timestamps(mut self: Store, user_address: ContractAddress) {
        let mut user = self.read_user_from_address(user_address);
        user.assert_exists();
        
        // Note: User model doesn't have last_updated_at/last_login_at
        // If we need to track this, we should look at their players
        // For now, this is a placeholder that can be extended
    }

    // --------- Season Management ---------
    fn read_season(self: Store, season_id: felt252) -> Season {
        self.world.read_model(season_id)
    }

    fn increase_season_prize_pool(mut self: Store, season_id: felt252, amount: u128) {
        let mut season = self.read_season(season_id);
        season.assert_exists();
        
        season.increase_prize_pool(amount);
        
        self.world.write_model(@season);
    }

    fn create_season(mut self: Store, season_id: felt252, name: ByteArray, start_date: u64, end_date: u64, prize_pool: u128) {
        // Create new season
        let new_season = SeasonTrait::new(season_id, name, start_date, end_date, prize_pool);
        
        self.world.write_model(@new_season);
    }

    // --------- Club Management ---------
    fn read_club(self: Store, club_id: felt252) -> Club {
        self.world.read_model(club_id)
    }

    fn create_club(mut self: Store, club_id: felt252, name: ByteArray) {
        // Create new club
        let new_club = ClubTrait::new(club_id, name);
        
        self.world.write_model(@new_club);
    }

    // --------- SeasonClub Management ---------
    fn create_season_club(mut self: Store, season_club_id: felt252, season_id: felt252, club_id: felt252) {
        // Create new season_club with default values for manager_id, coach_id, and stats
        let new_season_club = SeasonClubTrait::new(
            season_club_id,
            season_id,
            club_id,
            0, // manager_id - will be set later
            0, // coach_id - will be set later
            0, // season_points
            0, // offense
            0, // defense
            0  // intensity
        );
        
        self.world.write_model(@new_season_club);
    }

    // --------- UniversePlayer Management (for setup) ---------
    fn create_universe_player(
        mut self: Store,
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
        // Create new universe player with user_id = 0 (unclaimed)
        let new_player = UniversePlayerTrait::new(
            player_id,
            0, // user_id = 0 for unclaimed players
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
        
        self.world.write_model(@new_player);
    }

    // --------- OvergoalPlayer Management (for setup) ---------
    fn create_overgoal_player(
        mut self: Store,
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
        // Create new overgoal player (goal_currency is not in constructor, will be set to default)
        let new_overgoal_player = OvergoalPlayerTrait::new(
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
        
        self.world.write_model(@new_overgoal_player);
    }

    // --------- SeasonPlayer Management (for setup) ---------
    fn create_season_player(
        mut self: Store,
        season_player_id: felt252,
        season_id: felt252,
        season_club_id: felt252,
        overgoal_player_id: felt252
    ) {
        // Create new season player with default values for relationships
        // (season_points, matches_won, matches_lost will be set to defaults)
        let new_season_player = SeasonPlayerTrait::new(
            season_player_id,
            season_id,
            season_club_id,
            overgoal_player_id,
            0, // team_relationship - starts at 0
            0  // fans_relationship - starts at 0
        );
        
        self.world.write_model(@new_season_player);
    }
    
}