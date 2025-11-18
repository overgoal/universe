import { DojoProvider, DojoCall } from "@dojoengine/core";
import { Account, AccountInterface, BigNumberish, CairoOption, CairoCustomEnum } from "starknet";
import * as models from "./models.gen";

export function setupWorld(provider: DojoProvider) {

	const build_game_addCurrency_calldata = (playerId: BigNumberish, amount: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "add_currency",
			calldata: [playerId, amount],
		};
	};

	const game_addCurrency = async (snAccount: Account | AccountInterface, playerId: BigNumberish, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_addCurrency_calldata(playerId, amount),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_assignUser_calldata = (playerId: BigNumberish, userId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "assign_user",
			calldata: [playerId, userId],
		};
	};

	const game_assignUser = async (snAccount: Account | AccountInterface, playerId: BigNumberish, userId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_assignUser_calldata(playerId, userId),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_claimPlayer_calldata = (playerId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "claim_player",
			calldata: [playerId],
		};
	};

	const game_claimPlayer = async (snAccount: Account | AccountInterface, playerId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_claimPlayer_calldata(playerId),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createClub_calldata = (clubId: BigNumberish, name: string): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_club",
			calldata: [clubId, name],
		};
	};

	const game_createClub = async (snAccount: Account | AccountInterface, clubId: BigNumberish, name: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createClub_calldata(clubId, name),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createOrGetUser_calldata = (userAddress: string, username: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_or_get_user",
			calldata: [userAddress, username],
		};
	};

	const game_createOrGetUser = async (snAccount: Account | AccountInterface, userAddress: string, username: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createOrGetUser_calldata(userAddress, username),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createOvergoalPlayer_calldata = (overgoalPlayerId: BigNumberish, universePlayerId: BigNumberish, energy: BigNumberish, speed: BigNumberish, leadership: BigNumberish, pass: BigNumberish, shoot: BigNumberish, freekick: BigNumberish, visorType: BigNumberish, visorColor: BigNumberish, playerCategory: string, playerName: string, playerDescription: string): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_overgoal_player",
			calldata: [overgoalPlayerId, universePlayerId, energy, speed, leadership, pass, shoot, freekick, visorType, visorColor, playerCategory, playerName, playerDescription],
		};
	};

	const game_createOvergoalPlayer = async (snAccount: Account | AccountInterface, overgoalPlayerId: BigNumberish, universePlayerId: BigNumberish, energy: BigNumberish, speed: BigNumberish, leadership: BigNumberish, pass: BigNumberish, shoot: BigNumberish, freekick: BigNumberish, visorType: BigNumberish, visorColor: BigNumberish, playerCategory: string, playerName: string, playerDescription: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createOvergoalPlayer_calldata(overgoalPlayerId, universePlayerId, energy, speed, leadership, pass, shoot, freekick, visorType, visorColor, playerCategory, playerName, playerDescription),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createPlayer_calldata = (playerId: BigNumberish, userId: BigNumberish, bodyType: BigNumberish, skinColor: BigNumberish, beardType: BigNumberish, hairType: BigNumberish, hairColor: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_player",
			calldata: [playerId, userId, bodyType, skinColor, beardType, hairType, hairColor],
		};
	};

	const game_createPlayer = async (snAccount: Account | AccountInterface, playerId: BigNumberish, userId: BigNumberish, bodyType: BigNumberish, skinColor: BigNumberish, beardType: BigNumberish, hairType: BigNumberish, hairColor: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createPlayer_calldata(playerId, userId, bodyType, skinColor, beardType, hairType, hairColor),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createSeason_calldata = (seasonId: BigNumberish, name: string, startDate: BigNumberish, endDate: BigNumberish, prizePool: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_season",
			calldata: [seasonId, name, startDate, endDate, prizePool],
		};
	};

	const game_createSeason = async (snAccount: Account | AccountInterface, seasonId: BigNumberish, name: string, startDate: BigNumberish, endDate: BigNumberish, prizePool: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createSeason_calldata(seasonId, name, startDate, endDate, prizePool),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createSeasonClub_calldata = (seasonClubId: BigNumberish, seasonId: BigNumberish, clubId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_season_club",
			calldata: [seasonClubId, seasonId, clubId],
		};
	};

	const game_createSeasonClub = async (snAccount: Account | AccountInterface, seasonClubId: BigNumberish, seasonId: BigNumberish, clubId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createSeasonClub_calldata(seasonClubId, seasonId, clubId),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createSeasonPlayer_calldata = (seasonPlayerId: BigNumberish, seasonId: BigNumberish, seasonClubId: BigNumberish, overgoalPlayerId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_season_player",
			calldata: [seasonPlayerId, seasonId, seasonClubId, overgoalPlayerId],
		};
	};

	const game_createSeasonPlayer = async (snAccount: Account | AccountInterface, seasonPlayerId: BigNumberish, seasonId: BigNumberish, seasonClubId: BigNumberish, overgoalPlayerId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createSeasonPlayer_calldata(seasonPlayerId, seasonId, seasonClubId, overgoalPlayerId),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createUniversePlayer_calldata = (playerId: BigNumberish, createdAt: BigNumberish, fame: BigNumberish, charisma: BigNumberish, stamina: BigNumberish, strength: BigNumberish, agility: BigNumberish, intelligence: BigNumberish, universeCurrency: BigNumberish, bodyType: BigNumberish, skinColor: BigNumberish, beardType: BigNumberish, hairType: BigNumberish, hairColor: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_universe_player",
			calldata: [playerId, createdAt, fame, charisma, stamina, strength, agility, intelligence, universeCurrency, bodyType, skinColor, beardType, hairType, hairColor],
		};
	};

	const game_createUniversePlayer = async (snAccount: Account | AccountInterface, playerId: BigNumberish, createdAt: BigNumberish, fame: BigNumberish, charisma: BigNumberish, stamina: BigNumberish, strength: BigNumberish, agility: BigNumberish, intelligence: BigNumberish, universeCurrency: BigNumberish, bodyType: BigNumberish, skinColor: BigNumberish, beardType: BigNumberish, hairType: BigNumberish, hairColor: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createUniversePlayer_calldata(playerId, createdAt, fame, charisma, stamina, strength, agility, intelligence, universeCurrency, bodyType, skinColor, beardType, hairType, hairColor),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_recordLogin_calldata = (playerId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "record_login",
			calldata: [playerId],
		};
	};

	const game_recordLogin = async (snAccount: Account | AccountInterface, playerId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_recordLogin_calldata(playerId),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_spendCurrency_calldata = (playerId: BigNumberish, amount: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "spend_currency",
			calldata: [playerId, amount],
		};
	};

	const game_spendCurrency = async (snAccount: Account | AccountInterface, playerId: BigNumberish, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_spendCurrency_calldata(playerId, amount),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_updateAttributes_calldata = (playerId: BigNumberish, fame: BigNumberish, charisma: BigNumberish, stamina: BigNumberish, strength: BigNumberish, agility: BigNumberish, intelligence: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "update_attributes",
			calldata: [playerId, fame, charisma, stamina, strength, agility, intelligence],
		};
	};

	const game_updateAttributes = async (snAccount: Account | AccountInterface, playerId: BigNumberish, fame: BigNumberish, charisma: BigNumberish, stamina: BigNumberish, strength: BigNumberish, agility: BigNumberish, intelligence: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_updateAttributes_calldata(playerId, fame, charisma, stamina, strength, agility, intelligence),
				"universe",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};



	return {
		game: {
			addCurrency: game_addCurrency,
			buildAddCurrencyCalldata: build_game_addCurrency_calldata,
			assignUser: game_assignUser,
			buildAssignUserCalldata: build_game_assignUser_calldata,
			claimPlayer: game_claimPlayer,
			buildClaimPlayerCalldata: build_game_claimPlayer_calldata,
			createClub: game_createClub,
			buildCreateClubCalldata: build_game_createClub_calldata,
			createOrGetUser: game_createOrGetUser,
			buildCreateOrGetUserCalldata: build_game_createOrGetUser_calldata,
			createOvergoalPlayer: game_createOvergoalPlayer,
			buildCreateOvergoalPlayerCalldata: build_game_createOvergoalPlayer_calldata,
			createPlayer: game_createPlayer,
			buildCreatePlayerCalldata: build_game_createPlayer_calldata,
			createSeason: game_createSeason,
			buildCreateSeasonCalldata: build_game_createSeason_calldata,
			createSeasonClub: game_createSeasonClub,
			buildCreateSeasonClubCalldata: build_game_createSeasonClub_calldata,
			createSeasonPlayer: game_createSeasonPlayer,
			buildCreateSeasonPlayerCalldata: build_game_createSeasonPlayer_calldata,
			createUniversePlayer: game_createUniversePlayer,
			buildCreateUniversePlayerCalldata: build_game_createUniversePlayer_calldata,
			recordLogin: game_recordLogin,
			buildRecordLoginCalldata: build_game_recordLogin_calldata,
			spendCurrency: game_spendCurrency,
			buildSpendCurrencyCalldata: build_game_spendCurrency_calldata,
			updateAttributes: game_updateAttributes,
			buildUpdateAttributesCalldata: build_game_updateAttributes_calldata,
		},
	};
}