meta.name = "Spelunky HD 2"
meta.version = "1"
meta.description = "Spelunky HD's campaign inside of Spelunky 2"
meta.author = "Super Ninja Fat"

-- uncomment to allow loading unlocks.txt
-- meta.unsafe = true

-- register_option_float("hd_ui_botd_a_w", "UI: botd width", 0.08, 0.0, 99.0)
-- register_option_float("hd_ui_botd_b_h", "UI: botd height", 0.12, 0.0, 99.0)
-- register_option_float("hd_ui_botd_c_x", "UI: botd x", 0.2, -999.0, 999.0)
-- register_option_float("hd_ui_botd_d_y", "UI: botd y", 0.93, -999.0, 999.0)
-- register_option_float("hd_ui_botd_e_squash", "UI: botd uvx shifting rate", 0.25, -5.0, 5.0)

register_option_bool("hd_debug_info_boss", "Debug: Bossfight debug info", false)
register_option_bool("hd_debug_info_boulder", "Debug: Boulder debug info", false)
register_option_bool("hd_debug_info_feelings", "Debug: Level feelings debug info", false)
register_option_bool("hd_debug_info_path", "Debug: Path debug info", true)
register_option_bool("hd_debug_info_tongue", "Debug: Wormtongue debug info", false)
register_option_bool("hd_debug_invis", "Debug: Enable visibility of bts entities (invis ents for custom enemies, etc)", false)
register_option_bool("hd_og_ankhprice", "OG: Set the Ankh price to a constant $50,000 like it was in HD", false)
register_option_bool("hd_og_boulder_agro", "OG: Boulder - Enrage shopkeepers as they did in HD", true)
register_option_bool("hd_og_ghost_nosplit", "OG: Ghost - Prevent the ghost from splitting", false)
register_option_bool("hd_og_ghost_slow", "OG: Ghost - Revert the ghost to its HD speed", false)
register_option_bool("hd_og_ghost_time", "OG: Ghost - Change spawntime from 3:00->2:30 and 2:30->2:00 when cursed.", true)
register_option_bool("hd_og_nocursepot", "OG: Remove all Curse Pots", true)
register_option_bool("hd_test_give_botd", "Testing: Start with the Book of the Dead", true)
register_option_bool("hd_test_unlockbossexits", "Testing: Unlock boss exits", false)
register_option_bool("hd_z_antitrapcuck", "Prevent spawning traps that can cuck you", true)
register_option_bool("hd_z_toastfeeling", "Allow script-enduced feeling messages", true)

-- TODO:
register_option_bool("hd_og_boulder_phys", "OG: Boulder - Adjust to have the same physics as HD", false)

bool_to_number={ [true]=1, [false]=0 }

DANGER_GHOST_UIDS = {}
GHOST_TIME = 10800
GHOST_VELOCITY = 0.7
IDOLTRAP_TRIGGER = false
WHEEL_SPINNING = false
WHEEL_SPINTIME = 700 -- TODO: HD's was 10-11 seconds, convert to this.
ACID_POISONTIME = 270 -- TODO: Make sure it matches with HD, which was 3-4 seconds
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
TONGUE_UID = nil
TONGUE_BG_UID = nil
HAUNTEDCASTLE_ENTRANCE_UID = nil
BLACKMARKET_ENTRANCE_UID = nil
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
BOOKOFDEAD_TIC_LIMIT = 5
BOOKOFDEAD_RANGE = 14
bookofdead_tick = 0
-- bookofdead_tick_min = BOOKOFDEAD_TIC_LIMIT
bookofdead_frames = 4
bookofdead_frames_index = 1
bookofdead_squash = (1/bookofdead_frames) --options.hd_ui_botd_e_squash
PREFIRSTLEVEL_NUM = 40

OBTAINED_BOOKOFDEAD = false

UI_BOTD_IMG_ID, UI_BOTD_IMG_W, UI_BOTD_IMG_H = create_image('bookofdead.png')
UI_BOTD_PLACEMENT_W = 0.08
UI_BOTD_PLACEMENT_H = 0.12
UI_BOTD_PLACEMENT_X = 0.2
UI_BOTD_PLACEMENT_Y = 0.93

RUN_UNLOCK_AREA_CHANCE = 1
RUN_UNLOCK_AREA = {
	DWELLING = false,
	JUNGLE = false,
	ICE_CAVES = false,
	TEMPLE = false
}
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
	["SPIDERLAIR"] = {
		chance = 0,
		themes = { THEME.DWELLING },
		message = "My skin is crawling..."
	},
	["SNAKEPIT"] = {
		chance = 0,
		themes = { THEME.DWELLING },
		message = "I hear snakes... I hate snakes!"
	},
	["RESTLESS"] = {
		chance = 1,
		themes = { THEME.JUNGLE },
		message = "The dead are restless!"
	},
	["TIKIVILLAGE"] = {
		chance = 0,
		themes = { THEME.JUNGLE }
	},
	["FLOODED"] = {
		chance = 1,
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
		chance = 1,
		themes = { THEME.ICE_CAVES },
		message = "It smells like wet fur in here."
	},
	["UFO"] = {
		chance = 1,
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
		chance = 1,
		themes = { THEME.TEMPLE },
		message = "You hear prayers to Kali!"
	},
	["HELL"] = {
		themes = { THEME.VOLCANA },
		load = 1,
		message = "A horrible feeling of nausea comes over you!"
	},
}

-- TODO: issues with current hardcodedgeneration-dependent features:
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
HD_ROOMOBJECT.GENERIC = {
	shop = {
		{ -- prize wheel
			subchunk_id = "1001",
			pathalign = true,
			roomcodes = {
				"11111111111111..1111....22...1.Kl00002.....000W0.0.0%00000k0.$%00S0000bbbbbbbbbb",
				"11111111111111..11111...22......20000lK.0.W0000...0k00000%0.0000S00%$.bbbbbbbbbb"
			}
		},
		{ -- Damzel
			subchunk_id = "1002",
			pathalign = true,
			roomcodes = {
				"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K00S0000bbbbbbbbbb",
				"11111111111111..11111...22..11..2000l.110.W0000...0k00000...0000S00K..bbbbbbbbbb"
			}
		},
		{ -- Hiredhands(?)
			subchunk_id = "1003",
			pathalign = true,
			roomcodes = {
				"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0SSS000bbbbbbbbbb",
				"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000SSS0K..bbbbbbbbbb"
			}
		},
		{ -- Hiredhands(?)
			subchunk_id = "1004",
			pathalign = true,
			roomcodes = {
				"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0S0S000bbbbbbbbbb",
				"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S0S0K..bbbbbbbbbb"
			}
		},
		{ -- ?
			subchunk_id = "1005",
			pathalign = true,
			roomcodes = {
				"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..KS000000bbbbbbbbbb",
				"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S000K..bbbbbbbbbb"
			}
		}
	},
	vault = {
		{
			subchunk_id = "1010",
			roomcodes = {
				"11111111111111111111111|00011111100001111110EE0111111000011111111111111111111111"
			}
		}
	},
	alter = {
		{
			subchunk_id = "1011",
			roomcodes = {
				"220000002200000000000000000000000000000000000000000000x0000002211112201111111111"
			}
		}
	}
}
HD_ROOMOBJECT.FEELINGS = {
	SPIDERLAIR = {
		
		
		-- coffin_unlockable = {
			
		-- },
		-- coffin_unlockable_vertical = {
		
		-- },
	},
	SNAKEPIT = {
		pit = {
			-- Notes:
				-- spawn steps:
					-- 106
						-- levelw, levelh = get_levelsize()
						-- structx = math.random(1, levelw)
						-- spawn 106 at structx, 1
					-- 107
						-- _, levelh = get_levelsize()
						-- struct_midheight = math.random(1, levelh-2)
						-- for i = 1, struct_midheight, 1 do
							-- spawn 107 at structx, i
						-- end
					-- 108
						-- spawn 108 at structx, struct_midheight+1
			{
				subchunk_id = "106",
				-- grabs 5 and upwards from path_drop
				roomcodes = {
				"00000000000000000000600006000000000000000000000000000000000002200002201112002111",
				"00000000000000220000000000000000200002000112002110011100111012000000211111001111",
				"00000000000060000000000000000000000000000000000000002022020000100001001111001111",
				"11111111112222222222000000000000000000000000000000000000000000000000001120000211",
				"11111111112222111111000002211200000002100000000000200000000000000000211120000211",
				"11111111111111112222211220000001200000000000000000000000000012000000001120000211",
				"11111111112111111112021111112000211112000002112000000022000002200002201111001111"
				}
			},
			{
				subchunk_id = "107",
				roomcodes = {"111000011111n0000n11111200211111n0000n11111200211111n0000n11111200211111n0000n11"}
			},
			{
				subchunk_id = "108",
				roomcodes = {"111000011111n0000n1111100001111100N0001111N0110N11111NRRN1111111M111111111111111"}
			}
		}
	},
	SACRIFICIALPIT = {
		pit = {
			-- Notes:
				-- start from top
				-- seems to always be top to bottom
			-- Spawn steps:
				-- 116
					-- levelw, levelh = get_levelsize()
					-- structx = math.random(1, levelw)
					-- spawn 116 at structx, 1
				-- 117
					-- _, levelh = get_levelsize()
					-- struct_midheight = levelh-2
					-- for i = 1, struct_midheight, 1 do
						-- spawn 117 at structx, i
					-- end
				-- 118
					-- spawn 118 at structx, struct_midheight+1
			{
				subchunk_id = "116",
				-- grabs 5 and upwards from path_drop
				roomcodes = {
				"0000000000000000000000000000000000000000000100100000110011000111;01110111BBBB111"
				}
			},
			{
				subchunk_id = "117",
				roomcodes = {"11200002111120000211112000021111200002111120000211112000021111200002111120000211"}
			},
			{
				subchunk_id = "118",
				roomcodes = {"112000021111200002111120000211113wwww311113wwww311113wwww31111yyyyyy111111111111"}
			}
		}
	},
}
HD_ROOMOBJECT.WORLDS = {
	DWELLING = { -- Depending on how we access HD_ROOMOBJECT, rename this to MINES
		coffin_unlockable = {
			{
				subchunk_id = "74",
				pathalign = true,
				roomcodes = {
					"vvvvvvvvvvv++++++++vvL00000g0vvPvvvvvvvv0L000000000L0:000:0011111111111111111111",
					"vvvvvvvvvvv++++++++vvg000000LvvvvvvvvvPv00000000L000:000:0L011111111111111111111" -- facing left
				}
			},
		},
	},
	JUNGLE = {
	},
	ICE_CAVES = {
	},
	TEMPLE = {
	},
	OLMEC = {
		coffin_unlockable = {
			-- Spawn steps:
				-- levelw, _ = get_levelsize()
				-- structx = 1
				-- chance = math.random()
				-- if chance >= 0.5 then structx = levelw end
				-- spawn 143 at structx, 1
			{
				subchunk_id = "143",
				roomcodes = {
					"00000100000E110111E001100001100E100001E00110g00110001111110000000000000000000000",
					"00001000000E111011E001100001100E100001E00110g00110001111110000000000000000000000"
				}
			}
		}
	}
}

-- path:	DRESSER
-- drop:	SIDETABLE
-- notop:	SHORTCUTSTATIONBANNER
HD_SUBCHUNKID_TERM = {
	["path"] = {
		entity_type = ENT_TYPE.BG_BASECAMP_DRESSER,
		kill = true
	},
	["drop"] = {
		entity_type = ENT_TYPE.BG_BASECAMP_SIDETABLE,
		kill = true
	},
	["notop"] = {
		entity_type = ENT_TYPE.BG_BASECAMP_SHORTCUTSTATIONBANNER,
		kill = true
	},
	["entrance"] = { entity_type = ENT_TYPE.FLOOR_DOOR_ENTRANCE },
	["exit"] = { entity_type = ENT_TYPE.FLOOR_DOOR_EXIT },
}
-- TODO: Player Coffins
-- Subchunkid terminology
	-- 00 -- side				-- Empty/unassigned
	-- 01 -- path_normal		-- Standard room (horizontal exit)
	-- 02 -- path_drop			-- Path to exit (vertical exit)
	-- 03 -- path_notop			-- Path to exit (horizontal exit)
	-- 04 -- path_drop_notop	-- Path to exit (vertical exit)
	-- 05 -- entrance			-- Player start (horizontal exit)
	-- 06 -- entrance_drop		-- Player start (vertical exit)
	-- 07 -- exit				-- Exit door (horizontal entrance)
	-- 08 -- exit_notop			-- Exit door (vertical entrance)

