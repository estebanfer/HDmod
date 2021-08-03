meta.name = "Spelunky 2: HDmod"
meta.version = "0.0" -- Alpha, if anything.
meta.description = "Spelunky HD's campaign in Spelunky 2"
meta.author = "Super Ninja Fat"

-- uncomment to allow loading unlocks.txt
-- meta.unsafe = true

-- register_option_float("hd_ui_botd_a_w", "UI: botd width", 0.08, 0.0, 99.0)
-- register_option_float("hd_ui_botd_b_h", "UI: botd height", 0.12, 0.0, 99.0)
-- register_option_float("hd_ui_botd_c_x", "UI: botd x", 0.2, -999.0, 999.0)
-- register_option_float("hd_ui_botd_d_y", "UI: botd y", 0.93, -999.0, 999.0)
-- register_option_float("hd_ui_botd_e_squash", "UI: botd uvx shifting rate", 0.25, -5.0, 5.0)

register_option_bool("hd_debug_boss_exits_unlock", "Debug: Unlock boss exits",														false)
register_option_bool("hd_debug_feelingtoast_disable", "Debug: Disable script-enduced feeling toasts",								false)
register_option_bool("hd_debug_info_boss", "Debug: Info - Bossfight",																false)
register_option_bool("hd_debug_info_boulder", "Debug: Info - Boulder",																false)
register_option_bool("hd_debug_info_feelings", "Debug: Info - Level Feelings",														false)
register_option_bool("hd_debug_info_path", "Debug: Info - Path",																	true)
register_option_bool("hd_debug_info_tongue", "Debug: Info - Wormtongue",															false)
register_option_bool("hd_debug_info_worldstate", "Debug: Info - Worldstate",														false)
register_option_bool("hd_debug_scripted_enemies_show", "Debug: Enable visibility of entities used in custom enemy behavior",		false)
register_option_bool("hd_debug_item_botd_give", "Debug: Start with the Book of the Dead",											true)
register_option_bool("hd_debug_scripted_levelgen_disable", "Debug: Disable scripted level generation",								false)
register_option_string("hd_debug_scripted_levelgen_tilecodes_blacklist",
	"Debug: Blacklist scripted level generation tilecodes",
	"w3"
)
register_option_bool("hd_debug_testing_door", "Debug: Enable testing door in camp",													true)	
register_option_bool("hd_og_ankhprice", "OG: Item - Set the Ankh price to a constant $50,000 like it was in HD",					false)	-- Defaults to S2
register_option_bool("hd_og_boulder_agro_disable", "OG: Traps - Revert enraging shopkeepers as they did in HD",						false)	-- Defaults to HD
register_option_bool("hd_og_ghost_nosplit_disable", "OG: Ghost - Revert preventing the ghost from splitting",						false)	-- Defaults to HD
register_option_bool("hd_og_ghost_slow_enable", "OG: Ghost - Set the ghost to its HD speed",										false)	-- Defaults to S2
register_option_bool("hd_og_ghost_time_disable", "OG: Ghost - Revert spawntime from 2:30->3:00 and 2:00->2:30 when cursed.",		false)	-- Defaults to HD
register_option_bool("hd_og_cursepot_enable", "OG: Enable curse pot spawning",														false)	-- Defaults to HD

-- # TODO: revise from the old system, removing old uses.
-- Then, rename it to `hd_og_use_s2_spawns`
-- Reimplement it into `is_valid_*_spawn` methods to change spawns.
register_option_bool("hd_og_procedural_spawns_disable", "OG: Revert preserving HD's procedural spawning conditions",				false)	-- Defaults to HD

-- # TODO: Influence the velocity of the boulder on every frame.
-- register_option_bool("hd_og_boulder_phys", "OG: Boulder - Adjust to have the same physics as HD",									false)

bool_to_number={ [true]=1, [false]=0 }

DANGER_GHOST_UIDS = {}
GHOST_TIME = 10800
GHOST_VELOCITY = 0.7
IDOLTRAP_TRIGGER = false
WHEEL_SPINNING = false
WHEEL_SPINTIME = 700 -- For reference, HD's was 10-11 seconds
ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds
TONGUE_ACCEPTTIME = 200
IDOLTRAP_JUNGLE_ACTIVATETIME = 15
wheel_items = {}
global_dangers = {}
global_feelings = nil
global_levelassembly = nil
danger_tracker = {}
LEVEL_START = {} --LEVEL_PATH = {}
POSTTILE_STARTBOOL = false
IDOL_X = nil
IDOL_Y = nil
IDOL_UID = nil
BOULDER_UID = nil
BOULDER_SX = nil
BOULDER_SY = nil
BOULDER_SX2 = nil
BOULDER_SY2 = nil
BOULDER_CRUSHPREVENTION_EDGE = 0.15
BOULDER_CRUSHPREVENTION_HEIGHT = 0.3
BOULDER_CRUSHPREVENTION_VELOCITY = 0.16
BOULDER_CRUSHPREVENTION_MULTIPLIER = 2.5
BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
wheel_speed = 0
wheel_tick = WHEEL_SPINTIME
acid_tick = ACID_POISONTIME
tongue_tick = TONGUE_ACCEPTTIME
idoltrap_timeout = 0
idoltrap_blocks = {}
OLMEC_ID = nil
TONGUE_SEQUENCE = { ["READY"] = 1, ["RUMBLE"] = 2, ["EMERGE"] = 3, ["SWALLOW"] = 4 , ["GONE"] = 5 }
TONGUE_STATE = nil
TONGUE_STATECOMPLETE = false
BOSS_SEQUENCE = { ["CUTSCENE"] = 1, ["FIGHT"] = 2, ["DEAD"] = 3 }
BOSS_STATE = nil
OLMEC_SEQUENCE = { ["STILL"] = 1, ["FALL"] = 2 }
OLMEC_STATE = 0
BOULDER_DEBUG_PLAYERTOUCH = false
HELL_X = 0
HELL_Y = 87
BOOKOFDEAD_TIC_LIMIT = 5
BOOKOFDEAD_RANGE = 14
bookofdead_tick = 0
-- bookofdead_tick_min = BOOKOFDEAD_TIC_LIMIT
bookofdead_frames = 4
bookofdead_frames_index = 1
bookofdead_squash = (1/bookofdead_frames) --options.hd_ui_botd_e_squash
PREFIRSTLEVEL_NUM = 40
TONGUE_UID = nil
TONGUE_BG_UID = nil
DOOR_EXIT_TO_HAUNTEDCASTLE_UID = nil
DOOR_EXIT_TO_BLACKMARKET_UID = nil
DOOR_ENDGAME_OLMEC_UID = nil
DOOR_TESTING_UID = nil
DOOR_TUTORIAL_UID = nil
HD_WORLDSTATE_STATUS = { ["NORMAL"] = 1, ["TUTORIAL"] = 2, ["TESTING"] = 3}
HD_WORLDSTATE_STATE = HD_WORLDSTATE_STATUS.NORMAL


OBTAINED_BOOKOFDEAD = false

UI_BOTD_IMG_ID, UI_BOTD_IMG_W, UI_BOTD_IMG_H = create_image('res/bookofdead.png')
UI_BOTD_PLACEMENT_W = 0.08
UI_BOTD_PLACEMENT_H = 0.12
UI_BOTD_PLACEMENT_X = 0.2
UI_BOTD_PLACEMENT_Y = 0.93

RUN_UNLOCK_AREA_CHANCE = 1
RUN_UNLOCK_AREA = {} -- used to be `RUN_UNLOCK_AREA[THEME.DWELLING] = false` but that doesn't save into json well...
RUN_UNLOCK_AREA[#RUN_UNLOCK_AREA+1] = { theme = THEME.DWELLING, unlocked = false }
RUN_UNLOCK_AREA[#RUN_UNLOCK_AREA+1] = { theme = THEME.JUNGLE, unlocked = false }
RUN_UNLOCK_AREA[#RUN_UNLOCK_AREA+1] = { theme = THEME.ICE_CAVES, unlocked = false }
RUN_UNLOCK_AREA[#RUN_UNLOCK_AREA+1] = { theme = THEME.TEMPLE, unlocked = false }

RUN_UNLOCK = nil

HD_UNLOCKS = {}
HD_UNLOCKS.STARTER1 = { unlock_id = 19, unlocked = false }			--ENT_TYPE.CHAR_GUY_SPELUNKY
HD_UNLOCKS.STARTER2 = { unlock_id = 03, unlocked = false }			--ENT_TYPE.CHAR_COLIN_NORTHWARD
HD_UNLOCKS.STARTER3 = { unlock_id = 05, unlocked = false }			--ENT_TYPE.CHAR_BANDA
HD_UNLOCKS.STARTER4 = { unlock_id = 06, unlocked = false }			--ENT_TYPE.CHAR_GREEN_GIRL
HD_UNLOCKS.AREA_RAND1 = { unlock_id = 12, unlocked = false }		--ENT_TYPE.CHAR_TINA_FLAN
HD_UNLOCKS.AREA_RAND2 = { unlock_id = 01, unlocked = false }		--ENT_TYPE.CHAR_ANA_SPELUNKY
HD_UNLOCKS.AREA_RAND3 = { unlock_id = 02, unlocked = false }		--ENT_TYPE.CHAR_MARGARET_TUNNEL
HD_UNLOCKS.AREA_RAND4 = { unlock_id = 09, unlocked = false }		--ENT_TYPE.CHAR_COCO_VON_DIAMONDS
HD_UNLOCKS.OLMEC_WIN = {
	win = 1,
	unlock_id = 07,													--ENT_TYPE.CHAR_AMAZON
	unlocked = false
}
HD_UNLOCKS.WORM = {
	unlock_theme = THEME.EGGPLANT_WORLD,
	unlock_id = 16,													--ENT_TYPE.CHAR_PILOT
	unlocked = false
}				
HD_UNLOCKS.SPIDERLAIR = {
	feeling = "SPIDERLAIR",
	unlock_id = 13, unlocked = false }								--ENT_TYPE.CHAR_VALERIE_CRUMP
HD_UNLOCKS.YETIKINGDOM = {
	feeling = "YETIKINGDOM",
	unlock_id = 15, unlocked = false }								--ENT_TYPE.CHAR_DEMI_VON_DIAMONDS
HD_UNLOCKS.HAUNTEDCASTLE = {
	feeling = "HAUNTEDCASTLE",
	unlock_id = 17, unlocked = false }								--ENT_TYPE.CHAR_PRINCESS_AIRYN
HD_UNLOCKS.YAMA = {
	win = 2,
	unlock_id = 20,													--ENT_TYPE.CHAR_CLASSIC_GUY
	unlocked = false
}
HD_UNLOCKS.OLMEC_CHAMBER = {
	unlock_theme = THEME.OLMEC,
	unlock_id = 18, unlocked = false }								--ENT_TYPE.CHAR_DIRK_YAMAOKA
HD_UNLOCKS.TIKIVILLAGE = { -- RESIDENT TIK-EVIL: VILLAGE
	feeling = "TIKIVILLAGE",
	unlock_id = 11, unlocked = false }								--ENT_TYPE.CHAR_OTAKU
HD_UNLOCKS.BLACKMARKET = {
	feeling = "BLACKMARKET",
	unlock_id = 04, unlocked = false }								--ENT_TYPE.CHAR_ROFFY_D_SLOTH
HD_UNLOCKS.FLOODED = {
	feeling = "FLOODED",
	unlock_id = 10, unlocked = false }								--ENT_TYPE.CHAR_MANFRED_TUNNEL
HD_UNLOCKS.MOTHERSHIP = {
	unlock_theme = THEME.NEO_BABYLON,
	unlock_id = 08, unlocked = false }								--ENT_TYPE.CHAR_LISE_SYSTEM
HD_UNLOCKS.COG = {
	unlock_theme = THEME.CITY_OF_GOLD,
	unlock_id = 14, unlocked = false }								--ENT_TYPE.CHAR_AU


MESSAGE_FEELING = nil

HD_FEELING = {
	["VAULT"] = {
		themes = {
			THEME.DWELLING,
			THEME.JUNGLE,
			THEME.ICE_CAVES,
			THEME.TEMPLE,
			THEME.VOLCANA
		}
	},
	["SPIDERLAIR"] = {
		chance = 0,
		themes = { THEME.DWELLING },
		message = "My skin is crawling..."
	},
	["SNAKEPIT"] = {
		chance = 1,
		themes = { THEME.DWELLING },
		message = "I hear snakes... I hate snakes!"
	},
	["RESTLESS"] = {
		chance = 0,
		themes = { THEME.JUNGLE },
		message = "The dead are restless!"
	},
	["TIKIVILLAGE"] = {
		chance = 1,
		themes = { THEME.JUNGLE }
	},
	["FLOODED"] = {
		chance = 0,
		themes = { THEME.JUNGLE },
		message = "I hear rushing water!"
	},
	["BLACKMARKET_ENTRANCE"] = {
		themes = { THEME.JUNGLE }
	},
	["BLACKMARKET"] = {
		themes = { THEME.JUNGLE },
		message = "Welcome to the Black Market!"
	},
	["HAUNTEDCASTLE"] = {
		themes = { THEME.JUNGLE },
		message = "A wolf howls in the distance..."
	},
	["YETIKINGDOM"] = {
		chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "It smells like wet fur in here."
	},
	["UFO"] = {
		chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "I sense a psychic presence here!"
	},
	["MOAI"] = {
		themes = { THEME.ICE_CAVES }
	},
	["MOTHERSHIPENTRANCE"] = {
		themes = { THEME.ICE_CAVES },
		message = "It feels like the fourth of July..."
	},
	["SACRIFICIALPIT"] = {
		chance = 0,
		themes = { THEME.TEMPLE },
		message = "You hear prayers to Kali!"
	},
	["VLAD"] = {
		themes = { THEME.VOLCANA },
		load = 1,
		message = "A horrible feeling of nausea comes over you!"
	},
}


-- # TODO: Player Coffins
-- Subchunkid terminology
	-- 00 -- side				-- Empty/unassigned
	-- 01 -- path				-- Standard room (horizontal exit)
	-- 02 -- path_drop			-- Path to exit (vertical exit)
	-- 03 -- path_notop			-- Path to exit (horizontal exit)
	-- 04 -- path_drop_notop	-- Path to exit (vertical exit)
	-- 05 -- entrance			-- Player start (horizontal exit)
	-- 06 -- entrance_drop		-- Player start (vertical exit)
	-- 07 -- exit				-- Exit door (horizontal entrance)
	-- 08 -- exit_notop			-- Exit door (vertical entrance)

HD_SUBCHUNKID = {}

HD_SUBCHUNKID.SIDE = 0
HD_SUBCHUNKID.PATH = 1
HD_SUBCHUNKID.PATH_DROP = 2
HD_SUBCHUNKID.PATH_NOTOP = 3
HD_SUBCHUNKID.PATH_DROP_NOTOP = 4
HD_SUBCHUNKID.ENTRANCE = 5
HD_SUBCHUNKID.ENTRANCE_DROP = 6
HD_SUBCHUNKID.EXIT = 7
HD_SUBCHUNKID.EXIT_NOTOP = 8

HD_SUBCHUNKID.IDOL = 9

HD_SUBCHUNKID.ALTAR = 10

HD_SUBCHUNKID.COFFIN_UNLOCKABLE = 74
HD_SUBCHUNKID.COFFIN_UNLOCKABLE_NOTOP = 75
HD_SUBCHUNKID.COFFIN_UNLOCKABLE_DROP = 76
HD_SUBCHUNKID.COFFIN_UNLOCKABLE_DROP_NOTOP = 77

HD_SUBCHUNKID.SHOP_REGULAR = 1000
HD_SUBCHUNKID.SHOP_REGULAR_LEFT = 1001
HD_SUBCHUNKID.SHOP_PRIZE = 1002
HD_SUBCHUNKID.SHOP_PRIZE_LEFT = 1003
HD_SUBCHUNKID.SHOP_BROTHEL = 1004
HD_SUBCHUNKID.SHOP_BROTHEL_LEFT = 1005
HD_SUBCHUNKID.SHOP_UNKNOWN1 = 1006
HD_SUBCHUNKID.SHOP_UNKNOWN1_LEFT = 1007
HD_SUBCHUNKID.SHOP_UNKNOWN2 = 1008
HD_SUBCHUNKID.SHOP_UNKNOWN2_LEFT = 1009

HD_SUBCHUNKID.VAULT = 1010

HD_SUBCHUNKID.SNAKEPIT_TOP = 106
HD_SUBCHUNKID.SNAKEPIT_MIDSECTION = 107
HD_SUBCHUNKID.SNAKEPIT_BOTTOM = 108


HD_SUBCHUNKID.TIKIVILLAGE_PATH = 1030
HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP = 1031
HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP = 1032
HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP = 1033

HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT = 1034
HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT = 1035

HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT = 1036
HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT = 1037

HD_SUBCHUNKID.WORM_CRYSKNIFE_LEFTSIDE = 1241
HD_SUBCHUNKID.WORM_CRYSKNIFE_RIGHTSIDE = 1242

HD_SUBCHUNKID.COG_BOTD_LEFTSIDE = 126
HD_SUBCHUNKID.COG_BOTD_RIGHTSIDE = 127

HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP = 128
HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM = 129

HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN = 2001


HD_SUBCHUNKID.RESTLESS_TOMB = 147
HD_SUBCHUNKID.RESTLESS_IDOL = 148

HD_SUBCHUNKID.SACRIFICIALPIT_TOP = 116
HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION = 117
HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM = 118

HD_SUBCHUNKID.VLAD_TOP = 119
HD_SUBCHUNKID.VLAD_MIDSECTION = 120
HD_SUBCHUNKID.VLAD_BOTTOM = 121


-- KNOWN HD IDs:
--HD_SUBCHUNKID. = 6					-- Upper part of snake pit
--HD_SUBCHUNKID. = 7					-- Middle part of snake pit
--HD_SUBCHUNKID. = 8					-- Bottom part of snake pit
--HD_SUBCHUNKID. = 9					-- Rushing Water islands/lake surface
--HD_SUBCHUNKID. = 10					-- Rushing Water lake
--HD_SUBCHUNKID. = 11					-- Rushing Water lake with Ol' Bitey
--HD_SUBCHUNKID. = 12					-- Left part of psychic presence
--HD_SUBCHUNKID. = 13					-- Middle part of psychic presence
--HD_SUBCHUNKID. = 14					-- Right part of psychic presence
--HD_SUBCHUNKID. = 15					-- Moai
--HD_SUBCHUNKID. = 16					-- Kalipit top
--HD_SUBCHUNKID. = 17					-- Kalipit middle
--HD_SUBCHUNKID. = 18					-- Kalipit bottom
--HD_SUBCHUNKID. = 19					-- Vlad's Tower top
--HD_SUBCHUNKID. = 20					-- Vlad's Tower middle
--HD_SUBCHUNKID. = 21					-- Vlad's Tower bottom
--HD_SUBCHUNKID. = 22					-- Beehive with left/right exits
--HD_SUBCHUNKID. = 24					-- Beehive with left/down exits
--HD_SUBCHUNKID. = 25					-- Beehive with left/up exits
--HD_SUBCHUNKID. = 26					-- Book of the Dead room left
--HD_SUBCHUNKID. = 27					-- Book of the Dead room right
--HD_SUBCHUNKID. = 28					-- Top part of mothership entrance
--HD_SUBCHUNKID. = 29					-- Bottom part of mothership entrance
--HD_SUBCHUNKID. = 30					-- Castle top layer middle-left
--HD_SUBCHUNKID. = 31					-- Castle top layer middle-right
--HD_SUBCHUNKID. = 32					-- Castle middle layers left with exits left/right and sometimes up
--HD_SUBCHUNKID. = 33					-- Castle middle layers left with exits left/right/down
--HD_SUBCHUNKID. = 34					-- Castle exit
--HD_SUBCHUNKID. = 35					-- Castle altar
--HD_SUBCHUNKID. = 36					-- Castle right wall
--HD_SUBCHUNKID. = 37					-- Castle right wall with exits left/down
--HD_SUBCHUNKID. = 38					-- Castle right wall bottom layer
--HD_SUBCHUNKID. = 39					-- Castle right wall bottom layer with exit up
--HD_SUBCHUNKID. = 40					-- Castle bottom right moat
--HD_SUBCHUNKID. = 41					-- Crysknife pit left
--HD_SUBCHUNKID. = 42					-- Crysknife pit right
--HD_SUBCHUNKID. = 43					-- Castle coffin
--HD_SUBCHUNKID. = 46					-- Alien queen
--HD_SUBCHUNKID. = 47					-- DaR Castle Entrance
--HD_SUBCHUNKID. = 48					-- DaR Crystal Idol

-- "5", "6", "8", "F", "V", "("
HD_OBSTACLEBLOCK = {}
HD_OBSTACLEBLOCK.GROUND = {
	tilename = "5",
	dim = {3,5}
}
HD_OBSTACLEBLOCK.AIR = {
	tilename = "6",
	dim = {3,5}
}
HD_OBSTACLEBLOCK.DOOR = {
	tilename = "8",
	dim = {3,5}
}
HD_OBSTACLEBLOCK.PLATFORM = {
	tilename = "F",
	dim = {3,3},
	chunkcodes = {
		{"0ff000000"},
		{"0000ff000"},
		{"0000000ff"},
		{"00f000000"},
		{"0000f0000"},
		{"0000000f0"},
		{"0ji000000"},
		{"0000ji000"},
		{"0000000ji"},
		{"00i000000"},
		{"0000i0000"},
		{"0000000i0"}
	}
}
HD_OBSTACLEBLOCK.VINE = {
	tilename = "V",
	dim = {4,5},
	chunkcodes = {
		{"L0L0LL0L0LL000LL0000"},
		{"L0L0LL0L0LL000L0000L"},
		{"0L0L00L0L00L0L0000L0"}
	}
}
HD_OBSTACLEBLOCK.TEMPLE = {
	tilename = "(",
	dim = {3,4},
	chunkcodes = {
		{"111100000000"},
		{"222200000000"},
		{"222022200000"},
		{"022202220000"},
		{"000011110000"},
		{"000011112222"},
		{"000022221111"},
		{"000002202112"},
		{"000020021221"}
	}
}

HD_OBSTACLEBLOCK_TILENAME = {}
HD_OBSTACLEBLOCK_TILENAME["5"] = HD_OBSTACLEBLOCK.GROUND
HD_OBSTACLEBLOCK_TILENAME["6"] = HD_OBSTACLEBLOCK.AIR
HD_OBSTACLEBLOCK_TILENAME["8"] = HD_OBSTACLEBLOCK.DOOR
HD_OBSTACLEBLOCK_TILENAME["F"] = HD_OBSTACLEBLOCK.PLATFORM
HD_OBSTACLEBLOCK_TILENAME["V"] = HD_OBSTACLEBLOCK.VINE
HD_OBSTACLEBLOCK_TILENAME["("] = HD_OBSTACLEBLOCK.TEMPLE

-- retains HD tilenames
HD_TILENAME = {
	["0"] = {
		description = "Empty",
	},
	["#"] = {
		entity_types = {
			default = {ENT_TYPE.ACTIVEFLOOR_POWDERKEG},
		},
		description = "TNT Box",
	},
	["$"] = {
		description = "Roulette Item",
	},
	["%"] = {
		description = "Roulette Door",
	},
	["&"] = { -- 50% chance to spawn # TOTEST probably wrong
		entity_types = {
			default = {ENT_TYPE.LOGICAL_WATER_DRAIN, 0},
			alternate = {
				[THEME.CITY_OF_GOLD] = {ENT_TYPE.LOGICAL_LAVA_DRAIN, 0},
				[THEME.TEMPLE] = {ENT_TYPE.LOGICAL_LAVA_DRAIN, 0},
				[THEME.VOLCANA] = {ENT_TYPE.LOGICAL_LAVA_DRAIN, 0},
			},
		},
		offset = { 0, -2.5 },
		alternate_offset = {
			[THEME.CITY_OF_GOLD] = { 0, 0 },
			[THEME.TEMPLE] = { 0, 0 },
			[THEME.VOLCANA] = { 0, 0 },
		},
		description = "Waterfall",
		-- # TODO - Waterfall reskins in ASE:
			-- DWELLING: N/A
			-- COG: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\WORM\wormsmallbg.png
			-- JUNGLE: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\LUSH\lushsmallbg.png
			-- VOLCANA/TIAMAT: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\HELL\hellsmallbg.png
			-- TEMPLE: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\TEMPLE\templesmallbg.png
			-- ICE_CAVES: N/A(?)
	},
	["*"] = {
		entity_types = {
			default = {ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK},
			alternate = {
				[THEME.NEO_BABYLON] = {ENT_TYPE.ITEM_PLASMACANNON},
			},
		},
		-- hd_type = HD_ENT.TRAP_SPIKEBALL
		-- spawn method for plasma cannon should spawn a tile under it, stylized
		description = "Spikeball",
	},
	["+"] = {
		entity_types = {
			default = {0},--ENT_TYPE.BG_LEVEL_BACKWALL},
			alternate = {
				[THEME.ICE_CAVES] = {ENT_TYPE.FLOORSTYLED_MOTHERSHIP}
			},
		},
		description = "Wooden Background",
	},
	[","] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.FLOORSTYLED_MINEWOOD
			},
		},
		description = "Terrain/Wood",
	},
	["-"] = {
		entity_types = {
			default = {ENT_TYPE.ACTIVEFLOOR_THINICE},
		},
		description = "Cracking Ice",
	},
	["."] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
		},
		description = "Unmodified Terrain",
	},
	["1"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOORSTYLED_GUTS},
				[THEME.NEO_BABYLON] = {ENT_TYPE.FLOORSTYLED_MOTHERSHIP},
			},
		},
		description = "Terrain",
	},
	["2"] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOOR_GENERIC,
				0
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					ENT_TYPE.FLOORSTYLED_GUTS,
					ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK,
					0
				},
				[THEME.NEO_BABYLON] = {
					ENT_TYPE.FLOORSTYLED_MOTHERSHIP,
					0
				},
			},
		},
		description = "Terrain/Empty",
	},
	["3"] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.LIQUID_WATER
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					ENT_TYPE.FLOORSTYLED_GUTS,
					ENT_TYPE.LIQUID_WATER
				},
				[THEME.TEMPLE] = {
					ENT_TYPE.FLOOR_GENERIC,
					ENT_TYPE.LIQUID_LAVA
				},
				[THEME.CITY_OF_GOLD] = {
					ENT_TYPE.FLOOR_GENERIC,
					ENT_TYPE.LIQUID_LAVA
				},
				[THEME.VOLCANA] = {
					ENT_TYPE.FLOOR_GENERIC,
					ENT_TYPE.LIQUID_LAVA
				},
			},
		},
		description = "Terrain/Water",
	},
	["4"] = {
		entity_types = {
			default = {ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK},
		},
		description = "Pushblock",
	},
	["5"] = {
		description = "Ground Obstacle Block",
	},
	["6"] = {
		description = "Floating Obstacle Block",
	},
	["7"] = {
		embedded_ents = {
			ENT_TYPE.FLOOR_SPIKES,
			0
		},
		offset_spawnover = {0, -1},
		description = "Spikes/Empty",
	},
	["8"] = {
		description = "Door with Terrain Block",
	},
	["9"] = {
		description = "Exit/Entrance Door", -- old description: "Door without Platform"
	},
	[":"] = {
		entity_types = {
			default = {ENT_TYPE.MONS_SCORPION},
			alternate = {
				[THEME.JUNGLE] = {ENT_TYPE.MONS_TIKIMAN},
				[THEME.NEO_BABYLON] = {ENT_TYPE.MONS_YETI, ENT_TYPE.MONS_CAVEMAN}
			},
		},
		description = "World-specific Enemy Spawn",--"Scorpion from Mines Coffin",
	},
	[";"] = {
		-- # TODO: Damsel and Idol Kalipit
		description = "Damsel and Idol from Kalipit",
	},
	["="] = {
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_MINEWOOD},
		},
		description = "Wood with Background",
	},
	["A"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_IDOL_BLOCK},
		},
		description = "Mines Idol Platform",
	},
	["B"] = {
		-- # TODO: Find a good reskin replacement
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_STONE},
		},
		description = "Jungle/Temple Idol Platform",
	},
	["C"] = {
		-- # TODO: Ceiling Idol Trap
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_STONE},
			alternate = {
				[THEME.TIAMAT] = ENT_TYPE.ITEM_CRATE
			},
		},
		description = "Nonmovable Pushblock", -- also idol trap ceiling blocks
	},
	["D"] = {
		entity_types = {
			default = {0},
			tutorial = {
				ENT_TYPE.MONS_PET_DOG,
				ENT_TYPE.MONS_PET_CAT,
				ENT_TYPE.MONS_PET_HAMSTER
			},
		},
		--#TOTEST: Also used in tutorial level 3 placement {3, 4} as Damsel
		-- # TODO: door creation (should be same door as "%")
		description = "Door Gate", -- also used in temple idol trap
	},
	["E"] = {
		-- # TODO: figure out what this is and how it spawns
		entity_types = {
			tutorial = {ENT_TYPE.ITEM_GOLDBAR},
			default = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.ITEM_CRATE,
				ENT_TYPE.ITEM_CHEST,
				0
			},
		},
		description = "Terrain/Empty/Crate/Chest",
	},
	["F"] = {
		description = "Falling Platform Obstacle Block",
	},
	["G"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_LADDER},
		},
		description = "Ladder (Strict)",
	},
	["H"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_LADDER_PLATFORM},
		},
		description = "Ladder Platform (Strict)",
	},
	["I"] = {
		offset = { 0.5, 0 },
		description = "Idol",
	},
	["J"] = {
		entity_types = {
			default = {ENT_TYPE.MONS_GIANTFISH},
		},
		description = "Ol' Bitey",
	},
	["K"] = {
		description = "Shopkeeper",
	},
	["L"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_LADDER},
			alternate = {
				[THEME.JUNGLE] = {ENT_TYPE.FLOOR_VINE},
				[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOOR_VINE},
				[THEME.NEO_BABYLON] = {ENT_TYPE.ACTIVEFLOOR_SHIELD},
				[THEME.VOLCANA] = {ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN},
			},
		},
		description = "Ladder", -- sometimes used as Vine or Chain
	},
	["M"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
		},
		embedded_ents = {ENT_TYPE.ITEM_MATTOCK},
		description = "Crust Mattock from Snake Pit",
	},
	["N"] = {
		-- # TODO: In HD, this may be telling the spawn system to spawn using the chance of a snake against a cobra
		entity_types = {
			default = {ENT_TYPE.MONS_SNAKE},
		},
		description = "Snake from Snake Pit",
	},
	["O"] = {
		description = "Moai Head",
		-- # TODO: Generation.
		-- # TODO: Blocks/foreground reskins
			-- # TODO in ASE: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\ICE\icesmallbg.png
	},
	["P"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_LADDER_PLATFORM},
		},
		description = "Ladder Platform (Strict)",
	},
	["Q"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GROWABLE_VINE},
			alternate = {
				[THEME.JUNGLE] = {ENT_TYPE.FLOOR_GROWABLE_VINE},
				[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOOR_GROWABLE_VINE},
				[THEME.NEO_BABYLON] = {ENT_TYPE.MONS_ALIENQUEEN},
				[THEME.VOLCANA] = {ENT_TYPE.FLOOR_GROWABLE_VINE},--FLOOR_CHAINANDBLOCKS_CHAIN},
			},
		},
		-- # TODO: Generate ladder to just above floor.
		description = "Variable-Length Ladder",
	},
	["R"] = {
		entity_types = {
			default = {ENT_TYPE.ITEM_RUBY},
		},
		description = "Ruby from Snakepit",
	},
	["S"] = {
		description = "Shop Items",
	},
	["T"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_TREE_BASE},
		},
		-- # TODO: Generation.
		-- Use the following depreciated methods for a starting point:
		
		-- function decorate_tree(e_type, p_uid, side, y_offset, radius, right)
		-- 	if p_uid == 0 then return 0 end
		-- 	p_x, p_y, p_l = get_position(p_uid)
		-- 	branches = get_entities_at(e_type, 0, p_x+side, p_y, p_l, radius)
		-- 	branch_uid = 0
		-- 	if #branches == 0 then
		-- 		branch_uid = spawn_entity_over(e_type, p_uid, side, y_offset)
		-- 	else
		-- 		branch_uid = branches[1]
		-- 	end
		-- 	-- flip if you just created it and it's a 0x100 and it's on the left or if it's 0x200 and on the right.
		-- 	branch_e = get_entity(branch_uid)
		-- 	if branch_e ~= nil then
		-- 		-- flipped = test_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		-- 		if (#branches == 0 and branch_e.type.search_flags == 0x100 and side == -1) then
		-- 			flip_entity(branch_uid)
		-- 		elseif (branch_e.type.search_flags == 0x200 and right == true) then
		-- 			branch_e.flags = set_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		-- 		end
		-- 	end
		-- 	return branch_uid
		-- end
		-- function onlevel_decorate_trees()
		-- 	if state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE then
		-- 		-- add branches to tops of trees, add leaf decorations
		-- 		treetops = get_entities_by_type(ENT_TYPE.FLOOR_TREE_TOP)
		-- 		for _, treetop in ipairs(treetops) do
		-- 			branch_uid_left = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, -1, 0, 0.1, false)
		-- 			branch_uid_right = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, 1, 0, 0.1, false)
		-- 			if feeling_check("RESTLESS") == false then
		-- 				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
		-- 				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
		-- 			-- else
		-- 				-- # TODO: chance of grabbing the FLOOR_TREE_TRUNK below `treetop` and applying DECORATION_TREE with a reskin of a haunted face
		-- 			end
		-- 		end
		-- 	end
		-- end

		description = "Tree",
	},
	["U"] = {
		entity_types = {
			default = {ENT_TYPE.MONS_VLAD},
		},
		description = "Vlad",
	},
	["V"] = {
		description = "Vines Obstacle Block",
	},
	["W"] = {
		description = "Unknown: Something Shop-Related",
	},
	["X"] = {
		entity_types = {
			default = {ENT_TYPE.MONS_GIANTSPIDER},
		},
		-- alternate_hd_types = {
		-- -- Mothership: Alien Lord
		-- -- Hell: Horse Head & Ox Face
		-- },
		-- offset = { 0.5, 0 },
		description = "Giant Spider",
	},
	["Y"] = {
		entity_types = {
			default = {ENT_TYPE.MONS_YETIKING},
			alternate = {
				[THEME.TEMPLE] = {ENT_TYPE.MONS_MUMMY},
			},
		},
		description = "Yeti King",
	},
	["Z"] = {
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_BEEHIVE},
		},
		description = "Beehive Tile with Background",
	},
	["a"] = {
		--#TOTEST: Also used in tutorial:
			-- 2nd level, placement {4,2}.
			-- 3rd level, placement {1,2}.
		entity_types = {
			default = {ENT_TYPE.ITEM_PICKUP_ANKH},
			tutorial = {ENT_TYPE.ITEM_POT},
		},
		description = "Ankh",
	},
	-- # TODO:
		-- Add alternative shop floor of FLOOR_GENERIC
		-- Modify all HD shop roomcodes to accommodate this.
	["b"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_MINEWOOD},
		},
		flags = {
			[ENT_FLAG.SHOP_FLOOR] = true
		},
		description = "Shop Floor",
	},
	["c"] = {
		-- spawnfunction = function(params)
		-- 	set_timeout(create_idol_crystalskull, 10)
		-- end,
		
		offset = { 0.5, 0 },
		description = "Crystal Skull",
	},
	["d"] = {
		-- HD may spawn this as wood at times. The solution is to replace that tilecode with "v"
		entity_types = {
			default = {ENT_TYPE.FLOOR_JUNGLE},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK},
			},
		},
		description = "Jungle Terrain",
	},
	["e"] = {
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_BEEHIVE},
			tutorial = {ENT_TYPE.ITEM_CRATE},
		},
		contents = ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		description = "Beehive Tile",
	},
	["f"] = {
		entity_types = {
			default = {ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM},
		},
		description = "Falling Platform",
	},
	["g"] = {
		-- spawnfunction = function(params)
		-- 	create_unlockcoffin(params[1], params[2], params[3])
		-- end,
		-- entity_types = {
		-- 	default = {ENT_TYPE.ITEM_COFFIN},
		-- },
		description = "Coffin",
	},
	["h"] = {
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_VLAD},
			tutorial = {ENT_TYPE.ITEM_CRATE},
		},
		contents = ENT_TYPE.ITEM_PICKUP_ROPEPILE,
		description = "Vlad's Castle Brick",--Hell Terrain",
		--#TODO: in HD it's also the haunted castle altar
	},
	["i"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_ICE},
			alternate = {
				-- # TODO: Modify tikivillage codes by moving "i" tiles up one.
				-- Depreciated:
					-- function onlevel_decorate_cookfire()
						-- if state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE then
							-- -- spawn lavapot at campfire
							-- campfires = get_entities_by_type(ENT_TYPE.ITEM_COOKFIRE)
							-- for _, campfire in ipairs(campfires) do
								-- px, py, pl = get_position(campfire)
								-- spawn(ENT_TYPE.ITEM_LAVAPOT, px, py, pl, 0, 0)
							-- end
						-- end
					-- end
				[THEME.JUNGLE] = {ENT_TYPE.ITEM_LAVAPOT}
			},
		},
		description = "Ice Block",
	},
	["j"] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOOR_ICE,
				0
			},
		},
		description = "Ice Block/Empty", -- Old description: "Ice Block with Caveman".
	},
	["k"] = {
		entity_types = {
			default = {ENT_TYPE.DECORATION_SHOPSIGN},
		},
		offset = { 0, 4 },
		description = "Shop Entrance Sign",
	},
	["l"] = {
		entity_types = {
			default = {ENT_TYPE.ITEM_LAMP},
		},
		description = "Shop Lantern",
	},
	["m"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
			alternate = {
				[THEME.NEO_BABYLON] = {ENT_TYPE.ACTIVEFLOOR_ELEVATOR},
			},
		},
		flags = {
			[ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR] = true
		},
		description = "Unbreakable Terrain",
	},
	["n"] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.MONS_SNAKE,
				0,
			},
		},
		description = "Terrain/Empty/Snake",
	},
	["o"] = {
		entity_types = {
			default = {ENT_TYPE.ITEM_ROCK},
		},
		description = "Rock",
	},
	["p"] = {
		-- Not sure about this one. It's only used in the corners of the crystal skull jungle roomcode.
		-- # TODO: Investigate in HD
		-- entity_types = {
		-- 	default = {ENT_TYPE.ITEM_GOLDBAR},
		-- },
		description = "Treasure/Damsel",
	},
	["q"] = {
		-- # TODO: Trap Prevention.
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
		},
		description = "Obstacle-Resistant Terrain",
	},
	["r"] = {
		description = "Terrain/Stone", -- old description: Mines Terrain/Temple Terrain/Pushblock
		-- Used to be used for Temple Obstacle Block but it lead to conflictions
		-- From 
		entity_types = {
			default = {
				ENT_TYPE.FLOORSTYLED_STONE,
				ENT_TYPE.FLOOR_GENERIC,
				-- ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK
			},
		},
	},
	["s"] = {
		embedded_ents = {ENT_TYPE.FLOOR_SPIKES},
		offset_spawnover = {0, -1},
		description = "Spikes",
	},
	["t"] = {
		entity_types = {
			default = {
				ENT_TYPE.FLOORSTYLED_STONE
				-- ENT_TYPE.FLOORSTYLED_TEMPLE,
				-- ENT_TYPE.FLOOR_JUNGLE
			},
		},
		-- # TODO: ????? Investigate in HD.
		description = "Temple/Castle Terrain",
	},
	["u"] = {
		--#TOTEST: Also used in tutorial:
			-- 3rd level, placement {1,4}.
		entity_types = {
			tutorial = {ENT_TYPE.MONS_BAT},
			default = {ENT_TYPE.MONS_VAMPIRE},
		},
		description = "Vampire from Vlad's Tower",
	},
	["v"] = {
		entity_types = {
			default = {ENT_TYPE.FLOORSTYLED_MINEWOOD},
		},
		description = "Wood",
	},
	["w"] = {
		entity_types = {
			default = {ENT_TYPE.LIQUID_WATER},
			alternate = {
				[THEME.TEMPLE] = {ENT_TYPE.LIQUID_LAVA},
				[THEME.CITY_OF_GOLD] = {ENT_TYPE.LIQUID_LAVA},
				[THEME.VOLCANA] = {ENT_TYPE.LIQUID_LAVA},
			},
		},
		description = "Liquid",
	},
	["x"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_ALTAR},
		},
		description = "Kali Altar",
	},
	["y"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_GENERIC},
		},
		embedded_ents = {ENT_TYPE.ITEM_RUBY},
		description = "Crust Ruby in Terrain",
	},
	["z"] = {
		entity_types = {
			tutorial = {
				ENT_TYPE.ITEM_CHEST,
			},
			default = {
				ENT_TYPE.FLOORSTYLED_BEEHIVE,
				0
			},
			-- -- # TODO: spawn method for turret
			-- alternate = {
			-- 	[THEME.NEO_BABYLON] = {}
			-- },
		},
		-- # TODO: Temple has bg pillar as an alternative
		description = "Beehive Tile/Empty",
	},
	["|"] = {
		description = "Vault",
	},
	["~"] = {
		entity_types = {
			default = {ENT_TYPE.FLOOR_SPRING_TRAP},
		},
		description = "Bounce Trap",
	},
	["!"] = {
		-- one occasion in tutorial it's an arrow trap
		description = "Tutorial Controls Display",
	},
	["("] = {
		-- Had to create a new tile for Temple's obstacle tile because there were conflictions with "r" in Jungle.
		description = "Temple Obstacle Block",
	}
		-- description = "Unknown",
}


-- # TODO: issues with current hardcodedgeneration-dependent features:
	-- Vaults
		-- May interfere with the process of altering the level_path
	-- Idol traps
		-- Currently messes up mines level generation since S2 assumes that it's part of path
	-- Udjat eye placement
		-- mines level generation isn't as accurate
			-- slightly incorrect side rooms
			-- can't spawn on 1-4
	-- My own system for spawning the wormtongue
		-- Has to be hardcoded in order to work for both jungle and ice caves
		-- Has to be hardcoded in order to work for both jungle and ice caves

	-- if you need the variation that's facing left, use roomcodes[2].
	-- dimensions are assumed to be 10x8, but you can define them with dimensions = { w = 10, h = 8 }
HD_ROOMOBJECT = {}
HD_ROOMOBJECT.DIM = {h = 8, w = 10}
HD_ROOMOBJECT.GENERIC = {
	-- Regular
	[HD_SUBCHUNKID.SHOP_REGULAR] = {
		--{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..KS000000bbbbbbbbbb"}
		{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- S2 sync
	},
	[HD_SUBCHUNKID.SHOP_REGULAR_LEFT] = {
		--{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S000K..bbbbbbbbbb"}
		{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- S2 sync
	},
	-- Prize Wheel
	[HD_SUBCHUNKID.SHOP_PRIZE] = {
		--{"11111111111111..1111....22...1.Kl00002.....000W0.0.0%00000k0.$%00S0000bbbbbbbbbb"}
		{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- S2 sync
	},
	[HD_SUBCHUNKID.SHOP_PRIZE_LEFT] = {
		--{"11111111111111..11111...22......20000lK.0.W0000...0k00000%0.0000S00%$.bbbbbbbbbb"}
		{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- S2 sync
	},
	-- Damzel
	[HD_SUBCHUNKID.SHOP_BROTHEL] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K00S0000bbbbbbbbbb"}
	},
	[HD_SUBCHUNKID.SHOP_BROTHEL_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...0000S00K..bbbbbbbbbb"}
	},
	-- Hiredhands(?)
	[HD_SUBCHUNKID.SHOP_UNKNOWN1] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0SSS000bbbbbbbbbb"}
	},
	[HD_SUBCHUNKID.SHOP_UNKNOWN1_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000SSS0K..bbbbbbbbbb"}
	},
	-- Hiredhands(?)
	[HD_SUBCHUNKID.SHOP_UNKNOWN2] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0S0S000bbbbbbbbbb"}
	},
	[HD_SUBCHUNKID.SHOP_UNKNOWN2_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S0S0K..bbbbbbbbbb"}
	},
	-- Vault
	[HD_SUBCHUNKID.VAULT] = {
		--{"11111111111111111111111|00011111100001111110EE0111111000011111111111111111111111"}
		{"11111111111000000001100|00000110000000011000000001100000000110000000011111111111"} -- S2 sync
	},
	-- Altar
	[HD_SUBCHUNKID.ALTAR] = {
		{"220000002200000000000000000000000000000000000000000000xx000002211112201111111111"}
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- S2 sync
	}
}
HD_ROOMOBJECT.TUTORIAL = {}
HD_ROOMOBJECT.TUTORIAL[1] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 1},
			roomcodes = {{"11111111111111111122121111120010222220001000000000100000000010090000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"1111111111111111110001111100000000000000000000000!000000000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"1111111111222vv111000000000000000EE00000000vv00EE0000vv00vv0111vvN0vvN1111111vv1"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"1111111111222111111100022221110000000111000000vvv1000000v0010000000EE1111000v==1"}}
		},

		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"1111111111111111111111vvvv111100000001120L0EE000200Pvvvv00000LvvE000001Pvvvv1111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"11111111001111111200222221120000000110000000E110000001111R000000E111111100111110"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},
			roomcodes = {{"0000000000000000000000000000000000000000000000000000000!000011000000000000001111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000001100000000000000000000011110000000011000011111100N01111111111111111"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"0L111111110L011111110L000000000L000000000L00!000000L000000000L000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"0000000000000000000000EE000000001100000v0011000000001111100000111110001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"0000000000000110000000N0000000vvv000000000000N00000vvvvv000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"000000000000L000000000P11000E000L110011000L110000000L111000000L11100L01111111vPv"}}
		},

		-- 4
		{
			subchunk_id = HD_SUBCHUNKID.EXIT,
			placement = {4, 1},
			roomcodes = {{"1111111112111111222022222200000000000000000900000000vvv0000v00vvv0000v1vvvvv111v"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"1111111111001EE0000000vvvv000000v00v0000000NE0001100v==vv00000111110001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"000000000000000000000000000000000000000000110011000011001111ssssss0R111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000L000E00000L000110000L000010000L000000000L000000000L0000000N0L01111111111"}}
		},
	}
}
HD_ROOMOBJECT.TUTORIAL[2] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"10001111110000000000z000000000111000000011L00000e0vvPvvvvv11vEL000Ev11vvL0vvvv11"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"1111111111000000000000000000000000000!000e000000001111N00000111110N0001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"11111111110110000000000000000000000000000000001110000001111s00000011111111111111"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 4},
			roomcodes = {{"111111111100000000010EEEE000010vvvv0090100vv001111ssvvss111111vv1111111111111111"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"11L00001111100L000001111P00000vvvvL00000v00vL00000vEE0L00000v==vvvv1111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"1111111111111111111111011110010u000u000u00000000000000!0000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},
			roomcodes = {{"1111111111111110000011000000000000000011000000!011000000001100000000111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"1111111111000111111100000L000z111vvPvvvv11111L000011111L000011111L00L01111vvvvPv"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"111111111111111111vv1vvv1111v00eee0111vh0vvv0111v=000001111110001111111001111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"1100000011vv001111110v00111111h001111111=v11111111111111111111111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"11111111111111111111111001110011a0000u00111000000011e000N000111111111111111111vv"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"11111111L011101110L001100000L000000vvvvv000000E11111110011111111001111vvvv001111"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"10000000001000000000000!00000000000000001110101011RR10101011111s1s1s111111111111"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.EXIT,
			placement = {4, 2},
			roomcodes = {{"11111111110000111000000000000000900000001111000!00111100000111110a00011111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"11100011v0011000000000000000v=0000000111000000001110N000001011111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00v00vv000v00EEvEE00v=vvvvvv0011111111100000001100000z00040011111111111111111111"}}
		},
	}
}
HD_ROOMOBJECT.TUTORIAL[3] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 1},
			roomcodes = {{"1111111111vvvvvv2222v0000v0000v009000000v====v000011111100vv11111111vv1111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"22000000000000000!000000000000001000a0o00000011111vssssR1111v1111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"110011100000000010000000000000000000000v0000N0000v0o0111000v111111001v1111110001"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"0uvv10v00000vv000EEE000v00v===vvvv000000vv0v000001v00N00N00hvv=v1111111111111111"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"11111111110001111111z000022111110000000011000000vv11o00L000E11110Pvvvv11110L1111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"11111110011111110000000u0u00000o00000000v111110000v111110000v111110I001111111AA1"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},-- "!" = arrow trap for this one, h = rope crate
			roomcodes = {{"1111111001011111000100111100110011110000!111vvv0001111vE0000h111vvvv001111110000"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.SHOP_REGULAR_LEFT,
			placement = {2, 4},
			roomcodes = {{
				-- "111111111111111111111111221111112000l11101W0000...0k00000...000S000K..bbbbbbbbbb"
				-- wow, okay, so comparing SHOP_REGULAR_LEFT's roomcode to the original shows that it's almost exactly the same
				-- with the exception of the overhead tiles not set to shopkeeper tiles
				"00000000000000000000000000000000000000000000000000000000000000000000000000000000" -- S2 sync
			}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"11110Lvvv111100L0000vvv0vvvvv0vE00000000vvvvv0000011v0v0000011v000001111v=v00011"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"111111111100000000000000000000000L011111000P11vvvv000L11v000000L040EEE111111v==="}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"11110000000000000N01000N0111111111111111vvvv111010000v100000EE00400000===v111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"111111111111111111111111111111111111111111111111110001100010000000000000100000D0"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"1100001111110011111100000000u00000a00000vvvvv00000h0000001101111111110111111111s"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"111111z0111111111011000000000000000000000000000000101010110o10101011111s1s1s1111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"111111111111111111110000000u0000000!0000N0000000001100000000110001111111sss11111"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.EXIT,
			placement = {4, 4},
			roomcodes = {{"111111111111111vvvvv00001v0000000000009000100v====001000111111111111111111111111"}}
		},
	}
}
HD_ROOMOBJECT.TESTING = {}
HD_ROOMOBJECT.TESTING[1] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.EXIT,
			placement = {2, 3},
			roomcodes = {{"00000000000000090LL01111111PP10000000LL0000LL00LL0111PP11111000LL00000000LL00000"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000001111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"00000LL00000000LL00000000LL00000000LL00000000LL000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"000LL00000000LL00000000LL00000000LL00000000LL00000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000111111110000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
	}
}
HD_ROOMOBJECT.TESTING[2] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.EXIT,
			placement = {2, 3},
			roomcodes = {{"00000000000000090LL01111111PP10000000LL0000LL00LL0111PP11111000LL00000000LL00000"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000001111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"00000LL00000000LL00000000LL00000000LL00000000LL000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"000LL00000000LL00000000LL00000000LL00000000LL00000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000111111110000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
	}
}
HD_ROOMOBJECT.FEELINGS = {}
HD_ROOMOBJECT.FEELINGS["VAULT"] = {
	prePath = false,
	method = function()
		level_generation_method_nonaligned(
			{
				subchunk_id = HD_SUBCHUNKID.VAULT,
				roomcodes = (
					HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.VAULT] ~= nil
				) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.VAULT] or HD_ROOMOBJECT.GENERIC[HD_SUBCHUNKID.VAULT]
			}
		)
	end
}

HD_ROOMOBJECT.FEELINGS["SPIDERLAIR"] = {
	-- coffin_unlockable = {
		
	-- },
	-- rooms = {
	-- 	{
	-- 		subchunk_id = -1,
	-- 		roomcodes = {
	-- 			{""},
	-- 		}
	-- 	},
	-- }
}
HD_ROOMOBJECT.FEELINGS["SNAKEPIT"] = {
	prePath = true,
	rooms = {
		[HD_SUBCHUNKID.SNAKEPIT_TOP] = { -- grabs 4 and upwards from HD's path_drop roomcodes
			{
				"00000000000060000000000000000000000000000000000000001112220002100000001110111111", --if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000001112220002100000001110011111"-- else
			},
			{
				"00000000000060000000000000000000000000000000000000002221110000000001201111110111", --if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000002221110000000001201111100111"-- else
			},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211200000002100000000000200000000000000000211120000211"},
			{"11111111111111112222211220000001200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
		},
		[HD_SUBCHUNKID.SNAKEPIT_MIDSECTION] = {{"111000011111n0000n11111200211111n0000n11111200211111n0000n11111200211111n0000n11"}},
		[HD_SUBCHUNKID.SNAKEPIT_BOTTOM] = {{"111000011111n0000n1111100001111100N0001111N0110N11111NRRN1111111M111111111111111"}}
	}
}

-- Spawn Steps:
	-- 106
		-- levelw, levelh = get_levelsize()
		-- structx = math.random(1, levelw)
		-- spawn 106 at 1, structx
	-- 107
		-- _, levelh = get_levelsize()
		-- struct_midheight = math.random(1, levelh-2)
		-- for i = 1, struct_midheight, 1 do
			-- spawn 107 at i, structx
		-- end
	-- 108
		-- spawn 108 at struct_midheight+1, structx
HD_ROOMOBJECT.FEELINGS["SNAKEPIT"].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = HD_SUBCHUNKID.SNAKEPIT_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS["SNAKEPIT"].rooms[HD_SUBCHUNKID.SNAKEPIT_TOP]
		},
		{
			middle = {
				subchunk_id = HD_SUBCHUNKID.SNAKEPIT_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS["SNAKEPIT"].rooms[HD_SUBCHUNKID.SNAKEPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = HD_SUBCHUNKID.SNAKEPIT_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS["SNAKEPIT"].rooms[HD_SUBCHUNKID.SNAKEPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		1
	)
	
end

HD_ROOMOBJECT.FEELINGS["RESTLESS"] = {
	prePath = false,
	rooms = {
		[HD_SUBCHUNKID.RESTLESS_IDOL] = {
			{"tttttttttttttttttttttt00c000tt0tt0A00tt00400000040ttt0tt0ttttt000000tt1111111111"}
		},
		[HD_SUBCHUNKID.RESTLESS_TOMB] = {
			{
				"000000000000000000000000900000021t1t1200211t0t112011rtttr11011r111r11111rrrrr111",
				"0000000000000000000000000900000021t1t1200211t0t112011rtttr11111r111r11111rrrrr11",
			}
		},
	},
}
HD_ROOMOBJECT.FEELINGS["RESTLESS"].method = function()
	level_generation_method_nonaligned(
		{
			subchunk_id = HD_SUBCHUNKID.RESTLESS_TOMB,
			roomcodes = HD_ROOMOBJECT.FEELINGS["RESTLESS"].rooms[HD_SUBCHUNKID.RESTLESS_TOMB]
		}
	)
end

HD_ROOMOBJECT.FEELINGS["TIKIVILLAGE"] = {
	prePath = false,
	rooms = {
		-- Replaced all "d" tiles with "v"
		-- # TODO: Replace unlock roomcode "d" tiles with "v"
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH] = {
			{
				"0000:0000000vvvvv00000v000v0000G00:00Gv0vPv===vPv0vG00000Gv00G00:00G00v=======v1",
				"00000:0000000vvvvv00000v000v000vG00:00G00vPv===vPv0vG00000Gv00G00:00G01v=======v"
			},
			{"00000000000000:0000000vvvv000000v+0v00000vv0vv0000000:0100001vv=v110T01111111111"},
			{"000000000000000:00000000vvvv000000v0+v000000vv0vv0000010:0000T011v=vv11111111111"},
		},
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP] = {
			{"111111111111v1111v1112v0000v210000:0000000v====v0000000000002q120021121111001111"},
			{"111111111111v1111v1112v0000v210000:0000000v====v00000000000021120021q21111001111"},
		},

		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP] = {
			{"00000000000000000000000000t0t00vvvvvt0t00v0000t0t000:00000t00v====tit01111111111"},
			{"000000000000000000000t0t0000000t0tvvvvv00t0t0000v00t00000:000tit====v01111111111"},
		},
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT] = {
			{"1200000000vvvvv00000v000vv0000v0:00000001===vvv00011++00v00011110:00001111==v111"},
		},
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT] = {
			{"000000002100000vvvvv0000vv000v0000000:0v000vv====1000v00++110000:01111111v==1111"},
		},

		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP] = {
			{"000000000000vvvvvv0000v0+00v000000G:000000v=P==v0000v0G00v002qv2G02v121111G01111"},
			{"000000000000vvvvvv0000v00+0v000000:G000000v==P=v0000v00G0v002qv20G2v1211110G1111"},
		},
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT] = {
			{"12000000001v0vvvv0001v00+0v0001vv:G000001v==P==0001112G000001120G010001111G01111"},
		},
		[HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT] = {
			{"0000000021000vvvvvv1000v0+00v100000G:vv1000v=P===100000G211100010G021101110G1111"},
		},
	},
}
HD_ROOMOBJECT.FEELINGS["TIKIVILLAGE"].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	levelh_start, levelh_end = 2, levelh-1
	for room_y = levelh_start, levelh_end, 1 do
		for room_x = 1, levelw, 1 do
			path_to_replace = global_levelassembly.modification.levelrooms[room_y][room_x]
			path_to_replace_with = -1
			
			-- drop/drop_notop
			if (
				(path_to_replace == HD_SUBCHUNKID.PATH_DROP or path_to_replace == HD_SUBCHUNKID.PATH_DROP_NOTOP) and
				-- don't replace path_drop or path_drop_notop when room_y == 1
				-- (room_y ~= 1) and
				-- 2/5 chance not to replace path_drop or path_drop_notop
				(math.random(1, 5) > 3)
			) then
				if path_to_replace == HD_SUBCHUNKID.PATH_DROP then
					path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP
				elseif path_to_replace == HD_SUBCHUNKID.PATH_DROP_NOTOP then
					if (room_y == 2 or room_y == 3) and (room_x == 1) then
						path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT
					elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
						path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT
					else
						path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP
					end
				end
			end
		
			-- notop
			if (
				(path_to_replace == HD_SUBCHUNKID.PATH_NOTOP)
			) then
				if (room_y == 2 or room_y == 3) and (room_x == 1) then
					path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT
				elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
					path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT
				else
					path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP
				end
			end
		
			-- path
			if (
				(path_to_replace == HD_SUBCHUNKID.PATH)
			) then
				path_to_replace_with = HD_SUBCHUNKID.TIKIVILLAGE_PATH
			end
		
			if path_to_replace_with ~= -1 then
				levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS["TIKIVILLAGE"].rooms[path_to_replace_with], room_y, room_x)
			end
		end
	end


end



HD_ROOMOBJECT.FEELINGS["MOTHERSHIPENTRANCE"] = {
	prePath = true,
	rooms = {
		[HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP] = {
			{-- replaced tilecodes: tree ("T") with door ("9") (and fill the 0 tile underneath it)
				"++++++++++++000000++++090000++++++00++++++++00++++++++00++++++++00++++++++00++++",
				"++++++++++++000000++++000090++++++00++++++++00++++++++00++++++++00++++++++00++++",
			}
		},
		[HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM] = {{"++++00++++++++00++++++++00++++++++00++++++000000++0+++00+++000++00++000000000000"}}
	}
}
HD_ROOMOBJECT.FEELINGS["MOTHERSHIPENTRANCE"].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS["MOTHERSHIPENTRANCE"].rooms[HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP]
		},
		{
			bottom = {
				subchunk_id = HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS["MOTHERSHIPENTRANCE"].rooms[HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM]
			}
		},
		{1, 4}
		-- ,0
	)
end
HD_ROOMOBJECT.FEELINGS["SACRIFICIALPIT"] = {
	prePath = true,
	rooms = {
		[HD_SUBCHUNKID.SACRIFICIALPIT_TOP] = {{"0000000000000000000000000000000000000000000100100000110011000111;01110111BBBB111"}},
		[HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION] = {{"11200002111120000211112000021111200002111120000211112000021111200002111120000211"}},
		[HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM] = {{"112000021111200002111120000211113wwww311113wwww311113wwww31111yyyyyy111111111111"}}
	}
}

-- Notes:
	-- start from top
	-- seems to always be top to bottom
-- Spawn steps:
	-- 116
		-- levelw, levelh = get_levelsize()
		-- structx = math.random(1, levelw)
		-- spawn 116 at 1, structx
	-- 117
		-- _, levelh = get_levelsize()
		-- struct_midheight = levelh-2
		-- for i = 1, struct_midheight, 1 do
			-- spawn 117 at i, structx
		-- end
	-- 118
		-- spawn 118 at structx, struct_midheight+1
HD_ROOMOBJECT.FEELINGS["SACRIFICIALPIT"].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = HD_SUBCHUNKID.SACRIFICIALPIT_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS["SACRIFICIALPIT"].rooms[HD_SUBCHUNKID.SACRIFICIALPIT_TOP]
		},
		{
			middle = {
				subchunk_id = HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS["SACRIFICIALPIT"].rooms[HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS["SACRIFICIALPIT"].rooms[HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		2
	)
end

HD_ROOMOBJECT.FEELINGS["VLAD"] = {
	prePath = true,
	rooms = {
		[HD_SUBCHUNKID.VLAD_TOP] = {{"0000hh000000shhhhs000shhhhhhs00hhhU0hhh0shh0000hhshhhh00hhhhhhQ0000Qhhhh000000hh"}},
		[HD_SUBCHUNKID.VLAD_MIDSECTION] = {{
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhhh00000hhhhQ0hhhhhhhh0qhhhhhh",
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhh00000hhhhhhhhh0Qhhhhhhhhq0hh"
		}},
		[HD_SUBCHUNKID.VLAD_BOTTOM] = {{"hh0L00L0hhhhhL00Lhhh040L00L040hhhL00Lhhhhh0L00L0hh040ssss040hhshhhhshhhhhhhhhhhh"}},
	}
}
HD_ROOMOBJECT.FEELINGS["VLAD"].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = HD_SUBCHUNKID.VLAD_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS["VLAD"].rooms[HD_SUBCHUNKID.VLAD_TOP]
		},
		{
			middle = {
				subchunk_id = HD_SUBCHUNKID.VLAD_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS["VLAD"].rooms[HD_SUBCHUNKID.VLAD_MIDSECTION]
			},
			bottom = {
				subchunk_id = HD_SUBCHUNKID.VLAD_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS["VLAD"].rooms[HD_SUBCHUNKID.VLAD_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		2
	)
end

HD_ROOMOBJECT.WORLDS = {}
HD_ROOMOBJECT.WORLDS[THEME.DWELLING] = {
	chunkRules = {
		rooms = {
			[HD_SUBCHUNKID.SIDE] = function()
				range_start, range_end = 1, 9 -- default
				
				chunkPool_rand_index = math.random(range_start, range_end)
				
				if chunkPool_rand_index == 4 and state.level < 3 then return 2
				else return chunkPool_rand_index end
			end,
		},
		obstacleBlocks = {
			[HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 32 -- default
				if (state.level < 3) then
					range_start, range_end = 1, 14
				else
					range_start, range_end = 15, 32
				end

				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{
				"110000000040L600000011P000000011L000000011L5000000110000000011000000001111111111",
				"00000000110060000L040000000P110000000L110050000L11000000001100000000111111111111"
			},
			{"00000000110060000L040000000P110000000L110050000L11000000001100000000111111111111"},
			{"11000000110#000000#0111100111111200002112200000022110000001111200002111111111111"},-- if state.level < 3 then use case 2 instead
			{
				"11111111112000L000021vvvP0vvv11v0vL0v0v10000L000001v=v11v=v111111111111111111111",
				"111111111120000L00021vvv0Pvvv11v0v0Lv0v100000L00001v=v11v=v111111111111111111111"
			},
			{"11111111110221111220002111120000022220000002222000002111120002211112201111111111"},
			{"11111111111112222111112000021111102201111120000211111022011111200002111112222111"},
			{
				"11111111110000000000110000001111222222111111111111012222221200000000201100000011",-- 1/4 chance
				"11111111110000000000110000001111222222111111111111212222221002000000001100000011",-- 1/4 chance
				"11111111110000000000110000001111222222111111111111112222221112000000211100000011",-- 2/4 chance
				"11111111110000000000110000001111222222111111111111112222221112000000211100000011",-- 
			},
			{"121111112100L2112L0011P1111P1111L2112L1111L1111L1111L1221L1100L0000L001111221111"},
		},
		[HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000000050000000000000000000000000011111111111111111111"},
			{"60000600000000000000000600000000000000000000000000000222220000111111001111111111"},
			{"11111111112222222222000000000000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112022222222000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112211111111201111111100111111110022222222000000000001111111111"},
			{
				"1111111111000000000L111111111P000000000L5000050000000000000000000000001111111111",
				"1111111111L000000000P111111111L0000000005000050000000000000000000000001111111111"
			},
			{"000000000000L0000L0000PvvvvP0000L0000L0000PvvvvP0000L1111L0000L1111L001111111111"},
			{"00000000000111111110001111110000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{
				"2222222222000000000000000000L00vvvvvvvP00v050000L0vv000000L0v0000000L01111111111",
				"222222222200000000000L000000000Pvvvvvvv00L500000v00L000000vv0L0000000v1111111111"
			},
		},
		[HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000600006000000000000000000000000600006000000000000000000000000"},
			{
				"00000000000000000000600006000000000000000000050000000000000000000000001202111111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000000000000600006000000000000000000050000000000000000000000001200021111"--else
			},
			{
				"00000000000000000000600006000000000000005000000000000000000000000000001111112021", --if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000000000000600006000000000000005000000000000000000000000000001111200021"--else
			},
			{
				"00000000000060000000000000000000000000000000000000001112220002100000001110111111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000001112220002100000001110011111"--else
			},
			{
				"00000000000060000000000000000000000000000000000000002221110000000001201111110111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000002221110000000001201111100111"--else
			},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211200000002100000000000200000000000000000211120000211"},
			{"11111111111111112222211220000001200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
		},
		[HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},-- empty case (extra chance)
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},--
			{"00000000000000000000000600000000000000000000000000000111110000111111001111111111"},
			{"00000000000111111110001111110000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{"10000000011112002111111200211100000000000022222000011111111011111111111111111111"},
			{
				"0000000000000000000000000000L00vvvvvvvP00v050000L0vv000000L0v0000000L01111111111",
				"000000000000000000000L000000000Pvvvvvvv00L500000v00L000000vv0L0000000v1111111111"
			},
		},
		[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000000000000000600006000000000000000000000000600006000000000000000000000000"},
			{
				"00000000000000000000600006000000000000000000050000000000000000000000001202111111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000000000000600006000000000000000000050000000000000000000000001200021111"--else
			},
			{
				"00000000000000000000600006000000000000005000000000000000000000000000001111112021", --if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000000000000600006000000000000005000000000000000000000000000001111200021"--else
			},
			{
				"00000000000060000000000000000000000000000000000000001112220002100000001110111111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000001112220002100000001110011111"--else
			},
			{
				"00000000000060000000000000000000000000000000000000002221110000000001201111110111",--if (*(char *)(*(int *)(param_3 + 0x1715c) + 0x4405f4) == '\0')
				-- "00000000000060000000000000000000000000000000000000002221110000000001201111100111"--else
			},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
		},
		[HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000008000000000000000000L000000000P111111000L111111000L00111111111111111"},
			{"0000000000008000000000000000000000000L000111111P000111111L001111100L001111111111"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v1001111111101111111111",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1001111111101111111111"
			},
		},
		[HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000002000000002"},
			{"11111111112222222222000000000000000000000008000000000000000000000000002000000002"},
			{"00000000000008000000000000000000L000000000P111111000Lvvvv11000L000v1111vvvv0v111"},
			{"0000000000008000000000000000000000000L000111111P00011vvvvL00111v000L00111v0vvvv1"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v100111v000001111v0vv11",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1000000v111011vv0v1111"
			},
		},
		[HD_SUBCHUNKID.EXIT] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000010021110001001111000110111129012000000111111111021111111201111111111"},
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000010021110001001111000110111129012000000111111111021111111201111111111"},
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
		},
		[HD_SUBCHUNKID.IDOL] = {{"2200000022000000000000000000000000000000000000000000000000000000I000001111AA1111"}}
	},
	coffin_unlockable = {
		{
			subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
			pathalign = true,
			roomcodes = {
				{
					"vvvvvvvvvvv++++++++vvL00000g0vvPvvvvvvvv0L000000000L0:000:0011111111111111111111",
					"vvvvvvvvvvv++++++++vvg000000LvvvvvvvvvPv00000000L000:000:0L011111111111111111111" -- facing left
				}
			}
		},
	},
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"011100020000000"},
			{"000001111000000"},
			{"000000111100000"},
			{"000000000011111"},
			{"000002020017177"},
			{"000000202071717"},
			{"000000020277171"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000222021112"},

			{"000002010077117"},
			{"000000010271177"},
			{"0010000#0002120"},
			{"000001111000000"},
			{"000000111100000"},
			{"000000000011111"},
			{"000000020077177"},
			{"000000010077777"},
			{"000000020077177"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000077"},
			{"011100222070007"},
			{"001110022277000"},
			{"000000222021112"},
			{"000002010077177"},
			{"000000010277177"},

		},
		[HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"022220000022220"},
			{"222200000002222"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000111000000"},
			{"000000111002220"},
			{"000000222001110"},
			{"000000022001111"},
			{"000002220011100"},
		},
		[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.JUNGLE] = {
	chunkRules = {
		obstacleBlocks = {
			[HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 22 -- default
				if (math.random(2) == 2) then -- TODO: Figure out what conditions FUN_004e00c0() is filtering through in Ghidra.
					if (math.random(6) == 6) then -- if (uVar8 % 6 == 0)
						range_start, range_end = 20, 22 -- iVar6 = uVar8 % 3 + 0x67;
					else
						range_start, range_end = 9, 16 -- iVar6 = (uVar8 & 7) + 9;
					end
				else
					if (math.random(6) == 6) then -- if (uVar8 % 6 == 0)
						range_start, range_end = 17, 19 -- iVar6 = uVar8 % 3 + 100;
					else
						range_start, range_end = 1, 8 -- iVar6 = (uVar8 & 7) + 1;
					end
				end

				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{"111111111111V0000211120000021100000002110000000211112000021111120021111111001111"},
			{"1111111111112V000011112000002111200000001120000000112000021111120021111111001111"},
			{"11120021111100000222120000021100000002220000000211112000022211177T71111111111111"},
			{"1112002111222000001111200000212220000000112000000022200002111117T771111111111111"},-- empty case statement (2x more chance)
			{"1112002111222000001111200000212220000000112000000022200002111117T771111111111111"},--
			{
				"111111111112000Q0211120000021112000002111200000211112000021111120021111112002111",
				"11111111111200Q00211120000021112000002111200000211112000021111120021111112002111"
			},
			{"000000000001wwwwww1011wwwwww11113wwww311113wwww311113wwww31111133331111111111111"},
			{"00000000000000rr0000000rttr00000rrrrrr0000V0000000000000000000000000002000000002"},
		},
		[HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000050000500000000000000000000000011111111111111111111"},
			{"60000600000000000000000000000000000000000000000000000111110000111111001111111111"},
			{"2222222222000000000000000000000000tt000000r0220r0000t0tt0t000rtrttrtr01111111111"},
			{
				"0L000000001L111111110L222222200L000000000002002000011122111011200002111111111111",
				"00000000L011111111L102222222L000000000L00002002000011122111011200002111111111111"
			},
			{"1111111111V0000V000000000000000000000000000000000010000000011ssssssss11111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"00000000000000&0000000000000000q3wwww3q0013wwww310113wwww31111133331111111111111"},
			{"0060000000000000000000000000000000&000000q3wwww3q0113wwww31111133331111111111111"},
		},
		[HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
			{"11111111111111111111120000002100000000000000000000022000022021120021121111001111"},
		},
		[HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
			{
				"0000000000000000000000000000000000500000000000000000T000000011111111111111111111",
				"000000000000000000000000000000050000000000000000000000000T0011111111111111111111"
			},
			{
				"00000000000000000000000000000000000000000002222220001111111011111111111111111111",
				"00000000000000000000000000000000000000000222222000011111110011111111111111111111"
			},
			{
				"00000000000000000000000000000000000000000000000220000002211100002211111111111111",
				"00000000000000000000000000000000000000000220000000111220000011112200001111111111"
			},
			{"00000000000000&0000000000000000q3wwww3q0013wwww310113wwww31111133331111111111111"},
			{"00000000000060000000000000000000000000000q3wwww3q0113wwww31111133331111111111111"},
		},
		[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
		},
		[HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"01111111100222222220000000000000000000000008000000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000080000000000000000000000000000000000001110000111"},
			{"60000600000000000000000000000000800000000000000000000000000000000000001110000111"},
		},
		[HD_SUBCHUNKID.EXIT] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{
				"1111111111L000011112L009000000L011000020L012000000021100000000220T00T01111111111",
				"1111111111211110000L000000900L020000110L000000210L00000011200T00T022001111111111"
			},
		},
		[HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.IDOL] = {{"01000000100000I0000001BBBBBB10010000001011wwwwww1111wwwwww11113wwww3111111111111"}}
	},
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000000022222"},--1
			{"0000022222q111q"},--2
			{"0q000q100011122"},--3
			{"000q00001q22111"},--4
			{"00020q00201001q"},--5
			{"000000200102001"},--6
			{"02000q10q010710"},--7
			{"000200q01q01701"},--8
			{"000000000077777"},--9
			{"000007777711111"},--10
			{"0q000q100011177"},--0xb
			{"000q00001q77111"},--0xc
			{"00020q00201771q"},--0xd
			{"000000200102771"},--0xe
			{"02000q10q010717"},--0xf
			{"000200q01q71701"},--0x10
			{"00000000000T022"},--100
			{"000000000020T02"},--0x65
			{"0000000000220T0"},--0x66
			{"00000000000T077"},--0x67
			{"000000000070T07"},--0x68
			{"0000000000770T0"},--0x69 -- nice
		},
		[HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111122222000000"},
			{"211110222200000"},
			{"222220000000000"},
			{"111112111200000"},
		},
		[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000q1q0q111q"},
			{"00900q111q11111"},
			{"0090000100q212q"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD] = {
	-- unlockable coffin spawns at roomy == 11
	-- # TODO: When placing new roomcodes here, replace "v" tiles with "3"
	
	setRooms = {
		{
			-- prePath = false,
			subchunk_id = HD_SUBCHUNKID.WORM_CRYSKNIFE_LEFTSIDE,
			placement = {6, 1},
			roomcodes = {
				{"0000000dd00011111110011333333w013wwwwwww013wwwwwww011cwwwwww00111111110000000000"}
				-- {"0000000dd00011111110011333333w013wwwwwww013wwwwwww011wwwwwww00111111110000000000"} -- without crystal skull spawn
			}
		},
		{
			-- prePath = false,
			subchunk_id = HD_SUBCHUNKID.WORM_CRYSKNIFE_RIGHTSIDE,
			placement = {6, 2},
			roomcodes = {
				{"0dd00000000111111100w333333110wwwwwww310wwwwwww310wwwwwww11011111111000000000000"}
			}
		}
	},
	rooms = {
		[HD_SUBCHUNKID.SIDE] = {
			{"0dd0000dd02d0dddd0d20ddd00ddd02d0dddd0d20ddd00ddd000dddddd0011d0000d111111001111"},
		},
		[HD_SUBCHUNKID.PATH] = {
			{"000000000000000000000002001000000000000000020020001s000000s111ssssss111111111111"},
		},
		[HD_SUBCHUNKID.PATH_DROP] = {
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{
				"00000100000110011111011100011001100001100110001110011110011000001000001110101111",
				"00000000010110011111011100011001100001100110001110011110011000001000001110101111"
			},
		},
		[HD_SUBCHUNKID.PATH_NOTOP] = {
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{
				"00000100000110011111011100011001100001100110001110011110011000001000001110101111",
				"00000000010110011111011100011001100001100110001110011110011000001000001110101111"
			},
		},
		[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{
				"00000100000110011111011100011001100001100110001110011110011000001000001110101111",
				"00000000010110011111011100011001100001100110001110011110011000001000001110101111"
			},
		},
		[HD_SUBCHUNKID.ENTRANCE] = {
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"11111111112222222222000000000000000000000008000000000000000000000000002021111120"},
		},
		[HD_SUBCHUNKID.EXIT] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
		},
	},
	
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
}
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES] = {
	rooms = {
		[HD_SUBCHUNKID.SIDE] = {
			{"20000000020000000000000000000000000000000000000000000000000000000000002000000002"},
			{"10000000001000000000111000000022201100000000220100000000010000000001110000000222"},
			{"00000000010000000001000000011100001102220010220000001000000011100000002220000000"},
			{"00000000000002112000000111100000f1111f000001111000f00211200f00021120000000000000"},
			{"0000000000000000000000220022000011ff11000011001200202100120220210012020002002000"},
			{"0jiiiiiij00jij00jij0jjii0jiij0000000jij0jjiij0iij00jiij0jijj0jiij000000jjiiiiijj"},
			{"0jiiiiiij00jij00jij00jii0jiijj0jij0000000jij0jiijj0jij0jiij000000jiij00jjiiiiijj"},
			{"011iiii110000jjjj0000000ii00000000jj00000000ii00000000jj00000000ii00000002222000"},
		},
	-- 	[HD_SUBCHUNKID.PATH] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
	-- 		{""},
	-- 	},
		[HD_SUBCHUNKID.ENTRANCE] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111111111",
				"00000000000000000000000000000000000000000080000000000000000000000000001111111111"
			},
		},
		[HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000000011111110",
				"00000000000000000000000000000000000000000080000000000000000000000000000011111110"
			},
		},
		[HD_SUBCHUNKID.EXIT] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[HD_SUBCHUNKID.EXIT_NOTOP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[HD_SUBCHUNKID.IDOL] = {{"00000000000000I000000000--00000000000000000000000000000000000000ss00000000110000"}},
		[HD_SUBCHUNKID.ALTAR] = {{"000000000000000000000000000000000000000000000000000000xx000002211112201111111111"}},
		[HD_SUBCHUNKID.VAULT] = {{
			--"02222222202111111112211|00011221100001122110EE0112211000011221111111120222222220"
			"02222222202000000002200|00000220000000022000000002200000000220000000020222222220" -- S2 sync
		}},
	},
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"111110000000000"},
			{"000001111100000"},
			{"000000000011111"},
			{"000002020010100"},
			{"000000202001010"},
			{"000000020200101"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000222021112"},
			{"000002010000110"},
			{"000000010201100"},
		},
		[HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"000000000011111"},
			{"000001111122222"},
			{"111112222200000"},
			{"0jij00jij00jij0"},
		},
		[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON] = {
	-- chunkRules = {
	-- 	rooms = {
	-- 		[HD_SUBCHUNKID.SIDE] = function()
	-- 			-- # TODO
	-- 			-- if (?) 3; else 1 or 2;
	-- 			-- hardcoded chance: 1/11 to force 4
	-- 		end,
	-- 	},
	-- },
	rooms = {
		[HD_SUBCHUNKID.SIDE] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
			{"00000000000000110000000022000010001100011000110001100000000120~0000~021111111111"},
			{ -- Alien Lord
				"0000000000000000000000111111000011X000000011000L0000111111000~111111~01111111111",
				"0000000000000000000000111111000000X0110000L000110000111111000~111111~01111111111"
			},
			-- Zoo
			{"11110011110000000000010:00:01001111111100000000000m10:00:01m01111111101111111111"},
		},
		[HD_SUBCHUNKID.PATH] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
		},
		[HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000002200000000000000000022000000000000001111001111"},
		},
		[HD_SUBCHUNKID.PATH_NOTOP] = {
			{"000000000000000000000000000000000000000000000000000000mm000000000000001111111111"},
			{"0000000000000000000000000000000000~~0000000011000000001100000~001100~01111111111"},
		},
		[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"0000000000000000000000000000000000~~00000000110000000000000000~0000~001112002111"},
			{"000000000000000000000000000000000000000000000000000000mm000000000000001112002111"},
		},
		[HD_SUBCHUNKID.ENTRANCE] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"}
		},
		[HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"000000000000000000000000000000000000000000000000000001mm100000219012001111111111"},
			{"000000000000000000000000000000000000000000000000000001mm100000210912001111111111"},
			{"0000000000000000000000000000000000~000000011111000011000110000009000001111111111"},
			{"00000000000000000000000000000000000~00000001111100001100011000000900001111111111"},
		},
		[HD_SUBCHUNKID.EXIT] = {
			{"01000001000z00000z00000000000000000000000011011000011090110001111111001111111111"},
			{"001000001000z00000z0000000000000000000000001101100001109011000111111101111111111"},
		},
		[HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"000000000000110011000010009100001111110000z0000z000000000000mm000000mm1111001111"},
			{"000000000000110011000019000100001111110000z0000z000000000000mm000000mm1111001111"},
		},
		-- # TODO: Alien Queen generation method
		[HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN] = {
			{
				"110000011010000000100000Q000000L00000L000100000100L110*011L011110111101111111111",
				"0110000011010000000100000Q000000L00000L000100000100L110*011L01111011111111111111",
				"1100000011100000001100000Q00110LL000001101111100010000010*0111000110111111001111",
				"110000001111000000011100Q000001100000LL0100011111010*010000011011000111111001111",
			},
		},
	},
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000001000010000"},
			{"000000000100001"},
			{"000000010000100"},
			{"000000000000000"},
		},
		[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.TEMPLE] = {
	-- TODO: Replace all "r" tiles with "("

	-- rooms = {
	-- [HD_SUBCHUNKID.SIDE] = {
	-- 	{""},
	-- },
	-- 	[HD_SUBCHUNKID.PATH] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.ENTRANCE] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.ENTRANCE_DROP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.EXIT] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.EXIT_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.IDOL] = {{""}},
	-- 	[HD_SUBCHUNKID.ALTAR] = {{""}}
	-- },
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
	-- obstacleBlocks = {
	-- 	[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			-- {""},
	-- 	},
	-- 	[HD_OBSTACLEBLOCK.AIR.tilename] = {
			-- {""},
	-- 	},
	-- 	[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			-- {""},
	-- 	},
	-- },
}
HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD] = {
	setRooms = {
		{
			subchunk_id = HD_SUBCHUNKID.COG_BOTD_LEFTSIDE,
			placement = {3, 2},
			-- # TODO: alter this roomcode's altar (HAHHHH)
		roomcodes = {{"00000111110000011000000001100000Y00110001111111000000001100#00Y001100A1111111111"}}
		},
		{
			subchunk_id = HD_SUBCHUNKID.COG_BOTD_RIGHTSIDE,
			placement = {3, 3},
			roomcodes = {{"111110000000011000000001100Y000001111111000110000000011000000001100Y001111111111"}}
		}
	},
	-- rooms = {
	-- [HD_SUBCHUNKID.SIDE] = {
	-- 	{""},
	-- },
	-- 	[HD_SUBCHUNKID.PATH] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.ENTRANCE] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.ENTRANCE_DROP] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.EXIT] = {
	-- 		{""},
	-- 	},
	-- 	[HD_SUBCHUNKID.EXIT_NOTOP] = {
	-- 		{""},
	-- 	},
	-- },
	-- coffin_unlockable = {
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {

	-- 		}
	-- 	},
	-- },
	-- obstacleBlocks = {
	-- 	[HD_OBSTACLEBLOCK.GROUND.tilename] = {
			-- {""},
	-- 	},
	-- 	[HD_OBSTACLEBLOCK.AIR.tilename] = {
			-- {""},
	-- 	},
	-- 	[HD_OBSTACLEBLOCK.DOOR.tilename] = {
			-- {""},
	-- 	},
	-- },
}
HD_ROOMOBJECT.WORLDS[THEME.OLMEC] = {
	-- setRooms = {
	-- 	-- 1
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.PATH,
	-- 		placement = {1, 1},
	-- 		roomcodes = {{""},}
	-- 	},
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.PATH,
	-- 		placement = {1, 2},
	-- 		roomcodes = {{""},}
	-- 	},
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.PATH,
	-- 		placement = {1, 3},
	-- 		roomcodes = {{""},}
	-- 	},
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.PATH,
	-- 		placement = {1, 4},
	-- 		roomcodes = {{""},}
	-- 	},

	-- },
	-- coffin_unlockable = {
	-- 	-- Spawn steps:
	-- 		-- levelw, _ = get_levelsize()
	-- 		-- structx = 1
	-- 		-- if (math.random(2) == 2) then structx = levelw end
	-- 		-- spawn 143 at 1, structx
	-- 	{
	-- 		subchunk_id = HD_SUBCHUNKID.COFFIN_UNLOCKABLE,
	-- 		roomcodes = {
	-- 			{
	-- 				"00000100000E110111E001100001100E100001E00110g00110001111110000000000000000000000",
	-- 				"00001000000E111011E001100001100E100001E00110g00110001111110000000000000000000000"
	-- 			}
	-- 		}
	-- 	}
	-- },
	obstacleBlocks = {
		[HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"0EEE02111202220"},
			{"0000E0EEE121111"},
			{"E00001EEE011112"},
			{"1EE001111212200"},
			{"0EEE12111100221"},
			{"21112EEEEE11111"},
		},
	},
}

HD_COLLISIONTYPE = {
	AIR_TILE_1 = 1,
	AIR_TILE_2 = 2,
	FLOORTRAP = 3,
	FLOORTRAP_TALL = 4,
	GIANT_FROG = 5,
	GIANT_SPIDER = 6,
}

HD_DANGERTYPE = {
	CRITTER = 1,
	ENEMY = 2,
	FLOORTRAP = 3,
	FLOORTRAP_TALL = 4
}
HD_LIQUIDSPAWN = {
	PIRANHA = 1,
	MAGMAMAN = 2
}
HD_REMOVEINVENTORY = {
	SNAIL = {
		inventory_ownertype = ENT_TYPE.MONS_HERMITCRAB,
		inventory_entities = {
			ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
			ENT_TYPE.ACTIVEFLOOR_POWDERKEG,
			ENT_TYPE.ITEM_CRATE,
			ENT_TYPE.ITEM_CHEST
		}
	},
	SCORPIONFLY = {
		inventory_ownertype = ENT_TYPE.MONS_IMP,
		inventory_entities = {
			ENT_TYPE.ITEM_LAVAPOT
		}
	}
}
HD_REPLACE = {
	EGGSAC = 1
}
HD_KILL_ON = {
	STANDING = 1,
	STANDING_OUTOFWATER = 2
}

-- # TODO: Revise into HD_ABILITIES:
	-- HD_ABILITY_STATE = {
		-- IDLE = 1,
		-- AGRO = 2,
	-- }
	-- skin = nil,
	-- ability_uids = {
		-- master = nil,
		-- idle = nil,
		-- agro = nil
	-- },
	-- ability_state = 1
HD_BEHAVIOR = {
	-- IDEAS:
		-- Disable monster attacks.
			-- monster = get_entity():as_chasingmonster
			-- monster.chased_target_uid = 0
	OLMEC_SHOT = {
		velocityx = nil,
		velocityy = nil,
		velocity_settimer = 25
	},
	-- CRITTER_FROG = {
		-- jump_timeout = 70
		-- ai_timeout = 40
	-- },
	SCORPIONFLY = {
		-- abilities = {
			-- # TODO: replace with Imp
				-- Avoid using for agro distance since imps without lavapots immediately agro on the player regardless of distance
				-- set_timeout() to remove all lavapots from imps in onlevel_remove_mounts()
			-- if killed immediately, bat_uid still exists.
			-- # TOTEST: see if abilities can still be killed by the camera flash
			bat_uid = nil,--agro = { bat_uid = nil },
			-- idle = { mosquito_uid = nil }
		-- },
		agro = false -- upon agro, enable bat ability
		-- once taken damage, remove abilities
	}
	-- HAWKMAN = {
		-- caveman_uid = nil, -- Not sure if we want caveman or shopkeeperclone for this
		-- agro = false -- upon agro, enable 
	-- },
	-- GREENKNIGHT = {
		-- master = {uid = nil(caveman)},
		-- idle = {uid = nil(olmitebodyarmor), }, -- tospawn = olmitebodyarmor
			-- reskin olmitebodyarmor as greenknight
			-- Initialize caveman as invisible, olmite as visible.
			-- Once taken damage, remove abilities. If all abilities are removed, make caveman visible
			-- # TOTEST: Determine if there's better alternatives for whipping and stopping(without spike shoes) immunity
				-- pangxie
		-- uncheck 15 and uncheck 31.
	-- },
	-- BLACKKNIGHT = {
		-- shopkeeperclone_uid = nil,
		-- agro = true -- upon dropping shield, disable shopkeeperclone ability
	-- },
	-- reskin: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\MONSTERS\monstersbig4.png
	-- MAMMOTH = {
		-- cobra_uid = nil
			-- dim: {2, 2} -- set the dimensions to the same as the giantfly or else movement and collision will look weird
			-- hitbox: {0.550, 0.705} -- based off pangxie
	-- },
	-- reskin: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\MONSTERS\monstersbig2.png
	-- GIANTFROG = {
		-- frog_uid = nil
			-- dim: {2, 2} -- set the dimensions to the same as the giantfly or else movement and collision will look weird
			-- hitbox: { ?, ? }
	-- },
	-- reskin: C:\SDD\Steam\steamapps\common\Spelunky\Data\Textures\unpacked\MONSTERS\monstersbig5.png
	-- ALIEN_LORD = {
		-- cobra_uid = nil
	-- }
	-- ALIEN_TANK = {
		-- https://github.com/spelunky-fyi/overlunky/blob/main/docs/script-api.md#olmeccannon
	-- }
}
-- Currently supported db modifications:
	-- onlevel_dangers_modifications()
		-- Supported Variables:
			-- dim = { w, h }
				-- sets height and width
				-- # TODO: Split into two variables: One that gets set in onlevel_dangers_replace(), and one in onlevel_dangers_modifications.
					-- IDEA: dim_db and dim
			-- acceleration
			-- max_speed
			-- sprint_factor
			-- jump
			-- damage
			-- health
				-- sets EntityDB's life
			-- friction
			-- weight
			-- elasticity
		-- # TODO:
			-- blood_content
			-- draw_depth
	-- onlevel_dangers_replace
		-- Supported Variables:
			-- tospawn
				-- if set, determines the ENT_TYPE to spawn.
			-- toreplace
				-- if set, determines the ENT_TYPE to replace inside onlevel_dangers_replace.
			-- entitydb
				-- If set, determines the ENT_TYPE to apply EntityDB modifications to
	-- danger_applydb
		-- Supported Variables:
			-- dim = { w, h }
				-- sets height and width
				-- # TODO: Split into two variables: One that gets set in onlevel_dangers_replace(), and one in onlevel_dangers_modifications.
					-- IDEA: dim_db and dim
			-- color = { r, g, b }
				-- # TODO: Add alpha channel support
			-- hitbox = { w, h }
				-- `w` for hitboxx, `y` for hitboxy.
			-- flag_stunnable
			-- flag_collideswalls
			-- flag_nogravity
			-- flag_passes_through_objects
				-- sets flag if true, clears if false
	-- create_danger
		-- Supported Variables:
			-- dangertype
				-- Determines multiple factors required for certain dangers, such as spawn_entity_over().
			-- collisiontype
				-- Determines collision detection on creation of an HD_ENT. collision detection.
	-- onframe_manage_dangers
		-- Supported Variables:
			-- kill_on_standing = 
				-- HD_KILL_ON.STANDING
					-- Once standing on a surface, kill it.
				-- HD_KILL_ON.STANDING_OUTOFWATER
					-- Once standing on a surface and not submerged, kill it.
			-- itemdrop = { item = {HD_ENT, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
			-- treasuredrop = { item = {HD_ENT, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
HD_ENT = {}
HD_ENT.WEBNEST = {
	tospawn = ENT_TYPE.ITEM_REDLANTERN
}
HD_ENT.POWDERKEG = {
	tospawn = ENT_TYPE.ACTIVEFLOOR_POWDERKEG
}
HD_ENT.PUSHBLOCK = {
	tospawn = ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK
}
HD_ENT.ITEM_IDOL = {
	tospawn = ENT_TYPE.ITEM_IDOL
}
HD_ENT.ITEM_CRYSTALSKULL = {
	tospawn = ENT_TYPE.ITEM_MADAMETUSK_IDOL
}
ITEM_PICKUP_SPRINGSHOES = {
	tospawn = ENT_TYPE.ITEM_PICKUP_SPRINGSHOES
}
HD_ENT.ITEM_FREEZERAY = {
	tospawn = ENT_TYPE.ITEM_FREEZERAY
}
HD_ENT.ITEM_SAPPHIRE = {
	tospawn = ENT_TYPE.ITEM_SAPPHIRE
}
HD_ENT.FROG = {
	tospawn = ENT_TYPE.MONS_FROG,
	toreplace = ENT_TYPE.MONS_WITCHDOCTOR,--MOSQUITO,
	dangertype = HD_DANGERTYPE.ENEMY
}
HD_ENT.FIREFROG = {
	tospawn = ENT_TYPE.MONS_FIREFROG,
	-- toreplace = ENT_TYPE.MONS_MOSQUITO,
	dangertype = HD_DANGERTYPE.ENEMY
}
HD_ENT.SNAIL = {
	tospawn = ENT_TYPE.MONS_HERMITCRAB,
	toreplace = ENT_TYPE.MONS_MOSQUITO,--WITCHDOCTOR,
	entitydb = ENT_TYPE.MONS_HERMITCRAB,
	dangertype = HD_DANGERTYPE.ENEMY,
	health_db = 1,
	leaves_corpse_behind = false,-- removecorpse = true,
	removeinventory = HD_REMOVEINVENTORY.SNAIL,
}
HD_ENT.PIRANHA = {
	tospawn = ENT_TYPE.MONS_TADPOLE,
	dangertype = HD_DANGERTYPE.ENEMY,
	liquidspawn = HD_LIQUIDSPAWN.PIRANHA,
	-- entitydb = ENT_TYPE.MONS_TADPOLE,
	-- sprint_factor = -1,
	-- max_speed = -1,
	-- acceleration = -1,
	kill_on_standing = HD_KILL_ON.STANDING_OUTOFWATER
}
HD_ENT.WORMBABY = {
	tospawn = ENT_TYPE.MONS_MOLE,
	entitydb = ENT_TYPE.MONS_MOLE,
	dangertype = HD_DANGERTYPE.ENEMY,
	health_db = 1,
	leaves_corpse_behind = false,-- removecorpse = true
}
HD_ENT.EGGSAC = {
	tospawn = ENT_TYPE.ITEM_EGGSAC,
	toreplace = ENT_TYPE.MONS_JUMPDOG,
	dangertype = HD_DANGERTYPE.FLOORTRAP,
	collisiontype = HD_COLLISIONTYPE.FLOORTRAP,
	replaceoffspring = HD_REPLACE.EGGSAC
}
HD_ENT.TRAP_TIKI = {
	tospawn = ENT_TYPE.FLOOR_TOTEM_TRAP,
	toreplace = ENT_TYPE.ITEM_SNAP_TRAP,
	entitydb = ENT_TYPE.ITEM_TOTEM_SPEAR,
	dangertype = HD_DANGERTYPE.FLOORTRAP_TALL,
	collisiontype = HD_COLLISIONTYPE.FLOORTRAP_TALL,
	damage = 4
	-- # TODO: Tikitrap flames on dark level. If they spawn, move each flame down 0.5.
}
HD_ENT.CRITTER_RAT = {
	dangertype = HD_DANGERTYPE.CRITTER,
	entitydb = ENT_TYPE.MONS_CRITTERDUNGBEETLE,
	max_speed = 0.05,
	acceleration = 0.05
}
HD_ENT.CRITTER_FROG = { -- # TODO: critter jump/idle behavior
	tospawn = ENT_TYPE.MONS_CRITTERLOCUST,
	toreplace = ENT_TYPE.MONS_CRITTERBUTTERFLY,
	dangertype = HD_DANGERTYPE.CRITTER,
	entitydb = ENT_TYPE.MONS_CRITTERCRAB
	-- # TODO: Make jumping script, adjust movement EntityDB properties
	-- behavior = HD_BEHAVIOR.CRITTER_FROG,
}
HD_ENT.SPIDER = {
	tospawn = ENT_TYPE.MONS_SPIDER,
	toreplace = ENT_TYPE.MONS_SPIDER,
	dangertype = HD_DANGERTYPE.ENEMY
}
HD_ENT.HANGSPIDER = {
	tospawn = ENT_TYPE.MONS_HANGSPIDER,
	-- toreplace = ENT_TYPE.MONS_SPIDER,
	dangertype = HD_DANGERTYPE.ENEMY
}
HD_ENT.GIANTSPIDER = {
	tospawn = ENT_TYPE.MONS_GIANTSPIDER,
	-- toreplace = ENT_TYPE.MONS_SPIDER,
	dangertype = HD_DANGERTYPE.ENEMY,
	collisiontype = HD_COLLISIONTYPE.GIANT_SPIDER,
	offset_spawn = {0.5, 0}
}
HD_ENT.BOULDER = {
	dangertype = HD_DANGERTYPE.ENEMY,--HD_DANGERTYPE.FLOORTRAP,
	entitydb = ENT_TYPE.ACTIVEFLOOR_BOULDER
}
HD_ENT.SCORPIONFLY = {
	tospawn = ENT_TYPE.MONS_SCORPION,
	toreplace = ENT_TYPE.MONS_CATMUMMY,--SPIDER,
	dangertype = HD_DANGERTYPE.ENEMY,
	behavior = HD_BEHAVIOR.SCORPIONFLY,
	color = { 0.902, 0.176, 0.176 },
	removeinventory = HD_REMOVEINVENTORY.SCORPIONFLY
}
-- Devil Behavior:
	-- when the octopi is in it's run state, use get_entities_overlapping() to detect the block {ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK} it runs into.
		-- then kill block, set octopi stuntimer.
-- DEVIL = {
	-- tospawn = ENT_TYPE.MONS_OCTOPUS,
	-- toreplace = ?,
	-- entitydb = ENT_TYPE.MONS_OCTOPUS,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- sprint_factor = 7.0
	-- max_speed = 7.0
-- },
-- MAMMOTH = { -- # TODO: Frozen Immunity: if set, set on frame `as_movable().frozen_timer = 0`
	-- tospawn = ENT_TYPE.MONS_GIANTFLY,
	-- toreplace = ?,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_GIANTFLY,
	-- behavior = HD_BEHAVIOR.MAMMOTH,
	-- health_db = 8,
	-- itemdrop = {
		-- item = {HD_ENT.ITEM_FREEZERAY},
		-- chance = 1.0
	-- },
	-- treasuredrop = {
		-- item = {HD_ENT.ITEM_SAPPHIRE},
		-- chance = 1.0
	-- }
-- },
-- HAWKMAN = {
	-- tospawn = ENT_TYPE.MONS_SHOPKEEPERCLONE, -- Maybe.
	-- toreplace = ENT_TYPE.MONS_CAVEMAN,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- behavior = HD_BEHAVIOR.HAWKMAN
-- },
-- GREENKNIGHT = {
	-- tospawn = ENT_TYPE.MONS_OLMITE_BODYARMORED,
	-- toreplace = ENT_TYPE.MONS_CAVEMAN,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_OLMITE_BODYARMORED,
	-- behavior = HD_BEHAVIOR.GREENKNIGHT,
	-- stompdamage = false, -- (?)
-- },
-- NOTE: Shopkeeperclones are immune to whip damage, while the black knight in HD wasn't.
	-- May be able to override this by syncing the stun of a duct-taped entity (ie, if caveman is stunned, shopkeeperclone.stun_timer = 10)
		-- Might as well use a caveman for the master, considering that in HD when the blackknight drops his shield, he behaves like a green knight (so, a caveman)
-- BLACKKNIGHT = {
	-- tospawn = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- behavior = HD_BEHAVIOR.BLACKKNIGHT,
	-- health = 3,
	-- giveitem = ENT_TYPE.ITEM_METAL_SHIELD
-- },
-- SUCCUBUS = {
	-- master: ENT_TYPE.MONS_MONKEY,
	-- Skin: {ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_HAMSTER}
	-- abilities.agro = `master uid`
-- },
-- NOTE: ANUBIS II should be a reskin of MONS_ANUBIS, detecting the scepter shots and spawning red skeletons instead.
-- ANUBIS2 = {
	-- master: ENT_TYPE.MONS_ANUBIS,
	-- abilities.agro = `master uid`
-- }
-- 
-- # TODO: Succubus
	-- Once at least 1 MASK.PLAYER is within a 2 block radius(? TOTEST: Investigate in HD.), change skin and set ability_state to agro.
	-- cycle through players and if the player has the agro ability in its inventory(?), track it and deal one damage once it leaves.
	-- Once :as_monkey() method is merged into the main branch, set jump_timer to 0 on every frame.
	-- Once :as_leprechaun() method is merged into the main branch, set jump_timer to 0 on every frame.
		-- Upside to using leprechaun is a good skin option
		-- downside is no jump_timer and preventing the gold stealing and teleporting abilities
	-- Once :as_pet() method is merged into the main branch, half its yell_counter field to 299 if it's higher than 300.
-- NOTES:
	--She disguises herself as a Damsel to lure the Spelunker, then ambushes them once they are in range.
	-- If she manages to pounce on the Spelunker, she will cling to them like a Monkey and take one hit point when she jumps off.
	-- The Succubus mimics the appearance of the currently selected damsel type, disguising herself as a female, male, dog or sloth. Regardless of the disguise, she always transforms into a demonic woman upon attacking - there are no male, canine or sloth Succubus models.
	-- The Succubus' attack is accompanied by a loud "scare chord" sound effect that persists until she is killed.  Her most dangerous ability is to stun and push the player when she jumps off (like a monkey), and she can continue attacking the player while they are unconscious.

-- For HD_ENTs that include references to other HD_ENTs:
HD_ENT.GIANTFROG = {
	tospawn = ENT_TYPE.MONS_OCTOPUS,
	-- toreplace = ENT_TYPE.MONS_OCTOPUS,
	entitydb = ENT_TYPE.MONS_OCTOPUS,
	dangertype = HD_DANGERTYPE.ENEMY,
	collisiontype = HD_COLLISIONTYPE.GIANT_FROG,
	-- GIANTSPIDER = 6, -- ?????????
	health_db = 8,
	sprint_factor = 0,
	max_speed = 0.01,
	jump = 0.2,
	dim = {2.5, 2.5},
	offset_spawn = {0.5, 0},
	leaves_corpse_behind = false,--removecorpse = true,
	hitbox = {
		0.64,
		0.8
	},
	flags = {
		-- [ENT_FLAG.STUNNABLE] = false,
		{},
		{12}
	},
	itemdrop = {
		item = {HD_ENT.ITEM_PICKUP_SPRINGSHOES},--ENT_TYPE.ITEM_PICKUP_SPRINGSHOES},
		chance = 0.15 -- 15% (1/6.7)
	},
	treasuredrop = {
		item = {HD_ENT.ITEM_SAPPHIRE},
		chance = 0.50
	}
}
-- # TODO: Replace with regular frog
	-- Use a giant fly for tospawn
	-- Modify the behavior system to specify which ability uid is the visible one (make all other abilities invisible)
		-- Furthermore, modify it so you can allow scenarios like the greenknight happen;
			-- once taken damage, remove abilities. If all abilities are removed, make caveman visible

-- GIANTFROG = { -- PROBLEM: MONS_GIANTFLY eats frogs when near them. Determine potential alternative.
	-- tospawn = ENT_TYPE.MONS_GIANTFLY,
	-- toreplace = ENT_TYPE.MONS_GIANTFLY,
	-- dangertype = HD_DANGERTYPE.ENEMY,
	-- health = 8,
	-- entitydb = ENT_TYPE.MONS_GIANTFLY,
	-- behavior = HD_BEHAVIOR.GIANTFROG,
	-- dim = {2.5, 2.5},
	-- itemdrop = {
		-- item = {ENT_TYPE.ITEM_PICKUP_SPRINGSHOES},
		-- chance = 0.15 -- 15% (1/6.7)
	-- }
	-- treasuredrop = {
		-- item = {ENT_TYPE.ITEM_SAPPHIRE}, -- # TODO: Determine which gems.
		-- chance = 1.0
	-- }
-- },
HD_ENT.OLDBITEY = {
	tospawn = ENT_TYPE.MONS_GIANTFISH,
	dangertype = HD_DANGERTYPE.ENEMY,
	entitydb = ENT_TYPE.MONS_GIANTFISH,
	collisiontype = HD_COLLISIONTYPE.GIANT_FISH,
	itemdrop = {
		item = {HD_ENT.ITEM_IDOL},--ENT_TYPE.ITEM_IDOL},
		chance = 1
	}
}
HD_ENT.OLMEC_SHOT = {
	tospawn = ENT_TYPE.ITEM_TIAMAT_SHOT,
	dangertype = HD_DANGERTYPE.ENEMY,
	kill_on_standing = HD_KILL_ON.STANDING,
	behavior = HD_BEHAVIOR.OLMEC_SHOT,
	itemdrop = {
		item = {
			HD_ENT.FROG,--ENT_TYPE.MONS_FROG,
			HD_ENT.FIREFROG,--ENT_TYPE.MONS_FIREFROG,
			-- HD_ENT.,--ENT_TYPE.MONS_MONKEY,
			-- HD_ENT.,--ENT_TYPE.MONS_SCORPION,
			-- HD_ENT.,--ENT_TYPE.MONS_SNAKE,
			-- HD_ENT.,--ENT_TYPE.MONS_BAT
		},
		chance = 1.0
	},
	-- Enable "collides walls", uncheck "No Gravity", uncheck "Passes through objects".
	flags = {
		{13},
		{4, 10}
	},
}

TRANSITION_CRITTERS = {
	[THEME.DWELLING] = {
		entity = HD_ENT.CRITTER_RAT
	},
	[THEME.JUNGLE] = {
		entity = HD_ENT.CRITTER_FROG
	},
	-- Confirm if this is in HD level transitions
	-- [THEME.EGGPLANT_WORLD] = {
		-- entity = HD_ENT.CRITTER_MAGGOT
	-- },
	-- [THEME.ICE_CAVES] = {
		-- entity = HD_ENT.CRITTER_PENGUIN
	-- },
	-- [THEME.TEMPLE] = {
		-- entity = HD_ENT.CRITTER_LOCUST
	-- },
}

			-- parameters:
				-- {{HD_ENT, true}, {HD_ENT, false}, {HD_ENT, true}...}
					-- HD Enemy type
					-- true for chance to spawn as rare variants, if exists
LEVEL_DANGERS = {
	-- [THEME.DWELLING] = {
		-- dangers = {
			-- {
				-- entity = HD_ENT.SCORPIONFLY--SPIDER,
				-- -- variation = {
					-- -- entities = {HD_ENT.SPIDER, HD_ENT.HANGSPIDER, HD_ENT.GIANTSPIDER},
					-- -- chances = {0.5, 0.85}
				-- -- }
			-- },
			-- -- {
				-- -- entity = HD_ENT.HANGSPIDER
			-- -- },
			-- -- {
				-- -- entity = HD_ENT.GIANTSPIDER
			-- -- },
			-- {
				-- entity = HD_ENT.CRITTER_RAT
			-- }
		-- }
	-- },
	[THEME.DWELLING] = {
		dangers = {
			{
				entity = HD_ENT.SPIDER,
				variation = {
					entities = {HD_ENT.HANGSPIDER, HD_ENT.GIANTSPIDER},
					chances = {0.5, 0.85}
				}
			},
			{
				entity = HD_ENT.HANGSPIDER
			},
			{
				entity = HD_ENT.GIANTSPIDER
			},
			{
				entity = HD_ENT.CRITTER_RAT
			}
		}
	},
	[THEME.JUNGLE] = {
		dangers = {
			{
				entity = HD_ENT.FROG,
				variation = {
					entities = {HD_ENT.FIREFROG, HD_ENT.GIANTFROG},
					chances = {0.75, 0.85}
				}
			},
			{
				entity = HD_ENT.FIREFROG
			},
			{
				entity = HD_ENT.GIANTFROG
			},
			{
				entity = HD_ENT.TRAP_TIKI
			},
			{
				entity = HD_ENT.SNAIL
			},
			{
				entity = HD_ENT.PIRANHA
			},
			{
				entity = HD_ENT.CRITTER_FROG
			}
		}
	},
	[THEME.EGGPLANT_WORLD] = {
		dangers = {
			{
				entity = HD_ENT.EGGSAC
			},
			{
				entity = HD_ENT.WORMBABY
			}
		}
	},
	[THEME.TEMPLE] = {
		dangers = {
			{
				entity = HD_ENT.SCORPIONFLY
			}
		}
	}
}
-- TIKITRAP_TEMPLE.toreplace = ENT_TYPE.MONS_CATMUMMY
-- TIKITRAP_TEMPLE.tospawn = ENT_TYPE.FLOOR_TOTEM_TRAP
-- ARROWTRAP - adapt code from trap randomizer
-- HAWKMAN_TEMPLE
-- LEVEL_DANGERS[THEME.TEMPLE] = {
	-- dangers = {
	-- }
-- }
-- TIKITRAP_COG.toreplace = ENT_TYPE.MONS_LEPRECHAUN
-- TIKITRAP_COG.tospawn = ENT_TYPE.FLOOR_LION_TRAP
-- ARROWTRAP - adapt code from trap randomizer
-- LEVEL_DANGERS[THEME.CITY_OF_GOLD] = {
	-- dangers = {
	-- }
-- }

-- # TODO: For development of the new scripted level gen system, move tables/variables into here from init_onlevel() as needed.
function init_posttile_door()
	global_levelassembly = {}
end

-- post_tile-sensitive ON.START initializations
	-- Since ON.START runs on the first ON.SCREEN of a run, it runs after post_tile runs.
	-- Run this in post_tile to circumvent the issue.
function init_posttile_onstart()
	if POSTTILE_STARTBOOL == false then -- determine if you need to set new things
		POSTTILE_STARTBOOL = true
		global_feelings = TableCopy(HD_FEELING)
		-- other stuff
	end
end

function init_onlevel()
	wheel_items = {}
	idoltrap_blocks = {}
	-- global_levelassembly = nil
	danger_tracker = {}
	idoltrap_timeout = IDOLTRAP_JUNGLE_ACTIVATETIME
	IDOL_X = nil
	IDOL_Y = nil
	IDOL_UID = nil
	BOULDER_UID = nil
	BOULDER_SX = nil
	BOULDER_SY = nil
	BOULDER_SX2 = nil
	BOULDER_SY2 = nil
	BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
	BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
	BOULDER_DEBUG_PLAYERTOUCH = false
	TONGUE_UID = nil
	TONGUE_BG_UID = nil
	DOOR_EXIT_TO_HAUNTEDCASTLE_UID = nil
	DOOR_EXIT_TO_BLACKMARKET_UID = nil
	DOOR_ENDGAME_OLMEC_UID = nil

	DANGER_GHOST_UIDS = {}
	IDOLTRAP_TRIGGER = false
	
	
	OLMEC_ID = nil
	BOSS_STATE = nil
	TONGUE_STATE = nil
	TONGUE_STATECOMPLETE = false
	OLMEC_STATE = 0
	
	bookofdead_tick = 0
	wheel_speed = 0
	wheel_tick = WHEEL_SPINTIME
	acid_tick = ACID_POISONTIME
	tongue_tick = TONGUE_ACCEPTTIME
	-- bookofdead_tick_min = BOOKOFDEAD_TIC_LIMIT
	bookofdead_frames_index = 1

end

-- DANGER MODIFICATIONS - INITIALIZATION
-- # TODO: Replace these with lists that get applied to specific entities within the level.
	-- For example: Detect on.frame for moles. If said mole's uid doesn't already exist in the removecorpse list, add it. Elseif it is dead, kill it, then then remove its uid from the list.
-- initialize per-level enemy databases
function onlevel_dangers_init()
	if LEVEL_DANGERS[state.theme] then
		global_dangers = map(LEVEL_DANGERS[state.theme].dangers, function(danger) return danger.entity end)
		if feeling_check("FLOODED") == true then
			oldbitey = TableCopy(HD_ENT.OLDBITEY)
			if feeling_check("RESTLESS") == true then
				oldbitey.itemdrop.item = {HD_ENT.ITEM_CRYSTALSKULL}
			end
			table.insert(global_dangers, oldbitey) 
		end
	end
end

function bubbles()
	local fx = get_entities_by_type(ENT_TYPE.FX_WATER_SURFACE)
	for i,v in ipairs(fx) do
		local x, y, l = get_position(v)
		if math.random() < 0.003 then
			spawn_entity(ENT_TYPE.ITEM_ACIDBUBBLE, x, y, l, 0, 0)
		end
	end
end

 -- Trix wrote this
function replace(ent1, ent2, x_mod, y_mod)
	affected = get_entities_by_type(ent1)
	for i,ent in ipairs(affected) do

		ex, ey, el = get_position(ent)
		e = get_entity(ent):as_movable()

		s = spawn(ent2, ex, ey, el, 0, 0)
		se = get_entity(s):as_movable()
		se.velocityx = e.velocityx*x_mod
		se.velocityy = e.velocityy*y_mod

		move_entity(ent, 0, 0, 0, 0)-- kill_entity(ent)
	end
end

-- ha wrote this
-- # TOFIX: Items embedded with this can't get picked up.
	-- Break "3278409" up into setting/clearing specific flags.
	-- In testing, the mattock I embedded couldn't be picked up because it had ENT_FLAG.PASSES_THROUGH_OBJECTS enabled.
	
function embed(enum, uid)
	local uid_x, uid_y, uid_l = get_position(uid)
	local ents = get_entities_at(0, 0, uid_x, uid_y, uid_l, 0.1)
	if (#ents > 1) then return end

	local entitydb = get_type(enum)
	local previousdraw, previousflags = entitydb.draw_depth, entitydb.default_flags
	entitydb.draw_depth = 9
	entitydb.default_flags = 3278409 -- don't really need some flags for other things that dont explode, example is for jetpack
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.INVISIBLE)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.NO_GRAVITY)
	-- entitydb.default_flags = clr_flag(entitydb.default_flags, ENT_FLAG.COLLIDES_WALLS)

	local entity = get_entity(spawn_entity_over(enum, uid, 0, 0))
	entitydb.draw_depth = previousdraw
	entitydb.default_flags = previousflags
--   apply_entity_db(entity.uid)
  
--   message("Spawned " .. tostring(entity.uid))
	return 0;
end
-- Example:
-- register_option_button('button', "Attempt to embed a Jetpack", function()
  -- first_level_entity = get_entities()[1] -- probably a floor
  -- embed(ENT_TYPE.ITEM_JETPACK, first_level_entity)
-- end)

-- # TODO: Use this as a base for distributing embedded treasure(? if needed)
-- Malacath wrote this
-- Randomly distributes treasure in minewood_floor
-- set_post_tile_code_callback(function(x, y, layer)
    -- local rand = math.random(100)
    -- if rand > 65 then
        -- local ents = get_entities_overlapping(ENT_TYPE.FLOORSTYLED_MINEWOOD, 0, x - 0.45, y - 0.45, x + 0.45, y + 0.45, layer);
        -- if #ents == 1 then -- if not 1 then something else was spawned here already
            -- if rand > 95 then
                -- spawn_entity_over(ENT_TYPE.ITEM_JETPACK, ents[1], 0, 0);
            -- elseif rand > 80 then
                -- spawn_entity_over(ENT_TYPE.EMBED_GOLD_BIG, ents[1], 0, 0);
            -- else
                -- spawn_entity_over(ENT_TYPE.EMBED_GOLD, ents[1], 0, 0);
            -- end
        -- end
    -- end
-- end, "minewood_floor")


function teleport_mount(ent, x, y)
    if ent.overlay ~= nil then
        move_entity(ent.overlay.uid, x, y, 0, 0)
    else
        move_entity(ent.uid, x, y, 0, 0)
    end
    -- ent.more_flags = clr_flag(ent.more_flags, 16)
    set_camera_position(x, y)
end

function rotate(cx, cy, x, y, degrees)
	radians = degrees * (math.pi/180)
	rx = math.cos(radians) * (x - cx) - math.sin(radians) * (y - cy) + cx
	ry = math.sin(radians) * (x - cx) + math.cos(radians) * (y - cy) + cy
	result = {rx, ry}
	return result
end

function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function CompactList(list, prev_size)
	local j=0
	for i=1,prev_size do
		if list[i]~=nil then
			j=j+1
			list[j]=list[i]
		end
	end
	for i=j+1,prev_size do
		list[i]=nil
	end
	return list
end

function TableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function TableFirstKey(t)
  local count = 0
  for k,_ in pairs(t) do return k end
  return nil
end

function TableFirstValue(t)
  local count = 0
  for _,v in pairs(t) do return v end
  return nil
end

function TableRandomElement(tbl)
	local t = {}
	if #tbl == 0 then return nil end
	for _, v in ipairs(tbl) do
		t[#t+1] = v
	end
	return t[math.random(1, #t)]
end

function TableConcat(t1, t2)
	for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function map(tbl, f)
	local t = {}
	for k, v in ipairs(tbl) do
		t[k] = f(v)
	end
	return t
end

function TableCopy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[TableCopy(k, s)] = TableCopy(v, s) end
  return res
end

function setn(t,n)
	setmetatable(t,{__len=function() return n end})
end

-- translate levelrooms coordinates to the tile in the top-left corner in game coordinates
function locate_cornerpos_real(roomx, roomy)
	xmin, ymin, _, _ = get_bounds()
	tc_x = (roomx-1)*HD_ROOMOBJECT.DIM.w+(xmin+0.5)
	tc_y = (ymin-0.5) - ((roomy-1)*(HD_ROOMOBJECT.DIM.h))
	return tc_x, tc_y
end

-- -- translate levelrooms coordinates to the tile in the top-left corner in levelcode coordinates
-- function locate_cornerpos_levelassembly(roomx, roomy)
-- 	xmin, ymin = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
-- 	tc_x = (roomx-1)*HD_ROOMOBJECT.DIM.w+(xmin+0.5)
-- 	tc_y = (ymin-0.5) - ((roomy-1)*(HD_ROOMOBJECT.DIM.h))
-- 	return tc_x, tc_y
-- end

-- translate game coordinates to levelrooms coordinates
function locate_roompos_real(e_x, e_y)
	xmin, ymin, _, _ = get_bounds()
	roomx = math.ceil((e_x-(xmin+0.5))/HD_ROOMOBJECT.DIM.w)
	roomy = math.ceil(((ymin-0.5)-e_y)/HD_ROOMOBJECT.DIM.h)
	return roomx, roomy
end

-- translate levelcode coordinates to levelrooms coordinates
function locate_roompos_levelassembly(e_x, e_y)
	-- xmin, ymin, xmax, ymax = 1, 1, 4*10, 4*8
	roomx, roomy = math.ceil(e_x/HD_ROOMOBJECT.DIM.w), math.ceil(e_y/HD_ROOMOBJECT.DIM.h)
	return roomx, roomy
end

-- NOTE: Levels with irregular room sizes may lead to unintended return values.
-- For now, anything related to scripted level generation should use known constants instead of this.
function get_levelsize()
	xmin, ymin, xmax, ymax = get_bounds()
	levelw = math.ceil((xmax-xmin)/HD_ROOMOBJECT.DIM.w)
	levelh = math.ceil((ymin-ymax)/HD_ROOMOBJECT.DIM.h)
	return levelw, levelh
end

function get_unlock()
	-- # TODO: Boss win unlocks.
		-- Either move the following uncommented code into a dedicated method, or move this method to a place that works for a post-win screen
	-- unlockconditions_win = {}
	-- for unlock_name, unlock_properties in pairs(HD_UNLOCKS) do
		-- if unlock_properties.win ~= nil then
			-- unlockconditions_win[unlock_name] = unlock_properties
		-- end
	-- end
	unlock = nil
	
	if (
		detect_viable_unlock_area() == true and
		RUN_UNLOCK_AREA_CHANCE >= math.random()
	) then -- AREA_RAND* unlocks
		rand_pool = {"AREA_RAND1","AREA_RAND2","AREA_RAND3","AREA_RAND4"}
		coffin_rand_pool = {}
		chunkPool_rand_index = 1
		n = #rand_pool
		for rand_index = 1, #rand_pool, 1 do
			if HD_UNLOCKS[rand_pool[rand_index]].unlocked == true then
				rand_pool[rand_index] = nil
			end
		end
		rand_pool = CompactList(rand_pool, n)
		chunkPool_rand_index = math.random(1, #rand_pool)
		unlock = rand_pool[chunkPool_rand_index]
	else -- feeling/theme-based unlocks
		unlockconditions_feeling = {}
		unlockconditions_theme = {}
		for unlock_name, unlock_properties in pairs(HD_UNLOCKS) do
			if unlock_properties.feeling ~= nil then
				unlockconditions_feeling[unlock_name] = unlock_properties
			elseif unlock_properties.unlock_theme ~= nil then
				unlockconditions_theme[unlock_name] = unlock_properties
			end
		end
		
		for unlock_name, unlock_properties in pairs(unlockconditions_theme) do
			if unlock_properties.unlock_theme == state.theme then
				unlock = unlock_name
			end
		end
		for unlock_name, unlock_properties in pairs(unlockconditions_feeling) do
			if feeling_check(unlock_properties.feeling) == true then
				-- Probably won't be overridden by theme
				unlock = unlock_name
			end
		end
	end
	return unlock
end

-- function get_unlock_area()
-- 	rand_pool = {"AREA_RAND1","AREA_RAND2","AREA_RAND3","AREA_RAND4"}
-- 	coffin_rand_pool = {}
-- 	rand_index = 1
-- 	n = #rand_pool
-- 	for rand_index = 1, #rand_pool, 1 do
-- 		if HD_UNLOCKS[rand_pool[rand_index]].unlocked == true then
-- 			rand_pool[rand_index] = nil
-- 		end
-- 	end
-- 	rand_pool = CompactList(rand_pool, n)
-- 	rand_index = math.random(1, #rand_pool)
-- 	unlock = rand_pool[rand_index]
-- 	return unlock
-- end

-- # TODO: determining character unlock for coffin creation
-- function create_unlockcoffin(x, y, l)
-- 	coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
-- 	-- 193 + unlock_num = ENT_TYPE.CHAR_*
-- 	set_contents(coffin_uid, 193 + HD_UNLOCKS[unlock_name].unlock_id)
-- 	return coffin_uid
-- end

-- test if gold/gems automatically get placed into scripted tile generation or not
-- function gen_embedtreasures(uids_toembedin)
-- 	for _, uid_toembedin in ipairs(uids_toembedin) do
-- 		create_embedded(uid_toembedin)
-- 	end
-- end

function create_embedded(ent_toembedin, entity_type)
	if entity_type ~= ENT_TYPE.EMBED_GOLD and entity_type ~= ENT_TYPE.EMBED_GOLD_BIG then
		local entity_db = get_type(entity_type)
		local previous_draw, previous_flags = entity_db.draw_depth, entity_db.default_flags
		entity_db.draw_depth = 9
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.INVISIBLE)
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.NO_GRAVITY)
		entity_db.default_flags = clr_flag(entity_db.default_flags, ENT_FLAG.COLLIDES_WALLS)
		local entity = get_entity(spawn_entity_over(entity_type, ent_toembedin, 0, 0))
		entity_db.draw_depth = previous_draw
		entity_db.default_flags = previous_flags
	else
		spawn_entity_over(entity_type, ent_toembedin, 0, 0)
	end
end

function create_door_ending(x, y, l)
	-- # TODO: Remove exit door from the editor and spawn it manually here.
	-- Why? Currently the exit door spawns tidepool-specific critters and ambience sounds, which will probably go away once an exit door isn't there initially.
	-- ALTERNATIVE: kill ambient entities and critters. May allow compass to work.
	-- # TOTEST: Test if the compass works for this. If not, use the method Mr Auto suggested (attatching the compass arrow entity to it)
	DOOR_ENDGAME_OLMEC_UID = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	set_door_target(DOOR_ENDGAME_OLMEC_UID, 4, 2, THEME.TIAMAT)
	if options.hd_debug_boss_exits_unlock == false then
		lock_door_at(x, y)
	end
	-- Olmec/Yama Win
	if state.theme == THEME.OLMEC then
		set_interval(exit_olmec, 1)
	-- elseif state.theme == ??? then
		-- set_interval(exit_yama, 1)
	end
end

function create_door_entrance(x, y, l)
	-- # create the entrance door at the specified game coordinates.
	-- assign coordinates to a global variable to define the game coordinates the player needs to be
	spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	global_levelassembly.entrance = {x = x, y = y}
end

function create_door_testing(x, y, l)
	DOOR_TESTING_UID = spawn_door(x, y, l, THEME.TIDE_POOL, 1, 1)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
	get_entity(door_bg).animation_frame = 1
end

function create_door_tutorial(x, y, l)
	DOOR_TUTORIAL_UID = spawn_door(x, y, l, THEME.DWELLING, 1, 1)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
end

function create_door_exit(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
	set_door_target(door_target, state.world_next, state.level_next, state.theme_next)
	-- spawn_door(x, y, l, state.world_next, state.level_next, state.theme_next)
	
	-- local format_name = F'levelcode_bake_spawn(): Created Exit Door with targets: {state.world_next}, {state.level_next}, {state.theme_next}'
	-- message(format_name)
	if state.shoppie_aggro > 0 then
		spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x, y, l, 0, 0)
		-- get_entity(spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x, y, l, 0, 0)).is_patrolling = true
	end
end

function create_door_exit_to_hell(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, x, y, l, 0, 0)
	set_door_target(door_target, 5, 1, THEME.VOLCANA)--PREFIRSTLEVEL_NUM, THEME.VOLCANA)
	
	if OBTAINED_BOOKOFDEAD == true then
		helldoor_e = get_entity(door_target):as_movable()
		helldoor_e.flags = set_flag(helldoor_e.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
		helldoor_e.flags = clr_flag(helldoor_e.flags, ENT_FLAG.LOCKED)
		-- set_timeout(function()
			-- helldoors = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, 0, HELL_X, 87, LAYER.FRONT, 2)
			-- if #helldoors > 0 then
				-- helldoor_e = get_entity(helldoors[1]):as_movable()
				-- helldoor_e.flags = set_flag(helldoor_e.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
				-- helldoor_e.flags = clr_flag(helldoor_e.flags, ENT_FLAG.LOCKED)
				-- -- message("Aaalllright come on in!!! It's WARM WHER YOU'RE GOIN HAHAHAH")
			-- end
		-- end, 5)
	end
end

-- creates mothership entrance
function create_door_exit_to_mothership(x, y, l)
	-- _door_uid = spawn_door(x, y, l, 3, 3, THEME.NEO_BABYLON)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_BABYLON_1)
	get_entity(door_bg).animation_frame = 1
	set_door_target(door_target, 3, 3, THEME.NEO_BABYLON)
end

-- creates blackmarket entrance
function create_door_exit_to_blackmarket(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1)
	get_entity(door_bg).animation_frame = 1
	set_door_target(door_target, state.world, state.level_next, state.theme)
	DOOR_EXIT_TO_BLACKMARKET_UID = door_target--spawn_door(x, y, l, state.world, state.level+1, state.theme)
	-- spawn_entity(ENT_TYPE.LOGICAL_BLACKMARKET_DOOR, x, y, l, 0, 0)
	set_interval(entrance_blackmarket, 1)
end

function create_door_exit_to_hauntedcastle(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1)
	get_entity(door_bg).animation_frame = 1
	set_door_target(door_target, state.world, state.level_next, state.theme)
	DOOR_EXIT_TO_HAUNTEDCASTLE_UID = door_target--spawn_door(x, y, l, state.world, state.level+1, state.theme)
	set_interval(entrance_hauntedcastle, 1)
end

function create_ghost()
	xmin, _, xmax, _ = get_bounds()
	-- message("xmin: " .. xmin .. " ymin: " .. ymin .. " xmax: " .. xmax .. " ymax: " .. ymax)
	
	if #players > 0 then
		p_x, p_y, p_l = get_position(players[1].uid)
		bx_mid = (xmax - xmin)/2
		gx = 0
		gy = p_y
		if p_x > bx_mid then gx = xmax+5 else gx = xmin-5 end
		spawn(ENT_TYPE.MONS_GHOST, gx, gy, p_l, 0, 0)
		toast("A terrible chill runs up your spine!")
	-- else
		-- toast("A terrible chill r- ...wait, where are the players?!?")
	end
end

function create_crysknife(x, y, layer)
	spawn(ENT_TYPE.ITEM_POWERPACK, x, y, layer, 0, 0)--ENT_TYPE.ITEM_EXCALIBUR, x, y, layer, 0, 0)
end

function create_idol()
	local idols = get_entities_by_type(ENT_TYPE.ITEM_IDOL)
	if (
		#idols > 0 and
		feeling_check("RESTLESS") == false -- Instead, set `IDOL_UID` for the crystal skull during the scripted roomcode generation process
	) then
		IDOL_UID = idols[1]
		IDOL_X, IDOL_Y, idol_l = get_position(IDOL_UID)
		
		-- Idol trap variants
		if state.theme == THEME.DWELLING then
			spawn(ENT_TYPE.BG_BOULDER_STATUE, IDOL_X, IDOL_Y+2.5, idol_l, 0, 0)
		elseif state.theme == THEME.JUNGLE then
			for j = 1, 6, 1 do
				local blocks = get_entities_at(0, MASK.FLOOR, (math.floor(IDOL_X)-3)+j, math.floor(IDOL_Y), LAYER.FRONT, 1)
				idoltrap_blocks[j] = blocks[1]
			end
		elseif state.theme == THEME.ICE_CAVES then
			boulderbackgrounds = get_entities_by_type(ENT_TYPE.BG_BOULDER_STATUE)
			if #boulderbackgrounds > 0 then
				kill_entity(boulderbackgrounds[1])
			end
		-- elseif state.theme == THEME.TEMPLE then
			-- -- ACTIVEFLOOR_CRUSHING_ELEVATOR flipped upsidedown for idol trap?? --Probably doesn't work
		end
	end
end

function create_idol_crystalskull()
	idols = get_entities_by_type(ENT_TYPE.ITEM_MADAMETUSK_IDOL)
	if #idols > 0 then
		IDOL_UID = idols[1]
		x, y, _ = get_position(idols[1])
		IDOL_X, IDOL_Y = x, y
	end
end

function create_wormtongue(x, y, l)
	set_interval(tongue_animate, 15)
	-- currently using level generation to place stickytraps
	stickytrap_uid = spawn_entity(ENT_TYPE.FLOOR_STICKYTRAP_CEILING, x, y, l, 0, 0)
	sticky = get_entity(stickytrap_uid)
	sticky.flags = set_flag(sticky.flags, ENT_FLAG.INVISIBLE)
	sticky.flags = clr_flag(sticky.flags, ENT_FLAG.SOLID)
	move_entity(stickytrap_uid, x, y+1.15, 0, 0) -- avoids breaking surfaces by spawning trap on top of them
	balls = get_entities_by_type(ENT_TYPE.ITEM_STICKYTRAP_BALL) -- HAH balls
	if #balls > 0 then
		TONGUE_BG_UID = spawn_entity(ENT_TYPE.BG_LEVEL_DECO, x, y, l, 0, 0)
		worm_background = get_entity(TONGUE_BG_UID)
		worm_background.animation_frame = 8 -- jungle: 8 icecaves: probably 9
	
		-- sticky part creation
		TONGUE_UID = balls[1] -- HAHA tongue and balls
		ball = get_entity(TONGUE_UID):as_movable()
		ball.width = 1.35
		ball.height = 1.35
		ball.hitboxx = 0.3375
		ball.hitboxy = 0.3375
		
		ballstems = get_entities_by_type(ENT_TYPE.ITEM_STICKYTRAP_LASTPIECE)
		for _, ballstem_uid in ipairs(ballstems) do
			ballstem = get_entity(ballstem_uid)
			ballstem.flags = set_flag(ballstem.flags, ENT_FLAG.INVISIBLE)
			ballstem.flags = clr_flag(ballstem.flags, ENT_FLAG.CLIMBABLE)
		end
		balltriggers = get_entities_by_type(ENT_TYPE.LOGICAL_SPIKEBALL_TRIGGER)
		for _, balltrigger in ipairs(balltriggers) do kill_entity(balltrigger) end
		
		worm_exit_uid = spawn_door(x, y, l, state.world, state.level+1, THEME.EGGPLANT_WORLD)
		worm_exit = get_entity(worm_exit_uid)
		worm_exit.flags = set_flag(worm_exit.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS) -- pause ai to prevent magnetizing damsels
		lock_door_at(x, y)
		
		
		
		TONGUE_STATE = TONGUE_SEQUENCE.READY
		
		set_timeout(function()
			x, y, l = get_position(TONGUE_UID)
			door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				door_platform.flags = set_flag(door_platform.flags, ENT_FLAG.INVISIBLE)
				door_platform.flags = clr_flag(door_platform.flags, ENT_FLAG.SOLID)
				door_platform.flags = clr_flag(door_platform.flags, ENT_FLAG.IS_PLATFORM)
			else message("No Worm Door platform found") end
			-- # TOFIX: Platform seems not to spawn if vine is in the way
		end, 2)
	else
		message("No STICKYTRAP_BALL found, no tongue generated.")
		kill_entity(stickytrap_uid)
		TONGUE_STATE = TONGUE_SEQUENCE.GONE
	end
end

function idol_disturbance()
	if IDOL_UID ~= nil then
		x, y, l = get_position(IDOL_UID)
		return (x ~= IDOL_X or y ~= IDOL_Y)
	end
end

function detect_same_levelstate(t_a, l_a, w_a)
	if state.theme == t_a and state.level == l_a and state.world == w_a then return true else return false end
end

function detect_s2market()
	if test_flag(state.quest_flags, 18) == true then
		market_doors = get_entities_by_type(ENT_TYPE.LOGICAL_BLACKMARKET_DOOR)
		if (#market_doors > 0) then -- or (state.theme == THEME.JUNGLE and levelsize[2] >= 4)
			return true
		end
	end
	return false
end


-- -- won't set if already set to the current level or a past level
-- function feeling_set_once_future(feeling, levels, use_chance)
	-- if ( -- don't set it if it's on the correct theme and the level is set and it's set to the current level or a past level
		-- detect_feeling_themes(feeling) == false or
		-- (
			-- global_feelings[feeling].load ~= nil and
			-- global_feelings[feeling].load <= state.level
		-- )
	-- ) then return false
	-- else
		-- return feeling_set(feeling, levels, use_chance)
	-- end
-- end
-- won't set if the current theme doesn't match and load has already been set
function feeling_set_once(feeling, levels)
	if (
		detect_feeling_themes(feeling) == false or
		global_feelings[feeling].load ~= nil
	) then return false
	else
		return feeling_set(feeling, levels)
	end
end

-- if multiple levels and false are passed in, a random level in the table is set
	-- NOTE: won't set to a past level
function feeling_set(feeling, levels)
	roll = math.random()
	chance = 1
	if global_feelings[feeling].chance ~= nil then
		chance = global_feelings[feeling].chance
	end
	if chance >= roll then
		levels_indexed = {}
		for _, level in ipairs(levels) do
			if level >= state.level then
				levels_indexed[#levels_indexed+1] = level
			end
		end
		global_feelings[feeling].load = levels_indexed[math.random(1, #levels_indexed)]
		return true
	else return false end
end

function detect_feeling_themes(feeling)
	for _, feeling_theme in ipairs(global_feelings[feeling].themes) do
		if state.theme == feeling_theme then
			return true
		end
	end
	return false
end

function feeling_check(feeling)
	if (
		detect_feeling_themes(feeling) == true and
		state.level == global_feelings[feeling].load
	) then return true end
	return false
end

-- detect offset
function detection_floor(x, y, l, offsetx, offsety, _radius)
	_radius = _radius or 0.1
	local blocks = get_entities_at(0, MASK.FLOOR, x+offsetx, y+offsety, l, _radius)
	if (#blocks > 0) then
		return blocks[1]
	end
	return -1
end

-- return status: 1 for conflict, 0 for right side, -1 for left.
function conflictdetection_giant(hdctype, x, y, l)
	conflict_rightside = false
	scan_width = 1 -- check 2 across
	scan_height = 2 -- check 3 up
	floor_level = 1 -- default to frog
	-- if hdctype == HD_COLLISIONTYPE.GIANT_FROG then
		
	-- end
	if hdctype == HD_COLLISIONTYPE.GIANT_SPIDER then
		floor_level = 2 -- check ceiling
	end
	x_leftside = x - 1
	y_scanbase = y - 1
	for sides_xi = x, x_leftside, -1 do
		for block_yi = y_scanbase, y_scanbase+scan_height, 1 do
			for block_xi = sides_xi, sides_xi+scan_width, 1 do
				avoidair = true
				if block_yi == y_scanbase + floor_level then
					avoidair = false
				end
				if (
					(avoidair == false and (detection_floor(block_xi, block_yi, l, 0, 0) ~= -1)) or
					(avoidair == true and (detection_floor(block_xi, block_yi, l, 0, 0) == -1))
				) then
					conflict_rightside = true
				end
			end
		end
		if conflict_rightside == false then
			if sides_xi == x_leftside then
				return -1
			else
				return 0
			end
		end
	end
	return 1
end

-- detect blocks above and to the sides
function conflictdetection_floortrap(hdctype, x, y, l)
	conflict = false
	scan_width = 1 -- check 1 across
	scan_height = 1 -- check the space above
	if hdctype == HD_COLLISIONTYPE.FLOORTRAP and options.hd_og_procedural_spawns_disable == true then
		scan_width = 1 -- check 1 across (1 on each side)
		scan_height = 0 -- check the space above + 1 more
	elseif hdctype == HD_COLLISIONTYPE.FLOORTRAP_TALL and options.hd_og_procedural_spawns_disable == true then
		scan_width = 3 -- check 3 across (1 on each side)
		scan_height = 2 -- check the space above + 1 more
	end
	ey_above = y
	for block_yi = ey_above, ey_above+scan_height, 1 do
		-- skip sides when y == 1
		if block_yi < ey_above+scan_height then
			block_xi_min, block_xi_max = x, x
		else
			block_xi_min = x - math.floor(scan_width/2)
			block_xi_max = x + math.floor(scan_width/2)
		end
		for block_xi = block_xi_min, block_xi_max, 1 do
			conflict = (detection_floor(block_xi, block_yi, l, 0, 0) ~= -1)
			-- test `return conflict` here instead (I know it will work -_- but just to be safe, test it first)
			if conflict == true then
				break
			end
		end
		if conflict == true then break end
	end
	return conflict
end

-- returns: optimal offset for conflicts
function conflictdetection(hdctype, x, y, l)
	offset = { 0, 0 }
	-- avoid_types = {ENT_TYPE.FLOOR_BORDERTILE, ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOOR_JUNGLE, ENT_TYPE.FLOORSTYLED_MINEWOOD, ENT_TYPE.FLOORSTYLED_STONE}
	-- HD_COLLISIONTYPE = {
		-- AIR_TILE_1 = 1,
		-- AIR_TILE_2 = 2,
		-- FLOORTRAP = 3,
		-- FLOORTRAP_TALL = 4,
		-- GIANT_FROG = 5,
		-- GIANT_SPIDER = 6,
		-- -- GIANT_FISH = 7
	-- } and
	if (
		hd_type.collisiontype ~= nil and
		(
			hd_type.collisiontype >= HD_COLLISIONTYPE.AIR_TILE_1
			-- hd_type.collisiontype == HD_COLLISIONTYPE.FLOORTRAP or
			-- hd_type.collisiontype == HD_COLLISIONTYPE.FLOORTRAP_TALL
		)
	) then
		if (
			hdctype == HD_COLLISIONTYPE.FLOORTRAP or
			hdctype == HD_COLLISIONTYPE.FLOORTRAP_TALL
		) then
			conflict = conflictdetection_floortrap(hdctype, x, y, l)
			if conflict == true then
				offset = nil
			else
				offset = { 0, 0 }
			end
		elseif (
			hdctype == HD_COLLISIONTYPE.GIANT_FROG or
			hdctype == HD_COLLISIONTYPE.GIANT_SPIDER
		) then
			side = conflictdetection_giant(hdctype, x, y, l)
			if side > 0 then
				offset = nil
			else
				offset = { side, 0 }
			end
		end
	end
	return offset
end

function decorate_floor(e_uid, offsetx, offsety)--e_type, --e_theme, orientation(?))
	spawn_entity_over(ENT_TYPE.DECORATION_GENERIC, e_uid, offsetx, offsety)
end

function remove_borderfloor()
	for yi = 90, 88, -1 do
		for xi = 3, 42, 1 do
			local blocks = get_entities_at(ENT_TYPE.FLOOR_BORDERTILE, 0, xi, yi, LAYER.FRONT, 0.3)
			kill_entity(blocks[1])
		end
	end
end

function remove_entitytype_inventory(entity_type, inventory_entities)
	items = get_entities_by_type(inventory_entities)
	for r, inventoryitem in ipairs(items) do
		local mount = get_entity(inventoryitem):topmost()
		if mount ~= -1 and mount:as_container().type.id == entity_type then
			move_entity(inventoryitem, -r, 0, 0, 0)
			-- message("Should be hermitcrab: ".. mount.uid)
		end
	end
end

-- removes all types of an entity from any player that has it.
function remove_player_item(powerup, player)
	powerup_uids = get_entities_by_type(powerup)
	for i = 1, #powerup_uids, 1 do
		for j = 1, #players, 1 do
			if entity_has_item_uid(players[j].uid, powerup_uids[i]) then
				entity_remove_item(players[j].uid, powerup_uids[i])
			end
		end
	end
end

function animate_bookofdead(tick_limit)
	if bookofdead_tick <= tick_limit then
		bookofdead_tick = bookofdead_tick + 1
	else
		if bookofdead_frames_index == bookofdead_frames then
			bookofdead_frames_index = 1
		else
			bookofdead_frames_index = bookofdead_frames_index + 1
		end
		bookofdead_tick = 0
	end
end

function changestate_onloading_targets(w_a, l_a, t_a, w_b, l_b, t_b)
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		if test_flag(state.quest_flags, 1) == false then
			state.level_next = l_b
			state.world_next = w_b
			state.theme_next = t_b
			if t_b == THEME.BASE_CAMP then
				state.screen_next = ON.CAMP
			end
		end
	end
end

-- Used to "fake" world/theme/level
function changestate_onlevel_fake(w_a, l_a, t_a, w_b, l_b, t_b)--w_b=0, l_b=0, t_b=0)
	if detect_same_levelstate(t_a, l_a, w_a) == true then --and (w_b ~= 0 or l_b ~= 0 or t_b ~= 0) then
		-- if test_flag(state.quest_flags, 1) == false then
			state.level = l_b
			state.world = w_b
			state.theme = t_b
		-- end
	end
end

function changestate_samelevel_applyquestflags(w_a, l_a, t_a, flags_set, flags_clear)--w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
	end
end

function entrance_force_feeling(_feeling, _entrance_uid)
	door_entrance_ent = get_entity(_entrance_uid)
	if door_entrance_ent ~= nil then
		for i = 1, #players, 1 do
			if (
				door_entrance_ent:overlaps_with(get_entity(players[i].uid)) == true and
				players[i].state == CHAR_STATE.ENTERING
			) then
				feeling_set_once(_feeling, {state.level+1})
				break;
			end
		end
	end
end

function entrance_blackmarket()
	entrance_force_feeling("BLACKMARKET", DOOR_EXIT_TO_BLACKMARKET_UID)
end

function entrance_hauntedcastle()
	entrance_force_feeling("HAUNTEDCASTLE", DOOR_EXIT_TO_HAUNTEDCASTLE_UID)
end

-- # TODO: Either merge `exit_*BOSS*` methods or make exit_yama more specific
function exit_olmec()
	for i = 1, #players, 1 do
		x, y, l = get_position(players[i].uid)
		
		if (
			-- (get_entity(DOOR_ENDGAME_OLMEC_UID).entered == true)
			(players[i].state == CHAR_STATE.ENTERING) and
			(y > 95)
		) then
			state.win_state = 1
			break
		else
			state.win_state = 0
		end
	end
end

function entrance_force_worldstate(_worldstate, _entrance_uid)
	if HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.NORMAL then
		door_entrance_ent = get_entity(_entrance_uid)
		if door_entrance_ent ~= nil then
			for i = 1, #players, 1 do
				if (
					door_entrance_ent:overlaps_with(get_entity(players[i].uid)) == true and
					players[i].state == CHAR_STATE.ENTERING
				) then
					HD_WORLDSTATE_STATE = _worldstate
					break;
				end
			end
		end
	end
end

function entrance_testing()
	entrance_force_worldstate(HD_WORLDSTATE_STATUS.TESTING, DOOR_TESTING_UID)
end

function entrance_tutorial()
	entrance_force_worldstate(HD_WORLDSTATE_STATUS.TUTORIAL, DOOR_TUTORIAL_UID)
end

-- function exit_yama()
-- 	for i = 1, #players, 1 do
-- 		x, y, l = get_position(players[i].uid)
		
-- 		if players[i].state == CHAR_STATE.ENTERING then-- and y > ??? then
-- 			state.win_state = 2
-- 			break
-- 		else
-- 			state.win_state = 0
-- 		end
-- 	end
-- end

function test_bacterium()
	
	-- Bacterium Creation
		-- FLOOR_THORN_VINE:
			-- flags = clr_flag(flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) -- indestructable (maybe need to clear this? Not sure yet)
			-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
			-- visible
			-- allow hurting player
			-- disable collisions
			-- allow bombs to destroy them.
		-- ACTIVEFLOOR_BUSHBLOCK:
			-- invisible
			-- disable collisions
			-- allow taking damage (unless it's already enabled by default)
		-- ITEM_ROCK:
			-- disable physics
				-- re-enable once detached from surface
	-- Challenge: Let rock attatch to surface, move it on frame.

end

define_tile_code("hd_shortcuts")
define_tile_code("hd_tunnelman")
define_tile_code("hd_door_tutorial")
define_tile_code("hd_door_testing")

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return 0
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MARLA_TUNNEL)

set_pre_tile_code_callback(function(x, y, layer)
	oncamp_tunnelman_spawn()
	return true
end, "hd_tunnelman")

set_post_tile_code_callback(function(x, y, layer)
	oncamp_shortcuts()
	return true
end, "hd_shortcuts")

set_post_tile_code_callback(function(x, y, layer)
	create_door_tutorial(x, y, layer)
	return true
end, "hd_door_tutorial")

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_testing_door == true then
		create_door_testing(x, y, layer)
	end
	return true
end, "hd_door_testing")


-- set_pre_tile_code_callback(function(x, y, layer)
	-- if state.theme == THEME.JUNGLE then
		-- if detect_s2market() == true and layer == LAYER.FRONT and y < 88 then
			-- -- spawn(ENT_TYPE., x, y, layer, 0, 0)
			-- return true
		-- end
	-- end
	-- spawn(ENT_TYPE.FLOOR_GENERIC, x, y, layer, 0, 0)
	
	-- return true
-- end, "floor")

-- `set_pre_tile_code_callback` todos:
	-- “floor” -- if state.camp and shortcuts discovered, then
		-- if state.transition, if transition between worm and next level then
			-- replace floor with worm guts
		-- end
		-- if transition from jungle to ice caves then
			-- replace stone with floor_jungle end if transition from ice caves to temple then replace quicksand with stone
		-- end
		-- if state.level and detect_s2market()
			-- if (within the coordinates of where water should be)
				-- replace with water
			-- if (within the coordinates of where border should be)
				-- return false
			-- if (within the coordinates of where void should be)
				-- replace with nothing
			-- end
	-- “border(?)” see if you can change styles from here
		-- if detect_s2market() and `within the coordinates of where water should be` then
			-- replace with water
		-- end

	-- “treasure” if state.theme == THEME.OLMEC (or temple?) then use the hd tilecode chance for treasure when in temple/olmec
	-- “regenerating_wall50%” if state.theme == THEME.EGGPLANTWORLD then use the hd tilecode chance for floor50%(“2”) when in the worm

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_scripted_levelgen_disable == false then

		-- leveldoor_sx = x-1
		-- leveldoor_sy = y
		-- leveldoor_sx2 = x+1
		-- leveldoor_sy2 = y+3
		-- door_ents_masks = {
			-- MASK.PLAYER,	-- players (duh)
			-- MASK.MOUNT,		-- player mounts
			-- MASK.MONSTER,	-- exit-aggroed shopkeepers
			-- MASK.ITEM,		-- player-held items; entrance-spawned pots, skulls, torches;
			-- MASK.LOGICAL,
		-- }
		-- door_ents_uids = {}
		-- for _, door_ent_mask in ipairs(door_ents_masks) do
			-- door_ents_uids = TableConcat(door_ents_uids, get_entities_overlapping(
				-- 0,
				-- door_ent_mask,
				-- leveldoor_sx,
				-- leveldoor_sy,
				-- leveldoor_sx2,
				-- leveldoor_sy2,
				-- LAYER.FRONT
			-- ))
		-- end
		
		-- TEMPORARY: Remove S2 door.
		
		door_ents_uids = get_entities_at(0, 0, x, y, layer, 1)
		for _, door_ents_uid in ipairs(door_ents_uids) do
			kill_entity(door_ents_uid)
		end

		-- message("post-door: " .. tostring(state.time_level))
		-- if state.screen == 12 then
		-- end
	else
		spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, layer, 0, 0)

		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-2, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-4, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-4, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-4, layer, 0, 0)
		
		create_door_exit(x+2, y, layer)
	end
end, "door")


--[[
	START PROCEDURAL SPAWN DEF
--]]

-- Make a global table where you set `HD_ENT` as the index so you can access each definition on the fly
local global_procedural_spawns = {}

-- powderkeg / pushblock
local function create_powderkeg(x, y, l) spawn_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l, 0, 0) end
local function create_pushblock(x, y, l) spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0) end
local function is_valid_pushblock_spawn(x, y, l)
    -- # TODO: Revise. Replaces floor with spawn where it has floor to the left, right and under
	-- Only spawn where the powderkeg has floor left or right of it
    local not_entity_here = get_grid_entity_at(x, y, l) == -1
    if not_entity_here then
        local entity_below = get_grid_entity_at(x, y - 1, l) >= 0
        if entity_below then
            local entity_left = get_grid_entity_at(x - 1, y, l) >= 0
            local entity_right = get_grid_entity_at(x + 1, y, l) >= 0
            return entity_left ~= entity_right
        end
    end
    return false
end
global_procedural_spawns[HD_ENT.POWDERKEG] = define_procedural_spawn("hd_procedural_powderkeg", create_powderkeg, is_valid_pushblock_spawn)
global_procedural_spawns[HD_ENT.PUSHBLOCK] = define_procedural_spawn("hd_procedural_pushblock", create_pushblock, is_valid_pushblock_spawn)

-- HD_ENT.CRITTER_RAT
local function create_critter_rat(x, y, l) end
local function is_valid_critter_rat_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
global_procedural_spawns[HD_ENT.CRITTER_RAT] = define_procedural_spawn("hd_procedural_critter_rat", create_critter_rat, is_valid_critter_rat_spawn)

-- HD_ENT.SCORPION
local function create_scorpion(x, y, l) end
local function is_valid_scorpion_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.SCORPION] = define_procedural_spawn("hd_procedural_scorpion", create_scorpion, is_valid_scorpion_spawn)

-- HD_ENT.HANGSPIDER
local function create_hangspider(x, y, l) end
local function is_valid_hangspider_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
global_procedural_spawns[HD_ENT.HANGSPIDER] = define_procedural_spawn("hd_procedural_hangspider", create_hangspider, is_valid_hangspider_spawn)

-- HD_ENT.GIANTSPIDER
local function create_giantspider(x, y, l) end
local function is_valid_giantspider_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
global_procedural_spawns[HD_ENT.GIANTSPIDER] = define_procedural_spawn("hd_procedural_giantspider", create_giantspider, is_valid_giantspider_spawn)

-- HD_ENT.WEBNEST
local function create_webnest(x, y, l)
	-- (I think?) spawn_entity_over the floor above
end
local function is_valid_webnest_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
global_procedural_spawns[HD_ENT.WEBNEST] = define_procedural_spawn("hd_procedural_webnest", create_webnest, is_valid_webnest_spawn)

-- HD_ENT.JIANGSHI
local function create_jiangshi(x, y, l) end
local function is_valid_jiangshi_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.JIANGSHI] = define_procedural_spawn("hd_procedural_jiangshi", create_jiangshi, is_valid_jiangshi_spawn)

-- HD_ENT.VAMPIRE
local function create_vampire(x, y, l) end
local function is_valid_vampire_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.VAMPIRE] = define_procedural_spawn("hd_procedural_vampire", create_vampire, is_valid_vampire_spawn)

-- HD_ENT.GREENKNIGHT
local function create_greenknight(x, y, l) end
local function is_valid_greenknight_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.GREENKNIGHT] = define_procedural_spawn("hd_procedural_greenknight", create_greenknight, is_valid_greenknight_spawn)

-- HD_ENT.FROG
local function create_frog(x, y, l) end
local function is_valid_frog_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.FROG] = define_procedural_spawn("hd_procedural_frog", create_frog, is_valid_frog_spawn)

-- HD_ENT.FIREFROG
local function create_firefrog(x, y, l) end
local function is_valid_firefrog_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.FIREFROG] = define_procedural_spawn("hd_procedural_firefrog", create_firefrog, is_valid_firefrog_spawn)

-- HD_ENT.GIANTFROG
local function create_giantfrog(x, y, l) end
local function is_valid_giantfrog_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.GIANTFROG] = define_procedural_spawn("hd_procedural_giantfrog", create_giantfrog, is_valid_giantfrog_spawn)

-- HD_ENT.PIRANHA
local function create_piranha(x, y, l) end
local function is_valid_piranha_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.PIRANHA] = define_procedural_spawn("hd_procedural_piranha", create_piranha, is_valid_piranha_spawn)

-- HD_ENT.SNAIL
local function create_snail(x, y, l) end
local function is_valid_snail_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.SNAIL] = define_procedural_spawn("hd_procedural_snail", create_snail, is_valid_snail_spawn)

-- HD_ENT.TIKITRAP
local function create_tikitrap(x, y, l)
	-- spawn_entity_over the floor above
end
local function is_valid_tikitrap_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.TIKITRAP] = define_procedural_spawn("hd_procedural_tikitrap", create_tikitrap, is_valid_tikitrap_spawn)

-- HD_ENT.MAMMOTH
local function create_mammoth(x, y, l) end
local function is_valid_mammoth_spawn(x, y, l)
    -- # TODO: Implement.
    return false
end
--global_procedural_spawns[HD_ENT.MAMMOTH] = define_procedural_spawn("hd_procedural_mammoth", create_mammoth, is_valid_mammoth_spawn)

-- -- HD_ENT.TEMPLATE
-- local function create_template(x, y, l) end
-- local function is_valid_template_spawn(x, y, l)
--     -- # TODO: Implement.
--     return false
-- end
-- --global_procedural_spawns[HD_ENT.TEMPLATE] = define_procedural_spawn("hd_procedural_template", create_template, is_valid_template_spawn)

--[[-- Worm Tongue Depreciated Methods
-- Worm tongue generation
-- # TODO: Outdated. Revise with the following PSEUDOCODE:
	-- find all blocks that have 2 spaces above it free, pick a random one, then spawn the worm tongue.
	function onlevel_add_wormtongue()
		if state.theme == THEME.JUNGLE then -- or state.theme == THEME.ICE_CAVES then
			tonguepoints = get_entities_by_type(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH)
			if state.level == 1 then
				random_uid = -1
				random_index = math.random(1, #tonguepoints)
				for i, tonguepoint_uid in ipairs(tonguepoints) do
					if random_index == i then
						random_uid = tonguepoint_uid
						-- spawn worm
						create_wormtongue(get_position(random_uid))
					end
					move_entity(tonguepoint_uid, 0, 0, 0, 0)
				end
				if random_uid == -1 then
					message("No worm for you. YEOW!! (random_uid could not be set)")
				end
			else
				for _, tonguepoint_uid in ipairs(tonguepoints) do move_entity(tonguepoint_uid, 0, 0, 0, 0) end
			end
		end
		set_timeout(function()
			tonguepoints = get_entities_by_type(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH)
			for _, tonguepoint_uid in ipairs(tonguepoints) do kill_entity(tonguepoint_uid, 0, 0, 0, 0) end
		end, 5)
	end	
--]]

--[[--
	
--]]

--[[--
	
--]]

--[[
	END PROCEDURAL SPAWN DEF
--]]

set_callback(function(room_gen_ctx)
	if state.screen == ON.LEVEL then
		-- message("ON.POST_ROOM_GENERATION - ON.LEVEL")

		init_posttile_onstart()
		if options.hd_debug_scripted_levelgen_disable == false then
			init_posttile_door()
			levelcreation_init()
		end

	-- # TODO: Method to handle case-by-case spawn chances.
		-- Includes Feelings, The Worm enemies
		-- Forcing volcana not to spawn powderkegs
		
		-- -- set restless spawn chances
		-- if feeling_check("RESTLESS") then
		-- 	room_gen_ctx:set_procedural_spawn_chance(global_procedural_spawns[HD_ENT.JIANGSHI], 20)
		-- end

		-- prevent procedural spawns for tutorial
		if HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TUTORIAL then
			-- # TOFIX: These doen't seem to have any effect.
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.ADD_GOLD_BAR, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.ADD_GOLD_BARS, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.ARROWTRAP_CHANCE, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.SNAKE, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.BAT, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.SPIDER, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.COBRA, 0)
			-- room_gen_ctx:set_procedural_spawn_chance(PROCEDURAL_CHANCE.CAVEMAN, 0)
			
			-- #TODO: Add pots, spiderwebs, rocks, skulls, and skeletons when/if they are added
			-- #TODO: Add global_procedural_spawns once you implement them
		end

		level_w, level_h = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		-- level_w, level_h = 4, 4
		-- if state.theme == THEME.EGGPLANT_WORLD then
		-- 	level_w, level_h = 2, 12
		-- end
		for y = 0, level_h - 1, 1 do
		    for x = 0, level_w - 1, 1 do
				template_to_set = ROOM_TEMPLATE.SIDE
				
				if options.hd_debug_scripted_levelgen_disable == false then
					
					--[[
						Sync scripted level generation rooms with S2 generation rooms
					--]]
					_template_hd = global_levelassembly.modification.levelrooms[y+1][x+1]
					
					-- normal paths
					if (
						(_template_hd >= 1) and (_template_hd <= 8)
					) then
						template_to_set = _template_hd
					-- tikivillage paths
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH then
						template_to_set = ROOM_TEMPLATE.PATH_NORMAL
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP then
						template_to_set = ROOM_TEMPLATE.PATH_DROP
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP then
						template_to_set = ROOM_TEMPLATE.PATH_NOTOP
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP then
						template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT then
						template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
					elseif _template_hd == HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT then
						template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
					
					-- shop
					elseif (_template_hd == HD_SUBCHUNKID.SHOP_REGULAR) then
						template_to_set = ROOM_TEMPLATE.SHOP
					-- shop left
					elseif (_template_hd == HD_SUBCHUNKID.SHOP_REGULAR_LEFT) then
						template_to_set = ROOM_TEMPLATE.SHOP_LEFT
					-- prize wheel
					elseif (_template_hd == HD_SUBCHUNKID.SHOP_PRIZE) then
						template_to_set = ROOM_TEMPLATE.DICESHOP
					-- prize wheel left
					elseif (_template_hd == HD_SUBCHUNKID.SHOP_PRIZE_LEFT) then
						template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
						
					-- vault
					elseif (_template_hd == HD_SUBCHUNKID.VAULT) then
						template_to_set = ROOM_TEMPLATE.VAULT
					
					-- altar
					elseif (_template_hd == HD_SUBCHUNKID.ALTAR) then
						template_to_set = ROOM_TEMPLATE.ALTAR
					
					-- idol
					elseif (_template_hd == HD_SUBCHUNKID.IDOL) then
						template_to_set = ROOM_TEMPLATE.IDOL
						

					end
					room_gen_ctx:set_room_template(x, y, 0, template_to_set)
				else
					-- Set everything that's not the entrance to a side room
					local room_template_here = get_room_template(x, y, 0)
					if (
						(room_template_here ~= ROOM_TEMPLATE.ENTRANCE) and
						(room_template_here ~= ROOM_TEMPLATE.ENTRANCE_DROP)
					) then
						room_gen_ctx:set_room_template(x, y, 0, template_to_set)
					end
				end
	        end
	    end
	end
end, ON.POST_ROOM_GENERATION)

-- ON.CAMP
set_callback(function()
	-- oncamp_movetunnelman()
	-- oncamp_shortcuts()
	
	
	-- signs_back = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_BACK)
	-- signs_front = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_FRONT)
	-- x, y, l = 49, 90, LAYER.FRONT -- next to entrance
	
	-- pre_tile ON.START stuff
	global_feelings = nil
	HD_WORLDSTATE_STATE = HD_WORLDSTATE_STATUS.NORMAL

	set_interval(entrance_tutorial, 1)
	if options.hd_debug_testing_door == true then
		set_interval(entrance_testing, 1)
	end
end, ON.CAMP)

set_callback(function()
	unlocks_init()
end, ON.LOGO)

-- ON.START
set_callback(function()
	onstart_init_options()
	onstart_init_methods()
	-- global_feelings = TableCopy(HD_FEELING)
	
	-- Enable S2 udjat eye, S2 black market, and drill spawns to prevent them from spawning.
	changestate_samelevel_applyquestflags(state.world, state.level, state.theme, {17, 18, 19}, {})
	RUN_UNLOCK = nil
end, ON.START)

set_callback(function()
	-- pre_tile ON.START stuff
	global_feelings = nil
	POSTTILE_STARTBOOL = false
	-- HD_WORLDSTATE_STATE = HD_WORLDSTATE_STATUS.NORMAL
	-- DOOR_TESTING_UID = nil
	-- DOOR_TUTORIAL_UID = nil
end, ON.RESET)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
	onloading_applyquestflags()
end, ON.LOADING)

-- # TODO: When placing an AREA_RAND* character coffin in the level, set an ON.FRAME check for unlocking it; if check passes, set RUN_UNLOCK_AREA[state.theme] = true
set_callback(function(save_ctx)
	local save_areaUnlocks_str = json.encode(RUN_UNLOCK_AREA)
	save_ctx:save(save_areaUnlocks_str)
end, ON.SAVE)

-- Load bools of the areas you've unlocked AREA_RAND* characters in
set_callback(function(load_ctx)
	local load_areaUnlocks_str = load_ctx:load()
	if load_areaUnlocks_str ~= "" then
		RUN_UNLOCK_AREA = json.decode(load_areaUnlocks_str)
	end
end, ON.LOAD)

set_callback(function()
	-- global_levelassembly = nil
end, ON.TRANSITION)

function levelcreation_init()
	init_onlevel()
	unlocks_load()
	onlevel_levelrules()
	onlevel_set_feelings()
	onlevel_set_feelingToastMessage()
	-- Method to write override_path setrooms into path and levelcode
--ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
	-- onlevel_reverse_exits()
--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	-- onlevel_generation_detection()
	onlevel_generation_modification()
	onlevel_placement_lockedchest()
	-- onlevel_generation_execution()
	generation_removeborderfloor()
	-- onlevel_replace_powderkegs()
	-- onlevel_generation_pushblocks() -- PLACE AFTER onlevel_generation
end


set_callback(function()
	message(F'ON.LEVEL: {state.time_level}')--"ON.LEVEL: " .. tostring(state.time_level))
-- --ONLEVEL_PRIORITY: 1 - Set level constants (ie, init_onlevel(), levelrules)
	-- init_onlevel()

	-- TEMPORARY: move players and things they have to entrance point
	
	if options.hd_debug_scripted_levelgen_disable == false then
		for i = 1, #players, 1 do
			move_entity(players[i].uid, global_levelassembly.entrance.x, global_levelassembly.entrance.y, 0, 0)
		end
	end

	-- unlocks_load()
	-- onlevel_levelrules()
	-- onlevel_detection_feeling()
	-- onlevel_set_feelingToastMessage()
-- --ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
	-- onlevel_reverse_exits()
-- --ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	-- onlevel_generation_detection()
	-- onlevel_generation_modification()
	-- onlevel_generation_execution()
	-- generation_removeborderfloor()
	-- -- onlevel_replace_powderkegs()
	-- -- onlevel_generation_pushblocks() -- PLACE AFTER onlevel_generation
	
--ONLEVEL_PRIORITY: 4 - Set up dangers (LEVEL_DANGERS)
	onlevel_dangers_init()
	onlevel_dangers_modifications()
	onlevel_dangers_setonce()
	set_timeout(onlevel_dangers_replace, 3)
--ONLEVEL_PRIORITY: 5 - Remaining ON.LEVEL methods (ie, IDOL_UID)
	onlevel_remove_cursedpot() -- PLACE AFTER onlevel_placement_lockedchest()
	-- onlevel_prizewheel()
	-- onlevel_idoltrap()
	onlevel_remove_mounts()

	-- onlevel_blackmarket_ankh()
	
	-- # TODO: Replace onlevel_add_* methods with tilecode spawning.
	-- onlevel_add_crysknife()
	-- onlevel_add_botd()

	onlevel_hide_yama()
	onlevel_acidbubbles()
	onlevel_boss_init()
	onlevel_toastfeeling()
end, ON.LEVEL)

set_callback(function()
	onframe_manage_dangers()
	onframe_bacterium()
	onframe_ghosts()
	onframe_manage_inventory()
	onframe_prizewheel()
	onframe_idoltrap()
	onframe_tonguetimeout()
	onframe_acidpoison()
	onframe_boss()
end, ON.FRAME)

set_callback(function()
	onguiframe_ui_animate_botd()
	onguiframe_ui_info_boss()			-- debug
	onguiframe_ui_info_wormtongue() 	--
	onguiframe_ui_info_boulder()		--
	onguiframe_ui_info_feelings()		--
	onguiframe_ui_info_path()			--
	onguiframe_ui_info_worldstate()		--
	onguiframe_env_animate_prizewheel()
end, ON.GUIFRAME)



function onstart_init_options()	
	OBTAINED_BOOKOFDEAD = options.hd_debug_item_botd_give
	if options.hd_og_ghost_time_disable == false then GHOST_TIME = 9000 end

	-- UI_BOTD_PLACEMENT_W = options.hd_ui_botd_a_w
	-- UI_BOTD_PLACEMENT_H = options.hd_ui_botd_b_h
	-- UI_BOTD_PLACEMENT_X = options.hd_ui_botd_c_x
	-- UI_BOTD_PLACEMENT_Y = options.hd_ui_botd_d_y
end

function onstart_init_methods()
	set_ghost_spawn_times(GHOST_TIME, GHOST_TIME-1800)
	
	set_olmec_phase_y_level(0, 10.0)
	set_olmec_phase_y_level(1, 9.0)
	set_olmec_phase_y_level(2, 8.0)
end

-- LEVEL HANDLING
function onloading_levelrules()
	
	--[[
		Tutorial
	--]]
	
	-- Tutorial 1-3 -> Camp
	if (HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TUTORIAL) then
		changestate_onloading_targets(1,3,THEME.DWELLING,1,1,THEME.BASE_CAMP)
	end
	
	--[[
		Testing
	--]]
	
	-- Testing 1-2 -> Camp
	if (HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TESTING) then
		changestate_onloading_targets(1,2,state.theme,1,1,THEME.BASE_CAMP)
	end

	--[[
		Mines
	--]]

	-- Mines 1-1..3
    changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
    changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
	
	-- Mines 1-3 -> Mines 1-5(Fake 1-4)
    changestate_onloading_targets(1,3,THEME.DWELLING,1,5,THEME.DWELLING)

    -- Mines -> Jungle
    changestate_onloading_targets(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)

	--[[
		Jungle
	--]]

	-- Jungle 2-1..4
    changestate_onloading_targets(2,1,THEME.JUNGLE,2,2,THEME.JUNGLE)
    changestate_onloading_targets(2,2,THEME.JUNGLE,2,3,THEME.JUNGLE)
    changestate_onloading_targets(2,3,THEME.JUNGLE,2,4,THEME.JUNGLE)

    -- Jungle -> Ice Caves
    changestate_onloading_targets(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)

	--[[
		Worm
	--]]

	-- Worm(Jungle) 2-2 -> Jungle 2-4
	-- # TOTEST: Re-adjust level loading (remove changestate_onloading_targets() where scripted levelgen entrance doors take over)
	changestate_onloading_targets(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
	
	-- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	changestate_onloading_targets(3,2,THEME.EGGPLANT_WORLD,3,4,THEME.ICE_CAVES)

    
	--[[
		Ice Caves
	--]]
		-- # TOTEST: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
		
	-- Ice Caves 3-1..4
    changestate_onloading_targets(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    changestate_onloading_targets(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    changestate_onloading_targets(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
	
    -- Ice Caves -> Temple
    changestate_onloading_targets(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)

	--[[
		Mothership
	--]]
	
	-- Mothership(3-3) -> Ice Caves(3-4)
    changestate_onloading_targets(3,3,THEME.NEO_BABYLON,3,4,THEME.ICE_CAVES)
	
	--[[
		Temple
	--]]
	
	-- Temple 4-1..3
    changestate_onloading_targets(4,1,THEME.TEMPLE,4,2,THEME.TEMPLE)
    changestate_onloading_targets(4,2,THEME.TEMPLE,4,3,THEME.TEMPLE)

    -- Temple -> Olmec
    changestate_onloading_targets(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
	
	--[[
		City Of Gold
	--]]

    -- COG(4-3) -> Olmec
    changestate_onloading_targets(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	
	--[[
		Hell
	--]]

    changestate_onloading_targets(5,1,THEME.VOLCANA,5,2,THEME.VOLCANA)
    changestate_onloading_targets(5,2,THEME.VOLCANA,5,3,THEME.VOLCANA)

	-- Hell -> Yama
		-- Build Yama in Tiamat's chamber.
	changestate_onloading_targets(5,3,THEME.VOLCANA,5,4,THEME.TIAMAT)

	-- local format_name = F'onloading_levelrules(): Set loading target. state.*_next: {state.world_next}, {state.level_next}, {state.theme_next}'
	-- message(format_name)
end

-- executed with the assumption that onloading_levelrules() has already been run, applying state.*_next
function onloading_applyquestflags()
	flags_failsafe = {
		10, -- Disable Waddler's
		25, 26, -- Disable Moon and Star challenges.
		19 -- Disable drill -- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
	}
	for i = 1, #flags_failsafe, 1 do
		if test_flag(state.quest_flags, flags_failsafe[i]) == false then state.quest_flags = set_flag(state.quest_flags, flags_failsafe[i]) end
	end
end

-- Entities that spawn with methods that are only set once
function onlevel_dangers_setonce()
	-- loop through all dangers in global_dangers, setting enemy specifics
	if LEVEL_DANGERS[state.theme] and #global_dangers > 0 then
		for i = 1, #global_dangers, 1 do
			hd_type = global_dangers[i]
			if hd_type.removeinventory ~= nil then
				if hd_type.removeinventory == HD_REMOVEINVENTORY.SNAIL then
					set_timeout(function()
						hd_type = HD_ENT.SNAIL
						remove_entitytype_inventory(
							hd_type.removeinventory.inventory_ownertype,
							hd_type.removeinventory.inventory_entities
						)
					end, 5)
				elseif hd_type.removeinventory == HD_REMOVEINVENTORY.SCORPIONFLY then
					set_timeout(function()
						hd_type = HD_ENT.SCORPIONFLY
						remove_entitytype_inventory(
							hd_type.removeinventory.inventory_ownertype,
							hd_type.removeinventory.inventory_entities
						)
					end, 5)
				end
			end
			if hd_type.replaceoffspring ~= nil then
				if hd_type.replaceoffspring == HD_REPLACE.EGGSAC then
					set_interval(function() enttype_replace_danger({ ENT_TYPE.MONS_GRUB }, HD_ENT.WORMBABY, false, 0, 0) end, 1)
				end
			end
			if hd_type.liquidspawn ~= nil then
				if hd_type.liquidspawn == HD_LIQUIDSPAWN.PIRANHA then
					enttype_replace_danger(
						{
							ENT_TYPE.MONS_MOSQUITO,
							ENT_TYPE.MONS_WITCHDOCTOR,
							ENT_TYPE.MONS_CAVEMAN,
							ENT_TYPE.MONS_TIKIMAN,
							ENT_TYPE.MONS_MANTRAP,
							ENT_TYPE.MONS_MONKEY,
							ENT_TYPE.ITEM_SNAP_TRAP
						},
						HD_ENT.PIRANHA,
						true,
						0, 0
					)
				end
			end
		end
	end
end
-- DANGER DB MODIFICATIONS
-- Modifications that use methods that are only needed to be applied once.
-- This includes:
	-- EntityDB properties
function onlevel_dangers_modifications()
	-- loop through all dangers in global_dangers, setting enemy specific
	if LEVEL_DANGERS[state.theme] and #global_dangers > 0 then
		for i = 1, #global_dangers, 1 do
			if global_dangers[i].entitydb ~= nil and global_dangers[i].entitydb ~= 0 then
				s = spawn(global_dangers[i].entitydb, 0, 0, LAYER.FRONT, 0, 0)
				s_mov = get_entity(s):as_movable()
				
				if global_dangers[i].health_db ~= nil and global_dangers[i].health_db > 0 then
					s_mov.type.life = global_dangers[i].health_db
				end
				if global_dangers[i].sprint_factor ~= nil and global_dangers[i].sprint_factor >= 0 then
					s_mov.type.sprint_factor = global_dangers[i].sprint_factor
				end
				if global_dangers[i].max_speed ~= nil and global_dangers[i].max_speed >= 0 then
					s_mov.type.max_speed = global_dangers[i].max_speed
				end
				if global_dangers[i].jump ~= nil and global_dangers[i].jump >= 0 then
					s_mov.type.jump = global_dangers[i].jump
				end
				if global_dangers[i].dim_db ~= nil and #global_dangers[i].dim_db == 2 then
					s_mov.type.width = global_dangers[i].dim[1]
					s_mov.type.height = global_dangers[i].dim[2]
				end
				if global_dangers[i].damage ~= nil and global_dangers[i].damage >= 0 then
					s_mov.type.damage = global_dangers[i].damage
				end
				if global_dangers[i].acceleration ~= nil and global_dangers[i].acceleration >= 0 then
					s_mov.type.acceleration = global_dangers[i].acceleration
				end
				if global_dangers[i].friction ~= nil and global_dangers[i].friction >= 0 then
					s_mov.type.friction = global_dangers[i].friction
				end
				if global_dangers[i].weight ~= nil and global_dangers[i].weight >= 0 then
					s_mov.type.weight = global_dangers[i].weight
				end
				if global_dangers[i].elasticity ~= nil and global_dangers[i].elasticity >= 0 then
					s_mov.type.elasticity = global_dangers[i].elasticity
				end
				if global_dangers[i].leaves_corpse_behind ~= nil then
					s_mov.type.leaves_corpse_behind = global_dangers[i].leaves_corpse_behind
				end
				
				apply_entity_db(s)
			end
		end
	end
end

-- # TODO: Replace with a manual enemy spawning system.
	-- Notes:
		-- kays:
			-- "I believe it's a 1/N chance that any possible place for that enemy to spawn, it spawns. so in your example, for level 2 about 1/20 of the possible tiles for that enemy to spawn will actually spawn it"
	
		-- Dr.BaconSlices:
			-- "Yup, all it does is roll that chance on any viable tile. There are a couple more quirks, or so I've heard, like enemies spawning with more air around them rather than in enclosed areas, whereas treasure is more likely to be in cramped places. And of course, it checks for viable tiles instead of any tile, so it won't place things inside of floors or other solids, within a liquid it isn't supposed to be in, etc. There's also stuff like bats generating along celiengs instead of the ground, but I don't think I need to explain that haha"
			-- "Oh yeah, I forgot to mention that. The priority is determined based on the list, which you can see here with 50 million bats but 0 spiders. I'm assuming both of their chances are set to 1,1,1,1 but you're still only seeing bats, and that's because they're generating in all of the places that spiders are able to."
	-- Spawn requirements:
		-- Traps
			-- Notes:
				-- replaces FLOOR_* and FLOORSTYLED_* (so platforms count as spaces)
				-- don't spawn in place of gold/rocks/pots
			-- Arrow Trap:
				-- Notes:
					-- are the only damaging entity to spawn in the entrance 
				-- viable tiles:
					-- if there are two blocks and two spaces, mark the inside block for replacement, unless the trigger hitbox would touch the entrance door
				-- while spawning:
					-- don't spawn if it would result in its back touching another arrow trap
				
			-- Tiki Traps:
				-- Notes:
					-- Spawn after arrow traps
					-- are the only damaging entity to spawn in the entrance 
				-- viable space to place:
					-- Require a block on both sides of the block it's standing on
					-- Require a 3x2 space above the spawn
				-- viable tile to replace:
					-- 
				-- while spawning:
					-- don't spawn if it would result in its sides touching another tiki trap 
						-- HD doesn't check for this

-- DANGER MODIFICATIONS - ON.LEVEL
-- Find everything in the level within the given parameters, apply enemy modifications within parameters.
function onlevel_dangers_replace()
	if LEVEL_DANGERS[state.theme] then
		hd_types_toreplace = TableCopy(global_dangers)
		
		n = #hd_types_toreplace
		for i, danger in ipairs(hd_types_toreplace) do
			if danger.toreplace == nil then hd_types_toreplace[i] = nil end
		end
		hd_types_toreplace = CompactList(hd_types_toreplace, n)
		affected = get_entities_by_type(map(hd_types_toreplace, function(hd_type) return hd_type.toreplace end))
		giant_enemy = false
		-- message("#hd_types_toreplace: " .. tostring(#hd_types_toreplace))
		-- message("#affected: " .. tostring(#affected))

		for _,ent_uid in ipairs(affected) do
			e_ent = get_entity(ent_uid)
			if e_ent ~= nil then
				-- ex, ey, el = get_position(ent_uid)
				e_type = e_ent.type.id--e_ent:as_container().type.id
				
				
				variation = nil
				for i = 1, #LEVEL_DANGERS[state.theme].dangers, 1 do
					if (
						LEVEL_DANGERS[state.theme].dangers[i].entity ~= nil and
						LEVEL_DANGERS[state.theme].dangers[i].entity.toreplace ~= nil and
						LEVEL_DANGERS[state.theme].dangers[i].entity.toreplace == e_type and
						(
							LEVEL_DANGERS[state.theme].dangers[i].variation ~= nil and
							LEVEL_DANGERS[state.theme].dangers[i].variation.entities ~= nil and
							LEVEL_DANGERS[state.theme].dangers[i].variation.chances ~= nil and
							#LEVEL_DANGERS[state.theme].dangers[i].variation.entities == 2 and
							#LEVEL_DANGERS[state.theme].dangers[i].variation.chances == 2
						)
					) then
						variation = LEVEL_DANGERS[state.theme].dangers[i].variation
					end
				end
				-- # TODO: Replace dangers.variation with HD_ENT property, including chance.
					-- Frogs can replace mosquitos by having 100% chance. ie, if it was 99%, 1% chance not to spawn.
				-- Make a table consisting of: [ENT_TYPE] = {uid, uid, etc...}
					-- For each ENT_TYPE, split uids evenly amongst `replacements.danger`
					-- Then run each replacement's chance to spawn, replacing it if successful, removing it if unsuccessful.
				replacements = {}
				for _, danger in ipairs(hd_types_toreplace) do
					if danger.toreplace == e_type then replacements[#replacements+1] = danger end
				end
				-- map replacement and their chances here
				if #replacements > 0 then --for _, replacement in ipairs(replacements) do
					hd_ent_tolog = replacements[1]-- replacement
					if variation ~= nil then
						chance = math.random()
						if (chance >= variation.chances[2] and giant_enemy == false) then
							giant_enemy = true
							hd_ent_tolog = variation.entities[2]
						elseif (chance < variation.chances[2] and chance >= variation.chances[1]) then
							hd_ent_tolog = variation.entities[1]
						end
					end
					danger_replace(ent_uid, hd_ent_tolog, true, 0, 0)
				end
			end
		end
	end
end

function onlevel_generation_detection()
	-- level_init()
	global_levelassembly.detection = {
		-- path = TableCopy(LEVEL_PATH)
		-- levelcode = 
	}
end

-- CHUNK GENERATION - ON.LEVEL
-- Script-based roomcode and chunk generation
function onlevel_generation_modification()
	levelw, levelh = 4, 4
	if state.theme == THEME.EGGPLANT_WORLD then
		levelw, levelh = 2, 12
	end
	global_levelassembly.modification = {
		levelrooms = levelrooms_setn(levelw, levelh),
		levelcode = levelcode_setn(levelw, levelh)
	}
	unlock = set_run_unlock()

	gen_levelrooms_nonpath(unlock, true)
	if (
		(
			(state.theme ~= THEME.OLMEC) and
			(state.theme ~= THEME.TIAMAT)
		)
		and (HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.NORMAL)
	) then
		gen_levelrooms_path()
	end
	gen_levelrooms_nonpath(unlock, false)

	gen_levelcode_fill() -- global_levelassembly.modification.levelcode editing

	gen_levelcode_bake() -- spawn tiles in global_levelassembly.modification.levelcode
end

function onlevel_generation_execution()
	global_levelassembly.execution = {
		path = TableCopy(global_levelassembly.detection.path)
	}
	-- overwrite .execution.path with .modification.path in the places that it's not nil
	
-- kinda outdated nonsense:
	-- roomobject ideas:
	-- to spawn a coffin in olmec:
	-- add_coffin
			-- pick a random number between 
		-- 1: create the room object
			-- add to:
				-- subchunkid (optional): determine what to replace
				-- levelcoords (optional): level coordinates it can possibly spawn in (top left and top right)
				-- roomcodes: roomcodes it can possibly spawn
		-- NOTE: Use these like you use HD_ENT; You don't modify, instead use it to place roomcodes into global_levelassembly.roomcodes
		-- 2: figure out if global_levelassembly.roomobjects interfere with the path, if so, clean up
		-- 3: fill in appropriate levelcoord in global_levelassembly.roomobjects
			-- rooomobjects[4][1] = "1132032323..."
	

	-- idols = get_entities_by_type(ENT_TYPE.ITEM_IDOL)
	-- if #idols > 0 and feeling_check("RESTLESS") == true then
		-- idolx, idoly, idoll = get_position(idols[1])
		-- roomx, roomy = locate_roompos(idolx, idoly)
		-- -- cx, cy = remove_room(roomx, roomy, idoll)
		-- tmp_object = {
			-- roomcodes = {
				-- "ttttttttttttttttttttttp0c00ptt0tt0000tt00400000040ttt0tt0tttttp0000ptt1111111111"
				-- --"++++++++++++++++++++++00I000++0++0++0++00400000040+++0++0+++++000000++11GGGGGG11"
			-- },
			-- -- "tttttttttt
			-- -- tttttttttt
			-- -- ttp0c00ptt
			-- -- 0tt0000tt0
			-- -- 0400000040
			-- -- ttt0tt0ttt
			-- -- ttp0000ptt
			-- -- 1111111111"
			
			-- dimensions = { w = 10, h = 8 }
		-- }
		
		-- roomcode = tmp_object.roomcodes[1]
		-- dimw = tmp_object.dimensions.w
		-- dimh = tmp_object.dimensions.h
		-- replace_room(roomcode, dimw, dimh, roomx, roomy, idoll)
	-- end
	
	
	-- fill uids_toembedin using global_levelassembly.modification.levelcode
end

-- Where can AREA unlocks spawn?
	-- When it's in one of the four areas.
		-- Any exceptions to this, such as special areas?
			-- I'm going to ignore special cases, such as WORM where you're in another world, or BLACKMARKET. At least for now.
function detect_viable_unlock_area()
	viable = false
	-- RUN_UNLOCK_AREA[state.theme] ~= nil and RUN_UNLOCK_AREA[state.theme] == false
	for i = 1, #RUN_UNLOCK_AREA, 1 do
		if RUN_UNLOCK_AREA[i].theme == state.theme and RUN_UNLOCK_AREA[i].unlocked == false then
			viable = true
		end
	end
	return viable
end




function levelrooms_setn(levelw, levelh)
	path = {}

	setn(path, levelh)
	for hi = 1, levelh, 1 do
		tw = {}
		setn(tw, levelw)
		path[hi] = tw
	end
	
	-- setn(path, levelw)
	-- for wi = 1, levelw, 1 do
	-- 	th = {}
	-- 	setn(th, levelh)
	-- 	path[wi] = th
	-- end
	
	return path
end


function levelcode_setn(levelw, levelh)
	levelcodew, levelcodeh = levelw*10, levelh*8
	levelcode = {}

	setn(levelcode, levelcodeh)
	for hi = 1, levelcodeh, 1 do
		tw = {}
		setn(tw, levelcodew)
		levelcode[hi] = tw
	end
	
	-- setn(levelcode, levelcodew)
	-- for wi = 1, levelcodew, 1 do
	-- 	th = {}
	-- 	setn(th, levelcodeh)
	-- 	levelcode[wi] = th
	-- end

	return levelcode
end

function set_run_unlock()
	unlock = nil
	-- BronxTaco:
		-- "rando characters will replace the character inside the level feeling coffin"
		-- "you can see this happen in kinnis old AC wr"
	-- jjg27:
		-- "I don't think randos can appear in the coffins for special areas: Worm, Castle, Mothership, City of Gold, Olmec's Lair."
	if RUN_UNLOCK == nil then
		-- chance = math.random()
		-- if (
		-- 	detect_viable_unlock_area() == true and
		-- 	RUN_UNLOCK_AREA_CHANCE >= chance
		-- ) then -- AREA_RAND* unlocks
		-- 	-- RUN_UNLOCK = get_unlock_area()
		-- else -- feeling/theme-based unlocks
			unlock = get_unlock()
			RUN_UNLOCK = unlock
		-- end
	end
	
	-- debug message
	if RUN_UNLOCK ~= nil then
		message("RUN_UNLOCK: " .. RUN_UNLOCK)
	end
	return unlock
end

-- LEVEL HANDLING
-- For cases where room generation is hardcoded to a theme's level
-- and as a result we need to fake the world/level number
function onlevel_levelrules()
	-- Dwelling 1-5 = 1-4 (Dwelling 1-3 -> Dwelling 1-4)
	changestate_onlevel_fake(1,5,THEME.DWELLING,1,4,THEME.DWELLING)
	
	-- TOTEST:
	-- Use S2 Black Market as Flooded Feeling
		-- HD and S2 differences:
			-- S2 black market spawns are 2-2..4
			-- HD spawns are 2-1..3
				-- Prevents the black market from being accessed upon exiting the worm
				-- Gives room for the next level to load as black market

	-- Disable dark levels and vaults "before" you enter the world:
		-- Technically load into a total of 4 hell levels; 5-5 and 5-1..3
		-- on.load 5-5, set state.quest_flags 3 and 2, then warp the player to 5-1
		
		-- -- Jungle 2-0 = 2-1
		-- -- Disable Moon challenge.
		-- changestate_onlevel_fake_applyquestflags(2,1,THEME.JUNGLE, {25}, {})
		-- -- Ice Caves 3-0 = 3-1
		-- -- Disable Waddler's
		-- changestate_onlevel_fake_applyquestflags(3,1,THEME.ICE_CAVES, {10}, {})
		-- -- Temple 4-0 = 4-1
		-- -- Disable Star challenge.
		-- changestate_onlevel_fake_applyquestflags(4,1,THEME.TEMPLE, {26}, {})
		-- -- Volcana 5-5 = 5-1
		-- -- Disable Moon challenge and drill
		-- 	-- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
		-- changestate_onlevel_fake_applyquestflags(5,1,THEME.VOLCANA, {19, 25}, {})
		
	-- -- Volcana 5-1 -> Volcana 5-2
	-- changestate_onlevel_fake(5,5,THEME.VOLCANA,5,2,THEME.VOLCANA)
	-- -- Volcana 5-2 -> Volcana 5-3
	-- changestate_onlevel_fake(5,6,THEME.VOLCANA,5,3,THEME.VOLCANA)
end

-- # TODO: Outdate generation_removeborderfloor()

-- Reverse Level Handling
-- For cases where the entrance and exit need to be swapped
-- function onlevel_reverse_exits()
-- 	if state.theme == THEME.EGGPLANT_WORLD then
-- 		set_timeout(exit_reverse, 15)
-- 	end
-- end


-- # TODO: Improve with:
-- Multi-use method to spawn something on the level only once
-- placing chest and key on levels 2..4
-- make sure you set the "udjat eye spawned" flag on.start
function onlevel_placement_lockedchest()
	if test_flag(state.quest_flags, 17) == true then -- Udjat eye spawned
		lockedchest_uids = get_entities_by_type(ENT_TYPE.ITEM_LOCKEDCHEST)
		-- udjat_level = (#lockedchest_uids > 0)
		if (
			state.theme == THEME.DWELLING and
			(
				state.level == 2 or
				state.level == 3
				-- or state.level == 4
			-- # TODO: Extend availability of udjat chest to level 4.
			) and
			#lockedchest_uids > 0--udjat_level == true
		) then
			random_uid = -1
			random_index = math.random(1, #lockedchest_uids)
			for i, lockedchest_loop_uid in ipairs(lockedchest_uids) do
				if random_index == i then
					random_uid = lockedchest_loop_uid
				else
					kill_entity(lockedchest_loop_uid, 0, 0, 0, 0)
				end
			end
			if random_uid ~= -1 then
				lockedchest_uid = random_uid
				lockedchest_mov = get_entity(lockedchest_uid):as_movable()
				_, chest_y, _ = get_position(lockedchest_uid)
				-- use surface_x to center
				surface_x, surface_y, _ = get_position(lockedchest_mov.standing_on_uid)
				move_entity(lockedchest_uid, surface_x, chest_y, 0, 0)
				
				-- swap cursed pot and chest locations
				cursedpot_uids = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
				if #cursedpot_uids > 0 then 
					cursedpot_uid = cursedpot_uids[1]
					
					pot_x, pot_y, pot_l = get_position(cursedpot_uid) -- initial pot coordinates
					
					-- use surface_x to center
					move_entity(cursedpot_uid, surface_x, chest_y, 0, 0)
					
					move_entity(lockedchest_uid, pot_x, pot_y, 0, 0) -- move chest to initial pot coordinates
				end
			else
				message("onlevel_placement_lockedchest(): No Chest. (random_uid could not be set)")
			end
		-- else message("Couldn't find locked chest.")
		end
	end
end

function generation_removeborderfloor()
	if feeling_check("FLOODED") == true then
		remove_borderfloor()
	end
	-- if Mothership level
	if state.theme == THEME.NEO_BABYLON then
		remove_borderfloor()
	end
end

function onlevel_remove_cursedpot()
	cursedpot_uids = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
	if #cursedpot_uids > 0 and options.hd_og_cursepot_enable == false then
		xmin, ymin, _, _ = get_bounds()
		void_x = xmin - 3.5
		void_y = ymin
		spawn_entity(ENT_TYPE.FLOOR_BORDERTILE, void_x, void_y, LAYER.FRONT, 0, 0)
		for _, cursedpot_uid in ipairs(cursedpot_uids) do
			move_entity(cursedpot_uid, void_x, void_y+1, 0, 0)
		end
	end
end

function onlevel_prizewheel()
	local atms = get_entities_by_type(ENT_TYPE.ITEM_DICE_BET)
	local diceposters = get_entities_by_type(ENT_TYPE.BG_SHOP_DICEPOSTER)
	if #atms > 0 and #diceposters > 0 then
		kill_entity(get_entities_by_type(ENT_TYPE.BG_SHOP_DICEPOSTER)[1])
		for i, atm in ipairs(atms) do
			local atm_mov = get_entity(atms[i]):as_movable()
			local atm_facing = test_flag(atm_mov.flags, ENT_FLAG.FACING_LEFT)
			local atm_x, atm_y, atm_l = get_position(atm_mov.uid)
			local wheel_x_raw = atm_x
			local wheel_y_raw = atm_y+1.5
			
			local facing_dist = 1
			if atm_facing == false then facing_dist = -1 end
			wheel_x_raw = wheel_x_raw + 1 * facing_dist
			
			-- # TODO: Replace the function of `wheel_content` to keep track of the location on the board
			-- Rotate DICEPOSTER for new wheel
			local wheel_content = {
									255,	-- present
									14,		-- money
									23,		-- skull
									15,		-- bigmoney
									23,		-- skull
									14,		-- money
									23,		-- skull
									14,		-- money
									23,		-- skull
									}
			for item_ind = 1, 9, 1 do
				local angle = ((360/9)*item_ind-(360/18))
				local item_coord = rotate(wheel_x_raw, wheel_y_raw, wheel_x_raw, wheel_y_raw+1, angle)
				wheel_items[item_ind] = spawn(ENT_TYPE.ITEM_ROCK, item_coord[1], item_coord[2], atm_l, 0, 0)
				local _item = get_entity(wheel_items[item_ind]):as_movable()
				_item.flags = set_flag(_item.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
				_item.angle = -angle
				_item.animation_frame = wheel_content[item_ind]
				_item.width = 0.7
				_item.height = 0.7
			end
		end
		local dice = get_entities_by_type(ENT_TYPE.ITEM_DIE)
		for j, die in ipairs(dice) do
			local die_mov = get_entity(dice[j]):as_movable()
			die_mov.flags = clr_flag(die_mov.flags, ENT_FLAG.PICKUPABLE)
			die_mov.flags = clr_flag(die_mov.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
			die_mov.flags = set_flag(die_mov.flags, ENT_FLAG.INVISIBLE)
			local con = get_entity(dice[j]):as_container()
			con.inside = 3
		end
	end
		
	-- LOCATE DICE
	-- local die1 = get_entity(dice[1]):as_movable()
	-- local die2 = get_entity(dice[2]):as_movable()
	-- message("uid1 = " .. die1.uid .. ", uid2 = " .. die2.uid)

	-- local con1 = get_entity(dice[1]):as_container()
	-- local con2 = get_entity(dice[2]):as_container()
	-- message("con1 = " .. tostring(con1.inside) .. ", con2 = " .. tostring(con1.inside))
	-- local atm_mov = get_entity(atms[1]):as_movable()
	-- message("atm uid: " .. atm_mov.uid)
end

function onlevel_idoltrap()
	create_idol()
end

function onlevel_remove_mounts()
	mounts = get_entities_by_type({
		ENT_TYPE.MOUNT_TURKEY
		-- ENT_TYPE.MOUNT_ROCKDOG,
		-- ENT_TYPE.MOUNT_AXOLOTL,
		-- ENT_TYPE.MOUNT_MECH
	})
	-- Avoid removing mounts players are riding or holding
	-- avoid = {}
	-- for i = 1, #players, 1 do
		-- holdingmount = get_entity(players[1].uid):as_movable().holding_uid
		-- mount = get_entity(players[1].uid):topmost()
		-- -- message(tostring(mount.uid))
		-- if (
			-- mount ~= players[1].uid and
			-- (
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_TURKEY or
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_ROCKDOG or
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_AXOLOTL
			-- )
		-- ) then
			-- table.insert(avoid, mount)
		-- end
		-- if (
			-- holdingmount ~= -1 and
			-- (
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_TURKEY or
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_ROCKDOG or
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_AXOLOTL
			-- )
		-- ) then
			-- table.insert(avoid, holdingmount)
		-- end
	-- end
	if state.theme == THEME.DWELLING and (state.level == 2 or state.level == 3) then
		for t, mount in ipairs(mounts) do
			-- stop_remove = false
			-- for _, avoidmount in ipairs(avoid) do
				-- if mount == avoidmount then stop_remove = true end
			-- end
			mov = get_entity(mount):as_movable()
			if test_flag(mov.flags, ENT_FLAG.SHOP_ITEM) == false then --and stop_remove == false then
				move_entity(mount, 0, 0, 0, 0)
			end
		end
	end
end

function onlevel_blackmarket_ankh()
	if detect_s2market() == true then
		
		-- find the hedjet
		hedjets = get_entities_by_type(ENT_TYPE.ITEM_PICKUP_HEDJET)
		if #hedjets ~= 0 then
			-- spawn an ankh at the location of the hedjet
			hedjet_uid = hedjets[1]
			hedjet_mov = get_entity(hedjet_uid):as_movable()
			x, y, l = get_position(hedjet_uid)
			ankh_uid = spawn(ENT_TYPE.ITEM_PICKUP_ANKH, x, y, l, 0, 0)
			-- # IDEA: Replace Ankh with skeleton key, upon pickup in inventory, give player ankh powerup.
				-- Rename shop string for skeleton key as "Ankh", replace skeleton key with Ankh texture.
			-- # TODO: Slightly unrelated, but make a method to remove/replace useless items. Depending on the context, replace it with another item in the pool of even chance.
				-- Skeleton key
				-- Metal Shield
			ankh_mov = get_entity(ankh_uid):as_movable()
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.SHOP_ITEM)
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
			if options.hd_og_ankhprice == true then
				ankh_mov.price = 50000.0
			else
				ankh_mov.price = hedjet_mov.price
			end
			kill_entity(hedjet_uid)
			-- set flag 23 and 20
			-- detach/spawn_entity_over the purchase icons from the headjet, apply them to the ankh
			-- kill hedjet
			-- hedjet x: 37.500 y: 69.890
			-- FX_SALEICON y: 0.790-0.830?
			-- FX_SALEDIALOG_CONTAINER y: 0.46
			spawn_entity_over(ENT_TYPE.FX_SALEICON, ankh_uid, 0, 0)
			spawn_entity_over(ENT_TYPE.FX_SALEDIALOG_CONTAINER, ankh_uid, 0, 0)
		end
	end
end

function onlevel_acidbubbles()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_interval(bubbles, 35) -- 15)
	end
end

-- # TODO: Outdated. Revise to HD_ROOMOBJECT.WORM setroom location and make a new pickup that gives permanent firewhip. 
	-- IDEAS:
		-- Replace with actual crysknife and upgrade player damage.
			-- put crysknife animations in the empty space in items.png (animation_frame = 120 - 126 for crysknife) and then animating it behind the player
			-- Can't make player whip invisible, apparently, so that might be hard to do.
		-- Use powerpack
			-- It's the spiritual successor to the crysknife, so its a fitting replacement
			-- I'm planning to make bacterium use FLOOR_THORN_VINE for damage, but now I can even make them break with the powerpack if I also use bush blocks
			-- In my experience in HD, a good way of dispatching bacterium was with bombs, but it was hard to time correctly. So the powerpack would make bombs even more effective
function onlevel_add_crysknife()
	if state.theme == THEME.EGGPLANT_WORLD then
		x = 17
		y = 77
		if (math.random(2) == 2) then
			x = x - 10
		end
		create_crysknife(x, y, LAYER.FRONT)
	end
end

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY, NOTHING
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_YAMA_PLATFORM)

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY, NOTHING
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.BG_YAMA_BODY)

-- set_post_entity_spawn(function(entity)
--     entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.TAKE_NO_DAMAGE) -- Unneeded(?)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_YAMA)
-- # TODO: Relocate MONS_YAMA to a better place. Can't move him to back layer, it triggers the slow music :(
	-- OR: improve hiding him. Could use set_post_entity_spawn.
function onlevel_hide_yama()
	if state.theme == THEME.EGGPLANT_WORLD then
		kill_entity(get_entities_by_type(ENT_TYPE.BG_YAMA_BODY)[1])
		for i, yama_floor in ipairs(get_entities_by_type(ENT_TYPE.FLOOR_YAMA_PLATFORM)) do
			kill_entity(yama_floor)
		end
		local yama = get_entity(get_entities_by_type(ENT_TYPE.MONS_YAMA)[1]):as_movable()
		yama.flags = set_flag(yama.flags, ENT_FLAG.INVISIBLE)
		yama.flags = set_flag(yama.flags, ENT_FLAG.TAKE_NO_DAMAGE) -- Unneeded(?)
		yama.flags = set_flag(yama.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
	end
end

-- # TODO: Once COG generation is done, move into tile spawning
function onlevel_add_botd()
	if state.theme == THEME.CITY_OF_GOLD then
		if not options.hd_debug_item_botd_give then
			bookofdead_pickup_id = spawn(ENT_TYPE.ITEM_PICKUP_TABLETOFDESTINY, 6, 99.05, LAYER.FRONT, 0, 0)
			book_ = get_entity(bookofdead_pickup_id):as_movable()
			book_.animation_frame = 205
		end
	end
end

function onlevel_boss_init()
	if state.theme == THEME.OLMEC then
		BOSS_STATE = BOSS_SEQUENCE.CUTSCENE
		cutscene_move_olmec_pre()
		cutscene_move_cavemen()
		create_door_ending(41, 99, LAYER.FRONT)

		HELL_X = math.random(4,41)
		create_door_exit_to_hell(HELL_X, HELL_Y, LAYER.FRONT)
	end
end

function cutscene_move_olmec_pre()
	olmecs = get_entities_by_type(ENT_TYPE.ACTIVEFLOOR_OLMEC)
	if #olmecs > 0 then
		OLMEC_ID = olmecs[1]
		move_entity(OLMEC_ID, 24.500, 100.500, 0, 0)
	end
end

function cutscene_move_olmec_post()
	move_entity(OLMEC_ID, 22.500, 99.500, 0, 0)--24.500, 100.500, 0, 0)
end

function cutscene_move_cavemen()
	-- # TODO: OLMEC cutscene - Once custom hawkman AI is done:
	-- create a hawkman and disable his ai
	-- set_timeout() to reenable his ai and set his stuntimer.
	-- **does set_timeout() work during cutscenes?
		-- if not, use set_global_timeout
			-- set_timeout() accounts for pausing the game while set_global_timeout() does not
	-- **consider problems for skipping the cutscene
	cavemen = get_entities_by_type(ENT_TYPE.MONS_CAVEMAN)
	for i, caveman in ipairs(cavemen) do
		move_entity(caveman, 17.500+i, 99.05, 0, 0)
	end
end

-- # TODO: Revise replacing powderkegs into onlevel_generation. Also, note that the mines has a small chance of spawning powderkegs.
-- function onlevel_replace_powderkegs()
-- if state.theme == THEME.VOLCANA then
-- -- replace powderkegs with pushblocks, move_entity(powderkeg, 0, 0, 0, 0)
	-- end
-- end

-- function onlevel_generation_pushblocks()
	-- if state.theme == THEME.OLMEC then
		-- Pushblock generation. Have a random small chance to replace all FLOORSTYLED_STONE/FLOOR_GENERIC blocks with a ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK.
		-- Exceptions include not having a FLOORSTYLED_STONE/FLOOR_GENERIC block under it and being at the y coordinate of 98.
		-- get_entities_by_type({ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOORSTYLED_STONE})
		-- Probably best to pick a number between 5 and 20, and then choose that amount of random blocks out of the array.
		-- The problem is, there's going to be a lot of visible broken terrain as a result.
	-- end
-- end

-- Set level feelings (not to be confused with `feeling_set`)
function onlevel_set_feelings()
	if (
		(HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.NORMAL)
		-- (HD_WORLDSTATE_STATE ~= HD_WORLDSTATE_STATUS.TUTORIAL) or
		-- (HD_WORLDSTATE_STATE ~= HD_WORLDSTATE_STATUS.TESTING)
	) then
		--[[
			Game-wide Feelings
		--]]
		-- Vaults
		if (
			detect_same_levelstate(THEME.DWELLING, 1, 1) == false and
			detect_level_non_boss() and
			detect_level_non_special()
		) then
			feeling_set_once("VAULT", {state.level})
		end
		
		--[[
			Mines
		--]]
		if state.theme == THEME.DWELLING then
			encounter = math.random(1,2)
			if encounter == 1 then
				feeling_set_once("SPIDERLAIR", {state.level})
				-- pots will not spawn on this level.
				-- Spiders, spinner spiders, and webs appear much more frequently.
				-- Spawn web nests (probably RED_LANTERN, remove  and reskin it)
				-- Move pots into the void
			elseif encounter == 2 then
				feeling_set_once("SNAKEPIT", {state.level})
			end
		end
		--[[
			Jungle
		--]]
		if state.theme == THEME.JUNGLE then
			if feeling_check("HAUNTEDCASTLE") == false then
				if detect_s2market() == true then
					encounter = 1
					if ( -- if tikivillage has already been assigned, roll for flooded. Otherwise roll both
						global_feelings["TIKIVILLAGE"].load ~= nil
					) then
						encounter = 2
					else
						encounter = math.random(1,2)
					end
					if encounter == 1 then
						feeling_set_once("TIKIVILLAGE", {state.level})
					elseif encounter == 2 then
						feeling_set_once("FLOODED", {state.level})
					end
				else
					feeling_set_once("TIKIVILLAGE", {state.level})
				end
				
				
				if feeling_check("TIKIVILLAGE") == false then
					feeling_set_once("RESTLESS", {state.level})
				end
			end
			-- # TODO: Set BLACKMARKET_ENTRANCE and BLACKMARKET here
		end
		--[[
			Ice Caves
		--]]
		if state.theme == THEME.ICE_CAVES then
			
			-- # TODO(?): Really weird and possibly unintentional exception for MOAI spawn:
				-- The Moai is found on either level 3-2 or 3-3, unless the player went to The Worm and The Mothership, in that case The Moai will appear in 3-4 (after The Mothership).
			if state.level == 2 then
				feeling_set_once("MOAI", {2, 3})
			end
			
			if state.level == 4 then
				if global_feelings["MOTHERSHIPENTRANCE"].load == nil then
					feeling_set_once("MOTHERSHIPENTRANCE", {state.level})
				else
					global_feelings["MOTHERSHIPENTRANCE"].load = nil
					feeling_set_once("YETIKINGDOM", {state.level})
				end
				-- This level feeling only, and always, occurs on level 3-4.
					-- The entrance to Mothership sends you to 3-3 with THEME.NEO_BABYLON.
					-- When you exit, you will return to the beginning of 3-4 and be forced to do the level again before entering the Temple.
					-- Only available once in a run
			end
			
			encounter = math.random(1,2)
			
			if encounter == 1 and
			(
				feeling_check("MOAI") == false and
				state.level ~= 4
			) then
				feeling_set_once("YETIKINGDOM", {1,2,3})
			elseif encounter == 2 then
				feeling_set_once("UFO", {state.level})
			end
		end
		--[[
			Temple
		--]]
		if state.theme == THEME.TEMPLE then
			feeling_set_once("SACRIFICIALPIT", {1,2,3})
		end
		
		-- Currently hardcoded but keeping this here just in case
		--[[
			Hell
		--]]
		-- if state.theme == THEME.VOLCANA and state.level == 1 then
			-- feeling_set("VLAD", {state.level})
		-- end
	end
end

function onlevel_set_feelingToastMessage()
	-- theme message priorities are here (ie; rushingwater over restless)
	-- NOTES:
		-- Black Market, COG and Beehive are currently handled by the game
	
	loadchecks = TableCopy(global_feelings)
	
	n = #loadchecks
	for feelingname, loadcheck in pairs(loadchecks) do
		if (
			-- detect_feeling_themes(feelingname) == false or
			-- (
				-- detect_feeling_themes(feelingname) == true and
				-- (
					-- (loadcheck.load == nil or loadcheck.message == nil) or
					-- (feeling_check(feelingname))
				-- )
			-- )
			feeling_check(feelingname) == false
		) then loadchecks[feelingname] = nil end
	end
	loadchecks = CompactList(loadchecks, n)
	
	MESSAGE_FEELING = nil
	for feelingname, feeling in pairs(loadchecks) do
		-- Message Overrides may happen here:
		-- For example:
			-- if feelingname == "FLOODED" and feeling_check("RESTLESS") == true then break end
		MESSAGE_FEELING = feeling.message
	end
end

function onlevel_toastfeeling()
	if (
		MESSAGE_FEELING ~= nil and
		options.hd_debug_feelingtoast_disable == false
	) then
		toast(MESSAGE_FEELING)
	end
end

function oncamp_tunnelman_spawn()
	marla_uid = spawn_entity_nonreplaceable(ENT_TYPE.MONS_MARLA_TUNNEL, 15, 86, LAYER.FRONT, 0, 0)
	marla = get_entity(marla_uid)
	marla.flags = clr_flag(marla.flags, ENT_FLAG.FACING_LEFT)
	return marla_uid
end

function oncamp_shortcuts()

	--loop once for door materials,
	--once done, concatonate LOGIC_DOOR and ITEM_CONSTRUCTION_SIGN lists, make sure construction signs are last.
	--loop to move logic_door and construction signs. If it's a logic_door, move its accessories as well.
	--shortcut doors (if construction sign,  here too): LOGIC_DOOR, FLOOR_DOOR_STARTING_EXIT, BG_DOOR(when moving this, +0.31 to y) ENT_TYPE.ITEM_CONSTRUCTION_SIGN, 
	--3: x=21.000,	y=90.000
	--2: 			y-3=(87.000)
	--1: 			y-6=(84.000)
	--shortcut signs: ENT_TYPE.ITEM_SHORTCUT_SIGN
	--(+2.0 to x)
	
	-- shortcut_signframes = {}
	shortcut_flagstocheck = {4, 7, 10}
	shortcut_worlds = {2, 3, 4}
	shortcut_levels = {1, 1, 1}--PREFIRSTLEVEL_NUM, PREFIRSTLEVEL_NUM, PREFIRSTLEVEL_NUM}
	shortcut_themes = {THEME.JUNGLE, THEME.ICE_CAVES, THEME.TEMPLE}
	shortcut_doortextures = {
		TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1,
		TEXTURE.DATA_TEXTURES_FLOOR_ICE_1,
		TEXTURE.DATA_TEXTURES_FLOOR_TEMPLE_1
	}
	
	-- Placement of first shortcut door in HD: 16.0
	new_x = 19.0 -- adjusted for S2 camera
	for i, flagtocheck in ipairs(shortcut_flagstocheck) do
		-- door_or_constructionsign
		if savegame.shortcuts >= flagtocheck then
			spawn_door(new_x, 86, LAYER.FRONT, shortcut_worlds[i], shortcut_levels[i], shortcut_themes[i])
			-- spawn_entity(ENT_TYPE.FLOOR_DOOR_STARTING_EXIT, new_x, 86, 0, 0)

			door_bg = spawn_entity(ENT_TYPE.BG_DOOR, new_x, 86.31, LAYER.FRONT, 0, 0)
			get_entity(door_bg):set_texture(shortcut_doortextures[i])
			get_entity(door_bg).animation_frame = 1
			
			sign = spawn_entity(ENT_TYPE.ITEM_SHORTCUT_SIGN, new_x+1, 86-0.5, LAYER.FRONT, 0, 0)
			sign_animation_frame = get_entity(sign).animation_frame
			get_entity(sign).animation_frame = sign_animation_frame + (i-1)
		else
			spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, new_x, 86, LAYER.FRONT, 0, 0)
		end
		-- Space between shortcut doors in HD: 4.0
		new_x = new_x + 3 -- adjusted for S2 camera
	end

	-- fix gap in floor where S2 shortcut would normally spawn
	spawn(ENT_TYPE.FLOOR_GENERIC, 21, 84, LAYER.FRONT, 0, 0)
end

-- OVERHAUL. Keep the dice poster and rotating that. Use a rock for the needle and use in place of animation_frame = 193
function onframe_prizewheel()
	-- Prize Wheel
	-- Purchase Detection/Handling
	if #wheel_items > 0 then
	local atm = get_entities_by_type(ENT_TYPE.ITEM_DICE_BET)[1]
	local atm_mov = get_entity(atm):as_movable()
	local atm_facing = test_flag(atm_mov.flags, ENT_FLAG.FACING_LEFT)
	local atm_prompt = test_flag(atm_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
	local atm_x, atm_y, atm_l = get_position(atm_mov.uid)
	local wheel_x_raw = atm_x
	local wheel_y_raw = atm_y+1.5
	local facing_dist = 1
	if atm_facing == false then facing_dist = -1 end
	wheel_x_raw = wheel_x_raw + 1 * facing_dist

	if atm_prompt == false then
		if WHEEL_SPINNING == false then
			WHEEL_SPINNING = true
			wheel_tick = 0
		end

		if wheel_tick < WHEEL_SPINTIME then
			for i, item in ipairs(wheel_items) do
				local item_x, item_y, item_l = get_position(wheel_items[i])
				local item_e = get_entity(wheel_items[i]):as_movable()
				wheel_speed = 50 * 1.3^(-0.025*wheel_tick)
				local item_coord = rotate(wheel_x_raw, wheel_y_raw, item_x, item_y, wheel_speed)
				move_entity(wheel_items[i], item_coord[1], item_coord[2], 0, 0)
				item_e.angle = -1 * wheel_speed
			end
			wheel_tick = wheel_tick + 1
			else
				atm_mov.flags = set_flag(atm_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
				wheel_tick = WHEEL_SPINTIME
				WHEEL_SPINNING = false
			end
		end
	end
end

function onframe_idoltrap()
	-- Idol trap activation
	if IDOLTRAP_TRIGGER == false and IDOL_UID ~= nil and idol_disturbance() then
		IDOLTRAP_TRIGGER = true
		if feeling_check("RESTLESS") == true then
			create_ghost()
		elseif state.theme == THEME.DWELLING and IDOL_X ~= nil and IDOL_Y ~= nil then
			spawn(ENT_TYPE.LOGICAL_BOULDERSPAWNER, IDOL_X, IDOL_Y, idol_l, 0, 0)
		elseif state.theme == THEME.JUNGLE then
			-- break the 6 blocks under it in a row, starting with the outside 2 going in
			if #idoltrap_blocks > 0 then
				kill_entity(idoltrap_blocks[1])
				kill_entity(idoltrap_blocks[6])
				set_timeout(function()
					kill_entity(idoltrap_blocks[2])
					kill_entity(idoltrap_blocks[5])
				end, idoltrap_timeout)
				set_timeout(function()
					kill_entity(idoltrap_blocks[3])
					kill_entity(idoltrap_blocks[4])
				end, idoltrap_timeout*2)
			end
		elseif state.theme == THEME.ICE_CAVES then
			set_timeout(function()
				boulder_spawners = get_entities_by_type(ENT_TYPE.LOGICAL_BOULDERSPAWNER)
				if #boulder_spawners > 0 then
					kill_entity(boulder_spawners[1])
				end
			end, 3)
		end
	elseif IDOLTRAP_TRIGGER == true and IDOL_UID ~= nil and state.theme == THEME.DWELLING then
		if BOULDER_UID == nil then
			boulders = get_entities_by_type(ENT_TYPE.ACTIVEFLOOR_BOULDER)
			if #boulders > 0 then
				BOULDER_UID = boulders[1]
				-- # TODO: Obtain the last owner of the idol upon disturbing it. If no owner caused it, THEN select the first player alive.
				if options.hd_og_boulder_agro_disable == false then
					boulder = get_entity(BOULDER_UID):as_movable()
					for i, player in ipairs(players) do
						boulder.last_owner_uid = player.uid
					end
				end
			end
		else
			boulder = get_entity(BOULDER_UID)
			if boulder ~= nil then
				boulder = get_entity(BOULDER_UID):as_movable()
				x, y, l = get_position(BOULDER_UID)
				BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
				BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
				if boulder.velocityx >= BOULDER_CRUSHPREVENTION_VELOCITY or boulder.velocityx <= -BOULDER_CRUSHPREVENTION_VELOCITY then
					BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE*BOULDER_CRUSHPREVENTION_MULTIPLIER
					BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT*BOULDER_CRUSHPREVENTION_MULTIPLIER
				else 
					BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
					BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
				end
				BOULDER_SX = ((x - boulder.hitboxx)-BOULDER_CRUSHPREVENTION_EDGE_CUR)
				BOULDER_SY = ((y + boulder.hitboxy)-BOULDER_CRUSHPREVENTION_EDGE_CUR)
				BOULDER_SX2 = ((x + boulder.hitboxx)+BOULDER_CRUSHPREVENTION_EDGE_CUR)
				BOULDER_SY2 = ((y + boulder.hitboxy)+BOULDER_CRUSHPREVENTION_HEIGHT_CUR)
				local blocks = get_entities_overlapping(
					ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
					0,
					BOULDER_SX,
					BOULDER_SY,
					BOULDER_SX2,
					BOULDER_SY2,
					LAYER.FRONT
				)
				blocks = TableConcat(
					blocks, get_entities_overlapping(
						ENT_TYPE.ACTIVEFLOOR_POWDERKEG,
						0,
						BOULDER_SX,
						BOULDER_SY,
						BOULDER_SX2,
						BOULDER_SY2,
						LAYER.FRONT
					)
				)
				for _, block in ipairs(blocks) do
					kill_entity(block)
				end
				if options.hd_debug_info_boulder == true then
					touching = get_entities_overlapping(
						0,
						0x1,
						BOULDER_SX,
						BOULDER_SY,
						BOULDER_SX2,
						BOULDER_SY2,
						LAYER.FRONT
					)
					if #touching > 0 then BOULDER_DEBUG_PLAYERTOUCH = true else BOULDER_DEBUG_PLAYERTOUCH = false end
				end
			else message("Boulder crushed :(") end
		end
	end
end

function onframe_acidpoison()
	-- Worm LEVEL
	if state.theme == THEME.EGGPLANT_WORLD then
		-- Acid damage
		for i, player in ipairs(players) do
			-- local spelunker_mov = get_entity(player):as_movable()
			local spelunker_swimming = test_flag(player.more_flags, 11)
			local poisoned = player:is_poisoned()
			x, y, l = get_position(player.uid)
			if spelunker_swimming and player.health ~= 0 and not poisoned then
				if acid_tick <= 0 then
					spawn(ENT_TYPE.ITEM_ACIDSPIT, x, y, l, 0, 0)
					acid_tick = ACID_POISONTIME
				else
					acid_tick = acid_tick - 1
				end
			else
				acid_tick = ACID_POISONTIME
			end
		end
	end
end

function tongue_animate()
	if (
		state.theme == THEME.JUNGLE and -- or state.theme == THEME.ICE_CAVES) and
		TONGUE_UID ~= nil and
		(
			TONGUE_STATE == TONGUE_SEQUENCE.READY or
			TONGUE_STATE == TONGUE_SEQUENCE.RUMBLE
		)
	) then
		x, y, l = get_position(TONGUE_UID)
		for _ = 1, 3, 1 do
			if math.random() >= 0.5 then spawn_entity(ENT_TYPE.FX_WATER_DROP, x+((math.random()*1.5)-1), y+((math.random()*1.5)-1), l, 0, 0) end
		end
	end
end

function onframe_tonguetimeout()
	if state.theme == THEME.JUNGLE and TONGUE_UID ~= nil and TONGUE_STATE ~= TONGUE_SEQUENCE.GONE then --or state.theme == THEME.ICE_CAVES
		local tongue = get_entity(TONGUE_UID):as_movable()
		x, y, l = get_position(TONGUE_UID)
		checkradius = 1.5
		
		if tongue ~= nil and TONGUE_STATECOMPLETE == false then
			-- TONGUE_SEQUENCE = { ["READY"] = 1, ["RUMBLE"] = 2, ["EMERGE"] = 3, ["SWALLOW"] = 4 , ["GONE"] = 5 }
			if TONGUE_STATE == TONGUE_SEQUENCE.READY then
				damsels = get_entities_at(ENT_TYPE.MONS_PET_DOG, 0, x, y, l, checkradius)
				damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_CAT, 0, x, y, l, checkradius))
				damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_HAMSTER, 0, x, y, l, checkradius))
				if #damsels > 0 then
					damsel = get_entity(damsels[1]):as_movable()
					-- when alive damsel move_state == 9 for 4 seconds?
					-- message("damsel.move_state: " .. tostring(damsel.state))
					stuck_in_web = test_flag(damsel.more_flags, 8)--9)
					-- local falling = (damsel.state == 9)
					dead = test_flag(damsel.flags, ENT_FLAG.DEAD)
					if (
						(stuck_in_web == true)
						-- (dead == false and falling == true)
					) then
						if tongue_tick <= 0 then
							spawn_entity(ENT_TYPE.LOGICAL_BOULDERSPAWNER, x, y, l, 0, 0)
							TONGUE_STATE = TONGUE_SEQUENCE.RUMBLE
						else
							tongue_tick = tongue_tick - 1
						end
					else
						tongue_tick = TONGUE_ACCEPTTIME
					end
				end
			elseif TONGUE_STATE == TONGUE_SEQUENCE.RUMBLE then
				-- kill the boulder once you find one (or kill LOGICAL_BOULDERSPAWNER before it spawns one)
				set_timeout(function()
				
					if TONGUE_BG_UID ~= nil then
						worm_background = get_entity(TONGUE_BG_UID)
						worm_background.animation_frame = 4 -- 4 is the hole frame for Jungle, ice caves: probably 8
					else message("TONGUE_BG_UID is nil :(") end
					
					-- # TODO: Method to animate rubble better.
					for _ = 1, 3, 1 do
						spawn_entity(ENT_TYPE.ITEM_RUBBLE, x, y, l, ((math.random()*1.5)-1), ((math.random()*1.5)-1))
						spawn_entity(ENT_TYPE.ITEM_RUBBLE, x, y, l, ((math.random()*1.5)-1), ((math.random()*1.5)-1))
						spawn_entity(ENT_TYPE.ITEM_RUBBLE, x, y, l, ((math.random()*1.5)-1), ((math.random()*1.5)-1))
					end
					
					TONGUE_STATE = TONGUE_SEQUENCE.EMERGE
					TONGUE_STATECOMPLETE = false
				end, 65)
				TONGUE_STATECOMPLETE = true
			elseif TONGUE_STATE == TONGUE_SEQUENCE.EMERGE then
				set_timeout(function()
					-- level exit should activate here
					tongue_exit()
					TONGUE_STATE = TONGUE_SEQUENCE.SWALLOW
					TONGUE_STATECOMPLETE = false
				end, 40)
				TONGUE_STATECOMPLETE = true
			elseif TONGUE_STATE == TONGUE_SEQUENCE.SWALLOW then
				set_timeout(function()
					-- message("boulder deletion at state.time_level: " .. tostring(state.time_level))
					boulder_spawners = get_entities_by_type(ENT_TYPE.LOGICAL_BOULDERSPAWNER)
					kill_entity(boulder_spawners[1])
					
					kill_entity(TONGUE_UID)
					TONGUE_UID = nil
					
					TONGUE_STATE = TONGUE_SEQUENCE.GONE
				end, 40)
				TONGUE_STATECOMPLETE = true
			end -- never reaches "TONGUE_SEQUENCE.GONE"
		end
	end
end

function tongue_exit()
	x, y, l = get_position(TONGUE_UID)
	checkradius = 1.5
	local damsels = get_entities_at(ENT_TYPE.MONS_PET_DOG, 0, x, y, l, checkradius)
	damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_CAT, 0, x, y, l, checkradius))
	damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_HAMSTER, 0, x, y, l, checkradius))
	local ensnaredplayers = get_entities_at(0, 0x1, x, y, l, checkradius)
	
	-- TESTING OVERRIDE
	-- if #ensnaredplayers > 0 then
		-- set_timeout(function()
			-- warp(state.world, state.level+1, THEME.EGGPLANT_WORLD)
		-- end, 20)
	-- end
	
	exits_doors = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EXIT)
	exits_worm = get_entities_at(ENT_TYPE.FLOOR_DOOR_EXIT, 0, x, y, l, 1)
	worm_exit_uid = exits_worm[1]
	exitdoor = nil
	for _, exits_door in ipairs(exits_doors) do
		if exits_door ~= worm_exit_uid then exitdoor = exits_door end
	end
	if exitdoor ~= nil then
		exit_x, exit_y, _ = get_position(exitdoor)
		for _, damsel_uid in ipairs(damsels) do
			damsel = get_entity(damsel_uid):as_movable()
			stuck_in_web = test_flag(damsel.more_flags, 9)
			-- local dead = test_flag(damsel.flags, ENT_FLAG.DEAD)
			if (
				(stuck_in_web == true)
				-- # TODO: Don't teleport damsel if dead(? did this happen if the damsel was dead in HD? Investigate.)
				-- (dead == false)
			) then
				damsel.stun_timer = 0
				if options.hd_debug_scripted_enemies_show == false then
					damsel.flags = set_flag(damsel.flags, ENT_FLAG.INVISIBLE)
				end
				damsel.flags = clr_flag(damsel.flags, ENT_FLAG.INTERACT_WITH_WEBS)-- disable interaction with webs
				-- damsel.flags = clr_flag(damsel.flags, ENT_FLAG.STUNNABLE)-- disable stunable
				damsel.flags = set_flag(damsel.flags, ENT_FLAG.TAKE_NO_DAMAGE)--6)-- enable take no damage
				move_entity(damsel_uid, exit_x, exit_y+0.1, 0, 0)
			end
		end
	else
		message("No Level Exitdoor found, can't force-rescue damsels.")
	end
	if worm_exit_uid ~= nil then
		worm_exit = get_entity(worm_exit_uid)
		worm_exit.flags = clr_flag(worm_exit.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS) -- resume ai to magnetize damsels
		if #ensnaredplayers > 0 then
			-- unlock worm door, let players in
			unlock_door_at(x, y)
			local door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				if options.hd_debug_scripted_enemies_show == true then
					door_platform.flags = clr_flag(door_platform.flags, ENT_FLAG.INVISIBLE)
				end
				door_platform.flags = set_flag(door_platform.flags, ENT_FLAG.SOLID)
				door_platform.flags = set_flag(door_platform.flags, ENT_FLAG.IS_PLATFORM)
			end
			
			for _, ensnaredplayer_uid in ipairs(ensnaredplayers) do
				ensnaredplayer = get_entity(ensnaredplayer_uid):as_movable()
				ensnaredplayer.stun_timer = 0
				-- ensnaredplayer.more_flags = set_flag(ensnaredplayer.more_flags, 16)-- disable input
				
				if options.hd_debug_scripted_enemies_show == false then
					ensnaredplayer.flags = set_flag(ensnaredplayer.flags, ENT_FLAG.INVISIBLE)-- make each player invisible
				end
					-- disable interactions with anything else that may interfere with entering the door
				ensnaredplayer.flags = clr_flag(ensnaredplayer.flags, ENT_FLAG.INTERACT_WITH_WEBS)-- disable interaction with webs
				ensnaredplayer.flags = set_flag(ensnaredplayer.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)-- disable interaction with objects
				
				-- teleport player to the newly created invisible door (platform is at y+0.05)
				move_entity(ensnaredplayer_uid, x, y+0.15, 0, 0)
			end
			
			
			-- after enough time passed to let the player touch the platform, force door enter button
			set_timeout(function()
				x, y, l = get_position(TONGUE_UID)
				checkradius = 1.5
				local ensnaredplayers = get_entities_at(0, 0x1, x, y, l, checkradius)
				for _, ensnaredplayer_uid in ipairs(ensnaredplayers) do
					steal_input(ensnaredplayer_uid)
					send_input(ensnaredplayer_uid, BUTTON.DOOR)
				end
			end, 15)
			
			-- lock worm door
			set_timeout(function()
				x, y, l = get_position(TONGUE_UID)
				local exits = get_entities_at(ENT_TYPE.FLOOR_DOOR_EXIT, 0, x, y, l, 1)
				local door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
				if #exits > 0 then
					if #door_platforms > 0 then
						door_platform = get_entity(door_platforms[1])
						if options.hd_debug_scripted_enemies_show == true then
							door_platform.flags = set_flag(door_platform.flags, ENT_FLAG.INVISIBLE)
						end
						door_platform.flags = clr_flag(door_platform.flags, ENT_FLAG.SOLID)
						door_platform.flags = clr_flag(door_platform.flags, ENT_FLAG.IS_PLATFORM)
					end
					worm_exit = get_entity(exits[1])
					worm_exit.flags = set_flag(worm_exit.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS) -- pause ai to prevent magnetizing damsels
					lock_door_at(x, y)
				end
			end, 55)
		end
		
		-- hide worm tongue
		tongue = get_entity(TONGUE_UID)
		if options.hd_debug_scripted_enemies_show == false then
			tongue.flags = set_flag(tongue.flags, ENT_FLAG.INVISIBLE)
		end
		tongue.flags = set_flag(tongue.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)-- disable interaction with objects
	else
		message("No Worm Exitdoor found, can't force-exit players.")
	end
end

-- Specific to jungle; replace any jungle danger currently submerged in water with a tadpole.
-- Used to be part of onlevel_dangers_replace().
function enttype_replace_danger(enttypes, hd_type, check_submerged, _vx, _vy)
	check_submerged = check_submerged or false
	
	dangers_uids = get_entities_by_type(enttypes)
	for _, danger_uid in ipairs(dangers_uids) do
		
		d_mov = get_entity(danger_uid):as_movable()
		d_submerged = test_flag(d_mov.more_flags, 11)
		if (
			check_submerged == false or
			(check_submerged == true and d_submerged == true)
		) then
		
			
			-- d_mov = get_entity(danger_uid):as_movable()
			-- d_type = get_entity(uid):as_container().type.id
			-- uid_to_track = danger_uid
			
			-- if d_type ~= hd_type.toreplace
				-- x, y, l = get_position(danger_uid)
				-- vx = _vx or d_mov.velocityx
				-- vy = _vy or d_mov.velocityy
				-- uid_to_track = spawn(hd_type.tospawn, x, y, l, vx, vy)
				-- move_entity(danger_uid, 0, 0, 0, 0)
			-- end
			
			danger_replace(danger_uid, hd_type, false, _vx, _vy)
		end
	end
end

function onframe_manage_inventory()
	inventory_checkpickup_botd()
end

-- DANGER MODIFICATIONS - ON.FRAME
-- Massive enemy behavior handling method
function onframe_manage_dangers()
	n = #danger_tracker
	for i, danger in ipairs(danger_tracker) do
		danger_mov = get_entity(danger.uid)
		killbool = false
		if danger_mov == nil then
			killbool = true
		elseif danger_mov ~= nil then
			
			if danger_mov.move_state == 6 then
				-- On move_state jump, run a random chance to spit out a frog instead. velocityx = 0 and velocityy = 0.
				-- When it's within agro distance (find this value by drawing the recorded distance between you and the frog) and when d_mov.standing_on_uid ~= -1 and when not facing the player, flip_entity()
				if danger.hd_type == HD_ENT.GIANTFROG then
					behavior_giantfrog(danger.uid)
				end
			end
		
		
			danger_mov = get_entity(danger.uid):as_movable()
			danger.x, danger.y, danger.l = get_position(danger.uid)
			if danger.behavior ~= nil then
				-- # IDEA: Enemy Behavior Ideas
				-- for i, enemy in ipairs(get_entities_by_type({ENT_TYPE.MONS_TADPOLE})) do
				-- If enemy is tadpole
					-- if haunted level then
						-- - for each check what animation frame it's on and replace following frames:
						-- - 209-213 -> 227-231
						-- - 214 -> 215
						-- - 106-111 -> 91-96
						-- - 112 -> 127
					-- end
				-- elseif enemy is cloned_shopkeeper and theme == jungle (and haunted?) then
					-- change frames to black knight
					-- if weapon in inventory is shotgun(may use a set_timeout to let it spawn first)
						-- kill shotgun
						-- spawn shield
						-- give shield
					-- end
				-- elseif enemy is caveman and theme == jungle (and haunted?) then
					-- change frames to green_knight
					-- if dead and uid is still on a global array (TODO)
						-- spawn green gib effect
						-- remove uid from global array
					-- end
				-- end
				-- if danger.hd_type == HD_ENT.SCORPIONFLY then
					-- if danger.behavior.abilities ~= nil then
					
						-- "ability_uid" is an entity that's "duct-taped" to the main entity to allow it to adopt it's abilities.
						-- for _, ability_uid in ipairs(danger.behavior.abilities) do
							-- message("#danger.behavior.abilities: " .. tostring(#danger.behavior.abilities))
							-- if danger.behavior.abilities.agro ~= nil then
								if danger.behavior.bat_uid ~= nil then--behavior.abilities.bat_uid ~= nil then
									if danger_mov.health == 1 then
										-- **If SCORPIONFLY is killed, kill all abilities
											-- **Move this into its own method
										-- kill all abilities
										-- for _, behavior_tokill in ipairs(danger.behavior.abilities) do
											-- if #behavior_tokill > 0 and behavior_tokill[1] ~= nil then
												move_entity(danger.behavior.bat_uid, 0, 0, 0, 0)--move_entity(behavior_tokill[1], 0, 0, 0, 0)
												danger.behavior.bat_uid = nil--behavior_tokill[1] = nil
											-- end
										-- end
									else
										-- permanent agro
										-- **SCORPIONFLY -> Adopt S2's Monkey agro distance.
											-- change the if statement below so it's detecting if the BAT is agro'd, not the scorpion.
										-- **Use chased_target instead.
											-- get_entity():as_chasingmonster chased_target_uid
										if danger_mov.move_state == 5 and danger.behavior.agro == false then danger.behavior.agro = true end
										-- if no idle ability, toggle between agro and default
										-- if danger.behavior.abilities.idle == nil then
											behavior_toggle(
												danger.behavior.bat_uid,--behavior.abilities.agro[1],
												danger.uid,
												TableConcat({danger.uid}, {danger.behavior.bat_uid}),--map(danger.behavior.abilities, function(ability) return ability[1] end)),--{ danger.behavior.abilities.agro[1], danger.behavior.abilities.idle[1], danger.uid },
												danger.behavior.agro
											)
										-- end
									end
								end
							-- end
							-- if it has an idle behavior and agro == false then set it as agro
							-- if danger.behavior.abilities.idle ~= nil then
								-- -- WARNING: Not taking into account if abilities.agro.bat_uid is nil.
								-- -- However, this shouldn't be an issue, as neither is going to be nil when the other is not.
								-- if danger.behavior.abilities.idle[1] ~= nil then
									-- behavior_toggle(
										-- danger.behavior.abilities.agro[1],
										-- danger.behavior.abilities.idle[1],
										-- TableConcat({danger.uid}, map(danger.behavior.abilities, function(ability) return ability[1] end)),--{ danger.behavior.abilities.agro[1], danger.behavior.abilities.idle[1], danger.uid },
										-- danger.behavior.agro
									-- )
								-- end	
							-- end
						-- end
						
					-- end
				-- end
				if danger.behavior.velocity_settimer ~= nil and danger.behavior.velocity_settimer > 0 then
					danger.behavior.velocity_settimer = danger.behavior.velocity_settimer - 1
				else
					if danger.behavior.velocityx ~= nil then
						danger_mov.velocityx = danger.behavior.velocityx
					end
					if danger.behavior.velocityy ~= nil then
						danger_mov.velocityx = danger.behavior.velocityx
					end
					-- message("YEET: " .. tostring(danger_mov.velocityx))
					danger.behavior.velocity_settimer = nil
				end
			end

			if (
				-- (
					danger.hd_type.kill_on_standing ~= nil and
					(
						danger.hd_type.kill_on_standing == HD_KILL_ON.STANDING and
						danger_mov.standing_on_uid ~= -1
					) or
					(
						danger.hd_type.kill_on_standing == HD_KILL_ON.STANDING_OUTOFWATER and
						danger_mov.standing_on_uid ~= -1 and
						test_flag(danger_mov.more_flags, 11) == false
					)
				-- ) or
				-- (
				-- 	danger.hd_type.removecorpse ~= nil and
				-- 	danger.hd_type.removecorpse == true and
				-- 	test_flag(danger_mov.flags, ENT_FLAG.DEAD) == true
				-- )
			) then
				killbool = true
			end
		end
		if killbool == true then
			-- if there's no script-enduced death and we're left with a nil response to uid, track entity coordinates with HD_BEHAVIOR and upon a nil response set killbool in the danger_mov == nil statement. That should allow spawning the item here.
			-- This should also alow for removing all enemy behaviors.
			if danger.behavior ~= nil then
				if danger.behavior.bat_uid ~= nil then
					move_entity(danger.behavior.bat_uid, 0, 0, 0, 0)
				end
			end
			if danger.hd_type.itemdrop ~= nil then -- if dead and has possible item drops
				if danger.hd_type.itemdrop.item ~= nil and #danger.hd_type.itemdrop.item > 0 then
					if (
						danger.hd_type.itemdrop.chance == nil or
						(
							danger.hd_type.itemdrop.chance ~= nil and
							-- danger.itemdrop.chance > 0 and
							math.random() <= danger.hd_type.itemdrop.chance
						)
					) then
						itemdrop = danger.hd_type.itemdrop.item[math.random(1, #danger.hd_type.itemdrop.item)]
						if itemdrop == HD_ENT.ITEM_CRYSTALSKULL then
							create_ghost()
						end
						danger_spawn(itemdrop, danger.x, danger.y, danger.l, false, 0, 0)--spawn(itemdrop, etc)
					end
				end
			end
			if danger.hd_type.treasuredrop ~= nil then -- if dead and has possible item drops
				if danger.hd_type.treasuredrop.item ~= nil and #danger.hd_type.treasuredrop.item > 0 then
					if (
						danger.hd_type.treasuredrop.chance == nil or
						(
							danger.hd_type.treasuredrop.chance ~= nil and
							-- danger.treasuredrop.chance > 0 and
							math.random() <= danger.hd_type.treasuredrop.chance
						)
					) then
						itemdrop = danger.hd_type.treasuredrop.item[math.random(1, #danger.hd_type.treasuredrop.item)]
						danger_spawn(itemdrop, danger.x, danger.y, danger.l, false, 0, 0)
					end
				end
			end
			kill_entity(danger.uid)
			danger_tracker[i] = nil
		end
	end
	-- compact danger_tracker
	CompactList(danger_tracker, n)
end

-- if enabled == true, enable target_uid and disable master
-- if enabled == false, enable master_uid and disable behavior
-- loop through and disable behavior_uids unless it happeneds to be the behavior or the master uid
function behavior_toggle(target_uid, master_uid, behavior_uids, enabled)
	master_mov = get_entity(master_uid)
	if master_mov ~= nil then
		behavior_e = get_entity(target_uid)
		if behavior_e ~= nil then
			if enabled == true then
				-- behavior_e.flags = clr_flag(behavior_e.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)-- enable ai/physics of behavior
				behavior_set_facing(target_uid, master_uid)
				-- bx, by, _ = get_position(target_uid)
				-- move_entity(master_uid, bx, by, 0, 0)
				behavior_set_position(target_uid, master_uid)
			else
				-- behavior_e.flags = set_flag(behavior_e.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)-- disable ai/physics of behavior
				-- x, y, _ = get_position(master_uid)
				-- move_entity(target_uid, x, y, 0, 0)
				behavior_set_position(master_uid, target_uid)
			end
			for _, other_uid in ipairs(behavior_uids) do
				if other_uid ~= master_uid and other_uid ~= target_uid then
					-- other_e = get_entity(other_uid)
					-- if other_e ~= nil then
						-- other_e.flags = set_flag(other_e.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)-- disable ai/physics of behavior
					-- end
					behavior_set_position(master_uid, other_uid)
				end
			end
		else
			message("behavior_toggle(): behavior is nil")
		end
	else
		message("behavior_toggle(): master is nil")
	end
end

function behavior_set_position(uid_toadopt, uid_toset)
	x, y, _ = get_position(uid_toadopt)
	move_entity(uid_toset, x, y, 0, 0)
end

function behavior_set_facing(behavior_uid, master_uid)
	behavior_flags = get_entity_flags(behavior_uid)
	master_mov = get_entity(master_uid)
	if master_mov ~= nil then
		if test_flag(behavior_flags, ENT_FLAG.FACING_LEFT) then
			master_mov.flags = set_flag(master_mov.flags, ENT_FLAG.FACING_LEFT)
		else
			master_mov.flags = clr_flag(master_mov.flags, ENT_FLAG.FACING_LEFT)
		end
	else
		message("behavior_set_facing(): master is nil")
	end
end

function behavior_giantfrog(target_uid)
	message("SPEET!")
	ink = get_entities_by_type(ENT_TYPE.ITEM_INKSPIT)
	replaced = false
	for _, spit in ipairs(ink) do
		if replaced == false then
			spit_mov = get_entity(spit):as_movable()
			if spit_mov.last_owner_uid == target_uid then
				sx, sy, sl = get_position(spit)
				spawn(ENT_TYPE.MONS_FROG, sx, sy, sl, spit_mov.velocityx, spit_mov.velocityy)
				replaced = true
			end
		end
		kill_entity(spit)
	end
end

function onframe_ghosts()
	ghost_uids = get_entities_by_type({
		ENT_TYPE.MONS_GHOST
	})
	ghosttoset_uid = 0
	for _, found_ghost_uid in ipairs(ghost_uids) do
		accounted = 0
		for _, cur_ghost_uid in ipairs(DANGER_GHOST_UIDS) do
			if found_ghost_uid == cur_ghost_uid then accounted = cur_ghost_uid end
			
			ghost = get_entity(found_ghost_uid):as_ghost()
			-- message("timer: " .. tostring(ghost.split_timer) .. ", v_mult: " .. tostring(ghost.velocity_multiplier))
			if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		end
		if accounted == 0 then ghosttoset_uid = found_ghost_uid end
	end
	if ghosttoset_uid ~= 0 then
		ghost = get_entity(ghosttoset_uid):as_ghost()
		
		if (options.hd_og_ghost_slow_enable == true) then ghost.velocity_multiplier = GHOST_VELOCITY end
		if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		
		DANGER_GHOST_UIDS[#DANGER_GHOST_UIDS+1] = ghosttoset_uid
	end
end

function onframe_bacterium()
	if state.theme == THEME.EGGPLANT_WORLD then
		
		-- Bacterium Creation
			-- FLOOR_THORN_VINE:
				-- flags = clr_flag(flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) -- indestructable (maybe need to clear this? Not sure yet)
				-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
				-- visible
				-- allow hurting player
				-- allow bombs to destroy them.
			-- ACTIVEFLOOR_BUSHBLOCK:
				-- invisible
				-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
				-- allow taking damage (unless it's already enabled by default)
			-- ITEM_ROCK:
				-- disable ai and physics
					-- re-enable once detached from surface
		
		-- Bacterium Movement Script
		-- **Move to onframe_manage_dangers
		-- Class requirements:
		-- - Destination {float, float}
		-- - Angle int
		-- - Entity uid:
		-- - stun timeout (May be possible to track with the entity)
		-- # TODO: Bacterium Movement Script
		-- Detect whether it is owned by a wall and if the wall exists, and if not, attempt to adopt a wall within all
		-- 4 sides of it. If that fails, enable physics if not already.
		-- If it is owned by a wall, detect 
		-- PROTOTYPING:
		-- if {x, y} == destination, then:
		--   if "block to immediate right", then:
		--     if "block to immediate front", then:
		--       rotate -90d;
		--     end
		--     own block to immediate right;
		--   else:
		--     rotate 90d;
		--   end
		--   destination = {x, y} of immediate front
		-- go towards the destination;
		-- end
		-- **Get to the point where you can store a single bacterium in an array, get placed on a wall and toast the angle it's chosen to face.
	end
end

function onframe_olmec_cutscene() -- **Move to set_interval() that you can close later
	c_logics = get_entities_by_type(ENT_TYPE.LOGICAL_CINEMATIC_ANCHOR)
	if #c_logics > 0 then
		c_logics_e = get_entity(c_logics[1]):as_movable()
		dead = test_flag(c_logics_e.flags, ENT_FLAG.DEAD)
		if dead == true then
			-- If you skip the cutscene before olmec smashes the blocks, this will teleport him outside of the map and crash.
			-- kill the blocks olmec would normally smash.
			for b = 1, 4, 1 do
				local blocks = get_entities_at(ENT_TYPE.FLOORSTYLED_STONE, 0, 21+b, 98, LAYER.FRONT, 0.5)
				if #blocks > 0 then
					kill_entity(blocks[1])
				end
				b = b + 1
			end
			cutscene_move_olmec_post()
			BOSS_STATE = BOSS_SEQUENCE.FIGHT
		end
	end
end

function onframe_boss()
	if state.theme == THEME.OLMEC then
		if OLMEC_ID then
			if BOSS_STATE == BOSS_SEQUENCE.CUTSCENE then
				onframe_olmec_cutscene()
			elseif BOSS_STATE == BOSS_SEQUENCE.FIGHT then
				onframe_olmec_behavior()
				onframe_boss_wincheck()
			end
		end
	end
end

function onframe_olmec_behavior()
	olmec = get_entity(OLMEC_ID)
	if olmec ~= nil then
		olmec = get_entity(OLMEC_ID):as_olmec()
		-- Ground Pound behavior:
			-- # TODO: Shift OLMEC down enough blocks to match S2's OLMEC. Currently the spelunker is crushed between Olmec and the ceiling.
			-- This is due to HD's olmec having a much shorter jump and shorter hop curve and distance.
			-- Decide whether or not we restore this behavior or if we raise the ceiling generation.
		-- OLMEC_SEQUENCE = { ["STILL"] = 1, ["FALL"] = 2 }
		-- Enemy Spawning: Detect when olmec is about to smash down
		if olmec.velocityy > -0.400 and olmec.velocityx == 0 and OLMEC_STATE == OLMEC_SEQUENCE.FALL then
			OLMEC_STATE = OLMEC_SEQUENCE.STILL
			x, y, l = get_position(OLMEC_ID)
			-- random chance (maybe 20%?) each time olmec groundpounds, shoots 3 out in random directions upwards.
			-- if math.random() >= 0.5 then
				-- # TODO: Currently fires twice. Idea: Use a timeout variable to check time to refire.
				olmec_attack(x, y+2, l)
				-- olmec_attack(x, y+2.5, l)
				-- olmec_attack(x, y+2.5, l)
				
			-- end
		elseif olmec.velocityy < -0.400 then
			OLMEC_STATE = OLMEC_SEQUENCE.FALL
		end
	end
end

function olmec_attack(x, y, l)
	danger_spawn(HD_ENT.OLMEC_SHOT, x, y, l, false, 0, 150)
end

function danger_track(uid_to_track, x, y, l, hd_type)
	danger_object = {
		["uid"] = uid_to_track,
		["x"] = x, ["y"] = y, ["l"] = l,
		["hd_type"] = hd_type,
		["behavior"] = create_behavior(hd_type.behavior)
	}
	danger_tracker[#danger_tracker+1] = danger_object
end

function create_behavior(behavior)
	decorated_behavior = {}
	if behavior ~= nil then
		decorated_behavior = TableCopy(behavior)
		-- if behavior.abilities ~= nil then
			if behavior == HD_BEHAVIOR.SCORPIONFLY then
				-- **Ask the discord if it's actually possible to check if a variable exists even if it's set to nil
				-- The solution is probably assigning ability parameters by setting the variable to -1
					-- (which I CAN do in this situation considering it's a uid field)
				-- ACTUALLYYYYYYYYYYYY The solution is probably using string indexes(I'm probably butchuring the terminology)
					-- For instance; "for string, value in pairs(decorated_behavior.abilities) do if string == "bat_uid" then message("BAT!!") end end"
				
				-- if behavior.abilities.agro.bat_uid ~= nil then
					
					decorated_behavior.bat_uid = spawn(ENT_TYPE.MONS_IMP, x, y, l, 0, 0)--decorated_behavior.abilities.agro.bat_uid = spawn(ENT_TYPE.MONS_BAT, x, y, l, 0, 0)
					applyflags_to_uid(decorated_behavior.bat_uid, {{ 1, 6, 25 }})
				
				-- end
				-- if behavior.abilities.idle.mosquito_uid ~= nil then
					
					-- decorated_behavior.abilities.idle.mosquito_uid = spawn(ENT_TYPE.MONS_MOSQUITO, x, y, l, 0, 0)
					-- ability_e = get_entity(decorated_behavior.abilities.idle.mosquito_uid)
					-- if options.hd_debug_scripted_enemies_show == false then
						-- ability_e.flags = set_flag(ability_e.flags, ENT_FLAG.INVISIBLE)
					-- end
					-- ability_e.flags = set_flag(ability_e.flags, ENT_FLAG.TAKE_NO_DAMAGE)
					-- ability_e.flags = set_flag(ability_e.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
					
				-- end
				
					-- message("#decorated_behavior.abilities: " .. tostring(#decorated_behavior.abilities))
			end
			if behavior == HD_BEHAVIOR.OLMEC_SHOT then
				xvel = math.random(7, 30)/100
				yvel = math.random(5, 10)/100
				if math.random() >= 0.5 then xvel = -1*xvel end
				decorated_behavior.velocityx = xvel
				decorated_behavior.velocityy = yvel
			end
		-- end
	end
	return decorated_behavior
end

-- velocity defaults to 0
function create_danger(hd_type, x, y, l, _vx, _vy)
	vx = _vx or 0
	vy = _vy or 0
	uid = -1
	if (hd_type.collisiontype ~= nil and (hd_type.collisiontype == HD_COLLISIONTYPE.FLOORTRAP or hd_type.collisiontype == HD_COLLISIONTYPE.FLOORTRAP_TALL)) then
		floor_uid = detection_floor(x, y, l, 0, -1, 0.5)
		if floor_uid ~= -1 then
			uid = spawn_entity_over(hd_type.tospawn, floor_uid, 0, 1)
			if hd_type.collisiontype == HD_COLLISIONTYPE.FLOORTRAP_TALL then
				s_head = spawn_entity_over(hd_type.tospawn, uid, 0, 1)
			end
		end
		-- **Modify to accommodate the following enemies:
			-- The Mines:
				-- Miniboss enemy: Giant spider
				-- If there's a wall to the right, don't spawn. (maybe 2 walls down, too?)
			-- The Jungle:
				-- Miniboss enemy: Giant frog
				-- If there's a wall to the right, don't spawn. (For the future when we don't replace mosquitos (or any enemy at all), try to spawn on 2-block surfaces.
		-- **Move conflict detection into its own category.
		-- **Add an HD_ENT property that takes an enum to set collision detection.
	else
		uid = spawn(hd_type.tospawn, x, y, l, vx, vy)
	end
	return uid
end

function danger_applydb(uid, hd_type)
	s_mov = get_entity(uid):as_movable()
	x, y, l = get_position(uid)
	
	if hd_type == HD_ENT.HANGSPIDER then
		spawn(ENT_TYPE.ITEM_WEB, x, y, l, 0, 0) -- move into HD_ENT properties
		spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, uid, 0, 0) -- tikitraps can use this
	end
	if hd_type.color ~= nil and #hd_type.color == 3 then
		s_mov.color.r = hd_type.color[1]
		s_mov.color.g = hd_type.color[2]
		s_mov.color.b = hd_type.color[3]
	end
	if hd_type.health ~= nil and hd_type.health > 0 then
		s_mov.health = hd_type.health
	end
	if hd_type.dim ~= nil and #hd_type.dim == 2 then
		s_mov.width = hd_type.dim[1]
		s_mov.height = hd_type.dim[2]
	end
	if hd_type.hitbox ~= nil and #hd_type.hitbox == 2 then
		s_mov.hitboxx = hd_type.hitbox[1]
		s_mov.hitboxy = hd_type.hitbox[2]
	end
	-- # TODO: Move flags into a table of pairs(flagnumber, bool)
	if hd_type.flags ~= nil then
		applyflags_to_uid(uid, hd_type.flags)
	end
end

-- velocity defaults to uid's
function danger_replace(uid, hd_type, collision_detection, _vx, _vy)
	uid_to_track = uid
	d_mov = get_entity(uid_to_track):as_movable()
	vx = _vx or d_mov.velocityx
	vy = _vy or d_mov.velocityx
	
	x, y, l = get_position(uid_to_track)
	
	d_type = get_entity(uid_to_track).type.id
	
	offset_collision = conflictdetection(hd_type.collisiontype, x, y, l)
	if collision_detection == true and offset_collision == nil then
		offset_collision = nil
		uid_to_track = -1
		move_entity(uid, 0, 0, 0, 0)
	elseif collision_detection == false then
		offset_collision = { 0, 0 }
	end
	if offset_collision ~= nil then
		if (hd_type.tospawn ~= nil and hd_type.tospawn ~= d_type) then
			offset_spawn_x, offset_spawn_y = 0, 0
			if hd_type.offset_spawn ~= nil then
				offset_spawn_x, offset_spawn_y = hd_type.offset_spawn[1], hd_type.offset_spawn[2]
			end
			uid_to_track = create_danger(hd_type, x+offset_spawn_x+offset_collision[1], y+offset_spawn_y+offset_collision[2], l, vx, vy)
			
			move_entity(uid, 0, 0, 0, 0)
		else -- don't replace, apply velocities to and track what you normally would replace
			d_mov.velocityx = vx
			d_mov.velocityy = vy
			uid_to_track = uid
		end
	end

	if uid_to_track ~= -1 then 
		danger_applydb(uid_to_track, hd_type)
		danger_track(uid_to_track, x, y, l, hd_type)
	end
end

-- velocity defaults to 0 (by extension of `create_danger()`)
function danger_spawn(hd_type, x, y, l, collision_detection, _vx, _vy)
	offset_collision = { 0, 0 }
	if collision_detection == true then
		offset_collision = conflictdetection(hd_type.collisiontype, x, y, l)
	end
	if offset_collision ~= nil then
		offset_spawn_x, offset_spawn_y = 0, 0
		if hd_type.offset_spawn ~= nil then
			offset_spawn_x, offset_spawn_y = hd_type.offset_spawn[1], hd_type.offset_spawn[2]
		end
		uid = create_danger(hd_type, x+offset_spawn_x+offset_collision[1], y+offset_spawn_y+offset_collision[2], l, _vx, _vy)
		if uid ~= -1 then
			danger_applydb(uid, hd_type)
			danger_track(uid, x, y, l, hd_type)
		end
	end
end

-- # TODO: Revise `applyflags_to_*` method's `flags` parameter.
	-- From this:
		-- flags = {
			-- {ENT_FLAG.NO_GRAVITY},					-- set
			-- {ENT_FLAG.SOLID, ENT_FLAG.PICKUPABLE}	-- clear
		-- }
	-- To this:
		-- flags = {
			-- [ENT_FLAG.SOLID] = false,
			-- [ENT_FLAG.NO_GRAVITY] = true,
			-- [ENT_FLAG.PICKUPABLE] = false
		-- }
function applyflags_to_level(flags)
	if #flags > 0 then
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			state.level_flags = set_flag(state.level_flags, flag)
		end
		if #flags > 1 then
			flags_clear = flags[2]
			for _, flag in ipairs(flags_clear) do
				state.level_flags = clr_flag(state.level_flags, flag)
			end
		end
	else message("No level flags") end
end

function applyflags_to_quest(flags)
	if #flags > 0 then
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			state.quest_flags = set_flag(state.quest_flags, flag)
		end
		if #flags > 1 then
			flags_clear = flags[2]
			for _, flag in ipairs(flags_clear) do
				state.quest_flags = clr_flag(state.quest_flags, flag)
			end
		end
	else message("No quest flags") end
end

function applyflags_to_uid(uid_assignto, flags)
	if #flags > 0 then
		ability_e = get_entity(uid_assignto)
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			if (
				flag ~= 1 or
				(flag == 1 and options.hd_debug_scripted_enemies_show == false)
			) then
				ability_e.flags = set_flag(ability_e.flags, flag)
			end
		end
		if #flags > 1 then
			flags_clear = flags[2]
			for _, flag in ipairs(flags_clear) do
				ability_e.flags = clr_flag(ability_e.flags, flag)
			end
		end
	else message("No flags") end
end

function onframe_boss_wincheck()
	if BOSS_STATE == BOSS_SEQUENCE.FIGHT then
		olmec = get_entity(OLMEC_ID):as_olmec()
		if olmec ~= nil then
			if olmec.attack_phase == 3 then
				-- # TOTEST: set win sound to HD's win jingle
				local sound = get_sound(VANILLA_SOUND.UI_SECRET)
				if sound ~= nil then sound:play() end
				BOSS_STATE = BOSS_SEQUENCE.DEAD
				unlock_door_at(41, 99)
			end
		end
	end
end

function onguiframe_ui_info_boss()
	if options.hd_debug_info_boss == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if state.theme == THEME.OLMEC and OLMEC_ID ~= nil then
			olmec = get_entity(OLMEC_ID)
			text_x = -0.95
			text_y = -0.50
			white = rgba(255, 255, 255, 255)
			if olmec ~= nil then
				olmec = get_entity(OLMEC_ID):as_olmec()
				
				-- OLMEC_SEQUENCE = { ["STILL"] = 1, ["FALL"] = 2 }
				olmec_attack_state = "UNKNOWN"
				if OLMEC_STATE == OLMEC_SEQUENCE.STILL then olmec_attack_state = "STILL"
				elseif OLMEC_STATE == OLMEC_SEQUENCE.FALL then olmec_attack_state = "FALL" end
				
				-- BOSS_SEQUENCE = { ["CUTSCENE"] = 1, ["FIGHT"] = 2, ["DEAD"] = 3 }
				boss_attack_state = "UNKNOWN"
				if BOSS_STATE == BOSS_SEQUENCE.CUTSCENE then BOSS_attack_state = "CUTSCENE"
				elseif BOSS_STATE == BOSS_SEQUENCE.FIGHT then BOSS_attack_state = "FIGHT"
				elseif BOSS_STATE == BOSS_SEQUENCE.DEAD then BOSS_attack_state = "DEAD" end
				
				draw_text(text_x, text_y, 0, "OLMEC_STATE: " .. olmec_attack_state, white)
				text_y = text_y - 0.1
				draw_text(text_x, text_y, 0, "BOSS_STATE: " .. boss_attack_state, white)
			else draw_text(text_x, text_y, 0, "olmec is nil", white) end
		end
	end
end

function onguiframe_ui_info_wormtongue()
	if options.hd_debug_info_tongue == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if state.level == 1 and (state.theme == THEME.JUNGLE or state.theme == THEME.ICE_CAVES) then
			text_x = -0.95
			text_y = -0.45
			white = rgba(255, 255, 255, 255)
			
			-- TONGUE_SEQUENCE = { ["READY"] = 1, ["RUMBLE"] = 2, ["EMERGE"] = 3, ["SWALLOW"] = 4 , ["GONE"] = 5 }
			tongue_debugtext_sequence = "UNKNOWN"
			if TONGUE_STATE == TONGUE_SEQUENCE.READY then tongue_debugtext_sequence = "READY"
			elseif TONGUE_STATE == TONGUE_SEQUENCE.RUMBLE then tongue_debugtext_sequence = "RUMBLE"
			elseif TONGUE_STATE == TONGUE_SEQUENCE.EMERGE then tongue_debugtext_sequence = "EMERGE"
			elseif TONGUE_STATE == TONGUE_SEQUENCE.SWALLOW then tongue_debugtext_sequence = "SWALLOW"
			elseif TONGUE_STATE == TONGUE_SEQUENCE.GONE then tongue_debugtext_sequence = "GONE" end
			draw_text(text_x, text_y, 0, "Worm Tongue State: " .. tongue_debugtext_sequence, white)
			text_y = text_y-0.1
			
			tongue_debugtext_uid = tostring(TONGUE_UID)
			if TONGUE_UID == nil then tongue_debugtext_uid = "nil" end
			draw_text(text_x, text_y, 0, "Worm Tongue UID: " .. tongue_debugtext_uid, white)
			text_y = text_y-0.1
			
			tongue_debugtext_tick = tostring(tongue_tick)
			if tongue_tick == nil then tongue_debugtext_tick = "nil" end
			draw_text(text_x, text_y, 0, "Worm Tongue Acceptance tic: " .. tongue_debugtext_tick, white)
		end
	end
end

function onguiframe_ui_info_boulder()
	if options.hd_debug_info_boulder == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if (
			state.theme == THEME.DWELLING and
			(state.level == 2 or state.level == 3 or state.level == 4)
		) then
			text_x = -0.95
			text_y = -0.45
			green_rim = rgba(102, 108, 82, 255)
			green_hitbox = rgba(153, 196, 19, 170)
			white = rgba(255, 255, 255, 255)
			if BOULDER_UID == nil then text_boulder_uid = "No Boulder Onscreen"
			else text_boulder_uid = tostring(BOULDER_UID) end
			
			sx = BOULDER_SX
			sy = BOULDER_SY
			sx2 = BOULDER_SX2
			sy2 = BOULDER_SY2
			
			draw_text(text_x, text_y, 0, "BOULDER_UID: " .. text_boulder_uid, white)
			
			if BOULDER_UID ~= nil and sx ~= nil and sy ~= nil and sx2 ~= nil and sy2 ~= nil then
				text_y = text_y-0.1
				sp_x, sp_y = screen_position(sx, sy)
				sp_x2, sp_y2 = screen_position(sx2, sy2)
				
				-- draw_rect(sp_x, sp_y, sp_x2, sp_y2, 4, 0, green_rim)
				draw_rect_filled(sp_x, sp_y, sp_x2, sp_y2, 0, green_hitbox)
				
				text_boulder_sx = tostring(sx)
				text_boulder_sy = tostring(sy)
				text_boulder_sx2 = tostring(sx2)
				text_boulder_sy2 = tostring(sy2)
				if BOULDER_DEBUG_PLAYERTOUCH == true then text_boulder_touching = "Touching!" else text_boulder_touching = "Not Touching." end
				
				draw_text(text_x, text_y, 0, "SX: " .. text_boulder_sx, white)
				text_y = text_y-0.1
				draw_text(text_x, text_y, 0, "SY: " .. text_boulder_sy, white)
				text_y = text_y-0.1
				draw_text(text_x, text_y, 0, "SX2: " .. text_boulder_sx2, white)
				text_y = text_y-0.1
				draw_text(text_x, text_y, 0, "SY2: " .. text_boulder_sy2, white)
				text_y = text_y-0.1
				
				draw_text(text_x, text_y, 0, "Player touching top of hitbox: " .. text_boulder_touching, white)
			end
		end
	end
end

function onguiframe_ui_info_feelings()
	if options.hd_debug_info_feelings == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		text_x = -0.95
		text_y = -0.35
		white = rgba(255, 255, 255, 255)
		green = rgba(55, 200, 75, 255)
		
		text_levelfeelings = "No Level Feelings"
		feelings = 0
		
		for feelingname, feeling in pairs(global_feelings) do
			if feeling_check(feelingname) == true then
				feelings = feelings + 1
			end
		end
		if feelings ~= 0 then text_levelfeelings = (tostring(feelings) .. " Level Feelings") end
		
		draw_text(text_x, text_y, 0, text_levelfeelings, white)
		text_y = text_y-0.035
		color = white
		if MESSAGE_FEELING ~= nil then color = green end
		text_message_feeling = ("MESSAGE_FEELING: " .. tostring(MESSAGE_FEELING))
		draw_text(text_x, text_y, 0, text_message_feeling, color)
		text_y = text_y-0.05
		for feelingname, feeling in pairs(global_feelings) do
			color = white
			text_message = ""
			
			feeling_bool = feeling_check(feelingname)
			if feeling.message ~= nil then text_message = (": \"" .. feeling.message .. "\"") end
			if feeling_bool == true then color = green end
			
			text_feeling = (feelingname) .. text_message
			
			draw_text(text_x, text_y, 0, text_feeling, color)
			text_y = text_y-0.035
		end

	end
end

function onguiframe_ui_info_worldstate()
	if (
		options.hd_debug_info_worldstate == true
		and (state.pause == 0 and (state.screen == 11 or state.screen == 12))
	) then
		text_x = -0.95
		text_y = -0.37
		white = rgba(255, 255, 255, 255)
		green = rgba(55, 200, 75, 255)

		hd_worldstate_debugtext_status = "UNKNOWN"
		color = white

		-- HD_WORLDSTATE_STATE
		if HD_WORLDSTATE_STATE ~= nil then
			if HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.NORMAL then
				hd_worldstate_debugtext_status = "NORMAL"
			elseif HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TUTORIAL then
				hd_worldstate_debugtext_status = "TUTORIAL"
				color = green
			elseif HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TESTING then
				hd_worldstate_debugtext_status = "TESTING"
				color = green
			end
		end
		draw_text(text_x, text_y, 0, "HD_WORLDSTATE_STATE: " .. hd_worldstate_debugtext_status, color)

		text_y = text_y-0.1
		color = white

		-- door uid
		if DOOR_TUTORIAL_UID ~= nil and DOOR_TUTORIAL_UID >= 0 then color = green end
		draw_text(text_x, text_y, 0, "DOOR_TUTORIAL_UID: " .. tostring(DOOR_TUTORIAL_UID), color)

		text_y = text_y-0.1
		color = white

		-- overlaps with player 1
		door_entrance_ent = get_entity(DOOR_TUTORIAL_UID)
		door_testing_entered_text = "false"
		if door_entrance_ent:overlaps_with(get_entity(players[1].uid)) == true then
			door_testing_entered_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_text(text_x, text_y, 0, "OVERLAPS_WITH: " .. door_testing_entered_text, color)
		
		text_y = text_y-0.1
		color = white

		-- if player 1 state is entering
		player_entering_text = "false"
		if players[1].state == CHAR_STATE.ENTERING then
			player_entering_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_text(text_x, text_y, 0, "players[1].state == CHAR_STATE.ENTERING: " .. player_entering_text, color)

	end
end

function onguiframe_ui_info_path()
	if (
		options.hd_debug_info_path == true and
		-- (state.pause == 0 and state.screen == 12 and #players > 0) and
		global_levelassembly ~= nil
	) then
		text_x = -0.95
		text_y = -0.35
		white = rgba(255, 255, 255, 255)
		
		-- levelw, levelh = get_levelsize()
		levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		
		text_y_space = text_y
		for hi = 1, levelh, 1 do -- hi :)
			text_x_space = text_x
			for wi = 1, levelw, 1 do
				text_subchunkid = tostring(global_levelassembly.modification.levelrooms[hi][wi])
				if text_subchunkid == nil then text_subchunkid = "nil" end
				draw_text(text_x_space, text_y_space, 0, text_subchunkid, white)
				
				text_x_space = text_x_space+0.04
			end
			text_y_space = text_y_space-0.04
		end
	end
end

-- Prize Wheel
-- # TODO: Once using diceposter texture, remove this.
function onguiframe_env_animate_prizewheel()
	if (state.pause == 0 and state.screen == 12 and #players > 0) then
		local atms = get_entities_by_type(ENT_TYPE.ITEM_DICE_BET)
		if #atms > 0 then
			for i, atm in ipairs(atms) do
				local atm_mov = get_entity(atms[i]):as_movable()
				local atm_facing = test_flag(atm_mov.flags, ENT_FLAG.FACING_LEFT)
				local atm_x, atm_y, atm_l = get_position(atm_mov.uid)
				local wheel_x_raw = atm_x
				local wheel_y_raw = atm_y+1.5
				
				local facing_dist = 1
				if atm_facing == false then facing_dist = -1 end
				
				wheel_x_raw = wheel_x_raw + 1 * facing_dist
				
				local wheel_x, wheel_y = screen_position(wheel_x_raw, wheel_y_raw)
				-- draw_text(wheel_x, wheel_y, 0, tostring(wheel_speed), rgba(234, 234, 234, 255))
				draw_circle(wheel_x, wheel_y, screen_distance(1.3), 8, rgba(102, 108, 82, 255))
				draw_circle_filled(wheel_x, wheel_y, screen_distance(1.3), rgba(153, 196, 19, 70))
				draw_circle_filled(wheel_x, wheel_y, screen_distance(0.1), rgba(255, 59, 89, 255))
			end
		end
	end
end

-- Book of dead animating
function onguiframe_ui_animate_botd()
	if state.pause == 0 and state.screen == 12 and #players > 0 then
		if OBTAINED_BOOKOFDEAD == true then
			local w = UI_BOTD_PLACEMENT_W
			local h = UI_BOTD_PLACEMENT_H
			local x = UI_BOTD_PLACEMENT_X
			local y = UI_BOTD_PLACEMENT_Y
			local uvx1 = 0
			local uvy1 = 0
			local uvx2 = bookofdead_squash
			local uvy2 = 1
			
			if state.theme == THEME.OLMEC then
				local hellx_min = HELL_X - math.floor(BOOKOFDEAD_RANGE/2)
				local hellx_max = HELL_X + math.floor(BOOKOFDEAD_RANGE/2)
				p_x, p_y, p_l = get_position(players[1].uid)
				if (p_x >= hellx_min) and (p_x <= hellx_max) then
					animate_bookofdead(0.6*((p_x - HELL_X)^2) + BOOKOFDEAD_TIC_LIMIT)
				else
					bookofdead_tick = 0
					bookofdead_frames_index = 1
				end
			elseif state.theme == THEME.VOLCANA then
				if state.level == 1 then
					animate_bookofdead(12)
				elseif state.level == 2 then
					animate_bookofdead(8)
				elseif state.level == 3 then
					animate_bookofdead(4)
				else
					animate_bookofdead(2)
				end
			end
			
			uvx1 = -bookofdead_squash*(bookofdead_frames_index-1)
			uvx2 = bookofdead_squash - bookofdead_squash*(bookofdead_frames_index-1)
			
			-- draw_text(x-0.1, y, 0, tostring(bookofdead_tick), rgba(234, 234, 234, 255))
			-- draw_text(x-0.1, y-0.1, 0, tostring(bookofdead_frames_index), rgba(234, 234, 234, 255))
			draw_image(UI_BOTD_IMG_ID, x, y, x+w, y-h, uvx1, uvy1, uvx2, uvy2, 0xffffffff)
		end
	end
end


-- # TODO: Turn into a custom inventory system that works for all players.
function inventory_checkpickup_botd()
	if OBTAINED_BOOKOFDEAD == false then
		for i = 1, #players, 1 do
			if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) then
				-- # TODO: Move into the method that spawns Anubis II in COG
				toast("Death to the defiler!")
				OBTAINED_BOOKOFDEAD = true
				set_timeout(function() remove_player_item(ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) end, 1)
			end
		end
	end
end

-- apply randomized frame offsets to uids of ENT_TYPE.FLOOR tiles
	-- pass in:
		-- a table of uids
		-- a table of dimensions
	-- assign each uid a random animation_frame
	-- This method has recursive potential. Would work for areas much larger than 2x2 but would need adjustment for that
	
-- function tileapplier9000(_tilegroup)
-- 	uid_offsetpair = _tilegroup.uid_offsetpair
-- 	dim = _tilegroup.dim
-- 		-- width = 3
-- 		-- height = 4
-- 	for yi = 0, -(dim[2]-1), -1 do -- 0 -> -3
-- 		for xi = 0, (dim[1]-1), 1 do -- 0 -> 2
-- 			dim_viable = {(dim[1]-xi), (dim[2]+yi)} -- 3, 4 -> 1, 1
-- 			for _, offsetpair in ipairs(uid_offsetpair) do
-- 				-- Will have no uid if already applied.
-- 				if offsetpair.uid == nil and offsetpair.offset ~= nil then
-- 					dim_viable = tileapplier_get_viabledim(dim, xi, yi, offsetpair.offset)
-- 				end
-- 			end
-- 			-- if floor available, apply random animation_frame to uids
-- 			if dim_viable[1] > 0 and dim_viable[2] > 0 then
-- 				-- find applicable uids with the given dimensions
-- 				origin = { xi, yi }
-- 				tileapplier_apply_randomframe(_tilegroup, origin, dim_viable)
-- 			end
-- 		end
-- 	end
-- end

-- -- return uids (debug purposes)
-- function tileapplier_apply_randomframe(_tilegroup, origin, dim_viable)
-- 	uids = {}
-- 	setup_apply = tileapplier_get_randomwithin(dim_viable)
-- 	dim = setup_apply.dim--_tilegroup.dim
-- 	-- if origin[1] == 2 then
-- 		-- message(tostring(origin[1]) .. ", " .. tostring(origin[2]))-- .. ": " .. tostring(setup_apply.frames[1]))
-- 	-- end
-- 	uid_offsetpair = _tilegroup.uid_offsetpair
-- 	frames_i = 1 -- ah yes, frames_i, the ugly older brother of iframes
-- 	for yi = origin[2], dim[2]-1, 1 do -- start at origin[2], end at dim[2]
-- 		for xi = origin[1], dim[1]-1, 1 do
-- 			for _, offsetpair in ipairs(uid_offsetpair) do
-- 				if offsetpair.uid ~= nil and offsetpair.offset ~= nil then
-- 					if offsetpair.offset[1] == xi and offsetpair.offset[2] == yi then
-- 						floor_e = get_entity(offsetpair.uid)
-- 						floor_m = floor_e:as_movable()
-- 						frame = setup_apply.frames[frames_i]
-- 						-- message(tostring(xi) .. ", " .. tostring(yi) .. ": " .. tostring(frame))
-- 						floor_m.animation_frame = frame
-- 						-- apply to uids, then assign offset in dim
-- 						table.insert(uids, offsetpair.uid)
-- 						offsetpair.uid = nil
-- 					end
-- 				end
-- 			end
-- 			frames_i = frames_i + 1
-- 		end
-- 	end
-- 	return uids
-- end

-- function tileapplier_get_viabledim(dim, xi, yi, offset)
-- 	dim_viable = {(dim[1]-xi), (dim[2]+yi)}--{1+(dim[1]-xi), 1+(dim[2]-yi)}
-- 	x_larger = offset[1] > xi
-- 	x_equals = offset[1] == xi
-- 	y_larger = offset[2] > yi
-- 	y_equals = offset[2] == yi
-- 	both_equals = x_equals and y_equals
-- 	both_larger = x_larger and y_larger
-- 	if (x_equals or x_larger) and (y_equals or y_larger) then
-- 		if x_larger and y_equals then -- subtract from viable dimension
-- 			dim_viable[1] = dim_viable[1] - 1
-- 		elseif both_equals then
-- 			dim_viable[1] = dim_viable[1] - 2
-- 		end
-- 		if y_larger and x_equals then -- subtract from viable dimension
-- 			dim_viable[2] = dim_viable[2] - 1
-- 		elseif both_equals then
-- 			dim_viable[2] = dim_viable[2] - 2
-- 		end
-- 	end
-- 	return dim_viable
-- end

-- -- Compact tileframes_floor into a local table of matching dimensions
-- function tileapplier_get_randomwithin(_dim)
-- 	tileframes_floor_matching = TableCopy(TILEFRAMES_FLOOR)
-- 	n = #tileframes_floor_matching
-- 	for i, setup in ipairs(tileframes_floor_matching) do
-- 		if (
-- 			(setup.dim ~= nil and #setup.dim == 2) and
-- 			(setup.dim[1] > _dim[1] or setup.dim[2] > _dim[2])
-- 		) then tileframes_floor_matching[i] = nil end
-- 	end
-- 	tileframes_floor_matching = CompactList(tileframes_floor_matching, n)
-- 	-- message("#tileframes_floor_matching: " .. tostring(#tileframes_floor_matching))
-- 	-- message("_dim[1]: " .. tostring(_dim[1]).. ", _dim[2]: " .. tostring(_dim[2]))
-- 	return TableRandomElement(tileframes_floor_matching)
-- end

-- # TODO: Move HD_UNLOCKS to its own module
	-- Remove loading from external file, keep as hard-coded
	-- Still within it's own module, move HD_UNLOCKS to its own dedicated lua file so it can be easily overriden with a future mod.
		-- character_colors.zip?
function unlocks_file()
	lines = lines_from('Mods/Packs/HDmod/unlocks.txt')
	for _, inputstr in ipairs(lines) do
		t = {}
		for str in string.gmatch(inputstr, "([^//]+)") do
			table.insert(t, str)
		end
		inputstr_stripped = {}
		for str in string.gmatch(t[1], "([^%s]+)") do
			table.insert(inputstr_stripped, str)
		end
		HD_UNLOCKS[inputstr_stripped[1]].unlock_id = tonumber(inputstr_stripped[2])
	end
end

-- if `meta.unsafe` is enabled, load character unlocks as defined in the character file
-- otherwise use a hardcoded table for character unlocks
function unlocks_init()
	if meta.unsafe == true then
		unlocks_file()
	else
		unlocks_load()
	end
end

function unlocks_load()
	for _unlockname, k in pairs(HD_UNLOCKS) do
		HD_UNLOCKS[_unlockname].unlocked = test_flag(savegame.characters, k.unlock_id)
	end
	-- RUN_UNLOCK_AREA gets loaded in an ON.LOAD callback
end

function level_generation_method_side()
	-- world side rooms
	if (HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
		HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
		HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.SIDE] ~= nil
 	) then
		levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		for level_hi = 1, levelh, 1 do
			for level_wi = 1, levelw, 1 do
				subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
				if subchunk_id == nil then -- apply sideroom

					levelcode_inject_roomcode(
						HD_SUBCHUNKID.SIDE, HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.SIDE], level_hi, level_wi,
						-- rules
						(
							HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
							HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
							HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[HD_SUBCHUNKID.SIDE] ~= nil
						) and
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[HD_SUBCHUNKID.SIDE]() or math.random(#HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.SIDE])
					)
				end
			end
		end
	else
		message("path_gen_side: No roomcodes available for siderooms;")
	end
end

function level_generation_method_setrooms(setRooms, prePath)
	prePath = prePath or false
	for _, setroomcont in ipairs(setRooms) do
		if (setroomcont.prePath == nil and prePath == false) or (setroomcont.prePath ~= nil and setroomcont.prePath == prePath) then
			if setroomcont.placement == nil or setroomcont.subchunk_id == nil or setroomcont.roomcodes == nil then
				message("setroom params missing! Couldn't spawn.")
			else
				levelcode_inject_roomcode(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement[1], setroomcont.placement[2])
			end
		end
	end
end

--[[
	_nonaligned_room_type
		.subchunk_id
		.roomcodes
	_avoid_bottom
--]]
function level_generation_method_nonaligned(_nonaligned_room_type, _avoid_bottom)
	_avoid_bottom = _avoid_bottom or false
	
	
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y}

	-- build a collection of potential spots
	for level_hi = 1, levelh-(_avoid_bottom and 1 or 0), 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				-- add room
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	spot = TableRandomElement(spots)

	levelcode_inject_roomcode(_nonaligned_room_type.subchunk_id, _nonaligned_room_type.roomcodes, spot.y, spot.x)
end

--[[
	_aligned_room_types
		.left
			.subchunk_id
			.roomcodes
		.right
			.subchunk_id
			.roomcodes
--]]
function level_generation_method_aligned(_aligned_room_types)
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots_aligned = {}
		--{x, y, facing_left}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				if ( -- add right facing if there is a path on the right
					level_wi+1 <= levelw and
					(
						global_levelassembly.modification.levelrooms[level_hi][level_wi+1] >= 1 and
						global_levelassembly.modification.levelrooms[level_hi][level_wi+1] <= 8
					)
				) then
					table.insert(spots_aligned, {x = level_wi, y = level_hi, facing_left = false})
				elseif (-- add left facing if there is a path on the left
					level_wi-1 >= 1 and
					(
						global_levelassembly.modification.levelrooms[level_hi][level_wi-1] >= 1 and
						global_levelassembly.modification.levelrooms[level_hi][level_wi-1] <= 8
					)
				) then
					table.insert(spots_aligned, {x = level_wi, y = level_hi, facing_left = true})
				end
			end
		end
	end

	-- pick random place to fill
	spot = spots[math.random(#spots)]--TableRandomElement(spots)

	levelcode_inject_roomcode(
		(spot.facing_left and _aligned_room_types.left.subchunk_id or _aligned_room_types.right.subchunk_id),
		(spot.facing_left and _aligned_room_types.left.roomcodes or _aligned_room_types.right.roomcodes),
		spot.y, spot.x
	)
end

function detect_level_non_boss()
	return (
		state.theme ~= THEME.OLMEC and
		state.theme ~= THEME.TIAMAT
	)
end
function detect_level_non_special()
	return (
		state.theme ~= THEME.EGGPLANT_WORLD and
		state.theme ~= THEME.NEO_BABYLON and
		state.theme ~= THEME.CITY_OF_GOLD and
		feeling_check("HAUNTEDCASTLE") == false and
		feeling_check("BLACKMARKET") == false
	)
end

function level_generation_method_altar()
	if (
		-- detect_same_levelstate(THEME.DWELLING, 1, 1) == false and
		detect_level_non_boss() and
		detect_level_non_special()
	) then
		chance = 1--14 --(???)
		
		if (math.random(1, chance) == 1) then
			level_generation_method_nonaligned(
				{
					subchunk_id = HD_SUBCHUNKID.ALTAR,
					roomcodes =
						(
							HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
							HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.ALTAR] ~= nil
						) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.ALTAR] or HD_ROOMOBJECT.GENERIC[HD_SUBCHUNKID.ALTAR]
				}
			)
		end
	end
end
function level_generation_method_idol()
	if (
		feeling_check("SACRIFICIALPIT") == false and
		detect_level_non_boss() and
		detect_level_non_special()
	) then
		chance = 1 --(???)
		
		if (math.random(1, chance) == 1) then
			level_generation_method_nonaligned(
				{
					subchunk_id = feeling_check("RESTLESS") and HD_SUBCHUNKID.RESTLESS_IDOL or HD_SUBCHUNKID.IDOL,
					roomcodes = feeling_check("RESTLESS") and HD_ROOMOBJECT.FEELINGS["RESTLESS"].rooms[HD_SUBCHUNKID.RESTLESS_IDOL] or (
						(
							HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
							HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.IDOL] ~= nil
						) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[HD_SUBCHUNKID.IDOL]
					)
				},
				(state.theme == THEME.DWELLING)
			)
		end
	end
end


function level_generation_method_shops()
	if (
		detect_same_levelstate(THEME.DWELLING, 1, 1) == false and
		detect_level_non_boss() and
		detect_level_non_special()
	) then
		chance = state.level + ((state.world - 1) * 4)
		
		if (math.random(1, chance) <= 2) then
			shop_id_right = HD_SUBCHUNKID.SHOP_REGULAR
			shop_id_left = HD_SUBCHUNKID.SHOP_REGULAR_LEFT
			if (
				-- gurenteed regular shop on the second level of the first world
				detect_same_levelstate(THEME.DWELLING, 2, 1)
				-- # TODO: Add other shop types
			) then
				shop_id_right = HD_SUBCHUNKID.SHOP_REGULAR
				shop_id_left = HD_SUBCHUNKID.SHOP_REGULAR_LEFT
			end
			level_generation_method_aligned(
				{
					left = {
						subchunk_id = shop_id_left,
						roomcodes = HD_ROOMOBJECT.GENERIC[shop_id_left]
					},
					right = {
						subchunk_id = shop_id_right,
						roomcodes = HD_ROOMOBJECT.GENERIC[shop_id_right]
					}
				}
			)
		end
	end
end

function level_generation_method_structure_vertical(_structure_top, _structure_parts, _struct_x_pool, _midheight_min)
	_midheight_min = _midheight_min or 0
	
	_, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	structx = _struct_x_pool[math.random(1, #_struct_x_pool)]

	-- spawn top
	levelcode_inject_roomcode(_structure_top.subchunk_id, _structure_top.roomcodes, 1, structx)

	if _structure_parts ~= nil then
		midheight = (_midheight_min == 0) and 0 or math.random(_midheight_min, levelh-2)
		-- if _midheight_min == 0 then
		-- 	midheight = 0
		-- else
		-- 	midheight = math.random(_midheight_min, levelh-2)
		-- end

		-- spawn middle
		if _structure_parts.middle ~= nil then
			
			for i = 2, 1+midheight, 1 do
				levelcode_inject_roomcode(_structure_parts.middle.subchunk_id, _structure_parts.middle.roomcodes, i, structx)
			end
		end
		-- spawn bottom
		if _structure_parts.bottom ~= nil then
			levelcode_inject_roomcode(_structure_parts.bottom.subchunk_id, _structure_parts.bottom.roomcodes, 1+midheight+1, structx)
		end
	end
end

function levelcode_inject_roomcode(_subchunk_id, _roomPool, _level_hi, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	global_levelassembly.modification.levelrooms[_level_hi][_level_wi] = _subchunk_id

	c_y = ((_level_hi*HD_ROOMOBJECT.DIM.h)-HD_ROOMOBJECT.DIM.h)+1
	c_x = ((_level_wi*HD_ROOMOBJECT.DIM.w)-HD_ROOMOBJECT.DIM.w)+1
	
	-- message("levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject(_roomPool, HD_ROOMOBJECT.DIM.h, HD_ROOMOBJECT.DIM.w, c_y, c_x, _specified_index)
end

function levelcode_inject(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	chunkPool_rand_index = _specified_index
	chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			global_levelassembly.modification.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function gen_levelrooms_nonpath(unlock, prePath)
	-- world setrooms
	if HD_ROOMOBJECT.WORLDS[state.theme].setRooms ~= nil then
		level_generation_method_setrooms(HD_ROOMOBJECT.WORLDS[state.theme].setRooms, prePath)
	end

	-- testing setrooms
	if ((HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TESTING) and (HD_ROOMOBJECT.TESTING[state.level].setRooms ~= nil)) then
		level_generation_method_setrooms(HD_ROOMOBJECT.TESTING[state.level].setRooms, prePath)
	end

	-- tutorial setrooms
	if ((HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TUTORIAL) and (HD_ROOMOBJECT.TUTORIAL[state.level].setRooms ~= nil)) then
		level_generation_method_setrooms(HD_ROOMOBJECT.TUTORIAL[state.level].setRooms, prePath)
	end

	-- feeling structures
	for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
		if feeling_check(feeling) == true then
			if (feelingContent.prePath == nil and prePath == false) or (feelingContent.prePath ~= nil and feelingContent.prePath == prePath) then
				if feelingContent.method == nil then
					message("gen_levelrooms_nonpath: feeling method params missing! Couldn't execute spawn method.")
				else
					-- message("gen_levelrooms_nonpath: Executing feeling spawning method:")
					feelingContent.method()
				end
			end
			if feelingContent.setRooms ~= nil then
				level_generation_method_setrooms(feelingContent.setRooms, prePath)
			end
		end
	end

	-- # TODO: Character unlocks
	-- if unlock ~= nil then
	-- end
	
	-- HD_ROOMOBJECT.GENERIC
		-- altar
		-- idol
		-- side
	if prePath == false then
		-- level_generation_method_shops()

		level_generation_method_idol()
		level_generation_method_altar()

		level_generation_method_side()
	end
end

-- Edits to the levelcode
function gen_levelcode_fill()
	levelcode_chunks() -- apply chunk tilecodes ()
end
 
function levelcode_chunks()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	c_hi_len = levelh*HD_ROOMOBJECT.DIM.h
	c_wi_len = levelw*HD_ROOMOBJECT.DIM.w
	for levelcode_yi = 1, c_hi_len, 1 do
		for levelcode_xi = 1, c_wi_len, 1 do
			tilename = global_levelassembly.modification.levelcode[levelcode_yi][levelcode_xi]

			if HD_OBSTACLEBLOCK_TILENAME[tilename] ~= nil then
				chunkcodes = nil

				-- codes
				if (
					HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename] ~= nil
				) then
					chunkcodes = HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename]
				elseif HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes ~= nil then
					chunkcodes = HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes
				end

				-- rules
				chunkpool_rand_index = (
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename] ~= nil
				) and HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename]() or math.random(#chunkcodes)
	
				if chunkcodes ~= nil then
					c_dim_h, c_dim_w = HD_OBSTACLEBLOCK_TILENAME[tilename].dim[1], HD_OBSTACLEBLOCK_TILENAME[tilename].dim[2]
					levelcode_inject(chunkcodes, c_dim_h, c_dim_w, levelcode_yi, levelcode_xi, chunkpool_rand_index)
				else
					message("levelcode_chunks: No chunkcodes available for tilename \"" .. tilename .. "\";")
				end
			end
		end
	end
end

function gen_levelcode_bake()
	levelcode_bake_spawn()
	levelcode_bake_spawn_over()
end

function levelcode_bake_spawn()
	_x, _y = locate_cornerpos_real(1, 1) -- game coordinates of the topleft-most tile of the level
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	c_hi_len, c_wi_len = levelh*HD_ROOMOBJECT.DIM.h, levelw*HD_ROOMOBJECT.DIM.w
	y = _y
	for level_hi = 1, c_hi_len, 1 do
		x = _x
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = global_levelassembly.modification.levelcode[level_hi][level_wi]
			hd_tiletype, hd_tiletype_post = HD_TILENAME[_tilechar], HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil then
				-- if string.find(_tilechar, options.hd_debug_scripted_levelgen_tilecodes_blacklist) == false then message("PLOOP FALSE!!") end
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					l = LAYER.FRONT
					-- need subchunkid of what room we're in
					roomx, roomy = locate_roompos_levelassembly(level_wi, level_hi)
					_subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
					
					-- doors
					if _tilechar == "9" then
						if (
							(_subchunk_id == HD_SUBCHUNKID.ENTRANCE) or
							(_subchunk_id == HD_SUBCHUNKID.ENTRANCE_DROP)
						) then
							create_door_entrance(x, y, l)
						elseif (
							(_subchunk_id == HD_SUBCHUNKID.EXIT) or
							(_subchunk_id == HD_SUBCHUNKID.EXIT_NOTOP)
						) then
							-- spawn an exit door to the next level. Spawn a shopkeeper if agro.
							create_door_exit(x, y, l)
						elseif (_subchunk_id == HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP) then
							-- # TODO: Mothership entrance door; make a method to spawn the mothership entrance.
							create_door_exit_to_mothership(x, y, l)
						elseif (_subchunk_id == HD_SUBCHUNKID.RESTLESS_TOMB) then
							-- Haunted Castle entrance door; Spawn skeleton with crown and hidden castle entrance door
							-- # TODO: Haunted Castle Extra Item Spawns;
							-- Spawn king's tombstone
								-- Change skin to king

							-- 2 tiles down
								-- Spawn skeleton
								-- Spawn Crown
									-- Reskin ITEM_DIAMOND as gold crown
									-- (worth $5000 in HD, might as well leave price the same as diamond)
							
							-- 4 tiles down
								-- spawn hidden entrance
									-- Ask around the discord for a way to make the hidden door jingle go off
							create_door_exit_to_hauntedcastle(x, y-4, l)
						end
					-- coffins
					elseif _tilechar == "g" then
						if (
							-- (_subchunk_id == HD_SUBCHUNKID.) or
							(_subchunk_id == HD_SUBCHUNKID.COFFIN_UNLOCKABLE)
						) then
							-- # TODO: Creating unlock coffins
							
						-- elseif (
						-- 	(_subchunk_id == HD_SUBCHUNKID.) or
						-- 	(_subchunk_id == HD_SUBCHUNKID.)
						-- ) then
						-- 	-- # TODO: Creating player coffins
							
						end
					end
					
					with_offset_x, with_offset_y = 0, 0
					if hd_tiletype_post.alternate_offset ~= nil and hd_tiletype_post.alternate_offset[state.theme] ~= nil then
						with_offset_x, with_offset_y = hd_tiletype_post.alternate_offset[1], hd_tiletype_post.alternate_offset[2]
					elseif hd_tiletype_post.offset ~= nil then
						with_offset_x, with_offset_y = hd_tiletype_post.offset[1], hd_tiletype_post.offset[2]
					end
					with_offset_x, with_offset_y = with_offset_x + x, with_offset_y + y
	
					spawned_uid = 0
	
					-- HD_ENT and ENT_TYPE spawning
					if hd_tiletype.entity_types ~= nil then
						if hd_tiletype.entity_types.default ~= nil then
							entity_type_pool = hd_tiletype.entity_types.default
							entity_type = 0
							if (
								hd_tiletype.entity_types.alternate ~= nil and
								hd_tiletype.entity_types.alternate[state.theme] ~= nil
							) then
								entity_type_pool = hd_tiletype.entity_types.alternate[state.theme]
							elseif (
								hd_tiletype.entity_types.tutorial ~= nil and
								HD_WORLDSTATE_STATE == HD_WORLDSTATE_STATUS.TUTORIAL
							) then
								entity_type_pool = hd_tiletype.entity_types.tutorial
							end
							
							if #entity_type_pool == 1 then
								entity_type = entity_type_pool[1]
							elseif #entity_type_pool > 1 then
								entity_type = TableRandomElement(entity_type_pool)
							end
							entType_is_liquid = (
								entity_type == ENT_TYPE.LIQUID_WATER or
								entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
								entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
								entity_type == ENT_TYPE.LIQUID_LAVA or
								entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
							)
							if entity_type == 0 then
								hd_tiletype_post = HD_TILENAME["0"]
							else
								if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = HD_TILENAME["1"]
								elseif entType_is_liquid then hd_tiletype_post = HD_TILENAME["w"]
								-- If it doesn't have a matching HD_TILENAME, return the original one.
								end
								
								spawned_uid = entType_is_liquid and spawn_liquid(entity_type, with_offset_x, with_offset_y, l, 0, 0) or spawn(entity_type, with_offset_x, with_offset_y, l, 0, 0)
							end
						end
					elseif hd_tiletype_post.hd_type ~= nil then -- may be outdated since we could use .spawnfunction with `create_` methods
						danger_spawn(hd_tiletype_post.hd_type, x, y, l, false)
					end
	
					entType_is_container = (
						entity_type == ENT_TYPE.ITEM_POT or
						entity_type == ENT_TYPE.ITEM_CRATE or
						entity_type == ENT_TYPE.ITEM_COFFIN
					)
	
					if hd_tiletype_post.contents ~= nil and entType_is_container and spawned_uid ~= 0 then
						set_contents(spawned_uid, hd_tiletype_post.contents)
					end
	
					if hd_tiletype_post.spawnfunction ~= nil then hd_tiletype_post.spawnfunction({x, y, l}) end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end

function levelcode_bake_spawn_over()
	_x, _y = locate_cornerpos_real(1, 1) -- position of the topleft-most tile of the map
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	c_hi_len = levelh*HD_ROOMOBJECT.DIM.h
	c_wi_len = levelw*HD_ROOMOBJECT.DIM.w
	y = _y
	for level_hi = 1, c_hi_len, 1 do
		x = _x
		for level_wi = 1, c_wi_len, 1 do
			tilecode = global_levelassembly.modification.levelcode[level_hi][level_wi]
			if (
				HD_TILENAME[tilecode] ~= nil and
				HD_TILENAME[tilecode].embedded_ents ~= nil
			) then
				offsetx, offsety = 0, 0
				floorToSpawnOver = nil
				if HD_TILENAME[tilecode].offset_spawnover ~= nil then
					offsetx, offsety = HD_TILENAME[tilecode].offset_spawnover[1], HD_TILENAME[tilecode].offset_spawnover[2]
				end
				floorsAtOffset = get_entities_at(0, MASK.FLOOR, x+offsetx, y+offsety, LAYER.FRONT, 0.5)
				if #floorsAtOffset > 0 then floorToSpawnOver = floorsAtOffset[1] end
				-- # TOTEST: If gems/gold/items are spawning over this, move this method to run after gems/gold/items get embedded. Then here, detect and remove any items already embedded.
				entToEmbed = HD_TILENAME[tilecode].embedded_ents[math.random(1, #HD_TILENAME[tilecode].embedded_ents)]
				
				if (
					entToEmbed ~= 0 and
					floorToSpawnOver ~= nil
				) then
					if HD_TILENAME[tilecode].offset_spawnover ~= nil then
						spawn_entity_over(entToEmbed, floorToSpawnOver, offsetx*(-1), offsety*(-1))
					else
						embed(entToEmbed, floorToSpawnOver)
					end
				end
			end
			x = x + 1
		end
		y = y - 1
	end
end

-- the right side is blocked if:
function detect_sideblocked_right(path, wi, hi)
	levelw, _ = #path[1], #path
	return (
		-- the space to the right goes off of the path
		wi+1 > levelw
		or
		-- the space to the right has already been filled with a number
		path[hi][wi+1] ~= nil
	)
end

-- the left side is blocked
function detect_sideblocked_left(path, wi, hi)
	return (
		-- the space to the left goes off of the path
		wi-1 < 1
		or
		-- the space to the left has already been filled with a number
		path[hi][wi-1] ~= nil
	)
end

-- the under side is blocked
function detect_sideblocked_under(path, wi, hi)
	_, levelh = #path[1], #path
	return (
		-- the space under goes off of the path
		hi+1 > levelh
		or
		-- the space under has already been filled with a number
		path[hi+1][wi] ~= nil
	)
end

-- the top side is blocked
function detect_sideblocked_top(path, wi, hi)
	return (
		-- the space above goes off of the path
		hi-1 < 1
		or
		-- the space above has already been filled with a number
		path[hi-1][wi] ~= nil
	)
end

-- both sides blocked off
function detect_sideblocked_both(path, wi, hi)
	return (
		detect_sideblocked_left(path, wi, hi) and 
		detect_sideblocked_right(path, wi, hi)
	)
end

-- both sides blocked off
function detect_sideblocked_neither(path, wi, hi)
	return (
		(false == detect_sideblocked_left(path, wi, hi)) and 
		(false == detect_sideblocked_right(path, wi, hi))
	)
end

-- Parameters
	-- spread
		-- forces the level to zig-zag from one side of the level to the other, only dropping upon reaching each side
		-- UPDATE: Turns out TikiVillage ended up never needing this *shrug*
	-- Reverse path
		-- swaps s2 exit/entrance codes:
			-- 5,6 = 7,8
			-- 7,8 = 5,6
		-- used for mothership level
function gen_levelrooms_path()
	spread = false
	reverse_path = (state.theme == THEME.NEOBABYLON)

	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	message("levelw, levelh: " .. tostring(levelw) .. ", " .. tostring(levelh))

	-- build an array of unoccupied spaces to start winding downwards from
	rand_startindexes = {}
	for i = 1, levelw, 1 do
		if global_levelassembly.modification.levelrooms[1][i] == nil then
			rand_startindexes[#rand_startindexes+1] = i
		end
	end	
	
	assigned_exit = false
	assigned_entrance = false
	wi, hi = rand_startindexes[math.random(1, #rand_startindexes)], 1
	dropping = false
	
	-- don't spawn paths if roomcodes aren't available
	if HD_ROOMOBJECT.WORLDS[state.theme] == nil or
	(HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and HD_ROOMOBJECT.WORLDS[state.theme].rooms == nil) then
		-- message("level_createpath: No pathRooms available in HD_ROOMOBJECT.WORLDS;")
	else
		while assigned_exit == false do
			pathid = math.random(2)
			ind_off_x, ind_off_y = 0, 0
			if (
				(
					-- num == 2 and
					detect_sideblocked_under(global_levelassembly.modification.levelrooms, wi, hi)
				) or
				spread == true
			) then
				pathid = HD_SUBCHUNKID.PATH
			end
			if pathid == HD_SUBCHUNKID.PATH then
				dir = 0
				if detect_sideblocked_both(global_levelassembly.modification.levelrooms, wi, hi) then
					pathid = HD_SUBCHUNKID.PATH_DROP
				elseif detect_sideblocked_neither(global_levelassembly.modification.levelrooms, wi, hi) then
					dir = (math.random(2) == 2) and 1 or -1
				else
					if detect_sideblocked_right(global_levelassembly.modification.levelrooms, wi, hi) then
						dir = -1
					elseif detect_sideblocked_left(global_levelassembly.modification.levelrooms, wi, hi) then
						dir = 1
					end
				end
				ind_off_x = dir
			end
			
			if pathid == HD_SUBCHUNKID.PATH and dropping == true then
				pathid = HD_SUBCHUNKID.PATH_NOTOP
				dropping = false
			end
			if pathid == HD_SUBCHUNKID.PATH_DROP then
				ind_off_y = 1
				if dropping == true then
					pathid = HD_SUBCHUNKID.PATH_DROP_NOTOP
				end
				dropping = true
			end
			if assigned_entrance == false then
				if pathid == HD_SUBCHUNKID.PATH_DROP then
					pathid = HD_SUBCHUNKID.ENTRANCE_DROP
					if reverse_path == true then
						pathid = HD_SUBCHUNKID.EXIT_NOTOP
					end
				else
					pathid = HD_SUBCHUNKID.ENTRANCE
					if reverse_path == true then
						pathid = HD_SUBCHUNKID.EXIT
					end
				end
				assigned_entrance = true
			elseif hi == levelh then
				if detect_sideblocked_both(global_levelassembly.modification.levelrooms, wi, hi) then
					assigned_exit = true
				else
					assigned_exit = (math.random(2) == 2)
				end
				if assigned_exit == true then
					if pathid == HD_SUBCHUNKID.PATH_NOTOP then
						pathid = HD_SUBCHUNKID.EXIT_NOTOP
						if reverse_path == true then
							pathid = HD_SUBCHUNKID.ENTRANCE_DROP
						end
					else
						pathid = HD_SUBCHUNKID.EXIT
						if reverse_path == true then
							pathid = HD_SUBCHUNKID.ENTRANCE
						end
					end
				end
			end
			global_levelassembly.modification.levelrooms[hi][wi] = pathid

			if (
				HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid] ~= nil
			) then
				levelcode_inject_roomcode(
					pathid, HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid], hi, wi,
					-- rules
					(
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid] ~= nil
					) and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid]() or math.random(#HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid])
				)
			-- else
			-- 	message("levelcreation_setlevelcode_path: No roomcode/num available! - num: " .. num .. "; hi, wi: " .. hi .. ", " .. wi .. ";")
			end

			if assigned_exit == false then -- preserve final coordinates for bugtesting purposes
				wi, hi = (wi+ind_off_x), (hi+ind_off_y)
			end
		end
	end
end


-- SHOPS
-- Hiredhand shops have 1-3 hiredhands
-- Damzel for sale: The price for a kiss will be $8000 in The Mines, and it will increase by $2000 every area, so the prices will be $8000, $10000, $12000 and $14000 for a Damsel kiss in the four areas shops can spawn in. The price for buying the Damsel will be an extra 50% over the kiss price, making the prices $12000, $15000, $18000 and $21000 for all zones.
-- If custom shop generation ever becomes possible:
	-- Determine item pool, allow enabling certain S2 specific items with register_option_bool()
	

-- Wheel Gambling Ideas:
-- Detect purchasing from the game when the player loses 5k and stands right next to a machine
-- You can set flag 20 to turn the machine back on. it just doesn't show a buy dialog but works
-- Hide the dice, without dice it just crashes. you can set its alpha/size to 0 and make it immovable, probably
-- The wheel visuals/spinning:
-- It's most likely doable using the empty item sprites
-- Just have a few immovable objects that rotate and are upscaled :0
-- You could just use a few empty subimages in the items.png file and assign anything else to that frame

-- JUNGLE
-- ENEMIES:
-- Giant Frog
-- - While moving left or right(?), make it "hop" using velocity.
--   - on jump, add velocity up and to the direction it's facing.
-- LEVEL:
-- Haunted level: Spawn tusk idol, make it add a ghost upon disturbing it
--  - (It adds a ghost if the ghost is already spawned. Not sure if 2:30 ghost spawns if skull idol is already tripped)
-- ENT_TYPE_DECORATION_VLAD above alter? Or other banner, idk
-- Black Knight: Cloned shopkeeper with a sheild+extra health.
-- Green Knight: Tikiman/Caveman with extra health.


-- WORM LEVEL
-- ENEMIES:
-- Egg Sack - Replace maggots with 1hp cave mole
-- Bacterium - Maze navigating algorithm run through an array tracking each.
-- If entered from jungle, spawn tikimen, cavemen, monkeys, frogs, firefrogs, bats, and snails.
-- If entered from icecaves, spawn UFOs, Yetis, and bats.

-- ICE_CAVES
-- ENEMIES:
-- Mammoth - Use an enemy that never agros and paces between ledges. Store a bool to fire icebeam on stopping its idle walking cycle.
--  - If runs into player while frozen, kill/damage player.
-- Snowball
	-- once it hits something (has a victim?), revert animation_frame and remove uid from danger_tracker.

-- TEMPLE
-- ENEMIES:
-- Hawk man: Shopkeeper clone without shotgun (Or non teleporting Croc Man???)

-- LEVEL:
-- Script in hell door spawning
-- The Book of the Dead on the player's HUD will writhe faster the closer the player is to the X-coordinate of the entrance (HELL_X)
-- 

-- SCRIPTED ROOMCODE GENERATION
	-- IDEAS:
		-- In a 2d list loop for each room to replace:
			-- 1: log a 2d table of the level path and rooms to replace
				-- 1: As you loop over each room:
					-- Log in separate 2d array `rooms_subchunkids`: Based on HD_SUBCHUNKID and whether the space contains a shopkeep, log subchunk ids as generated by the game.
						-- 0: Non-main path subchunk
						-- 1: Main path, goes L/R (also entrance/exit)
						-- 2: Main path, goes L/R and down (and up if it's below another 2)
						-- 3: Main path, goes L/R and up
						-- 1000: Shop (rename in the future?)
						-- 1001: Vault (rename in the future?)
						-- 1002: Kali (rename in the future?)
						-- 1003: Idol (rename in the future?)
				-- 2: Detect whether there's an exit. Without the exit, we can't move enemies. if there IS no exit, generate a new path with one or adjust the existing path to make one.
					-- UPDATE: May be possible to fix broken exit generation by preventing waddler's shop from spawning entirely.
					-- For instance, the ice caves can sometimes generate no exit on the 4th row.
					-- If no 1 subchunkid exists on the fourth row:
						-- if 2 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
						-- elseif 3 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
							-- replace 3 with 2, mark in `rooms_replaceids`
						-- elseif 1000 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
							-- replace 3 with 2
								-- if vault, mark as 2 in `rooms_replaceids`
								-- elseif shop, mark as 3 in `rooms_replaceids`
				-- 3: Otherwise, here's where script-determined level paths would be managed
					-- For instance, given the chance to have a snake pit, adjust/replace the path with one that includes it.
				-- 4: Log in separate 2d array `rooms_replaceids`:
					-- if no roomcodes exist to replace the room:
						-- 0: Don't touch this room.
					-- if the room has in the path:
					-- 1: Replace this room.
					-- else:
						-- if it's vault, kali alter, or idol trap:
							-- 2: Maintain this room's structure and find a new place to move it to.
						-- if it's a shop:
							-- 3: Maintain this room's structure and find a new place to move it to. Maintain its orientation in relation to the path.
				-- 5: Log which rooms need to be flipped. loop over the path and log in separate 2d array `rooms_orientids`:
					-- if the subchunk id is not a 3:
						-- 0: Don't touch this room.
					-- if the replacement id is a 3:
						-- if the path id to the right of it is a 1, 2 or 3:
							-- 2: Facing right.
						-- if the path id to the left of it is a 1, 2 or 3:
							-- 3: Facing left.
			-- 2: Log uids of all overlapping enemies, move to exit
				-- Parameters
					-- optional table of ENT_TYPE
					-- Mask (default to any mask of 0x4)
				-- Method moves all found entities to the exit door and returns a table of their uids
				-- append each table into a 2d array based on the room they occupied
			-- 3: ???
			-- 4: Generate rooms, log generated rooms
				-- Parameters
					-- optional table of ENT_TYPE
					-- Path
				-- For rooms you replace, keep in mind:
					-- Checks to make sure killing/moving certain floors won't lead to problems, such as shops
						-- IDEA: TOTEST: If flag for shop floor is checked, uncheck it.
					-- Establish a system of methods/parameters for removing certain elements from rooms.
						-- Some scenarios:
							-- get_entities_overlapping() on LIQUID_WATER or LIQUID_LAVA to remove it, otherwise there'd be consequences.
						-- pushblocks/powderkegs, crates/goldbars, encrusted gems/items/goldbits/cavemen(?)
						-- Theme specific entities:
							-- falling platforms
						-- S2 Level feeling-specific entities:
							-- Restless:
								-- remove fog effect, music(? is that possible?)
								-- replace FLOOR_TOMB with normal
								-- remove restless-specific enemies
							-- Dark level: remove torches on rooms you replace
								-- Once all rooms to be replaced are replaced, place torches in those rooms.
				-- Determine roomcodes to use with global list constant (same way as LEVEL_DANGERS[state.theme]) and the current room
					-- global_feelings[*] overrides some or all rooms
				-- append each table into a 2d array based on the room they occupied
				-- for each room, process HD_TILENAME, spawn_entity()
					-- if (tilename == 2 or tilename == j) and math.random() >= 0.5
						-- spawn_entity()
						-- if tilename == 2
							-- mark as 1
						-- if tilename == j
							-- mark as i
					-- else
						-- mark as 0
				-- return into `postgen_roomcodes`
			-- 5: Once `rooms_roomcodes_postgen` is finished, gets baked into a full array of the characters
				-- `postgen_levelcode`
			-- 6: Move enemies from exit to designated rooms/custom spawning system
				-- Parameters
					-- `postgen_levelcode`
			-- 7: Final touchups. This MAY include level background details, ambient sounds.				
				-- If dark level, place torches in rooms you replaced earlier
					-- Once all rooms to be replaced are replaced, place torches in those rooms.
		-- Certain room constants may need to be recognized and marked for replacement. This includes:
			-- Tun rooms
				-- Constraints are ENT_TYPE.MONS_MERCHANT in the front layer
			-- Tun rooms
				-- Constraints are ENT_TYPE.MONS_THEIF in the front layer
			-- Shops and vaults in HELL
		-- Make the outline of a vault room tilecode `2` (50% chance to remove each outlining block)
		-- pass in tiles as nil to ignore.
			-- initialize an empty table t of size n: setn(t, n)
		-- Black Market & Flooded Revamp:
			-- Replace S2 style black market with HD
				-- HD and S2 differences:
					-- S2 black market spawns are 2-2, 2-3, and 2-4
					-- HD spawns are 2-1, 2-2, and 2-3
						-- Prevents the black market from being accessed upon exiting the worm
						-- Gives room for the next level to load as black market
				-- script spawning LOGICAL_BLACKMARKET_DOOR
					-- if feeling_check("BLACKMARKET_ENTRANCE") == true
				-- In the roomcode generation, establish methods and parameters to make shop spawning possible
					-- Will need at least:
						-- 
				-- if detect_s2market() == true 
			-- Use S2 black market for flooded level feeling
				-- Set FLOODED: Detect when S2 black market spawns
					-- function onloading_setfeeling_load_flooded: roll HD_FEELING_FLOODED_CHANCE 4 times (or 3 if you're not going to try to extend the levels to allow S2 black market to spawn)
					-- for each roll: if true, return true
					-- if it returned true, set LOAD_FLOODED to true
						-- if detect_s2market() == true and LOAD_FLOODED == true, set HD_FEELING_FLOODED
			
	-- Roomcodes:
		-- Level Feelings:
			-- TIKI VILLAGE
				-- Notes:
					-- Tiki Village roomcodes never replace top (or bottom?) path
					-- Has no sideroom codes
					-- Unlockable coffin is always a path drop(?)
					-- Might(?) always generate with a zig-zag like path
				-- Roomcodes:
					-- 
			-- SNAKE PIT
				-- Notes:
					-- Doesn't have to link with main path
					-- I've seen it generate starting at the top level, idk about bottom
					-- Appears to occupy three side rooms vertically
				-- Ideas:
					-- Spawning conditions:
					-- If in dwelling and three side rooms vertically exist, have a random chance to replace them with snake pit.
				-- Roomcodes:
					--

-- bitwise notes:
-- print(3 & 5)  -- bitwise and
-- print(3 | 5)  -- bitwise or
-- print(3 ~ 5)  -- bitwise xor
-- print(7 >> 1) -- bitwise right shift
-- print(7 << 1) -- bitwise left shift
-- print(~7)     -- bitwise not

-- For mammoth behavior: If set, run it as a function: within the function, run a check on an array you pass in defining the `animation_frame`s you replace and the enemy you are having override its idle state.


-- # TODO: Implement system that reviews savedata to unlock coffins.
-- Some cases should be as simple as "If it's not unlocked yet, set this coffin to this character."
-- Other cases... well... involve filtering through multiple coffins in the same area,
-- giving a random character unlock, and level feeling specific unlocks.
-- Some may need to be enabled as unlocked from the beginning!

-- Character list: SUBJECT TO CHANGE.
-- - Decide whether original colors should be preserved, should we want to include reskins;
-- - (HD Little Jay = mint green; S2 Little Jay = Lime)
-- - Could just wing it and decide on case-by-case, ie, Roffy D Sloth -> PacoEspelanko
-- - But that may not make everyone happy; we want the mod to appeal to widest audience
-- - Heck, maybe we don't reskin any of them and leave it up to the users.
-- - But that's the problem, what coffins do we replace then...
-- - Maybe we make two versions: One to preserve HD's unlocks by color, and one for character equivalents

-- https://spelunky.fandom.com/wiki/Spelunkers
-- https://spelunky.fandom.com/wiki/Spelunky_2_Characters
-- ###HD EQUIVALENTS###
-- Spelunky Guy: 	Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_GUY_SPELUNKY
-- Solution:		Enable from the start via savedata.

-- Colin Northward:	Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_COLIN_NORTHWARD
-- Solution:		Already enabled(?)

-- Alto Singh:		Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_BANDA
-- Solution:		Enable from the start via savedata.

-- Liz Mutton:		Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_GREEN_GIRL
-- Solution:		Enable from the start via savedata.

-- Tina Flan:		Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.CHAR_TINA_FLAN
-- Solution:		No modifications necessary.

-- Lime:			Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.ROFFY_D_SLOTH
-- Solution:		RESKIN -> PacoEspelanko. https://spelunky.fyi/mods/m/pacoespelanko/

-- Margaret Tunnel:	Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.CHAR_MARGARET_TUNNEL
-- Solution:		IF NEEDED, lock from the start in savedata.

-- Cyan:			Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. https://spelunky.fyi/mods/m/cyan-from-hd/

-- Van Horsing:		Coffin at the top of the Haunted Castle level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. https://spelunky.fyi/mods/m/van-horsing-sprite-sheet-all-animations/

-- Jungle Warrior:	Defeat Olmec and get to the exit.
-- Replacement:		ENT_TYPE.CHAR_AMAZON
-- Solution:		No modifications necessary.

-- Meat Boy:		Dark green pod near the end of the Worm.
-- Replacement:		ENT_TYPE.CHAR_PILOT
-- Solution:		RESKIN -> Meat Boy. https://spelunky.fyi/mods/m/meat-boy-with-bandage-rope/

-- Yang:			Defeat King Yama and get to the exit.
-- Replacement:		ENT_TYPE.CHAR_CLASSIC_GUY
-- Solution:		RESKIN(?)

-- The Inuk:		Found inside a coffin in a Yeti Kingdom level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA.

-- The Round Girl:	Found inside a coffin in a Spider's Lair level.
-- Replacement:		ENT_TYPE.CHAR_VALERIE_CRUMP
-- Solution:		No modifications necessary.

-- Ninja:			Found inside a coffin in Olmec's Chamber.
-- Replacement:		ENT_TYPE.CHAR_DIRK_YAMAOKA
-- Solution:		No modifications necessary.

-- The Round Boy:	Found inside a coffin in a Tiki Village in the Jungle.
-- Replacement:		ENT_TYPE.OTAKU
-- Solution:		No modifications necessary.

-- Cyclops:			Can be bought from the Black Market for $10,000, or simply 'kidnapped'. May also be found in a coffin after seeing him in the Black Market.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. S2 has a coffin in the black market.

-- Viking:			Found inside a coffin in a Flooded Cavern or "The Dead Are Restless" level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA

-- Robot:			Found inside a capsule in the Mothership.
-- Replacement:		ENT_TYPE.CHAR_LISE_SYSTEM
-- Solution:		No modifications necessary.

-- Golden Monk:		Found inside a coffin in the City of Gold.
-- Replacement:		ENT_TYPE.CHAR_AU
-- Solution:		Literally no modifications necessary, maybe not even scripting anything.

-- ###UNDETERMINED###

-- Ana Spelunky:	ENT_TYPE.CHAR_ANA_SPELUNKY
-- Solution:		IF NEEDED, lock from the start in savedata.

-- Princess Airyn:	ENT_TYPE.CHAR_PRINCESS_AIRYN
-- Solution:		NO IDEA

-- Manfred Tunnel:	ENT_TYPE.CHAR_MANFRED_TUNNEL
-- Solution:		NO IDEA

-- Coco Von Diamonds:	ENT_TYPE.CHAR_COCO_VON_DIAMONDS
-- Solution:		NO IDEA

-- Demi Von Diamonds:	ENT_TYPE.CHAR_DEMI_VON_DIAMONDS
-- Solution:		

-- WORM UNLOCK
-- coffin_e = get_entity(create_unlockcoffin(x, y, l))
-- coffin_e.flags = set_flag(coffin_e.flags, ENT_FLAG.NO_GRAVITY)
-- coffin_m = coffin_e:as_movable()
-- -- coffin_m.animation_frame = 0
-- coffin_m.velocityx = 0
-- coffin_m.velocityy = 0

-- IDEA: Black Market unlock
-- if character hasn't been unlocked yet:
	-- if `blackmarket_char_witnessed` == false:
		--`blackmarket_char_witnessed` = true
		-- Have him up for sale in the black market
			-- if purchased or shopkeeprs agrod:
				-- unlock character
	-- if `blackmarket_char_witnessed` == true:
		-- found in coffin elsewhere (where?)

-- BORDERS
-- use https://spelunky.fyi/mods/m/sample-mod-custom-in-engine-textures/?c=2366
-- to replace border textures for:
	-- The Worm
	-- Hell (Volcana)
-- Reskin textures for:
	-- Tiamat (as Hell)
