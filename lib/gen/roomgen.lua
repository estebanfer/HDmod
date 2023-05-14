local spikeslib = require 'lib.entities.spikes'
local hideyholelib = require 'lib.entities.hideyhole'

local module = {}

optionslib.register_option_bool("hd_debug_scripted_levelgen_path_info", "Level gen - Show path info", nil, false, true)
optionslib.register_option_string("hd_debug_scripted_levelgen_tilecodes_blacklist", "Level gen - Blacklist tilecodes", nil, "", true)

POSTTILE_STARTBOOL = false
FRAG_PREVENTION_UID = nil


module.global_levelassembly = nil

function module.init_posttile_door()
	module.global_levelassembly = {}
end


local function init_onlevel()
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
	moailib.init()
	doorslib.init()
	tombstonelib.init()
	roomdeflib.init()
	spikeslib.init()
	hideyholelib.init()
end

--[[
	post_tile-sensitive ON.START initializations

	Since ON.START runs on the first ON.SCREEN of a run, it runs after post_tile runs.
	Run this in post_tile to circumvent the issue.
]]
local function init_posttile_onstart()
	if POSTTILE_STARTBOOL == false then -- determine if you need to set new things
		POSTTILE_STARTBOOL = true

		feelingslib.init()
	end
end

local function levelcreation_init()
	init_onlevel()
	unlockslib.unlocks_load()

	if (
		(worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL)
		-- (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)
		-- or (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TESTING)
	) then
		feelingslib.onlevel_set_feelings()
	end
	flagslib.clear_dark_level()
	feelingslib.onlevel_set_feelingToastMessage()
end

local assign_s2_level_height

set_callback(function()
	if state.screen == SCREEN.LEVEL then
		init_posttile_onstart()

		if options.hd_debug_scripted_levelgen_disable == false then
			roomgenlib.init_posttile_door()
			levelcreation_init()
		end
	end
end, ON.PRE_LEVEL_GENERATION)

set_callback(function()
	if state.screen == SCREEN.LEVEL and options.hd_debug_scripted_levelgen_disable == false then
		assign_s2_level_height()
	end
end, ON.POST_ROOM_GENERATION)

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_scripted_levelgen_disable == false then
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


set_pre_tile_code_callback(function(x, y, layer)
	local type_to_use = ENT_TYPE.FLOOR_GENERIC

	if state.theme == THEME.TEMPLE then
		type_to_use = (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE)
	end

	local entity = get_entity(spawn_grid_entity(type_to_use, x, y, layer))
	entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)

	return true
end, "shop_wall")

-- remove the lephrechaun that spawns with echoes levels and chests
--[[
set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return 0
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_LEPRECHAUN)
]]

function assign_s2_level_height()
	
	local new_width = 4
	local new_height = 4

	if (--levels that already have a constant width and height
		state.theme ~= THEME.OLMEC
		and state.theme ~= THEME.EGGPLANT_WORLD
		and state.theme ~= THEME.CITY_OF_GOLD
	) then
		-- set height for rushing water
		if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
			new_height = 5
		elseif state.theme == THEME.ICE_CAVES
		or state.theme == THEME.NEO_BABYLON then
			--aproximated size
			new_height = 7
		end
		state.width = new_width
		state.height = new_height
	end
end

function module.detect_same_levelstate(t_a, l_a, w_a)
	if state.theme == t_a and state.level == l_a and state.world == w_a then return true else return false end
end

set_callback(function()
	POSTTILE_STARTBOOL = false
end, ON.RESET)


-- set_callback(function()
-- 	-- roomgenlib.global_levelassembly = nil
-- end, ON.TRANSITION)

local levelrooms_setn, levelrooms_setn_rowfive, levelcode_setn, level_generation_method_side
local level_generation_method_setrooms, detect_level_allow_path_gen, level_generation_method_world_coffin
local level_generation_method_coffin_coop, level_generation_method_shops
local gen_levelrooms_nonpath, gen_levelcode_fill, gen_levelrooms_path
--[[
	CHUNK GENERATION - ON.LEVEL

	Script-based roomcode and chunk generation
]]
function module.onlevel_generation_modification()
	-- Initialize global_levelassembly
	local levelw, levelh = 4, 4
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

	gen_levelcode_fill() -- fills in obstacle blocks

end

local gen_levelcode_phase
-- phase one of baking levelcode
	-- spawning most things
