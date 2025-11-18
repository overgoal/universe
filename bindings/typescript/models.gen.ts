import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

// Type definition for `universe::models::club::Club` struct
export interface Club {
	id: BigNumberish;
	name: string;
}

// Type definition for `universe::models::overgoal_player::OvergoalPlayer` struct
export interface OvergoalPlayer {
	id: BigNumberish;
	universe_player_id: BigNumberish;
	goal_currency: BigNumberish;
	energy: BigNumberish;
	speed: BigNumberish;
	leadership: BigNumberish;
	pass: BigNumberish;
	shoot: BigNumberish;
	freekick: BigNumberish;
	is_injured: boolean;
	visor_type: BigNumberish;
	visor_color: BigNumberish;
	player_category: string;
	player_name: string;
	player_description: string;
}

// Type definition for `universe::models::season::Season` struct
export interface Season {
	id: BigNumberish;
	name: string;
	start_date: BigNumberish;
	end_date: BigNumberish;
	prize_pool: BigNumberish;
}

// Type definition for `universe::models::season_club::SeasonClub` struct
export interface SeasonClub {
	id: BigNumberish;
	season_id: BigNumberish;
	club_id: BigNumberish;
	manager_id: BigNumberish;
	coach_id: BigNumberish;
	season_points: BigNumberish;
	offense: BigNumberish;
	defense: BigNumberish;
	intensity: BigNumberish;
	chemistry: BigNumberish;
	matches_won: BigNumberish;
	matches_lost: BigNumberish;
	matches_drawn: BigNumberish;
}

// Type definition for `universe::models::season_player::SeasonPlayer` struct
export interface SeasonPlayer {
	id: BigNumberish;
	season_id: BigNumberish;
	season_club_id: BigNumberish;
	overgoal_player_id: BigNumberish;
	team_relationship: BigNumberish;
	fans_relationship: BigNumberish;
	season_points: BigNumberish;
	matches_won: BigNumberish;
	matches_lost: BigNumberish;
	trophies_won: BigNumberish;
}

// Type definition for `universe::models::universe_player::UniversePlayer` struct
export interface UniversePlayer {
	id: BigNumberish;
	user_id: BigNumberish;
	created_at: BigNumberish;
	last_updated_at: BigNumberish;
	last_login_at: BigNumberish;
	fame: BigNumberish;
	charisma: BigNumberish;
	stamina: BigNumberish;
	strength: BigNumberish;
	agility: BigNumberish;
	intelligence: BigNumberish;
	universe_currency: BigNumberish;
	body_type: BigNumberish;
	skin_color: BigNumberish;
	beard_type: BigNumberish;
	hair_type: BigNumberish;
	hair_color: BigNumberish;
}

// Type definition for `universe::models::user::User` struct
export interface User {
	owner: string;
	username: BigNumberish;
	created_at: BigNumberish;
}

export interface SchemaType extends ISchemaType {
	universe: {
		Club: Club,
		OvergoalPlayer: OvergoalPlayer,
		Season: Season,
		SeasonClub: SeasonClub,
		SeasonPlayer: SeasonPlayer,
		UniversePlayer: UniversePlayer,
		User: User,
	},
}
export const schema: SchemaType = {
	universe: {
		Club: {
			id: 0,
		name: "",
		},
		OvergoalPlayer: {
			id: 0,
			universe_player_id: 0,
			goal_currency: 0,
			energy: 0,
			speed: 0,
			leadership: 0,
			pass: 0,
			shoot: 0,
			freekick: 0,
			is_injured: false,
			visor_type: 0,
			visor_color: 0,
		player_category: "",
		player_name: "",
		player_description: "",
		},
		Season: {
			id: 0,
		name: "",
			start_date: 0,
			end_date: 0,
			prize_pool: 0,
		},
		SeasonClub: {
			id: 0,
			season_id: 0,
			club_id: 0,
			manager_id: 0,
			coach_id: 0,
			season_points: 0,
			offense: 0,
			defense: 0,
			intensity: 0,
			chemistry: 0,
			matches_won: 0,
			matches_lost: 0,
			matches_drawn: 0,
		},
		SeasonPlayer: {
			id: 0,
			season_id: 0,
			season_club_id: 0,
			overgoal_player_id: 0,
			team_relationship: 0,
			fans_relationship: 0,
			season_points: 0,
			matches_won: 0,
			matches_lost: 0,
			trophies_won: 0,
		},
		UniversePlayer: {
			id: 0,
			user_id: 0,
			created_at: 0,
			last_updated_at: 0,
			last_login_at: 0,
			fame: 0,
			charisma: 0,
			stamina: 0,
			strength: 0,
			agility: 0,
			intelligence: 0,
			universe_currency: 0,
			body_type: 0,
			skin_color: 0,
			beard_type: 0,
			hair_type: 0,
			hair_color: 0,
		},
		User: {
			owner: "",
			username: 0,
			created_at: 0,
		},
	},
};
export enum ModelsMapping {
	Club = 'universe-Club',
	OvergoalPlayer = 'universe-OvergoalPlayer',
	Season = 'universe-Season',
	SeasonClub = 'universe-SeasonClub',
	SeasonPlayer = 'universe-SeasonPlayer',
	UniversePlayer = 'universe-UniversePlayer',
	User = 'universe-User',
}