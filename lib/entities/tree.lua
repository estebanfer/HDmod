local validlib = require('lib.spawning.valid')

local module = {}

local ANIMATION_FRAMES_ENUM = {
    FACE = 1,
    BLOCK_DECO = 2,
	TREETOP_CENTER = 3,
	TREETOP_BRANCH = 4
}

local ANIMATION_FRAMES_RES = {
    { 0 },
    { 1, 2, 3 },
    { 0 },
    { 1 },
}

local top_texture_id
local restless_texture_id
do
	local top_texture_def = TextureDefinition.new()
	top_texture_def.width = 256
	top_texture_def.height = 128
	top_texture_def.tile_width = 128
	top_texture_def.tile_height = 128
	top_texture_def.texture_path = "res/treetop.png"
	top_texture_id = define_texture(top_texture_def)

	local restless_texture_def = TextureDefinition.new()
	restless_texture_def.width = 512
	restless_texture_def.height = 128
	restless_texture_def.tile_width = 128
	restless_texture_def.tile_height = 128
	restless_texture_def.texture_path = "res/restless_deco.png"
	restless_texture_id = define_texture(restless_texture_def)
end

-- HD-style tree decorating methods
local function decorate_tree(e_type, p_uid, side, y_offset, radius, right)
	if p_uid == 0 then return 0 end
	local p_x, p_y, p_l = get_position(p_uid)
	local branches = get_entities_at(e_type, 0, p_x+side, p_y, p_l, radius)
	local branch_uid = 0
	if #branches == 0 then
		branch_uid = spawn_entity_over(e_type, p_uid, side, y_offset)
		if e_type == ENT_TYPE.DECORATION_TREE then
			local branch_e = get_entity(branch_uid)
			branch_e.animation_frame = 87+12*prng:random_index(2, PRNG_CLASS.LEVEL_GEN)
		end
	else
		branch_uid = branches[1]
	end
	-- apply top branch texture
	local branch_e = get_entity(branch_uid)
	if e_type == ENT_TYPE.DECORATION_TREE_VINE_TOP then
		branch_e:set_texture(top_texture_id)
		branch_e.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.TREETOP_BRANCH][1]
	end
	-- flip if you just created it and it's a 0x100 and it's on the left or if it's 0x200 and on the right.
	if branch_e ~= nil then
		-- flipped = test_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		if (#branches == 0 and branch_e.type.search_flags == 0x100 and side == -1) then -- to flip branches
			flip_entity(branch_uid)
		elseif (branch_e.type.search_flags == 0x200 and right == false) then -- to flip decorations
			branch_e.flags = set_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		end
	end
	return branch_uid
end

local function add_top_branches(treetop_uid)
	local branch_uid_left = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop_uid, -1, 0, 0.1, false)
	local branch_uid_right = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop_uid, 1, 0, 0.1, false)
	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false
	) then
		decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
		decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
	else
		decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_left, 0.03, 0.47, 0.5, false)
		decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_right, -0.03, 0.47, 0.5, true)
	end
	for _, deco_uid in pairs(entity_get_items_by(treetop_uid, ENT_TYPE.DECORATION_TREETRUNK_TOPFRONT, MASK.DECORATION)) do
		local deco = get_entity(deco_uid)
		deco:set_texture(top_texture_id)
		deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.TREETOP_CENTER][1]
	end
end

