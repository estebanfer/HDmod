commonlib = require 'lib.common'
demolib = require 'lib.demo'
worldlib = require 'lib.worldstate'
camplib = require 'lib.camp'
testlib = require 'lib.test'
roomdeflib = require 'lib.gen.roomdef'
roomgenlib = require 'lib.gen.roomgen'
tiledeflib = require 'lib.gen.tiledef'
feelingslib = require 'lib.feelings'
unlockslib = require 'lib.unlocks'
cooplib = require 'lib.coop'
locatelib = require 'lib.locate'

validlib = require 'lib.spawning.valid'
spawndeflib = require 'lib.spawning.spawndef'
createlib = require 'lib.spawning.create'
removelib = require 'lib.spawning.remove'
embedlib = require 'lib.spawning.embed'
hdtypelib = require 'lib.entities.hdtype'
botdlib = require 'lib.entities.botd'
wormtonguelib = require 'lib.entities.wormtongue'
ghostlib = require 'lib.entities.ghost'
olmeclib = require 'lib.entities.olmec'
boulderlib = require 'lib.entities.boulder'
idollib = require 'lib.entities.idol'
acidlib = require 'lib.entities.acid'
treelib = require 'lib.entities.tree'
ankhmoailib = require 'lib.entities.ankhmoai'
doorslib = require 'lib.entities.doors'
tombstonelib = require 'lib.entities.tombstone'

meta.name = "HDmod - Demo"
meta.version = "1.02"
meta.description = "Spelunky HD's campaign in Spelunky 2"
meta.author = "Super Ninja Fat"

register_option_bool("hd_debug_boss_exits_unlock", "Debug: Unlock boss exits",														false)
register_option_bool("hd_debug_feelingtoast_disable", "Debug: Disable script-enduced feeling toasts",								false)
register_option_bool("hd_debug_info_boss", "Debug: Info - Bossfight",																false)
register_option_bool("hd_debug_info_boulder", "Debug: Info - Boulder",																false)
register_option_bool("hd_debug_info_feelings", "Debug: Info - Level Feelings",														false)
register_option_bool("hd_debug_info_path", "Debug: Info - Path",																	false)
register_option_bool("hd_debug_info_tongue", "Debug: Info - Wormtongue",															false)
register_option_bool("hd_debug_info_worldstate", "Debug: Info - Worldstate",														false)
register_option_bool("hd_debug_scripted_enemies_show", "Debug: Enable visibility of entities used in custom enemy behavior",		false)
register_option_bool("hd_debug_item_botd_give", "Debug: Start with item - Book of the Dead",										false)
register_option_bool("hd_debug_scripted_levelgen_disable", "Debug: Disable scripted level generation",								false)
register_option_string("hd_debug_scripted_levelgen_tilecodes_blacklist",
	"Debug: Blacklist scripted level generation tilecodes",
	""
)
register_option_bool("hd_debug_testing_door", "Debug: Enable testing door in camp",													false)
register_option_bool("hd_og_floorstyle_temple", "OG: Set temple's floorstyle to stone instead of temple",							false)	-- Defaults to S2
-- register_option_bool("hd_og_ankhprice", "OG: Set the Ankh price to a constant $50,000 like it was in HD",							false)	-- Defaults to S2
register_option_bool("hd_og_boulder_agro_disable", "OG: Boulder - Don't enrage shopkeepers",										false)	-- Defaults to HD
register_option_bool("hd_og_ghost_nosplit_disable", "OG: Ghost - Allow the ghost to split",											false)	-- Defaults to HD
register_option_bool("hd_og_ghost_slow_enable", "OG: Ghost - Set the ghost to its HD speed",										false)	-- Defaults to S2
register_option_bool("hd_og_ghost_time_disable", "OG: Ghost - Use S2 spawntimes: 2:30->3:00 and 2:00->2:30 when cursed.",			false)	-- Defaults to HD
register_option_bool("hd_og_cursepot_enable", "OG: Enable curse pot spawning",														false)	-- Defaults to HD
register_option_bool("hd_og_tree_spawn", "OG: Tree spawns - Spawn trees in S2 style instead of HD",									false)	-- Defaults to HD

-- # TODO: revise from the old system, removing old uses.
-- Then, rename it to `hd_og_use_s2_spawns`
-- Reimplement it into `is_valid_*_spawn` methods to change spawns.
register_option_bool("hd_og_procedural_spawns_disable", "OG: Use S2 instead of HD procedural spawning conditions",				false)	-- Defaults to HD

-- # TODO: Influence the velocity of the boulder on every frame.
-- register_option_bool("hd_og_boulder_phys", "OG: Boulder - Adjust to have the same physics as HD",									false)


POSTTILE_STARTBOOL = false
FRAG_PREVENTION_UID = nil



-- post_tile-sensitive ON.START initializations
	-- Since ON.START runs on the first ON.SCREEN of a run, it runs after post_tile runs.
	-- Run this in post_tile to circumvent the issue.
function init_posttile_onstart()
	if POSTTILE_STARTBOOL == false then -- determine if you need to set new things
		POSTTILE_STARTBOOL = true
		feelingslib.init()
		wormtonguelib.tongue_spawned = false
		-- other stuff
	end
	-- message("wormtonguelib.tongue_spawned: " .. tostring(wormtonguelib.tongue_spawned))
end

function init_onlevel()
	FRAG_PREVENTION_UID = nil

	createlib.init()
	hdtypelib.init()
	botdlib.init()
	wormtonguelib.init()
	ghostlib.init()
	olmeclib.init()
	boulderlib.init()
	idollib.init()
	unlockslib.init()
	cooplib.init()
	acidlib.init()
	ankhmoailib.init()
	doorslib.init()
	tombstonelib.init()
	roomdeflib.init()
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


function detect_same_levelstate(t_a, l_a, w_a)
	if state.theme == t_a and state.level == l_a and state.world == w_a then return true else return false end
end

-- prevent dark levels for specific states
function clear_dark_level()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
		or worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING
		or state.theme == THEME.VOLCANA
		or state.theme == THEME.NEO_BABYLON
		or feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == true
	) then
		state.level_flags = clr_flag(state.level_flags, 18)
	end
end

function remove_borderfloor()
	local xmin, _, xmax, ymax = get_bounds()
	for yi = ymax-0.5, (ymax-0.5)-2, -1 do
		for xi = xmin+0.5, xmax-0.5, 1 do
			local blocks = get_entities_at(0, MASK.FLOOR, xi, yi, LAYER.FRONT, 0.3)
			kill_entity(blocks[1])
		end
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

function changestate_onloading_targets(w_a, l_a, t_a, w_b, l_b, t_b)
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		-- if t_b == THEME.BASE_CAMP then
		-- 	state.screen_next = ON.CAMP
		-- end
		if test_flag(state.quest_flags, 1) == false then
			state.level_next = l_b
			state.world_next = w_b
			state.theme_next = t_b
			if t_b == THEME.BASE_CAMP then
				state.screen_next = ON.CAMP
			end
			-- if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
			-- 	state.screen_next = ON.LEVEL
			-- end
		end
	end
end

-- Used to "fake" world/theme/level
function changestate_onlevel_fake(w_a, l_a, t_a, w_b, l_b, t_b)
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		state.level = l_b
		state.world = w_b
		state.theme = t_b
	end
end

function changestate_samelevel_applyquestflags(w_a, l_a, t_a, flags_set, flags_clear)--w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
	end
end

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return 0
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_LEPRECHAUN)


-- set_post_entity_spawn(function(entity)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN_FLOOR_SPREADING, 0)

set_pre_tile_code_callback(function(x, y, layer)
	local type_to_use = ENT_TYPE.FLOOR_GENERIC

	if state.theme == THEME.TEMPLE then
		type_to_use = (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE)
	end

	local entity = get_entity(spawn_grid_entity(type_to_use, x, y, layer, 0, 0))
	entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)

	return true