-- TODO: Choose a unique ENT_TYPE for (at least the first 4) SUBCHUNKIDs
HD_SUBCHUNKID = {
	["0"] = {
		{ entity_type = 0 }
	},
	["1"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["path"].entity_type }
	},
	["2"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["path"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["drop"].entity_type }
	},
	["3"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["path"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["notop"].entity_type }
	},
	["4"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["path"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["drop"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["notop"].entity_type }
	},
	["5"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["entrance"].entity_type }
	},
	["6"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["entrance"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["drop"].entity_type }
	},
	["7"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["exit"].entity_type }
	},
	["8"] = {
		{ entity_type = HD_SUBCHUNKID_TERM["exit"].entity_type },
		{ entity_type = HD_SUBCHUNKID_TERM["notop"].entity_type }
	},
	-- ["6" = , -- Upper part of snake pit
	-- ["7" = , -- Middle part of snake pit
	-- ["8" = , -- Bottom part of snake pit
	-- ["9" = , -- Rushing Water islands/lake surface
	-- ["10" = , -- Rushing Water lake
	-- ["11" = , -- Rushing Water lake with Ol' Bitey
	-- ["12" = , -- Left part of psychic presence
	-- ["13" = , -- Middle part of psychic presence
	-- ["14" = , -- Right part of psychic presence
	-- ["15" = , -- Moai
	-- ["16" = , -- Kalipit top
	-- ["17" = , -- Kalipit middle
	-- ["18" = , -- Kalipit bottom
	-- ["19" = , -- Vlad's Tower top
	-- ["20" = , -- Vlad's Tower middle
	-- ["21" = , -- Vlad's Tower bottom
	-- ["22" = , -- Beehive with left/right exits
	-- ["24" = , -- Beehive with left/down exits
	-- ["25" = , -- Beehive with left/up exits
	-- ["26" = , -- Book of the Dead room left
	-- ["27" = , -- Book of the Dead room right
	-- ["28" = , -- Top part of mothership entrance
	-- ["29" = , -- Bottom part of mothership entrance
	-- ["30" = , -- Castle top layer middle-left
	-- ["31" = , -- Castle top layer middle-right
	-- ["32" = , -- Castle middle layers left with exits left/right and sometimes up
	-- ["33" = , -- Castle middle layers left with exits left/right/down
	-- ["34" = , -- Castle exit
	-- ["35" = , -- Castle altar
	-- ["36" = , -- Castle right wall
	-- ["37" = , -- Castle right wall with exits left/down
	-- ["38" = , -- Castle right wall bottom layer
	-- ["39" = , -- Castle right wall bottom layer with exit up
	-- ["40" = , -- Castle bottom right moat
	-- ["41" = , -- Crysknife pit left
	-- ["42" = , -- Crysknife pit right
	-- ["43" = , -- Castle coffin
	-- ["46" = , -- Alien queen
	-- ["47" = , -- DaR Castle Entrance
	-- ["48" = , -- DaR Crystal Idol
}

-- retains HD tilenames
HD_TILENAME = {
	-- ["1"] = {
		-- entity_types = ENT_TYPE.FLOOR_GENERIC,
		-- description = "Terrain",
	-- },
	-- ["2"] = ENT_TYPE.FLOOR_GENERIC,
	-- ["+"] = ENT_TYPE.FLOORSTYLED_STONE,
	-- ["4"] = ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
	-- ["G"] = ENT_TYPE.FLOOR_TOMB,
	-- ["I"] = ENT_TYPE.ITEM_IDOL,
	-- ["i"] = ENT_TYPE.FLOOR_ICE,
	-- ["j"] = ENT_TYPE.FLOOR_ICE,
	["0"] = {
		description = "Empty",
	},
    ["#"] = {
		entity_types = {ENT_TYPE.ACTIVEFLOOR_POWDERKEG},
		description = "TNT Box",
	},
    ["$"] = {
		description = "Roulette Item",
	},
    ["%"] = {
		description = "Roulette Door",
	},
    ["&"] = { -- 50% chance to spawn
		entity_types = {ENT_TYPE.LOGICAL_WATER_DRAIN, 0},
		alternate_types = {
			[THEME.TEMPLE] = {ENT_TYPE.LOGICAL_LAVA_DRAIN, 0},
			[THEME.VOLCANA] = {ENT_TYPE.LOGICAL_LAVA_DRAIN, 0},
		},
		offset = { 0, -2 },
		alternate_offset = {
			[THEME.TEMPLE] = { 0, 0 },
			[THEME.VOLCANA] = { 0, 0 },
		},
		description = "Waterfall",
	},
    ["*"] = {
		-- hd_type = HD_ENT.TRAP_SPIKEBALL
		description = "Spikeball",
	},
    ["+"] = {
		description = "Wooden Background",
	},
    [","] = {
		entity_types = {
			ENT_TYPE.FLOOR_GENERIC,
			ENT_TYPE.FLOORSTYLED_MINEWOOD
		},
		description = "Terrain/Wood",
	},
    ["-"] = {
		entity_types = {ENT_TYPE.ACTIVEFLOOR_THINICE},
		description = "Cracking Ice",
	},
    ["."] = {
		entity_types = {ENT_TYPE.FLOOR_GENERIC},
		description = "Unmodified Terrain",
	},
    ["1"] = {
		entity_types = {ENT_TYPE.FLOOR_GENERIC},
		description = "Terrain",
	},
    ["2"] = {
		entity_types = {
			ENT_TYPE.FLOOR_GENERIC,
			0
		},
		alternate_types = {
			[THEME.EGGPLANT_WORLD] = {
				ENT_TYPE.FLOORSTYLED_GUTS,
				ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK,
				0
			},
		},
		description = "Terrain/Empty",
	},
    ["3"] = {
		entity_types = {
			ENT_TYPE.FLOOR_GENERIC,
			ENT_TYPE.LIQUID_WATER
		},
		alternate_types = {
			[THEME.TEMPLE] = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.LIQUID_WATER
			},
			[THEME.VOLCANA] = {
				ENT_TYPE.FLOOR_GENERIC,
				ENT_TYPE.LIQUID_WATER
			},
		},
		description = "Terrain/Water",
	},
    ["4"] = {
		entity_types = {ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK},
		description = "Pushblock",
	},
    ["5"] = {
		-- TODO: subchunk parameters
		description = "Ground Obstacle Block",
	},
    ["6"] = {
		-- TODO: subchunk parameters
		description = "Floating Obstacle Block",
	},
    ["7"] = {
		entity_types = {
			ENT_TYPE.FLOOR_SPIKES,
			0
		},
		description = "Spikes/Empty",
	},
    ["8"] = {
		-- TODO: subchunk parameters
		description = "Door with Terrain Block",
	},
    ["9"] = {
		-- TODO: subchunk parameters
		description = "Door without Platform",
	},
    [":"] = {
		entity_types = {ENT_TYPE.MONS_SCORPION},
		alternate_types = {
			[THEME.JUNGLE] = {ENT_TYPE.MONS_TIKIMAN}
		},
		description = "Tikiman or Scorpion from Mines Coffin",--"Scorpion from Mines Coffin",
	},
    [";"] = {
		-- TODO: two across parameter
		description = "Damsel and Idol from Kalipit",
	},
    ["="] = {
		description = "Wood with Background",
	},
    ["A"] = {
		-- TODO: two across parameter
		entity_types = {ENT_TYPE.FLOOR_IDOL_BLOCK},
		description = "Mines Idol Platform",
	},
    ["B"] = {
		-- TODO: Find a good reskin replacement
		entity_types = {ENT_TYPE.FLOORSTYLED_STONE},
		description = "Jungle/Temple Idol Platform",
	},
    ["C"] = {
		-- TODO: Ceiling Idol Trap
		entity_types = {ENT_TYPE.FLOORSTYLED_STONE},
		description = "Nonmovable Pushblock", -- also idol trap ceiling blocks
	},
    ["D"] = {
		-- TODO: door creation (should be same door as "%")
		description = "Door Gate", -- also used in temple idol trap
	},
    ["E"] = {
		-- TODO: subchunk parameters
		entity_types = {
			ENT_TYPE.FLOOR_GENERIC,
			ENT_TYPE.ITEM_CRATE,
			ENT_TYPE.ITEM_CHEST,
			0
		},
		description = "Terrain/Empty/Crate/Chest",
	},
    ["F"] = {
		-- TODO: subchunk parameters
		description = "Falling Platform Obstacle Block",
	},
    ["G"] = {
		entity_types = {ENT_TYPE.FLOOR_LADDER},
		description = "Ladder",
	},
    ["H"] = {
		entity_types = {ENT_TYPE.FLOOR_LADDER_PLATFORM},
		description = "Ladder Platform",
	},
    ["I"] = {
		offset = { 0.5, 0 },
		description = "Idol",
	},
    ["J"] = {
		entity_types = {ENT_TYPE.MONS_GIANTFISH},
		description = "Ol' Bitey",
	},
    ["K"] = {
		description = "Shopkeeper",
	},
    ["L"] = {
		entity_types = {ENT_TYPE.FLOOR_LADDER},
		alternate_types = {
			[THEME.JUNGLE] = {ENT_TYPE.FLOOR_VINE},
			[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOOR_VINE},
			[THEME.VOLCANA] = {ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN},
		},
		description = "Ladder",
	},
    ["M"] = {
		description = "Crust Mattock from Snake Pit",
	},
    ["N"] = {
		entity_types = {ENT_TYPE.MONS_SNAKE},
		description = "Snake from Snake Pit",
	},
    ["O"] = {
		description = "Moai Head",
	},
    ["P"] = {
		entity_types = {ENT_TYPE.FLOOR_LADDER_PLATFORM},
		description = "Ladder Platform",
	},
    ["Q"] = {
		entity_types = {ENT_TYPE.FLOOR_LADDER},
		alternate_types = {
			[THEME.JUNGLE] = {ENT_TYPE.FLOOR_VINE},
			[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOOR_VINE},
			[THEME.VOLCANA] = {ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN},
		},
		-- TODO: Generate ladder to just above floor.
		description = "Variable-Length Ladder",
	},
    ["R"] = {
		description = "Ruby from Snakepit",
	},
    ["S"] = {
		description = "Shop Items",
	},
    ["T"] = {
		-- TODO: Tree spawn method
		description = "Tree",
	},
    ["U"] = {
		entity_types = {ENT_TYPE.MONS_VLAD},
		description = "Vlad",
	},
    ["V"] = {
		-- TODO: subchunk parameters
		description = "Vines Obstacle Block",
	},
    ["W"] = {
		description = "Unknown: Something Shop-Related",
	},
    ["X"] = {
		entity_types = {ENT_TYPE.MONS_GIANTSPIDER},
		-- alternate_hd_types = {
		-- -- Hell: Horse Head & Ox Face
		-- },
		-- offset = { 0.5, 0 },
		description = "Giant Spider",
	},
    ["Y"] = {
		entity_types = {ENT_TYPE.MONS_YETIKING},
		alternate_types = {
			[THEME.TEMPLE] = {ENT_TYPE.MONS_MUMMY},
		},
		description = "Yeti King",
	},
    ["Z"] = {
		entity_types = {ENT_TYPE.FLOORSTYLED_BEEHIVE},
		description = "Beehive Tile with Background",
	},
    ["a"] = {
		entity_types = {ENT_TYPE.ITEM_PICKUP_ANKH},
		description = "Ankh",
	},
	-- TODO:
		-- Add alternative shop floor of FLOOR_GENERIC
		-- Modify all HD shop roomcodes to accommodate this.
    ["b"] = {
		entity_types = {ENT_TYPE.FLOOR_MINEWOOD},
		flags = {
			[24] = true
		},
		description = "Shop Floor",
	},
    ["c"] = {
		spawnfunction = function(params)
			set_timeout(create_idol_crystalskull, 10)
		end,
		offset = { 0.5, 0 },
		description = "Crystal Skull",
	},
    ["d"] = {
		entity_types = {ENT_TYPE.FLOOR_JUNGLE},
		alternate_types = {
			[THEME.EGGPLANT_WORLD] = {ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK},
		},
		description = "Jungle Terrain",
	},
    ["e"] = {
		entity_types = {ENT_TYPE.FLOORSTYLED_BEEHIVE},
		description = "Beehive Tile",
	},
    ["f"] = {
		entity_types = {ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM},
		description = "Falling Platform",
	},
    ["g"] = {
		spawnfunction = function(params)
			create_unlockcoffin(params[1], params[2], params[3])
		end,
		entity_types = {ENT_TYPE.ITEM_COFFIN},
		description = "Coffin",
	},
    ["h"] = {
		entity_types = {ENT_TYPE.FLOORSTYLED_VLAD},
		description = "Hell Terrain", -- haunted castle alter
		-- TODO: subchunk parameters
	},
    ["i"] = {
		entity_types = {ENT_TYPE.FLOOR_ICE},
		description = "Ice Block",
	},
    ["j"] = {
		-- TODO: Investigate in HD. Pretty sure this is "Ice Block/Empty".
		description = "Ice Block with Caveman",
	},
    ["k"] = {
		entity_types = {ENT_TYPE.DECORATION_SHOPSIGN},
		offset = { 0, 4 },
		description = "Shop Entrance Sign",
	},
    ["l"] = {
		entity_types = {ENT_TYPE.ITEM_LAMP},
		description = "Shop Lantern",
	},
    ["m"] = {
		entity_types = {ENT_TYPE.FLOOR_GENERIC},
		flags = {
			[2] = true
		},
		description = "Unbreakable Terrain",
	},
    ["n"] = {
		entity_types = {
			ENT_TYPE.FLOOR_GENERIC,
			ENT_TYPE.MONS_SNAKE,
			0,
		},
		description = "Terrain/Empty/Snake",
	},
    ["o"] = {
		entity_types = {ENT_TYPE.ITEM_ROCK},
		description = "Rock",
	},
    ["p"] = {
		-- Not sure about this one. It's only used in the corners of the crystal skull jungle roomcode.
		-- TODO: Investigate in HD
		entity_types = {ENT_TYPE.ITEM_GOLDBAR},
		description = "Treasure/Damsel",
	},
    ["q"] = {
		-- TODO: Trap Prevention.
		entity_types = {ENT_TYPE.LIQUID_WATER},
		description = "Obstacle-Resistant Terrain",
	},
    ["r"] = {
		-- TODO: subchunk parameters
		description = "Mines Terrain/Temple Terrain/Pushblock",
	},
    ["s"] = {
		entity_types = {ENT_TYPE.FLOOR_SPIKES},
		description = "Spikes",
	},
    ["t"] = {
		-- entity_types = {
			-- ENT_TYPE.FLOORSTYLED_TEMPLE,
			-- ENT_TYPE.FLOOR_JUNGLE
		-- },
		-- TODO: ????? Investigate in HD.
		description = "Temple/Castle Terrain",
	},
    ["u"] = {
		entity_types = {ENT_TYPE.MONS_VAMPIRE},
		description = "Vampire from Vlad's Tower",
	},
    ["v"] = {
		entity_types = {ENT_TYPE.FLOORSTYLED_MINEWOOD},
		alternate_types = {
			[THEME.EGGPLANT_WORLD] = {ENT_TYPE.FLOORSTYLED_GUTS, ENT_TYPE.LIQUID_WATER},
		},
		description = "Wood",
	},
    ["w"] = {
		entity_types = {ENT_TYPE.LIQUID_WATER},
		alternate_types = {
			[THEME.TEMPLE] = {ENT_TYPE.LIQUID_LAVA},
			[THEME.VOLCANA] = {ENT_TYPE.LIQUID_LAVA},
		},
		description = "Water",
	},
    ["x"] = {
		description = "Kali Altar",
	},
    ["y"] = {
		description = "Crust Ruby in Terrain",
	},
    ["z"] = {
		entity_types = {
			ENT_TYPE.FLOORSTYLED_BEEHIVE,
			0
		},
		alternate_types = {
			[THEME.DWELLING] = {ENT_TYPE.ITEM_GOLDBAR},
		},
		-- TODO: Temple has bg pillar as an alternative
		description = "Beehive Tile/Empty",
	},
    ["|"] = {
		description = "Vault",
	},
    ["~"] = {
		entity_types = {ENT_TYPE.FLOOR_SPRING_TRAP},
		description = "Bounce Trap",
	},
	
		-- description = "Unknown",
}


TILEFRAMES_FLOOR = {
	-- 1x1
	{
		frames = {0},
		dim = {1, 1}
	},
	{
		frames = {1},
		dim = {1, 1}
	},
	{
		frames = {12},
		dim = {1, 1}
	},
	{
		frames = {13},
		dim = {1, 1}
	},
	-- 1x2
	{
		frames = {2, 14},
		dim = {1, 2}
	},
	{
		frames = {3, 15},
		dim = {1, 2}
	},
	-- 2x1
	{
		frames = {24, 25},
		dim = {2, 1}
	},
	{
		frames = {26, 27},
		dim = {2, 1}
	},
	-- 2x2
	{
		frames = {36, 37, 48, 49},
		-- frames = {48, 49, 36, 37},
		dim = {2, 2}
	},
	{
		frames = {38, 39, 50, 51},
		-- frames = {50, 51, 38, 39},
		dim = {2, 2}
	},
	{
		frames = {60, 61, 72, 73},
		-- frames = {72, 73, 60, 61},
		dim = {2, 2}
	},
	{
		frames = {62, 63, 74, 75},
		-- frames = {74, 75, 62, 63},
		dim = {2, 2}
	},
}

HD_COLLISIONTYPE = {
	AIR_TILE_1 = 1,
	AIR_TILE_2 = 2,
	FLOORTRAP = 3,
	FLOORTRAP_TALL = 4,
	GIANT_FROG = 5,
	GIANT_SPIDER = 6,
	-- GIANT_FISH = 7 -- not needed since it's always manually spawned
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

-- TODO: Revise into HD_ABILITIES:
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
			-- TODO: replace with Imp
				-- Avoid using for agro distance since imps without lavapots immediately agro on the player regardless of distance
				-- TODO: set_timeout() to remove all lavapots from imps in onlevel_remove_mounts()
			-- TODO: if killed immediately, bat_uid still exists.
			-- TODO: abilities can still be killed by the camera flash
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
			-- TODO: Determine if there's better alternatives for whipping and stopping(without spike shoes) immunity
				-- pangxie
		-- uncheck 15 and uncheck 31.
	-- },
	-- BLACKKNIGHT = {
		-- shopkeeperclone_uid = nil,
		-- agro = true -- upon dropping shield, disable shopkeeperclone ability
	-- },
	-- MAMMOTH = {
		-- cobra_uid = nil
			-- dim: {2, 2} -- set the dimensions to the same as the giantfly or else movement and collision will look weird
			-- hitbox: {0.550, 0.705} -- based off pangxie
	-- },
	-- GIANTFROG = {
		-- frog_uid = nil
			-- dim: {2, 2} -- set the dimensions to the same as the giantfly or else movement and collision will look weird
			-- hitbox: { ?, ? }
	-- },
	-- ALIEN_LORD = {
		-- cobra_uid = nil
	-- }
}
-- Currently supported db modifications:
	-- onlevel_dangers_modifications()
		-- Supported Variables:
			-- dim = { w, h }
				-- sets height and width
				-- TODO: Split into two variables: One that gets set in onlevel_dangers_replace(), and one in onlevel_dangers_modifications.
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
		-- TODO:
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
				-- TODO: Split into two variables: One that gets set in onlevel_dangers_replace(), and one in onlevel_dangers_modifications.
					-- IDEA: dim_db and dim
			-- color = { r, g, b }
				-- TODO: Add alpha channel support
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
	removecorpse = true,
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
	removecorpse = true
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
	-- TODO: Tikitrap flames on dark level. If they spawn, move each flame down 0.5.
}
HD_ENT.CRITTER_RAT = {
	dangertype = HD_DANGERTYPE.CRITTER,
	entitydb = ENT_TYPE.MONS_CRITTERDUNGBEETLE,
	max_speed = 0.05,
	acceleration = 0.05
}
HD_ENT.CRITTER_FROG = { -- TODO: behavior for jumping
	tospawn = ENT_TYPE.MONS_CRITTERCRAB,
	toreplace = ENT_TYPE.MONS_CRITTERBUTTERFLY,
	dangertype = HD_DANGERTYPE.CRITTER,
	entitydb = ENT_TYPE.MONS_CRITTERCRAB
	-- TODO: Make jumping script, adjust movement EntityDB properties
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
-- MAMMOTH = { -- TODO: Frozen Immunity
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
	-- stompdamage = false, -- TODO: Add this(?)
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
-- }
-- TODO:
	-- Once at least 1 mask 0x1 is within a 2 block radius(? TOTEST: Investigate in HD.), change skin and set ability_state to agro.
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
	removecorpse = true,
	hitbox = {
		0.64,
		0.8
	},
	flags = {
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
--TODO: Replace with regular frog
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
		-- item = {ENT_TYPE.ITEM_SAPPHIRE}, -- TODO: Determine which gems.
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

-- TODO: For development of the new scripted level gen system, move tables/variables into here from init_onlevel() as needed.
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
	HAUNTEDCASTLE_ENTRANCE_UID = nil
	BLACKMARKET_ENTRANCE_UID = nil
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
-- TODO: Replace these with lists that get applied to specific entities within the level.
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
		
		if (options.hd_og_boulder_phys == true and
			state.theme == THEME.DWELLING and
			(
				state.level == 2 or
				state.level == 3 or
				state.level == 4
			)
		) then		
			boulder_modified = TableCopy(HD_ENT.BOULDER)
			-- boulder_modified.?
			table.insert(global_dangers, boulder_modified)
		else table.insert(global_dangers, HD_ENT.BOULDER) end
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

-- TODO: Use this as a base for embedding items in generate_tile()
-- ha wrote this
function embed(enum, uid)
  local uid_x, uid_y, uid_l = get_position(uid)
  local ents = get_entities_at(0, 0, uid_x, uid_y, uid_l, 0.1)
  if (#ents > 1) then return end

  local entitydb = get_type(enum)
  local previousdraw, previousflags = entitydb.draw_depth, entitydb.default_flags
  entitydb.draw_depth = 9
  entitydb.default_flags = 3278409 -- don't really need some flags for other things that dont explode, example is for jetpack

  local entity = get_entity(spawn_entity_over(enum, uid, 0, 0))
  entitydb.draw_depth = previousdraw
  entitydb.default_flags = previousflags  
  
  message("Spawned " .. tostring(entity.uid))
  return 0;
end
-- Example:
-- register_option_button('button', "Attempt to embed a Jetpack", function()
  -- first_level_entity = get_entities()[1] -- probably a floor
  -- embed(ENT_TYPE.ITEM_JETPACK, first_level_entity)
-- end)

-- TODO: Use this as a base for distributing embedded treasure
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

function locate_cornerpos(roomx, roomy)
	xmin, ymin, _, _ = get_bounds()
	tc_x = (roomx-1)*10+(xmin+0.5)
	tc_y = (ymin-0.5) - ((roomy-1)*(8))
	return tc_x, tc_y
end

function locate_roompos(e_x, e_y)
	xmin, ymin, _, _ = get_bounds()
	-- my brain can't do math, please excuse this embarrassing algorithm
	roomx = math.ceil((e_x-(xmin+0.5))/10)
	roomy = math.ceil(((ymin-0.5)-e_y)/8)
	return roomx, roomy
end

function get_levelsize()
	xmin, ymin, xmax, ymax = get_bounds()
	levelw = math.ceil((xmax-xmin)/10)
	levelh = math.ceil((ymin-ymax)/8)
	return levelw, levelh
end

function get_unlock()
	-- TODO: Boss win unlocks.
		-- Either move the following uncommented code into a dedicated method, or move this method to a place that works for a post-win screen
	-- unlockconditions_win = {}
	-- for unlock_name, unlock_properties in pairs(HD_UNLOCKS) do
		-- if unlock_properties.win ~= nil then
			-- unlockconditions_win[unlock_name] = unlock_properties
		-- end
	-- end
	unlock = nil
	unlockconditions_feeling = {} -- TODO: Maybe move into HD_FEELING as `unlock = true`
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
	
	return unlock
end

function get_unlock_area()
	rand_pool = {"AREA_RAND1","AREA_RAND2","AREA_RAND3","AREA_RAND4"}
	coffin_rand_pool = {}
	rand_index = 1
	n = #rand_pool
	for rand_index = 1, #rand_pool, 1 do
		if HD_UNLOCKS[rand_pool[rand_index]].unlocked == true then
			rand_pool[rand_index] = nil
		end
	end
	rand_pool = CompactList(rand_pool, n)
	rand_index = math.random(1, #rand_pool)
	unlock = rand_pool[rand_index]
	return unlock
end


function create_unlockcoffin(x, y, l)
	coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	-- 193 + unlock_num = ENT_TYPE.CHAR_*
	set_contents(coffin_uid, 193 + HD_UNLOCKS[unlock_name].unlock_id)
	return coffin_uid
end

-- test if gold/gems automatically get placed into scripted tile generation or not
function gen_embedtreasures(uids_toembedin)
	for _, uid_toembedin in ipairs(uids_toembedin) do
		create_embedded(uid_toembedin)
	end
end

function create_embedded(ent_toembedin, entity_type)
	if entity_type ~= ENT_TYPE.EMBED_GOLD and entity_type ~= ENT_TYPE.EMBED_GOLD_BIG then
		local entity_db = get_type(entity_type)
		local previous_draw, previous_flags = entity_db.draw_depth, entity_db.default_flags
		entity_db.draw_depth = 9
		entity_db.default_flags = set_flag(entity_db.default_flags, 1)
		entity_db.default_flags = set_flag(entity_db.default_flags, 4)
		entity_db.default_flags = set_flag(entity_db.default_flags, 10)
		entity_db.default_flags = clr_flag(entity_db.default_flags, 13)
		local entity = get_entity(spawn_entity_over(entity_type, ent_toembedin, 0, 0))
		entity_db.draw_depth = previous_draw
		entity_db.default_flags = previous_flags
	else
		spawn_entity_over(entity_type, ent_toembedin, 0, 0)
	end
end

function create_endingdoor(x, y, l)
	-- TODO: Remove exit door from the editor and spawn it manually here.
	-- Why? Currently the exit door spawns tidepool-specific critters and ambience sounds, which will probably go away once an exit door isn't there initially.
	-- ALTERNATIVE: kill ambient entities and critters. May allow compass to work.
	-- TODO: Test if the compass works for this
	exitdoor = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	set_door_target(exitdoor, 4, 2, THEME.TIAMAT)
	if options.hd_test_unlockbossexits == false then
		lock_door_at(x, y)
	end
end

function create_entrance_hell()
	HELL_X = math.random(4,41)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, HELL_X, 87, LAYER.FRONT, 0, 0)
	set_door_target(door_target, 5, PREFIRSTLEVEL_NUM, THEME.VOLCANA)
	
	if OBTAINED_BOOKOFDEAD == true then
		helldoor_e = get_entity(door_target):as_movable()
		helldoor_e.flags = set_flag(helldoor_e.flags, 20)
		helldoor_e.flags = clr_flag(helldoor_e.flags, 22)
		-- set_timeout(function()
			-- helldoors = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, 0, HELL_X, 87, LAYER.FRONT, 2)
			-- if #helldoors > 0 then
				-- helldoor_e = get_entity(helldoors[1]):as_movable()
				-- helldoor_e.flags = set_flag(helldoor_e.flags, 20)
				-- helldoor_e.flags = clr_flag(helldoor_e.flags, 22)
				-- -- toast("Aaalllright come on in!!! It's WARM WHER YOU'RE GOIN HAHAHAH")
			-- end
		-- end, 5)
	end
end

function create_entrance_mothership(x, y, l)
	spawn_door(x, y, l, 3, 3, THEME.NEO_BABYLON)
end

function create_entrance_blackmarket(x, y, l)
	BLACKMARKET_ENTRANCE_UID = spawn_door(x, y, l, state.world, state.level+1, state.theme)
	-- spawn_entity(ENT_TYPE.LOGICAL_BLACKMARKET_DOOR, x, y, l, 0, 0)
	set_interval(entrance_blackmarket, 1)
end

function create_entrance_hauntedcastle(x, y, l)
	HAUNTEDCASTLE_ENTRANCE_UID = spawn_door(x, y, l, state.world, state.level+1, state.theme)
	set_interval(entrance_hauntedcastle, 1)
end

function create_ghost()
	xmin, _, xmax, _ = get_bounds()
	-- toast("xmin: " .. xmin .. " ymin: " .. ymin .. " xmax: " .. xmax .. " ymax: " .. ymax)
	
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
	sticky.flags = set_flag(sticky.flags, 1)
	sticky.flags = clr_flag(sticky.flags, 3)
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
			ballstem.flags = set_flag(ballstem.flags, 1)
			ballstem.flags = clr_flag(ballstem.flags, 9)
		end
		balltriggers = get_entities_by_type(ENT_TYPE.LOGICAL_SPIKEBALL_TRIGGER)
		for _, balltrigger in ipairs(balltriggers) do kill_entity(balltrigger) end
		
		worm_exit_uid = spawn_door(x, y, l, state.world, state.level+1, THEME.EGGPLANT_WORLD)
		worm_exit = get_entity(worm_exit_uid)
		worm_exit.flags = set_flag(worm_exit.flags, 28) -- pause ai to prevent magnetizing damsels
		lock_door_at(x, y)
		
		
		
		TONGUE_STATE = TONGUE_SEQUENCE.READY
		
		set_timeout(function()
			x, y, l = get_position(TONGUE_UID)
			door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				door_platform.flags = set_flag(door_platform.flags, 1)
				door_platform.flags = clr_flag(door_platform.flags, 3)
				door_platform.flags = clr_flag(door_platform.flags, 8)
			else toast("No Worm Door platform found") end
			-- TODO: Platform seems not to spawn if vine is in the way
		end, 2)
	else
		toast("No STICKYTRAP_BALL found, no tongue generated.")
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
	if hdctype == HD_COLLISIONTYPE.FLOORTRAP and options.hd_z_antitrapcuck == true then
		scan_width = 1 -- check 1 across (1 on each side)
		scan_height = 0 -- check the space above + 1 more
	elseif hdctype == HD_COLLISIONTYPE.FLOORTRAP_TALL and options.hd_z_antitrapcuck == true then
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
			--TODO: test `return conflict` here instead (I know it will work -_- but just to be safe, test it first)
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

function generate_tile(_tilechar, _x, _y, _l)--, replacetile)
	--replacetile = replacetile or nil
		-- Future room replacement methods may lead to have `replacetile` be:
			-- uid
				-- to replace a single tile; all other entities potentially occupying the space will be taken care of in other ways.
			-- bool
				-- Remove everything in the space. Use get_entities_overlapping().

	x = _x
	y = _y
	l = _l
	hd_tiletype, hd_tiletype_post = HD_TILENAME[_tilechar], HD_TILENAME[_tilechar]
	if hd_tiletype == nil then return nil end
	-- chance_half = (math.random() >= 0.5)
	
	-- TODO:
		-- HD_FEELING:
			-- RESTLESS:
				-- Tomb: ENT_TYPE_DECORATION_LARGETOMB
				-- Crown: ITEM_DIAMOND -> custom animation_frame of the gold crown
					-- (worth $5000 in HD, might as well leave it as diamond)

	-- HD_ENT and ENT_TYPE spawning
	if hd_tiletype.entity_types ~= nil then
		entity_type_pool = hd_tiletype.entity_types
		entity_type = 0
		if (
			hd_tiletype.alternate_types ~= nil and
			hd_tiletype.alternate_types[state.theme] ~= nil
		) then
			entity_type_pool = hd_tiletype.alternate_types[state.theme]
		end
		
		if #entity_type_pool == 1 then
			entity_type = entity_type_pool[1]
		elseif #entity_type_pool > 1 then
			entity_type = TableRandomElement(entity_type_pool)
		end
		
		if entity_type == 0 then
			return HD_TILENAME["0"]
		else
			-- TODO: Make specific checks for the result.
			if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = HD_TILENAME["1"]
			elseif (entity_type == ENT_TYPE.LIQUID_WATER or entity_type == ENT_TYPE.LIQUID_LAVA) then hd_tiletype_post = HD_TILENAME["w"]
			-- If it doesn't have a matching HD_TILENAME, return the original one.
			end
		end
		floor_uid = spawn(entity_type, x, y, l, 0, 0)
		
		-- Notes:
			-- It seems that floorstyled spawns with a specific animation_frame.
			-- TODO: Make a system to inspect `postgen_levelcode` and based on its orientation, alter animation_frame for each.
			-- Both floorstyled and floor need an animation frame changer that has the following parameters for each:
			-- floorstyled:
				-- tilepool:
					-- single blocks
						-- lower right bottom tileframe 1
						-- lower right bottom tileframe 2
			-- floor:
				-- tilepool:
					-- single blocks
						-- lower right bottom tileframe 1
						-- lower right bottom tileframe 2
		-- decorate
			-- TODO: Use for placing decorations on floor tiles once placed.
			-- use orientation parameter to adjust what side the decorations need to go on. Take open sides into consideration.
		-- for degrees = 0, 270.0, 90.0 do
			-- offsetcoord = rotate(x, y, x, y+1, degrees)
			-- conflict = (detection_floor(offsetcoord[1], offsetcoord[2], _l, 0, 0) ~= -1)
			-- if conflict == false then
				-- decorate_floor(floor_uid, offsetcoord[1], offsetcoord[2])
			-- end
		-- end
	elseif hd_tiletype_post.hd_type ~= nil then
		danger_spawn(hd_tiletype_post.hd_type, x, y, l, false)
	end
	params = {x, y, l}
	if hd_tiletype_post.spawnfunction ~= nil then hd_tiletype_post.spawnfunction(params) end
	
	return hd_tiletype_post
end

function generate_chunk(c_roomcode, c_dimw, c_dimh, x, y, layer, offsetx, offsety)
	x_ = x + offsetx
	y_ = y + offsety
	i = 1
	for r_yi = 0, c_dimh-1, 1  do
		for r_xi = 0, c_dimw-1, 1 do
			generate_tile(c_roomcode:sub(i, i), x_+r_xi, y_-r_yi, layer)
			i = i + 1
		end
	end
end

function remove_room(roomx, roomy, layer)
	tc_x, tc_y = locate_cornerpos(roomx, roomy)
	for yi = 0, 8-1, 1  do
		for xi = 0, 10-1, 1 do
			local blocks = get_entities_at(0, MASK.FLOOR, tc_x+xi, tc_y-yi, layer, 0.1)
			for _, block in ipairs(blocks) do
				kill_entity(block)
			end
		end
	end
	return tc_x, tc_y
end

function remove_borderfloor()
	for yi = 90, 88, -1 do
		for xi = 3, 42, 1 do
			local blocks = get_entities_at(ENT_TYPE.FLOOR_BORDERTILE, 0, xi, yi, LAYER.FRONT, 0.3)
			kill_entity(blocks[1])
		end
	end
end

function replace_room(c_roomcode, c_dimw, c_dimh, roomx, roomy, layer)
	moved_ghostpot, moved_damsel = nil, nil
	exits = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EXIT)
	if #exits > 0 then
		exit_x, exit_y, _ = get_position(exits[1])
		cx, cy = locate_cornerpos(roomx, roomy)
		checkradius = 0.5
		i = 1
		for yi = 0, c_dimh-1, 1  do
			for xi = 0, c_dimw-1, 1 do
				roomchar = c_roomcode:sub(i, i)
				damsels = get_entities_at(ENT_TYPE.MONS_PET_DOG, 0, cx+xi, cy-yi, layer, checkradius)
				damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_CAT, 0, cx+xi, cy-yi, layer, checkradius))
				damsels = TableConcat(damsels, get_entities_at(ENT_TYPE.MONS_PET_HAMSTER, 0, cx+xi, cy-yi, layer, checkradius))
				ghostpots = get_entities_at(ENT_TYPE.ITEM_CURSEDPOT, 0, cx+xi, cy-yi, layer, checkradius)
				
				if #damsels == 0 and #ghostpots == 0 then
					local blocks = get_entities_at(0, 0, cx+xi, cy-yi, layer, checkradius)
					for _, block in ipairs(blocks) do
						kill_entity(block)
					end
				else
					for _, damsel in ipairs(damsels) do
						-- Move the damsel to the exit?? I sure hope this method doesn't last for longer than a frame O_o
						move_entity(damsel, exit_x, exit_y, 0, 0)
						moved_damsel = damsel
					end
					for _, ghostpot in ipairs(ghostpots) do
						move_entity(ghostpot, exit_x, exit_y, 0, 0)
						moved_ghostpot = ghostpot
					end
				end
				if (
					ghostpot ~= nil and
					roomchar == "0" and
					i+c_dimw < string.len(c_roomcode) and
					c_roomcode:sub(i+c_dimw, i+c_dimw) ~= "0"
				) then
					move_entity(moved_ghostpot, xi, yi, 0, 0)
				elseif (
					moved_damsel ~= nil and
					roomchar == "0" and
					i+c_dimw < string.len(c_roomcode) and
					c_roomcode:sub(i+c_dimw, i+c_dimw) ~= "0"
				) then
					move_entity(moved_damsel, xi, yi, 0, 0)
				else
					generate_tile(roomchar, cx+xi, cy-yi, layer)
				end
				i = i + 1
			end
		end
	else
		toast("AAAAH there's no exit to store important stuff at so we can't replace that room :(")
	end
end

function decorate_tree(e_type, p_uid, side, y_offset, radius, right)
	if p_uid == 0 then return 0 end
	p_x, p_y, p_l = get_position(p_uid)
	branches = get_entities_at(e_type, 0, p_x+side, p_y, p_l, radius)
	branch_uid = 0
	if #branches == 0 then
		branch_uid = spawn_entity_over(e_type, p_uid, side, y_offset)
	else
		branch_uid = branches[1]
	end
	-- flip if you just created it and it's a 0x100 and it's on the left or if it's 0x200 and on the right.
	branch_e = get_entity(branch_uid)
	if branch_e ~= nil then
		-- flipped = test_flag(branch_e.flags, 17)
		if (#branches == 0 and branch_e.type.search_flags == 0x100 and side == -1) then
			flip_entity(branch_uid)
		elseif (branch_e.type.search_flags == 0x200 and right == true) then
			branch_e.flags = set_flag(branch_e.flags, 17)
		end
	end
	return branch_uid
end

function remove_entitytype_inventory(entity_type, inventory_entities)
	items = get_entities_by_type(inventory_entities)
	for r, inventoryitem in ipairs(items) do
		local mount = get_entity(inventoryitem):topmost()
		if mount ~= -1 and mount:as_container().type.id == entity_type then
			move_entity(inventoryitem, -r, 0, 0, 0)
			-- toast("Should be hermitcrab: ".. mount.uid)
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

-- "fake" world/theme/level to let you set quest flags that otherwise wouldn't apply to the first level of a world
function changestate_onlevel_fake_applyquestflags(w, l, t, flags_set, flags_clear)--w_a, l_a, t_a, w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if detect_same_levelstate(t, PREFIRSTLEVEL_NUM, w) == true then--t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
		-- TODO: Consider the consequences of skipping over a level (such as shopkeeper forgiveness)
			-- IDEAS:
				-- if wantedlevel > 0 then wantedlevel = wantedlevel+1
		warp(w, l, t)
	end
end

function changestate_onloading_applyquestflags(w_a, l_a, t_a, flags_set, flags_clear)--w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
	end
end

function entrance_blackmarket()
	ex, ey, _ = get_position(BLACKMARKET_ENTRANCE_UID)
	for i = 1, #players, 1 do
		x, y, _ = get_position(players[i].uid)
		closetodoor = 0.5
		
		if (
			players[i].state == 19 and
			(y+closetodoor >= ey and y-closetodoor <= ey) and
			(x+closetodoor >= ex and x-closetodoor <= ex)
		) then
			feeling_set_once("BLACKMARKET", {state.level+1})
		end
	end
end

function entrance_hauntedcastle()
	ex, ey, _ = get_position(HAUNTEDCASTLE_ENTRANCE_UID)
	for i = 1, #players, 1 do
		x, y, _ = get_position(players[i].uid)
		closetodoor = 0.5
		
		if (
			players[i].state == 19 and
			(y+closetodoor >= ey and y-closetodoor <= ey) and
			(x+closetodoor >= ex and x-closetodoor <= ex)
		) then
			feeling_set_once("HAUNTEDCASTLE", {state.level+1})
		end
	end
end

function exit_olmec()
	for i = 1, #players, 1 do
		x, y, l = get_position(players[i].uid)
		
		if players[i].state == 19 and y > 95 then
			state.win_state = 1
			break
		else
			state.win_state = 0
		end
	end
end

function exit_yama() -- TODO: Merge these methods into one that takes parameters
	for i = 1, #players, 1 do
		x, y, l = get_position(players[i].uid)
		
		if players[i].state == 19 then-- and y > ??? then
			state.win_state = 2
			break
		else
			state.win_state = 0
		end
	end
end

function exit_winstate()
	if state.theme == THEME.OLMEC then
		set_interval(exit_olmec, 1)
	-- elseif state.theme == ??? then
		-- set_interval(exit_yama, 1)
	end
end

function exit_reverse()
	exits = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EXIT)
	entrances = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_ENTRANCE)
	x, y, l = get_position(exits[1])
	exit_mov = get_entity(exits[1]):as_movable()
	nextworld, nextlevel, nexttheme = get_door_target(exit_mov.uid)
	for i,player in ipairs(players) do
		teleport_mount(player, x, y)
	end
	for i,v in ipairs(exits) do
		x, y, l = get_position(v)
		move_entity(v, x+100, y, 0, 0)
		lock_door_at(x, y)
	end
	for i,v in ipairs(entrances) do
		x, y, l = get_position(v)
		door(x, y, l, nextworld, nextlevel, nexttheme)
		unlock_door_at(x, y)
	end
end

function test_tileapplier9000()
	_x, _y, l = 45, 90, LAYER.FRONT -- next to entrance
	testfloors = {}
	width = 3
	height = 4
	toassign = {}
	toassign = {
		uid_offsetpair = {
			-- {uid = testfloors[1], offset = {1, 1}},
		},
		dim = {width, height}
	}
	for yi = 0, -(height-1), -1 do -- 0 -> -3
		for xi = 0, (width-1), 1 do -- 0 -> 2
			-- testfloors[#testfloors+1] = spawn_entity(ENT_TYPE.FLOOR_GENERIC, _x+(xi-1), _y+(yi-1), l, 0, 0)
			table.insert(toassign.uid_offsetpair, {uid = spawn_entity(ENT_TYPE.FLOOR_GENERIC, _x+xi, _y-yi, l, 0, 0), offset = {xi, yi}})
		end
	end
	tileapplier9000(toassign)
	-- testfloor_e = get_entity(testfloors[1])
	-- testfloor_m = testfloor_e:as_movable()
	-- animation_frame = testfloor_m.animation_frame
	-- toast(tostring(_x) .. ", " .. tostring(_y) .. ": " .. tostring(animation_frame))

end

function test_bacterium()
	
	-- Bacterium Creation
		-- FLOOR_THORN_VINE:
			-- flags = clr_flag(flags, 2) -- indestructable (maybe need to clear this? Not sure yet)
			-- flags = clr_flag(flags, 3) -- solid wall
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

function test_levelsize()
	levelw, levelh = get_levelsize()
	toast("levelw: " .. tostring(levelw) .. ", levelh: " .. tostring(levelh))
end

define_tile_code("campfix")
define_tile_code("generation")

-- set_pre_tile_code_callback(function(x, y, layer)
	-- -- generate_chunk("222111", 3, 2, x, y, layer, 0, 0)
	-- if global_levelassembly == nil then
		-- message("PLOOP")
		-- levelcreation_init()
	-- end
	
	-- -- TODO: Here's where you would be using the coordinates to spawn_entity out of global_levelassembly.execution.levelcode
	-- wi, hi = locate_roompos(x, y)
	-- room_hi_len = hi*8
	-- room_wi_len = wi*10
	
	-- for room_hi = room_hi_len-8, room_hi_len, 1 do
		-- for room_wi = room_wi_len-10, room_wi_len, 1 do
			-- if global_levelassembly.modification.levelcode[room_hi][room_wi] == "9" and hi == 1 then -- TODO: Move into generate_tile() and modify to work with MOTHERSHIP
				-- for j = 1, #players, 1 do
					-- move_entity(players[j].uid, x+(room_wi-1), y-(room_hi-1), 0, 0)
				-- end
			-- end
			-- generate_tile(global_levelassembly.modification.levelcode[room_hi][room_wi], x+(room_wi-1), y-(room_hi-1), layer)
		-- end
	-- end
	
	-- return true
-- end, "generation")

set_pre_tile_code_callback(function(x, y, layer)
	tospawn = ENT_TYPE.FLOOR_DOOR_STARTING_EXIT
	if x == 21 then
		if y == 84 then
			tospawn = ENT_TYPE.FLOOR_GENERIC
		else return true end
	end
	spawn(tospawn, x, y, LAYER.FRONT, 0, 0)
	return true
end, "campfix")

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

-- `set_post_tile_code_callback` todos:
	-- probably not needed since you don't use these tilecodes anymore
		-- “fountain_head”/“fountain_drain” if state.theme == THEME.VOLCANA then change the color of the fountain head (In the future, this should be replaced by changing which texture sheet it pulls from *adjusting when needed, for instance, COG)

set_post_tile_code_callback(function(x, y, layer)
	init_posttile_door()
	init_posttile_onstart()
	levelcreation_init()
	
	-- TODO: print to console all of the overlapping entities.
		-- try seeing if players/torches/skulls/pots spawn at this point
	
	
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
	
	-- move door ent test
	
	de_x_offset = 2
	de_y_offset = 3
	
	door_ents_uids = get_entities_at(0, 0, x, y, layer, 1)
	for _, door_ents_uid in ipairs(door_ents_uids) do
		de_x, de_y, _ = get_position(door_ents_uid)
		move_entity(door_ents_uid, de_x+de_x_offset, de_y+de_y_offset, 0, 0)
	end
	
	-- -- print to console
	
	-- message("door_ents_uids => types: ")
	for _, door_ent_uid in ipairs(door_ents_uids) do
		de_type_id = get_type(door_ent_uid).id
		message("   " .. tostring(de_type_id))
	end
	
	-- generate_chunk("111212", 3, 2, x, y, layer, -1, -1)
	-- message("post-door: " .. tostring(state.time_level))
	-- if state.screen == 12 then
	-- end
end, "door")

-- ON.CAMP
set_callback(function()
	oncamp_movetunnelman()
	oncamp_shortcuts()
	
	
	-- signs_back = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_BACK)
	-- signs_front = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_FRONT)
	-- x, y, l = 49, 90, LAYER.FRONT -- next to entrance
	
	-- pre_tile ON.START stuff
	global_feelings = nil
end, ON.CAMP)

set_callback(function()
	unlocks_init()
end, ON.LOGO)

-- ON.START
set_callback(function()
	onstart_init_options()
	onstart_init_methods()
	-- global_feelings = TableCopy(HD_FEELING)
	
	RUN_UNLOCK = nil
end, ON.START)

set_callback(function()
	-- pre_tile ON.START stuff
	global_feelings = nil
	POSTTILE_STARTBOOL = false
end, ON.RESET)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
	onloading_applyquestflags()
end, ON.LOADING)

set_callback(function()
	-- global_levelassembly = nil
end, ON.TRANSITION)

function levelcreation_init()
	
	init_onlevel()
	unlocks_load()
	onlevel_levelrules()
	onlevel_detection_feeling()
	onlevel_setfeelingmessage()
--ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
	onlevel_reverse_exits() -- TODO: Outdate.
--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	-- onlevel_generation_detection()
	onlevel_generation_modification()
	-- onlevel_generation_execution()
	generation_removeborderfloor()
	-- onlevel_replace_powderkegs()
	-- onlevel_generation_pushblocks() -- PLACE AFTER onlevel_generation
end

function levelcreation_setlevelcode_rand(num, wi, hi)
	for feeling, feeling_rooms in ipairs(HD_ROOMOBJECT.FEELINGS) do
		if feeling_check(feeling) == true then
			for roomid, roomcont in ipairs(feeling_rooms) do
				if roomid == num then
					rand_index = math.random(1, #roomcont.roomcodes)
					roomcode = roomcont.roomcodes[rand_index]
					room_hi_len = hi*8
					room_wi_len = wi*10
					i = 1
					for room_hi = room_hi_len-8, room_hi_len, 1 do
						for room_wi = room_wi_len-10, room_wi_len, 1 do
							global_levelassembly.modification.levelcode[room_hi][room_wi] = roomcode:sub(i, i)
							i = i + 1
						end
					end
				end
			end
		end
	end
end

set_callback(function()
	message("ON.LEVEL: " .. tostring(state.time_level))
-- --ONLEVEL_PRIORITY: 1 - Set level constants (ie, init_onlevel(), levelrules)
	init_onlevel()
	-- unlocks_load()
	onlevel_levelrules()
	-- onlevel_detection_feeling()
	onlevel_setfeelingmessage()
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
	onlevel_placement_lockedchest() -- TODO: Revise into onlevel_generation
	onlevel_nocursedpot() -- PLACE AFTER onlevel_placement_lockedchest()
	onlevel_prizewheel()
	onlevel_idoltrap()
	onlevel_remove_mounts()
	-- onlevel_decorate_cookfire()
	onlevel_decorate_trees()
	-- onlevel_blackmarket_ankh()
	onlevel_add_wormtongue()
	onlevel_crysknife()
	onlevel_hide_yama()
	onlevel_acidbubbles()
	onlevel_add_botd()
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
	onguiframe_env_animate_prizewheel()
end, ON.GUIFRAME)



function onstart_init_options()	
	OBTAINED_BOOKOFDEAD = options.hd_test_give_botd
	if options.hd_og_ghost_time == true then GHOST_TIME = 9000 end

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
	
	-- Base Camp -> Jungle 2-1
    -- changestate_onloading_targets(1,1,THEME.BASE_CAMP,2,2,THEME.JUNGLE) -- fake 2-1
	
	-- Dwelling 1-3 -> Dwelling 1-5(Fake 1-4)
    changestate_onloading_targets(1,3,THEME.DWELLING,1,5,THEME.DWELLING)
    -- Dwelling -> Jungle
    changestate_onloading_targets(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)--PREFIRSTLEVEL_NUM,THEME.JUNGLE)
	-- -- Jungle 2-1 -> Jungle 2->2
    -- if state.nexttheme ~= EGGPLANT_WORLD then
		-- changestate_onloading_targets(2,1,THEME.JUNGLE,2,3,THEME.JUNGLE) -- fake 2-2
	-- end
	-- -- Jungle 2-2 -> Jungle 2->3
    -- changestate_onloading_targets(2,2,THEME.JUNGLE,2,4,THEME.JUNGLE) -- fake 2-3
	-- -- Jungle 2-3 -> Jungle 2->4
    -- changestate_onloading_targets(2,3,THEME.JUNGLE,2,5,THEME.JUNGLE) -- fake 2-4
	-- Jungle 2-1 -> Worm 2-2
		-- TODO(? may not need to handle this)
	-- Worm(Jungle) 2-2 -> Jungle 2-4
	changestate_onloading_targets(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
    -- Jungle -> Ice Caves
    changestate_onloading_targets(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)--PREFIRSTLEVEL_NUM,THEME.ICE_CAVES)
    -- Ice Caves -> Ice Caves
		-- TODO: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
    changestate_onloading_targets(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    changestate_onloading_targets(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    changestate_onloading_targets(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
	-- Mothership -> Ice Caves
    changestate_onloading_targets(3,3,THEME.NEO_BABYLON,3,4,THEME.ICE_CAVES)
    -- Ice Caves -> Temple
    changestate_onloading_targets(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)--PREFIRSTLEVEL_NUM,THEME.TEMPLE)
	-- Ice Caves 3-1 -> Worm
		-- TODO(? may not need to handle this)
	-- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	changestate_onloading_targets(3,2,THEME.EGGPLANT_WORLD,3,4,THEME.ICE_CAVES)
    -- Temple -> Olmec
    changestate_onloading_targets(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
    -- COG(4-3) -> Olmec
    changestate_onloading_targets(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	
	-- Hell -> Yama
		-- TODO: Build Yama in Tiamat's chamber.
	-- changestate_onloading_targets(5,3,THEME.VOLCANA,5,4,???)
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
	
	-- Jungle:
	-- 3->4: Clr 18 -- allow rushing water feeling
	changestate_onloading_applyquestflags(2, 3, THEME.JUNGLE, {}, {18})

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
				
				apply_entity_db(s)
			end
		end
	end
end

-- TODO: Replace with a manual enemy spawning system.
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
		-- toast("#hd_types_toreplace: " .. tostring(#hd_types_toreplace))
		-- toast("#affected: " .. tostring(#affected))

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
				-- TODO: Replace dangers.variation with HD_ENT property, including chance.
					-- Frogs can replace mosquitos by having 100% chance. ie, if it was 99%, 1% chance not to spawn.
				-- TODO: Make a table consisting of: [ENT_TYPE] = {uid, uid, etc...}
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
	levelw, levelh = get_levelsize()
	global_levelassembly.modification = {
		path = path_setn(get_levelsize()),
		levelcode = levelcode_setn(levelw, levelh)
	}
	-- TODO: Method to write setrooms into path and levelcode
		-- Run first
	level_init()
	set_run_unlock() -- TODO: Modify/encapsulate with method to write coffin/blackmarket unlock into path and levelcode
	-- TODO: Method to write HD_ROOMOBJECT.GENERIC into path and levelcode
		-- Run after coffin unlocks
		-- Remember to check THEME specific overrides (vault, kali)
		-- Also place idol rooms here
	-- TODO: Method to write into path and levelcode
	for hi = 1, levelh, 1 do
		for wi = 1, levelw, 1 do
			num = global_levelassembly.modification.path[hi][wi]
			if num ~= nil then
				levelcreation_setlevelcode_rand(num, wi, hi)
			end
		end
	end
	-- TODO: Method to bake in subchunk tiles (write into levelcode)
	
	-- TODO: Method to write override_path setrooms into path and levelcode
		-- Run anytime after level_init()
	

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
	
	
	
	-- -- For cases where S2 differs in chunk (aka subchunk) generation:
		-- -- use a unique tilecode in the level editor to signify chunk placement
		-- -- Challenge: Jungle vine chunk.
		
		-- -- JUNGLE - SUBCHUNK - VINE
	-- tmp_object = {
		-- roomcodes = {
			-- "L0L0LL0L0LL000LL0000",
			-- -- L0L0L
			-- -- L0L0L
			-- -- L000L
			-- -- L0000
			
			-- "L0L0LL0L0LL000L0000L",
			-- -- L0L0L
			-- -- L0L0L
			-- -- L000L
			-- -- 0000L
			
			-- "0L0L00L0L00L0L0000L0"
			-- -- 0L0L0
			-- -- 0L0L0
			-- -- 0L0L0
			-- -- 000L0
		-- },
		-- dimensions = { w = 5, h = 4 }
	-- }
	
	-- fill uids_toembedin using global_levelassembly.modification.levelcode
end

function detect_viable_unlock_area()
	-- Where can AREA unlocks spawn?
		-- When it's in one of the four areas.
			-- Any exceptions to this, such as special areas?
				-- I'm going to ignore special cases, such as WORM where you're in another world, or BLACKMARKET. At least for now.
	if (
		state.theme == THEME.DWELLING
		or
		state.theme == THEME.JUNGLE
		or
		state.theme == THEME.ICE_CAVES
		or
		state.theme == THEME.TEMPLE
	) then return true end
	return false
end

function path_setn(levelw, levelh)
	path = {}
	setn(path, levelw)
	
	for wi = 1, levelw, 1 do
		th = {}
		setn(th, levelh)
		path[wi] = th
	end
	return path
end

function levelcode_setn(levelw, levelh)
	levelcodew, levelcodeh = levelw*10, levelh*8 
	levelcode = {}
	setn(levelcode, levelcodew)
	
	for wi = 1, levelcodew, 1 do
		th = {}
		setn(th, levelcodeh)
		levelcode[wi] = th
	end
	return levelcode
end

function set_run_unlock()
	-- BronxTaco:
		-- "rando characters will replace the character inside the level feeling coffin"
		-- "you can see this happen in kinnis old AC wr"
	-- jjg27:
		-- "I don't think randos can appear in the coffins for special areas: Worm, Castle, Mothership, City of Gold, Olmec's Lair."
	if RUN_UNLOCK == nil then
		chance = math.random()
		if (
			detect_viable_unlock_area() == true and
			RUN_UNLOCK_AREA_CHANCE >= chance
		) then
			RUN_UNLOCK = get_unlock_area()
		else
			RUN_UNLOCK = get_unlock()
		end
		
		if RUN_UNLOCK ~= nil then
			message("RUN_UNLOCK: " .. RUN_UNLOCK)
		end
	end
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
		
		-- -- Jungle 2-4 = 2-1 (Dwelling 1-4 -> Jungle 2-1)
	
		-- changestate_onlevel_fake(2,2,THEME.JUNGLE,2,1,THEME.JUNGLE)
		-- changestate_onlevel_fake(2,3,THEME.JUNGLE,2,2,THEME.JUNGLE)
		-- changestate_onlevel_fake(2,4,THEME.JUNGLE,2,3,THEME.JUNGLE)
		-- -- Jungle 2-5 = 2-4 (Jungle 2-3 -> Jungle 2-4)
		-- changestate_onlevel_fake(2,5,THEME.JUNGLE,2,4,THEME.JUNGLE)

	-- Disable dark levels and vaults "before" you enter the world:
		-- Technically load into a total of 4 hell levels; 5-5 and 5-1..3
		-- on.load 5-5, set state.quest_flags 3 and 2, then warp the player to 5-1
		
		-- Jungle 2-0 = 2-1
		-- Disable Moon challenge.
		changestate_onlevel_fake_applyquestflags(2,1,THEME.JUNGLE, {25}, {})
		-- Ice Caves 3-0 = 3-1
		-- Disable Waddler's
		changestate_onlevel_fake_applyquestflags(3,1,THEME.ICE_CAVES, {10}, {})
		-- Temple 4-0 = 4-1
		-- Disable Star challenge.
		changestate_onlevel_fake_applyquestflags(4,1,THEME.TEMPLE, {26}, {})
		-- Volcana 5-5 = 5-1
		-- Disable Moon challenge and drill
			-- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
		changestate_onlevel_fake_applyquestflags(5,1,THEME.VOLCANA, {19, 25}, {})
		
	-- -- Volcana 5-1 -> Volcana 5-2
	-- changestate_onlevel_fake(5,5,THEME.VOLCANA,5,2,THEME.VOLCANA)
	-- -- Volcana 5-2 -> Volcana 5-3
	-- changestate_onlevel_fake(5,6,THEME.VOLCANA,5,3,THEME.VOLCANA)
end

-- Reverse Level Handling
-- For cases where the entrance and exit need to be swapped
-- TODO: See if you can force-swap with `entrance` and `exit` tilecodes placed in door chunks
-- TOTEST: Try it with eggplant world, if that works, apply it to neo-babylon as well
function onlevel_reverse_exits()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_timeout(exit_reverse, 15)
	end
end

function generation_removeborderfloor()
	-- if S2 black market
	-- TODO: Replace with if feeling_check("FLOODED") == true then
	if feeling_check("FLOODED") == true then
		remove_borderfloor()
	end
	-- if Mothership level
	if state.theme == THEME.NEO_BABYLON then
		remove_borderfloor()
	end
end

function onlevel_placement_lockedchest()
	-- Change udjat eye and black market detection to:
	if test_flag(state.quest_flags, 17) == true then -- Udjat eye spawned
		lockedchest_uids = get_entities_by_type(ENT_TYPE.ITEM_LOCKEDCHEST)
		-- udjat_level = (#lockedchest_uids > 0)
		if (
			state.theme == THEME.DWELLING and
			(
				state.level == 2 or
				state.level == 3
				-- or state.level == 4
			-- TODO: Extend availability of udjat chest to level 4.
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
				toast("onlevel_placement_lockedchest(): No Chest. (random_uid could not be set)")
			end
		-- else toast("Couldn't find locked chest.")
		end
	end
end

function onlevel_nocursedpot()
	cursedpot_uids = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
	if #cursedpot_uids > 0 and options.hd_og_nocursepot == true then
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
			local atm_facing = test_flag(atm_mov.flags, 17)
			local atm_x, atm_y, atm_l = get_position(atm_mov.uid)
			local wheel_x_raw = atm_x
			local wheel_y_raw = atm_y+1.5
			
			local facing_dist = 1
			if atm_facing == false then facing_dist = -1 end
			wheel_x_raw = wheel_x_raw + 1 * facing_dist
			
			-- TODO: Replace the function of `wheel_content` to keep track of the location on the board
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
				_item.flags = set_flag(_item.flags, 28)
				_item.angle = -angle
				_item.animation_frame = wheel_content[item_ind]
				_item.width = 0.7
				_item.height = 0.7
			end
		end
		local dice = get_entities_by_type(ENT_TYPE.ITEM_DIE)
		for j, die in ipairs(dice) do
			local die_mov = get_entity(dice[j]):as_movable()
			die_mov.flags = clr_flag(die_mov.flags, 18)
			die_mov.flags = clr_flag(die_mov.flags, 7)
			die_mov.flags = set_flag(die_mov.flags, 1)
			local con = get_entity(dice[j]):as_container()
			con.inside = 3
		end
	end
		
	-- LOCATE DICE
	-- local die1 = get_entity(dice[1]):as_movable()
	-- local die2 = get_entity(dice[2]):as_movable()
	-- toast("uid1 = " .. die1.uid .. ", uid2 = " .. die2.uid)

	-- local con1 = get_entity(dice[1]):as_container()
	-- local con2 = get_entity(dice[2]):as_container()
	-- toast("con1 = " .. tostring(con1.inside) .. ", con2 = " .. tostring(con1.inside))
	-- local atm_mov = get_entity(atms[1]):as_movable()
	-- toast("atm uid: " .. atm_mov.uid)
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
		-- -- toast(tostring(mount.uid))
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
			if test_flag(mov.flags, 23) == false then --and stop_remove == false then
				move_entity(mount, 0, 0, 0, 0)
			end
		end
	end
end

-- TODO: Outdated. Merge into with Scripted Roomcode Generation
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

function onlevel_decorate_trees()
	if state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE then
		-- add branches to tops of trees, add leaf decorations
		treetops = get_entities_by_type(ENT_TYPE.FLOOR_TREE_TOP)
		for _, treetop in ipairs(treetops) do
			branch_uid_left = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, -1, 0, 0.1, false)
			branch_uid_right = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, 1, 0, 0.1, false)
			if feeling_check("RESTLESS") == false then
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
			-- else
				-- TODO: 50% chance of grabbing the FLOOR_TREE_TRUNK below `treetop` and applying a haunted face to it
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
			-- IDEA: Replace Ankh with skeleton key, upon pickup in inventory, give player ankh powerup.
				-- Rename shop string for skeleton key as "Ankh", replace skeleton key with Ankh texture.
			-- TODO: Slightly unrelated, but make a method to remove/replace useless items. Depending on the context, replace it with another item in the pool of even chance.
				-- Skeleton key
				-- Metal Shield
			ankh_mov = get_entity(ankh_uid):as_movable()
			ankh_mov.flags = set_flag(ankh_mov.flags, 23)
			ankh_mov.flags = set_flag(ankh_mov.flags, 20)
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

function onlevel_add_wormtongue()
	-- Worm tongue generation
	-- Placement is currently done with stickytraps placed in the level editor (at least for jungle)
	-- TODO: For all path generation blocks (include side?) (with space of course), add a unique tile to detect inside on.level
	-- On loading the first jungle or ice cave level, find all of the unique entities spawned, select a random one, and spawn the worm tongue.
	-- Then kill all of said unique entities.
	-- ALTERNATIVE: Move into onlevel_generation; find all blocks that have 2 spaces above it free, pick a random one, then spawn the worm tongue.

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
				toast("No worm for you. YEOW!! (random_uid could not be set)")
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

function onlevel_acidbubbles()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_interval(bubbles, 35) -- 15)
	end
end

function onlevel_crysknife()
	if state.theme == THEME.EGGPLANT_WORLD then
		x = 17
		y = 109
		if (math.random() >= 0.5) then
			x = x - 10
		end
		-- TODO: OVERHAUL.
			-- IDEAS:
				-- Replace with actual crysknife and upgrade player damage.
					-- put crysknife animations in the empty space in items.png (animation_frame = 120 - 126 for crysknife) and then animating it behind the player
					-- Can't make player whip invisible, apparently, so that might be hard to do.
				-- Use powerpack
					-- It's the spiritual successor to the crysknife, so its a fitting replacement
					-- I'm planning to make bacterium use FLOOR_THORN_VINE for damage, but now I can even make them break with the powerpack if I also use bush blocks
					-- In my experience in HD, a good way of dispatching bacterium was with bombs, but it was hard to time correctly. So the powerpack would make bombs even more effective
		spawn(ENT_TYPE.ITEM_POWERPACK, x, y, LAYER.FRONT, 0, 0)--ENT_TYPE.ITEM_EXCALIBUR, x, y, LAYER.FRONT, 0, 0)
	end
end

function onlevel_hide_yama()
	if state.theme == THEME.EGGPLANT_WORLD then
		-- TODO: Relocate MONS_YAMA to a better place. Can't move him to back layer, it triggers the slow music :(
		kill_entity(get_entities_by_type(ENT_TYPE.BG_YAMA_BODY)[1])
		for i, yama_floor in ipairs(get_entities_by_type(ENT_TYPE.FLOOR_YAMA_PLATFORM)) do
			kill_entity(yama_floor)
		end
		local yama = get_entity(get_entities_by_type(ENT_TYPE.MONS_YAMA)[1]):as_movable()
		yama.flags = set_flag(yama.flags, 1)
		yama.flags = set_flag(yama.flags, 6)
		yama.flags = set_flag(yama.flags, 28)
		
		-- modified replace() method
		-- affected = get_entities_by_type(ENT_TYPE.MONS_JUMPDOG)
		 -- for i,ent in ipairs(affected) do

		  -- e = get_entity(ent):as_movable()
		  -- floor_uid = e.standing_on_uid
		  -- s = spawn_entity_over(ENT_TYPE.ITEM_EGGSAC, floor_uid, 0, 1)
		  -- se = get_entity(s):as_movable()

		  -- kill_entity(ent)
		 -- end 
	end
end

function onlevel_add_botd()
	-- TODO: Once COG generation is done, change to THEME.CITY_OF_GOLD and figure out coordinates to move it to
	if state.theme == THEME.OLMEC then
		if not options.hd_test_give_botd then
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
		create_endingdoor(41, 99, LAYER.FRONT)
		create_entrance_hell()
	end
	-- Olmec/Yama Win
	exit_winstate()
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
	-- TODO: Once custom hawkman AI is done:
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

-- function onlevel_replace_powderkegs()
	-- if state.theme == THEME.VOLCANA then
		-- TODO: Maybe, in order to save memory, merge this with onlevel_generation
		-- -- replace powderkegs with pushblocks, move_entity(powderkeg, 0, 0, 0, 0)
	-- end
-- end

-- function onlevel_generation_pushblocks()
	-- if state.theme == THEME.OLMEC then
		-- TODO: Pushblock generation. Have a random small chance to replace all FLOORSTYLED_STONE/FLOOR_GENERIC blocks with a ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK.
		-- Exceptions include not having a FLOORSTYLED_STONE/FLOOR_GENERIC block under it and being at the y coordinate of 98.
		-- get_entities_by_type({ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOORSTYLED_STONE})
		-- Probably best to pick a number between 5 and 20, and then choose that amount of random blocks out of the array.
		-- The problem is, there's going to be a lot of visible broken terrain as a result.
	-- end
-- end

function onlevel_detection_feeling()
	if state.theme == THEME.DWELLING then
		encounter = math.random(1,2)
		if encounter == 1 then
			feeling_set_once("SPIDERLAIR", {state.level})
			-- TODO: pots will not spawn on this level.
			-- Spiders, spinner spiders, and webs appear much more frequently.
			-- Spawn web nests (probably RED_LANTERN, remove  and reskin it)
			-- Move pots into the void
		elseif encounter == 2 then
			feeling_set_once("SNAKEPIT", {state.level})
		end
	end
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
		-- TODO: Set BLACKMARKET_ENTRANCE and BLACKMARKET here
	end
	if state.theme == THEME.ICE_CAVES then
		
		-- TODO(?): Really weird and possibly unintentional exception:
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
	if state.theme == THEME.TEMPLE then
		feeling_set_once("SACRIFICIALPIT", {1,2,3})
	end
	-- -- HELL
	-- if state.theme == THEME.VOLCANA and state.level == 1 then
		-- feeling_set("HELL", {state.level})
	-- end
	
	-- GAME ENDUCED RESTLESS
	-- TODO: Find a way to just remove and replace everything given this occurance
	if (
		state.theme == THEME.JUNGLE or
		state.theme == THEME.VOLCANA or
		state.theme == THEME.TEMPLE or
		state.theme == THEME.TIDEPOOL
	) then
		tombstones = get_entities_by_type(ENT_TYPE.DECORATION_TOMB)
		if #tombstones > 0 then
			feeling_set("RESTLESS", {state.level})
		end
	end
end

function onlevel_setfeelingmessage()
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
		options.hd_z_toastfeeling == true
	) then
		toast(MESSAGE_FEELING)
	end
end


function oncamp_movetunnelman()
	marlas = get_entities_by_type(ENT_TYPE.MONS_MARLA_TUNNEL)
	for _, marla_uid in ipairs(marlas) do
		move_entity(marla_uid, 0, 0, 0, 0)
	end
	marla_uid = spawn_entity(ENT_TYPE.MONS_MARLA_TUNNEL, 15, 86, LAYER.FRONT, 0, 0)
	marla = get_entity(marla_uid)
	marla.flags = clr_flag(marla.flags, 17)
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
	shortcut_levels = {PREFIRSTLEVEL_NUM, PREFIRSTLEVEL_NUM, PREFIRSTLEVEL_NUM}
	shortcut_themes = {THEME.JUNGLE, THEME.ICE_CAVES, THEME.TEMPLE}
	-- TODO: Once we are able to change which texture an entity is pulling from, assign bg textures here:
	shortcut_doortextures = {
		TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1,
		TEXTURE.DATA_TEXTURES_FLOOR_ICE_1,
		TEXTURE.DATA_TEXTURES_FLOOR_TEMPLE_1
	}--{569, 343, 409}
	
	
	-- Placement of first shortcut door in HD: 16.0
	new_x = 19.0 -- adjusted for S2 camera
	for i, flagtocheck in ipairs(shortcut_flagstocheck) do
		-- door_or_constructionsign
		if savegame.shortcuts >= flagtocheck then
			spawn_door(new_x, 86, LAYER.FRONT, shortcut_worlds[i], shortcut_levels[i], shortcut_themes[i])
			-- spawn_entity(ENT_TYPE.FLOOR_DOOR_STARTING_EXIT, new_x, 86, 0, 0)
			door_bg = spawn_entity(ENT_TYPE.BG_DOOR, new_x, 86.31, LAYER.FRONT, 0, 0)
			door_texture_id = get_entity(door_bg):get_texture()
			-- door_texture = get_texture_definition(door_texture_id)
			-- door_id = define_texture(door_texture)
			get_entity(door_bg):set_texture(shortcut_doortextures[i])
			get_entity(door_bg).animation_frame = 1
			-- message(tostring("door_animation_frame: " .. tostring(get_entity(door_bg).animation_frame)))
			sign = spawn_entity(ENT_TYPE.ITEM_SHORTCUT_SIGN, new_x+1, 86-0.5, LAYER.FRONT, 0, 0)
			-- get_entity(sign).animation_frame = shortcut_signframes[i]
		else
			spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, new_x, 86, LAYER.FRONT, 0, 0)
		end
		-- Space between shortcut doors in HD: 4.0
		new_x = new_x + 3 -- adjusted for S2 camera
	end	
end

function onframe_prizewheel()
	-- Prize Wheel
	-- Purchase Detection/Handling
	-- TODO: OVERHAUL. Keep the dice poster and rotating that. Use a rock for the needle and use in place of animation_frame = 193
	if #wheel_items > 0 then
	local atm = get_entities_by_type(ENT_TYPE.ITEM_DICE_BET)[1]
	local atm_mov = get_entity(atm):as_movable()
	local atm_facing = test_flag(atm_mov.flags, 17)
	local atm_prompt = test_flag(atm_mov.flags, 20)
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
				atm_mov.flags = set_flag(atm_mov.flags, 20)
				wheel_tick = WHEEL_SPINTIME
				WHEEL_SPINNING = false
			end
		end
		-- TODO: Prize background: animation_frame = 59->deactivate, 60->activate
		-- TODO: Laser Floor: animation_frame = 51->deactivate, 54->activate
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
				-- TODO: Obtain the last owner of the idol upon disturbing it. If no owner caused it, THEN select the first player alive.
				if options.hd_og_boulder_agro == true then
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
			else toast("Boulder crushed :(") end
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
					-- toast("damsel.move_state: " .. tostring(damsel.state))
					stuck_in_web = test_flag(damsel.more_flags, 8)--9)
					-- local falling = (damsel.state == 9)
					dead = test_flag(damsel.flags, 29)
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
					else toast("TONGUE_BG_UID is nil :(") end
					
					-- TODO: Method to animate rubble better.
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
					-- toast("boulder deletion at state.time_level: " .. tostring(state.time_level))
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
			-- local dead = test_flag(damsel.flags, 29)
			if (
				(stuck_in_web == true)
				-- TODO: Don't swallow damsel if dead(? did this happen if the damsel was dead in HD? Investigate.)
				-- (dead == false)
			) then
				damsel.stun_timer = 0
				if options.hd_debug_invis == false then
					damsel.flags = set_flag(damsel.flags, 1)
				end
				damsel.flags = clr_flag(damsel.flags, 21)-- disable interaction with webs
				-- damsel.flags = clr_flag(damsel.flags, 12)-- disable stunable
				damsel.flags = set_flag(damsel.flags, 4)--6)-- enable take no damage
				move_entity(damsel_uid, exit_x, exit_y+0.1, 0, 0)
			end
		end
	else
		toast("No Level Exitdoor found, can't force-rescue damsels.")
	end
	if worm_exit_uid ~= nil then
		worm_exit = get_entity(worm_exit_uid)
		worm_exit.flags = clr_flag(worm_exit.flags, 28) -- resume ai to magnetize damsels
		if #ensnaredplayers > 0 then
			-- unlock worm door, let players in
			unlock_door_at(x, y)
			local door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				if options.hd_debug_invis == true then
					door_platform.flags = clr_flag(door_platform.flags, 1)
				end
				door_platform.flags = set_flag(door_platform.flags, 3)
				door_platform.flags = set_flag(door_platform.flags, 8)
			end
			
			for _, ensnaredplayer_uid in ipairs(ensnaredplayers) do
				ensnaredplayer = get_entity(ensnaredplayer_uid):as_movable()
				ensnaredplayer.stun_timer = 0
				-- ensnaredplayer.more_flags = set_flag(ensnaredplayer.more_flags, 16)-- disable input
				
				if options.hd_debug_invis == false then
					ensnaredplayer.flags = set_flag(ensnaredplayer.flags, 1)-- make each player invisible
				end
					-- disable interactions with anything else that may interfere with entering the door
				ensnaredplayer.flags = clr_flag(ensnaredplayer.flags, 21)-- disable interaction with webs
				ensnaredplayer.flags = set_flag(ensnaredplayer.flags, 4)-- disable interaction with objects
				
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
						if options.hd_debug_invis == true then
							door_platform.flags = set_flag(door_platform.flags, 1)
						end
						door_platform.flags = clr_flag(door_platform.flags, 3)
						door_platform.flags = clr_flag(door_platform.flags, 8)
					end
					worm_exit = get_entity(exits[1])
					worm_exit.flags = set_flag(worm_exit.flags, 28) -- pause ai to prevent magnetizing damsels
					lock_door_at(x, y)
				end
			end, 55)
		end
		
		-- hide worm tongue
		tongue = get_entity(TONGUE_UID)
		if options.hd_debug_invis == false then
			tongue.flags = set_flag(tongue.flags, 1)
		end
		tongue.flags = set_flag(tongue.flags, 4)-- disable interaction with objects
	else
		toast("No Worm Exitdoor found, can't force-exit players.")
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
			
			-- TODO: Move into HD_BEHAVIOR, use frog instead of octopi (Careful to avoid modifying enemydb properties)
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
				-- TODO: Enemy Behavior Ideas
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
							-- toast("#danger.behavior.abilities: " .. tostring(#danger.behavior.abilities))
							-- if danger.behavior.abilities.agro ~= nil then
								if danger.behavior.bat_uid ~= nil then--behavior.abilities.bat_uid ~= nil then
									if danger_mov.health == 1 then
										-- TODO: If SCORPIONFLY is killed, kill all abilities
										-- TODO: Move this into its own method
										-- kill all abilities
										-- for _, behavior_tokill in ipairs(danger.behavior.abilities) do
											-- if #behavior_tokill > 0 and behavior_tokill[1] ~= nil then
												move_entity(danger.behavior.bat_uid, 0, 0, 0, 0)--move_entity(behavior_tokill[1], 0, 0, 0, 0)
												danger.behavior.bat_uid = nil--behavior_tokill[1] = nil
											-- end
										-- end
									else
										-- permanent agro
										-- TODO: SCORPIONFLY -> Adopt S2's Monkey agro distance.
											-- change the if statement below so it's detecting if the BAT is agro'd, not the scorpion.
										-- TODO: Use chased_target instead.
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
					-- toast("YEET: " .. tostring(danger_mov.velocityx))
					danger.behavior.velocity_settimer = nil
				end
			end

			if (
				(
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
				) or
				(
					danger.hd_type.removecorpse ~= nil and
					danger.hd_type.removecorpse == true and
					test_flag(danger_mov.flags, 29) == true
				)
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
	-- TODO: move to method
	-- local j=0
	-- for i=1,n do
		-- if danger_tracker[i]~=nil then
			-- j=j+1
			-- danger_tracker[j]=danger_tracker[i]
		-- end
	-- end
	-- for i=j+1,n do
		-- danger_tracker[i]=nil
	-- end
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
				-- behavior_e.flags = clr_flag(behavior_e.flags, 28)-- enable ai/physics of behavior
				behavior_set_facing(target_uid, master_uid)
				-- bx, by, _ = get_position(target_uid)
				-- move_entity(master_uid, bx, by, 0, 0)
				behavior_set_position(target_uid, master_uid)
			else
				-- behavior_e.flags = set_flag(behavior_e.flags, 28)-- disable ai/physics of behavior
				-- x, y, _ = get_position(master_uid)
				-- move_entity(target_uid, x, y, 0, 0)
				behavior_set_position(master_uid, target_uid)
			end
			for _, other_uid in ipairs(behavior_uids) do
				if other_uid ~= master_uid and other_uid ~= target_uid then
					-- other_e = get_entity(other_uid)
					-- if other_e ~= nil then
						-- other_e.flags = set_flag(other_e.flags, 28)-- disable ai/physics of behavior
					-- end
					behavior_set_position(master_uid, other_uid)
				end
			end
		else
			toast("behavior_toggle(): behavior is nil")
		end
	else
		toast("behavior_toggle(): master is nil")
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
		if test_flag(behavior_flags, 17) then
			master_mov.flags = set_flag(master_mov.flags, 17)
		else
			master_mov.flags = clr_flag(master_mov.flags, 17)
		end
	else
		toast("behavior_set_facing(): master is nil")
	end
end

function behavior_giantfrog(target_uid)
	toast("SPEET!")
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
			-- toast("timer: " .. tostring(ghost.split_timer) .. ", v_mult: " .. tostring(ghost.velocity_multiplier))
			if (options.hd_og_ghost_nosplit == true) then ghost.split_timer = 0 end
		end
		if accounted == 0 then ghosttoset_uid = found_ghost_uid end
	end
	if ghosttoset_uid ~= 0 then
		ghost = get_entity(ghosttoset_uid):as_ghost()
		
		if (options.hd_og_ghost_slow == true) then ghost.velocity_multiplier = GHOST_VELOCITY end
		if (options.hd_og_ghost_nosplit == true) then ghost.split_timer = 0 end
		
		DANGER_GHOST_UIDS[#DANGER_GHOST_UIDS+1] = ghosttoset_uid
	end
end

function onframe_bacterium()
	if state.theme == THEME.EGGPLANT_WORLD then
		
		-- Bacterium Creation
			-- FLOOR_THORN_VINE:
				-- flags = clr_flag(flags, 2) -- indestructable (maybe need to clear this? Not sure yet)
				-- flags = clr_flag(flags, 3) -- solid wall
				-- visible
				-- allow hurting player
				-- allow bombs to destroy them.
			-- ACTIVEFLOOR_BUSHBLOCK:
				-- invisible
				-- flags = clr_flag(flags, 3) -- solid wall
				-- allow taking damage (unless it's already enabled by default)
			-- ITEM_ROCK:
				-- disable ai and physics
					-- re-enable once detached from surface
		
		-- Bacterium Movement Script
		-- TODO: Move to onframe_manage_dangers
		-- Class requirements:
		-- - Destination {float, float}
		-- - Angle int
		-- - Entity uid:
		-- - stun timeout (May be possible to track with the entity)
		-- TODO: Detect whether it is owned by a wall and if the wall exists, and if not, attempt to adopt a wall within all
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
		-- TODO: Get to the point where you can store a single bacterium in an array, get placed on a wall and toast the angle it's chosen to face.
	end
end

function onframe_olmec_cutscene() -- TODO: Move to set_interval() that you can close later
	c_logics = get_entities_by_type(ENT_TYPE.LOGICAL_CINEMATIC_ANCHOR)
	if #c_logics > 0 then
		c_logics_e = get_entity(c_logics[1]):as_movable()
		dead = test_flag(c_logics_e.flags, 29)
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
			-- TODO: Currently the spelunker can be crushed on the ceiling.
			-- This is due to HD's olmec having a much shorter jump and shorter hop curve and distance.
			-- Decide whether or not we restore this behavior or if we raise the ceiling generation.
		-- OLMEC_SEQUENCE = { ["STILL"] = 1, ["FALL"] = 2 }
		-- Enemy Spawning: Detect when olmec is about to smash down
		if olmec.velocityy > -0.400 and olmec.velocityx == 0 and OLMEC_STATE == OLMEC_SEQUENCE.FALL then
			OLMEC_STATE = OLMEC_SEQUENCE.STILL
			x, y, l = get_position(OLMEC_ID)
			-- random chance (maybe 20%?) each time olmec groundpounds, shoots 3 out in random directions upwards.
			-- if math.random() >= 0.5 then
				-- TODO: Currently runs twice. Find a fix.
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
				-- TODO: Ask the discord if it's actually possible to check if a variable exists even if it's set to nil
				-- The solution is probably assigning ability parameters by setting the variable to -1
					-- (which I CAN do in this situation considering it's a uid field)
				-- ACTUALLYYYYYYYYYYYY The solution is probably using string indexes(I'm probably butchuring the terminology)
					-- For instance; "for string, value in pairs(decorated_behavior.abilities) do if string == "bat_uid" then toast("BAT!!") end end"
				
				-- if behavior.abilities.agro.bat_uid ~= nil then
					
					decorated_behavior.bat_uid = spawn(ENT_TYPE.MONS_IMP, x, y, l, 0, 0)--decorated_behavior.abilities.agro.bat_uid = spawn(ENT_TYPE.MONS_BAT, x, y, l, 0, 0)
					applyflags_to_uid(decorated_behavior.bat_uid, {{ 1, 6, 25 }})
				
				-- end
				-- if behavior.abilities.idle.mosquito_uid ~= nil then
					
					-- decorated_behavior.abilities.idle.mosquito_uid = spawn(ENT_TYPE.MONS_MOSQUITO, x, y, l, 0, 0)
					-- ability_e = get_entity(decorated_behavior.abilities.idle.mosquito_uid)
					-- if options.hd_debug_invis == false then
						-- ability_e.flags = set_flag(ability_e.flags, 1)
					-- end
					-- ability_e.flags = set_flag(ability_e.flags, 6)
					-- ability_e.flags = set_flag(ability_e.flags, 25)
					
				-- end
				
					-- toast("#decorated_behavior.abilities: " .. tostring(#decorated_behavior.abilities))
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
		-- TODO: Modify to accommodate the following enemies:
			-- The Mines:
				-- Miniboss enemy: Giant spider
				-- If there's a wall to the right, don't spawn. (maybe 2 walls down, too?)
			-- The Jungle:
				-- Miniboss enemy: Giant frog
				-- If there's a wall to the right, don't spawn. (For the future when we don't replace mosquitos (or any enemy at all), try to spawn on 2-block surfaces.
		-- TODO: Move conflict detection into its own category.
		-- TODO: Add an HD_ENT property that takes an enum to set collision detection.
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
	-- TODO: Move flags into a table of pairs(flagnumber, bool)
	if hd_type.flags ~= nil then
		applyflags_to_uid(uid, hd_type.flags)
	end
	
	-- if hd_type.flag_stunnable ~= nil then
		-- if hd_type.flag_stunnable == true then
			-- s_mov.flags = set_flag(s_mov.flags, 12)
		-- else
			-- s_mov.flags = clr_flag(s_mov.flags, 12)
		-- end
	-- end
	
	-- if hd_type.flag_collideswalls ~= nil then
		-- if hd_type.flag_collideswalls == true then
			-- s_mov.flags = set_flag(s_mov.flags, 13)
		-- else
			-- s_mov.flags = clr_flag(s_mov.flags, 13)
		-- end
	-- end
	
	-- if hd_type.flag_nogravity ~= nil then
		-- if hd_type.flag_nogravity == true then
			-- s_mov.flags = set_flag(s_mov.flags, 4)
		-- else
			-- s_mov.flags = clr_flag(s_mov.flags, 4)
		-- end
	-- end
	
	-- if hd_type.flag_passes_through_objects ~= nil then
		-- if hd_type.flag_passes_through_objects == true then
			-- s_mov.flags = set_flag(s_mov.flags, 10)
		-- else
			-- s_mov.flags = clr_flag(s_mov.flags, 10)
		-- end
	-- end
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
	else toast("No level flags") end
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
	else toast("No quest flags") end
end

function applyflags_to_uid(uid_assignto, flags)
	if #flags > 0 then
		ability_e = get_entity(uid_assignto)
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			if (
				flag ~= 1 or
				(flag == 1 and options.hd_debug_invis == false)
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
	else toast("No flags") end
end

function onframe_boss_wincheck()
	if BOSS_STATE == BOSS_SEQUENCE.FIGHT then
		olmec = get_entity(OLMEC_ID):as_olmec()
		if olmec ~= nil then
			if olmec.attack_phase == 3 then
				-- TODO: play cool win jingle
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

function onguiframe_ui_info_path()
	if options.hd_debug_info_path == true and (state.pause == 0 and state.screen == 12 and #players > 0) and global_levelassembly ~= nil then
		text_x = -0.95
		text_y = -0.35
		white = rgba(255, 255, 255, 255)
		
		levelw, levelh = get_levelsize()--#global_levelassembly.execution.path, #global_levelassembly.execution.path[1]--get_levelsize()
		text_y_space = text_y
		for hi = 1, levelh, 1 do -- hi :)
			text_x_space = text_x
			for wi = 1, levelw, 1 do
				text_subchunkid = tostring(global_levelassembly.modification.path[wi][hi])
				if text_subchunkid == nil then text_subchunkid = "nil" end
				draw_text(text_x_space, text_y_space, 0, text_subchunkid, white)
				
				text_x_space = text_x_space+0.04
			end
			text_y_space = text_y_space-0.04
		end
	end
end

-- Prize Wheel
-- TODO: Once using diceposter texture, remove this.
function onguiframe_env_animate_prizewheel()
	if (state.pause == 0 and state.screen == 12 and #players > 0) then
		local atms = get_entities_by_type(ENT_TYPE.ITEM_DICE_BET)
		if #atms > 0 then
			for i, atm in ipairs(atms) do
				local atm_mov = get_entity(atms[i]):as_movable()
				local atm_facing = test_flag(atm_mov.flags, 17)
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


-- TODO: Turn into a custom inventory system that works for all players.
function inventory_checkpickup_botd()
	if OBTAINED_BOOKOFDEAD == false then
		for i = 1, #players, 1 do
			if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) then
				-- TODO: Move into the method that spawns Anubis II in COG
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
	
function tileapplier9000(_tilegroup)
	uid_offsetpair = _tilegroup.uid_offsetpair
	dim = _tilegroup.dim
		-- width = 3
		-- height = 4
	for yi = 0, -(dim[2]-1), -1 do -- 0 -> -3
		for xi = 0, (dim[1]-1), 1 do -- 0 -> 2
			dim_viable = {(dim[1]-xi), (dim[2]+yi)} -- 3, 4 -> 1, 1
			for _, offsetpair in ipairs(uid_offsetpair) do
				-- Will have no uid if already applied.
				if offsetpair.uid == nil and offsetpair.offset ~= nil then
					dim_viable = tileapplier_get_viabledim(dim, xi, yi, offsetpair.offset)
				end
			end
			-- if floor available, apply random animation_frame to uids
			if dim_viable[1] > 0 and dim_viable[2] > 0 then
				-- find applicable uids with the given dimensions
				origin = { xi, yi }
				tileapplier_apply_randomframe(_tilegroup, origin, dim_viable)
			end
		end
	end
end

-- return uids (debug purposes)
function tileapplier_apply_randomframe(_tilegroup, origin, dim_viable)
	uids = {}
	setup_apply = tileapplier_get_randomwithin(dim_viable)
	dim = setup_apply.dim--_tilegroup.dim
	-- if origin[1] == 2 then
		-- toast(tostring(origin[1]) .. ", " .. tostring(origin[2]))-- .. ": " .. tostring(setup_apply.frames[1]))
	-- end
	uid_offsetpair = _tilegroup.uid_offsetpair
	frames_i = 1 -- ah yes, frames_i, the ugly older brother of iframes
	for yi = origin[2], dim[2]-1, 1 do -- start at origin[2], end at dim[2]
		for xi = origin[1], dim[1]-1, 1 do
			for _, offsetpair in ipairs(uid_offsetpair) do
				if offsetpair.uid ~= nil and offsetpair.offset ~= nil then
					if offsetpair.offset[1] == xi and offsetpair.offset[2] == yi then
						floor_e = get_entity(offsetpair.uid)
						floor_m = floor_e:as_movable()
						frame = setup_apply.frames[frames_i]
						-- toast(tostring(xi) .. ", " .. tostring(yi) .. ": " .. tostring(frame))
						floor_m.animation_frame = frame
						-- apply to uids, then assign offset in dim
						table.insert(uids, offsetpair.uid)
						offsetpair.uid = nil
					end
				end
			end
			frames_i = frames_i + 1
		end
	end
	return uids
end

function tileapplier_get_viabledim(dim, xi, yi, offset)
	dim_viable = {(dim[1]-xi), (dim[2]+yi)}--{1+(dim[1]-xi), 1+(dim[2]-yi)}
	x_larger = offset[1] > xi
	x_equals = offset[1] == xi
	y_larger = offset[2] > yi
	y_equals = offset[2] == yi
	both_equals = x_equals and y_equals
	both_larger = x_larger and y_larger
	if (x_equals or x_larger) and (y_equals or y_larger) then
		if x_larger and y_equals then -- subtract from viable dimension
			dim_viable[1] = dim_viable[1] - 1
		elseif both_equals then
			dim_viable[1] = dim_viable[1] - 2
		end
		if y_larger and x_equals then -- subtract from viable dimension
			dim_viable[2] = dim_viable[2] - 1
		elseif both_equals then
			dim_viable[2] = dim_viable[2] - 2
		end
	end
	return dim_viable
end

-- Compact tileframes_floor into a local table of matching dimensions
function tileapplier_get_randomwithin(_dim)
	tileframes_floor_matching = TableCopy(TILEFRAMES_FLOOR)
	n = #tileframes_floor_matching
	for i, setup in ipairs(tileframes_floor_matching) do
		if (
			(setup.dim ~= nil and #setup.dim == 2) and
			(setup.dim[1] > _dim[1] or setup.dim[2] > _dim[2])
		) then tileframes_floor_matching[i] = nil end
	end
	tileframes_floor_matching = CompactList(tileframes_floor_matching, n)
	-- toast("#tileframes_floor_matching: " .. tostring(#tileframes_floor_matching))
	-- toast("_dim[1]: " .. tostring(_dim[1]).. ", _dim[2]: " .. tostring(_dim[2]))
	return TableRandomElement(tileframes_floor_matching)
end

-- TODO: Move HD_UNLOCKS to its own module
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
end

function level_init()
	-- level_loadpath()
	if state.theme ~= THEME.OLMEC and state.theme ~= THEME.TIAMAT then
		level_createpath(false, (state.theme == THEME.NEOBABYLON))
	end
end


-- TODO:

-- the right side is blocked if:
function detect_sideblocked_right(path, wi, hi, levelw, levelh)
	if (
		-- the space to the right goes off of the path
		wi+1 > levelw
		or
		-- the space to the right has already been filled with a number
		path[hi][wi+1] ~= nil
	) then
		return true
	else
		return false
	end
end

-- the left side is blocked if:
function detect_sideblocked_left(path, wi, hi, levelw, levelh)
	if (
		-- the space to the left goes off of the path
		wi-1 < 1
		or
		-- the space to the left has already been filled with a number
		path[hi][wi-1] ~= nil
	) then
		return true
	else
		return false
	end
end

-- the under side is blocked if:
function detect_sideblocked_under(path, wi, hi, levelw, levelh)
	if (
		-- the space under goes off of the path
		hi+1 > levelh
		or
		-- the space under has already been filled with a number
		path[hi+1][wi] ~= nil
	) then
		return true
	else
		return false
	end
end

-- both sides blocked off
function detect_sideblocked_both(path, wi, hi, levelw, levelh)
	return (
		detect_sideblocked_left(path, wi, hi, levelw, levelh) and 
		detect_sideblocked_right(path, wi, hi, levelw, levelh)
	)
end

-- Parameters
	-- spread
		-- forces the level to zig-zag from one side of the level to the other, only dropping upon reaching each side
	-- Reverse path
		-- only thing you need to do is swap s2 exit/entrance codes:
			-- 5,6 = 7,8
			-- 7,8 = 5,6
		-- used for mothership level
function level_createpath(spread, reverse_path)
	levelw, levelh = get_levelsize()
	message("levelw, levelh: " .. tostring(levelw) .. ", " .. tostring(levelh))
	-- chose an open space to start winding downwards from
	rand_startindexes = {}
	for wi = 1, levelw, 1 do
		if global_levelassembly.modification.path[1][wi] == nil then
			rand_startindexes[#rand_startindexes+1] = wi
		end
	end	
	
	assigned_exit = false
	assigned_entrance = false
	wi, hi = rand_startindexes[math.random(1, #rand_startindexes)], 1
	dropping = false
	while assigned_exit == false do
		num = math.random(2)
		ind_off_x, ind_off_y = 0, 0
		if (num == 2 and detect_sideblocked_under(global_levelassembly.modification.path, wi, hi, levelw, levelh)) or spread == true then
			num = 1
		end
		if num == 1 then
			if detect_sideblocked_both(global_levelassembly.modification.path, wi, hi, levelw, levelh) then
				num = 2
			else
				dir = 1
				if detect_sideblocked_right(global_levelassembly.modification.path, wi, hi, levelw, levelh) then
					dir = -1
				else
					if (math.random(2) == 2) then
						dir = 1
					else
						dir = -1
					end
				end
				ind_off_x = dir
			end
		end
		
		if num == 1 and dropping == true then
			num = 3
			dropping = false
		end
		if num == 2 then
			ind_off_y = 1
			if dropping == true then
				num = 4
			end
			dropping = true
		end
		if assigned_entrance == false then
			if num == 2 then
				num = 6
				if reverse_path == true then
					num = 8
				end
			else
				num = 5
				if reverse_path == true then
					num = 7
				end
			end
			assigned_entrance = true
		elseif hi == levelh then
			if detect_sideblocked_both(global_levelassembly.modification.path, wi, hi, levelw, levelh) then
				assigned_exit = true
			else
				assigned_exit = (math.random(2) == 2)
			end
			if assigned_exit == true then
				if num == 3 then
					num = 8
					if reverse_path == true then
						num = 6
					end
				else
					num = 7
					if reverse_path == true then
						num = 5
					end
				end
			end
		end
		global_levelassembly.modification.path[wi][hi] = tostring(num)
		-- TODO: Chose roomcode based on `num`, THEME, and FEELING, and apply to global_levelassembly.modification.levelcode
		if assigned_exit == false then -- preserve final coordinates for bugtesting purposes
			wi, hi = wi+ind_off_x, hi+ind_off_y
		end
	end
end

function level_loadpath()
	levelw, levelh = get_levelsize()
	LEVEL_PATH = path_setn(levelw, levelh)
	for hi = 1, levelh, 1 do
		for wi = 1, levelw, 1 do
			x, y = locate_cornerpos(wi, hi)
			edge = 0--.5
			ROOM_SX = x+edge
			ROOM_SY = y-7+edge
			ROOM_SX2 = x+9-edge
			ROOM_SY2 = y-edge
			id = "0"
			terms = {}
			terms_toavoid = {}
			for term_name, term_properties in pairs(HD_SUBCHUNKID_TERM) do
				entity_type = term_properties.entity_type
				uids = get_entities_overlapping(
					entity_type,
					0,
					ROOM_SX,
					ROOM_SY,
					ROOM_SX2,
					ROOM_SY2,
					LAYER.FRONT
				)
				if #uids > 0 then
					terms[term_name] = entity_type
					if term_properties.kill ~= nil and options.hd_debug_invis == false then
						for _, uid in ipairs(uids) do
							kill_entity(uid)
						end
					end
				else
					terms_toavoid[term_name] = entity_type
				end
			end
			if TableLength(terms) > 0 then
				-- loop over terms to avoid. if it contains those, abort.
				
				subchunkids_tonarrow = TableCopy(HD_SUBCHUNKID)
				for subchunk_id, types in pairs(subchunkids_tonarrow) do
					
					contains_terms_all = false
					tnum = 0
					for term_name, entity_type in pairs(terms) do
						for i = 1, #types, 1 do
							if entity_type == types[i].entity_type then
								tnum = tnum + 1
							end
						end
					end
					if tnum == TableLength(terms) then contains_terms_all = true end
					
					contains_terms_toavoid = false
					for term_name, term_enttype in pairs(terms_toavoid) do
						for i = 1, #types, 1 do
							if term_enttype == types[i].entity_type then
								contains_terms_toavoid = true
							end
						end
					end
					
					if (
						subchunk_id == "0" or
						contains_terms_all == false or
						contains_terms_toavoid == true
					) then
						subchunkids_tonarrow[subchunk_id] = nil
					end
				end
				
				if TableLength(subchunkids_tonarrow) == 1 then id = TableFirstKey(subchunkids_tonarrow) end
			end
			
			LEVEL_PATH[wi][hi] = id
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


-- TODO: Implement system that reviews savedata to unlock coffins.
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
-- coffin_e.flags = set_flag(coffin_e.flags, 10)
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


-- Animation = {
  -- __name = "sol.Animation.user"
-- }
-- Arrowtrap = {
  -- __index = "function: 0000023A40DA7260",
  -- __name = "sol.Arrowtrap.user",
  -- __newindex = "function: 0000023A40DA4BE0"
-- }
-- BUTTON = {
  -- BOMB = 4,
  -- DOOR = 32,
  -- JUMP = 1,
  -- ROPE = 8,
  -- RUN = 16,
  -- WHIP = 2
-- }
-- Bomb = {
  -- __index = "function: 0000023A1590BE50",
  -- __name = "sol.Bomb.user",
  -- __newindex = "function: 0000023A1590A2D0"
-- }
-- CONST = {
  -- ENGINE_FPS = 60
-- }
-- COSUBTHEME = {
  -- DWELLING = 0,
  -- ICECAVES = 5,
  -- JUNGLE = 1,
  -- NEOBABYLON = 6,
  -- RESET = -1,
  -- SUNKENCITY = 7,
  -- TEMPLE = 4,
  -- TIDEPOOL = 3,
  -- VOLCANA = 2
-- }
-- Cape = {
  -- __index = "function: 0000023A40DA84F0",
  -- __name = "sol.Cape.user",
  -- __newindex = "function: 0000023A40DA8700"
-- }
-- ChasingMonster = {
  -- __index = "function: 0000023A1590AE80",
  -- __name = "sol.ChasingMonster.user",
  -- __newindex = "function: 0000023A1590C740"
-- }
-- Color = {
  -- __name = "sol.Color.user"
-- }
-- Container = {
  -- __index = "function: 0000023A40DA3ED0",
  -- __name = "sol.Container.user",
  -- __newindex = "function: 0000023A40DA21F0"
-- }
-- Crushtrap = {
  -- __index = "function: 0000023A40DA6B80",
  -- __name = "sol.Crushtrap.user",
  -- __newindex = "function: 0000023A40DA49D0"
-- }
-- CustomSound = {
  -- __name = "sol.CustomSound.user"
-- }
-- DROP = {
  -- ALTAR_DICE_CLIMBINGGLOVES = 0,
  -- ALTAR_DICE_COOKEDTURKEY = 1,
  -- ALTAR_DICE_DIAMOND = 2,
  -- ALTAR_DICE_MACHETE = 3,
  -- ALTAR_DICE_ROPEPILE = 4,
  -- ALTAR_DICE_SPECTACLES = 5,
  -- ALTAR_DICE_TELEPACK = 6,
  -- ALTAR_DICE_VAMPIRE = 7,
  -- ALTAR_DICE_WEBGUN = 8,
  -- ALTAR_IDOL_GOLDEN_MONKEY = 9,
  -- ALTAR_KAPALA = 10,
  -- ALTAR_PRESENT_EGGPLANT = 11,
  -- ALTAR_ROCK_WOODENARROW = 12,
  -- ALTAR_ROYAL_JELLY = 13,
  -- ALTAR_USHABTI_CAVEMAN = 14,
  -- ALTAR_USHABTI_TURKEY = 15,
  -- ALTAR_USHABTI_VAMPIRE = 16,
  -- ANUBIS2_JETPACK = 17,
  -- ANUBIS_SCEPTER = 18,
  -- BEG_BOMBBAG = 19,
  -- BEG_TRUECROWN = 20,
  -- BONEPILE_SKELETONKEY = 21,
  -- BONEPILE_SKULL = 22,
  -- CROCMAN_TELEPACK = 23,
  -- CROCMAN_TELEPORTER = 24,
  -- GHOSTJAR_DIAMOND = 25,
  -- GHOST_DIAMOND = 26,
  -- GIANTSPIDER_PASTE = 27,
  -- GOLDENMONKEY_NUGGET = 28,
  -- GOLDENMONKEY_SMALLEMERALD = 29,
  -- GOLDENMONKEY_SMALLNUGGET = 30,
  -- GOLDENMONKEY_SMALLRUBY = 31,
  -- GOLDENMONKEY_SMALLSAPPHIRE = 32,
  -- GOLDENPARACHUTE_SMALLNUGGET = 33,
  -- HANGINGSPIDER_WEBGUN = 34,
  -- ICECAVE_BOULDER = 35,
  -- JIANGSHIASSASSIN_SPIKESHOES = 36,
  -- JIANGSHI_SPRINGSHOES = 37,
  -- KINGU_TABLETOFDESTINY = 38,
  -- LEPRECHAUN_CLOVER = 39,
  -- MATTOCK_BROKENMATTOCK = 40,
  -- MOLE_MATTOCK = 41,
  -- MOSQUITO_HOVERPACK = 42,
  -- MUMMY_DIAMOND = 43,
  -- MUMMY_FLY = 44,
  -- NECROMANCER_RUBY = 45,
  -- OLMEC_BOMB = 46,
  -- OLMEC_CAVEMEN = 47,
  -- OLMEC_UFO = 48,
  -- OSIRIS_EMERALDS = 49,
  -- OSIRIS_TABLETOFDESTINY = 50,
  -- PANGXIE_ACIDBUBBLE = 51,
  -- QUEENBEE_ROYALJELLY = 52,
  -- ROBOT_METALSHIELD = 53,
  -- SCEPTER_ANUBISSPECIALSHOT = 54,
  -- SCEPTER_PLAYERSHOT = 55,
  -- SHOPKEEPER_GOLDCOIN = 56,
  -- SKELETON_SKELETONKEY = 57,
  -- SORCERESS_RUBY = 58,
  -- SPARROW_ROPEPILE = 59,
  -- SPARROW_SKELETONKEY = 60,
  -- TIAMAT_BAT = 61,
  -- TIAMAT_BEE = 62,
  -- TIAMAT_CAVEMAN = 63,
  -- TIAMAT_COBRA = 64,
  -- TIAMAT_HERMITCRAB = 65,
  -- TIAMAT_MONKEY = 66,
  -- TIAMAT_MOSQUITO = 67,
  -- TIAMAT_OCTOPUS = 68,
  -- TIAMAT_OLMITE = 69,
  -- TIAMAT_SCORPION = 70,
  -- TIAMAT_SHOT = 71,
  -- TIAMAT_SNAKE = 72,
  -- TIAMAT_UFO = 73,
  -- TIAMAT_YETI = 74,
  -- TORCH_SMALLNUGGET = 75,
  -- TURKEY_COOKEDTURKEY = 76,
  -- UFO_PARACHUTE = 77,
  -- VAMPIRE_CAPE = 78,
  -- VAN_HORSING_COMPASS = 79,
  -- VAN_HORSING_DIAMOND = 80,
  -- VLAD_VLADSCAPE = 81,
  -- YETIKING_FREEZERAY = 82,
  -- YETIKING_ICESPIRE = 83,
  -- YETIQUEEN_POWERPACK = 84,
  -- YETI_PITCHERSMITT = 85
-- }
-- DROPCHANCE = {
  -- BONEBLOCK_SKELETONKEY = 0,
  -- CROCMAN_TELEPACK = 1,
  -- HANGINGSPIDER_WEBGUN = 2,
  -- JIANGSHIASSASSIN_SPIKESHOES = 3,
  -- JIANGSHI_SPRINGSHOES = 4,
  -- MOLE_MATTOCK = 5,
  -- MOSQUITO_HOVERPACK = 6,
  -- ROBOT_METALSHIELD = 7,
  -- SKELETON_SKELETONKEY = 8,
  -- UFO_PARACHUTE = 9,
  -- YETI_PITCHERSMITT = 10
-- }
-- ENT_TYPE = {
  -- ACTIVEFLOOR_BONEBLOCK = 599,
  -- ACTIVEFLOOR_BOULDER = 597,
  -- ACTIVEFLOOR_BUBBLE_PLATFORM = 620,
  -- ACTIVEFLOOR_BUSHBLOCK = 600,
  -- ACTIVEFLOOR_CHAINEDPUSHBLOCK = 602,
  -- ACTIVEFLOOR_CHAINED_SPIKEBALL = 606,
  -- ACTIVEFLOOR_CRUSHING_ELEVATOR = 621,
  -- ACTIVEFLOOR_CRUSH_TRAP = 609,
  -- ACTIVEFLOOR_CRUSH_TRAP_LARGE = 610,
  -- ACTIVEFLOOR_DRILL = 608,
  -- ACTIVEFLOOR_EGGSHIPBLOCKER = 595,
  -- ACTIVEFLOOR_EGGSHIPPLATFORM = 594,
  -- ACTIVEFLOOR_ELEVATOR = 615,
  -- ACTIVEFLOOR_FALLING_PLATFORM = 605,
  -- ACTIVEFLOOR_GIANTCLAM_BASE = 616,
  -- ACTIVEFLOOR_KINGU_PLATFORM = 617,
  -- ACTIVEFLOOR_LIGHTARROWPLATFORM = 604,
  -- ACTIVEFLOOR_METALARROWPLATFORM = 603,
  -- ACTIVEFLOOR_OLMEC = 611,
  -- ACTIVEFLOOR_POWDERKEG = 601,
  -- ACTIVEFLOOR_PUSHBLOCK = 598,
  -- ACTIVEFLOOR_REGENERATINGBLOCK = 623,
  -- ACTIVEFLOOR_SHIELD = 622,
  -- ACTIVEFLOOR_SLIDINGWALL = 613,
  -- ACTIVEFLOOR_THINICE = 614,
  -- ACTIVEFLOOR_TIAMAT_PLATFORM = 618,
  -- ACTIVEFLOOR_TIAMAT_SHOULDERPLATFORM = 619,
  -- ACTIVEFLOOR_TIMEDPOWDERKEG = 612,
  -- ACTIVEFLOOR_UNCHAINED_SPIKEBALL = 607,
  -- ACTIVEFLOOR_WOODENLOG_TRAP = 596,
  -- BG_ANUBIS_THRONE = 817,
  -- BG_BASECAMP_BUNKBED = 797,
  -- BG_BASECAMP_DININGTABLE_DISHES = 799,
  -- BG_BASECAMP_DRESSER = 796,
  -- BG_BASECAMP_SHORTCUTSTATIONBANNER = 800,
  -- BG_BASECAMP_SIDETABLE = 798,
  -- BG_BOULDER_STATUE = 826,
  -- BG_CONSTELLATION_CONNECTION = 774,
  -- BG_CONSTELLATION_FLASH = 770,
  -- BG_CONSTELLATION_GLOW = 773,
  -- BG_CONSTELLATION_HALO = 772,
  -- BG_CONSTELLATION_STAR = 771,
  -- BG_COSMIC_FARFLOATINGDEBRIS = 838,
  -- BG_COSMIC_FLOATINGDEBRIS = 837,
  -- BG_CROWN_STATUE = 816,
  -- BG_DOOR = 784,
  -- BG_DOORGEM = 795,
  -- BG_DOOR_BACK_LAYER = 786,
  -- BG_DOOR_BLACK_MARKET = 788,
  -- BG_DOOR_COG = 789,
  -- BG_DOOR_EGGPLANT_WORLD = 791,
  -- BG_DOOR_FRONT_LAYER = 785,
  -- BG_DOOR_GHIST_SHOP = 787,
  -- BG_DOOR_LARGE = 783,
  -- BG_DOOR_OLMEC_SHIP = 790,
  -- BG_DRILL_INDICATOR = 814,
  -- BG_DUAT_BLOODMOON = 823,
  -- BG_DUAT_FARFLOATINGDEBRIS = 825,
  -- BG_DUAT_FLOATINGDEBRIS = 824,
  -- BG_DUAT_LAYER = 820,
  -- BG_DUAT_PYRAMID_LAYER = 822,
  -- BG_DUAT_SIDE_DECORATION = 821,
  -- BG_EGGSAC_STAINS = 839,
  -- BG_EGGSHIP_ROOM = 775,
  -- BG_ENDINGTREASURE_HUNDUN_GOLD = 777,
  -- BG_ICE_CRYSTAL = 819,
  -- BG_KALI_STATUE = 807,
  -- BG_LEVEL_BACKWALL = 778,
  -- BG_LEVEL_BOMB_SOOT = 781,
  -- BG_LEVEL_COSMIC = 836,
  -- BG_LEVEL_DECO = 779,
  -- BG_LEVEL_POWEREDBOMB_SOOT = 782,
  -- BG_LEVEL_SHADOW = 780,
  -- BG_MOAI_STATUE = 827,
  -- BG_MOTHER_STATUE = 833,
  -- BG_OLMEC_PILLAR = 818,
  -- BG_OUROBORO = 794,
  -- BG_PALACE_CANDLE = 831,
  -- BG_PALACE_DISHES = 832,
  -- BG_PARENTSHIP_LANDINGLEG = 776,
  -- BG_SHOP = 801,
  -- BG_SHOPWANTEDPORTRAIT = 805,
  -- BG_SHOPWANTEDPOSTER = 804,
  -- BG_SHOP_BACKDOOR = 803,
  -- BG_SHOP_DICEPOSTER = 806,
  -- BG_SHOP_ENTRANCEDOOR = 802,
  -- BG_SPACE = 757,
  -- BG_SURFACE_BACKGROUNDSEAM = 769,
  -- BG_SURFACE_ENTITY = 767,
  -- BG_SURFACE_LAYER = 764,
  -- BG_SURFACE_LAYER_HOLE = 766,
  -- BG_SURFACE_LAYER_OCCLUDER = 765,
  -- BG_SURFACE_MOVING_STAR = 762,
  -- BG_SURFACE_NEBULA = 763,
  -- BG_SURFACE_OLMEC_LAYER = 768,
  -- BG_SURFACE_SHOOTING_STAR = 759,
  -- BG_SURFACE_SHOOTING_STAR_TRAIL = 760,
  -- BG_SURFACE_SHOOTING_STAR_TRAIL_PARTICLE = 761,
  -- BG_SURFACE_STAR = 758,
  -- BG_TUTORIAL_SIGN_BACK = 792,
  -- BG_TUTORIAL_SIGN_FRONT = 793,
  -- BG_UDJATSOCKET_DECORATION = 813,
  -- BG_VAT_BACK = 828,
  -- BG_VAT_FRONT = 830,
  -- BG_VAT_SHOPKEEPER_PRIME = 829,
  -- BG_VLAD_WINDOW = 815,
  -- BG_WATER_FOUNTAIN = 834,
  -- BG_YAMA_BODY = 835,
  -- CHAR_AMAZON = 200,
  -- CHAR_ANA_SPELUNKY = 194,
  -- CHAR_AU = 207,
  -- CHAR_BANDA = 198,
  -- CHAR_CLASSIC_GUY = 213,
  -- CHAR_COCO_VON_DIAMONDS = 202,
  -- CHAR_COLIN_NORTHWARD = 196,
  -- CHAR_DEMI_VON_DIAMONDS = 208,
  -- CHAR_DIRK_YAMAOKA = 211,
  -- CHAR_EGGPLANT_CHILD = 216,
  -- CHAR_GREEN_GIRL = 199,
  -- CHAR_GUY_SPELUNKY = 212,
  -- CHAR_HIREDHAND = 215,
  -- CHAR_LISE_SYSTEM = 201,
  -- CHAR_MANFRED_TUNNEL = 203,
  -- CHAR_MARGARET_TUNNEL = 195,
  -- CHAR_OTAKU = 204,
  -- CHAR_PILOT = 209,
  -- CHAR_PRINCESS_AIRYN = 210,
  -- CHAR_ROFFY_D_SLOTH = 197,
  -- CHAR_TINA_FLAN = 205,
  -- CHAR_VALERIE_CRUMP = 206,
  -- DECORATION_BABYLON = 127,
  -- DECORATION_BABYLONBUSH = 138,
  -- DECORATION_BABYLON_FLOWER = 141,
  -- DECORATION_BABYLON_HANGING_FLOWER = 144,
  -- DECORATION_BABYLON_NEON_SIGN = 145,
  -- DECORATION_BASECAMPDOGSIGN = 152,
  -- DECORATION_BASECAMPSIGN = 151,
  -- DECORATION_BEEHIVE = 162,
  -- DECORATION_BG_TRANSITIONCOVER = 128,
  -- DECORATION_BONEBLOCK = 121,
  -- DECORATION_BORDER = 115,
  -- DECORATION_BRANCH = 146,
  -- DECORATION_BUSHBLOCK = 122,
  -- DECORATION_CHAINANDBLOCKS_CHAINDECORATION = 163,
  -- DECORATION_COG = 169,
  -- DECORATION_CONVEYORBELT_RAILING = 164,
  -- DECORATION_CROSS_BEAM = 131,
  -- DECORATION_DUAT = 171,
  -- DECORATION_DUAT_DARKSAND = 173,
  -- DECORATION_DUAT_DESTRUCTIBLE_BG = 174,
  -- DECORATION_DUAT_SAND = 172,
  -- DECORATION_DWELLINGBUSH = 136,
  -- DECORATION_EGGPLANT_ALTAR = 180,
  -- DECORATION_GENERIC = 116,
  -- DECORATION_GUTS = 179,
  -- DECORATION_HANGING_BANNER = 134,
  -- DECORATION_HANGING_HIDE = 132,
  -- DECORATION_HANGING_SEAWEED = 133,
  -- DECORATION_HANGING_WIRES = 135,
  -- DECORATION_JUNGLE = 119,
  -- DECORATION_JUNGLEBUSH = 137,
  -- DECORATION_JUNGLE_FLOWER = 140,
  -- DECORATION_JUNGLE_HANGING_FLOWER = 143,
  -- DECORATION_KELP = 166,
  -- DECORATION_LARGETOMB = 185,
  -- DECORATION_MINEWOOD = 120,
  -- DECORATION_MINEWOOD_POLE = 129,
  -- DECORATION_MOTHERSHIP = 170,
  -- DECORATION_MOTHER_STATUE_HAND = 181,
  -- DECORATION_MUSHROOM_HAT = 160,
  -- DECORATION_PAGODA = 125,
  -- DECORATION_PAGODA_POLE = 130,
  -- DECORATION_PALACE = 175,
  -- DECORATION_PALACE_CHANDELIER = 177,
  -- DECORATION_PALACE_PORTRAIT = 178,
  -- DECORATION_PALACE_SIGN = 176,
  -- DECORATION_PIPE = 182,
  -- DECORATION_POTOFGOLD_RAINBOW = 189,
  -- DECORATION_REGENERATING_BORDER = 187,
  -- DECORATION_REGENERATING_SMALL_BLOCK = 186,
  -- DECORATION_SHOPFORE = 148,
  -- DECORATION_SHOPSIGN = 149,
  -- DECORATION_SHOPSIGNICON = 150,
  -- DECORATION_SKULLDROP_TRAP = 188,
  -- DECORATION_SLIDINGWALL_CHAINDECORATION = 167,
  -- DECORATION_SPIKES_BLOOD = 147,
  -- DECORATION_STONE = 123,
  -- DECORATION_SUNKEN = 126,
  -- DECORATION_SUNKEN_BRIDGE = 183,
  -- DECORATION_SURFACE = 117,
  -- DECORATION_SURFACE_COVER = 118,
  -- DECORATION_TEMPLE = 124,
  -- DECORATION_TEMPLE_SAND = 168,
  -- DECORATION_THORN_VINE = 161,
  -- DECORATION_TIDEPOOLBUSH = 139,
  -- DECORATION_TIDEPOOL_CORAL = 142,
  -- DECORATION_TOMB = 184,
  -- DECORATION_TREE = 153,
  -- DECORATION_TREETRUNK_BROKEN = 157,
  -- DECORATION_TREETRUNK_CLIMBINGHINT = 154,
  -- DECORATION_TREETRUNK_TOPBACK = 156,
  -- DECORATION_TREETRUNK_TOPFRONT = 155,
  -- DECORATION_TREE_VINE = 159,
  -- DECORATION_TREE_VINE_TOP = 158,
  -- DECORATION_VLAD = 165,
  -- EMBED_GOLD = 190,
  -- EMBED_GOLD_BIG = 191,
  -- FLOORSTYLED_BABYLON = 106,
  -- FLOORSTYLED_BEEHIVE = 108,
  -- FLOORSTYLED_COG = 110,
  -- FLOORSTYLED_DUAT = 112,
  -- FLOORSTYLED_GUTS = 114,
  -- FLOORSTYLED_MINEWOOD = 102,
  -- FLOORSTYLED_MOTHERSHIP = 111,
  -- FLOORSTYLED_PAGODA = 105,
  -- FLOORSTYLED_PALACE = 113,
  -- FLOORSTYLED_STONE = 103,
  -- FLOORSTYLED_SUNKEN = 107,
  -- FLOORSTYLED_TEMPLE = 104,
  -- FLOORSTYLED_VLAD = 109,
  -- FLOOR_ALTAR = 47,
  -- FLOOR_ARROW_TRAP = 40,
  -- FLOOR_BASECAMP_DININGTABLE = 8,
  -- FLOOR_BASECAMP_LONGTABLE = 9,
  -- FLOOR_BASECAMP_SINGLEBED = 7,
  -- FLOOR_BIGSPEAR_TRAP = 79,
  -- FLOOR_BORDERTILE = 1,
  -- FLOOR_BORDERTILE_METAL = 2,
  -- FLOOR_BORDERTILE_OCTOPUS = 3,
  -- FLOOR_CHAINANDBLOCKS_CEILING = 61,
  -- FLOOR_CHAINANDBLOCKS_CHAIN = 62,
  -- FLOOR_CHAIN_CEILING = 63,
  -- FLOOR_CHALLENGE_ENTRANCE = 87,
  -- FLOOR_CHALLENGE_WAITROOM = 88,
  -- FLOOR_CLIMBING_POLE = 20,
  -- FLOOR_CONVEYORBELT_LEFT = 64,
  -- FLOOR_CONVEYORBELT_RIGHT = 65,
  -- FLOOR_DICE_FORCEFIELD = 86,
  -- FLOOR_DOOR_COG = 31,
  -- FLOOR_DOOR_EGGPLANT_WORLD = 36,
  -- FLOOR_DOOR_EGGSHIP = 33,
  -- FLOOR_DOOR_EGGSHIP_ATREZZO = 34,
  -- FLOOR_DOOR_EGGSHIP_ROOM = 35,
  -- FLOOR_DOOR_ENTRANCE = 22,
  -- FLOOR_DOOR_EXIT = 23,
  -- FLOOR_DOOR_GHISTSHOP = 28,
  -- FLOOR_DOOR_LAYER = 26,
  -- FLOOR_DOOR_LAYER_DROP_HELD = 27,
  -- FLOOR_DOOR_LOCKED = 29,
  -- FLOOR_DOOR_LOCKED_PEN = 30,
  -- FLOOR_DOOR_MAIN_EXIT = 24,
  -- FLOOR_DOOR_MOAI_STATUE = 32,
  -- FLOOR_DOOR_PLATFORM = 37,
  -- FLOOR_DOOR_STARTING_EXIT = 25,
  -- FLOOR_DUAT_ALTAR = 71,
  -- FLOOR_DUSTWALL = 70,
  -- FLOOR_EGGPLANT_ALTAR = 74,
  -- FLOOR_EMPRESS_GRAVE = 96,
  -- FLOOR_EXCALIBUR_STONE = 69,
  -- FLOOR_FACTORY_GENERATOR = 66,
  -- FLOOR_FORCEFIELD = 85,
  -- FLOOR_FORCEFIELD_TOP = 90,
  -- FLOOR_GENERIC = 4,
  -- FLOOR_GIANTFROG_PLATFORM = 83,
  -- FLOOR_GROWABLE_CLIMBING_POLE = 21,
  -- FLOOR_GROWABLE_VINE = 19,
  -- FLOOR_HORIZONTAL_FORCEFIELD = 91,
  -- FLOOR_HORIZONTAL_FORCEFIELD_TOP = 92,
  -- FLOOR_ICE = 72,
  -- FLOOR_IDOL_BLOCK = 48,
  -- FLOOR_IDOL_TRAP_CEILING = 49,
  -- FLOOR_JUNGLE = 10,
  -- FLOOR_JUNGLE_SPEAR_TRAP = 43,
  -- FLOOR_LADDER = 15,
  -- FLOOR_LADDER_PLATFORM = 16,
  -- FLOOR_LASER_TRAP = 45,
  -- FLOOR_LION_TRAP = 44,
  -- FLOOR_MOAI_PLATFORM = 75,
  -- FLOOR_MOTHER_STATUE = 81,
  -- FLOOR_MOTHER_STATUE_PLATFORM = 82,
  -- FLOOR_MUSHROOM_BASE = 55,
  -- FLOOR_MUSHROOM_HAT_PLATFORM = 58,
  -- FLOOR_MUSHROOM_TOP = 57,
  -- FLOOR_MUSHROOM_TRUNK = 56,
  -- FLOOR_PAGODA_PLATFORM = 14,
  -- FLOOR_PALACE_BOOKCASE_PLATFORM = 100,
  -- FLOOR_PALACE_CHANDELIER_PLATFORM = 99,
  -- FLOOR_PALACE_TABLE_PLATFORM = 97,
  -- FLOOR_PALACE_TRAY_PLATFORM = 98,
  -- FLOOR_PEN = 93,
  -- FLOOR_PIPE = 78,
  -- FLOOR_PLATFORM = 13,
  -- FLOOR_POISONED_ARROW_TRAP = 41,
  -- FLOOR_QUICKSAND = 68,
  -- FLOOR_SHOPKEEPER_GENERATOR = 76,
  -- FLOOR_SLIDINGWALL_CEILING = 67,
  -- FLOOR_SPARK_TRAP = 46,
  -- FLOOR_SPIKEBALL_CEILING = 60,
  -- FLOOR_SPIKES = 38,
  -- FLOOR_SPIKES_UPSIDEDOWN = 39,
  -- FLOOR_SPRING_TRAP = 73,
  -- FLOOR_STICKYTRAP_CEILING = 80,
  -- FLOOR_STORAGE = 50,
  -- FLOOR_SUNCHALLENGE_GENERATOR = 77,
  -- FLOOR_SURFACE = 5,
  -- FLOOR_SURFACE_HIDDEN = 6,
  -- FLOOR_TELEPORTINGBORDER = 84,
  -- FLOOR_TENTACLE_BOTTOM = 101,
  -- FLOOR_THORN_VINE = 59,
  -- FLOOR_TIMED_FORCEFIELD = 89,
  -- FLOOR_TOMB = 94,
  -- FLOOR_TOTEM_TRAP = 42,
  -- FLOOR_TREE_BASE = 51,
  -- FLOOR_TREE_BRANCH = 54,
  -- FLOOR_TREE_TOP = 53,
  -- FLOOR_TREE_TRUNK = 52,
  -- FLOOR_TUNNEL_CURRENT = 11,
  -- FLOOR_TUNNEL_NEXT = 12,
  -- FLOOR_VINE = 17,
  -- FLOOR_VINE_TREE_TOP = 18,
  -- FLOOR_YAMA_PLATFORM = 95,
  -- FX_ALIENBLAST = 692,
  -- FX_ALIENBLAST_RETICULE_EXTERNAL = 691,
  -- FX_ALIENBLAST_RETICULE_INTERNAL = 690,
  -- FX_ALIENQUEEN_EYE = 689,
  -- FX_ALIENQUEEN_EYEBALL = 688,
  -- FX_ANKH_BACKGLOW = 750,
  -- FX_ANKH_BROKENPIECE = 753,
  -- FX_ANKH_FALLINGSPARK = 749,
  -- FX_ANKH_FRONTGLOW = 751,
  -- FX_ANKH_LIGHTBEAM = 752,
  -- FX_ANKH_ROTATINGSPARK = 748,
  -- FX_ANUBIS_SPECIAL_SHOT_RETICULE = 733,
  -- FX_APEP_FIRE = 679,
  -- FX_APEP_MOUTHPIECE = 680,
  -- FX_AXOLOTL_HEAD_ENTERING_DOOR = 740,
  -- FX_BASECAMP_COUCH_ARM = 741,
  -- FX_BIRDIES = 634,
  -- FX_BUTTON = 668,
  -- FX_BUTTON_DIALOG = 669,
  -- FX_CINEMATIC_BLACKBAR = 661,
  -- FX_COMPASS = 644,
  -- FX_CRITTERFIREFLY_LIGHT = 739,
  -- FX_CRUSHINGELEVATOR_DECO = 715,
  -- FX_CRUSHINGELEVATOR_FILL = 714,
  -- FX_DIEINDICATOR = 709,
  -- FX_DRILL_TURNING = 681,
  -- FX_EGGSHIP_CENTERJETFLAME = 628,
  -- FX_EGGSHIP_DOOR = 627,
  -- FX_EGGSHIP_HOOK_CHAIN = 743,
  -- FX_EGGSHIP_JETFLAME = 629,
  -- FX_EGGSHIP_SHADOW = 630,
  -- FX_EGGSHIP_SHELL = 626,
  -- FX_EMPRESS = 742,
  -- FX_EXPLOSION = 635,
  -- FX_HORIZONTALLASERBEAM = 712,
  -- FX_HUNDUN_EGG_CRACK = 719,
  -- FX_HUNDUN_EYE = 724,
  -- FX_HUNDUN_EYEBALL = 723,
  -- FX_HUNDUN_EYELID = 722,
  -- FX_HUNDUN_LIMB_CALF = 717,
  -- FX_HUNDUN_LIMB_FOOT = 718,
  -- FX_HUNDUN_LIMB_THIGH = 716,
  -- FX_HUNDUN_NECK_PIECE = 720,
  -- FX_HUNDUN_WING = 721,
  -- FX_INK_BLINDNESS = 671,
  -- FX_INK_SPLAT = 672,
  -- FX_JETPACKFLAME = 655,
  -- FX_KINGU_HEAD = 683,
  -- FX_KINGU_LIMB = 686,
  -- FX_KINGU_PLATFORM = 685,
  -- FX_KINGU_SHADOW = 684,
  -- FX_KINGU_SLIDING = 687,
  -- FX_LAMASSU_ATTACK = 738,
  -- FX_LASERBEAM = 711,
  -- FX_LAVA_BUBBLE = 673,
  -- FX_LAVA_GLOW = 674,
  -- FX_LEADER_FLAG = 682,
  -- FX_MAIN_EXIT_DOOR = 633,
  -- FX_MECH_COLLAR = 734,
  -- FX_MEGAJELLYFISH_BOTTOM = 730,
  -- FX_MEGAJELLYFISH_CROWN = 726,
  -- FX_MEGAJELLYFISH_EYE = 727,
  -- FX_MEGAJELLYFISH_FLIPPER = 729,
  -- FX_MEGAJELLYFISH_STAR = 728,
  -- FX_MEGAJELLYFISH_TAIL = 731,
  -- FX_MEGAJELLYFISH_TAIL_BG = 732,
  -- FX_MINIGAME_SHIP_CENTERJETFLAME = 745,
  -- FX_MINIGAME_SHIP_DOOR = 744,
  -- FX_MINIGAME_SHIP_JETFLAME = 746,
  -- FX_MODERNEXPLOSION = 637,
  -- FX_NECROMANCER_ANKH = 659,
  -- FX_OLMECPART_FLOATER = 662,
  -- FX_OLMECPART_LARGE = 663,
  -- FX_OLMECPART_MEDIUM = 664,
  -- FX_OLMECPART_SMALL = 665,
  -- FX_OLMECPART_SMALLEST = 666,
  -- FX_OUROBORO_HEAD = 639,
  -- FX_OUROBORO_OCCLUDER = 638,
  -- FX_OUROBORO_TAIL = 640,
  -- FX_OUROBORO_TEXT = 641,
  -- FX_OUROBORO_TRAIL = 642,
  -- FX_PICKUPEFFECT = 653,
  -- FX_PLAYERINDICATOR = 646,
  -- FX_PLAYERINDICATORPORTRAIT = 647,
  -- FX_PORTAL = 725,
  -- FX_POWEREDEXPLOSION = 636,
  -- FX_QUICKSAND_DUST = 735,
  -- FX_QUICKSAND_RUBBLE = 736,
  -- FX_SALEDIALOG_CONTAINER = 649,
  -- FX_SALEDIALOG_ICON = 652,
  -- FX_SALEDIALOG_TITLE = 650,
  -- FX_SALEDIALOG_VALUE = 651,
  -- FX_SALEICON = 648,
  -- FX_SHADOW = 631,
  -- FX_SHOTGUNBLAST = 654,
  -- FX_SLEEP_BUBBLE = 670,
  -- FX_SMALLFLAME = 656,
  -- FX_SORCERESS_ATTACK = 737,
  -- FX_SPARK = 693,
  -- FX_SPARK_SMALL = 694,
  -- FX_SPECIALCOMPASS = 645,
  -- FX_SPRINGTRAP_RING = 657,
  -- FX_STORAGE_INDICATOR = 710,
  -- FX_TELEPORTSHADOW = 660,
  -- FX_TIAMAT_ARM_LEFT1 = 702,
  -- FX_TIAMAT_ARM_LEFT2 = 703,
  -- FX_TIAMAT_ARM_LEFT3 = 704,
  -- FX_TIAMAT_ARM_RIGHT1 = 705,
  -- FX_TIAMAT_ARM_RIGHT2 = 706,
  -- FX_TIAMAT_HEAD = 708,
  -- FX_TIAMAT_NECK = 707,
  -- FX_TIAMAT_TAIL = 697,
  -- FX_TIAMAT_TAIL_DECO1 = 698,
  -- FX_TIAMAT_TAIL_DECO2 = 699,
  -- FX_TIAMAT_TAIL_DECO3 = 700,
  -- FX_TIAMAT_THRONE = 695,
  -- FX_TIAMAT_TORSO = 701,
  -- FX_TIAMAT_WAIST = 696,
  -- FX_TORNJOURNALPAGE = 632,
  -- FX_UNDERWATER_BUBBLE = 675,
  -- FX_VAT_BUBBLE = 713,
  -- FX_WATER_DROP = 676,
  -- FX_WATER_SPLASH = 677,
  -- FX_WATER_SURFACE = 678,
  -- FX_WEBBEDEFFECT = 667,
  -- FX_WITCHDOCTOR_HINT = 658,
  -- ITEM_ACIDBUBBLE = 391,
  -- ITEM_ACIDSPIT = 389,
  -- ITEM_ALIVE_EMBEDDED_ON_ICE = 463,
  -- ITEM_ANUBIS_COFFIN = 453,
  -- ITEM_AUTOWALLTORCH = 415,
  -- ITEM_AXOLOTL_BUBBLESHOT = 456,
  -- ITEM_BASECAMP_TUTORIAL_SIGN = 408,
  -- ITEM_BIG_SPEAR = 364,
  -- ITEM_BLOOD = 352,
  -- ITEM_BOMB = 347,
  -- ITEM_BONES = 483,
  -- ITEM_BOOMBOX = 409,
  -- ITEM_BOOMERANG = 581,
  -- ITEM_BROKENEXCALIBUR = 584,
  -- ITEM_BROKEN_ARROW = 372,
  -- ITEM_BROKEN_MATTOCK = 428,
  -- ITEM_BULLET = 424,
  -- ITEM_CAMERA = 578,
  -- ITEM_CAPE = 562,
  -- ITEM_CHAIN = 431,
  -- ITEM_CHAIN_LASTPIECE = 432,
  -- ITEM_CHEST = 395,
  -- ITEM_CLIMBABLE_ROPE = 350,
  -- ITEM_CLONEGUN = 587,
  -- ITEM_CLONEGUNSHOT = 426,
  -- ITEM_COFFIN = 435,
  -- ITEM_CONSTRUCTION_SIGN = 405,
  -- ITEM_COOKFIRE = 484,
  -- ITEM_CRABMAN_ACIDBUBBLE = 392,
  -- ITEM_CRABMAN_CLAW = 393,
  -- ITEM_CRABMAN_CLAWCHAIN = 394,
  -- ITEM_CRATE = 402,
  -- ITEM_CROSSBOW = 577,
  -- ITEM_CURSEDPOT = 481,
  -- ITEM_CURSING_CLOUD = 440,
  -- ITEM_DEPLOYED_PARACHUTE = 464,
  -- ITEM_DIAMOND = 497,
  -- ITEM_DICE_BET = 449,
  -- ITEM_DICE_PRIZE_DISPENSER = 450,
  -- ITEM_DIE = 448,
  -- ITEM_DMCRATE = 403,
  -- ITEM_EGGPLANT = 487,
  -- ITEM_EGGSAC = 492,
  -- ITEM_EGGSHIP = 353,
  -- ITEM_EGGSHIP_HOOK = 455,
  -- ITEM_EMERALD = 498,
  -- ITEM_EMERALD_SMALL = 503,
  -- ITEM_EMPRESS_GRAVE = 470,
  -- ITEM_ENDINGTREASURE_HUNDUN = 398,
  -- ITEM_ENDINGTREASURE_TIAMAT = 397,
  -- ITEM_EXCALIBUR = 583,
  -- ITEM_FIREBALL = 385,
  -- ITEM_FLAMETHROWER_FIREBALL = 387,
  -- ITEM_FLOATING_ORB = 491,
  -- ITEM_FLY = 436,
  -- ITEM_FREEZERAY = 576,
  -- ITEM_FREEZERAYSHOT = 425,
  -- ITEM_FROZEN_LIQUID = 462,
  -- ITEM_GHIST_PRESENT = 423,
  -- ITEM_GIANTCLAM_TOP = 445,
  -- ITEM_GIANTFLY_HEAD = 467,
  -- ITEM_GIANTSPIDER_WEBSHOT = 368,
  -- ITEM_GOLDBAR = 495,
  -- ITEM_GOLDBARS = 496,
  -- ITEM_GOLDCOIN = 502,
  -- ITEM_HANGANCHOR = 370,
  -- ITEM_HANGSTRAND = 369,
  -- ITEM_HOLDTHEIDOL = 359,
  -- ITEM_HONEY = 444,
  -- ITEM_HORIZONTALLASERBEAM = 452,
  -- ITEM_HOUYIBOW = 588,
  -- ITEM_HOVERPACK = 570,
  -- ITEM_HUNDUN_FIREBALL = 386,
  -- ITEM_ICECAGE = 427,
  -- ITEM_ICESPIRE = 488,
  -- ITEM_IDOL = 356,
  -- ITEM_INKSPIT = 390,
  -- ITEM_JETPACK = 565,
  -- ITEM_JETPACK_MECH = 566,
  -- ITEM_JUNGLE_SPEAR_COSMETIC = 361,
  -- ITEM_JUNGLE_SPEAR_DAMAGING = 362,
  -- ITEM_KEY = 399,
  -- ITEM_LAMASSU_LASER_SHOT = 380,
  -- ITEM_LAMP = 418,
  -- ITEM_LAMPFLAME = 419,
  -- ITEM_LANDMINE = 439,
  -- ITEM_LASERBEAM = 451,
  -- ITEM_LASERTRAP_SHOT = 382,
  -- ITEM_LAVAPOT = 485,
  -- ITEM_LEAF = 388,
  -- ITEM_LIGHT_ARROW = 374,
  -- ITEM_LION_SPEAR = 363,
  -- ITEM_LITWALLTORCH = 414,
  -- ITEM_LOCKEDCHEST = 400,
  -- ITEM_LOCKEDCHEST_KEY = 401,
  -- ITEM_MACHETE = 582,
  -- ITEM_MADAMETUSK_IDOL = 357,
  -- ITEM_MADAMETUSK_IDOLNOTE = 358,
  -- ITEM_MATTOCK = 580,
  -- ITEM_METAL_ARROW = 373,
  -- ITEM_METAL_SHIELD = 590,
  -- ITEM_MINIGAME_ASTEROID = 477,
  -- ITEM_MINIGAME_ASTEROID_BG = 476,
  -- ITEM_MINIGAME_BROKEN_ASTEROID = 478,
  -- ITEM_MINIGAME_SHIP = 474,
  -- ITEM_MINIGAME_UFO = 475,
  -- ITEM_NUGGET = 501,
  -- ITEM_NUGGET_SMALL = 506,
  -- ITEM_OLMECCANNON_BOMBS = 437,
  -- ITEM_OLMECCANNON_UFO = 438,
  -- ITEM_OLMECSHIP = 355,
  -- ITEM_PALACE_CANDLE = 489,
  -- ITEM_PALACE_CANDLE_FLAME = 468,
  -- ITEM_PARENTSSHIP = 354,
  -- ITEM_PASTEBOMB = 348,
  -- ITEM_PICKUP_ANKH = 537,
  -- ITEM_PICKUP_BOMBBAG = 513,
  -- ITEM_PICKUP_BOMBBOX = 514,
  -- ITEM_PICKUP_CLIMBINGGLOVES = 523,
  -- ITEM_PICKUP_CLOVER = 519,
  -- ITEM_PICKUP_COMPASS = 528,
  -- ITEM_PICKUP_COOKEDTURKEY = 516,
  -- ITEM_PICKUP_CROWN = 534,
  -- ITEM_PICKUP_EGGPLANTCROWN = 535,
  -- ITEM_PICKUP_ELIXIR = 518,
  -- ITEM_PICKUP_GIANTFOOD = 517,
  -- ITEM_PICKUP_HEDJET = 533,
  -- ITEM_PICKUP_JOURNAL = 510,
  -- ITEM_PICKUP_KAPALA = 532,
  -- ITEM_PICKUP_PARACHUTE = 530,
  -- ITEM_PICKUP_PASTE = 527,
  -- ITEM_PICKUP_PITCHERSMITT = 524,
  -- ITEM_PICKUP_PLAYERBAG = 541,
  -- ITEM_PICKUP_ROPE = 511,
  -- ITEM_PICKUP_ROPEPILE = 512,
  -- ITEM_PICKUP_ROYALJELLY = 515,
  -- ITEM_PICKUP_SEEDEDRUNSUNLOCKER = 520,
  -- ITEM_PICKUP_SKELETON_KEY = 539,
  -- ITEM_PICKUP_SPECIALCOMPASS = 529,
  -- ITEM_PICKUP_SPECTACLES = 522,
  -- ITEM_PICKUP_SPIKESHOES = 526,
  -- ITEM_PICKUP_SPRINGSHOES = 525,
  -- ITEM_PICKUP_TABLETOFDESTINY = 538,
  -- ITEM_PICKUP_TORNJOURNALPAGE = 509,
  -- ITEM_PICKUP_TRUECROWN = 536,
  -- ITEM_PICKUP_UDJATEYE = 531,
  -- ITEM_PLASMACANNON = 585,
  -- ITEM_PLASMACANNON_SHOT = 375,
  -- ITEM_PLAYERGHOST = 446,
  -- ITEM_PLAYERGHOST_BREATH = 447,
  -- ITEM_POT = 480,
  -- ITEM_POTOFGOLD = 457,
  -- ITEM_POWERPACK = 572,
  -- ITEM_POWERUP_ANKH = 558,
  -- ITEM_POWERUP_CLIMBING_GLOVES = 544,
  -- ITEM_POWERUP_COMPASS = 552,
  -- ITEM_POWERUP_CROWN = 555,
  -- ITEM_POWERUP_EGGPLANTCROWN = 556,
  -- ITEM_POWERUP_HEDJET = 554,
  -- ITEM_POWERUP_KAPALA = 547,
  -- ITEM_POWERUP_PARACHUTE = 551,
  -- ITEM_POWERUP_PASTE = 543,
  -- ITEM_POWERUP_PITCHERSMITT = 549,
  -- ITEM_POWERUP_SKELETON_KEY = 560,
  -- ITEM_POWERUP_SPECIALCOMPASS = 553,
  -- ITEM_POWERUP_SPECTACLES = 548,
  -- ITEM_POWERUP_SPIKE_SHOES = 545,
  -- ITEM_POWERUP_SPRING_SHOES = 546,
  -- ITEM_POWERUP_TABLETOFDESTINY = 559,
  -- ITEM_POWERUP_TRUECROWN = 557,
  -- ITEM_POWERUP_UDJATEYE = 550,
  -- ITEM_PRESENT = 422,
  -- ITEM_PUNISHBALL = 429,
  -- ITEM_PUNISHCHAIN = 430,
  -- ITEM_PURCHASABLE_CAPE = 564,
  -- ITEM_PURCHASABLE_HOVERPACK = 571,
  -- ITEM_PURCHASABLE_JETPACK = 567,
  -- ITEM_PURCHASABLE_POWERPACK = 573,
  -- ITEM_PURCHASABLE_TELEPORTER_BACKPACK = 569,
  -- ITEM_REDLANTERN = 420,
  -- ITEM_REDLANTERNFLAME = 421,
  -- ITEM_ROCK = 365,
  -- ITEM_ROPE = 349,
  -- ITEM_RUBBLE = 643,
  -- ITEM_RUBY = 500,
  -- ITEM_RUBY_SMALL = 505,
  -- ITEM_SAPPHIRE = 499,
  -- ITEM_SAPPHIRE_SMALL = 504,
  -- ITEM_SCEPTER = 586,
  -- ITEM_SCEPTER_ANUBISSHOT = 376,
  -- ITEM_SCEPTER_ANUBISSPECIALSHOT = 377,
  -- ITEM_SCEPTER_PLAYERSHOT = 378,
  -- ITEM_SCRAP = 486,
  -- ITEM_SHORTCUT_SIGN = 406,
  -- ITEM_SHOTGUN = 575,
  -- ITEM_SKULL = 482,
  -- ITEM_SKULLDROPTRAP = 461,
  -- ITEM_SKULLDROPTRAP_SKULL = 490,
  -- ITEM_SLIDINGWALL_CHAIN = 433,
  -- ITEM_SLIDINGWALL_CHAIN_LASTPIECE = 434,
  -- ITEM_SLIDINGWALL_SWITCH = 465,
  -- ITEM_SLIDINGWALL_SWITCH_REWARD = 466,
  -- ITEM_SNAP_TRAP = 469,
  -- ITEM_SORCERESS_DAGGER_SHOT = 381,
  -- ITEM_SPARK = 383,
  -- ITEM_SPEEDRUN_SIGN = 407,
  -- ITEM_SPIKES = 454,
  -- ITEM_STICKYTRAP_BALL = 460,
  -- ITEM_STICKYTRAP_LASTPIECE = 459,
  -- ITEM_STICKYTRAP_PIECE = 458,
  -- ITEM_TELEPORTER = 579,
  -- ITEM_TELEPORTER_BACKPACK = 568,
  -- ITEM_TELESCOPE = 411,
  -- ITEM_TENTACLE = 471,
  -- ITEM_TENTACLE_LAST_PIECE = 473,
  -- ITEM_TENTACLE_PIECE = 472,
  -- ITEM_TIAMAT_SHOT = 384,
  -- ITEM_TORCH = 416,
  -- ITEM_TORCHFLAME = 417,
  -- ITEM_TOTEM_SPEAR = 360,
  -- ITEM_TURKEY_NECK = 443,
  -- ITEM_TUTORIAL_MONSTER_SIGN = 404,
  -- ITEM_TV = 410,
  -- ITEM_UDJAT_SOCKET = 441,
  -- ITEM_UFO_LASER_SHOT = 379,
  -- ITEM_UNROLLED_ROPE = 351,
  -- ITEM_USHABTI = 442,
  -- ITEM_VAULTCHEST = 396,
  -- ITEM_VLADS_CAPE = 563,
  -- ITEM_WALLTORCH = 412,
  -- ITEM_WALLTORCHFLAME = 413,
  -- ITEM_WEB = 366,
  -- ITEM_WEBGUN = 574,
  -- ITEM_WEBSHOT = 367,
  -- ITEM_WHIP = 345,
  -- ITEM_WHIP_FLAME = 346,
  -- ITEM_WOODEN_ARROW = 371,
  -- ITEM_WOODEN_SHIELD = 589,
  -- LIQUID_COARSE_WATER = 908,
  -- LIQUID_IMPOSTOR_LAKE = 909,
  -- LIQUID_LAVA = 910,
  -- LIQUID_STAGNANT_LAVA = 911,
  -- LIQUID_WATER = 907,
  -- LOGICAL_ANCHOVY_FLOCK = 871,
  -- LOGICAL_ARROW_TRAP_TRIGGER = 847,
  -- LOGICAL_BIGSPEAR_TRAP_TRIGGER = 882,
  -- LOGICAL_BLACKMARKET_DOOR = 846,
  -- LOGICAL_BOULDERSPAWNER = 878,
  -- LOGICAL_BURNING_ROPE_EFFECT = 861,
  -- LOGICAL_CAMERA_ANCHOR = 857,
  -- LOGICAL_CAMERA_FLASH = 863,
  -- LOGICAL_CINEMATIC_ANCHOR = 860,
  -- LOGICAL_CONSTELLATION = 842,
  -- LOGICAL_CONVEYORBELT_SOUND_SOURCE = 870,
  -- LOGICAL_CRUSH_TRAP_TRIGGER = 851,
  -- LOGICAL_CURSED_EFFECT = 856,
  -- LOGICAL_DM_ALIEN_BLAST = 887,
  -- LOGICAL_DM_CAMERA_ANCHOR = 885,
  -- LOGICAL_DM_CRATE_SPAWNING = 888,
  -- LOGICAL_DM_DEATH_MIST = 886,
  -- LOGICAL_DM_IDOL_SPAWNING = 889,
  -- LOGICAL_DM_SPAWN_POINT = 884,
  -- LOGICAL_DOOR = 844,
  -- LOGICAL_DOOR_AMBIENT_SOUND = 845,
  -- LOGICAL_DUSTWALL_APEP = 862,
  -- LOGICAL_DUSTWALL_SOUND_SOURCE = 875,
  -- LOGICAL_EGGPLANT_THROWER = 892,
  -- LOGICAL_FROST_BREATH = 891,
  -- LOGICAL_ICESLIDING_SOUND_SOURCE = 876,
  -- LOGICAL_JUNGLESPEAR_TRAP_TRIGGER = 849,
  -- LOGICAL_LAVA_DRAIN = 880,
  -- LOGICAL_LIMB_ANCHOR = 865,
  -- LOGICAL_MINIGAME = 893,
  -- LOGICAL_MUMMYFLIES_SOUND_SOURCE = 872,
  -- LOGICAL_ONFIRE_EFFECT = 854,
  -- LOGICAL_OUROBORO_CAMERA_ANCHOR = 858,
  -- LOGICAL_OUROBORO_CAMERA_ANCHOR_ZOOMIN = 859,
  -- LOGICAL_PIPE_TRAVELER_SOUND_SOURCE = 877,
  -- LOGICAL_PLATFORM_SPAWNER = 883,
  -- LOGICAL_POISONED_EFFECT = 855,
  -- LOGICAL_PORTAL = 866,
  -- LOGICAL_QUICKSAND_AMBIENT_SOUND_SOURCE = 873,
  -- LOGICAL_QUICKSAND_SOUND_SOURCE = 874,
  -- LOGICAL_REGENERATING_BLOCK = 881,
  -- LOGICAL_ROOM_LIGHT = 864,
  -- LOGICAL_SHOOTING_STARS_SPAWNER = 843,
  -- LOGICAL_SPIKEBALL_TRIGGER = 850,
  -- LOGICAL_SPLASH_BUBBLE_GENERATOR = 890,
  -- LOGICAL_STATICLAVA_SOUND_SOURCE = 867,
  -- LOGICAL_STREAMLAVA_SOUND_SOURCE = 868,
  -- LOGICAL_STREAMWATER_SOUND_SOURCE = 869,
  -- LOGICAL_TENTACLE_TRIGGER = 852,
  -- LOGICAL_TOTEM_TRAP_TRIGGER = 848,
  -- LOGICAL_WATER_DRAIN = 879,
  -- LOGICAL_WET_EFFECT = 853,
  -- MIDBG = 808,
  -- MIDBG_BEEHIVE = 811,
  -- MIDBG_PALACE_STYLEDDECORATION = 810,
  -- MIDBG_PLATFORM_STRUCTURE = 812,
  -- MIDBG_STYLEDDECORATION = 809,
  -- MONS_ALIEN = 267,
  -- MONS_ALIENQUEEN = 271,
  -- MONS_AMMIT = 280,
  -- MONS_ANUBIS = 253,
  -- MONS_ANUBIS2 = 259,
  -- MONS_APEP_BODY = 255,
  -- MONS_APEP_HEAD = 254,
  -- MONS_APEP_TAIL = 256,
  -- MONS_BAT = 224,
  -- MONS_BEE = 278,
  -- MONS_BODYGUARD = 306,
  -- MONS_CATMUMMY = 251,
  -- MONS_CAVEMAN = 225,
  -- MONS_CAVEMAN_BOSS = 232,
  -- MONS_CAVEMAN_SHOPKEEPER = 226,
  -- MONS_COBRA = 248,
  -- MONS_CRABMAN = 311,
  -- MONS_CRITTERANCHOVY = 335,
  -- MONS_CRITTERBUTTERFLY = 332,
  -- MONS_CRITTERCRAB = 336,
  -- MONS_CRITTERDRONE = 340,
  -- MONS_CRITTERDUNGBEETLE = 331,
  -- MONS_CRITTERFIREFLY = 339,
  -- MONS_CRITTERFISH = 334,
  -- MONS_CRITTERLOCUST = 337,
  -- MONS_CRITTERPENGUIN = 338,
  -- MONS_CRITTERSLIME = 341,
  -- MONS_CRITTERSNAIL = 333,
  -- MONS_CROCMAN = 247,
  -- MONS_EGGPLANT_MINISTER = 290,
  -- MONS_FEMALE_JIANGSHI = 261,
  -- MONS_FIREBUG = 241,
  -- MONS_FIREBUG_UNCHAINED = 242,
  -- MONS_FIREFROG = 284,
  -- MONS_FISH = 262,
  -- MONS_FROG = 283,
  -- MONS_GHIST = 314,
  -- MONS_GHIST_SHOPKEEPER = 315,
  -- MONS_GHOST = 317,
  -- MONS_GHOST_MEDIUM_HAPPY = 319,
  -- MONS_GHOST_MEDIUM_SAD = 318,
  -- MONS_GHOST_SMALL_ANGRY = 320,
  -- MONS_GHOST_SMALL_HAPPY = 323,
  -- MONS_GHOST_SMALL_SAD = 321,
  -- MONS_GHOST_SMALL_SURPRISED = 322,
  -- MONS_GIANTFISH = 265,
  -- MONS_GIANTFLY = 288,
  -- MONS_GIANTFROG = 285,
  -- MONS_GIANTSPIDER = 223,
  -- MONS_GOLDMONKEY = 309,
  -- MONS_GRUB = 286,
  -- MONS_HANGSPIDER = 222,
  -- MONS_HERMITCRAB = 264,
  -- MONS_HORNEDLIZARD = 230,
  -- MONS_HUNDUN = 292,
  -- MONS_HUNDUNS_SERVANT = 307,
  -- MONS_HUNDUN_BIRDHEAD = 293,
  -- MONS_HUNDUN_SNAKEHEAD = 294,
  -- MONS_IMP = 243,
  -- MONS_JIANGSHI = 260,
  -- MONS_JUMPDOG = 289,
  -- MONS_KINGU = 281,
  -- MONS_LAMASSU = 274,
  -- MONS_LAVAMANDER = 244,
  -- MONS_LEPRECHAUN = 310,
  -- MONS_MADAMETUSK = 305,
  -- MONS_MAGMAMAN = 239,
  -- MONS_MANTRAP = 233,
  -- MONS_MARLA_TUNNEL = 299,
  -- MONS_MEGAJELLYFISH = 312,
  -- MONS_MEGAJELLYFISH_BACKGROUND = 313,
  -- MONS_MERCHANT = 297,
  -- MONS_MOLE = 231,
  -- MONS_MONKEY = 238,
  -- MONS_MOSQUITO = 237,
  -- MONS_MUMMY = 249,
  -- MONS_NECROMANCER = 252,
  -- MONS_OCTOPUS = 263,
  -- MONS_OLD_HUNTER = 303,
  -- MONS_OLMITE_BODYARMORED = 276,
  -- MONS_OLMITE_HELMET = 275,
  -- MONS_OLMITE_NAKED = 277,
  -- MONS_OSIRIS_HAND = 258,
  -- MONS_OSIRIS_HEAD = 257,
  -- MONS_PET_CAT = 327,
  -- MONS_PET_DOG = 326,
  -- MONS_PET_HAMSTER = 328,
  -- MONS_PET_TUTORIAL = 219,
  -- MONS_PROTOSHOPKEEPER = 272,
  -- MONS_QUEENBEE = 279,
  -- MONS_REDSKELETON = 228,
  -- MONS_ROBOT = 240,
  -- MONS_SCARAB = 295,
  -- MONS_SCORPION = 229,
  -- MONS_SHOPKEEPER = 296,
  -- MONS_SHOPKEEPERCLONE = 273,
  -- MONS_SISTER_PARMESAN = 302,
  -- MONS_SISTER_PARSLEY = 300,
  -- MONS_SISTER_PARSNIP = 301,
  -- MONS_SKELETON = 227,
  -- MONS_SNAKE = 220,
  -- MONS_SORCERESS = 250,
  -- MONS_SPIDER = 221,
  -- MONS_STORAGEGUY = 308,
  -- MONS_TADPOLE = 287,
  -- MONS_THIEF = 304,
  -- MONS_TIAMAT = 282,
  -- MONS_TIKIMAN = 234,
  -- MONS_UFO = 266,
  -- MONS_VAMPIRE = 245,
  -- MONS_VLAD = 246,
  -- MONS_WITCHDOCTOR = 235,
  -- MONS_WITCHDOCTORSKULL = 236,
  -- MONS_YAMA = 291,
  -- MONS_YANG = 298,
  -- MONS_YETI = 268,
  -- MONS_YETIKING = 269,
  -- MONS_YETIQUEEN = 270,
  -- MOUNT_AXOLOTL = 899,
  -- MOUNT_BASECAMP_CHAIR = 903,
  -- MOUNT_BASECAMP_COUCH = 904,
  -- MOUNT_MECH = 900,
  -- MOUNT_QILIN = 901,
  -- MOUNT_ROCKDOG = 898,
  -- MOUNT_TURKEY = 897
-- }
-- Entity = {
  -- __name = "sol.Entity.user"
-- }
-- EntityDB = {
  -- __name = "sol.EntityDB.user"
-- }
-- Ghost = {
  -- __index = "function: 0000023A40DB5040",
  -- __name = "sol.Ghost.user",
  -- __newindex = "function: 0000023A40DB3A40"
-- }
-- Gun = {
  -- __index = "function: 0000023A40DA2350",
  -- __name = "sol.Gun.user",
  -- __newindex = "function: 0000023A40DA3A00"
-- }
-- Illumination = {
  -- __name = "sol.Illumination.user"
-- }
-- Inventory = {
  -- __name = "sol.Inventory.user"
-- }
-- Jiangshi = {
  -- __index = "function: 0000023A40DB5670",
  -- __name = "sol.Jiangshi.user",
  -- __newindex = "function: 0000023A40DB5930"
-- }
-- LAYER = {
  -- BACK = 1,
  -- FRONT = 0,
  -- PLAYER = -1,
  -- PLAYER1 = -1,
  -- PLAYER2 = -2,
  -- PLAYER3 = -3,
  -- PLAYER4 = -4
-- }
-- LoadContext = {
  -- __name = "sol.LoadContext.user"
-- }
-- MASK = {
  -- ACTIVEFLOOR = 128,
  -- BG = 1024,
  -- DECORATION = 512,
  -- EXPLOSION = 16,
  -- FLOOR = 256,
  -- FX = 64,
  -- ITEM = 8,
  -- LAVA = 16384,
  -- LOGICAL = 4096,
  -- MONSTER = 4,
  -- MOUNT = 2,
  -- PLAYER = 1,
  -- ROPE = 32,
  -- SHADOW = 2048,
  -- WATER = 8192
-- }
-- Monster = {
  -- __index = "function: 0000023A1590FCE0",
  -- __name = "sol.Monster.user",
  -- __newindex = "function: 0000023A15911700"
-- }
-- Mount = {
  -- __index = "function: 0000023A1590B350",
  -- __name = "sol.Mount.user",
  -- __newindex = "function: 0000023A1590A850"
-- }
-- Movable = {
  -- __index = "function: 0000023A15911440",
  -- __name = "sol.Movable.user",
  -- __newindex = "function: 0000023A15910D60"
-- }
-- ON = {
  -- ARENA_INTRO = 25,
  -- ARENA_MATCH = 26,
  -- ARENA_MENU = 21,
  -- ARENA_SCORE = 27,
  -- CAMP = 11,
  -- CHARACTER_SELECT = 9,
  -- CONSTELLATION = 19,
  -- CREDITS = 17,
  -- DEATH = 14,
  -- FRAME = 101,
  -- GAMEFRAME = 108,
  -- GUIFRAME = 100,
  -- INTRO = 1,
  -- LEADERBOARD = 7,
  -- LEVEL = 12,
  -- LOAD = 107,
  -- LOADING = 104,
  -- LOGO = 0,
  -- MENU = 4,
  -- ONLINE_LOADING = 28,
  -- ONLINE_LOBBY = 29,
  -- OPTIONS = 5,
  -- PROLOGUE = 2,
  -- RECAP = 20,
  -- RESET = 105,
  -- SAVE = 106,
  -- SCORES = 18,
  -- SCREEN = 102,
  -- SEED_INPUT = 8,
  -- SPACESHIP = 15,
  -- START = 103,
  -- TEAM_SELECT = 10,
  -- TITLE = 3,
  -- TRANSITION = 13,
  -- WIN = 16
-- }
-- Olmec = {
  -- __index = "function: 0000023A40DA6970",
  -- __name = "sol.Olmec.user",
  -- __newindex = "function: 0000023A40DA68C0"
-- }
-- OlmecFloater = {
  -- __index = "function: 0000023A40DA9AF0",
  -- __name = "sol.OlmecFloater.user",
  -- __newindex = "function: 0000023A40DA90A0"
-- }
-- PARTICLEEMITTER = {
  -- ACIDBUBBLEBURST_BUBBLES = 101,
  -- ACIDBUBBLEBURST_SPARKS = 102,
  -- ALIENBLAST_SHOCKWAVE = 178,
  -- ALTAR_MONSTER_APPEAR_POOF = 161,
  -- ALTAR_SKULL = 95,
  -- ALTAR_SMOKE = 96,
  -- ALTAR_SPARKS = 97,
  -- APEP_DUSTWALL = 157,
  -- ARROWPOOF = 67,
  -- AU_GOLD_SPARKLES = 74,
  -- AXOLOTL_BIGBUBBLEKILL = 185,
  -- AXOLOTL_SMALLBUBBLEKILL = 184,
  -- BLAST_PLASMAWARP_TRAIL = 136,
  -- BLOODTRAIL = 64,
  -- BLUESPARKS = 106,
  -- BOMB_SMOKE = 24,
  -- BOOMERANG_TRAIL = 171,
  -- BROKENORB_BLAST_LARGE = 203,
  -- BROKENORB_BLAST_MEDIUM = 202,
  -- BROKENORB_BLAST_SMALL = 201,
  -- BROKENORB_ORBS_LARGE = 209,
  -- BROKENORB_ORBS_MEDIUM = 208,
  -- BROKENORB_ORBS_SMALL = 207,
  -- BROKENORB_SHOCKWAVE_LARGE = 215,
  -- BROKENORB_SHOCKWAVE_MEDIUM = 214,
  -- BROKENORB_SHOCKWAVE_SMALL = 213,
  -- BROKENORB_SPARKS_LARGE = 212,
  -- BROKENORB_SPARKS_MEDIUM = 211,
  -- BROKENORB_SPARKS_SMALL = 210,
  -- BROKENORB_WARP_LARGE = 206,
  -- BROKENORB_WARP_MEDIUM = 205,
  -- BROKENORB_WARP_SMALL = 204,
  -- BULLETPOOF = 66,
  -- CAMERA_FRAME = 105,
  -- CAVEMAN_SPITTLE = 189,
  -- CHARSELECTOR_MIST = 196,
  -- CHARSELECTOR_TORCHFLAME_FLAMES = 8,
  -- CHARSELECTOR_TORCHFLAME_SMOKE = 7,
  -- CLOVER_WITHER_HUD = 78,
  -- COFFINDOORPOOF_SPARKS = 140,
  -- COG_SPARKLE = 80,
  -- COG_TUNNEL_FOG = 81,
  -- COLLECTPOOF_CLOUDS = 99,
  -- COLLECTPOOF_SPARKS = 98,
  -- CONTACTEFFECT_SPARKS = 130,
  -- COOKFIRE_FLAMES = 34,
  -- COOKFIRE_SMOKE = 33,
  -- COOKFIRE_WARP = 35,
  -- CRUSHTRAPPOOF = 58,
  -- CURSEDEFFECT_PIECES = 116,
  -- CURSEDEFFECT_PIECES_HUD = 117,
  -- CURSEDEFFECT_SKULL = 118,
  -- CURSEDPOT_BEHINDSMOKE = 47,
  -- CURSEDPOT_SMOKE = 46,
  -- DMCOUNTDOWN_BLAST = 21,
  -- DMCOUNTDOWN_DUST = 17,
  -- DMCOUNTDOWN_FLAMES = 20,
  -- DMCOUNTDOWN_FOG = 23,
  -- DMCOUNTDOWN_HIGH_TENSION_THUNDERBOLT = 22,
  -- DMCOUNTDOWN_RUBBLES = 15,
  -- DMCOUNTDOWN_RUBBLES_LARGE = 16,
  -- DMCOUNTDOWN_SPARKS = 18,
  -- DMCOUNTDOWN_SPARKS_SMALL = 19,
  -- DMPREMATCH_ASH_2P = 150,
  -- DMPREMATCH_ASH_3P = 151,
  -- DMPREMATCH_ASH_4P = 152,
  -- DMPREMATCH_SEPARATOR_GLOW_TRAIL = 200,
  -- DMRESULTS_ASH = 149,
  -- DMRESULT_BLOOD = 13,
  -- DMRESULT_MEATPIECES = 14,
  -- DM_DEATH_MIST = 177,
  -- DUSTWALL = 156,
  -- EGGSHIP_SMOKE = 43,
  -- ENDINGTREASURE_DUST = 45,
  -- ENDING_TREASURE_HUNDUN_SPARKLE = 73,
  -- ENDING_TREASURE_TIAMAT_SPARKLE = 72,
  -- EVAPORATION_WATER = 143,
  -- EXPLOSION_SHOCKWAVE = 27,
  -- EXPLOSION_SMOKE = 25,
  -- EXPLOSION_SPARKS = 26,
  -- EXPLOSION_WHITESMOKE = 28,
  -- FIREBALL_DESTROYED = 42,
  -- FIREBALL_TRAIL = 41,
  -- FLAMETHROWER_SMOKE = 40,
  -- FLAMETRAIL_FLAMES = 82,
  -- FLAMETRAIL_SMOKE = 83,
  -- FLOORDUST = 48,
  -- FLOORFALLINGDUST_RUBBLE = 50,
  -- FLOORFALLINGDUST_SMOKE = 49,
  -- FLOORPOOF = 52,
  -- FLOORPOOF_BIG = 54,
  -- FLOORPOOF_SMALL = 53,
  -- FLOORPOOF_TRAIL = 59,
  -- FLOORPOOF_TRAIL_BIG = 60,
  -- FLYPOOF = 56,
  -- FROST_BREATH = 197,
  -- GASTRAIL = 141,
  -- GASTRAIL_BIG = 142,
  -- GHOST_FOG = 92,
  -- GHOST_MIST = 90,
  -- GHOST_WARP = 91,
  -- GREENBLOODTRAIL = 65,
  -- GRUB_TRAIL = 173,
  -- HIGH_TENSION_THUNDERBOLT = 190,
  -- HITEFFECT_HALO = 125,
  -- HITEFFECT_RING = 123,
  -- HITEFFECT_SMACK = 124,
  -- HITEFFECT_SPARKS = 119,
  -- HITEFFECT_SPARKS_BIG = 120,
  -- HITEFFECT_STARS_BIG = 122,
  -- HITEFFECT_STARS_SMALL = 121,
  -- HORIZONTALLASERBEAM_SPARKLES = 163,
  -- HORIZONTALLASERBEAM_SPARKLES_END = 165,
  -- HORIZONTALLASERBEAM_SPARKS = 167,
  -- ICECAGE_MIST = 155,
  -- ICECAVES_DIAMONDDUST = 153,
  -- ICEFLOOR_MIST = 154,
  -- ICESPIRETRAIL_SPARKLES = 108,
  -- INKSPIT_BUBBLEBURST = 104,
  -- INKSPIT_TRAIL = 103,
  -- ITEMDUST = 62,
  -- ITEM_CRUSHED_SPARKS = 79,
  -- JETPACK_LITTLEFLAME = 85,
  -- JETPACK_SMOKETRAIL = 84,
  -- KINGUDUST = 169,
  -- KINGUSLIDINGDUST = 170,
  -- LAMASSU_AIMING_SPARKLES = 194,
  -- LAMASSU_SHOT_SPARKLES = 193,
  -- LAMASSU_SHOT_WARP = 192,
  -- LARGEITEMDUST = 63,
  -- LASERBEAM_CONTACT = 168,
  -- LASERBEAM_SPARKLES = 162,
  -- LASERBEAM_SPARKLES_END = 164,
  -- LASERBEAM_SPARKS = 166,
  -- LAVAHEAT = 145,
  -- LAVAPOT_DRIP = 186,
  -- LEVEL_MIST = 191,
  -- LIONTRAP_SPARKLE = 77,
  -- MAGMAMANHEAT = 146,
  -- MAINMENU_CEILINGDUST_RUBBLE = 10,
  -- MAINMENU_CEILINGDUST_RUBBLE_SMALL = 12,
  -- MAINMENU_CEILINGDUST_SMOKE = 9,
  -- MAINMENU_CEILINGDUST_SMOKE_SMALL = 11,
  -- MERCHANT_APPEAR_POOF = 160,
  -- MINIGAME_ASTEROID_DUST = 216,
  -- MINIGAME_ASTEROID_DUST_SMALL = 217,
  -- MINIGAME_BROKENASTEROID_SMOKE = 219,
  -- MINIGAME_UFO_SMOKE = 218,
  -- MOLEFLOORPOOF = 61,
  -- MOUNT_TAMED = 158,
  -- MUSIC_NOTES = 198,
  -- NECROMANCER_SUMMON = 183,
  -- NOHITEFFECT_RING = 128,
  -- NOHITEFFECT_SMACK = 129,
  -- NOHITEFFECT_SPARKS = 126,
  -- NOHITEFFECT_STARS = 127,
  -- OLMECFLOORPOOF = 57,
  -- OLMECSHIP_HOLE_DUST = 44,
  -- ONFIREEFFECT_FLAME = 111,
  -- ONFIREEFFECT_SMOKE = 110,
  -- OUROBORO_EMBERS = 89,
  -- OUROBORO_FALLING_RUBBLE = 51,
  -- OUROBORO_MIST = 88,
  -- PETTING_PET = 159,
  -- PINKSPARKS = 107,
  -- PLAYERGHOST_FREEZESPARKLES = 93,
  -- POISONEDEFFECT_BUBBLES_BASE = 112,
  -- POISONEDEFFECT_BUBBLES_BURST = 113,
  -- POISONEDEFFECT_BUBBLES_HUD = 114,
  -- POISONEDEFFECT_SKULL = 115,
  -- PORTAL_DUST_FAST = 175,
  -- PORTAL_DUST_SLOW = 174,
  -- PORTAL_WARP = 176,
  -- PRIZEAPPEARING_CLOUDS = 100,
  -- SANDFLOORPOOF = 55,
  -- SCEPTERKILL_SPARKLES = 133,
  -- SCEPTERKILL_SPARKS = 134,
  -- SCEPTER_BLAST = 135,
  -- SHOTGUNBLAST_SMOKE = 86,
  -- SHOTGUNBLAST_SPARKS = 87,
  -- SMALLFLAME_FLAMES = 37,
  -- SMALLFLAME_SMOKE = 36,
  -- SMALLFLAME_WARP = 38,
  -- SPARKTRAP_TRAIL = 199,
  -- SPLASH_WATER = 144,
  -- TELEPORTEFFECT_GREENSPARKLES = 138,
  -- TELEPORTEFFECT_REDSPARKLES = 139,
  -- TELEPORTEFFECT_SPARKS = 137,
  -- TIAMAT_SCREAM_WARP = 195,
  -- TITLE_TORCHFLAME_ASH = 6,
  -- TITLE_TORCHFLAME_BACKFLAMES = 2,
  -- TITLE_TORCHFLAME_BACKFLAMES_ANIMATED = 4,
  -- TITLE_TORCHFLAME_FLAMES = 3,
  -- TITLE_TORCHFLAME_FLAMES_ANIMATED = 5,
  -- TITLE_TORCHFLAME_SMOKE = 1,
  -- TOMB_FOG = 94,
  -- TORCHFLAME_FLAMES = 31,
  -- TORCHFLAME_IGNITION_SPARK = 29,
  -- TORCHFLAME_SMOKE = 30,
  -- TORCHFLAME_WARP = 32,
  -- TREASURE_SPARKLE_HIGH = 70,
  -- TREASURE_SPARKLE_HUD = 71,
  -- TREASURE_SPARKLE_LOW = 68,
  -- TREASURE_SPARKLE_MEDIUM = 69,
  -- UFOLASERSHOTHITEFFECT_BIG = 131,
  -- UFOLASERSHOTHITEFFECT_SMALL = 132,
  -- USHABTI_GOLD = 75,
  -- USHABTI_JADE = 76,
  -- VOLCANO_ASH = 148,
  -- VOLCANO_FOG = 147,
  -- WATER_DROP_DESTROYED = 187,
  -- WATER_DROP_DESTROYED_UPWARDS = 188,
  -- WETEFFECT_DROPS = 109,
  -- WHIPFLAME_FLAMES = 39,
  -- WITCHDOCTORSKULL_TRAIL = 172,
  -- YETIKING_YELL_DUST = 180,
  -- YETIKING_YELL_FOG = 179,
  -- YETIKING_YELL_SPARKLES = 181,
  -- YETIQUEEN_LANDING_SNOWDUST = 182
-- }
-- ParticleDB = {
  -- __name = "sol.ParticleDB.user"
-- }
-- Player = {
  -- __index = "function: 0000023A1590A590",
  -- __name = "sol.Player.user",
  -- __newindex = "function: 0000023A1590C3D0"
-- }
-- PlayingSound = {
  -- __name = "sol.PlayingSound.user"
-- }
-- SOUND_LOOP_MODE = {
  -- BIDIRECTIONAL = 2,
  -- LOOP = 1,
  -- OFF = 0
-- }
-- SOUND_TYPE = {
  -- MUSIC = 1,
  -- SFX = 0
-- }
-- SaturationVignette = {
  -- __name = "sol.SaturationVignette.user"
-- }
-- SaveContext = {
  -- __name = "sol.SaveContext.user"
-- }
-- SaveData = {
  -- __name = "sol.SaveData.user"
-- }
-- StateMemory = {
  -- __name = "sol.StateMemory.user"
-- }
-- THEME = {
  -- ABZU = 13,
  -- ARENA = 18,
  -- BASE_CAMP = 17,
  -- CITY_OF_GOLD = 11,
  -- COSMIC_OCEAN = 10,
  -- DUAT = 12,
  -- DWELLING = 1,
  -- EGGPLANT_WORLD = 15,
  -- HUNDUN = 16,
  -- ICE_CAVES = 7,
  -- JUNGLE = 2,
  -- NEO_BABYLON = 8,
  -- OLMEC = 4,
  -- SUNKEN_CITY = 9,
  -- TEMPLE = 6,
  -- TIAMAT = 14,
  -- TIDE_POOL = 5,
  -- VOLCANA = 3
-- }
-- VANILLA_SOUND = {
  -- BGM_BGM_BASECAMP = "BGM/BGM_basecamp",
  -- BGM_BGM_CREDITS = "BGM/BGM_credits",
  -- BGM_BGM_DM = "BGM/BGM_dm",
  -- BGM_BGM_ENDING = "BGM/BGM_ending",
  -- BGM_BGM_MASTER = "BGM/BGM_master",
  -- BGM_BGM_MENU = "BGM/BGM_menu",
  -- BGM_BGM_TITLE = "BGM/BGM_title",
  -- CRITTERS_DRONE_CRASH = "Critters/Drone_crash",
  -- CRITTERS_DRONE_LOOP = "Critters/Drone_loop",
  -- CRITTERS_FIREFLY_FLASH = "Critters/Firefly_flash",
  -- CRITTERS_LOCUST_LOOP = "Critters/Locust_loop",
  -- CRITTERS_PENGUIN_JUMP1 = "Critters/Penguin_jump1",
  -- CRITTERS_PENGUIN_JUMP2 = "Critters/Penguin_jump2",
  -- CRITTERS_SNAIL_ATTACH = "Critters/Snail_attach",
  -- CUTSCENE_ANKH_CRACK = "Cutscene/Ankh_crack",
  -- CUTSCENE_ANKH_LOOP = "Cutscene/Ankh_loop",
  -- CUTSCENE_ANKH_PULSE = "Cutscene/Ankh_pulse",
  -- CUTSCENE_ANKH_SHATTER = "Cutscene/Ankh_shatter",
  -- CUTSCENE_BIG_TREASURE_LAND = "Cutscene/Big_treasure_land",
  -- CUTSCENE_BIG_TREASURE_OPEN = "Cutscene/Big_treasure_open",
  -- CUTSCENE_CAVE_RUMBLE = "Cutscene/Cave_rumble",
  -- CUTSCENE_CONSTELLATION_LOOP = "Cutscene/Constellation_loop",
  -- CUTSCENE_CREDITS_ASTEROID = "Cutscene/Credits_asteroid",
  -- CUTSCENE_CREDITS_THRUSTER_LOOP = "Cutscene/Credits_thruster_loop",
  -- CUTSCENE_CREDITS_UFO_BONK = "Cutscene/Credits_ufo_bonk",
  -- CUTSCENE_EGGSHIP_AMB_LOOP = "Cutscene/Eggship_amb_loop",
  -- CUTSCENE_EGGSHIP_DOOR = "Cutscene/Eggship_door",
  -- CUTSCENE_EGGSHIP_EMERGE = "Cutscene/Eggship_emerge",
  -- CUTSCENE_EGGSHIP_LAND = "Cutscene/Eggship_land",
  -- CUTSCENE_EGGSHIP_LOOP = "Cutscene/Eggship_loop",
  -- CUTSCENE_EGGSHIP_THRUSTER_LOOP = "Cutscene/Eggship_thruster_loop",
  -- CUTSCENE_JOURNAL_PAGE = "Cutscene/Journal_page",
  -- CUTSCENE_KEY_DROP = "Cutscene/Key_drop",
  -- CUTSCENE_MENU_INTRO_LOOP = "Cutscene/Menu_intro_loop",
  -- CUTSCENE_OUROBOROS_DOOR_LOOP = "Cutscene/Ouroboros_door_loop",
  -- CUTSCENE_OUROBOROS_LOOP = "Cutscene/Ouroboros_loop",
  -- CUTSCENE_OUROBOROS_SHAKE = "Cutscene/Ouroboros_shake",
  -- CUTSCENE_RUMBLE_LOOP = "Cutscene/Rumble_loop",
  -- DEATHMATCH_DM_BANNER = "Deathmatch/dm_banner",
  -- DEATHMATCH_DM_COUNTDOWN = "Deathmatch/dm_countdown",
  -- DEATHMATCH_DM_ITEM_SPAWN = "Deathmatch/dm_item_spawn",
  -- DEATHMATCH_DM_ITEM_WARN = "Deathmatch/dm_item_warn",
  -- DEATHMATCH_DM_PILLAR_CRUSH = "Deathmatch/dm_pillar_crush",
  -- DEATHMATCH_DM_PILLAR_LOOP = "Deathmatch/dm_pillar_loop",
  -- DEATHMATCH_DM_SCORE = "Deathmatch/dm_score",
  -- DEATHMATCH_DM_SPLASH = "Deathmatch/dm_splash",
  -- DEATHMATCH_DM_TIMER = "Deathmatch/dm_timer",
  -- DEFAULT_SOUND = "default_sound",
  -- ENEMIES_ALIEN_JUMP = "Enemies/Alien_jump",
  -- ENEMIES_ALIEN_QUEEN_LOOP = "Enemies/Alien_queen_loop",
  -- ENEMIES_ALIEN_QUEEN_SHOT = "Enemies/Alien_queen_shot",
  -- ENEMIES_ALIEN_QUEEN_SIGHT_LOOP = "Enemies/Alien_queen_sight_loop",
  -- ENEMIES_ALIEN_SPEECH = "Enemies/Alien_speech",
  -- ENEMIES_AMMIT_WALK = "Enemies/Ammit_walk",
  -- ENEMIES_ANUBIS_ACTIVATE = "Enemies/Anubis_activate",
  -- ENEMIES_ANUBIS_ATK = "Enemies/Anubis_atk",
  -- ENEMIES_ANUBIS_SPECIAL_SHOT = "Enemies/Anubis_special_shot",
  -- ENEMIES_ANUBIS_WARN = "Enemies/Anubis_warn",
  -- ENEMIES_APEP_BODY_LOOP = "Enemies/Apep_body_loop",
  -- ENEMIES_APEP_HEAD_LOOP = "Enemies/Apep_head_loop",
  -- ENEMIES_BAT_FLAP = "Enemies/Bat_flap",
  -- ENEMIES_BEE_LOOP = "Enemies/Bee_loop",
  -- ENEMIES_BEE_QUEEN_LOOP = "Enemies/Bee_queen_loop",
  -- ENEMIES_BOSS_CAVEMAN_BONK = "Enemies/Boss_caveman_bonk",
  -- ENEMIES_BOSS_CAVEMAN_CRUSH = "Enemies/Boss_caveman_crush",
  -- ENEMIES_BOSS_CAVEMAN_JUMP = "Enemies/Boss_caveman_jump",
  -- ENEMIES_BOSS_CAVEMAN_LAND = "Enemies/Boss_caveman_land",
  -- ENEMIES_BOSS_CAVEMAN_ROLL_LOOP = "Enemies/Boss_caveman_roll_loop",
  -- ENEMIES_BOSS_CAVEMAN_STEP = "Enemies/Boss_caveman_step",
  -- ENEMIES_BOSS_CAVEMAN_STOMP = "Enemies/Boss_caveman_stomp",
  -- ENEMIES_CATMUMMY_ATK = "Enemies/Catmummy_atk",
  -- ENEMIES_CATMUMMY_JUMP = "Enemies/Catmummy_jump",
  -- ENEMIES_CATMUMMY_RUN = "Enemies/Catmummy_run",
  -- ENEMIES_CAVEMAN_PRAY_LOOP = "Enemies/Caveman_pray_loop",
  -- ENEMIES_CAVEMAN_STEP = "Enemies/Caveman_step",
  -- ENEMIES_CAVEMAN_TALK = "Enemies/Caveman_talk",
  -- ENEMIES_CAVEMAN_TRIGGER = "Enemies/Caveman_trigger",
  -- ENEMIES_COBRA_ATK = "Enemies/Cobra_atk",
  -- ENEMIES_CROCMAN_ATK = "Enemies/Crocman_atk",
  -- ENEMIES_CROCMAN_TRIGGER = "Enemies/Crocman_trigger",
  -- ENEMIES_EGGPLANT_DOG_BOUNCE = "Enemies/Eggplant_dog_bounce",
  -- ENEMIES_EGGPLANT_MINISTER_LOOP = "Enemies/Eggplant_minister_loop",
  -- ENEMIES_EGGPLANT_MINISTER_MORPH = "Enemies/Eggplant_minister_morph",
  -- ENEMIES_EGGSAC_BURST = "Enemies/Eggsac_burst",
  -- ENEMIES_EGGSAC_WARN = "Enemies/Eggsac_warn",
  -- ENEMIES_ENEMY_HIT_INVINCIBLE = "Enemies/Enemy_hit_invincible",
  -- ENEMIES_FIREBUG_ARM = "Enemies/Firebug_arm",
  -- ENEMIES_FIREBUG_ATK_LOOP = "Enemies/Firebug_atk_loop",
  -- ENEMIES_FIREBUG_FLY_LOOP = "Enemies/Firebug_fly_loop",
  -- ENEMIES_FLYINGFISH_BONK = "Enemies/Flyingfish_bonk",
  -- ENEMIES_FLYINGFISH_FLAP = "Enemies/Flyingfish_flap",
  -- ENEMIES_FLYINGFISH_WIGGLE = "Enemies/Flyingfish_wiggle",
  -- ENEMIES_FROG_CHARGE_LOOP = "Enemies/Frog_charge_loop",
  -- ENEMIES_FROG_EAT = "Enemies/Frog_eat",
  -- ENEMIES_FROG_GIANT_OPEN = "Enemies/Frog_giant_open",
  -- ENEMIES_FROG_JUMP = "Enemies/Frog_jump",
  -- ENEMIES_GHIST_LOOP = "Enemies/Ghist_loop",
  -- ENEMIES_GHOST_LOOP = "Enemies/Ghost_loop",
  -- ENEMIES_GHOST_SPLIT = "Enemies/Ghost_split",
  -- ENEMIES_GIANT_FLY_EAT = "Enemies/Giant_fly_eat",
  -- ENEMIES_GIANT_FLY_LOOP = "Enemies/Giant_fly_loop",
  -- ENEMIES_GIANT_SPIDER_DROP = "Enemies/Giant_spider_drop",
  -- ENEMIES_GIANT_SPIDER_JUMP = "Enemies/Giant_spider_jump",
  -- ENEMIES_GIANT_SPIDER_WALK = "Enemies/Giant_spider_walk",
  -- ENEMIES_GOLD_MONKEY_JUMP = "Enemies/Gold_monkey_jump",
  -- ENEMIES_GOLD_MONKEY_POOP = "Enemies/Gold_monkey_poop",
  -- ENEMIES_GRUB_EVOLVE = "Enemies/Grub_evolve",
  -- ENEMIES_GRUB_JUMP = "Enemies/Grub_jump",
  -- ENEMIES_GRUB_LOOP = "Enemies/Grub_loop",
  -- ENEMIES_HANGSPIDER_ATK = "Enemies/Hangspider_atk",
  -- ENEMIES_HERMITCRAB_ATK = "Enemies/Hermitcrab_atk",
  -- ENEMIES_HERMITCRAB_MORPH = "Enemies/Hermitcrab_morph",
  -- ENEMIES_HUMPHEAD_LOOP = "Enemies/Humphead_loop",
  -- ENEMIES_HUNDUN_ATK = "Enemies/Hundun_atk",
  -- ENEMIES_HUNDUN_DEATH_LAND = "Enemies/Hundun_death_land",
  -- ENEMIES_HUNDUN_HEAD_DESTROY = "Enemies/Hundun_head_destroy",
  -- ENEMIES_HUNDUN_HEAD_EMERGE = "Enemies/Hundun_head_emerge",
  -- ENEMIES_HUNDUN_HURT = "Enemies/Hundun_hurt",
  -- ENEMIES_HUNDUN_STEP = "Enemies/Hundun_step",
  -- ENEMIES_HUNDUN_WARN = "Enemies/Hundun_warn",
  -- ENEMIES_HUNDUN_WINGS_EMERGE = "Enemies/Hundun_wings_emerge",
  -- ENEMIES_HUNDUN_WING_FLAP = "Enemies/Hundun_wing_flap",
  -- ENEMIES_IMP_DROP = "Enemies/Imp_drop",
  -- ENEMIES_IMP_FLAP = "Enemies/Imp_flap",
  -- ENEMIES_JELLYFISH_LOOP = "Enemies/Jellyfish_loop",
  -- ENEMIES_JIANGSHI_CHARGE = "Enemies/Jiangshi_charge",
  -- ENEMIES_JIANGSHI_FEMALE_JUMP = "Enemies/Jiangshi_female_jump",
  -- ENEMIES_JIANGSHI_FLIP = "Enemies/Jiangshi_flip",
  -- ENEMIES_JIANGSHI_JUMP = "Enemies/Jiangshi_jump",
  -- ENEMIES_KILLED_ENEMY = "Enemies/Killed_enemy",
  -- ENEMIES_KILLED_ENEMY_BONES = "Enemies/Killed_enemy_bones",
  -- ENEMIES_KILLED_ENEMY_CORPSE = "Enemies/Killed_enemy_corpse",
  -- ENEMIES_KINGU_GRIP = "Enemies/Kingu_grip",
  -- ENEMIES_KINGU_HURT = "Enemies/Kingu_hurt",
  -- ENEMIES_KINGU_SLIDE_LOOP = "Enemies/Kingu_slide_loop",
  -- ENEMIES_LAMASSU_AIM_LOCK = "Enemies/Lamassu_aim_lock",
  -- ENEMIES_LAMASSU_AIM_LOOP = "Enemies/Lamassu_aim_loop",
  -- ENEMIES_LAMASSU_ATK_HIT = "Enemies/Lamassu_atk_hit",
  -- ENEMIES_LAMASSU_ATK_LOOP = "Enemies/Lamassu_atk_loop",
  -- ENEMIES_LAMASSU_FLY = "Enemies/Lamassu_fly",
  -- ENEMIES_LAMASSU_WALK = "Enemies/Lamassu_walk",
  -- ENEMIES_LAVAMANDER_ATK = "Enemies/Lavamander_atk",
  -- ENEMIES_LAVAMANDER_CHARGE = "Enemies/Lavamander_charge",
  -- ENEMIES_LAVAMANDER_JUMP = "Enemies/Lavamander_jump",
  -- ENEMIES_LAVAMANDER_TRANSFORM = "Enemies/Lavamander_transform",
  -- ENEMIES_LEPRECHAUN_JUMP = "Enemies/Leprechaun_jump",
  -- ENEMIES_LEPRECHAUN_LOOP = "Enemies/Leprechaun_loop",
  -- ENEMIES_LEPRECHAUN_STEAL_LOOP = "Enemies/Leprechaun_steal_loop",
  -- ENEMIES_LIZARD_BONK = "Enemies/Lizard_bonk",
  -- ENEMIES_LIZARD_CURL_LOOP = "Enemies/Lizard_curl_loop",
  -- ENEMIES_LIZARD_JUMP = "Enemies/Lizard_jump",
  -- ENEMIES_LIZARD_UNROLL = "Enemies/Lizard_unroll",
  -- ENEMIES_MAGMAMAN_JUMP = "Enemies/Magmaman_jump",
  -- ENEMIES_MAGMAMAN_TRANSFORM = "Enemies/Magmaman_transform",
  -- ENEMIES_MANTRAP_BITE = "Enemies/Mantrap_bite",
  -- ENEMIES_MOLERAT_DIG_LOOP = "Enemies/Molerat_dig_loop",
  -- ENEMIES_MOLERAT_RUN_LOOP = "Enemies/Molerat_run_loop",
  -- ENEMIES_MONKEY_JUMP = "Enemies/Monkey_jump",
  -- ENEMIES_MONKEY_STEAL_END = "Enemies/Monkey_steal_end",
  -- ENEMIES_MONKEY_STEAL_LOOP = "Enemies/Monkey_steal_loop",
  -- ENEMIES_MOSQUITO_LOOP = "Enemies/Mosquito_loop",
  -- ENEMIES_MOSQUITO_PIERCE = "Enemies/Mosquito_pierce",
  -- ENEMIES_MUMMY_FLIES_LOOP = "Enemies/Mummy_flies_loop",
  -- ENEMIES_MUMMY_STEP = "Enemies/Mummy_step",
  -- ENEMIES_MUMMY_VOMIT = "Enemies/Mummy_vomit",
  -- ENEMIES_NECROMANCER_CHARGE_LOOP = "Enemies/Necromancer_charge_loop",
  -- ENEMIES_NECROMANCER_SPAWN = "Enemies/Necromancer_spawn",
  -- ENEMIES_OCTOPUS_ATK = "Enemies/Octopus_atk",
  -- ENEMIES_OCTOPUS_BONK = "Enemies/Octopus_bonk",
  -- ENEMIES_OCTOPUS_JUMP = "Enemies/Octopus_jump",
  -- ENEMIES_OCTOPUS_WALK = "Enemies/Octopus_walk",
  -- ENEMIES_OLMEC_BOMB_SPAWN = "Enemies/Olmec_bomb_spawn",
  -- ENEMIES_OLMEC_CRUSH = "Enemies/Olmec_crush",
  -- ENEMIES_OLMEC_HOVER_LOOP = "Enemies/Olmec_hover_loop",
  -- ENEMIES_OLMEC_PAD_BREAK = "Enemies/Olmec_pad_break",
  -- ENEMIES_OLMEC_PAD_SHOW = "Enemies/Olmec_pad_show",
  -- ENEMIES_OLMEC_SPLASH = "Enemies/Olmec_splash",
  -- ENEMIES_OLMEC_STOMP = "Enemies/Olmec_stomp",
  -- ENEMIES_OLMEC_TRANSFORM_CLOSE = "Enemies/Olmec_transform_close",
  -- ENEMIES_OLMEC_TRANSFORM_OPEN = "Enemies/Olmec_transform_open",
  -- ENEMIES_OLMEC_UFO_SPAWN = "Enemies/Olmec_ufo_spawn",
  -- ENEMIES_OLMEC_UNCOVER = "Enemies/Olmec_uncover",
  -- ENEMIES_OLMITE_ARMOR_BREAK = "Enemies/Olmite_armor_break",
  -- ENEMIES_OLMITE_JUMP = "Enemies/Olmite_jump",
  -- ENEMIES_OLMITE_STOMP = "Enemies/Olmite_stomp",
  -- ENEMIES_OSIRIS_APPEAR = "Enemies/Osiris_appear",
  -- ENEMIES_OSIRIS_PUNCH = "Enemies/Osiris_punch",
  -- ENEMIES_PANGXIE_BUBBLE_ATK = "Enemies/Pangxie_bubble_atk",
  -- ENEMIES_PANGXIE_PUNCH1 = "Enemies/Pangxie_punch1",
  -- ENEMIES_PANGXIE_PUNCH2 = "Enemies/Pangxie_punch2",
  -- ENEMIES_PROTO_BURST_LOOP = "Enemies/Proto_burst_loop",
  -- ENEMIES_PROTO_CRAWL = "Enemies/Proto_crawl",
  -- ENEMIES_ROBOT_LOOP = "Enemies/Robot_loop",
  -- ENEMIES_ROBOT_TRIGGER = "Enemies/Robot_trigger",
  -- ENEMIES_SCORPION_ATK = "Enemies/Scorpion_atk",
  -- ENEMIES_SKELETON_COLLAPSE = "Enemies/Skeleton_collapse",
  -- ENEMIES_SKELETON_MATERIALIZE = "Enemies/Skeleton_materialize",
  -- ENEMIES_SNAKE_ATK = "Enemies/Snake_atk",
  -- ENEMIES_SORCERESS_ATK = "Enemies/Sorceress_atk",
  -- ENEMIES_SORCERESS_ATK_SPAWN = "Enemies/Sorceress_atk_spawn",
  -- ENEMIES_SORCERESS_CHARGE_LOOP = "Enemies/Sorceress_charge_loop",
  -- ENEMIES_SORCERESS_JUMP = "Enemies/Sorceress_jump",
  -- ENEMIES_SPIDER_JUMP = "Enemies/Spider_jump",
  -- ENEMIES_SPIDER_TRIGGER = "Enemies/Spider_trigger",
  -- ENEMIES_STONE_TRANSFORM_LOOP = "Enemies/Stone_transform_loop",
  -- ENEMIES_STORAGE_KEEPER_DIE = "Enemies/Storage_keeper_die",
  -- ENEMIES_STORAGE_KEEPER_JUMP = "Enemies/Storage_keeper_jump",
  -- ENEMIES_TADPOLE_SWIM = "Enemies/Tadpole_swim",
  -- ENEMIES_TIAMAT_HURT = "Enemies/Tiamat_hurt",
  -- ENEMIES_TIAMAT_ORB_LOOP = "Enemies/Tiamat_orb_loop",
  -- ENEMIES_TIAMAT_SCEPTER = "Enemies/Tiamat_scepter",
  -- ENEMIES_TIAMAT_SCREAM1 = "Enemies/Tiamat_scream1",
  -- ENEMIES_TIAMAT_SCREAM2 = "Enemies/Tiamat_scream2",
  -- ENEMIES_TIKIMAN_TALK = "Enemies/Tikiman_talk",
  -- ENEMIES_UFO_ATK_END = "Enemies/UFO_atk_end",
  -- ENEMIES_UFO_ATK_LOOP = "Enemies/UFO_atk_loop",
  -- ENEMIES_UFO_CHARGE = "Enemies/UFO_charge",
  -- ENEMIES_UFO_DAMAGE = "Enemies/UFO_damage",
  -- ENEMIES_UFO_EJECT = "Enemies/UFO_eject",
  -- ENEMIES_UFO_LOOP = "Enemies/UFO_loop",
  -- ENEMIES_VAMPIRE_JUMP = "Enemies/Vampire_jump",
  -- ENEMIES_VLAD_TRIGGER = "Enemies/Vlad_trigger",
  -- ENEMIES_WITCHDOCTOR_CHANT_LOOP = "Enemies/Witchdoctor_chant_loop",
  -- ENEMIES_WITCHDOCTOR_STAB = "Enemies/Witchdoctor_stab",
  -- ENEMIES_WITCHDOCTOR_TALK = "Enemies/Witchdoctor_talk",
  -- ENEMIES_WITCHDOCTOR_TRIGGER = "Enemies/Witchdoctor_trigger",
  -- ENEMIES_YETI_BIG_CHARGE = "Enemies/Yeti_big_charge",
  -- ENEMIES_YETI_BIG_PUNCH = "Enemies/Yeti_big_punch",
  -- ENEMIES_YETI_BIG_STEP = "Enemies/Yeti_big_step",
  -- ENEMIES_YETI_KING_ROAR = "Enemies/Yeti_king_roar",
  -- ENEMIES_YETI_QUEEN_JUMP = "Enemies/Yeti_queen_jump",
  -- ENEMIES_YETI_QUEEN_SLAM = "Enemies/Yeti_queen_slam",
  -- FX_FX_ANUBIS_WARN = "FX/FX_anubis_warn",
  -- FX_FX_COSMIC_ORB = "FX/FX_cosmic_orb",
  -- FX_FX_CURSE = "FX/FX_curse",
  -- FX_FX_DM_BANNER = "FX/FX_dm_banner",
  -- FX_FX_JOURNAL_ENTRY = "FX/FX_journal_entry",
  -- FX_FX_JOURNAL_PAGE = "FX/FX_journal_page",
  -- ITEMS_ARROW_STICK = "Items/Arrow_stick",
  -- ITEMS_BACKPACK_WARN = "Items/Backpack_warn",
  -- ITEMS_BOMB_BIG_TIMER = "Items/Bomb_big_timer",
  -- ITEMS_BOMB_STICK = "Items/Bomb_stick",
  -- ITEMS_BOMB_TIMER = "Items/Bomb_timer",
  -- ITEMS_BOOMBOX_OFF = "Items/Boombox_off",
  -- ITEMS_BOOMERANG_CATCH = "Items/Boomerang_catch",
  -- ITEMS_BOOMERANG_LOOP = "Items/Boomerang_loop",
  -- ITEMS_BOW = "Items/Bow",
  -- ITEMS_BOW_RELOAD = "Items/Bow_reload",
  -- ITEMS_CAMERA = "Items/Camera",
  -- ITEMS_CAPE_LOOP = "Items/Cape_loop",
  -- ITEMS_CAPE_VLAD_FLAP = "Items/Cape_vlad_flap",
  -- ITEMS_CLONE_GUN = "Items/Clone_gun",
  -- ITEMS_COIN_BOUNCE = "Items/Coin_bounce",
  -- ITEMS_CROSSBOW = "Items/Crossbow",
  -- ITEMS_CROSSBOW_RELOAD = "Items/Crossbow_reload",
  -- ITEMS_DAMSEL_CALL = "Items/Damsel_call",
  -- ITEMS_DAMSEL_PET = "Items/Damsel_pet",
  -- ITEMS_EXCALIBUR = "Items/Excalibur",
  -- ITEMS_FREEZE_RAY = "Items/Freeze_ray",
  -- ITEMS_FREEZE_RAY_HIT = "Items/Freeze_ray_hit",
  -- ITEMS_HOVERPACK_LOOP = "Items/Hoverpack_loop",
  -- ITEMS_JETPACK_END = "Items/Jetpack_end",
  -- ITEMS_JETPACK_IGNITE = "Items/Jetpack_ignite",
  -- ITEMS_JETPACK_LOOP = "Items/Jetpack_loop",
  -- ITEMS_MACHETE = "Items/Machete",
  -- ITEMS_MATTOCK_BREAK = "Items/Mattock_break",
  -- ITEMS_MATTOCK_HIT = "Items/Mattock_hit",
  -- ITEMS_MATTOCK_SWING = "Items/Mattock_swing",
  -- ITEMS_PARACHUTE = "Items/Parachute",
  -- ITEMS_PLASMA_CANNON = "Items/Plasma_cannon",
  -- ITEMS_PLASMA_CANNON_CHARGE = "Items/Plasma_cannon_charge",
  -- ITEMS_ROPE_ATTACH = "Items/Rope_attach",
  -- ITEMS_ROPE_BURN_LOOP = "Items/Rope_burn_loop",
  -- ITEMS_SCEPTER = "Items/Scepter",
  -- ITEMS_SHOTGUN_FIRE = "Items/Shotgun_fire",
  -- ITEMS_SPRING_SHOES = "Items/Spring_shoes",
  -- ITEMS_TV_LOOP = "Items/TV_loop",
  -- ITEMS_UDJAT_BLINK = "Items/Udjat_blink",
  -- ITEMS_USHABTI_RATTLE = "Items/Ushabti_rattle",
  -- ITEMS_WEBGUN = "Items/Webgun",
  -- ITEMS_WEBGUN_HIT = "Items/Webgun_hit",
  -- ITEMS_WITCHDOCTORSKULL_LOOP = "Items/Witchdoctorskull_loop",
  -- ITEMS_WOODEN_SHIELD_BREAK = "Items/Wooden_shield_break",
  -- ITEMS_WOODEN_SHIELD_DAMAGE = "Items/Wooden_shield_damage",
  -- LIQUIDS_LAVA_STATIC_LOOP = "Liquids/Lava_static_loop",
  -- LIQUIDS_LAVA_STREAM_LOOP = "Liquids/Lava_stream_loop",
  -- LIQUIDS_WATER_REV_STREAM_LOOP = "Liquids/Water_rev_stream_loop",
  -- LIQUIDS_WATER_SPLASH = "Liquids/Water_splash",
  -- LIQUIDS_WATER_STREAM_LOOP = "Liquids/Water_stream_loop",
  -- MENU_CANCEL = "Menu/Cancel",
  -- MENU_CHARSEL_DESELECTION = "Menu/Charsel_deselection",
  -- MENU_CHARSEL_DOOR = "Menu/Charsel_door",
  -- MENU_CHARSEL_NAVI = "Menu/Charsel_navi",
  -- MENU_CHARSEL_QUICK_NAVI = "Menu/Charsel_quick_navi",
  -- MENU_CHARSEL_QUICK_NOPE = "Menu/Charsel_quick_nope",
  -- MENU_CHARSEL_QUICK_OPEN = "Menu/Charsel_quick_open",
  -- MENU_CHARSEL_SCROLL = "Menu/Charsel_scroll",
  -- MENU_CHARSEL_SELECTION = "Menu/Charsel_selection",
  -- MENU_CHARSEL_SELECTION2 = "Menu/Charsel_selection2",
  -- MENU_DIRT_FALL = "Menu/Dirt_fall",
  -- MENU_JOURNAL_STICKER = "Menu/Journal_sticker",
  -- MENU_MM_BAR = "Menu/MM_bar",
  -- MENU_MM_NAVI = "Menu/MM_navi",
  -- MENU_MM_OPTIONS_SUB = "Menu/MM_options_sub",
  -- MENU_MM_RESET = "Menu/MM_reset",
  -- MENU_MM_SELECTION = "Menu/MM_selection",
  -- MENU_MM_SET = "Menu/MM_set",
  -- MENU_MM_TOGGLE = "Menu/MM_toggle",
  -- MENU_NAVI = "Menu/Navi",
  -- MENU_PAGE_RETURN = "Menu/Page_return",
  -- MENU_PAGE_TURN = "Menu/Page_turn",
  -- MENU_SELECTION = "Menu/Selection",
  -- MENU_TITLE_SELECTION = "Menu/Title_selection",
  -- MENU_TITLE_TORCH_LOOP = "Menu/Title_torch_loop",
  -- MENU_ZOOM_IN = "Menu/Zoom_in",
  -- MENU_ZOOM_OUT = "Menu/Zoom_out",
  -- MOUNTS_AXOLOTL_ATK = "Mounts/Axolotl_atk",
  -- MOUNTS_AXOLOTL_ATK_HIT = "Mounts/Axolotl_atk_hit",
  -- MOUNTS_AXOLOTL_JUMP1 = "Mounts/Axolotl_jump1",
  -- MOUNTS_AXOLOTL_JUMP2 = "Mounts/Axolotl_jump2",
  -- MOUNTS_AXOLOTL_UNTAMED_LOOP = "Mounts/Axolotl_untamed_loop",
  -- MOUNTS_AXOLOTL_WALK = "Mounts/Axolotl_walk",
  -- MOUNTS_MECH_DRIVE_LOOP = "Mounts/Mech_drive_loop",
  -- MOUNTS_MECH_JUMP = "Mounts/Mech_jump",
  -- MOUNTS_MECH_PUNCH1 = "Mounts/Mech_punch1",
  -- MOUNTS_MECH_SMASH = "Mounts/Mech_smash",
  -- MOUNTS_MECH_SPARK = "Mounts/Mech_spark",
  -- MOUNTS_MECH_TRANSFORM = "Mounts/Mech_transform",
  -- MOUNTS_MECH_TURN = "Mounts/Mech_turn",
  -- MOUNTS_MECH_WALK1 = "Mounts/Mech_walk1",
  -- MOUNTS_MECH_WALK2 = "Mounts/Mech_walk2",
  -- MOUNTS_MECH_WARN = "Mounts/Mech_warn",
  -- MOUNTS_MOUNT = "Mounts/Mount",
  -- MOUNTS_MOUNT_LAND = "Mounts/Mount_land",
  -- MOUNTS_MOUNT_TAME = "Mounts/Mount_tame",
  -- MOUNTS_QILIN_FLY_LOOP = "Mounts/Qilin_fly_loop",
  -- MOUNTS_QILIN_HATCH = "Mounts/Qilin_hatch",
  -- MOUNTS_QILIN_JUMP1 = "Mounts/Qilin_jump1",
  -- MOUNTS_QILIN_JUMP2 = "Mounts/Qilin_jump2",
  -- MOUNTS_QILIN_WALK = "Mounts/Qilin_walk",
  -- MOUNTS_TURKEY_ATK = "Mounts/Turkey_atk",
  -- MOUNTS_TURKEY_FLAP = "Mounts/Turkey_flap",
  -- MOUNTS_TURKEY_JUMP = "Mounts/Turkey_jump",
  -- MOUNTS_TURKEY_UNTAMED_LOOP = "Mounts/Turkey_untamed_loop",
  -- MOUNTS_TURKEY_WALK = "Mounts/Turkey_walk",
  -- MOUNTS_WILDDOG_FIREBALL_LOOP = "Mounts/Wilddog_fireball_loop",
  -- MOUNTS_WILDDOG_JUMP1 = "Mounts/Wilddog_jump1",
  -- MOUNTS_WILDDOG_JUMP2 = "Mounts/Wilddog_jump2",
  -- MOUNTS_WILDDOG_UNTAMED_LOOP = "Mounts/Wilddog_untamed_loop",
  -- MOUNTS_WILDDOG_WALK = "Mounts/Wilddog_walk",
  -- PLAYER_DEATH_GHOST = "Player/Death_ghost",
  -- PLAYER_ENTER_DOOR = "Player/Enter_door",
  -- PLAYER_EQUIP = "Player/Equip",
  -- PLAYER_GRAB_LEDGE = "Player/Grab_ledge",
  -- PLAYER_INKED = "Player/Inked",
  -- PLAYER_JUMP = "Player/Jump",
  -- PLAYER_LAND_CHAIN = "Player/Land_chain",
  -- PLAYER_LISE_DRIVE_LOOP = "Player/LISE_drive_loop",
  -- PLAYER_LISE_LOADING_LOOP = "Player/LISE_loading_loop",
  -- PLAYER_LISE_PUSH_LOOP = "Player/LISE_push_loop",
  -- PLAYER_LISE_RADAR_LOOP = "Player/LISE_radar_loop",
  -- PLAYER_LISE_WARNING = "Player/LISE_warning",
  -- PLAYER_NO_ITEM = "Player/No_item",
  -- PLAYER_PGHOST_ATK = "Player/Pghost_atk",
  -- PLAYER_PGHOST_CHARGE_LOOP = "Player/Pghost_charge_loop",
  -- PLAYER_PGHOST_DASH = "Player/Pghost_dash",
  -- PLAYER_PGHOST_SHAKE = "Player/Pghost_shake",
  -- PLAYER_PGHOST_SPAWN = "Player/Pghost_spawn",
  -- PLAYER_PGHOST_SPIN = "Player/Pghost_spin",
  -- PLAYER_PUSH_BLOCK_LOOP = "Player/Push_block_loop",
  -- PLAYER_TOSS_ROPE = "Player/Toss_rope",
  -- PLAYER_WHIP1 = "Player/Whip1",
  -- PLAYER_WHIP2 = "Player/Whip2",
  -- PLAYER_WHIP_JUMP = "Player/Whip_jump",
  -- SHARED_ANGER = "Shared/Anger",
  -- SHARED_BLOCK_LAND = "Shared/Block_land",
  -- SHARED_BLOOD_SPLURT = "Shared/Blood_splurt",
  -- SHARED_BUBBLE_BONK = "Shared/Bubble_bonk",
  -- SHARED_BUBBLE_BURST = "Shared/Bubble_burst",
  -- SHARED_BUBBLE_BURST_BIG = "Shared/Bubble_burst_big",
  -- SHARED_CEILING_CRUMBLE = "Shared/Ceiling_crumble",
  -- SHARED_CLIMB = "Shared/Climb",
  -- SHARED_COFFIN_BREAK = "Shared/Coffin_break",
  -- SHARED_COFFIN_RATTLE = "Shared/Coffin_rattle",
  -- SHARED_COLLISION_SURFACE = "Shared/Collision_surface",
  -- SHARED_COSMIC_ORB_DESTROY = "Shared/Cosmic_orb_destroy",
  -- SHARED_COSMIC_ORB_LOOP = "Shared/Cosmic_orb_loop",
  -- SHARED_CURSED_LOOP = "Shared/Cursed_loop",
  -- SHARED_CURSE_GET = "Shared/Curse_get",
  -- SHARED_DAMAGED = "Shared/Damaged",
  -- SHARED_DAMAGED_FIRE = "Shared/Damaged_fire",
  -- SHARED_DAMAGED_POISON = "Shared/Damaged_poison",
  -- SHARED_DARK_LEVEL_START = "Shared/Dark_level_start",
  -- SHARED_DESTRUCTIBLE_BREAK = "Shared/Destructible_break",
  -- SHARED_DOOR_AMB_LOOP = "Shared/Door_amb_loop",
  -- SHARED_DOOR_UNLOCK = "Shared/Door_unlock",
  -- SHARED_DROP = "Shared/Drop",
  -- SHARED_EXPLOSION = "Shared/Explosion",
  -- SHARED_EXPLOSION_MODERN = "Shared/Explosion_modern",
  -- SHARED_FIRE_IGNITE = "Shared/Fire_ignite",
  -- SHARED_FIRE_LOOP = "Shared/Fire_loop",
  -- SHARED_GRAB_CLIMBABLE = "Shared/Grab_climbable",
  -- SHARED_HH_ANGER = "Shared/HH_anger",
  -- SHARED_HH_OBEY = "Shared/HH_obey",
  -- SHARED_HUMANOID_JUMP = "Shared/Humanoid_jump",
  -- SHARED_ICE_BREAK = "Shared/Ice_break",
  -- SHARED_ICE_SLIDE_LOOP = "Shared/Ice_slide_loop",
  -- SHARED_IMPALED = "Shared/Impaled",
  -- SHARED_LAND = "Shared/Land",
  -- SHARED_LANTERN_BREAK = "Shared/Lantern_break",
  -- SHARED_NEON_SIGN_LOOP = "Shared/Neon_sign_loop",
  -- SHARED_OPEN_CHEST = "Shared/Open_chest",
  -- SHARED_OPEN_CRATE = "Shared/Open_crate",
  -- SHARED_PICK_UP = "Shared/Pick_up",
  -- SHARED_POISON_WARN = "Shared/Poison_warn",
  -- SHARED_PORTAL_LOOP = "Shared/Portal_loop",
  -- SHARED_RICOCHET = "Shared/Ricochet",
  -- SHARED_RUBBLE_BREAK = "Shared/Rubble_break",
  -- SHARED_SACRIFICE = "Shared/Sacrifice",
  -- SHARED_SACRIFICE_EGGPLANT = "Shared/Sacrifice_eggplant",
  -- SHARED_SCARAB_LOOP = "Shared/Scarab_loop",
  -- SHARED_SLEEP_BUBBLE = "Shared/Sleep_bubble",
  -- SHARED_SMOKE_TELEPORT = "Shared/Smoke_teleport",
  -- SHARED_STORAGE_PAD_ACTIVATE = "Shared/Storage_pad_activate",
  -- SHARED_STUNNED_WAKE = "Shared/Stunned_wake",
  -- SHARED_TELEPORT = "Shared/Teleport",
  -- SHARED_TILE_BREAK = "Shared/Tile_break",
  -- SHARED_TOSS = "Shared/Toss",
  -- SHARED_TOSS_FIRE = "Shared/Toss_fire",
  -- SHARED_TRIP = "Shared/Trip",
  -- SHARED_WAKE_BLINK = "Shared/Wake_blink",
  -- SHARED_WEBBED = "Shared/Webbed",
  -- SHOP_SHOP_BUY = "Shop/Shop_buy",
  -- SHOP_SHOP_ENTER = "Shop/Shop_enter",
  -- SHOP_SHOP_FOCUS = "Shop/Shop_focus",
  -- SHOP_SHOP_NOPE = "Shop/Shop_nope",
  -- SHOP_SHOP_PICK_UP = "Shop/Shop_pick_up",
  -- TRANSITIONS_TRANS_ANGER = "Transitions/Trans_anger",
  -- TRANSITIONS_TRANS_ANKH = "Transitions/Trans_ankh",
  -- TRANSITIONS_TRANS_DARK = "Transitions/Trans_dark",
  -- TRANSITIONS_TRANS_DARK_FIRST = "Transitions/Trans_dark_first",
  -- TRANSITIONS_TRANS_DEATH = "Transitions/Trans_death",
  -- TRANSITIONS_TRANS_DM_RESULTS = "Transitions/Trans_dm_results",
  -- TRANSITIONS_TRANS_LAYER = "Transitions/Trans_layer",
  -- TRANSITIONS_TRANS_LAYER_SPECIAL = "Transitions/Trans_layer_special",
  -- TRANSITIONS_TRANS_OUROBOROS = "Transitions/Trans_ouroboros",
  -- TRANSITIONS_TRANS_PAUSE = "Transitions/Trans_pause",
  -- TRANSITIONS_TRANS_PIPE = "Transitions/Trans_pipe",
  -- TRANSITIONS_TRANS_SHOP = "Transitions/Trans_shop",
  -- TRANSITIONS_TRANS_THEME = "Transitions/Trans_theme",
  -- TRANSITIONS_TRANS_TUNNEL = "Transitions/Trans_tunnel",
  -- TRAPS_ARROWTRAP_TRIGGER = "Traps/Arrowtrap_trigger",
  -- TRAPS_BOULDER_CRUSH = "Traps/Boulder_crush",
  -- TRAPS_BOULDER_EMERGE = "Traps/Boulder_emerge",
  -- TRAPS_BOULDER_LOOP = "Traps/Boulder_loop",
  -- TRAPS_BOULDER_WARN_LOOP = "Traps/Boulder_warn_loop",
  -- TRAPS_CONVEYOR_BELT_LOOP = "Traps/Conveyor_belt_loop",
  -- TRAPS_CRUSHTRAP_BIG_STOP = "Traps/Crushtrap_big_stop",
  -- TRAPS_CRUSHTRAP_STOP = "Traps/Crushtrap_stop",
  -- TRAPS_DRILL_LOOP = "Traps/Drill_loop",
  -- TRAPS_DUAT_WALL_LOOP = "Traps/Duat_wall_loop",
  -- TRAPS_ELEVATOR_DOWN = "Traps/Elevator_down",
  -- TRAPS_ELEVATOR_UP = "Traps/Elevator_up",
  -- TRAPS_GENERATOR_GENERATE = "Traps/Generator_generate",
  -- TRAPS_GIANTCLAM_CLOSE = "Traps/Giantclam_close",
  -- TRAPS_GIANTCLAM_OPEN = "Traps/Giantclam_open",
  -- TRAPS_KALI_ANGERED = "Traps/Kali_angered",
  -- TRAPS_LASERBEAM_CHARGE = "Traps/Laserbeam_charge",
  -- TRAPS_LASERBEAM_COLLISION = "Traps/Laserbeam_collision",
  -- TRAPS_LASERBEAM_END = "Traps/Laserbeam_end",
  -- TRAPS_LASERBEAM_LOOP = "Traps/Laserbeam_loop",
  -- TRAPS_LASERTRAP_CHARGE = "Traps/Lasertrap_charge",
  -- TRAPS_LASERTRAP_TRIGGER = "Traps/Lasertrap_trigger",
  -- TRAPS_LIONTRAP_ATK = "Traps/Liontrap_atk",
  -- TRAPS_LIONTRAP_TRIGGER = "Traps/Liontrap_trigger",
  -- TRAPS_MINE_ACTIVATE = "Traps/Mine_activate",
  -- TRAPS_MINE_BLINK = "Traps/Mine_blink",
  -- TRAPS_MINE_DEACTIVATE = "Traps/Mine_deactivate",
  -- TRAPS_PIPE_LOOP = "Traps/Pipe_loop",
  -- TRAPS_PLATFORM_BREAK = "Traps/Platform_break",
  -- TRAPS_PLATFORM_TRIGGER = "Traps/Platform_trigger",
  -- TRAPS_QUICKSAND_AMB_LOOP = "Traps/Quicksand_amb_loop",
  -- TRAPS_QUICKSAND_LOOP = "Traps/Quicksand_loop",
  -- TRAPS_REGENBLOCK_GROW = "Traps/Regenblock_grow",
  -- TRAPS_SKULLBLOCK_ATK = "Traps/Skullblock_atk",
  -- TRAPS_SKULLBLOCK_TRIGGER = "Traps/Skullblock_trigger",
  -- TRAPS_SKULLDROP_DROP = "Traps/Skulldrop_drop",
  -- TRAPS_SKULLDROP_LOOP = "Traps/Skulldrop_loop",
  -- TRAPS_SLIDEWALL_STOMP = "Traps/Slidewall_stomp",
  -- TRAPS_SNAPTRAP_CLOSE = "Traps/Snaptrap_close",
  -- TRAPS_SNAPTRAP_OPEN = "Traps/Snaptrap_open",
  -- TRAPS_SPARK_HIT = "Traps/Spark_hit",
  -- TRAPS_SPARK_LOOP = "Traps/Spark_loop",
  -- TRAPS_SPEARTRAP_ATK = "Traps/Speartrap_atk",
  -- TRAPS_SPEARTRAP_TRIGGER = "Traps/Speartrap_trigger",
  -- TRAPS_SPIKE_BALL_DROP_LOOP = "Traps/Spike_ball_drop_loop",
  -- TRAPS_SPIKE_BALL_END = "Traps/Spike_ball_end",
  -- TRAPS_SPIKE_BALL_HIT = "Traps/Spike_ball_hit",
  -- TRAPS_SPIKE_BALL_RISE_LOOP = "Traps/Spike_ball_rise_loop",
  -- TRAPS_SPRING_TRIGGER = "Traps/Spring_trigger",
  -- TRAPS_STICKYTRAP_DROP_LOOP = "Traps/Stickytrap_drop_loop",
  -- TRAPS_STICKYTRAP_END = "Traps/Stickytrap_end",
  -- TRAPS_STICKYTRAP_HIT = "Traps/Stickytrap_hit",
  -- TRAPS_STICKYTRAP_RISE_LOOP = "Traps/Stickytrap_rise_loop",
  -- TRAPS_STICKYTRAP_WAKE = "Traps/Stickytrap_wake",
  -- TRAPS_SWITCH_FLICK = "Traps/Switch_flick",
  -- TRAPS_THINICE_CRACK = "Traps/Thinice_crack",
  -- TRAPS_TIKI_ATK = "Traps/Tiki_atk",
  -- TRAPS_TIKI_TRIGGER = "Traps/Tiki_trigger",
  -- TRAPS_WOODENLOG_CRUSH = "Traps/Woodenlog_crush",
  -- TRAPS_WOODENLOG_TRIGGER = "Traps/Woodenlog_trigger",
  -- UI_DAMSEL_KISS = "UI/Damsel_kiss",
  -- UI_DEPOSIT = "UI/Deposit",
  -- UI_GET_GEM = "UI/Get_gem",
  -- UI_GET_GOLD = "UI/Get_gold",
  -- UI_GET_ITEM1 = "UI/Get_item1",
  -- UI_GET_ITEM2 = "UI/Get_item2",
  -- UI_GET_SCARAB = "UI/Get_scarab",
  -- UI_JOURNAL_ENTRY = "UI/Journal_entry",
  -- UI_JOURNAL_OFF = "UI/Journal_off",
  -- UI_JOURNAL_ON = "UI/Journal_on",
  -- UI_KAPPALA_HEAL = "UI/Kappala_heal",
  -- UI_NPC_VOCAL = "UI/NPC_vocal",
  -- UI_PAUSE_MENU_OFF = "UI/Pause_menu_off",
  -- UI_PAUSE_MENU_ON = "UI/Pause_menu_on",
  -- UI_SECRET = "UI/Secret",
  -- UI_SECRET2 = "UI/Secret2",
  -- UI_TEXT_DESCRIPTION = "UI/Text_description",
  -- UI_TUNNEL_COUNT = "UI/Tunnel_count",
  -- UI_TUNNEL_SCROLL = "UI/Tunnel_scroll",
  -- UI_TUNNEL_TABLET_DOWN = "UI/Tunnel_tablet_down",
  -- UI_TUNNEL_TABLET_UP = "UI/Tunnel_tablet_up",
  -- UI_ZOOM_IN = "UI/Zoom_in",
  -- UI_ZOOM_OUT = "UI/Zoom_out"
-- }
-- VANILLA_SOUND_CALLBACK_TYPE = {
  -- CREATED = 1,
  -- DESTROYED = 2,
  -- RESTARTED = 16,
  -- STARTED = 8,
  -- START_FAILED = 64,
  -- STOPPED = 32
-- }
-- VANILLA_SOUND_PARAM = {
  -- ANGER_PROXIMITY = 11,
  -- ANGER_STATE = 12,
  -- CAM_DEPTH = 24,
  -- COLLISION_MATERIAL = 14,
  -- CURRENT_LAYER2 = 37,
  -- CURRENT_LEVEL = 35,
  -- CURRENT_SHOP_TYPE = 36,
  -- CURRENT_THEME = 34,
  -- CURSED = 28,
  -- DIST_CENTER_X = 1,
  -- DIST_CENTER_Y = 2,
  -- DIST_PLAYER = 4,
  -- DIST_Z = 3,
  -- DM_STATE = 32,
  -- FAST_FORWARD = 33,
  -- FIRST_RUN = 23,
  -- GHOST = 9,
  -- LIGHTNESS = 16,
  -- LIQUID_INTENSITY = 7,
  -- LIQUID_STREAM = 6,
  -- MONSTER_ID = 19,
  -- PAGE = 31,
  -- PLAYER_ACTIVITY = 20,
  -- PLAYER_CHARACTER = 30,
  -- PLAYER_CONTROLLED = 29,
  -- PLAYER_DEPTH = 22,
  -- PLAYER_LIFE = 21,
  -- POISONED = 27,
  -- POS_SCREEN_X = 0,
  -- RESTLESS_DEAD = 25,
  -- SIZE = 17,
  -- SPECIAL_MACHINE = 26,
  -- SUBMERGED = 5,
  -- TORCH_PROXIMITY = 13,
  -- TRIGGER = 10,
  -- TYPE_ID = 18,
  -- VALUE = 8,
  -- VELOCITY = 15
-- }
-- VladsCape = {
  -- __index = "function: 0000023A15910680",
  -- __name = "sol.VladsCape.user",
  -- __newindex = "function: 0000023A159114F0"
-- }
-- WIN_STATE = {
  -- COSMIC_OCEAN_WIN = 3,
  -- HUNDUN_WIN = 2,
  -- NO_WIN = 0,
  -- TIAMAT_WIN = 1
-- }
-- apply_entity_db = function(...) end
-- carry = function(...) end
-- clear_callback = function(...) end
-- clear_vanilla_sound_callback = function(...) end
-- clr_flag = function(...) end
-- clrflag = function(...) end
-- create_image = function(...) end
-- create_sound = function(...) end
-- define_tile_code = function(...) end
-- distance = function(...) end
-- door = function(...) end
-- draw_circle = function(...) end
-- draw_circle_filled = function(...) end
-- draw_image = function(...) end
-- draw_image_rotated = function(...) end
-- draw_line = function(...) end
-- draw_rect = function(...) end
-- draw_rect_filled = function(...) end
-- draw_text = function(...) end
-- draw_text_size = function(...) end
-- entity_get_items_by = function(...) end
-- entity_has_item_type = function(...) end
-- entity_has_item_uid = function(...) end
-- entity_remove_item = function(...) end
-- flip_entity = function(...) end
-- force_co_subtheme = function(...) end
-- force_dark_level = function(...) end
-- game_position = function(...) end
-- generate_particles = function(...) end
-- get_bounds = function(...) end
-- get_camera_position = function(...) end
-- get_door_target = function(...) end
-- get_entities = function(...) end
-- get_entities_at = function(...) end
-- get_entities_by = function(...) end
-- get_entities_by_layer = function(...) end
-- get_entities_by_mask = function(...) end
-- get_entities_by_type = function(...) end
-- get_entities_overlapping = function(...) end
-- get_entity = function(...) end
-- get_entity_ai_state = function(...) end
-- get_entity_flags = function(...) end
-- get_entity_flags2 = function(...) end
-- get_entity_type = function(...) end
-- get_frame = function(...) end
-- get_level_flags = function(...) end
-- get_ms = function(...) end
-- get_particle_type = function(...) end
-- get_position = function(...) end
-- get_render_position = function(...) end
-- get_sound = function(...) end
-- get_type = function(...) end
-- get_window_size = function(...) end
-- get_zoom_level = function(...) end
-- god = function(...) end
-- inspect = {
  -- KEY = {},
  -- METATABLE = {},
  -- _DESCRIPTION = "human-readable representations of tables",
  -- _LICENSE = "    MIT LICENSE\n\n    Copyright (c) 2013 Enrique García Cota\n\n    Permission is hereby granted, free of charge, to any person obtaining a\n    copy of this software and associated documentation files (the\n    \"Software\"), to deal in the Software without restriction, including\n    without limitation the rights to use, copy, modify, merge, publish,\n    distribute, sublicense, and/or sell copies of the Software, and to\n    permit persons to whom the Software is furnished to do so, subject to\n    the following conditions:\n\n    The above copyright notice and this permission notice shall be included\n    in all copies or substantial portions of the Software.\n\n    THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS\n    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\n    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\n    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY\n    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,\n    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE\n    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n  ",
  -- _URL = "http://github.com/kikito/inspect.lua",
  -- _VERSION = "inspect.lua 3.1.0",
  -- inspect = ((loadstring or load)("\27LuaT\0\25“\13\n\26\n\4\8\8xV\0\0\0\0\0\0\0\0\0\0\0(w@\4\4€\nlocal inspect ={\n  _VERSION = 'inspect.lua 3.1.0',\n  _URL     = 'http://github.com/kikito/inspect.lua',\n  _DESCRIPTION = 'human-readable representations of tables',\n  _LICENSE = [[\n    MIT LICENSE\n\n    Copyright (c) 2013 Enrique García Cota\n\n    Permission is hereby granted, free of charge, to any person obtaining a\n    copy of this software and associated documentation files (the\n    \"Software\"), to deal in the Software without restriction, including\n    without limitation the rights to use, copy, mod...\2°\2Ê\2\0\11½Â€\0\0008\1\0€\19\1\0\0R\0\0\0€\0\2\0\14\1\1\0B\0\0¸\0\0€\11\1\0\1\14\1\2\2Ž\1\1\3Â\0\0008\0\0€ƒ\1\2\0\14\2\1\5B‚\0\0008\0\0€\3\2\3\0Ž\2\1\7Â\2\0\0008\4\0€\9\3\1\0€\3\5\0\0\4\0\0“\4\0\0R\0\0\0\19\5\0\0R\0\0\0D\3\5\2\0\0\6\0\11\3\0\8“\3\4\0R\0\0\0’\3\0\2’ƒ\9\n\19\4\0\0R\0\0\0’\3\11\8\19\4\0\0R\0\0\0’\3\12\8\19\4\0\0R\0\0\0’\3\13\8’\3\3\3’\3\5\4\9\4\2\0€\4\0\0D\4\2\2’\3\14\8\9\4\3\0D\3\3\2”ƒ\6\15€\4\0\0Ä\3\3\1‹\3\0\16Ž\3\7\17\14\4\6\11Å\3\2\0Æ\3\0\0Ç\3\1\0’\4†depth\4…math\4…huge\4ˆnewline\4‚\n\4‡indent\4ƒ  \4ˆprocess\4setmetatable\4†level\3\0\0\0\0\0\0\0\0\4‡buffer\4„ids\4‡maxIds\4‘tableAppearances\4‰putValue\4†table\4‡concat„\0\0\0\1\16\0\1\13\0\1\18\0€½\1\0\0\0\0\2\0\0\0\0\1\0\0\0\1\0\0\0\1\2\0\1\0\0\0\0\0\0\0\0\3\0\0\1\1\1\0\0\1\0\0\1\0\0\1\1\1\0\0\0\1÷\11\0\0\2\0\0\0\0\1€‡…root€½ˆoptions€½†depthŠ½ˆnewlineŽ½‡indent’½ˆprocess“½Šinspector´½„…_ENV‘processRecursive–countTableAppearancesInspector_mt",'@serialized'))
-- }
-- json = {
  -- _version = "0.1.2",
  -- decode = ((loadstring or load)("\27LuaT\0\25“\13\n\26\n\4\8\8xV\0\0\0\0\0\0\0\0\0\0\0(w@\5\4€\n--\n-- json.lua\n--\n-- Copyright (c) 2020 rxi\n--\n-- Permission is hereby granted, free of charge, to any person obtaining a copy of\n-- this software and associated documentation files (the \"Software\"), to deal in\n-- the Software without restriction, including without limitation the rights to\n-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\n-- of the Software, and to permit persons to whom the Software is furnished to do\n-- so, subject to the following conditions:\n--\n-- The...\2ø\3‚\1\0\8¦‹\0\0\0\0\1\0\0Ä\0\2\2¼€\1\0008\3\0€‹\0\0\2\3\1\0‹\1\0\0\0\2\0\0Ä\1\2\0025\1\2\0Ä\0\2\1‰\0\1\0\0\1\0\0‰\1\2\0\0\2\0\0\2\0€\9\3\3\0‡\3\0\0Ä\1\5\0Ä\0\0\3‰\1\2\0\0\2\0\0€\2\2\0\9\3\3\0‡\3\0\0Ä\1\5\2\0\1\3\0´\1\0\0;\1\3\0008\2\0€‰\1\4\0\0\2\0\0€\2\2\0\3\3\2\0Ä\1\4\1È\0\2\0Ç\1\1\0…\4…type\4‡string\4†error\4§expected argument of type string, got \4‘trailing garbage…\0\0\0\1\n\0\1\17\0\1\12\0\1\18\0€¦\1\0\0\0\0\1\0\0\0\0\0\0\2\0\0\0\0\0\0\0\0\1\0\0\0\0\0\0\1\0\0\1\0\0\0\0\2\1€ƒ„str€¦„res•¦„idx•¦……_ENV†parseŠnext_charŒspace_charsdecode_error",'@serialized')),
  -- encode = ((loadstring or load)("\27LuaT\0\25“\13\n\26\n\4\8\8xV\0\0\0\0\0\0\0\0\0\0\0(w@\1\4€\n--\n-- json.lua\n--\n-- Copyright (c) 2020 rxi\n--\n-- Permission is hereby granted, free of charge, to any person obtaining a copy of\n-- this software and associated documentation files (the \"Software\"), to deal in\n-- the Software without restriction, including without limitation the rights to\n-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\n-- of the Software, and to permit persons to whom the Software is furnished to do\n-- so, subject to the following conditions:\n--\n-- The...\1‡\1‰\1\0\3…‰\0\0\0\0\1\0\0Ä\0\2\2È\0\2\0Ç\0\1\0€\1\1\0€…\1\0\0\0\1€„val€…‡encode",'@serialized'))
-- }
-- kill_entity = function(...) end
-- layer_door = function(...) end
-- load_script = function(...) end
-- lock_door_at = function(...) end
-- message = function(...) end
-- modify_sparktraps = function(...) end
-- move_entity = function(...) end
-- options = {}
-- pause = function(...) end
-- pick_up = function(...) end
-- players = 
-- read_input = function(...) end
-- read_prng = function(...) end
-- read_stolen_input = function(...) end
-- register_option_bool = function(...) end
-- register_option_button = function(...) end
-- register_option_combo = function(...) end
-- register_option_float = function(...) end
-- register_option_int = function(...) end
-- register_option_string = function(...) end
-- replace_drop = function(...) end
-- return_input = function(...) end
-- rgba = function(...) end
-- savegame = 
-- say = function(...) end
-- screen_distance = function(...) end
-- screen_position = function(...) end
-- seed_prng = function(...) end
-- send_input = function(...) end
-- set_arrowtrap_projectile = function(...) end
-- set_blood_multiplication = function(...) end
-- set_callback = function(...) end
-- set_camera_position = function(...) end
-- set_contents = function(...) end
-- set_door = function(...) end
-- set_door_target = function(...) end
-- set_drop_chance = function(...) end
-- set_entity_flags = function(...) end
-- set_entity_flags2 = function(...) end
-- set_flag = function(...) end
-- set_ghost_spawn_times = function(...) end
-- set_global_interval = function(...) end
-- set_global_timeout = function(...) end
-- set_interval = function(...) end
-- set_kapala_blood_threshold = function(...) end
-- set_kapala_hud_icon = function(...) end
-- set_level_flags = function(...) end
-- set_olmec_phase_y_level = function(...) end
-- set_post_tile_code_callback = function(...) end
-- set_pre_tile_code_callback = function(...) end
-- set_seed = function(...) end
-- set_timeout = function(...) end
-- set_vanilla_sound_callback = function(...) end
-- setflag = function(...) end
-- spawn = function(...) end
-- spawn_door = function(...) end
-- spawn_entity = function(...) end
-- spawn_entity_over = function(...) end
-- spawn_layer_door = function(...) end
-- state = 
-- steal_input = function(...) end
-- test_flag = function(...) end
-- testflag = function(...) end
-- toast = function(...) end
-- unlock_door_at = function(...) end
-- warp = function(...) end
-- win_button = function(...) end
-- win_check = function(...) end
-- win_combo = function(...) end
-- win_drag_float = function(...) end
-- win_drag_int = function(...) end
-- win_image = function(...) end
-- win_inline = function(...) end
-- win_input_float = function(...) end
-- win_input_int = function(...) end
-- win_input_text = function(...) end
-- win_popid = function(...) end
-- win_pushid = function(...) end
-- win_sameline = function(...) end
-- win_separator = function(...) end
-- win_slider_float = function(...) end
-- win_slider_int = function(...) end
-- win_text = function(...) end
-- window = function(...) end
-- zoom = function(...) end