local vine_top_positions = {}
-- Since once the VINE_TREE_TOP spawns over a branch, it can't be fixed, we have to prevent it from spawning. Another way would be to just spawn another branch
set_pre_entity_spawn(function (entity_type, x, y, layer, overlay_entity, spawn_flags)
	if spawn_flags & SPAWN_TYPE.SCRIPT ~= 0 then return end
	-- messpect("Removed tree vine at:", x, y)
	local uid_at = get_grid_entity_at(x, y, layer)
	vine_top_positions[#vine_top_positions+1] = {x, y}
	if uid_at ~= -1 then
		return uid_at
	end
end, SPAWN_TYPE.LEVEL_GEN_GENERAL, MASK.FLOOR, ENT_TYPE.FLOOR_VINE_TREE_TOP)

function module.postlevelgen_decorate_trees()
	if (
		state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE
	) then
		-- remove tree vines
		for _, pos in pairs(vine_top_positions) do
			local x, top_y = pos[1], pos[2]
			local floor_at_uid = get_grid_entity_at(x, top_y, LAYER.FRONT)
			if get_entity_type(floor_at_uid) == ENT_TYPE.FLOOR_VINE_TREE_TOP then
				get_entity(floor_at_uid):destroy()
			end

			-- Update branch decorations
			local is_top = (
				get_entity_type(get_grid_entity_at(x-1, top_y-1, LAYER.FRONT)) == ENT_TYPE.FLOOR_TREE_TOP
				or get_entity_type(get_grid_entity_at(x+1, top_y-1, LAYER.FRONT)) == ENT_TYPE.FLOOR_TREE_TOP
			)
			local haunted = (
				feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == true
				or feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == true
			)
			local branch_uid = get_grid_entity_at(x, top_y-1, LAYER.FRONT)
			local deco = get_entity(entity_get_items_by(branch_uid, ENT_TYPE.DECORATION_TREE_VINE_TOP, 0)[1])
			-- decorate normal branches
			if
				not is_top
				and haunted
			then
				deco:destroy()
				decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid, 0.03, 0.47, 0.5, false)
			end
			-- apply top branch texture
			if
				is_top
				and not haunted
			then
				prinspect(deco.uid)
				deco:set_texture(top_texture_id)
				deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.TREETOP_BRANCH][1]
			end

			local y = top_y
			repeat
				y = y - 1
				local branch_vine_uid = get_grid_entity_at(x, y, LAYER.FRONT)
				if entity_has_item_type(branch_vine_uid, ENT_TYPE.DECORATION_TREE_VINE) then
					local vine_decor_uid = entity_get_items_by(branch_vine_uid, ENT_TYPE.DECORATION_TREE_VINE, MASK.DECORATION)[1]
					get_entity(vine_decor_uid):destroy()
					set_entity_flags(branch_vine_uid, clr_flag(get_entity_flags(branch_vine_uid), ENT_FLAG.CLIMBABLE))
				elseif get_entity_type(branch_vine_uid) == ENT_TYPE.FLOOR_VINE then
					get_entity(branch_vine_uid):destroy()
				end
			until get_entity_type(branch_vine_uid) ~= ENT_TYPE.FLOOR_TREE_BRANCH and get_entity_type(branch_vine_uid) ~= ENT_TYPE.FLOOR_VINE
		end
	end
	vine_top_positions = {}
end

function module.create_hd_tree(x, y, l)
	-- create base
	local cur_trunk = spawn_grid_entity(ENT_TYPE.FLOOR_TREE_BASE, x, y, l)

	local max_height = 6
	-- if 1/3 chance passes, set maximum to 5
	if prng:random_chance(3, PRNG_CLASS.LEVEL_GEN) then max_height = 5 end

	for i = 3, max_height, 1 do
		-- if any of the 3 blocks above i are occupied, spawn 2 branches and break
		local topleft2 = get_grid_entity_at(x-1, y+i, l)
		local topmid2 = get_grid_entity_at(x, y+i, l)
		local topright2 = get_grid_entity_at(x+1, y+i, l)
		if (
			(topleft2 ~= -1 or topmid2 ~= -1 or topright2 ~= -1)
			or i == max_height
		) then
			add_top_branches(spawn_entity_over(ENT_TYPE.FLOOR_TREE_TOP, cur_trunk, 0, 1))
			break
		end
		-- spawn trunk at i
		cur_trunk = spawn_entity_over(ENT_TYPE.FLOOR_TREE_TRUNK, cur_trunk, 0, 1)
		-- if if 1/3 chance passes, spawn branch on left side
		if prng:random_chance(3, PRNG_CLASS.LEVEL_GEN) then
			decorate_tree(ENT_TYPE.DECORATION_TREE, decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, cur_trunk, -1, 0, 0.1, false), 0.03, 0.47, 0.5, false)
		end
		-- if if 1/3 chance passes, spawn branch on right side
		if prng:random_chance(3, PRNG_CLASS.LEVEL_GEN) then
			decorate_tree(ENT_TYPE.DECORATION_TREE, decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, cur_trunk, 1, 0, 0.1, false), -0.03, 0.47, 0.5, true)
		end
	end
end

function module.onlevel_decorate_haunted()
	-- decorate tree trunks
	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE)
		or feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS)
	) then
		for _, uid in pairs(get_entities_by_type(ENT_TYPE.DECORATION_TREE)) do
			local deco = get_entity(uid)
			if (
				(-- ignore branch decorations
					deco.animation_frame == 112
					or deco.animation_frame == 124
					or deco.animation_frame == 136
				) and prng:random_chance(12, PRNG_CLASS.LEVEL_GEN)
			) then
				deco:set_texture(restless_texture_id)
				deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.FACE][1]
			end
		end
	end
	
	-- decorate grass
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
		for _, uid in pairs(get_entities_by_type(ENT_TYPE.DECORATION_JUNGLEBUSH)) do
			local x, y, _ = get_position(uid)
			if (
				not validlib.is_invalid_dar_decor_spawn(x, y)
				and prng:random_chance(2, PRNG_CLASS.LEVEL_GEN)
			) then
				local deco = get_entity(uid)
				deco:set_texture(restless_texture_id)
				if deco.animation_frame == 53 then
					deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.BLOCK_DECO][1]
				elseif deco.animation_frame == 54 then
					deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.BLOCK_DECO][2]
				elseif deco.animation_frame == 55 then
					deco.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.BLOCK_DECO][3]
				end
			end
		end
	end
end

return module