end, "shop_wall")

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l, 0, 0)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l, 0, 0)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

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
			-- door_ents_uids = commonlib.TableConcat(door_ents_uids, get_entities_overlapping(
				-- 0,
				-- door_ent_mask,
				-- leveldoor_sx,
				-- leveldoor_sy,
				-- leveldoor_sx2,
				-- leveldoor_sy2,
				-- LAYER.FRONT
			-- ))
		-- end
		
		-- TEMPORARY: Remove floor to avoid telefragging the player.
		
		-- if (
		-- 	state.theme ~= THEME.OLMEC
		-- ) then
		-- 	-- door_ents_uids = get_entities_at(0, MASK.FLOOR, x, y, layer, 1)
		-- 	-- for _, door_ents_uid in ipairs(door_ents_uids) do
		-- 	-- 	kill_entity(door_ents_uid)
		-- 	-- end
		-- 	FRAG_PREVENTION_UID = get_grid_entity_at(x, y, layer)
		-- 	local entity = get_entity(FRAG_PREVENTION_UID)
		-- 	if entity ~= nil then
		-- 		entity.flags = clr_flag(entity.flags, ENT_FLAG.SOLID)
		-- 	end
		-- end

		-- message("post-door: " .. tostring(state.time_level))
	else
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y+1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y+1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y, layer, 0, 0)

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
		
		doorslib.create_door_exit(x+2, y, layer)
	end
end, "door")


local s2_room_template_blackmarket_ankh = define_room_template("hdmod_blackmarket_ankh", ROOM_TEMPLATE_TYPE.SHOP)
local s2_room_template_blackmarket_shop = define_room_template("hdmod_blackmarket_shop", ROOM_TEMPLATE_TYPE.SHOP)


set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		init_posttile_onstart()
		if options.hd_debug_scripted_levelgen_disable == false then
			roomgenlib.init_posttile_door()
			levelcreation_init()
			
			assign_s2_level_height()
		end
	end
end, ON.PRE_LEVEL_GENERATION)

set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		-- message(F'ON.POST_ROOM_GENERATION - ON.LEVEL: {state.time_level}')

		if options.hd_debug_scripted_levelgen_disable == false then
			
			cooplib.detect_coop_coffin(room_gen_ctx)

			if state.theme == THEME.DWELLING and state.level == 4 then
				for x = 0, state.width - 1 do
					for y = 0, state.height - 1 do
						room_gen_ctx:unmark_as_set_room(x, y, LAYER.FRONT)
					end
				end
			end

			levelcreation()

			set_blackmarket_shoprooms(room_gen_ctx)

			onlevel_generation_execution_phase_one()
			onlevel_generation_execution_phase_two()

		end


		level_w, level_h = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		for y = 0, level_h - 1, 1 do
		    for x = 0, level_w - 1, 1 do
				local template_to_set = ROOM_TEMPLATE.SIDE
				local room_template_here = get_room_template(x, y, 0)

				if options.hd_debug_scripted_levelgen_disable == false then

					_template_hd = roomgenlib.global_levelassembly.modification.levelrooms[y+1][x+1]

					if (
						state.theme == THEME.OLMEC
					) then
						if (x == 0 and y == 3) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (x == 3 and y == 3) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							-- template_to_set = ROOM_TEMPLATE.PATH_NORMAL
							template_to_set = room_template_here
						end
					elseif (
						feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
					) then
						if (_template_hd == roomdeflib.HD_SUBCHUNKID.YAMA_ENTRANCE) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.YAMA_EXIT) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							template_to_set = ROOM_TEMPLATE.SIDE
							-- template_to_set = room_template_here
						end
					else
						--[[
							Sync scripted level generation rooms with S2 generation rooms
						--]]
						
						--LevelGenSystem variables
						if (
							_template_hd == roomdeflib.HD_SUBCHUNKID.ENTRANCE or
							_template_hd == roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP
						) then
							state.level_gen.spawn_room_x, state.level_gen.spawn_room_y = x, y
						end
	
						-- normal paths
						if (
							(_template_hd >= 1) and (_template_hd <= 8)
						) then
							template_to_set = _template_hd
	
						-- tikivillage paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH then
							template_to_set = ROOM_TEMPLATE.PATH_NORMAL
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
	
						-- flooded paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_SIDE then
							template_to_set = ROOM_TEMPLATE.SIDE
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
						
						-- hauntedcastle paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
	
						-- shop
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR) then
							if state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
								template_to_set = ROOM_TEMPLATE.DICESHOP
							else
								template_to_set = ROOM_TEMPLATE.SHOP
							end
						-- shop left
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT) then
							if state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
								template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
							else
								template_to_set = ROOM_TEMPLATE.SHOP_LEFT
							end
						-- prize wheel
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE) then
							template_to_set = ROOM_TEMPLATE.DICESHOP
						-- prize wheel left
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT) then
							template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
							
						-- vault
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.VAULT) then
							template_to_set = ROOM_TEMPLATE.VAULT
						
						-- altar
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.ALTAR) then
							template_to_set = ROOM_TEMPLATE.ALTAR
						
						-- idol
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.IDOL) then
							template_to_set = ROOM_TEMPLATE.IDOL
							
						-- black market
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_SHOP) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT--s2_room_template_blackmarket_shop
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_ANKH) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT--s2_room_template_blackmarket_ankh

						-- coop coffin
						
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP) then
							template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER
						elseif (
							_template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
							or _template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP
							or _template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
						) then
							template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER_VERTICAL

						end
					end
				else
					-- Set everything that's not the entrance to a side room
					if (
						(room_template_here == ROOM_TEMPLATE.ENTRANCE) or
						(room_template_here == ROOM_TEMPLATE.ENTRANCE_DROP)
					) then
						template_to_set = room_template_here
					end
				end
				room_gen_ctx:set_room_template(x, y, 0, template_to_set)
	        end
	    end
		
		if (
			feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM)
			or feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			or state.theme == THEME.NEO_BABYLON
		) then
			for x = 0, level_w - 1, 1 do
				room_gen_ctx:set_room_template(x, level_h, 0, ROOM_TEMPLATE.SIDE)
			end
		end
		
		spawndeflib.set_chances(room_gen_ctx)

	end
end, ON.POST_ROOM_GENERATION)


