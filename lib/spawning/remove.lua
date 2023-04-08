local validlib = require 'lib.spawning.valid'
local module = {}

function module.remove_embedded_at(x, y, l)
	local entity_uids = get_entities_at({
		ENT_TYPE.EMBED_GOLD,
		ENT_TYPE.EMBED_GOLD_BIG,
		ENT_TYPE.ITEM_RUBY,
		ENT_TYPE.ITEM_SAPPHIRE,
		ENT_TYPE.ITEM_EMERALD,

		ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE,
		ENT_TYPE.ITEM_PICKUP_ROPEPILE,
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_PICKUP_BOMBBOX,
		ENT_TYPE.ITEM_PICKUP_SPECTACLES,
		ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
		ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
		ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
		ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
		ENT_TYPE.ITEM_PICKUP_PASTE,
		ENT_TYPE.ITEM_PICKUP_COMPASS,
		ENT_TYPE.ITEM_PICKUP_PARACHUTE,
		ENT_TYPE.ITEM_CAPE,
		ENT_TYPE.ITEM_JETPACK,
		ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
		ENT_TYPE.ITEM_HOVERPACK,
		ENT_TYPE.ITEM_POWERPACK,
		ENT_TYPE.ITEM_WEBGUN,
		ENT_TYPE.ITEM_SHOTGUN,
		ENT_TYPE.ITEM_FREEZERAY,
		ENT_TYPE.ITEM_CROSSBOW,
		ENT_TYPE.ITEM_CAMERA,
		ENT_TYPE.ITEM_TELEPORTER,
		ENT_TYPE.ITEM_MATTOCK,
		ENT_TYPE.ITEM_BOOMERANG,
		ENT_TYPE.ITEM_MACHETE
	}, 0, x, y, l, 0.5)
	if #entity_uids ~= 0 then
		-- message("Bye bye, embed! " .. x .. " " .. y)
		local entity = get_entity(entity_uids[1])
		-- entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
		entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
		-- move_entity(entity.uid, 1000, 0, 0, 0)
		entity:destroy()
	end
end

function module.remove_floor_and_embedded_at(x, y, l)
    local uid = get_grid_entity_at(x, y, l)
    if uid ~= -1 then
		module.remove_embedded_at(x, y, l)
        local floor = get_entity(uid)
		floor:destroy() -- kill_entity(uid)
    end
end

function module.remove_items_for_hideyhole_spawn(x, y, l)
    for i,v in pairs(get_entities_at(0, MASK.ITEM, x, y, l, 0.4)) do
        local ent = get_entity(v)
        if commonlib.has(validlib.hideyhole_items_to_keep, ent.type.id) then return false end
        ent:destroy()
    end
    return true
end


function module.remove_non_held_item(items, x, y)
	local hitbox_items = get_entities_overlapping_hitbox(
		items,
		MASK.ITEM,
		AABB:new(
			x-.5,
			y+.5,
			x+.5,
			y-.5
		),
		LAYER.FRONT
	)
	for _, item_uid in ipairs(hitbox_items) do
		for _, pl in ipairs(players) do
			if entity_has_item_uid(pl.uid, item_uid) == false then
				local ent = get_entity(item_uid)
				ent:destroy()
			end
		end
	end
end

--[[
	SPAWN EXCEPTIONS
	Several areas in HD shouldn't spawn certain entities. The following code should fix that.
	Code adapted from JayTheBusinessGoose: https://github.com/jaythebusinessgoose/CustomLevels/blob/master/custom_levels.lua
--]]


local removed_procedural_spawns = {
	ENT_TYPE.ITEM_TORCH,
	ENT_TYPE.MONS_PET_DOG,
	ENT_TYPE.ITEM_BONES,
	ENT_TYPE.EMBED_GOLD,
	ENT_TYPE.EMBED_GOLD_BIG,
	ENT_TYPE.ITEM_POT,
	ENT_TYPE.ITEM_NUGGET,
	ENT_TYPE.ITEM_NUGGET_SMALL,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.ITEM_CHEST,
	ENT_TYPE.ITEM_CRATE,
	ENT_TYPE.MONS_PET_CAT,
	ENT_TYPE.MONS_PET_HAMSTER,
	ENT_TYPE.ITEM_ROCK,
	ENT_TYPE.ITEM_RUBY,
	ENT_TYPE.ITEM_CURSEDPOT,
	ENT_TYPE.ITEM_SAPPHIRE,
	ENT_TYPE.ITEM_EMERALD,
	ENT_TYPE.ITEM_WALLTORCH,
	ENT_TYPE.MONS_SCARAB,
	ENT_TYPE.ITEM_AUTOWALLTORCH,
	ENT_TYPE.ITEM_WEB,
	ENT_TYPE.ITEM_GOLDBAR,
	ENT_TYPE.ITEM_GOLDBARS,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.MONS_SKELETON,
}

local removed_embedded_items = {
    ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE,
    ENT_TYPE.ITEM_PICKUP_ROPEPILE,
    ENT_TYPE.ITEM_PICKUP_BOMBBAG,
    ENT_TYPE.ITEM_PICKUP_BOMBBOX,
    ENT_TYPE.ITEM_PICKUP_SPECTACLES,
    ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
    ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
    ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
    ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
    ENT_TYPE.ITEM_PICKUP_PASTE,
    ENT_TYPE.ITEM_PICKUP_COMPASS,
    ENT_TYPE.ITEM_PICKUP_PARACHUTE,
    ENT_TYPE.ITEM_CAPE,
    ENT_TYPE.ITEM_JETPACK,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_HOVERPACK,
    ENT_TYPE.ITEM_POWERPACK,
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_CROSSBOW,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_BOOMERANG,
    ENT_TYPE.ITEM_MACHETE,
}


-- custom_level_state.procedural_spawn_callback = set_post_entity_spawn(function(entity, spawn_flags)
-- 	if (

-- 	) then return end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, removed_procedural_spawns)

local removed_embedded_currencies = {
    ENT_TYPE.EMBED_GOLD,
    ENT_TYPE.EMBED_GOLD_BIG,
    ENT_TYPE.ITEM_RUBY,
    ENT_TYPE.ITEM_SAPPHIRE,
    ENT_TYPE.ITEM_EMERALD,
}
-- set_post_entity_spawn(function(entity, spawn_flags)
-- 	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
-- 		if (
-- 			state.theme ~= THEME.NEO_BABYLON
-- 			and state.theme ~= THEME.EGGPLANT_WORLD
-- 			-- and (feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false)
-- 		) then
-- 			return
-- 		end
-- 	elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
-- 		if (
-- 			entity.type.id == ENT_TYPE.EMBED_GOLD
-- 			or entity.type.id == ENT_TYPE.EMBED_GOLD_BIG
-- 		) then
-- 			return
-- 		end
-- 	elseif worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TESTING then
-- 		return
-- 	end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN, 0, removed_embedded_currencies)

-- set_post_entity_spawn(function(entity, spawn_flags) -- remove embedded items from tutorial/testing
-- 	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then return end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN, 0, removed_embedded_items)


--[[
	/SPAWN EXCEPTIONS
--]]


-- prevent tilecode entrance door entities from spawning
local function remove_entrance_door_entity(_entity)
	if
		state.screen == ON.LEVEL
		and
		options.hd_debug_scripted_levelgen_disable == false
		and state.theme ~= THEME.OLMEC
	then
		kill_entity(_entity.uid)
	end
end
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.BG_DOOR)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.FLOOR_DOOR_ENTRANCE)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.LOGICAL_DOOR)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.LOGICAL_PLATFORM_SPAWNER)




return module