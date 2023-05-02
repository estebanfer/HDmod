local removelib = require 'lib.spawning.remove'

local module = {}

optionslib.register_option_bool("hd_og_cursepot_enable", "OG: Enable curse pot spawning", nil, false) -- Defaults to HD

local function onlevel_create_impostorlake()
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

local function onlevel_removeborderfloor()
	if (
		state.theme == THEME.NEO_BABYLON
		-- or state.theme == THEME.OLMEC -- Lava touching the void ends up in a crash
	) then
		local xmin, _, xmax, ymax = get_bounds()
		for yi = ymax-0.5, (ymax-0.5)-2, -1 do
			for xi = xmin+0.5, xmax-0.5, 1 do
				local uid = get_grid_entity_at(xi, yi, LAYER.FRONT)
				if uid ~= -1 then get_entity(uid):destroy() end
			end
		end
	end
end

-- # TODO: Do a pre_entity_spawn version of this that replaces the floor instead.
local function onlevel_remove_s2_generated_gapblocks()
	if (
		state.theme == THEME.NEO_BABYLON
		or state.theme == THEME.EGGPLANT_WORLD
	) then
		for _, uid in pairs(get_entities_by(state.theme == THEME.NEO_BABYLON and ENT_TYPE.FLOORSTYLED_BABYLON or ENT_TYPE.FLOOR_GENERIC, 0, LAYER.FRONT)) do
			get_entity(uid):destroy()
		end
	end
end


local function onlevel_replace_border_textures()
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
		local boneder_texture = define_texture(texture_def)

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

local function onlevel_remove_cursedpot()
	local cursedpot_uids = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
	if #cursedpot_uids > 0 and options.hd_og_cursepot_enable == false then
		local xmin, ymin, _, _ = get_bounds()
		local void_x = xmin - 3.5
		local void_y = ymin
		spawn_entity(ENT_TYPE.FLOOR_BORDERTILE, void_x, void_y, LAYER.FRONT, 0, 0)
		for _, cursedpot_uid in ipairs(cursedpot_uids) do
			move_entity(cursedpot_uid, void_x, void_y+1, 0, 0)
		end
	end
end

local function onlevel_remove_mounts()
	local mounts = get_entities_by_type({
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
			local mov = get_entity(mount)
			if test_flag(mov.flags, ENT_FLAG.SHOP_ITEM) == false then --and stop_remove == false then
				move_entity(mount, 0, 0, 0, 0)
			end
		end
	end
end

function module.remove_boulderstatue()
	if state.theme == THEME.ICE_CAVES then
		for _, uid in ipairs(get_entities_by_type(ENT_TYPE.BG_BOULDER_STATUE)) do
			get_entity(uid):destroy()
		end
	end
end

function module.remove_neobab_decorations()
	if state.theme == THEME.NEO_BABYLON then
		for _, uid in ipairs(get_entities_by_type({ENT_TYPE.DECORATION_BABYLON_NEON_SIGN, ENT_TYPE.DECORATION_HANGING_WIRES})) do
			get_entity(uid):destroy()
		end
	end
end

local function onlevel_remove_cobwebs_on_pushblocks()
	if (--only run on any themes that have pushblocks
		state.theme == THEME.DWELLING
		or state.theme == THEME.TEMPLE
		or state.theme == THEME.OLMEC
		or state.theme == THEME.VOLCANA
	) then
		local pushblocks = get_entities_by({ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, ENT_TYPE.ACTIVEFLOOR_POWDERKEG}, MASK.ACTIVEFLOOR, LAYER.FRONT)
		for _, pushblock in ipairs(pushblocks) do
			local x, y, _ = get_position(pushblock)
			local webs = get_entities_at(ENT_TYPE.ITEM_WEB, MASK.ITEM, x, y+1, LAYER.FRONT, 0.5)
			if (
				#webs ~= 0
				and get_entity_type(webs[1]) == ENT_TYPE.ITEM_WEB
			) then
				kill_entity(webs[1])
			end
		end
	end
end

local function remove_door_items()
	if state.theme ~= THEME.OLMEC then
		local items_to_remove = {
			ENT_TYPE.ITEM_POT,
			ENT_TYPE.ITEM_SKULL,
			ENT_TYPE.ITEM_BONES,
			ENT_TYPE.ITEM_ROCK,
			ENT_TYPE.ITEM_WEB,
			ENT_TYPE.ITEM_CHEST,
			ENT_TYPE.ITEM_CRATE,
			ENT_TYPE.ITEM_RUBY,
			ENT_TYPE.ITEM_SAPPHIRE,
			ENT_TYPE.ITEM_EMERALD,
			ENT_TYPE.ITEM_GOLDBAR,
			ENT_TYPE.ITEM_GOLDBARS
		}
		removelib.remove_non_held_item(
			items_to_remove,
			roomgenlib.global_levelassembly.exit.x, roomgenlib.global_levelassembly.exit.y
		)
		removelib.remove_non_held_item(
			items_to_remove,
			roomgenlib.global_levelassembly.entrance.x, roomgenlib.global_levelassembly.entrance.y
		)
	end
end

-- remove pots and rocks that weren't placed via scripting
set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if (
		spawn_flags & SPAWN_TYPE.SCRIPT == 0
		and (
			worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
			or state.theme == THEME.NEO_BABYLON
			or feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR)
		)
	) then
        return spawn_entity(ENT_TYPE.FX_SHADOW, x, y, l, 0, 0)
    end
end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, ENT_TYPE.ITEM_ROCK, ENT_TYPE.ITEM_POT)