set_callback(function()
	if state.screen == SCREEN.LEVEL then
		onlevel_generation_execution_phase_three()
		--[[
			Procedural Spawn post_level_generation stuff
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				tombstonelib.set_ash_tombstone()

				if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
					local shopkeeper_uids = get_entities_by(ENT_TYPE.MONS_SHOPKEEPER, 0, LAYER.FRONT)
					for _, shopkeeper_uid in pairs(shopkeeper_uids) do
						get_entity(shopkeeper_uid).has_key = false
					end
				end
			end
		end
		
		--[[
			Level Background stuff
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				local backwalls = get_entities_by(ENT_TYPE.BG_LEVEL_BACKWALL, 0, LAYER.FRONT)
				-- message("#backwalls: " .. tostring(#backwalls))
				
				--[[
					Room-Specific
				--]]
				if state.theme == THEME.NEO_BABYLON then
					-- ice caves bg
					local backwall = get_entity(backwalls[1])
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_ICE_0)

					-- mothership bg
					local w, h = 40, 32
					local x, y, l = 22.5, 106.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end
				
				if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
					local w, h = 30, 28
					local x, y, l = 17.5, 104.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_STONE_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/4, backwall.height/4 -- divide by 4 for normal-sized brick
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) then
					local w, h = 6, 8
					local x, y, l = 22.5, 94.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end

				--[[
					Room-Specific
				--]]
				level_w, level_h = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
				for y = 1, level_h, 1 do
					for x = 1, level_w, 1 do
						_template_hd = roomgenlib.global_levelassembly.modification.levelrooms[y][x]
						local corner_x, corner_y = locatelib.locate_game_corner_position_from_levelrooms_position(x, y)
						if _template_hd == roomdeflib.HD_SUBCHUNKID.VLAD_BOTTOM then
							
							-- main tower
							local w, h = 10, (8*3)+3
							local x, y, l = corner_x+4.5, corner_y+6, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

							-- vlad alcove
							local w, h = 2, 2
							local x, y, l = corner_x+4.5, corner_y+20.5, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

							-- mother statue
							spawn_entity(ENT_TYPE.BG_CROWN_STATUE, corner_x+4.5, corner_y+(8*3)-7, l, 0, 0)

						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP then
							local w, h = 10, 8
							local x, y, l = corner_x+4.5, corner_y-3.5, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
						end
					end
				end
			end
		end

		--[[
			Tile Decorations
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				if (
					feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)
					or feelingslib.feeling_check(feelingslib.FEELING_ID.SNOWING)
				) then
					local floors = get_entities_by_type(ENT_TYPE.FLOOR_GENERIC)
					for _, floor_uid in pairs(floors) do
						local floor = get_entity(floor_uid)
						if floor.deco_top ~= -1 then
							local deco_top = get_entity(floor.deco_top)
							if (
								deco_top.animation_frame ~= 101
								and deco_top.animation_frame ~= 102
								and deco_top.animation_frame ~= 103
							) then
								deco_top.animation_frame = deco_top.animation_frame - 24
							end
						end
					end
				end
			end
			--[[
				Lut Settings
			]]
			
			if state.theme == THEME.VOLCANA then
				local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_LUT_ORIGINAL_0)
				texture_def.texture_path = "res/lut_hell.png"
				local vlad_atmos_id = define_texture(texture_def)
				set_lut(vlad_atmos_id, LAYER.FRONT)
			end
		end
	end
end, ON.POST_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.PRE_LEVEL_GENERATION: {state.time_level}')

-- 	-- if state.screen == ON.LEVEL then
-- 	-- 	if options.hd_debug_scripted_levelgen_disable == false then
-- 	-- 		onlevel_generation_execution_phase_one()
-- 	-- 		onlevel_generation_execution_phase_two() -- # TOTEST: ON.POST_LEVEL_GENERATION
-- 	-- 	end
-- 	-- end
-- end, ON.PRE_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.POST_LEVEL_GENERATION: {state.time_level}')


set_callback(function()
	game_manager.screen_title.ana_right_eyeball_torch_reflection.x, game_manager.screen_title.ana_right_eyeball_torch_reflection.y = -0.7, 0.05
	game_manager.screen_title.ana_left_eyeball_torch_reflection.x, game_manager.screen_title.ana_left_eyeball_torch_reflection.y = -0.55, 0.05
end, ON.TITLE)

-- ON.START
set_callback(function()
	onstart_init_options()
	-- Enable S2 udjat eye, S2 black market, and drill spawns to prevent them from spawning.
	changestate_samelevel_applyquestflags(state.world, state.level, state.theme, {17, 18, 19}, {})
end, ON.START)

set_callback(function()
	-- pre_tile ON.START stuff
	POSTTILE_STARTBOOL = false
	-- worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL
	-- camplib.DOOR_TESTING_UID = nil
	-- camplib.DOOR_TUTORIAL_UID = nil
end, ON.RESET)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
	onloading_applyquestflags()
end, ON.LOADING)

function levelcreation_init()
	init_onlevel()
	unlockslib.unlocks_load()
	-- onlevel_levelrules()
	
	if (
		(worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL)
		-- (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)
		-- or (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TESTING)
	) then
		feelingslib.onlevel_set_feelings()
	end
	clear_dark_level()
	feelingslib.onlevel_set_feelingToastMessage()
	-- Method to write override_path setrooms into path and levelcode
	--ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
end

function levelcreation()
	--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	onlevel_generation_modification()
end

function assign_s2_level_height()
	
	local new_width = 4
	local new_height = 4

	if (--levels that already have a constant width and height
		state.theme ~= THEME.OLMEC
		and state.theme ~= THEME.EGGPLANT_WORLD
		and state.theme ~= THEME.CITY_OF_GOLD
		and state.theme ~= THEME.NEO_BABYLON
	) then
		if (
			(--echoes themes
				state.theme == THEME.DWELLING
				or state.theme == THEME.JUNGLE
				or state.theme == THEME.TEMPLE
				or state.theme == THEME.VOLCANA
			)
			and (
				state.height ~= 4
				and state.width ~= 4
			)
		) then
			new_width = 4
			new_height = 4
		end
	
		-- set height for rushing water
		if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
			new_height = 5
		end
		state.width = new_width
		state.height = new_height
	end
end

function set_blackmarket_shoprooms(room_gen_ctx)

	if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		unlockslib.UNLOCK_WI, unlockslib.UNLOCK_HI = 0, 0
		if unlockslib.LEVEL_UNLOCK ~= nil then
			unlockslib.UNLOCK_WI = math.random(minw, maxw)
			unlockslib.UNLOCK_HI = math.random(minh, (unlockslib.UNLOCK_WI ~= maxw and maxh or maxh-1))
		end
		-- message("wi, hi: " .. unlockslib.UNLOCK_WI .. ", " .. unlockslib.UNLOCK_HI)
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.DICE_SHOP)
				elseif (hi == unlockslib.UNLOCK_HI and wi == unlockslib.UNLOCK_WI) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.HIRED_HAND_SHOP)
				else
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, math.random(0, 5))
				end
			end
		end
		-- room_gen_ctx:set_shop_type(1, 0, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 0, LAYER.FRONT, math.random(0, 5))

		-- room_gen_ctx:set_shop_type(1, 1, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 1, LAYER.FRONT, math.random(0, 5))

		-- room_gen_ctx:set_shop_type(1, 2, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 2, LAYER.FRONT, SHOP_TYPE.DICE_SHOP)

		-- room_gen_ctx:set_shop_type(3, 2, LAYER.FRONT, SHOP_TYPE.HEDJET_SHOP)--unneeded
	end

end

set_callback(function()
	-- message(F'ON.LEVEL: {state.time_level}')
	onlevel_generation_execution_phase_four()

-- --ONLEVEL_PRIORITY: 1 - Set level constants (ie, init_onlevel(), levelrules)
	-- Use a timeout since that seems to prevent loading some of the quillback level entities
	set_timeout(onlevel_levelrules, 20)

	-- TEMPORARY: move players and things they have to entrance point
	
	-- if (
	-- 	options.hd_debug_scripted_levelgen_disable == false and
	-- 	state.theme ~= THEME.OLMEC-- detect_level_non_boss()
	-- ) then
	-- 	for i = 1, #players, 1 do
	-- 		move_entity(players[i].uid, roomgenlib.global_levelassembly.entrance.x, roomgenlib.global_levelassembly.entrance.y, 0, 0)
	-- 	end
	-- 	local entity = get_entity(FRAG_PREVENTION_UID)
	-- 	if entity ~= nil then
	-- 		entity.flags = set_flag(entity.flags, ENT_FLAG.SOLID)
	-- 	end
	-- end
	
--ONLEVEL_PRIORITY: 4 - Set up dangers (LEVEL_DANGERS)
--ONLEVEL_PRIORITY: 5 - Remaining ON.LEVEL methods (ie, IDOL_UID)
	onlevel_remove_cursedpot()
	onlevel_remove_mounts()

	onlevel_hide_yama()
	treelib.onlevel_decorate_trees()
	onlevel_replace_border()
	onlevel_removeborderfloor()
	onlevel_create_impostorlake()
	onlevel_remove_boulderstatue()

	olmeclib.onlevel_olmec_init()

	feelingslib.onlevel_toastfeeling()
end, ON.LEVEL)

set_callback(function()
	onguiframe_ui_info_path()			-- debug
end, ON.GUIFRAME)



function onstart_init_options()	
	botdlib.OBTAINED_BOOKOFDEAD = options.hd_debug_item_botd_give
	if options.hd_og_ghost_time_disable == false then ghostlib.GHOST_TIME = 9000 end

	-- UI_BOTD_PLACEMENT_W = options.hd_ui_botd_a_w
	-- UI_BOTD_PLACEMENT_H = options.hd_ui_botd_b_h
	-- UI_BOTD_PLACEMENT_X = options.hd_ui_botd_c_x
	-- UI_BOTD_PLACEMENT_Y = options.hd_ui_botd_d_y
end

-- LEVEL HANDLING
function onloading_levelrules()
	
	--[[
		Tutorial
	--]]
	
	-- Tutorial 1-3 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL) then
		changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
		changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
		changestate_onloading_targets(1,3,THEME.DWELLING,1,1,THEME.BASE_CAMP)
		return
	end
	
	--[[
		Testing
	--]]
	
	-- Testing 1-2 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING) then
		changestate_onloading_targets(1,1,state.theme,1,2,state.theme)
		changestate_onloading_targets(1,2,state.theme,1,1,THEME.BASE_CAMP)
		return
	end

	-- --[[
	-- 	Mines
	-- --]]

	-- -- Mines 1-1..3
    -- changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
    -- changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
	
	-- -- Mines 1-3 -> Mines 1-5(Fake 1-4)
    -- changestate_onloading_targets(1,3,THEME.DWELLING,1,5,THEME.DWELLING)

    -- -- Mines -> Jungle
    changestate_onloading_targets(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)

	-- --[[
	-- 	Jungle
	-- --]]

	-- -- Jungle 2-1..4
    -- changestate_onloading_targets(2,1,THEME.JUNGLE,2,2,THEME.JUNGLE)
    -- changestate_onloading_targets(2,2,THEME.JUNGLE,2,3,THEME.JUNGLE)
    -- changestate_onloading_targets(2,3,THEME.JUNGLE,2,4,THEME.JUNGLE)

    -- -- Jungle -> Ice Caves
    -- changestate_onloading_targets(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)

	-- --[[
	-- 	Worm
	-- --]]

	-- -- Worm(Jungle) 2-2 -> Jungle 2-4
	-- -- # TOTEST: Re-adjust level loading (remove changestate_onloading_targets() where scripted levelgen entrance doors take over)
	-- changestate_onloading_targets(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
	
	-- -- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	-- changestate_onloading_targets(3,2,THEME.EGGPLANT_WORLD,3,4,THEME.ICE_CAVES)

    
	-- --[[
	-- 	Ice Caves
	-- --]]
	-- 	-- # TOTEST: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
		
	-- -- Ice Caves 3-1..4
    -- changestate_onloading_targets(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
	
    -- -- Ice Caves -> Temple
    -- changestate_onloading_targets(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)

	-- --[[
	-- 	Mothership
	-- --]]
	
	-- -- Mothership(3-3) -> Ice Caves(3-4)
    -- changestate_onloading_targets(3,3,THEME.NEO_BABYLON,3,4,THEME.ICE_CAVES)
	
	-- --[[
	-- 	Temple
	-- --]]
	
	-- -- Temple 4-1..3
    -- changestate_onloading_targets(4,1,THEME.TEMPLE,4,2,THEME.TEMPLE)
    -- changestate_onloading_targets(4,2,THEME.TEMPLE,4,3,THEME.TEMPLE)

    -- -- Temple -> Olmec
    -- changestate_onloading_targets(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	City Of Gold
	-- --]]

    -- -- COG(4-3) -> Olmec
    -- changestate_onloading_targets(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	Hell
	-- --]]

    -- changestate_onloading_targets(5,1,THEME.VOLCANA,5,2,THEME.VOLCANA)
    -- changestate_onloading_targets(5,2,THEME.VOLCANA,5,3,THEME.VOLCANA)

	-- -- Hell -> Yama
	-- 	-- Build Yama in Tiamat's chamber.
	-- changestate_onloading_targets(5,3,THEME.VOLCANA,5,4,THEME.TIAMAT)

	-- -- local format_name = F'onloading_levelrules(): Set loading target. state.*_next: {state.world_next}, {state.level_next}, {state.theme_next}'
	-- -- message(format_name)

	-- Demo Handling
	if (
		state.level == 4
		and state.world == demolib.DEMO_MAX_WORLD
		and state.screen_next ~= ON.DEATH
	) then
		changestate_onloading_targets(state.world,state.level,state.theme,1,1,THEME.BASE_CAMP)
		set_global_timeout(function()
			if state.screen ~= ON.LEVEL then toast("Demo over. Thanks for playing!") end
		end, 30)
	end

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

