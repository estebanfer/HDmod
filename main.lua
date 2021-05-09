meta.name = "Spelunky HD 2"
meta.version = "1"
meta.description = "Spelunky HD's campaign inside of Spelunky 2"
meta.author = "Super Ninja Fat"


register_option_bool("hd_toastfeeling", "Allow script-enduced feeling messages", true)
register_option_bool("hd_udjat", "On an Udjat level, replace the Ghost Jar with an Udjat Chest", true)
register_option_bool("hd_nocursedpot", "Remove all Ghost Jars", false)
register_option_bool("hd_ghosttime", "Spawns the ghost at 2:30 instead of 3:00 and 2:00 instead of 2:30 when cursed.", true)
register_option_bool("hd_antitrapcuck", "Prevent spawning traps that can cuck you", true)
register_option_bool("hd_freebookofdead", "Start with the Book of the dead", true)
register_option_bool("hd_unlockbossexit", "Unlock boss exit", false)
register_option_bool("hd_boss_info", "Enable bossfight info", false)
register_option_bool("hd_wormtongue_info", "Enable wormtongue info", true)
register_option_bool("hd_show_ducttapeenemies", "Draw enemies used for custom enemy behavior", false)
register_option_bool("hd_boulder_phys", "Adjust boulders to have the same physics as HD", true)
register_option_bool("hd_boulder_agro", "Make boulders enrage shopkeepers", true)
register_option_float("bod_w", "bod width", 0.08, 0.0, 99.0)
register_option_float("bod_h", "bod height", 0.12, 0.0, 99.0)
register_option_float("bod_x", "bod x", 0.2, -999.0, 999.0)
register_option_float("bod_y", "bod y", 0.93, -999.0, 999.0)
-- register_option_float("bod_squash", "bod uvx shifting rate", 0.25, -5.0, 5.0)

bool_to_number={ [true]=1, [false]=0 }

HD_ENT_TIKITRAP_SET = false
HD_ENT_GIANTFROG_SET = false

GHOST_SPAWNED = false
GHOST_TIME = 10800
IDOLTRAP_TRIGGER = false
HD_FEELING_SPIDERLAIR = false
HD_FEELING_RESTLESS = false
MESSAGE_FEELING = nil
WHEEL_SPINNING = false
WHEEL_SPINTIME = 700 -- TODO: HD's was 10-11 seconds, convert to this.
ACID_POISONTIME = 270 -- TODO: Make sure it matches with HD, which was 3-4 seconds
TONGUE_ACCEPTTIME = 200
IDOLTRAP_JUNGLE_ACTIVATETIME = 15
wheel_items = {}
global_dangers = {}
global_dangers_postspawn = {}
danger_tracker = {} -- Parameters: uid, special features
IDOL_X = nil
IDOL_Y = nil
IDOL_UID = nil
TONGUE_UID = nil
TONGUE_BG_UID = nil
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
OLMEC_SEQUENCE = { ["STILL"] = 1, ["JUMP"] = 2, ["MIDAIR"] = 3, ["FALL"] = 4 }
OLMEC_STATE = 0
HELL_X = 0
BOOKOFDEAD_TIC_LIMIT = 5
BOOKOFDEAD_RANGE = 14
bookofdead_tick = 0
-- bookofdead_tick_min = BOOKOFDEAD_TIC_LIMIT
bookofdead_frames = 4
bookofdead_frames_index = 1
bookofdead_squash = (1/bookofdead_frames) --options.bod_squash

OBTAINED_BOOKOFDEAD = false

UI_BOOKOFDEAD_ID, UI_BOOKOFDEAD_w, UI_BOOKOFDEAD_h = create_image('bookofdead.png')

-- Bool check for levels that don't spawn the ghost
-- Any level except Boss levels and Worm levels
-- blacklist levels 

