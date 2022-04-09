-- commonlib = require 'common'

local module = {}

module.HD_COLLISIONTYPE = {
	AIR_TILE_1 = 1,
	AIR_TILE_2 = 2,
	FLOORTRAP = 3,
	FLOORTRAP_TALL = 4,
	GIANT_FROG = 5,
	GIANT_SPIDER = 6,
}

module.HD_DANGERTYPE = {
	CRITTER = 1,
	ENEMY = 2,
	FLOORTRAP = 3,
	FLOORTRAP_TALL = 4
}
module.HD_LIQUIDSPAWN = {
	PIRANHA = 1,
	MAGMAMAN = 2
}
module.HD_REMOVEINVENTORY = {
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
module.HD_REPLACE = {
	EGGSAC = 1
}
module.HD_KILL_ON = {
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
module.HD_BEHAVIOR = {
	-- IDEAS:
		-- Disable monster attacks.
			-- monster = get_entity():as_chasingmonster
			-- monster.chased_target_uid = 0
	OLMEC_SHOT = {
		velocity_set = {
			velocityx = nil,
			velocityy = nil,
			timer = 25
		}
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
			-- if killed immediately, imp_uid still exists.
			-- # TOTEST: see if abilities can still be killed by the camera flash
			imp_uid = nil,--agro = { imp_uid = nil },
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
	-- create_hd_type
		-- Supported Variables:
			-- dangertype
				-- Determines multiple factors required for certain dangers, such as spawn_entity_over().
			-- collisiontype
				-- Determines collision detection on creation of an module.HD_ENT. collision detection.
	-- onframe_manage_dangers
		-- Supported Variables:
			-- kill_on_standing = 
				-- module.HD_KILL_ON.STANDING
					-- Once standing on a surface, kill it.
				-- module.HD_KILL_ON.STANDING_OUTOFWATER
					-- Once standing on a surface and not submerged, kill it.
			-- itemdrop = { item = {HD_ENT, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
			-- treasuredrop = { item = {HD_ENT, etc...}, chance = 0.0 }
				-- on it not existing in the world, have a chance to spawn a random item where it previously existed.
module.HD_ENT = {
    ITEM_IDOL = {
        tospawn = ENT_TYPE.ITEM_IDOL
    },
    ITEM_CRYSTALSKULL = {
        tospawn = ENT_TYPE.ITEM_MADAMETUSK_IDOL
    },
    ITEM_PICKUP_SPRINGSHOES = {
        tospawn = ENT_TYPE.ITEM_PICKUP_SPRINGSHOES
    },
    ITEM_FREEZERAY = {
        tospawn = ENT_TYPE.ITEM_FREEZERAY
    },
    ITEM_SAPPHIRE = {
        tospawn = ENT_TYPE.ITEM_SAPPHIRE
    },
    FROG = {
        tospawn = ENT_TYPE.MONS_FROG,
        dangertype = module.HD_DANGERTYPE.ENEMY
    },
    FIREFROG = {
        tospawn = ENT_TYPE.MONS_FIREFROG,
        dangertype = module.HD_DANGERTYPE.ENEMY
    },
    SNAIL = {
        tospawn = ENT_TYPE.MONS_HERMITCRAB,
        dangertype = module.HD_DANGERTYPE.ENEMY,
        health_db = 1,
        leaves_corpse_behind = false,
        removeinventory = module.HD_REMOVEINVENTORY.SNAIL,
    },
    PIRANHA = {
        tospawn = ENT_TYPE.MONS_TADPOLE,
        dangertype = module.HD_DANGERTYPE.ENEMY,
        liquidspawn = module.HD_LIQUIDSPAWN.PIRANHA,
        -- sprint_factor = -1,
        -- max_speed = -1,
        -- acceleration = -1,
        kill_on_standing = module.HD_KILL_ON.STANDING_OUTOFWATER
    },
    WORMBABY = {
        tospawn = ENT_TYPE.MONS_MOLE,
        dangertype = module.HD_DANGERTYPE.ENEMY,
        health_db = 1,
        leaves_corpse_behind = false,
    },
    EGGSAC = {
        tospawn = ENT_TYPE.ITEM_EGGSAC,
        dangertype = module.HD_DANGERTYPE.FLOORTRAP,
        collisiontype = module.HD_COLLISIONTYPE.FLOORTRAP,
        replaceoffspring = module.HD_REPLACE.EGGSAC
    },
    TRAP_TIKI = {
        tospawn = ENT_TYPE.FLOOR_TOTEM_TRAP,
        entitydb = ENT_TYPE.ITEM_TOTEM_SPEAR,
        dangertype = module.HD_DANGERTYPE.FLOORTRAP_TALL,
        collisiontype = module.HD_COLLISIONTYPE.FLOORTRAP_TALL,
        damage = 4
        -- # TODO: Tikitrap flames on dark level. If they spawn, move each flame down 0.5.
    },
    CRITTER_RAT = {
        tospawn = ENT_TYPE.MONS_CRITTERDUNGBEETLE,
        dangertype = module.HD_DANGERTYPE.CRITTER,
        max_speed = 0.05,
        acceleration = 0.05
    },
    CRITTER_FROG = { -- # TODO: critter jump/idle behavior
        tospawn = ENT_TYPE.MONS_CRITTERLOCUST,
        dangertype = module.HD_DANGERTYPE.CRITTER,
        -- # TODO: Make jumping script, adjust movement EntityDB properties
        -- behavior = module.HD_BEHAVIOR.CRITTER_FROG,
    },
    SPIDER = {
        tospawn = ENT_TYPE.MONS_SPIDER,
        dangertype = module.HD_DANGERTYPE.ENEMY
    },
    HANGSPIDER = {
        tospawn = ENT_TYPE.MONS_HANGSPIDER,
        dangertype = module.HD_DANGERTYPE.ENEMY
    },
    GIANTSPIDER = {
        tospawn = ENT_TYPE.MONS_GIANTSPIDER,
        dangertype = module.HD_DANGERTYPE.ENEMY,
        collisiontype = module.HD_COLLISIONTYPE.GIANT_SPIDER,
        offset_spawn = {0.5, 0}
    },
    SCORPIONFLY = {
        tospawn = ENT_TYPE.MONS_SCORPION,
        dangertype = module.HD_DANGERTYPE.ENEMY,
        behavior = module.HD_BEHAVIOR.SCORPIONFLY,
        color = { 0.902, 0.176, 0.176 },
        removeinventory = module.HD_REMOVEINVENTORY.SCORPIONFLY
    }
}
-- Devil Behavior:
	-- when the octopi is in it's run state, use get_entities_overlapping() to detect the block {ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK} it runs into.
		-- then kill block, set octopi stuntimer.
-- DEVIL = {
	-- tospawn = ENT_TYPE.MONS_OCTOPUS,
	-- toreplace = ?,
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- sprint_factor = 7.0
	-- max_speed = 7.0
-- },
-- MAMMOTH = { -- # TODO: Frozen Immunity: if set, set on frame `as_movable().frozen_timer = 0`
	-- tospawn = ENT_TYPE.MONS_GIANTFLY,
	-- toreplace = ?,
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_GIANTFLY,
	-- behavior = module.HD_BEHAVIOR.MAMMOTH,
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
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- behavior = module.HD_BEHAVIOR.HAWKMAN
-- },
-- GREENKNIGHT = {
	-- tospawn = ENT_TYPE.MONS_OLMITE_BODYARMORED,
	-- toreplace = ENT_TYPE.MONS_CAVEMAN,
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_OLMITE_BODYARMORED,
	-- behavior = module.HD_BEHAVIOR.GREENKNIGHT,
	-- stompdamage = false, -- (?)
-- },
-- NOTE: Shopkeeperclones are immune to whip damage, while the black knight in HD wasn't.
	-- May be able to override this by syncing the stun of a duct-taped entity (ie, if caveman is stunned, shopkeeperclone.stun_timer = 10)
		-- Might as well use a caveman for the master, considering that in HD when the blackknight drops his shield, he behaves like a green knight (so, a caveman)
-- BLACKKNIGHT = {
	-- tospawn = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- entitydb = ENT_TYPE.MONS_CAVEMAN,--ENT_TYPE.MONS_SHOPKEEPERCLONE,
	-- behavior = module.HD_BEHAVIOR.BLACKKNIGHT,
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

-- # TODO: Test/Implement Giant Frog.
	-- Creation
		-- Use a regular frog for the behavior
		-- Use a giant fly for the base
				-- PROBLEM: MONS_GIANTFLY eats frogs when near them. Determine potential alternative.
		-- Modify the behavior system to specify which ability uid is the visible one (make all other abilities invisible)
			-- Furthermore, modify it so you can allow scenarios like the greenknight happen;
				-- GreenKnight: once taken damage, remove abilities. If all abilities are removed, make caveman visible
	-- Behavior:
		-- On move_state == 6 (jump), run a random chance to spit out a frog instead. velocityx = 0 and velocityy = 0.
		-- When it's within a short distance of the player and when d_mov.standing_on_uid ~= -1 and when not facing the player, flip_entity()
-- GIANTFROG = {
	-- tospawn = ENT_TYPE.MONS_GIANTFLY,
	-- dangertype = module.HD_DANGERTYPE.ENEMY,
	-- health = 8,
	-- entitydb = ENT_TYPE.MONS_GIANTFLY,
	-- behavior = module.HD_BEHAVIOR.GIANTFROG,
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
module.HD_ENT.OLDBITEY = {
	tospawn = ENT_TYPE.MONS_GIANTFISH,
	dangertype = module.HD_DANGERTYPE.ENEMY,
	collisiontype = module.HD_COLLISIONTYPE.GIANT_FISH,
	itemdrop = {
		item = {module.HD_ENT.ITEM_IDOL},--ENT_TYPE.ITEM_IDOL},
		chance = 1
	}
}
module.HD_ENT.OLMEC_SHOT = {
	tospawn = ENT_TYPE.ITEM_TIAMAT_SHOT,
	dangertype = module.HD_DANGERTYPE.ENEMY,
	kill_on_standing = module.HD_KILL_ON.STANDING,
	behavior = module.HD_BEHAVIOR.OLMEC_SHOT,
	itemdrop = {
		item = {
			module.HD_ENT.FROG,--ENT_TYPE.MONS_FROG,
			module.HD_ENT.FIREFROG,--ENT_TYPE.MONS_FIREFROG,
			-- module.HD_ENT.,--ENT_TYPE.MONS_MONKEY,
			-- module.HD_ENT.,--ENT_TYPE.MONS_SCORPION,
			-- module.HD_ENT.,--ENT_TYPE.MONS_SNAKE,
			-- module.HD_ENT.,--ENT_TYPE.MONS_BAT
		},
		chance = 1.0
	},
	-- Enable "collides walls", uncheck "No Gravity", uncheck "Passes through objects".
	flags = {
		{13},
		{4, 10}
	},
}

module.TRANSITION_CRITTERS = {
	[THEME.DWELLING] = {
		entity = module.HD_ENT.CRITTER_RAT
	},
	[THEME.JUNGLE] = {
		entity = module.HD_ENT.CRITTER_FROG
	},
	-- Confirm if this is in HD level transitions
	-- [THEME.EGGPLANT_WORLD] = {
		-- entity = module.HD_ENT.CRITTER_MAGGOT
	-- },
	-- [THEME.ICE_CAVES] = {
		-- entity = module.HD_ENT.CRITTER_PENGUIN
	-- },
	-- [THEME.TEMPLE] = {
		-- entity = module.HD_ENT.CRITTER_LOCUST
	-- },
}

module.danger_tracker = {}

function module.init()
    module.danger_tracker = {}
end


function danger_track(uid_to_track, x, y, l, hd_type)
	danger_object = {
		["uid"] = uid_to_track,
		["x"] = x, ["y"] = y, ["l"] = l,
		["hd_type"] = hd_type,
		["behavior"] = create_hd_behavior(hd_type.behavior)
	}
	module.danger_tracker[#module.danger_tracker+1] = danger_object
end

function create_hd_behavior(behavior)
	decorated_behavior = {}
	if behavior ~= nil then
		decorated_behavior = commonlib.TableCopy(behavior)
		-- if behavior.abilities ~= nil then
			if behavior == module.HD_BEHAVIOR.SCORPIONFLY then
				-- **Ask the discord if it's actually possible to check if a variable exists even if it's set to nil
				-- The solution is probably assigning ability parameters by setting the variable to -1
					-- (which I CAN do in this situation considering it's a uid field)
				-- ACTUALLYYYYYYYYYYYY The solution is probably using string indexes(I'm probably butchuring the terminology)
					-- For instance; "for string, value in pairs(decorated_behavior.abilities) do if string == "imp_uid" then message("IMP!!") end end"
				
				-- if behavior.abilities.agro.imp_uid ~= nil then
					
					decorated_behavior.imp_uid = spawn(ENT_TYPE.MONS_IMP, x, y, l, 0, 0)--decorated_behavior.abilities.agro.imp_uid = spawn(ENT_TYPE.MONS_IMP, x, y, l, 0, 0)
					applyflags_to_uid(decorated_behavior.imp_uid, {{ 1, 6, 25 }})
				
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
			if behavior == module.HD_BEHAVIOR.OLMEC_SHOT then
				xvel = math.random(7, 30)/100
				yvel = math.random(5, 10)/100
				if math.random() >= 0.5 then xvel = -1*xvel end
				decorated_behavior.velocity_set.velocityx = xvel
				decorated_behavior.velocity_set.velocityy = yvel
			end
		-- end
	end
	return decorated_behavior
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


function enttype_replace_danger(enttypes, hd_type, _vx, _vy)
	dangers_uids = get_entities_by_type(enttypes)
	for _, danger_uid in ipairs(dangers_uids) do
		hdtypelib.danger_replace(danger_uid, hd_type, false, _vx, _vy)
	end
end

function danger_applydb(uid, hd_type)
	s_mov = get_entity(uid):as_movable()
	x, y, l = get_position(uid)
	
	if hd_type.removeinventory ~= nil then
		if hd_type.removeinventory == module.HD_REMOVEINVENTORY.SNAIL then
			set_timeout(function()
				hd_type = module.HD_ENT.SNAIL
				remove_entitytype_inventory(
					hd_type.removeinventory.inventory_ownertype,
					hd_type.removeinventory.inventory_entities
				)
			end, 5)
		elseif hd_type.removeinventory == module.HD_REMOVEINVENTORY.SCORPIONFLY then
			set_timeout(function()
				hd_type = module.HD_ENT.SCORPIONFLY
				remove_entitytype_inventory(
					hd_type.removeinventory.inventory_ownertype,
					hd_type.removeinventory.inventory_entities
				)
			end, 5)
		end
	end
	if hd_type.replaceoffspring ~= nil then
		if hd_type.replaceoffspring == module.HD_REPLACE.EGGSAC then
			set_interval(function() enttype_replace_danger({ ENT_TYPE.MONS_GRUB }, module.HD_ENT.WORMBABY, 0, 0) end, 1)
		end
	end
	
	if hd_type == module.HD_ENT.HANGSPIDER then
		spawn(ENT_TYPE.ITEM_WEB, x, y, l, 0, 0)
		spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, uid, 0, 0)
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

	-- DANGER DB MODIFICATIONS
	-- Modifications that use methods that are only needed to be applied once
	-- This includes:
		-- EntityDB properties
	if hd_type.entitydb ~= nil then
		uid = spawn_entity(hd_type.entitydb, 0, 0, LAYER.FRONT, 0, 0)
		s_mov = get_entity(uid)
	end
	if hd_type.health_db ~= nil and hd_type.health_db > 0 then
		s_mov.type.life = hd_type.health_db
	end
	if hd_type.sprint_factor ~= nil and hd_type.sprint_factor >= 0 then
		s_mov.type.sprint_factor = hd_type.sprint_factor
	end
	if hd_type.max_speed ~= nil and hd_type.max_speed >= 0 then
		s_mov.type.max_speed = hd_type.max_speed
	end
	if hd_type.jump ~= nil and hd_type.jump >= 0 then
		s_mov.type.jump = hd_type.jump
	end
	if hd_type.dim_db ~= nil and #hd_type.dim_db == 2 then
		s_mov.type.width = hd_type.dim[1]
		s_mov.type.height = hd_type.dim[2]
	end
	if hd_type.damage ~= nil and hd_type.damage >= 0 then
		s_mov.type.damage = hd_type.damage
	end
	if hd_type.acceleration ~= nil and hd_type.acceleration >= 0 then
		s_mov.type.acceleration = hd_type.acceleration
	end
	if hd_type.friction ~= nil and hd_type.friction >= 0 then
		s_mov.type.friction = hd_type.friction
	end
	if hd_type.weight ~= nil and hd_type.weight >= 0 then
		s_mov.type.weight = hd_type.weight
	end
	if hd_type.elasticity ~= nil and hd_type.elasticity >= 0 then
		s_mov.type.elasticity = hd_type.elasticity
	end
	if hd_type.leaves_corpse_behind ~= nil then
		s_mov.type.leaves_corpse_behind = hd_type.leaves_corpse_behind
	end
	
	apply_entity_db(uid)
end


-- velocity defaults to 0
function create_hd_type_notrack(hd_type, x, y, l, _vx, _vy)
	vx = _vx or 0
	vy = _vy or 0
	uid = -1
	if (hd_type.collisiontype ~= nil and (hd_type.collisiontype == module.HD_COLLISIONTYPE.FLOORTRAP or hd_type.collisiontype == module.HD_COLLISIONTYPE.FLOORTRAP_TALL)) then
		floor_uid = detection_floor(x, y, l, 0, -1, 0.5)
		if floor_uid ~= -1 then
			uid = spawn_entity_over(hd_type.tospawn, floor_uid, 0, 1)
			if hd_type.collisiontype == module.HD_COLLISIONTYPE.FLOORTRAP_TALL then
				s_head = spawn_entity_over(hd_type.tospawn, uid, 0, 1)
				if test_flag(state.level_flags, 18) == true then
					spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, s_head, 0.29, 0.26)
					spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, s_head, -0.29, 0.26)
				end
			end
		end
	else
		uid = spawn(hd_type.tospawn, x, y, l, vx, vy)
	end
	return uid
end

-- velocity defaults to 0 (by extension of `create_hd_type_notrack()`)
function module.create_hd_type(hd_type, x, y, l, collision_detection, _vx, _vy)
	offset_collision = { 0, 0 }
	if collision_detection == true then
		offset_collision = conflictdetection(hd_type, x, y, l)
	end
	if offset_collision ~= nil then
		offset_spawn_x, offset_spawn_y = 0, 0
		if hd_type.offset_spawn ~= nil then
			offset_spawn_x, offset_spawn_y = hd_type.offset_spawn[1], hd_type.offset_spawn[2]
		end
		uid = create_hd_type_notrack(hd_type, x+offset_spawn_x+offset_collision[1], y+offset_spawn_y+offset_collision[2], l, _vx, _vy)
		if uid ~= -1 then
			danger_applydb(uid, hd_type)
			danger_track(uid, x, y, l, hd_type)
			return uid
		end
	end
end


-- velocity defaults to uid's
function module.danger_replace(uid, hd_type, collision_detection, _vx, _vy)
	uid_to_track = uid
	d_mov = get_entity(uid_to_track):as_movable()
	vx = _vx or d_mov.velocityx
	vy = _vy or d_mov.velocityx
	
	x, y, l = get_position(uid_to_track)
	
	d_type = get_entity(uid_to_track).type.id
	
	offset_collision = conflictdetection(hd_type, x, y, l)
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
			uid_to_track = create_hd_type_notrack(hd_type, x+offset_spawn_x+offset_collision[1], y+offset_spawn_y+offset_collision[2], l, vx, vy)
			
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


-- DANGER MODIFICATIONS - ON.FRAME
-- Massive enemy behavior handling method
set_callback(function()

	n = # module.danger_tracker
	for i, danger in ipairs( module.danger_tracker) do
		danger_mov = get_entity(danger.uid)
		killbool = false
		if danger_mov == nil then
			killbool = true
		elseif danger_mov ~= nil then
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
				-- if danger.hd_type == module.HD_ENT.SCORPIONFLY then
					-- if danger.behavior.abilities ~= nil then
					
						-- "ability_uid" is an entity that's "duct-taped" to the main entity to allow it to adopt it's abilities.
						-- for _, ability_uid in ipairs(danger.behavior.abilities) do
							-- message("#danger.behavior.abilities: " .. tostring(#danger.behavior.abilities))
							-- if danger.behavior.abilities.agro ~= nil then
								if danger.behavior.imp_uid ~= nil then--behavior.abilities.imp_uid ~= nil then
									if danger_mov.health == 1 then
										-- **If SCORPIONFLY is killed, kill all abilities
											-- **Move this into its own method
										-- kill all abilities
										-- for _, behavior_tokill in ipairs(danger.behavior.abilities) do
											-- if #behavior_tokill > 0 and behavior_tokill[1] ~= nil then
												move_entity(danger.behavior.imp_uid, 0, 0, 0, 0)--move_entity(behavior_tokill[1], 0, 0, 0, 0)
												danger.behavior.imp_uid = nil--behavior_tokill[1] = nil
											-- end
										-- end
									else
										-- permanent agro
										-- **SCORPIONFLY -> Adopt S2's Monkey agro distance.
											-- change the if statement below so it's detecting if the IMP is agro'd, not the scorpion.
										-- **Use chased_target instead.
											-- get_entity():as_chasingmonster chased_target_uid
										if danger_mov.move_state == 5 and danger.behavior.agro == false then danger.behavior.agro = true end
										-- if no idle ability, toggle between agro and default
										-- if danger.behavior.abilities.idle == nil then
											behavior_toggle(
												danger.behavior.imp_uid,--behavior.abilities.agro[1],
												danger.uid,
												{danger.uid, danger.behavior.imp_uid},--commonlib.map(danger.behavior.abilities, function(ability) return ability[1] end)),--{ danger.behavior.abilities.agro[1], danger.behavior.abilities.idle[1], danger.uid },
												danger.behavior.agro
											)
										-- end
									end
								end
							-- end
							-- if it has an idle behavior and agro == false then set it as agro
							-- if danger.behavior.abilities.idle ~= nil then
								-- -- WARNING: This doesn't consider the scenario of abilities.agro.imp_uid being nil.
								-- -- However, this shouldn't be an issue, as neither is going to be nil when the other is not.
								-- if danger.behavior.abilities.idle[1] ~= nil then
									-- behavior_toggle(
										-- danger.behavior.abilities.agro[1],
										-- danger.behavior.abilities.idle[1],
										-- commonlib.TableConcat({danger.uid}, commonlib.map(danger.behavior.abilities, function(ability) return ability[1] end)),--{ danger.behavior.abilities.agro[1], danger.behavior.abilities.idle[1], danger.uid },
										-- danger.behavior.agro
									-- )
								-- end	
							-- end
						-- end
						
					-- end
				-- end
				if danger.behavior.velocity_set ~= nil then
					if danger.behavior.velocity_set.timer > 0 then
						danger.behavior.velocity_set.timer = danger.behavior.velocity_set.timer - 1
					else
						if danger.behavior.velocity_set.velocityx ~= nil then
							danger_mov.velocityx = danger.behavior.velocity_set.velocityx
						end
						if danger.behavior.velocity_set.velocityy ~= nil then
							danger_mov.velocityy = danger.behavior.velocity_set.velocityy
						end
						-- message("Olmec behavior 'YEET' velocityx: " .. tostring(danger_mov.velocityx))
						danger.behavior.velocity_set = nil
					end
				end
			end

			if (
				danger.hd_type.kill_on_standing ~= nil and
				(
					danger.hd_type.kill_on_standing == module.HD_KILL_ON.STANDING and
					danger_mov.standing_on_uid ~= -1
				) or
				(
					danger.hd_type.kill_on_standing == module.HD_KILL_ON.STANDING_OUTOFWATER and
					danger_mov.standing_on_uid ~= -1 and
					test_flag(danger_mov.more_flags, 11) == false
				)
			) then
				killbool = true
			end
		end
		if killbool == true then
			-- if there's no script-enduced death and we're left with a nil response to uid, track entity coordinates with HD_BEHAVIOR and upon a nil response set killbool in the danger_mov == nil statement. That should allow spawning the item here.
			-- This should also alow for removing all enemy behaviors.
			if danger.behavior ~= nil then
				if danger.behavior.imp_uid ~= nil then
					move_entity(danger.behavior.imp_uid, 0, 0, 0, 0)
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
						if itemdrop == module.HD_ENT.ITEM_CRYSTALSKULL then
							create_ghost()
						end
						hdtypelib.create_hd_type(itemdrop, danger.x, danger.y, danger.l, false, 0, 0)--spawn(itemdrop, etc)
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
						hdtypelib.create_hd_type(itemdrop, danger.x, danger.y, danger.l, false, 0, 0)
					end
				end
			end
			kill_entity(danger.uid)
			 module.danger_tracker[i] = nil
		end
	end
	-- compact danger_tracker
	commonlib.CompactList( module.danger_tracker, n)
end, ON.FRAME)

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

function remove_entitytype_inventory(entity_type, inventory_entities)
	-- items = get_entities_by_type(inventory_entities)
	-- for r, inventoryitem in ipairs(items) do
	-- 	local mount = get_entity(inventoryitem):topmost()
	-- 	if mount ~= -1 and mount:as_container().type.id == entity_type then
	-- 		move_entity(inventoryitem, -r, 0, 0, 0)
	-- 		-- message("Should be hermitcrab: ".. mount.uid)
	-- 	end
	-- end
	for r, _uid in ipairs(get_entities_by_type(entity_type)) do
		for _, inventoryitem in ipairs(inventory_entities) do
			local items = entity_get_items_by(_uid, inventoryitem, 0)
			for _, _to_remove_uid in ipairs(items) do
				move_entity(_to_remove_uid, -r, 0, 0, 0)
				--[[
					-- # TODO: Find a better way to remove powderkegs and pushblocks. The following uncommented code does not remove it propperly.
					local entity = get_entity(_to_remove_uid)
					entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
					kill_entity(_to_remove_uid)
				]]
			end
		end
	end
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
	-- if hdctype == hdtypelib.HD_COLLISIONTYPE.GIANT_FROG then
		
	-- end
	if hdctype == hdtypelib.HD_COLLISIONTYPE.GIANT_SPIDER then
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
	if hdctype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP and options.hd_og_procedural_spawns_disable == true then
		scan_width = 1 -- check 1 across (1 on each side)
		scan_height = 0 -- check the space above + 1 more
	elseif hdctype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP_TALL and options.hd_og_procedural_spawns_disable == true then
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
function conflictdetection(hd_type, x, y, l)
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
			hd_type.collisiontype >= hdtypelib.HD_COLLISIONTYPE.AIR_TILE_1
			-- hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP or
			-- hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP_TALL
		)
	) then
		if (
			hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP or
			hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.FLOORTRAP_TALL
		) then
			conflict = conflictdetection_floortrap(hd_type.collisiontype, x, y, l)
			if conflict == true then
				offset = nil
			else
				offset = { 0, 0 }
			end
		elseif (
			hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.GIANT_FROG or
			hd_type.collisiontype == hdtypelib.HD_COLLISIONTYPE.GIANT_SPIDER
		) then
			side = conflictdetection_giant(hd_type.collisiontype, x, y, l)
			if side > 0 then
				offset = nil
			else
				offset = { side, 0 }
			end
		end
	end
	return offset
end



return module