-- CHUNK GENERATION - ON.LEVEL
-- Script-based roomcode and chunk generation
function onlevel_generation_modification()
	levelw, levelh = 4, 4
	if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].level_dim ~= nil then
		levelw, levelh = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].level_dim.w, roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].level_dim.h
	end
	roomgenlib.global_levelassembly.modification = {
		levelrooms = levelrooms_setn(levelw, levelh),
		levelcode = levelcode_setn(levelw, levelh),
		rowfive = {
			levelrooms = levelrooms_setn_rowfive(levelw),
			levelcode = levelcode_setn(levelw, 1),
		},
	}
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL) then
		
		unlockslib.get_unlock()

		gen_levelrooms_nonpath(true)
		if detect_level_allow_path_gen() then
			gen_levelrooms_path()
		end
		gen_levelrooms_nonpath(false)
		
		level_generation_method_world_coffin()

		level_generation_method_coffin_coop()

		level_generation_method_shops()
		
		level_generation_method_side()
	else
		-- testing setrooms
		if ((worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING) and (roomdeflib.HD_ROOMOBJECT.TESTING[state.level].setRooms ~= nil)) then
			level_generation_method_setrooms(roomdeflib.HD_ROOMOBJECT.TESTING[state.level].setRooms)
		end
	
		-- tutorial setrooms
		if ((worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL) and (roomdeflib.HD_ROOMOBJECT.TUTORIAL[state.level].setRooms ~= nil)) then
			level_generation_method_setrooms(roomdeflib.HD_ROOMOBJECT.TUTORIAL[state.level].setRooms)
		end
	end

	gen_levelcode_fill() -- roomgenlib.global_levelassembly.modification.levelcode adjusting (obstacle chunks)

end

-- phase one of baking levelcode
	-- spawning most things
function onlevel_generation_execution_phase_one()
	gen_levelcode_phase_1()
	gen_levelcode_phase_1(true)
end

-- phase two of baking levelcode
	-- spawn_over entities, such as spikes
function onlevel_generation_execution_phase_two()
	gen_levelcode_phase_2()
	gen_levelcode_phase_2(true)
end
-- # TODO: More phases to fix crashing entities
	-- water
	-- chain(/vine?)
function onlevel_generation_execution_phase_three()
	gen_levelcode_phase_3()
	gen_levelcode_phase_3(true)
end

-- during on_level
	-- elevators
	-- force fields
function onlevel_generation_execution_phase_four()
	gen_levelcode_phase_4()
	gen_levelcode_phase_4(true)
end

function levelrooms_setn_rowfive(levelw)
	tw = {}
	commonlib.setn(tw, levelw)
	return tw
end

function levelrooms_setn(levelw, levelh)
	path = {}

	commonlib.setn(path, levelh)
	for hi = 1, levelh, 1 do
		tw = {}
		commonlib.setn(tw, levelw)
		path[hi] = tw
	end
	
	return path
end


