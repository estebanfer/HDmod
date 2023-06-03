local module = {}

optionslib.register_option_bool("hd_debug_testing_door", "Enable testing door in camp", nil, false, true)

local stone_door_texture_id
do
    local stone_door_texture_def = TextureDefinition.new()
    stone_door_texture_def.width = 386
    stone_door_texture_def.height = 640
    stone_door_texture_def.tile_width = 386
    stone_door_texture_def.tile_height = 320
    stone_door_texture_def.texture_path = "res/stone_doors.png"
    stone_door_texture_id = define_texture(stone_door_texture_def)
end

module.DOOR_TESTING_UID = nil
module.DOOR_TUTORIAL_UID = nil

function module.create_door_testing(x, y, l)
	module.DOOR_TESTING_UID = spawn_door(x, y, l, 1, 1, THEME.DWELLING)--THEME.TIDE_POOL)
	local door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_3)
	get_entity(door_bg).animation_frame = 1
end

function module.create_door_tutorial(x, y, l)
	if options.hd_debug_demo_enable_tutorial then
		module.DOOR_TUTORIAL_UID = spawn_door(x, y, l, 1, 1, THEME.DWELLING)
	else
		local construction_sign = get_entity(spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, l, 0, 0))
		construction_sign:set_draw_depth(40)
	end
	local door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
end

local function entrance_force_worldstate(_worldstate, _entrance_uid)
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
		local door_entrance_ent = get_entity(_entrance_uid)
		if door_entrance_ent ~= nil then
			for i = 1, #players, 1 do
				if (
					door_entrance_ent:overlaps_with(get_entity(players[i].uid)) == true and
					players[i].state == CHAR_STATE.ENTERING
				) then
					worldlib.HD_WORLDSTATE_STATE = _worldstate
					break;
				end
			end
		end
	end
end

local function entrance_testing()
	entrance_force_worldstate(worldlib.HD_WORLDSTATE_STATUS.TESTING, camplib.DOOR_TESTING_UID)
end

local function entrance_tutorial()
	entrance_force_worldstate(worldlib.HD_WORLDSTATE_STATUS.TUTORIAL, camplib.DOOR_TUTORIAL_UID)
end

local function oncamp_tunnelman_spawn(x, y, l)
	local marla_uid = spawn_entity_nonreplaceable(ENT_TYPE.MONS_MARLA_TUNNEL, x, y, l, 0, 0)
	local marla = get_entity(marla_uid)
	marla.flags = clr_flag(marla.flags, ENT_FLAG.FACING_LEFT)
	return marla_uid
end

local function oncamp_shortcuts(x, y, l)

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
	local shortcut_flagstocheck = {4, 7, 10}
	local shortcut_worlds = {2, 3, 4}
	local shortcut_levels = {1, 1, 1}
	local shortcut_themes = {THEME.JUNGLE, THEME.ICE_CAVES, THEME.TEMPLE}
	local shortcut_doortextures = {
		TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1,
		TEXTURE.DATA_TEXTURES_FLOOR_ICE_1,
		(options.hd_og_floorstyle_temple and stone_door_texture_id or TEXTURE.DATA_TEXTURES_FLOOR_TEMPLE_1)
	}
	
	-- hd-accurate x-placement of first shortcut door: 16
	-- pre-camera fix x-placement of first shortcut door: 19
	local new_x = x
	local shortcut_available = false
	for i, flagtocheck in ipairs(shortcut_flagstocheck) do
		if (
			(shortcut_worlds[i] <= demolib.DEMO_MAX_WORLD or options.hd_debug_demo_enable_all_worlds)
			-- and savegame.shortcuts >= flagtocheck
		) then
			spawn_door(new_x, y, l, shortcut_worlds[i], shortcut_levels[i], shortcut_themes[i])
		else
			local construction_sign = get_entity(spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, new_x, y, l, 0, 0))
			construction_sign:set_draw_depth(40)
		end
		
		local door_bg = spawn_entity(ENT_TYPE.BG_DOOR, new_x, y+.31, l, 0, 0)
		get_entity(door_bg):set_texture(shortcut_doortextures[i])
		get_entity(door_bg).animation_frame = 1

		-- local sign = get_entity(spawn_entity(ENT_TYPE.ITEM_SHORTCUT_SIGN, new_x+1, y-0.5, LAYER.FRONT, 0, 0))
		-- local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_BASECAMP_1)
		-- texture_def.texture_path = "res/shortcut_signs.png"
		-- sign:set_texture(define_texture(texture_def))
		-- sign.animation_frame = sign.animation_frame + (i-1)

		-- hd-accurate space between shortcut doors: 4
		-- pre-camera fix space between shortcut doors: 3
		new_x = new_x + 4
	end
end

local function oncamp_fixes()
	-- fix gap in floor where S2 shortcut would normally spawn
	spawn(ENT_TYPE.FLOOR_GENERIC, 21, 84, LAYER.FRONT, 0, 0)

	-- # TODO: add missing wood bg decorations (wood bg doesn't get placed past the usual s2 camera bounds)

end


set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return 0
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MARLA_TUNNEL)

define_tile_code("hd_shortcuts")
define_tile_code("hd_tunnelman")

set_pre_tile_code_callback(function(x, y, layer)
	oncamp_tunnelman_spawn(x, y, layer)
	return true
end, "hd_tunnelman")

set_post_tile_code_callback(function(x, y, layer)
	oncamp_shortcuts(x, y, layer)
	oncamp_fixes()
	return true
end, "hd_shortcuts")

define_tile_code("hd_door_tutorial")
define_tile_code("hd_door_testing")

set_post_tile_code_callback(function(x, y, layer)
	camplib.create_door_tutorial(x, y, layer)
	return true
end, "hd_door_tutorial")

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_testing_door == true then
		camplib.create_door_testing(x, y, layer)
	end
	return true
end, "hd_door_testing")


-- ON.CAMP
set_callback(function()
	-- pre_tile ON.START stuff
	worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL

	set_interval(entrance_tutorial, 1)
	if options.hd_debug_testing_door == true then
		set_interval(entrance_testing, 1)
	end

	state.camera.bounds_top = 93.9
	state.camera.bounds_bottom = 82.7
	state.camera.bounds_left = 8.5
	state.camera.bounds_right = 51.5

	state.camera.adjusted_focus_x = 41.55
	state.camera.adjusted_focus_y = 88.3

end, ON.CAMP)

set_callback(function()
	set_camp_camera_bounds_enabled(false)
end, ON.LOGO)

return module