-- TODO: Choose a unique ENT_TYPE for (at least the first 4) SUBCHUNKIDs
HD_SUBCHUNKID = {
	-- ["0" = , -- Non-main path subchunk
	-- ["1" = , -- Main path, goes L/R (also entrance/exit)
	-- ["2" = , -- Main path, goes L/R and down (and up if it's below another 2)
	-- ["3" = , -- Main path, goes L/R and up
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

HD_TILENAME = {
	["0"] = 0,
	["1"] = ENT_TYPE.FLOOR_GENERIC,
	["2"] = ENT_TYPE.FLOOR_GENERIC,
	["+"] = ENT_TYPE.FLOORSTYLED_STONE,
	["4"] = ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
	["G"] = ENT_TYPE.FLOOR_TOMB,
	["i"] = ENT_TYPE.ITEM_IDOL
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

HD_REMOVEMOUNT = {
	SNAIL = 1,
	SCORPIONFLY = 2,
	EGGSAC = 3
}

KILL_ON = {
	STANDING = 1,
	STANDING_OUTOFWATER = 2
}

HD_BEHAVIOR = {
	-- IDEAS:
		-- Disable enemy attacks.
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
				-- TODO: Split into two variables: One that gets set in onlevel_generation_dangers(), and one in onlevel_dangers_modifications.
					-- IDEA: dim_db and dim
			-- acceleration
			-- max_speed
			-- sprint_factor
			-- jump
			-- damage
			-- health
				-- sets EntityDB's life
		-- TODO:
			-- friction
			-- weight
			-- elasticity
			-- blood_content
			-- draw_depth
	-- onlevel_generation_dangers
		-- Supported Variables:
			-- tospawn
				-- if set, determines the ENT_TYPE to spawn.
			-- toreplace
				-- if set, determines the ENT_TYPE to replace inside onlevel_generation_dangers.
			-- postspawn
				-- If set, determines the ENT_TYPE to apply EntityDB modifications to
				-- TODO: Rename to entitytype
			-- dim = { w, h }
				-- sets height and width
				-- TODO: Split into two variables: One that gets set in onlevel_generation_dangers(), and one in onlevel_dangers_modifications.
					-- IDEA: dim_db and dim
			-- color = { r, g, b }
				-- TODO: Add alpha channel support
			-- hitbox = { w, h }
				-- `w` for hitboxx, `y` for hitboxy.
			-- stunnable
				-- sets flag if true, clears if false
			-- dangertype
				-- Determines multiple factors required for certain dangers, such as spawn_entity_over().
					-- Currently determines collision detection.
				-- TODO: Move conflict detection into its own variable that takes an enum to set collision detection.
	-- onframe_managedangers
		-- Supported Variables:
			-- kill_on_standing = 
				-- KILL_ON.STANDING
					-- Once standing on a surface, kill it.
				-- KILL_ON.STANDING_OUTOFWATER
					-- Once standing on a surface and not submerged, kill it.
			-- itemdrop = { item = {ENT_TYPE, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
			-- treasuredrop = { item = {ENT_TYPE, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
HD_ENT = {
	FROG = {
		tospawn = ENT_TYPE.MONS_FROG,
		toreplace = ENT_TYPE.MONS_MOSQUITO,
		dangertype = HD_DANGERTYPE.ENEMY
	},
	FIREFROG = {
		tospawn = ENT_TYPE.MONS_FIREFROG,
		toreplace = ENT_TYPE.MONS_MOSQUITO,
		dangertype = HD_DANGERTYPE.ENEMY
	},
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
		-- postspawn = ENT_TYPE.MONS_GIANTFLY,
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
	GIANTFROG = {
		tospawn = ENT_TYPE.MONS_OCTOPUS,
		toreplace = ENT_TYPE.MONS_OCTOPUS,
		postspawn = ENT_TYPE.MONS_OCTOPUS,
		dangertype = HD_DANGERTYPE.ENEMY,
		health_db = 8,
		sprint_factor = 0,
		max_speed = 0.01,
		jump = 0.2,
		dim = {2.5, 2.5},
		removecorpse = true,
		hitbox = {
			0.64,
			0.8
		},
		stunnable = false,
		itemdrop = {
			item = {ENT_TYPE.ITEM_PICKUP_SPRINGSHOES},
			chance = 0.15 -- 15% (1/6.7)
		}
	},
	SNAIL = {
		tospawn = ENT_TYPE.MONS_HERMITCRAB,
		toreplace = ENT_TYPE.MONS_WITCHDOCTOR,
		postspawn = ENT_TYPE.MONS_HERMITCRAB,
		dangertype = HD_DANGERTYPE.ENEMY,
		health_db = 1,
		removecorpse = true,
		removemounts = HD_REMOVEMOUNT.SNAIL
	},
	PIRANHA = {
		-- postspawn = ENT_TYPE.MONS_TADPOLE,
		dangertype = HD_DANGERTYPE.ENEMY,
		liquidspawn = HD_LIQUIDSPAWN.PIRANHA,
		-- sprint_factor = -1,
		-- max_speed = -1,
		-- acceleration = -1,
		kill_on_standing = KILL_ON.STANDING_OUTOFWATER
	},
	WORMBABY = {
		postspawn = ENT_TYPE.MONS_MOLE,
		dangertype = HD_DANGERTYPE.ENEMY,
		health_db = 1,
		removecorpse = true
	},
	EGGSAC = {
		tospawn = ENT_TYPE.ITEM_EGGSAC,
		toreplace = ENT_TYPE.MONS_JUMPDOG,
		dangertype = HD_DANGERTYPE.FLOORTRAP,
		removemounts = HD_REMOVEMOUNT.EGGSAC
	},
	TRAP_TIKI = {
		tospawn = ENT_TYPE.FLOOR_TOTEM_TRAP,
		toreplace = ENT_TYPE.ITEM_SNAP_TRAP,
		postspawn = ENT_TYPE.ITEM_TOTEM_SPEAR,
		dangertype = HD_DANGERTYPE.FLOORTRAP_TALL,
		damage = 4
	},
	OLDBITEY = {
		dangertype = HD_DANGERTYPE.ENEMY,
		postspawn = ENT_TYPE.MONS_GIANTFISH,
		itemdrop = {
			item = {ENT_TYPE.ITEM_IDOL}, --ENT_TYPE.ITEM_MADAMETUSK_IDOL
			chance = 1
		}
	},
	CRITTER_RAT = {
		dangertype = HD_DANGERTYPE.CRITTER,
		postspawn = ENT_TYPE.MONS_CRITTERDUNGBEETLE,
		max_speed = 0.05,
		acceleration = 0.05
	},
	CRITTER_FROG = { -- TODO: behavior for jumping
		tospawn = ENT_TYPE.MONS_CRITTERCRAB,
		toreplace = ENT_TYPE.MONS_CRITTERBUTTERFLY,
		dangertype = HD_DANGERTYPE.CRITTER,
		postspawn = ENT_TYPE.MONS_CRITTERCRAB
		-- TODO: Make jumping script, adjust movement EntityDB properties
		-- behavior = HD_BEHAVIOR.CRITTER_FROG,
	},
	SPIDER = {
		tospawn = ENT_TYPE.MONS_SPIDER,
		toreplace = ENT_TYPE.MONS_SPIDER,
		dangertype = HD_DANGERTYPE.ENEMY
	},
	HANGSPIDER = {
		tospawn = ENT_TYPE.MONS_HANGSPIDER,
		toreplace = ENT_TYPE.MONS_SPIDER,
		dangertype = HD_DANGERTYPE.ENEMY
	},
	GIANTSPIDER = {
		tospawn = ENT_TYPE.MONS_GIANTSPIDER,
		toreplace = ENT_TYPE.MONS_SPIDER,
		dangertype = HD_DANGERTYPE.ENEMY
	},
	BOULDER = {
		dangertype = HD_DANGERTYPE.ENEMY,--HD_DANGERTYPE.FLOORTRAP,
		postspawn = ENT_TYPE.ACTIVEFLOOR_BOULDER
		-- TODO: Modify EntityDB to make the physics of it match that of HD's.
	},
	SCORPIONFLY = {
		tospawn = ENT_TYPE.MONS_SCORPION,
		toreplace = ENT_TYPE.MONS_SPIDER,--CATMUMMY,
		dangertype = HD_DANGERTYPE.ENEMY,
		behavior = HD_BEHAVIOR.SCORPIONFLY,
		color = { 0.902, 0.176, 0.176 },
		removemounts = HD_REMOVEMOUNT.SCORPIONFLY
	},
	OLMEC_SHOT = { -- TODO: Add behavior and move into danger handling
		dangertype = HD_DANGERTYPE.ENEMY,
		kill_on_standing = KILL_ON.STANDING,
		itemdrop = {
			item = {
				ENT_TYPE.MONS_FROG,
				ENT_TYPE.MONS_FIREFROG,
				ENT_TYPE.MONS_MONKEY,
				ENT_TYPE.MONS_SCORPION,
				ENT_TYPE.MONS_SNAKE,
				ENT_TYPE.MONS_BAT
			},
			chance = 1.0
		}
	},
	-- DEVIL = {
		-- tospawn = ENT_TYPE.MONS_OCTOPUS,
		-- toreplace = ?,
		-- postspawn = ENT_TYPE.MONS_OCTOPUS,
		-- dangertype = HD_DANGERTYPE.ENEMY,
		-- sprint_factor = 7.0
		-- max_speed = 7.0
	-- },
	-- MAMMOTH = { -- TODO: Frozen Immunity
		-- tospawn = ENT_TYPE.MONS_GIANTFLY,
		-- toreplace = ?,
		-- dangertype = HD_DANGERTYPE.ENEMY,
		-- postspawn = ENT_TYPE.MONS_GIANTFLY,
		-- behavior = HD_BEHAVIOR.MAMMOTH,
		-- health_db = 8,
		-- itemdrop = {
			-- item = {ENT_TYPE.ITEM_FREEZERAY},
			-- chance = 1.0
		-- },
		-- treasuredrop = {
			-- item = {ENT_TYPE.ITEM_SAPPHIRE},
			-- chance = 1.0
		-- }
	-- },
	-- HAWKMAN = {
		-- tospawn = ENT_TYPE.MONS_SHOPKEEPERCLONE, -- Maybe.
		-- toreplace = ENT_TYPE.MONS_CAVEMAN,
		-- dangertype = HD_DANGERTYPE.ENEMY,
		-- postspawn = ENT_TYPE.MONS_SHOPKEEPERCLONE,
		-- behavior = HD_BEHAVIOR.HAWKMAN
	-- },
	-- GREENKNIGHT = {
		-- tospawn = ENT_TYPE.MONS_OLMITE_BODYARMORED,
		-- toreplace = ENT_TYPE.MONS_CAVEMAN,
		-- dangertype = HD_DANGERTYPE.ENEMY,
		-- postspawn = ENT_TYPE.MONS_OLMITE_BODYARMORED,
		-- behavior = HD_BEHAVIOR.GREENKNIGHT,
		-- stompdamage = false, -- TODO: Add this(?)
	-- },
	-- NOTE: Shopkeeperclones are immune to whip damage, while the black knight in HD wasn't.
		-- May be able to override this by syncing the stun of a duct-taped entity (ie, if caveman is stunned, shopkeeperclone.stun_timer = 10)
			-- Might as well use a caveman for the master, considering that in HD when the blackknight drops his shield, he behaves like a green knight (so, a caveman)
	-- BLACKKNIGHT = {
		-- tospawn = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
		-- dangertype = HD_DANGERTYPE.ENEMY,
		-- postspawn = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
		-- behavior = HD_BEHAVIOR.BLACKKNIGHT,
		-- health = 3,
		-- giveitem = ENT_TYPE.ITEM_METAL_SHIELD
	-- }
}


			-- parameters:
				-- {{HD_ENT, true}, {HD_ENT, false}, {HD_ENT, true}...}
					-- HD Enemy type
					-- true for chance to spawn as rare variants, if exists
LEVEL_DANGERS = {
	[THEME.DWELLING] = {
		dangers = {
			{
				entity = HD_ENT.SCORPIONFLY--SPIDER,
				-- variation = {
					-- entities = {HD_ENT.SPIDER, HD_ENT.HANGSPIDER, HD_ENT.GIANTSPIDER},
					-- chances = {0.5, 0.85}
				-- }
			},
			-- {
				-- entity = HD_ENT.HANGSPIDER
			-- },
			-- {
				-- entity = HD_ENT.GIANTSPIDER
			-- },
			{
				entity = HD_ENT.CRITTER_RAT
			}
		}
	},
	-- [THEME.DWELLING] = {
		-- dangers = {
			-- {
				-- entity = HD_ENT.SPIDER,
				-- variation = {
					-- entities = {HD_ENT.SPIDER, HD_ENT.HANGSPIDER, HD_ENT.GIANTSPIDER},
					-- chances = {0.5, 0.85}
				-- }
			-- },
			-- {
				-- entity = HD_ENT.HANGSPIDER
			-- },
			-- {
				-- entity = HD_ENT.GIANTSPIDER
			-- },
			-- {
				-- entity = HD_ENT.CRITTER_RAT
			-- }
		-- }
	-- },
	[THEME.JUNGLE] = {
		dangers = {
			{
				entity = HD_ENT.FROG,
				variation = {
					entities = {HD_ENT.FROG, HD_ENT.FIREFROG, HD_ENT.GIANTFROG},
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


function init()
	wheel_items = {}
	idoltrap_blocks = {}
	danger_tracker = {}
	idoltrap_timeout = IDOLTRAP_JUNGLE_ACTIVATETIME
	IDOL_X = nil
	IDOL_Y = nil
	IDOL_UID = nil
	TONGUE_UID = nil
	TONGUE_BG_UID = nil
	GHOST_SPAWNED = false
	IDOLTRAP_TRIGGER = false
	HD_FEELING_SPIDERLAIR = false
	HD_FEELING_RESTLESS = false
	MESSAGE_FEELING = nil
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
		if (
				options.hd_boulder_phys == true and
				state.theme == THEME.DWELLING and
				(
					state.level == 2 or
					state.level == 3 or
					state.level == 4
				)
		) then
			table.insert(LEVEL_DANGERS[THEME.DWELLING].dangers, { entity = HD_ENT.BOULDER }) --if options.hd_boulder_phys == true then
		end
		global_dangers = map(LEVEL_DANGERS[state.theme].dangers, function(danger) return danger.entity end)
		global_dangers_postspawn = map(global_dangers, function(entity) return entity.postspawn end)
	end
end

function blacklist_level_noghost()
	return (
		state.theme == THEME.EGGPLANT_WORLD or
		state.theme == THEME.OLMEC
	)
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

function locate_cornerpos(roomx, roomy)
	xmin, ymin, xmax, ymax = get_bounds()
	tc_x = (roomx-1)*10+(xmin+0.5)
	tc_y = (ymin-0.5) - ((roomy-1)*(8))
	return tc_x, tc_y
end

function locate_roompos(e_x, e_y)
	xmin, ymin, xmax, ymax = get_bounds()
	-- my brain can't do math, please excuse this embarrassing algorithm
	roomx = math.ceil((e_x-(xmin+0.5))/10)
	roomy = math.ceil(((ymin-0.5)-e_y)/8)
	return roomx, roomy
end

function create_ghost()
	xmin, ymin, xmax, ymax = get_bounds()
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

function idol_disturbance()
	if IDOL_UID ~= nil then
		x, y, l = get_position(IDOL_UID)
		return (x ~= IDOL_X or y ~= IDOL_Y)
	end
end

-- detect offset
function conflictdetection_floor(x, y, l, offsetx, offsety)
	blocks = get_entities_at(0, MASK.FLOOR, x+offsetx, y+offsety, l, 0.1)--0.2)
	if (#blocks > 0) then
		return true
	end
	return false
end

-- detect blocks above and to the sides
function conflictdetection_trap(d_hddtype, dx, dy, dl)
	local conflict = false
	-- avoid_types = {ENT_TYPE.FLOOR_BORDERTILE, ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOOR_JUNGLE, ENT_TYPE.FLOORSTYLED_MINEWOOD, ENT_TYPE.FLOORSTYLED_STONE}
	scan_width = 1 -- check 1 across
	scan_height = 1 -- check the space above
	if d_hddtype == HD_DANGERTYPE.FLOORTRAP and options.hd_antitrapcuck == true then
		scan_width = 1 -- check 3 across (1 on each side)
		scan_height = 0 -- check the space above + 1 more
	elseif d_hddtype == HD_DANGERTYPE.FLOORTRAP_TALL and options.hd_antitrapcuck == true then
		scan_width = 3 -- check 3 across (1 on each side)
		scan_height = 2 -- check the space above + 1 more
	end
	ey_above = dy
	for block_yi = ey_above, ey_above+scan_height, 1 do
		-- skip sides when y == 1
		if block_yi < ey_above+scan_height then
			block_xi_min, block_xi_max = dx, dx
		else
			block_xi_min = dx - math.floor(scan_width/2)
			block_xi_max = dx + math.floor(scan_width/2)
		end
		for block_xi = block_xi_min, block_xi_max, 1 do
			conflict = conflictdetection_floor(block_xi, block_yi, dl, 0, 0)
			--TODO: test `return conflict` here instead (I know it will work -_- but just to be safe, test it first)
			if conflict == true then
				break
			end
		end
		if conflict == true then break end
	end
	return conflict
end

function decorate_floor(e_uid, offsetx, offsety)--e_type, --e_theme, orientation(?))
	spawn_entity_over(ENT_TYPE.DECORATION_GENERIC, e_uid, offsetx, offsety)
end

function generate_floor(hd_tileid, e_x, e_y, e_l)
	e_x_ = e_x
	e_y_ = e_y
	
	e_type = 0
	-- chance_half = (math.random() >= 0.5)
	
	-- spawn
	if hd_tileid == "2" and (math.random() >= 0.5) then--chance_half == true then -- if 2, 50% chance not to spawn.
		e_type = 0
	else
		e_type = HD_TILENAME[hd_tileid]
	end
	if hd_tileid == "i" then -- if idol, move to middle
		e_x_ = e_x_+0.5
		-- if haunted replace with tusk idol
		if HD_FEELING_RESTLESS == true then
			e_type = ENT_TYPE.ITEM_MADAMETUSK_IDOL
		end
	end

	if e_type ~= 0 then
		floor_uid = spawn(e_type, e_x_, e_y_, e_l, 0, 0)
		if hd_tileid == "i" and HD_FEELING_RESTLESS == true then
			set_timeout(function()
				idols = get_entities_by_type(ENT_TYPE.ITEM_MADAMETUSK_IDOL)
				if #idols > 0 then
					IDOL_UID = idols[1]
					x, y, _ = get_position(idols[1])
					IDOL_X, IDOL_Y = x, y
				end
			end, 10)
		end
		-- decorate
			-- TODO: Use for placing decorations on floor tiles once placed.
			-- use orientation parameter to adjust what side the decorations need to go on. Take open sides into consideration.
		-- for degrees = 0, 270.0, 90.0 do
			-- offsetcoord = rotate(e_x_, e_y_, e_x_, e_y_+1, degrees)
			-- conflict = conflictdetection_floor(offsetcoord[1], offsetcoord[2], e_l, 0, 0)
			-- if conflict == false then
				-- decorate_floor(floor_uid, offsetcoord[1], offsetcoord[2])
			-- end
		-- end
	end
end

function generate_chunk(c_roomcode, c_dimw, c_dimh, x, y, layer, offsetx, offsety)
	x_ = x + offsetx
	y_ = y + offsety
	i = 1
	for r_yi = 0, c_dimh-1, 1  do
		for r_xi = 0, c_dimw-1, 1 do
			generate_floor(c_roomcode:sub(i, i), x_+r_xi, y_-r_yi, layer)
			i = i + 1
		end
	end
end

function remove_room(roomx, roomy, layer)
	tc_x, tc_y = locate_cornerpos(roomx, roomy)
	for yi = 0, 8-1, 1  do
		for xi = 0, 10-1, 1 do
			blocks = get_entities_at(0, MASK.FLOOR, tc_x+xi, tc_y-yi, layer, 0.1)
			for _, block in ipairs(blocks) do
				kill_entity(block)
			end
		end
	end
	return tc_x, tc_y
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
					blocks = get_entities_at(0, 0, cx+xi, cy-yi, layer, checkradius)
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
					generate_floor(roomchar, cx+xi, cy-yi, layer)
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


function remove_crabmounts()
	hidingspots = get_entities_by_type({ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, ENT_TYPE.ACTIVEFLOOR_POWDERKEG, ENT_TYPE.ITEM_CRATE, ENT_TYPE.ITEM_CHEST})
	for r, inventoryitem in ipairs(hidingspots) do
		local mount = get_entity(inventoryitem):topmost()
		if mount ~= -1 and mount:as_container().type.id == ENT_TYPE.MONS_HERMITCRAB then
			move_entity(inventoryitem, -r, 0, 0, 0)
			-- toast("Should be hermitcrab: ".. mount.uid)
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

function change_target(w_a, l_a, t_a, w_b, l_b, t_b)
	if state.theme == t_a and state.level == l_a and state.world == w_a then
		if test_flag(state.quest_flags, 1) == false then
			state.level_next = l_b
			state.world_next = w_b
			state.theme_next = t_b
		end
	end
end

function change_level(w_a, l_a, t_a, w_b, l_b, t_b)--w_b=0, l_b=0, t_b=0)
	if state.theme == t_a and state.level == l_a and state.world == w_a then --and (w_b ~= 0 or l_b ~= 0 or t_b ~= 0) then
		-- if test_flag(state.quest_flags, 1) == false then
			state.level = l_b
			state.world = w_b
			state.theme = t_b
		-- end
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



-- ON.START
set_callback(function()
	OBTAINED_BOOKOFDEAD = options.hd_freebookofdead
	if options.hd_ghosttime == true then
		GHOST_TIME = 9000
	end
	-- TODO: Enable once methods are merged with the WHIP build.
	set_ghost_spawn_times(GHOST_TIME, GHOST_TIME-1800)
	set_olmec_phase_y_level(0, 10.0)
	set_olmec_phase_y_level(1, 9.0)
	set_olmec_phase_y_level(2, 8.0)
	
end, ON.START)

-- ON.CAMP
set_callback(function()
	oncamp_movetunnelman()
	oncamp_shortcuts()
	
	
	-- signs_back = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_BACK)
	-- signs_front = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_FRONT)
	-- x, y, l = 49, 90, LAYER.FRONT -- next to entrance
	
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
	
end, ON.CAMP)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
end, ON.LOADING)

set_callback(function()
--ONLEVEL_PRIORITY: 1 - Set level constants (ie, init(), level feelings, levelrules)
	init()
	onlevel_levelrules()
	onlevel_detection_feeling()
	onlevel_setfeelingmessage()
--ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
	onlevel_reverse_exits()
--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	onlevel_generation_chunks()
	-- onlevel_replace_powderkegs()
	-- onlevel_generation_pushblocks() -- PLACE AFTER onlevel_generation_chunks()
--ONLEVEL_PRIORITY: 4 - Set up dangers (LEVEL_DANGERS)
	onlevel_dangers_init()
	onlevel_dangers_modifications()
	onlevel_dangers_setonce()
	set_timeout(onlevel_generation_dangers, 3)
--ONLEVEL_PRIORITY: 5 - Remaining ON.LEVEL methods (ie, IDOL_UID)
	onlevel_ghostpotandkeygen()
	onlevel_prizewheel()
	onlevel_idoltrap()
	onlevel_remove_mounts()
	-- onlevel_decorate_cookfire()
	onlevel_decorate_trees()
	onlevel_blackmarket_ankh()
	onlevel_add_wormtongue()
	onlevel_crysknife()
	onlevel_hide_yama()
	onlevel_acidbubbles()
	onlevel_add_botd()
	onlevel_boss_init()
	onlevel_coffinunlocks()
	onlevel_toastfeeling()
	
end, ON.LEVEL)

set_callback(function()
	onframe_managedangers()
	onframe_manualghostspawn()
	onframe_prizewheel()
	onframe_idoltrap()
	onframe_tonguetimeout()
	onframe_acidpoison()
	onframe_bacterium()
	onframe_boss()
end, ON.FRAME)

set_callback(function()
	onguiframe_ui_animate_botd()
	onguiframe_ui_info_boss()			-- debug
	onguiframe_ui_info_wormtongue() 	--
	onguiframe_env_animate_prizewheel()
end, ON.GUIFRAME)



-- LEVEL HANDLING
function onloading_levelrules()
	-- Dwelling 1-3 -> Dwelling 1-5(Fake 1-4)
    change_target(1,3,THEME.DWELLING,1,5,THEME.DWELLING)
    -- Dwelling -> Jungle
    change_target(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)
    -- Jungle -> Ice Caves
    change_target(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)
	-- Jungle 2-1 -> Worm 2-2
		-- TODO(? may not need to handle this)
	-- Worm(Jungle) 2-2 -> Jungle 2-4
	change_target(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
    -- Ice Caves -> Ice Caves
		-- TODO: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
    change_target(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    change_target(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    change_target(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
    -- Ice Caves -> Temple
    change_target(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)
	-- Ice Caves 3-1 -> Worm
		-- TODO(? may not need to handle this)
	-- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	change_target(3,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
    -- Temple -> Olmec
    change_target(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
    -- COG(4-3) -> Olmec
    change_target(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	-- Olmec -> Hell
	-- change_target(4,4,THEME.OLMEC,5,1,THEME.VOLCANA)
	-- Hell -> Yama
		-- TODO: Figure out a place to host Yama. Maybe a theme with different FLOOR_BORDERTILE textures?
	-- change_target(5,3,THEME.VOLCANA,5,4,???)
end

-- Specific to jungle; replace any jungle danger currently submerged in water with a tadpole.
-- Used to be part of onlevel_generation_dangers().
function onlevel_dangers_piranha()
	jungledangers = get_entities_by_type({
		ENT_TYPE.MONS_MOSQUITO,
		ENT_TYPE.MONS_WITCHDOCTOR,
		ENT_TYPE.MONS_CAVEMAN,
		ENT_TYPE.MONS_TIKIMAN,
		ENT_TYPE.MONS_MANTRAP,
		ENT_TYPE.MONS_MONKEY,
		ENT_TYPE.ITEM_SNAP_TRAP
	})
	for _, danger in ipairs(jungledangers) do
		d_mov = get_entity(danger):as_movable()
		d_submerged = test_flag(d_mov.more_flags, 11)
		if d_submerged == true then
			x, y, l = get_position(danger)
			s = spawn(ENT_TYPE.MONS_TADPOLE, x, y, l, 0, 0)--HD_ENT.PIRANHA.postspawn, x, y, l, 0, 0)
			
			-- TODO: Replace with danger_spawn()
			behavior = {}
			-- s_e = get_entity(s)
			danger_object = {
				["uid"] = s,
				["x"] = x, ["y"] = y, ["l"] = l,
				["hd_type"] = HD_ENT.PIRANHA,
				["behavior"] = behavior,
			}
			danger_tracker[#danger_tracker+1] = danger_object
			
			move_entity(danger, 0, 0, 0, 0)
		end
	end
end

-- Entities that spawn with methods that are only set once
function onlevel_dangers_setonce()
	-- loop through all dangers in global_dangers, setting enemy specifics
	if LEVEL_DANGERS[state.theme] and #global_dangers > 0 then
		for i = 1, #global_dangers, 1 do
			if global_dangers[i].removemounts ~= nil then
				if global_dangers[i].removemounts == HD_REMOVEMOUNT.SNAIL then
					set_timeout(remove_crabmounts, 5)
				end
				if global_dangers[i].removemounts == HD_REMOVEMOUNT.EGGSAC then
					set_interval(onframe_replace_grubs, 1)
				end
			end
			
			if global_dangers[i].liquidspawn ~= nil then
				if global_dangers[i].liquidspawn == HD_LIQUIDSPAWN.PIRANHA then
					onlevel_dangers_piranha()
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
		dangers_tospawn = map(global_dangers, function(entity) return entity.tospawn end)
		dangers_postspawn = map(global_dangers, function(entity) return entity.postspawn end)
		for i = 1, #global_dangers, 1 do
			toset = 0
			if dangers_tospawn[i] ~= 0 then toset = dangers_tospawn[i] end
			if dangers_postspawn[i] ~= 0 then toset = dangers_postspawn[i] end
			if toset ~= 0 then
				s = spawn(toset, 0, 0, LAYER.FRONT, 0, 0)
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
				
				apply_entity_db(s)
			end
		end
	end
end

-- DANGER MODIFICATIONS - ON.LEVEL
-- Find everything in the level within the given parameters, apply enemy modifications within parameters.
function onlevel_generation_dangers()
	if LEVEL_DANGERS[state.theme] then
		dangers_variation = map(LEVEL_DANGERS[state.theme].dangers, function(danger) return danger.variation end)
		-- dangers_tospawn = map(global_dangers, function(entity) return entity.tospawn end)
		-- dangers_toreplace = map(global_dangers, function(entity) return entity.toreplace end)
		-- dangers_type = map(global_dangers, function(entity) return entity.dangertype end)
		
		affected = get_entities_by_type(map(global_dangers, function(entity) return entity.toreplace end))--dangers_toreplace)
		local giant_enemy = false

		for i,ent in ipairs(affected) do
			e_ent = get_entity(ent)
			if e_ent ~= nil then
				e_mov = e_ent:as_movable()
				e_cont = e_ent:as_container()
				ex, ey, el = get_position(ent)
				e_type = e_cont.type.id
				-- e_submerged = test_flag(e_mov.more_flags, 11)
				
				local dangers_index = 0
				for j = 1, #global_dangers, 1 do
					if global_dangers[j].toreplace ~= nil and global_dangers[j].toreplace == e_type then dangers_index = j end
				end
				if dangers_index == 0 then toast("NO DANGER INDEX SET") end
				
				variation = nil
				for j = 1, #LEVEL_DANGERS[state.theme].dangers, 1 do
					if (
						LEVEL_DANGERS[state.theme].dangers[j].entity ~= nil and
						LEVEL_DANGERS[state.theme].dangers[j].entity.toreplace ~= nil and
						LEVEL_DANGERS[state.theme].dangers[j].entity.toreplace == e_type and
						(
							LEVEL_DANGERS[state.theme].dangers[j].variation ~= nil and
							LEVEL_DANGERS[state.theme].dangers[j].variation.entities ~= nil and
							LEVEL_DANGERS[state.theme].dangers[j].variation.chances ~= nil and
							#LEVEL_DANGERS[state.theme].dangers[j].variation.entities == 3 and
							#LEVEL_DANGERS[state.theme].dangers[j].variation.chances == 2
						)
					) then
						variation = LEVEL_DANGERS[state.theme].dangers[j].variation
					end
				end
				-- if variation == nil then toast("NO DANGER INDEX SET") end
				
				if global_dangers[dangers_index].tospawn ~= nil and global_dangers[dangers_index].tospawn ~= 0 then
					s = -1
					hd_ent_tolog = global_dangers[dangers_index]
					-- TODO: Modify to accommodate the following enemies:
						-- The Mines:
							-- Miniboss enemy: Giant spider
							-- If there's a wall to the right, don't spawn. (maybe 2 walls down, too?)
						-- The Jungle:
							-- Miniboss enemy: Giant frog
							-- If there's a wall to the right, don't spawn. (For the future when we don't replace mosquitos (or any enemy at all), try to spawn on 2-block surfaces.
					-- TODO: Move conflict detection into its own category.
					-- TODO: Add an HD_ENT property that takes an enum to set collision detection.
					if (
						global_dangers[dangers_index].dangertype ~= nil and
						global_dangers[dangers_index].dangertype >= HD_DANGERTYPE.FLOORTRAP
					) then
						local conflict = conflictdetection_trap(global_dangers[dangers_index].dangertype, ex, ey, el)
						if conflict == false then --or (conflict == true and options.hd_antitrapcuck == false) then
							-- if there is no conflict or there is conflict and the anti-cuck option is disabled, create trap
							floor_uid = e_mov.standing_on_uid
							s = spawn_entity_over(global_dangers[dangers_index].tospawn, floor_uid, 0, 1)
							if global_dangers[dangers_index].dangertype == HD_DANGERTYPE.FLOORTRAP_TALL then
								s_head = spawn_entity_over(global_dangers[dangers_index].tospawn, get_entity(s):as_movable().uid, 0, 1)
								-- TODO: Tikitrap flames on dark level. If they spawn, move each flame down 0.5.
							end
						end
					elseif (
						global_dangers[dangers_index].toreplace ~= nil and
						global_dangers[dangers_index].toreplace == e_type
					) then
						if variation ~= nil then
						
							local chance = math.random()
							if (
								chance >= variation.chances[2] and
								giant_enemy == false
							) then
								giant_enemy = true
								
								-- if variation.entities[3].tospawn == ENT_TYPE.MONS_GIANTSPIDER then
									-- s = spawn(variation.entities[3].tospawn, ex, ey-0.5, el, 0, 0)
								-- else
									s = spawn(variation.entities[3].tospawn, ex, ey, el, 0, 0)
								-- end
								-- if variation.entities[3].tospawn == ENT_TYPE.MONS_OCTOPUS then
									-- s_mov = get_entity(s):as_movable()
									-- 2.5 width, 2.5 height, 0.64 Box Width, 0.8 Box Height. Uncheck "Stunable". Set health to 8 hp.
									-- to make devil, detect block it runs into and kill it when the octopi is in it's run state, then set its stuntimer.
									
									-- s_mov.hitboxx = 0.64
									-- s_mov.hitboxy = 0.8
									-- s_mov.width = 2.5
									-- s_mov.height = 2.5
									-- s_mov.flags = clr_flag(s_mov.flags, 12)
									-- apply_entity_db(s)
								-- end
								hd_ent_tolog = variation.entities[3]
							elseif (
								(chance < variation.chances[2] and chance >= variation.chances[1]) and
								giant_enemy == false
							) then
								s = spawn(variation.entities[2].tospawn, ex, ey, el, 0, 0)
								if variation.entities[2].tospawn == ENT_TYPE.MONS_HANGSPIDER then
									spawn(ENT_TYPE.ITEM_WEB, ex, ey, el, 0, 0) -- move into HD_ENT properties
									spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, s, 0, 0) -- tikitraps can use this
								end
								hd_ent_tolog = variation.entities[2]
							else
								s = spawn(variation.entities[2].tospawn, ex, ey, el, 0, 0)
								hd_ent_tolog = variation.entities[2]
							end
							-- s = spawn(variation.entities[1].tospawn, ex, ey, el, 0, 0)
						else
							s = spawn(global_dangers[dangers_index].tospawn, ex, ey, el, 0, 0)
						end
					else
						toast("IMPOSSIBLE!!")
					end
					if s ~= -1 then
						
						danger_spawn(s, hd_ent_tolog, ex, ey, el, 0, 0)
						-- move_entity(ent, 0, 0, 0, 0)
					-- else --if you uncomment this, remove "this. 0_0"
						-- s = ent
					-- end
						-- Enemy features here
						s_mov = get_entity(s):as_movable()
						if hd_ent_tolog.color ~= nil and #hd_ent_tolog.color == 3 then
							s_mov.color.r = hd_ent_tolog.color[1]
							s_mov.color.g = hd_ent_tolog.color[2]
							s_mov.color.b = hd_ent_tolog.color[3]
						end
						if hd_ent_tolog.health ~= nil and hd_ent_tolog.health > 0 then
							s_mov.health = hd_ent_tolog.health
						end
						if hd_ent_tolog.dim ~= nil and #hd_ent_tolog.dim == 2 then
							s_mov.width = hd_ent_tolog.dim[1]
							s_mov.height = hd_ent_tolog.dim[2]
						end
						if hd_ent_tolog.hitbox ~= nil and #hd_ent_tolog.hitbox == 2 then
							s_mov.hitboxx = hd_ent_tolog.hitbox[1]
							s_mov.hitboxy = hd_ent_tolog.hitbox[2]
						end
						-- stunnable = false,-- s_mov.flags = clr_flag(s_mov.flags, 12)
						if hd_ent_tolog.stunnable ~= nil then
							if hd_ent_tolog.stunnable == true then
								s_mov.flags = set_flag(s_mov.flags, 12)
							else
								s_mov.flags = clr_flag(s_mov.flags, 12)
							end
						end
					end
					move_entity(ent, 0, 0, 0, 0) -- "this. 0_0"
				end
			end
		end
	end
end

-- CHUNK GENERATION - ON.LEVEL
-- Script-based roomcode and chunk generation
function onlevel_generation_chunks()
	-- For cases where S2 differs in roomcode generation:
		-- Determine the level dimensions based on the map bounds
			-- level: 40 wide, 32 tall
			-- roomcode size: 10 wide, 8 tall
			-- room width = 40/10 = 4
			-- room height = 32/8 = 4
		-- Obtain coordinates that reside within the room you want to replace
			-- (use a unique entity or hardcode it if it's a setroom)
			
			-- challenge: based on idol coordinates, find the roompos, then find the top left coordinates of the room it is in.
			-- idol: 38, 117
			-- find tc_x and tc_y
			
			-- e_x = 38
			-- e_y = 117
			-- topx, topy = locate_cornerpos(locate_roompos(e_x, e_y))
			-- toast("topx: " .. topx .. ", topy: " .. topy)
			
	idols = get_entities_by_type(ENT_TYPE.ITEM_IDOL)
	if #idols > 0 and HD_FEELING_RESTLESS == true then
		idolx, idoly, idoll = get_position(idols[1])
		roomx, roomy = locate_roompos(idolx, idoly)
		-- cx, cy = remove_room(roomx, roomy, idoll)
		tmp_object = {
			roomcodes = {
				"++++++++++++++++++++++00i000++0++0++0++00400000040+++0++0+++++000000++11GGGGGG11"
			},
			-- "++++++++++
			-- ++++++++++
			-- ++00i000++
			-- 0++0++0++0
			-- 0400000040
			-- +++0++0+++
			-- ++000000++
			-- 11GGGGGG11"
			dimensions = { w = 10, h = 8 }
		}
		
		roomcode = tmp_object.roomcodes[1]
		dimw = tmp_object.dimensions.w
		dimh = tmp_object.dimensions.h
		-- generate_chunk(roomcode, dimw, dimh, cx, cy, idoll, 0, 0)
		replace_room(roomcode, dimw, dimh, roomx, roomy, idoll)
	end
	
	
	
	-- For cases where S2 differs in chunk (aka subchunk) generation:
		-- use a unique tilecode in the level editor to signify chunk placement
		-- Challenge: Jungle vine chunk.
		
		-- JUNGLE - SUBCHUNK - VINE
	tmp_object = {
		roomcodes = {
			"L0L0LL0L0LL000LL0000",
			-- L0L0L
			-- L0L0L
			-- L000L
			-- L0000
			
			"L0L0LL0L0LL000L0000L",
			-- L0L0L
			-- L0L0L
			-- L000L
			-- 0000L
			
			"0L0L00L0L00L0L0000L0"
			-- 0L0L0
			-- 0L0L0
			-- 0L0L0
			-- 000L0
		},
		dimensions = { w = 5, h = 4 }
	}
		

end

-- LEVEL HANDLING
-- For cases where room generation is hardcoded to a theme's level
-- and as a result we need to fake the world/level number
function onlevel_levelrules()
	-- Dwelling 1-3 -> Dwelling 1-4
	change_level(1,5,THEME.DWELLING,1,4,THEME.DWELLING)
end

-- Reverse Level Handling
-- For cases where the entrance and exit need to be swapped
function onlevel_reverse_exits()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_timeout(exit_reverse, 15)
	end
end

function onlevel_ghostpotandkeygen()
	local cursedpot = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
	-- Udjat chest replacement using cursed pot spawn
	if #cursedpot > 0 then
		local lockedchest = get_entities_by_type(ENT_TYPE.ITEM_LOCKEDCHEST)
		local udjat_level = (#lockedchest > 0)

		pot_x, pot_y, pot_l = get_position(cursedpot[1]) -- initial pot coordinates
		if udjat_level == true and options.hd_udjat == true then
			chest_x, chest_y, chest_l = get_position(lockedchest[1]) -- move cursed pot to old chest location
			move_entity(cursedpot[1], chest_x, chest_y-4, 0, 0) -- TODO: update once layer parameter is supported
			spawn(ENT_TYPE.ITEM_LOCKEDCHEST, pot_x, pot_y, pot_l, 0, 0) -- spawn chest at initial pot coordinates
		end
		-- Ghost Jar removal
		if options.hd_nocursedpot == true then
			if udjat_level == true then
				set_timeout(function()
					local cursedpot = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
					if #cursedpot > 0 then
						kill_entity(cursedpot[1])
					end
				end, 3)
				set_timeout(function()
					kill_entity(get_entities_by_type(ENT_TYPE.MONS_GHOST)[1])
				end, 4)
				set_timeout(function()
					kill_entity(get_entities_by_type(ENT_TYPE.ITEM_DIAMOND)[1])
				end, 5)
			else
				kill_entity(cursedpot[1])
				kill_entity(get_entities_by_type(ENT_TYPE.MONS_GHOST)[1])
				kill_entity(get_entities_by_type(ENT_TYPE.ITEM_DIAMOND)[1])
			end
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
	-- Idol traps
	local idols = get_entities_by_type(ENT_TYPE.ITEM_IDOL)
	if (
		#idols > 0 and
		HD_FEELING_RESTLESS == false -- Instead, set `IDOL_UID` for the crystal skull during the scripted roomcode generation process
	) then
		IDOL_UID = idols[1]
		IDOL_X, IDOL_Y, idol_l = get_position(IDOL_UID)
		
		-- If in dwelling
		if state.theme == THEME.DWELLING then
			spawn(ENT_TYPE.BG_BOULDER_STATUE, IDOL_X, IDOL_Y+2.5, idol_l, 0, 0)
			-- set boulder stats
			-- if options.hd_boulder_phys == true then
				-- boulder_uid = spawn(ENT_TYPE.ACTIVEFLOOR_BOULDER, 0, 0, LAYER.FRONT, 0, 0)
				-- boulder = get_entity(boulder_uid)
				-- -- boulder.type.
			-- end
		elseif state.theme == THEME.JUNGLE then
			for j = 1, 6, 1 do
				blocks = get_entities_at(0, MASK.FLOOR, (math.floor(IDOL_X)-3)+j, math.floor(IDOL_Y), LAYER.FRONT, 1)
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
			if HD_FEELING_RESTLESS == false then
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
			-- else
				-- TODO: 50% chance of grabbing the FLOOR_TREE_TRUNK below `treetop` and applying a haunted face to it
			end
		end
	end
end

function onlevel_blackmarket_ankh()
	if state.theme == THEME.JUNGLE and (
		state.level == 2 or
		state.level == 3 or
		state.level == 4
	) then
		-- find the hedjet
		hedjets = get_entities_by_type(ENT_TYPE.ITEM_PICKUP_HEDJET)
		if #hedjets ~= 0 then
			-- spawn an ankh at the location of the hedjet
			hedjet = hedjets[1]
			x, y, l = get_position(hedjet)
			ankh_uid = spawn(ENT_TYPE.ITEM_PICKUP_ANKH, x-2, y, l, 0, 0)
			ankh_mov = get_entity(ankh_uid):as_movable()
			ankh_mov.flags = set_flag(ankh_mov.flags, 23)
			ankh_mov.flags = set_flag(ankh_mov.flags, 20)
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
		
		door_uid = spawn_door(x, y, l, state.world, state.level+1, THEME.EGGPLANT_WORLD)
		lock_door_at(x, y)
		
		
		TONGUE_STATE = TONGUE_SEQUENCE.READY
		-- toast("door_uid:" .. tostring(door_uid))
		
		set_timeout(function()
			x, y, l = get_position(TONGUE_UID)
			door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				door_platform.flags = set_flag(door_platform.flags, 1)
				door_platform.flags = clr_flag(door_platform.flags, 3)
				door_platform.flags = clr_flag(door_platform.flags, 8)
			else toast("No Worm Door platform found") end
		end, 2)
	else
		toast("No STICKYTRAP_BALL found, no tongue generated.")
		kill_entity(stickytrap_uid)
		TONGUE_STATE = TONGUE_SEQUENCE.GONE
	end
end

function onlevel_add_wormtongue()
	-- Worm tongue generation
	-- Placement is currently done with stickytraps placed in the level editor (at least for jungle)
	-- TODO: For all path generation blocks (include side?) (with space of course), add a unique tile to detect inside on.level
	-- On loading the first jungle or ice cave level, find all of the unique entities spawned, select a random one, and spawn the worm tongue.
	-- Then kill all of said unique entities.
	-- ALTERNATIVE: Move into onlevel_generation_chunks(); find all blocks that have 2 spaces above it free, pick a random one, then spawn the worm tongue.

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
				kill_entity(tonguepoint_uid, 0, 0, 0, 0)
			end
			if random_uid == -1 then
				toast("No worm for you. YEOW!! (random_uid could not be set)")
			end
		else
			for _, tonguepoint_uid in ipairs(tonguepoints) do kill_entity(tonguepoint_uid, 0, 0, 0, 0) end
		end
	end
end

function onlevel_acidbubbles()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_interval(bubbles, 40) -- 15)
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
		if not options.hd_freebookofdead then
			bookofdead_pickup_id = spawn(ENT_TYPE.ITEM_PICKUP_TABLETOFDESTINY, 6, 99.05, LAYER.FRONT, 0, 0)
			book_ = get_entity(bookofdead_pickup_id):as_movable()
			book_.animation_frame = 205
		end
	end
end

function onlevel_boss_init()
	if state.theme == THEME.OLMEC then
		BOSS_STATE = BOSS_SEQUENCE.CUTSCENE
		onlevel_olmec_cutscene_moveolmec()
		onlevel_olmec_cutscene_movecavemen()
		onlevel_add_endingdoor(41, 99)
		onlevel_add_helldoor()
	end
	-- Olmec/Yama Win
	exit_winstate()
end

function onlevel_add_endingdoor(x, y)
	-- TODO: Remove exit door from the editor and spawn it manually here.
	-- Why? Currently the exit door spawns tidepool-specific critters and ambience sounds, which will probably go away once an exit door isn't there initially.
	-- ALTERNATIVE: kill ambient entities and critters. May allow compass to work.
	-- TODO: Test if the compass works for this
	exitdoor = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, LAYER.FRONT, 0, 0)
	set_door_target(exitdoor, 4, 2, THEME.TIAMAT)
	if options.hd_unlockbossexit == false then
		lock_door_at(x, y)
	end
end

function onlevel_olmec_cutscene_moveolmec()
	olmecs = get_entities_by_type(ENT_TYPE.ACTIVEFLOOR_OLMEC)
	if #olmecs > 0 then
		OLMEC_ID = olmecs[1]
		move_entity(olmecs[1], 24.500, 100.500, 0, 0)
	else toast("AGH no olmec found :(") end
end

function onlevel_olmec_cutscene_movecavemen()
	-- TODO: Once custom hawkman AI is done:
	-- create a hawkman and disable his ai
	-- set_timeout() to reenable his ai and set his stuntimer.
	-- **does set_timeout() work during cutscenes?
	-- **does set_timeout() account for pausing the game?
	-- **consider problems for skipping the cutscene
	cavemen = get_entities_by_type(ENT_TYPE.MONS_CAVEMAN)
	for i, caveman in ipairs(cavemen) do
		move_entity(caveman, 17.500+i, 99.05, 0, 0)
	end
end

-- function onlevel_replace_powderkegs()
	-- if state.theme == THEME.VOLCANA then
		-- TODO: Maybe, in order to save memory, merge this with onlevel_generation_chunks
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

function onlevel_add_helldoor()
	if state.theme == THEME.OLMEC then
		HELL_X = math.random(4,41)
		door_target = spawn(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, HELL_X, 87, LAYER.FRONT, 0, 0)
		set_door_target(door_target, 5, 1, THEME.VOLCANA)
		
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
end


function onlevel_detection_feeling()
	if state.theme == THEME.DWELLING then
		-- Spider's Lair
		giant_spiders = get_entities_by_type(ENT_TYPE.MONS_GIANTSPIDER)
		if #giant_spiders >= 4 then
			HD_FEELING_SPIDERLAIR = true
			-- TODO: pots will not spawn on this level.
			-- Spiders, spinner spiders, and webs appear much more frequently.
			-- Spawn web nests (probably RED_LANTERN and reskin it)
			-- Replace pots with spiders(?)
		else
			for spid_i = #giant_spiders-1, 1, -1 do
				move_entity(giant_spiders[spid_i], 0, 0, 0, 0)
			end
		end
	elseif (
		state.theme == THEME.JUNGLE or
		state.theme == THEME.VOLCANA or
		state.theme == THEME.TEMPLE or
		state.theme == THEME.TIDEPOOL
	) then
		tombstones = get_entities_by_type(ENT_TYPE.DECORATION_TOMB)
		if #tombstones > 0 then
			HD_FEELING_RESTLESS = true
		end
	end
end

function onlevel_setfeelingmessage()
	-- theme message priorities are here (ie; rushingwater over restless)
	if HD_FEELING_SPIDERLAIR == true then
		MESSAGE_FEELING = "My skin is crawling..."
	end
	if HD_FEELING_RESTLESS == true then
		MESSAGE_FEELING = "The dead are restless!"
	end
end

function onlevel_toastfeeling()
	if MESSAGE_FEELING ~= nil and options.hd_toastfeeling == true then
		if (
			HD_FEELING_SPIDERLAIR == true or
			HD_FEELING_RESTLESS == true or -- TOTEST: See whether or not this conflicts with the feeling message the game already toasts.
			options.hd_nocursedpot == true -- a feeble attempt to prevent ghost pot breaking message from playing. TOTEST.
		) then
			toast(MESSAGE_FEELING)
		end
	end
end

function onlevel_coffinunlocks()
-- coffin replacement
	if #players == 1 then
		coffins = get_entities_by_type(ENT_TYPE.ITEM_COFFIN)
		if #coffins > 0 then
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
			
			
			if state.theme == THEME.OLMEC then
				set_contents(coffins[1], ENT_TYPE.CHAR_DIRK_YAMAOKA)
			elseif state.theme == THEME.EGGPLANT_WORLD then
				-- todo: replace with ITEM_ANUBIS_COFFIN
				set_contents(coffins[1], ENT_TYPE.CHAR_PILOT)
				coffin_e = get_entity(coffins[1])
				coffin_e.flags = set_flag(coffin_e.flags, 10)
				coffin_m = coffin_e:as_movable()
				-- coffin_m.animation_frame = 0
				coffin_m.velocityx = 0
				coffin_m.velocityy = 0
			elseif state.theme == THEME.JUNGLE then
				set_contents(coffins[1], ENT_TYPE.CHAR_OTAKU)
			elseif state.theme == THEME.ICE_CAVES then
				-- TODO: Find way to distinguish coffins
				set_contents(coffins[1], ENT_TYPE.CHAR_COCO_VON_DIAMONDS)
				-- set_contents(coffins[2], ENT_TYPE.CHAR_LISE_SYSTEM)
				coffin_e = get_entity(coffins[1])
			end
		end
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
	
	doors_or_constructionsigns = {}
	doors_floors = {}
	doors_bgs = {}
	doors_signs = {}
	shortcut_worlds = {4, 3, 2}
	shortcut_levels = {1, 1, 1}
	shortcut_themes = {THEME.TEMPLE, THEME.ICE_CAVES, THEME.JUNGLE}
	-- shortcut_doorframes = {1, 1, 1}
	x = 21.0
	for y = 90, 84, -3 do
		doors_or_constructionsigns = TableConcat(doors_or_constructionsigns, get_entities_at(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, 0, x, y, LAYER.FRONT, 0.5))
		doors_or_constructionsigns = TableConcat(doors_or_constructionsigns, get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, y, LAYER.FRONT, 0.5))
		doors_floors = TableConcat(doors_floors, get_entities_at(ENT_TYPE.FLOOR_DOOR_STARTING_EXIT, 0, x, y, LAYER.FRONT, 0.5))
		doors_bgs = TableConcat(doors_bgs, get_entities_at(ENT_TYPE.BG_DOOR, 0, x, y, LAYER.FRONT, 0.5))
		doors_signs = TableConcat(doors_signs, get_entities_at(ENT_TYPE.ITEM_SHORTCUT_SIGN, 0, x+2.0, y, LAYER.FRONT, 0.5))
	end
	-- Placement of first shortcut door in HD: 16.0
	new_x = 19.0 -- adjusted for S2 camera
	for i = #doors_or_constructionsigns, 1, -1 do
		-- door_or_constructionsign
		if get_entity(doors_or_constructionsigns[i]):as_container().type.id == ENT_TYPE.LOGICAL_DOOR then
			kill_entity(doors_or_constructionsigns[i])
			spawn_door(new_x, 86, LAYER.FRONT, shortcut_worlds[i], shortcut_levels[i], shortcut_themes[i])
			move_entity(doors_floors[i], new_x, 86, 0, 0)
			move_entity(doors_signs[i], new_x+1, 86, 0, 0)
			
			move_entity(doors_bgs[i], new_x, 86.31, 0, 0)
			-- get_entity(doors_bgs[i]):as_movable().animation_frame = shortcut_doorframes[i]
			
		else
			move_entity(doors_or_constructionsigns[i], new_x, 86, 0, 0)
		end
		-- Space between shortcut doors in HD: 4.0
		new_x = new_x + 3 -- adjusted for S2 camera
	end
	
	-- door_bg_frame = get_entity(doors_bgs[3]):as_movable().animation_frame
	-- toast("third door_bg_frame: " .. door_bg_frame)
	
	spawn(ENT_TYPE.FLOOR_GENERIC, 21, 84, LAYER.FRONT, 0, 0)
	spawn(ENT_TYPE.FLOOR_GENERIC, 23, 84, LAYER.FRONT, 0, 0)
	-- TODO: Remove destroyed block artifacts surrounding these blocks
	
end

function onframe_manualghostspawn()
	if (
		(options.hd_nocursedpot == true) and
		(state.time_level > GHOST_TIME) and
		(GHOST_SPAWNED == false) and
		(blacklist_level_noghost())
	) then
		create_ghost()
		GHOST_SPAWNED = true
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
		if HD_FEELING_RESTLESS == true then
			create_ghost()
		elseif state.theme == THEME.DWELLING and IDOL_X ~= nil and IDOL_Y ~= nil then
			spawn(ENT_TYPE.LOGICAL_BOULDERSPAWNER, IDOL_X, IDOL_Y, idol_l, 0, 0)
		elseif state.theme == THEME.JUNGLE then
			-- break the 6 blocks under it in a row, starting with the outside 2 going in
			if #idoltrap_blocks > 0 then
				kill_entity(idoltrap_blocks[1])
				kill_entity(idoltrap_blocks[6])
				-- TODO: TEST THIS INSTEAD:
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
					local damsel = get_entity(damsels[1]):as_movable()
					-- when alive damsel move_state == 9 for 4 seconds?
					-- toast("damsel.move_state: " .. tostring(damsel.state))
					local falling = (damsel.state == 9)
					local dead = test_flag(damsel.flags, 29)
					if (
						(dead == false and falling == true)
						-- or (dead == true and ) -- TODO: Find some way to detect a dead pet that's not in a spelunker's arms
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
			if test_flag(damsel.flags, 29) == false then
				damsel.stun_timer = 0
				if options.hd_show_ducttapeenemies == false then
					damsel.flags = set_flag(damsel.flags, 1)
				end
				damsel.flags = clr_flag(damsel.flags, 21)-- disable interaction with webs
				-- damsel.flags = clr_flag(damsel.flags, 12)-- disable stunable
				damsel.flags = set_flag(damsel.flags, 4)--6)-- enable take no damage
				move_entity(damsel_uid, exit_x, exit_y+0.1, 0, 0)
			end
		end
		
		if #ensnaredplayers > 0 then
			-- unlock worm door, let players in
			unlock_door_at(x, y)
			local door_platforms = get_entities_at(ENT_TYPE.FLOOR_DOOR_PLATFORM, 0, x, y, l, 1.5)
			if #door_platforms > 0 then
				door_platform = get_entity(door_platforms[1])
				if options.hd_show_ducttapeenemies == true then
					door_platform.flags = clr_flag(door_platform.flags, 1)
				end
				door_platform.flags = set_flag(door_platform.flags, 3)
				door_platform.flags = set_flag(door_platform.flags, 8)
			end
			
			for _, ensnaredplayer_uid in ipairs(ensnaredplayers) do
				ensnaredplayer = get_entity(ensnaredplayer_uid):as_movable()
				-- TODO:
				ensnaredplayer.stun_timer = 0
				-- ensnaredplayer.more_flags = set_flag(ensnaredplayer.more_flags, 16)-- disable input
				
				if options.hd_show_ducttapeenemies == false then
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
						if options.hd_show_ducttapeenemies == true then
							door_platform.flags = set_flag(door_platform.flags, 1)
						end
						door_platform.flags = clr_flag(door_platform.flags, 3)
						door_platform.flags = clr_flag(door_platform.flags, 8)
					end
				end
				lock_door_at(x, y)
			end, 55)
		end
		
		-- hide worm tongue
		tongue = get_entity(TONGUE_UID)
		if options.hd_show_ducttapeenemies == false then
			tongue.flags = set_flag(tongue.flags, 1)
		end
		tongue.flags = set_flag(tongue.flags, 4)-- disable interaction with objects
		
	else
		toast("NO EXIT DOOR can't move damsels to exit")
	end
end

-- Specific to jungle; replace any jungle danger currently submerged in water with a tadpole.
-- Used to be part of onlevel_generation_dangers().
function onframe_replace_grubs()
	grubs = get_entities_by_type({
		ENT_TYPE.MONS_GRUB,
	})
	for _, danger in ipairs(grubs) do
		d_mov = get_entity(danger):as_movable()
		x, y, l = get_position(danger)
		s = spawn(ENT_TYPE.MONS_MOLE, x, y, l, d_mov.velocityx, d_mov.velocityy)--HD_ENT.PIRANHA.postspawn, x, y, l, 0, 0)
		-- TODO: Replace with danger_spawn()
		behavior = {}
		danger_object = {
			["uid"] = s,
			["x"] = x, ["y"] = y, ["l"] = l,
			["hd_type"] = HD_ENT.WORMBABY,
			["behavior"] = behavior,
		}
		danger_tracker[#danger_tracker+1] = danger_object
		
		move_entity(danger, 0, 0, 0, 0)
	end
end

-- DANGER MODIFICATIONS - ON.FRAME
-- Massive enemy behavior handling method
function onframe_managedangers()
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
						danger.hd_type.kill_on_standing == KILL_ON.STANDING and
						danger_mov.standing_on_uid ~= -1
					) or
					(
						danger.hd_type.kill_on_standing == KILL_ON.STANDING_OUTOFWATER and
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
			if danger_tracker[i].hd_type.itemdrop ~= nil then -- if dead and has possible item drops
				if danger_tracker[i].hd_type.itemdrop.item ~= nil and #danger_tracker[i].hd_type.itemdrop.item > 0 then
					if (
						danger_tracker[i].hd_type.itemdrop.chance == nil or
						(
							danger_tracker[i].hd_type.itemdrop.chance ~= nil and
							-- danger_tracker[i].itemdrop.chance > 0 and
							math.random() <= danger_tracker[i].hd_type.itemdrop.chance
						)
					) then
						spawn(danger_tracker[i].hd_type.itemdrop.item[math.random(1, #danger_tracker[i].hd_type.itemdrop.item)], danger.x, danger.y, danger.l, 0, 0)
					end
				end
			end
			if danger_tracker[i].hd_type.treasuredrop ~= nil then -- if dead and has possible item drops
				if danger_tracker[i].hd_type.treasuredrop.item ~= nil and #danger_tracker[i].hd_type.treasuredrop.item > 0 then
					if (
						danger_tracker[i].hd_type.treasuredrop.chance == nil or
						(
							danger_tracker[i].hd_type.treasuredrop.chance ~= nil and
							-- danger_tracker[i].treasuredrop.chance > 0 and
							math.random() <= danger_tracker[i].hd_type.treasuredrop.chance
						)
					) then
						spawn(danger_tracker[i].hd_type.treasuredrop.item[math.random(1, #danger_tracker[i].hd_type.treasuredrop.item)], danger.x, danger.y, danger.l, 0, 0)
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
-- loop through and disable behavior_uids unless it happends to be the behavior or the master uid
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
		-- TODO: Move to onframe_managedangers
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
				blocks = get_entities_at(ENT_TYPE.FLOORSTYLED_STONE, 0, 21+b, 98, LAYER.FRONT, 0.5)
				if #blocks > 0 then
					kill_entity(blocks[1])
				end
				b = b + 1
			end
			move_entity(OLMEC_ID, 22.500, 99.500, 0, 0)--24.500, 100.500, 0, 0)
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
		else toast("AGH no olmec found :(") end
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
		-- OLMEC_SEQUENCE = { ["STILL"] = 1, ["JUMP"] = 2, ["MIDAIR"] = 3, ["FALL"] = 4 }
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
	else toast("AGHHHH olmec is nil :(") end
end

function olmec_attack(x, y, l)
	s = spawn_entity(ENT_TYPE.ITEM_TIAMAT_SHOT, x, y, l, 0, 150)
	-- Enable "collides walls", uncheck "No Gravity", uncheck "Passes through objects".
	danger_setflags(s, { 13 }, { 4, 10 })
	
	xvel = math.random(7, 30)/100
	yvel = math.random(5, 10)/100
	if math.random() >= 0.5 then xvel = -1*xvel end
	olmec_shot_object = {
		["uid"] = s,
		["x"] = x, ["y"] = y, ["l"] = l,
		["hd_type"] = HD_ENT.OLMEC_SHOT,
		["behavior"] = TableCopy(HD_BEHAVIOR.OLMEC_SHOT)
	}
	olmec_shot_object.behavior.velocityx = xvel
	olmec_shot_object.behavior.velocityy = yvel
	danger_tracker[#danger_tracker+1] = olmec_shot_object
	
end

function danger_spawn(uid, hd_type, x, y, l, vx, vy)
	-- **This stuff is already delt with in onlevel_dangers_modifications.
	-- If spawning manually, use stuff like this outside dangers_spawn().
		-- if hd_type == HD_ENT.SNAIL then
			-- set_timeout(remove_crabmounts, 5)
		-- end
	
	
	behavior = {}
	if hd_type.behavior ~= nil then
		behavior = TableCopy(hd_type.behavior)
		-- if hd_type.behavior.abilities ~= nil then
			if hd_type.behavior == HD_BEHAVIOR.SCORPIONFLY then
				-- TODO: Ask the discord if it's actually possible to check if a variable exists even if it's set to nil
				-- The solution is probably assigning ability parameters by setting the variable to -1
					-- (which I CAN do in this situation considering it's a uid field)
				-- ACTUALLYYYYYYYYYYYY The solution is probably using string indexes(I'm probably butchuring the terminology)
					-- For instance; "for string, value in pairs(hd_type.behavior.abilities) do if string == "bat_uid" then toast("BAT!!") end end"
				
				-- if hd_type.behavior.abilities.agro.bat_uid ~= nil then
					
					behavior.bat_uid = spawn(ENT_TYPE.MONS_BAT, x, y, l, 0, 0)--behavior.abilities.agro.bat_uid = spawn(ENT_TYPE.MONS_BAT, x, y, l, 0, 0)
					danger_setflags(behavior.bat_uid, { 1, 6, 25 })
				
				-- end
				-- if hd_type.behavior.abilities.idle.mosquito_uid ~= nil then
					
					-- behavior.abilities.idle.mosquito_uid = spawn(ENT_TYPE.MONS_MOSQUITO, x, y, l, 0, 0)
					-- ability_e = get_entity(behavior.abilities.idle.mosquito_uid)
					-- if options.hd_show_ducttapeenemies == false then
						-- ability_e.flags = set_flag(ability_e.flags, 1)
					-- end
					-- ability_e.flags = set_flag(ability_e.flags, 6)
					-- ability_e.flags = set_flag(ability_e.flags, 25)
					
				-- end
				
					-- toast("#behavior.abilities: " .. tostring(#behavior.abilities))
			end
		-- end
	end
	-- s_e = get_entity(s)
	danger_object = {
		["uid"] = uid,
		["x"] = x, ["y"] = y, ["l"] = l,
		["hd_type"] = hd_type,
		["behavior"] = behavior
	}
	danger_tracker[#danger_tracker+1] = danger_object
end

function danger_setflags(uid_assignto, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	ability_e = get_entity(uid_assignto)
	for _, flag in ipairs(flags_set) do
		if (
			flag ~= 1 or
			(flag == 1 and options.hd_show_ducttapeenemies == false)
		) then
			ability_e.flags = set_flag(ability_e.flags, flag)
		end
	end
	for _, flag in ipairs(flags_clear) do
		ability_e.flags = clr_flag(ability_e.flags, flag)
	end
end

function onframe_boss_wincheck()
	if BOSS_STATE == BOSS_SEQUENCE.FIGHT then
		olmec = get_entity(OLMEC_ID):as_olmec()
		if olmec ~= nil then
			if olmec.attack_phase == 3 then
				-- TODO: play cool win jingle
				toast("big dummy hed is ded")
				BOSS_STATE = BOSS_SEQUENCE.DEAD
				unlock_door_at(41, 99)
			end
		else toast("AGHHHH olmec is nil :(") end
	end
end

function onguiframe_ui_info_boss()
	if options.hd_boss_info == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if state.theme == THEME.OLMEC and OLMEC_ID ~= nil then
			olmec = get_entity(OLMEC_ID)
			if olmec ~= nil then
				-- code adapted from olmec.lua
				olmec = get_entity(OLMEC_ID):as_olmec()
				text_x = -0.95
				text_y = -0.50
				white = rgba(255, 255, 255, 255)
				-- OLMEC_SEQUENCE = { ["STILL"] = 1, ["JUMP"] = 2, ["MIDAIR"] = 3, ["FALL"] = 4 }
				olmec_attack_state = "UNKNOWN"
				if OLMEC_STATE == OLMEC_SEQUENCE.STILL then olmec_attack_state = "STILL"
				-- elseif OLMEC_STATE == OLMEC_SEQUENCE.JUMP then olmec_attack_state = "JUMP"
				-- elseif OLMEC_STATE == OLMEC_SEQUENCE.MIDAIR then olmec_attack_state = "MIDAIR"
				elseif OLMEC_STATE == OLMEC_SEQUENCE.FALL then olmec_attack_state = "FALL" end
				draw_text(text_x, text_y, 0, "Custom Olmec State Detection: " .. olmec_attack_state, white)
			else toast("AGHHHH olmec is nil :(") end
		end
	end
end

function onguiframe_ui_info_wormtongue()
	if options.hd_wormtongue_info == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
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
			local w = options.bod_w
			local h = options.bod_h
			local x = options.bod_x
			local y = options.bod_y
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
			draw_image(UI_BOOKOFDEAD_ID, x, y, x+w, y-h, uvx1, uvy1, uvx2, uvy2, 0xffffffff)
		elseif entity_has_item_type(players[1].uid, ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) then
			toast("Death to the defiler!")
			OBTAINED_BOOKOFDEAD = true
			set_timeout(function()
				tabletpowerup_uids = get_entities_by_type(ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY)
				if #tabletpowerup_uids > 0 then
					entity_remove_item(players[1].uid, tabletpowerup_uids[1])
				end
			end, 1)
		end
	end
end



-- SHOPS
-- Hiredhand shops have 1-3 hiredhands
-- Damzel for sale: The price for a kiss will be $8000 in The Mines, and it will increase by $2000 every area, so the prices will be $8000, $10000, $12000 and $14000 for a Damsel kiss in the four areas shops can spawn in. The price for buying the Damsel will be an extra 50% over the kiss price, making the prices $12000, $15000, $18000 and $21000 for all zones.

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
--  - If runs into player while frozen, damage player.

-- TEMPLE
-- ENEMIES:
-- Hawk man: Shopkeeper clone without shotgun (Or non teleporting Croc Man???)

-- LEVEL:
-- Move unlock coffin to frontlayer
-- Script in hell door spawning
-- The Book of the Dead on the player's HUD will writhe faster the closer the player is to the X-coordinate of the entrance (HELL_X)
-- 

-- SCRIPTED ROOMCODE GENERATION
	-- IDEAS:
		-- In a 2d list loop for each room to replace:
			-- 1: log a 2d table of the level path and rooms to replace
				-- Conflicts may include shops, vaults, missing exits
				-- Based on HD_SUBCHUNKID, log subchunk ids as generated by the game. Log in separate 2d array `rooms_subchunkids`:
						-- 0: Non-main path subchunk
						-- 1: Main path, goes L/R (also entrance/exit)
						-- 2: Main path, goes L/R and down (and up if it's below another 2)
						-- 3: Main path, goes L/R and up
				-- Otherwise, here's where script-determined level paths would be managed
				-- As you loop over each room, log in separate 2d array `rooms_replaceids`:
					-- 0: Don't touch this room.
					-- 1: Replace this toom.
					-- 2: Maintain this room's structure and find a new place to move it to.
					-- 3: Maintain this room's structure and find a new place to move it to. Maintain its orientation in relation to the path.
				-- Once finished, log which rooms need to be flipped. loop over the path and log in separate 2d array `rooms_orientids`:
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
			-- 3: Generate rooms, log generated rooms
				-- Parameters
					-- optional table of ENT_TYPE
					-- Path
				-- Determine rooms with global list constant (same way as LEVEL_DANGERS[state.theme]) and the current room
				-- append each table into a 2d array based on the room they occupied
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