function levelcode_setn(levelw, levelh)
	levelcodew, levelcodeh = levelw*10, levelh*8
	levelcode = {}

	commonlib.setn(levelcode, levelcodeh)
	for hi = 1, levelcodeh, 1 do
		tw = {}
		commonlib.setn(tw, levelcodew)
		levelcode[hi] = tw
	end

	return levelcode
end

-- LEVEL HANDLING
-- For cases where room generation is hardcoded to a theme's level
-- and as a result we need to fake the world/level number
function onlevel_levelrules()
	-- Dwelling 1-5 = 1-4 (Dwelling 1-3 -> Dwelling 1-4)
	-- changestate_onlevel_fake(1,5,THEME.DWELLING,1,4,THEME.DWELLING)
	
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

function onlevel_create_impostorlake()
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
		local x, y = 22.5, 88.5--80.5
		local w, h = 40, 12
		spawn_impostor_lake(
			AABB:new(
				x-(w/2),
				y+(h/2),
				x+(w/2),
				y-(h/2)
			),
			LAYER.FRONT, ENT_TYPE.LIQUID_IMPOSTOR_LAKE, 1.0
		)
	end
end

function onlevel_removeborderfloor()
	if (
		state.theme == THEME.NEO_BABYLON
		-- or state.theme == THEME.OLMEC -- Lava touching the void ends up in a crash
	) then
		remove_borderfloor()
	end
end

function onlevel_replace_border()
	if (
		state.theme == THEME.EGGPLANT_WORLD
		or state.theme == THEME.VOLCANA
	) then
		
		local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
		if state.theme == THEME.EGGPLANT_WORLD then
			texture_def.texture_path = "res/worm_border.png"
		elseif state.theme == THEME.VOLCANA then
			texture_def.texture_path = "res/hell_border.png"
		end
		boneder_texture = define_texture(texture_def)

		local bonebordere = get_entities_by_type(ENT_TYPE.FLOOR_BORDERTILE) -- get all entities of these types
		for _, boneborder_uid in pairs(bonebordere) do 
			get_entity(boneborder_uid):set_texture(boneder_texture)

			local boneborderdecoratione = entity_get_items_by(boneborder_uid, ENT_TYPE.DECORATION_BORDER, 0)
			for _, boneborderdecoration_uid in pairs(boneborderdecoratione) do
				get_entity(boneborderdecoration_uid):set_texture(boneder_texture)
			end
		end
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

function onlevel_remove_boulderstatue()
	if state.theme == THEME.ICE_CAVES then
		boulderbackgrounds = get_entities_by_type(ENT_TYPE.BG_BOULDER_STATUE)
		if #boulderbackgrounds > 0 then
			kill_entity(boulderbackgrounds[1])
		end
	end
end


-- Use junglespear traps for idol trap blocks and other blocks that shouldn't have post-destruction decorations
set_post_entity_spawn(function(_entity)
	_spikes = entity_get_items_by(_entity.uid, ENT_TYPE.LOGICAL_JUNGLESPEAR_TRAP_TRIGGER, 0)
	for _, _spike in ipairs(_spikes) do
		kill_entity(_spike)
	end
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP)


-- # TODO: Fix the following method. For some godforsaken reason it won't move the player.

-- -- move players and things they have to scripted entrance point
-- function move_entrance_door_entity(_entity)
-- 	_x, _y, _l = get_position(_entity.uid)
-- 	local _offset_x, _offset_y = _x-state.level_gen.spawn_x, _y-state.level_gen.spawn_y
-- 	if (
-- 		state.screen == ON.LEVEL and
-- 		options.hd_debug_scripted_levelgen_disable == false and
-- 		detect_level_non_boss()
-- 	) then
-- 		-- move_entity(_entity.uid, roomgenlib.global_levelassembly.entrance.x+_offset_x, roomgenlib.global_levelassembly.entrance.y+_offset_y, 0, 0)
-- 		move_entity(_entity.uid, roomgenlib.global_levelassembly.entrance.x, roomgenlib.global_levelassembly.entrance.y, 0, 0)
-- 		message("moved to: " .. roomgenlib.global_levelassembly.entrance.x .. ", " .. roomgenlib.global_levelassembly.entrance.y)
-- 	end
-- 	-- message("_offset_x, _offset_y: " .. _offset_x .. ", " .. _offset_y)
-- end
-- set_post_entity_spawn(move_entrance_door_entity,
-- SPAWN_TYPE.ANY,
-- -- SPAWN_TYPE.LEVEL_GEN,
-- -- SPAWN_TYPE.LEVEL_GEN_GENERAL,
-- -- SPAWN_TYPE.LEVEL_GEN_PROCEDURAL,
-- -- SPAWN_TYPE.LEVEL_GEN_TILE_CODE,
-- -- SPAWN_TYPE.SYSTEMIC,
-- MASK.PLAYER)

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY NOTHING
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_YAMA_PLATFORM)

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY NOTHING
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
		-- kill_entity(get_entities_by_type(ENT_TYPE.BG_YAMA_BODY)[1])
		-- for i, yama_floor in ipairs(get_entities_by_type(ENT_TYPE.FLOOR_YAMA_PLATFORM)) do
		-- 	kill_entity(yama_floor)
		-- end

		-- local yama = get_entity(get_entities_by_type(ENT_TYPE.MONS_YAMA)[1])
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.INVISIBLE)
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.TAKE_NO_DAMAGE) -- Unneeded(?)
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
		-- move_entity(0, 1000, 0, 0)
	end
end

set_callback(function(text)
    if (
		text == "Your voice echoes in here..."
		or text == "You hear the beating of drums..."
		or text == "You hear the sounds of revelry!"
		or text == "You feel strangely at peace."
	) then -- this will only work when chosen language is English, unless you add all variants for all languages
        text = "" -- message won't be shown
	elseif (
		text == "Shortcut Station: Coming Soon! -Mama Tunnel"
		or text == "New shortcut coming soon! -Mama Tunnel"
	) then
		text = "Feature in development!"
    end
	return text
end, ON.TOAST)

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

function onguiframe_ui_info_path()
	if (
		options.hd_debug_info_path == true and
		-- (state.pause == 0 and state.screen == 12 and #players > 0) and
		roomgenlib.global_levelassembly ~= nil
	) then
		text_x = -0.95
		text_y = -0.35
		white = rgba(255, 255, 255, 255)
		
		-- levelw, levelh = get_levelsize()
		levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		
		text_y_space = text_y
		for hi = 1, levelh, 1 do -- hi :)
			text_x_space = text_x
			for wi = 1, levelw, 1 do
				text_subchunkid = tostring(roomgenlib.global_levelassembly.modification.levelrooms[hi][wi])
				if text_subchunkid == nil then text_subchunkid = "nil" end
				draw_text(text_x_space, text_y_space, 0, text_subchunkid, white)
				
				text_x_space = text_x_space+0.04
			end
			text_y_space = text_y_space-0.04
		end
	end
end