function module.onlevel_generation_execution_phase_one()
	gen_levelcode_phase(1)
	gen_levelcode_phase(1, true)
end

-- phase two of baking levelcode
	-- spawn_over entities, such as spikes
function module.onlevel_generation_execution_phase_two()
	gen_levelcode_phase(2)
	gen_levelcode_phase(2, true)
end

-- More phases to fix crashing entities
	-- water
	-- chain(/vine?)
function module.onlevel_generation_execution_phase_three()
	gen_levelcode_phase(3)
	gen_levelcode_phase(3, true)
end

function levelrooms_setn_rowfive(levelw)
	local tw = {}
	commonlib.setn(tw, levelw)
	return tw
end

function levelrooms_setn(levelw, levelh)
	local path = {}

	commonlib.setn(path, levelh)
	for hi = 1, levelh, 1 do
		local tw = {}
		commonlib.setn(tw, levelw)
		path[hi] = tw
	end
	
	return path
end


function levelcode_setn(levelw, levelh)
	local levelcodew, levelcodeh = levelw*10, levelh*8
	local levelcode = {}

	commonlib.setn(levelcode, levelcodeh)
	for hi = 1, levelcodeh, 1 do
		local tw = {}
		commonlib.setn(tw, levelcodew)
		levelcode[hi] = tw
	end

	return levelcode
end


