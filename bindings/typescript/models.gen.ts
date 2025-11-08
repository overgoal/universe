import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

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
		UniversePlayer: UniversePlayer,
		User: User,
	},
}
export const schema: SchemaType = {
	universe: {
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
	UniversePlayer = 'universe-UniversePlayer',
	User = 'universe-User',
}