function level_generation_method_side()

	--[[
		ROOM CODES
	--]]
	-- worlds
	chunkcodes = (
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.SIDE] ~= nil
	) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.SIDE]
	-- feelings
	check_feeling_content = nil
	-- feelings
	for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
		if (
			feelingslib.feeling_check(feeling) == true and
			feelingContent.rooms ~= nil and
			feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.SIDE] ~= nil
		) then
			check_feeling_content = feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.SIDE]
		end
	end
	if check_feeling_content ~= nil then
		chunkcodes = check_feeling_content
	end

	if chunkcodes ~= nil then
		levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		for level_hi = 1, levelh, 1 do
			for level_wi = 1, levelw, 1 do
				subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
				if subchunk_id == nil then -- apply sideroom
					specified_index = math.random(#chunkcodes)
					side_results = nil
					if (
						roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
						roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
						roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[roomdeflib.HD_SUBCHUNKID.SIDE] ~= nil
					) then
						side_results = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[roomdeflib.HD_SUBCHUNKID.SIDE]({wi = level_wi, hi = level_hi})
					end
					for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
						if (
							feelingslib.feeling_check(feeling) == true and
							feelingContent.chunkRules ~= nil and
							feelingContent.chunkRules.rooms ~= nil and
							feelingContent.chunkRules.rooms[roomdeflib.HD_SUBCHUNKID.SIDE] ~= nil
						) then
							side_results = feelingContent.chunkRules.rooms[roomdeflib.HD_SUBCHUNKID.SIDE]({wi = level_wi, hi = level_hi})
						end
					end
					
					if (side_results ~= nil) then
						specified_index = -1
						if (
							side_results.index == nil
						) then
							if side_results.altar ~= nil then
								altar_roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.ALTAR]
								check_feeling_content = nil
								for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
									if (
										feelingslib.feeling_check(feeling) == true and
										feelingContent.rooms ~= nil and
										feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.ALTAR] ~= nil
									) then
										check_feeling_content = feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.ALTAR]
									end
								end
								if check_feeling_content ~= nil then
									altar_roomcodes = check_feeling_content
								end
								if altar_roomcodes == nil then
									altar_roomcodes = roomdeflib.HD_ROOMOBJECT.GENERIC[roomdeflib.HD_SUBCHUNKID.ALTAR]
								end

								levelcode_inject_roomcode(
									roomdeflib.HD_SUBCHUNKID.ALTAR,
									altar_roomcodes,
									level_hi, level_wi
								)
							elseif side_results.idol ~= nil then
								idol_roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.IDOL]
								check_feeling_content = nil
								for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
									if (
										feelingslib.feeling_check(feeling) == true and
										feelingContent.rooms ~= nil and
										feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.IDOL] ~= nil
									) then
										check_feeling_content = feelingContent.rooms[roomdeflib.HD_SUBCHUNKID.IDOL]
									end
								end
								if check_feeling_content ~= nil then
									idol_roomcodes = check_feeling_content
								end
								levelcode_inject_roomcode(
									(
										feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) and
										roomdeflib.HD_SUBCHUNKID.RESTLESS_IDOL or roomdeflib.HD_SUBCHUNKID.IDOL
									),
									(
										feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) and
										roomdeflib.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[roomdeflib.HD_SUBCHUNKID.RESTLESS_IDOL] or
										idol_roomcodes
									),
									level_hi, level_wi
								)
							end
						else
							specified_index = side_results.index
						end
					end

					if specified_index ~= -1 then

						levelcode_inject_roomcode(
							roomdeflib.HD_SUBCHUNKID.SIDE,
							chunkcodes, -- roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.SIDE],
							level_hi, level_wi,
							-- rules
							specified_index
						)
					end
				end
			end
		end
	else
		message("level_generation_method_side: No roomcodes available for siderooms;")
	end
end