function level_generation_method_side()

	--[[
		ROOM CODES
	--]]
	-- worlds
	local chunkcodes = (
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
		roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.SIDE] ~= nil
	) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.SIDE]
	-- feelings
	local check_feeling_content = nil
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
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		for level_hi = 1, levelh, 1 do
			for level_wi = 1, levelw, 1 do
				local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
				if subchunk_id == nil then -- apply sideroom
					local specified_index = math.random(#chunkcodes)
					local side_results = nil
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
								local altar_roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.ALTAR]
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

								module.levelcode_inject_roomcode(
									roomdeflib.HD_SUBCHUNKID.ALTAR,
									altar_roomcodes,
									level_hi, level_wi
								)
							elseif side_results.idol ~= nil then
								local idol_roomcodes = roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[roomdeflib.HD_SUBCHUNKID.IDOL]
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
								module.levelcode_inject_roomcode(
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

						module.levelcode_inject_roomcode(
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

local function level_generation_method_setrooms_rowfive(setRooms, prePath)
	for _, setroomcont in ipairs(setRooms) do
		if (setroomcont.prePath == nil and prePath == false) or (setroomcont.prePath ~= nil and setroomcont.prePath == prePath) then
			if setroomcont.placement == nil or setroomcont.subchunk_id == nil or setroomcont.roomcodes == nil then
				message("setroom params missing! Couldn't spawn.")
			else
				module.levelcode_inject_roomcode_rowfive(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement)
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
				module.levelcode_inject_roomcode(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement[1], setroomcont.placement[2])
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
function module.level_generation_method_nonaligned(_nonaligned_room_type, _avoid_bottom)
	_avoid_bottom = _avoid_bottom or false
	
	
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	local spots = {}
		--{x, y}

	-- build a collection of potential spots
	for level_hi = 1, levelh-(_avoid_bottom and 1 or 0), 1 do
		for level_wi = 1, levelw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				-- add room
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	local spot = commonlib.TableCopyRandomElement(spots)

	module.levelcode_inject_roomcode(_nonaligned_room_type.subchunk_id, _nonaligned_room_type.roomcodes, spot.y, spot.x)
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
function module.level_generation_method_aligned(_aligned_room_types)
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	local spots = {}
		--{x, y, facing_left}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
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
	local spot = spots[math.random(#spots)]
	if spot ~= nil then
		module.levelcode_inject_roomcode(
			(spot.facing_left and _aligned_room_types.left.subchunk_id or _aligned_room_types.right.subchunk_id),
			(spot.facing_left and _aligned_room_types.left.roomcodes or _aligned_room_types.right.roomcodes),
			spot.y, spot.x
		)
	end
end

function module.detect_level_non_boss()
	return (
		state.theme ~= THEME.OLMEC
		and feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false
	)
end
function module.detect_level_non_special()
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
		module.detect_level_non_boss() and
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
		module.level_generation_method_aligned(
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
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		
		local spots = {}
		for room_y = 1, levelh, 1 do
			for room_x = 1, levelw, 1 do
				local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_y][room_x]
				local path_to_replace_with = -1
				
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
			local spot = spots[math.random(#spots)]
			local roomcode = nil
			
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

			module.levelcode_inject_roomcode(
				spot.id,
				roomcode,
				spot.y, spot.x
			)
		end
	end
end

function level_generation_method_shops()
	if (
		roomgenlib.detect_same_levelstate(THEME.DWELLING, 1, 1) == false
		and state.theme ~= THEME.VOLCANA
		and module.detect_level_non_boss()
		and module.detect_level_non_special()
		and (math.random(state.level + ((state.world - 1) * 4)) <= 2)
	) then
		local shop_id_right = roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR
		local shop_id_left = roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT

        -- prinspect(string.format('Prior shop_type: %s', state.level_gen.shop_type))
		-- # TODO: Find and implement HD chances of shop types
		if math.random(7) == 1 then
			state.level_gen.shop_type = SHOP_TYPE.DICE_SHOP
			shop_id_right = roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE
			shop_id_left = roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
		elseif state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
			state.level_gen.shop_type = math.random(0, 5)
		end
        -- prinspect(string.format('Post-script shop_type: %s', state.level_gen.shop_type))

		module.level_generation_method_aligned(
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

function module.level_generation_method_structure_vertical(_structure_top, _structure_parts, _struct_x_pool, _mid_height_min)
	_mid_height_min = _mid_height_min or 0
	
	local _, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	local structx = _struct_x_pool[math.random(1, #_struct_x_pool)]

	-- spawn top
	module.levelcode_inject_roomcode(_structure_top.subchunk_id, _structure_top.roomcodes, 1, structx)

	if _structure_parts ~= nil then
		local mid_height = (_mid_height_min == 0) and 0 or math.random(_mid_height_min, levelh-2)
		-- if _midheight_min == 0 then
		-- 	midheight = 0
		-- else
		-- 	midheight = math.random(_midheight_min, levelh-2)
		-- end

		-- spawn middle
		if _structure_parts.middle ~= nil then
			
			for i = 2, 1+mid_height, 1 do
				module.levelcode_inject_roomcode(_structure_parts.middle.subchunk_id, _structure_parts.middle.roomcodes, i, structx)
			end
		end
		-- spawn bottom
		if _structure_parts.bottom ~= nil then
			module.levelcode_inject_roomcode(_structure_parts.bottom.subchunk_id, _structure_parts.bottom.roomcodes, mid_height+2, structx)
		end
	end
end

local levelcode_inject_rowfive
function module.levelcode_inject_roomcode_rowfive(_subchunk_id, _roomPool, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	roomgenlib.global_levelassembly.modification.rowfive.levelrooms[_level_wi] = _subchunk_id

	local c_y = 1
	local c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("module.levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject_rowfive(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject_rowfive(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	local chunkPool_rand_index = _specified_index
	local chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	local chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	local i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			roomgenlib.global_levelassembly.modification.rowfive.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

local levelcode_inject
function module.levelcode_inject_roomcode(_subchunk_id, _roomPool, _level_hi, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	roomgenlib.global_levelassembly.modification.levelrooms[_level_hi][_level_wi] = _subchunk_id

	local c_y = ((_level_hi*CONST.ROOM_HEIGHT)-CONST.ROOM_HEIGHT)+1
	local c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("module.levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	local chunkPool_rand_index = _specified_index
	local chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	local chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	local i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			roomgenlib.global_levelassembly.modification.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function gen_levelrooms_nonpath(prePath)
	if prePath then
		if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].prePathMethod ~= nil then
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].prePathMethod()
		end
	else
		if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].postPathMethod ~= nil then
			roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].postPathMethod()
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
			if prePath then
				if feelingContent.prePathMethod ~= nil then
					feelingContent.prePathMethod()
				end
			else
				if feelingContent.postPathMethod ~= nil then
					feelingContent.postPathMethod()
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
end

--[[
	Obstacle chunk edits to the levelcode
]]
local levelcode_chunks
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
				local chunkcodes = nil

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
				local chunkpool_rand_index = (
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
					local c_dim_h, c_dim_w = roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[1], roomdeflib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[2]
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

function gen_levelcode_phase(phase, rowfive)
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
	local y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		local x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			local _tilechar = roomgenlib.global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = roomgenlib.global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			local hd_tiletype = tiledeflib.HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = tiledeflib.HD_TILENAME[_tilechar], tiledeflib.HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phases ~= nil and hd_tiletype.phases[phase] ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					local entity_type_pool = {}
					local entity_type = 0
					if hd_tiletype.phases[phase].default ~= nil then
						entity_type_pool = hd_tiletype.phases[phase].default
					end
					if (
						hd_tiletype.phases[phase].alternate ~= nil and
						hd_tiletype.phases[phase].alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phases[phase].alternate[state.theme]
					elseif (
						hd_tiletype.phases[phase].tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phases[phase].tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableCopyRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
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
function module.detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the right goes off of the path
		wi+1 > maxw
		or
		-- the space to the right has already been filled with a number
		path[hi][wi+1] ~= nil
	)
end

-- the left side is blocked
function module.detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the left goes off of the path
		wi-1 < minw
		or
		-- the space to the left has already been filled with a number
		path[hi][wi-1] ~= nil
	)
end

-- the under side is blocked
local function detect_sideblocked_under(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space under goes off of the path
		hi+1 > maxh
		or
		-- the space under has already been filled with a number
		path[hi+1][wi] ~= nil
	)
end

-- the top side is blocked
local function detect_sideblocked_top(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space above goes off of the path
		hi-1 < minh
		or
		-- the space above has already been filled with a number
		path[hi-1][wi] ~= nil
	)
end

-- both sides blocked off
function module.detect_sideblocked_both(path, wi, hi, minw, minh, maxw, maxh)
	return (
		module.detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh) and 
		module.detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	)
end

-- both sides blocked off
function module.detect_sideblocked_neither(path, wi, hi, minw, minh, maxw, maxh)
	return (
		(false == module.detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)) and 
		(false == module.detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh))
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
	local reverse_path = (state.theme == THEME.NEO_BABYLON)

	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	local minw, minh, maxw, maxh = 1, 1, levelw, levelh
	-- message("levelw, levelh: " .. tostring(levelw) .. ", " .. tostring(levelh))

	-- build an array of unoccupied spaces to start winding downwards from
	local rand_startindexes = {}
	for i = 1, levelw, 1 do
		if roomgenlib.global_levelassembly.modification.levelrooms[1][i] == nil then
			rand_startindexes[#rand_startindexes+1] = i
		end
	end	
	
	local assigned_exit = false
	local assigned_entrance = false
	local wi, hi = rand_startindexes[math.random(1, #rand_startindexes)], 1
	local dropping = false

	-- don't spawn paths if roomcodes aren't available
	if roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] == nil or
	(roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms == nil) then
		-- message("level_createpath: No pathRooms available in roomdeflib.HD_ROOMOBJECT.WORLDS;")
	else
		while assigned_exit == false do
			local pathid = math.random(2)
			local ind_off_x, ind_off_y = 0, 0
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
				local dir = 0
				if module.detect_sideblocked_both(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					pathid = roomdeflib.HD_SUBCHUNKID.PATH_DROP
				elseif module.detect_sideblocked_neither(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = (math.random(2) == 2) and 1 or -1
				else
					if module.detect_sideblocked_right(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
						dir = -1
					elseif module.detect_sideblocked_left(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
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
				if module.detect_sideblocked_both(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
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
			local chunkcodes = (
				roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid] ~= nil
			) and roomdeflib.HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid]
			-- feelings
			local check_feeling_content = nil
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
				
				local specified_index = math.random(#chunkcodes)
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

				module.levelcode_inject_roomcode(
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



---@param draw_ctx GuiDrawContext
set_callback(function(draw_ctx)
	if (
		options.hd_debug_scripted_levelgen_path_info == true and
		-- (state.pause == 0 and state.screen == 12 and #players > 0) and
		roomgenlib.global_levelassembly ~= nil
	) then
		local text_x = -0.95
		local text_y = -0.35
		local white = rgba(255, 255, 255, 255)
		
		-- levelw, levelh = get_levelsize()
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		
		local text_y_space = text_y
		for hi = 1, levelh, 1 do -- hi :)
			local text_x_space = text_x
			for wi = 1, levelw, 1 do
				local text_subchunkid = tostring(roomgenlib.global_levelassembly.modification.levelrooms[hi][wi])
				if text_subchunkid == nil then text_subchunkid = "nil" end
				draw_ctx:draw_text(text_x_space, text_y_space, 0, text_subchunkid, white)
				
				text_x_space = text_x_space+0.04
			end
			text_y_space = text_y_space-0.04
		end
	end
end, ON.GUIFRAME)

return module