-- remove spiderwebs from tutorial
set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if (
		spawn_flags & SPAWN_TYPE.SCRIPT == 0
		and worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
	) then
        return spawn_entity(ENT_TYPE.FX_SHADOW, x, y, l, 0, 0)
    end
end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, ENT_TYPE.ITEM_WEB)

-- remove nonscript critters
set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if spawn_flags & SPAWN_TYPE.SCRIPT == 0 then
        return spawn_entity(ENT_TYPE.FX_SHADOW, x, y, l, 0, 0)
    end
end,
	SPAWN_TYPE.ANY,-- SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL,
	0,
	ENT_TYPE.MONS_CRITTERANCHOVY,
	ENT_TYPE.MONS_CRITTERBUTTERFLY,
	ENT_TYPE.MONS_CRITTERCRAB,
	ENT_TYPE.MONS_CRITTERDRONE,
	ENT_TYPE.MONS_CRITTERDUNGBEETLE,
	ENT_TYPE.MONS_CRITTERFIREFLY,
	ENT_TYPE.MONS_CRITTERFISH,
	ENT_TYPE.MONS_CRITTERLOCUST,
	ENT_TYPE.MONS_CRITTERPENGUIN,
	ENT_TYPE.MONS_CRITTERSLIME,
	ENT_TYPE.MONS_CRITTERSNAIL
)

function module.postlevelgen_remove_items()
	remove_door_items()
end

function module.postlevelgen_spawn_dar_fog()
	if (
		not feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS)
		and not feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE)
	) then return end

	local random_entity = get_entities_by(ENT_TYPE.BG_LEVEL_BACKWALL, MASK.SHADOW, LAYER.FRONT)[1]
	for rx = 1, state.width, 2 do
		for ry = 1, state.height, 2 do
			local part = generate_world_particles(PARTICLEEMITTER.TOMB_FOG, random_entity)
			part.entity_uid = -1
			part.x, part.y = get_room_pos(rx, ry)
		end
	end
end

function module.postlevelgen_fix_jungle_door_ambient_sound()
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
		if state.theme == THEME.DWELLING and state.level == 4 then
			local door = get_entities_by(ENT_TYPE.FLOOR_DOOR_EXIT, MASK.FLOOR, LAYER.FRONT)[1]

			local old_ambient = entity_get_items_by(door, ENT_TYPE.LOGICAL_DOOR_AMBIENT_SOUND, MASK.LOGICAL)[1]
			kill_entity(old_ambient)

			--Spawn ambient on the left, so it becomes the jungle ambient (must have an overlay)
			local x, y = get_position(door)
			local left_bordertile = get_grid_entity_at(0, y, LAYER.FRONT)
			local ambient = spawn_over(ENT_TYPE.LOGICAL_DOOR_AMBIENT_SOUND, left_bordertile, 0, 0)

			--Move it and attach to the door
			move_entity(ambient, x, y, 0, 0)
			attach_entity(door, ambient)
		elseif state.theme == THEME.ICE_CAVES and state.level == 4 then
			local doors = get_entities_by(ENT_TYPE.FLOOR_DOOR_EXIT, MASK.FLOOR, LAYER.FRONT)
			for _, door in pairs(doors) do
				local x, y = get_position(door)
				local rx, ry = get_room_index(x, y)
				local room_template = get_room_template(rx, ry, LAYER.FRONT)
				--Ignore MS door and moai door
				if room_template == ROOM_TEMPLATE.EXIT or room_template == ROOM_TEMPLATE.EXIT_NOTOP then
					-- messpect("main door room", get_room_template_name(room_template))
					spawn_over(ENT_TYPE.LOGICAL_DOOR_AMBIENT_SOUND, door, 0, 0)
					break
				end
			end
		end
	end
end

function module.onlevel_touchups()
	onlevel_remove_cursedpot()
	onlevel_remove_mounts()
	onlevel_replace_border_textures()
	onlevel_removeborderfloor()
	onlevel_create_impostorlake()
	onlevel_remove_cobwebs_on_pushblocks()
	onlevel_remove_s2_generated_gapblocks()
end

-- set_post_entity_spawn(function(entity)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN_FLOOR_SPREADING, 0)

-- Use junglespear traps for idol trap blocks and other blocks that shouldn't have post-destruction decorations
set_post_entity_spawn(function(_entity)
	local _spikes = entity_get_items_by(_entity.uid, ENT_TYPE.LOGICAL_JUNGLESPEAR_TRAP_TRIGGER, 0)
	for _, _spike in ipairs(_spikes) do
		kill_entity(_spike)
	end
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP)

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if spawn_flags & SPAWN_TYPE.SCRIPT == 0 then
        -- print("BYE PET")
        return spawn_entity(ENT_TYPE.FX_SHADOW, x, y, l, 0, 0)
    end
    -- print("HI PET")
end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_HAMSTER)

-- Prevent fog at the bottom of the worm
state.level_gen.themes[THEME.EGGPLANT_WORLD]:set_pre_spawn_effects(function(theme)
	state.level_gen.themes[THEME.DWELLING]:spawn_effects()
	return true
end)

return module