function level_generation_method_setrooms_rowfive(setRooms, prePath)
	for _, setroomcont in ipairs(setRooms) do
		if (setroomcont.prePath == nil and prePath == false) or (setroomcont.prePath ~= nil and setroomcont.prePath == prePath) then
			if setroomcont.placement == nil or setroomcont.subchunk_id == nil or setroomcont.roomcodes == nil then
				message("setroom params missing! Couldn't spawn.")
			else
				levelcode_inject_roomcode_rowfive(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement)
			end
		end
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
	
	
	levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y}

	-- build a collection of potential spots
	for level_hi = 1, levelh-(_avoid_bottom and 1 or 0), 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				-- add room
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	spot = commonlib.TableRandomElement(spots)

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
	levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y, facing_left}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				if ( -- add right facing if there is a path on the right
					level_wi+1 <= levelw and
					(
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi+1] ~= nil and
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi+1] >= 1 and
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi+1] <= 8
					)
				) then
					table.insert(spots, {x = level_wi, y = level_hi, facing_left = false})
				elseif (-- add left facing if there is a path on the left
					level_wi-1 >= 1 and
					(
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi-1] ~= nil and
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi-1] >= 1 and
						roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi-1] <= 8
					)
				) then
					table.insert(spots, {x = level_wi, y = level_hi, facing_left = true})
				end
			end
		end
	end

	-- pick random place to fill
	spot = spots[math.random(#spots)]
	if spot ~= nil then
		levelcode_inject_roomcode(
			(spot.facing_left and _aligned_room_types.left.subchunk_id or _aligned_room_types.right.subchunk_id),
			(spot.facing_left and _aligned_room_types.left.roomcodes or _aligned_room_types.right.roomcodes),
			spot.y, spot.x
		)
	end
end

function detect_level_non_boss()
	return (
		state.theme ~= THEME.OLMEC
		and feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false
	)
end
function detect_level_non_special()
	return (
		state.theme ~= THEME.EGGPLANT_WORLD and
		state.theme ~= THEME.NEO_BABYLON and
		state.theme ~= THEME.CITY_OF_GOLD and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end
function detect_level_allow_path_gen()
	return (
		detect_level_non_boss() and
		-- state.theme ~= THEME.CITY_OF_GOLD and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end

function level_generation_method_world_coffin()
	if (
		unlockslib.LEVEL_UNLOCK ~= nil
		and (
			unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
			or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
			or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
			or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
		)
	) then
		level_generation_method_aligned(
			{
				left = {
					subchunk_id = roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end
end

function level_generation_method_coffin_coop()
	if cooplib.detect_level_allow_coop_coffin() then
		levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		
		spots = {}
		for room_y = 1, levelh, 1 do
			for room_x = 1, levelw, 1 do
				path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_y][room_x]
				path_to_replace_with = -1
				
				if path_to_replace == roomdeflib.HD_SUBCHUNKID.PATH_DROP then
					path_to_replace_with = roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP
				elseif path_to_replace == roomdeflib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
					path_to_replace_with = roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
				elseif path_to_replace == roomdeflib.HD_SUBCHUNKID.PATH_NOTOP then
					path_to_replace_with = roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
				elseif path_to_replace == roomdeflib.HD_SUBCHUNKID.PATH then
					path_to_replace_with = roomdeflib.HD_SUBCHUNKID.COFFIN_COOP
				end
				
				if path_to_replace_with ~= -1 then
					table.insert(spots, {x = room_x, y = room_y, id = path_to_replace_with})
				end
			
			end
		end
		if #spots ~= 0 then
			-- pick random place to fill
			spot = spots[math.random(#spots)]
			roomcode = nil
			
			if (
				roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
				roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[spot.id] ~= nil
			) then
				roomcode = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[spot.id]
			end
			-- feelings
			for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
				if (
					feelingslib.feeling_check(feeling) == true and
					feelingContent.rooms ~= nil and
					feelingContent.rooms[spot.id] ~= nil
				) then
					roomcode = feelingContent.rooms[spot.id]
				end
			end

			levelcode_inject_roomcode(
				spot.id,
				roomcode,
				spot.y, spot.x
			)
		end
	end
end

function level_generation_method_shops()
	if (
		detect_same_levelstate(THEME.DWELLING, 1, 1) == false and
		state.theme ~= THEME.VOLCANA and
		detect_level_non_boss() and
		detect_level_non_special()
	) then
		if (math.random(state.level + ((state.world - 1) * 4)) <= 2) then
			shop_id_right = roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR
			shop_id_left = roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT
			-- # TODO: Find real chance of spawning a dice shop.
			-- This is a temporary solution.
			if math.random(7) == 1 then
				state.level_gen.shop_type = SHOP_TYPE.DICE_SHOP
				shop_id_right = roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE
				shop_id_left = roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
			-- elseif state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
			-- 	state.level_gen.shop_type = math.random(0, 5)
			end

			level_generation_method_aligned(
				{
					left = {
						subchunk_id = shop_id_left,
						roomcodes = roomdeflib.HD_ROOMOBJECT.GENERIC[shop_id_left]
					},
					right = {
						subchunk_id = shop_id_right,
						roomcodes = roomdeflib.HD_ROOMOBJECT.GENERIC[shop_id_right]
					}
				}
			)
		end
	end
end

function level_generation_method_structure_vertical(_structure_top, _structure_parts, _struct_x_pool, _mid_height_min)
	_mid_height_min = _mid_height_min or 0
	
	_, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	structx = _struct_x_pool[math.random(1, #_struct_x_pool)]

	-- spawn top
	levelcode_inject_roomcode(_structure_top.subchunk_id, _structure_top.roomcodes, 1, structx)

	if _structure_parts ~= nil then
		mid_height = (_mid_height_min == 0) and 0 or math.random(_mid_height_min, levelh-2)
		-- if _midheight_min == 0 then
		-- 	midheight = 0
		-- else
		-- 	midheight = math.random(_midheight_min, levelh-2)
		-- end

		-- spawn middle
		if _structure_parts.middle ~= nil then
			
			for i = 2, 1+mid_height, 1 do
				levelcode_inject_roomcode(_structure_parts.middle.subchunk_id, _structure_parts.middle.roomcodes, i, structx)
			end
		end
		-- spawn bottom
		if _structure_parts.bottom ~= nil then
			levelcode_inject_roomcode(_structure_parts.bottom.subchunk_id, _structure_parts.bottom.roomcodes, mid_height+2, structx)
		end
	end
end

function levelcode_inject_roomcode_rowfive(_subchunk_id, _roomPool, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	roomgenlib.global_levelassembly.modification.rowfive.levelrooms[_level_wi] = _subchunk_id

	c_y = 1
	c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject_rowfive(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject_rowfive(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	chunkPool_rand_index = _specified_index
	chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			roomgenlib.global_levelassembly.modification.rowfive.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function levelcode_inject_roomcode(_subchunk_id, _roomPool, _level_hi, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	roomgenlib.global_levelassembly.modification.levelrooms[_level_hi][_level_wi] = _subchunk_id

	c_y = ((_level_hi*CONST.ROOM_HEIGHT)-CONST.ROOM_HEIGHT)+1
	c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	chunkPool_rand_index = _specified_index
	chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			roomgenlib.global_levelassembly.modification.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function gen_levelrooms_nonpath(prePath)
	
	if (
		(roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].prePath == nil and prePath == false)
		or (roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].prePath ~= nil and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].prePath == prePath)
	) then
		if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].method ~= nil then
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].method()
		end
	end
	-- world setrooms
	if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].setRooms ~= nil then
		level_generation_method_setrooms(roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].setRooms, prePath)
	end
	if (
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.setRooms ~= nil
	) then
		level_generation_method_setrooms_rowfive(roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.setRooms, prePath)
	end
	
	-- feeling structures
	for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
		if feelingslib.feeling_check(feeling) == true then
			if (feelingContent.prePath == nil and prePath == false) or (feelingContent.prePath ~= nil and feelingContent.prePath == prePath) then
				if feelingContent.method ~= nil then
					-- message("gen_levelrooms_nonpath: Executing feeling spawning method:")
					feelingContent.method()
				end
			end
			if feelingContent.setRooms ~= nil then
				level_generation_method_setrooms(feelingContent.setRooms, prePath)
			end
			if (
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.setRooms ~= nil
			) then
				level_generation_method_setrooms_rowfive(feelingContent.rowfive.setRooms, prePath)
			end
		end
	end

-- # TODO: Coffin Unlock Methods inside of the methods above
-- # TODO: Other Coffin Unlock Methods
--[[
	to right or left of path:
		- world unlock coffins
		- Mothership coffin
		- Yetikingdom
	top room, random x coord:
		- Olmec
	11th room down, replace path room at random x coord:
		- Worm
	top room, leftmost or rightmost:
		- COG
	replace specific roomid(s):
		- Spiderlair
		- Haunted Castle
		- Rushing Water
	middle two rows, replace path_drop or path_notop_drop:
		- Tikivillage
	replace shop:
		- Black Market
--]]
end

-- Edits to the levelcode
function gen_levelcode_fill()
	levelcode_chunks()
	levelcode_chunks(true)
end
 
function levelcode_chunks(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #roomgenlib.global_levelassembly.modification.rowfive.levelrooms
	end
	
	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end

	for levelcode_yi = 1, c_hi_len, 1 do
		for levelcode_xi = 1, c_wi_len, 1 do
			local tilename = roomgenlib.global_levelassembly.modification.levelcode[levelcode_yi][levelcode_xi]
			if rowfive == true then
				tilename = roomgenlib.global_levelassembly.modification.rowfive.levelcode[levelcode_yi][levelcode_xi]
			end

			if roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename] ~= nil then
				chunkcodes = nil

				--[[
					CHUNK CODES
				--]]
				-- worlds
				if (
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks ~= nil and
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename] ~= nil
				) then
					chunkcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename]
				elseif roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes ~= nil then
					chunkcodes = roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes
				end
				-- feelings
				for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.obstacleBlocks ~= nil and
						feelingContent.obstacleBlocks[tilename] ~= nil
					) then
						chunkcodes = feelingContent.obstacleBlocks[tilename]
					end
				end

				--[[
					CHUNK RULES
				--]]
				-- worlds
				chunkpool_rand_index = (
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks ~= nil and
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename] ~= nil
				) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename]() or math.random(#chunkcodes)
				-- feelings
				for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.chunkRules ~= nil and
						feelingContent.chunkRules.obstacleBlocks ~= nil and
						feelingContent.chunkRules.obstacleBlocks[tilename] ~= nil
					) then
						chunkpool_rand_index = feelingContent.chunkRules.obstacleBlocks[tilename]()
					end
				end
	
				if chunkcodes ~= nil then
					c_dim_h, c_dim_w = roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[1], roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[2]
					if rowfive == true then
						levelcode_inject_rowfive(chunkcodes, c_dim_h, c_dim_w, levelcode_yi, levelcode_xi, chunkpool_rand_index)
					else
						levelcode_inject(chunkcodes, c_dim_h, c_dim_w, levelcode_yi, levelcode_xi, chunkpool_rand_index)
					end
				else
					message("levelcode_chunks: No chunkcodes available for tilename \"" .. tilename .. "\";")
				end
			end
		end
	end
end

function gen_levelcode_phase_1(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #roomgenlib.global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = roomgenlib.global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = roomgenlib.global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = tiledeflib.HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = tiledeflib.HD_TILENAME[_tilechar], tiledeflib.HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_1 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_1.default ~= nil then
						entity_type_pool = hd_tiletype.phase_1.default
					end
					if (
						hd_tiletype.phase_1.alternate ~= nil and
						hd_tiletype.phase_1.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_1.alternate[state.theme]
					elseif (
						hd_tiletype.phase_1.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_1.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = tiledeflib.HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = tiledeflib.HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = tiledeflib.HD_TILENAME["w"]
					-- 	end
						
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end

function gen_levelcode_phase_2(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #roomgenlib.global_levelassembly.modification.rowfive.levelrooms
	end

	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end


	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = roomgenlib.global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = roomgenlib.global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = tiledeflib.HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_2 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_2.default ~= nil then
						entity_type_pool = hd_tiletype.phase_2.default
					end
					if (
						hd_tiletype.phase_2.alternate ~= nil and
						hd_tiletype.phase_2.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_2.alternate[state.theme]
					elseif (
						hd_tiletype.phase_2.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_2.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
				end
			end
			x = x + 1
		end
		y = y - 1
	end
end


function gen_levelcode_phase_3(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #roomgenlib.global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = roomgenlib.global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = roomgenlib.global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = tiledeflib.HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = tiledeflib.HD_TILENAME[_tilechar], tiledeflib.HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_3 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_3.default ~= nil then
						entity_type_pool = hd_tiletype.phase_3.default
					end
					if (
						hd_tiletype.phase_3.alternate ~= nil and
						hd_tiletype.phase_3.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_3.alternate[state.theme]
					elseif (
						hd_tiletype.phase_3.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_3.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = tiledeflib.HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = tiledeflib.HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = tiledeflib.HD_TILENAME["w"]
					-- 	end
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end


function gen_levelcode_phase_4(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #roomgenlib.global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = roomgenlib.global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = roomgenlib.global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = tiledeflib.HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = tiledeflib.HD_TILENAME[_tilechar], tiledeflib.HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_4 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_4.default ~= nil then
						entity_type_pool = hd_tiletype.phase_4.default
					end
					if (
						hd_tiletype.phase_4.alternate ~= nil and
						hd_tiletype.phase_4.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_4.alternate[state.theme]
					elseif (
						hd_tiletype.phase_4.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_4.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = tiledeflib.HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = tiledeflib.HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = tiledeflib.HD_TILENAME["w"]
					-- 	end
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end

-- the right side is blocked if:
function detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the right goes off of the path
		wi+1 > maxw
		or
		-- the space to the right has already been filled with a number
		path[hi][wi+1] ~= nil
	)
end

-- the left side is blocked
function detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the left goes off of the path
		wi-1 < minw
		or
		-- the space to the left has already been filled with a number
		path[hi][wi-1] ~= nil
	)
end

-- the under side is blocked
function detect_sideblocked_under(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space under goes off of the path
		hi+1 > maxh
		or
		-- the space under has already been filled with a number
		path[hi+1][wi] ~= nil
	)
end

-- the top side is blocked
function detect_sideblocked_top(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space above goes off of the path
		hi-1 < minh
		or
		-- the space above has already been filled with a number
		path[hi-1][wi] ~= nil
	)
end

-- both sides blocked off
function detect_sideblocked_both(path, wi, hi, minw, minh, maxw, maxh)
	return (
		detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh) and 
		detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	)
end

-- both sides blocked off
function detect_sideblocked_neither(path, wi, hi, minw, minh, maxw, maxh)
	return (
		(false == detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)) and 
		(false == detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh))
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
	-- spread = false
	reverse_path = (state.theme == THEME.NEO_BABYLON)

	levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 1, levelw, levelh
	-- message("levelw, levelh: " .. tostring(levelw) .. ", " .. tostring(levelh))

	-- build an array of unoccupied spaces to start winding downwards from
	rand_startindexes = {}
	for i = 1, levelw, 1 do
		if roomgenlib.global_levelassembly.modification.levelrooms[1][i] == nil then
			rand_startindexes[#rand_startindexes+1] = i
		end
	end	
	
	assigned_exit = false
	assigned_entrance = false
	wi, hi = rand_startindexes[math.random(1, #rand_startindexes)], 1
	dropping = false

	-- don't spawn paths if roomcodes aren't available
	if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] == nil or
	(roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms == nil) then
		-- message("level_createpath: No pathRooms available in roomdeflib.HD_ROOMOBJECT.WORLDS;")
	else
		while assigned_exit == false do
			pathid = math.random(2)
			ind_off_x, ind_off_y = 0, 0
			if (
				(
					-- num == 2 and
					detect_sideblocked_under(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh)
				)
				-- or spread == true
			) then
				pathid = roomdeflib.HD_SUBCHUNKID.PATH
			end
			if pathid == roomdeflib.HD_SUBCHUNKID.PATH then
				dir = 0
				if detect_sideblocked_both(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					pathid = roomdeflib.HD_SUBCHUNKID.PATH_DROP
				elseif detect_sideblocked_neither(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = (math.random(2) == 2) and 1 or -1
				else
					if detect_sideblocked_right(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
						dir = -1
					elseif detect_sideblocked_left(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
						dir = 1
					end
				end
				ind_off_x = dir
			end
			
			if pathid == roomdeflib.HD_SUBCHUNKID.PATH and dropping == true then
				pathid = roomdeflib.HD_SUBCHUNKID.PATH_NOTOP
				dropping = false
			end
			if pathid == roomdeflib.HD_SUBCHUNKID.PATH_DROP then
				ind_off_y = 1
				if dropping == true then
					pathid = roomdeflib.HD_SUBCHUNKID.PATH_DROP_NOTOP
				end
				dropping = true
			end
			if assigned_entrance == false then
				if pathid == roomdeflib.HD_SUBCHUNKID.PATH_DROP then
					pathid = roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP
					if reverse_path == true then
						pathid = roomdeflib.HD_SUBCHUNKID.EXIT_NOTOP
					end
				else
					pathid = roomdeflib.HD_SUBCHUNKID.ENTRANCE
					if reverse_path == true then
						pathid = roomdeflib.HD_SUBCHUNKID.EXIT
					end
				end
				assigned_entrance = true
			elseif hi == maxh then
				if detect_sideblocked_both(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					assigned_exit = true
				else
					assigned_exit = (math.random(2) == 2)
				end
				if assigned_exit == true then
					if pathid == roomdeflib.HD_SUBCHUNKID.PATH_NOTOP then
						pathid = roomdeflib.HD_SUBCHUNKID.EXIT_NOTOP
						if reverse_path == true then
							pathid = roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP
						end
					else
						pathid = roomdeflib.HD_SUBCHUNKID.EXIT
						if reverse_path == true then
							pathid = roomdeflib.HD_SUBCHUNKID.ENTRANCE
						end
					end
				end
			end
			roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] = pathid
			
			
			--[[
				ROOM CODES
			--]]
			-- worlds
			chunkcodes = (
				roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid] ~= nil
			) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid]
			-- feelings
			check_feeling_content = nil
			-- feelings
			for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
				if (
					feelingslib.feeling_check(feeling) == true and
					feelingContent.rooms ~= nil and
					feelingContent.rooms[pathid] ~= nil
				) then
					check_feeling_content = feelingContent.rooms[pathid]
				end
			end
			if check_feeling_content ~= nil then
				chunkcodes = check_feeling_content
			end

			if (
				chunkcodes ~= nil
			) then
				
				specified_index = math.random(#chunkcodes)
				if (
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
					roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid] ~= nil
				) then
					specified_index = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid]()
				end
				check_feeling_content = nil
				for feeling, feelingContent in pairs(roomdeflib.HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.chunkRules ~= nil and
						feelingContent.chunkRules.rooms ~= nil and
						feelingContent.chunkRules.rooms[pathid] ~= nil
					) then
						check_feeling_content = feelingContent.chunkRules.rooms[pathid]()
					end
				end
				if check_feeling_content ~= nil then
					specified_index = check_feeling_content
				end

				levelcode_inject_roomcode(
					pathid,
					chunkcodes,
					hi, wi,
					-- rules
					specified_index
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
					-- Log in separate 2d array `rooms_subchunkids`: Based on genlib.HD_SUBCHUNKID and whether the space contains a shopkeep, log subchunk ids as generated by the game.
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
			-- initialize an empty table t of size n: commonlib.setn(t, n)
		-- Black Market & Flooded Revamp:
			-- Replace S2 style black market with HD
				-- HD and S2 differences:
					-- S2 black market spawns are 2-2, 2-3, and 2-4
					-- HD spawns are 2-1, 2-2, and 2-3
						-- Prevents the black market from being accessed upon exiting the worm
						-- Gives room for the next level to load as black market
				-- script spawning LOGICAL_BLACKMARKET_DOOR
					-- if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET_ENTRANCE) == true
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
