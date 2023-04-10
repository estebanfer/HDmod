local module = {}

optionslib.register_option_bool("hd_og_tree_spawn", "OG: Tree spawns - Spawn trees in S2 style instead of HD", nil, false) -- Defaults to HD

local hauntedface_texture_def
local hauntedgrass_texture_def
do
	hauntedface_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_0)
	hauntedface_texture_def.texture_path = "res/restless_jungle.png"
	hauntedface_texture_def = define_texture(hauntedface_texture_def)

	hauntedgrass_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_0)
	hauntedgrass_texture_def.texture_path = "res/restless_jungle.png"
	hauntedgrass_texture_def = define_texture(hauntedgrass_texture_def)
end

-- # TODO: Revise into HD_TILENAME["T"] and improve.
-- Use the following methods for a starting point:

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
			branch_e.animation_frame = 87+12*math.random(2)
		end
	else
		branch_uid = branches[1]
	end
	-- flip if you just created it and it's a 0x100 and it's on the left or if it's 0x200 and on the right.
	local branch_e = get_entity(branch_uid)
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


local function add_top_branches(treetop)
	local branch_uid_left = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, -1, 0, 0.1, false)
	local branch_uid_right = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, 1, 0, 0.1, false)
	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false
	) then
		decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
		decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
	else
		decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_left, 0.03, 0.47, 0.5, false)
		decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_right, -0.03, 0.47, 0.5, true)
		-- # TODO: chance of grabbing the FLOOR_TREE_TRUNK below `treetop` and applying DECORATION_TREE with a reskin of a haunted face
	end
end



local function fix_branch(branch_uid)
	-- prinspect(branch_uid)
	local b_x, b_y, b_l = get_position(branch_uid)
	local tree_trunk = get_grid_entity_at(b_x-1, b_y, b_l)
	if tree_trunk == -1 then
		tree_trunk = get_grid_entity_at(b_x+1, b_y, b_l)
	end
	if tree_trunk ~= -1 then
		tree_trunk = get_entity(tree_trunk)
		if (
			tree_trunk.type.id == ENT_TYPE.FLOOR_TREE_TOP
			or tree_trunk.type.id == ENT_TYPE.FLOOR_TREE_TRUNK
		) then
			prinspect(tree_trunk.uid)
		end
	end
end

function module.onlevel_decorate_trees()
	if (
		(state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE) and
		options.hd_og_tree_spawn == false
	) then
		-- remove tree vines
		local treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_BRANCH)
		for _, treebranch in ipairs(treeParts) do
			if entity_has_item_type(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP) then
				-- local leaf_decor = entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP, 0)[1]
				-- -- prinspect(leaf_decor)
				-- local b_x, b_y, b_l = get_position(leaf_decor)

				-- local branches = get_entities_at(ENT_TYPE.FLOOR_TREE_BRANCH, 0, b_x, b_y+1, b_l, 1)
				-- local branch_above = -1
				-- if #branches ~= 0 then
				-- 	branch_above = branches[1]
				-- end

				-- local b_x, b_y, b_l = get_position(treebranch)
				-- local branch_above = get_entities_at(ENT_TYPE.FLOOR_TREE_BRANCH, 0, b_x, b_y+1, b_l, 1)
				-- local tmp_branch = -1
				-- if branch_above ~= -1 then
				-- 	branch_above = get_entity(branch_above)
				-- 	if (
				-- 		branch_above.type.id == ENT_TYPE.FLOOR_VINE_TREE_TOP
				-- 	) then
				-- 		kill_entity(branch_above.uid)
				-- 		tmp_branch = get_grid_entity_at(b_x, b_y+1, b_l)
				-- 		if tmp_branch ~= -1 then
				-- 			branch_above = tmp_branch
				-- 		end
				-- 	end
				-- 	if (
				-- 		branch_above.type.id == ENT_TYPE.FLOOR_TREE_BRANCH
				-- 	) then
				-- 		-- prinspect(branch_above.uid)
				-- 		fix_branch(branch_above.uid)
				-- 	end
				-- end

				-- local is_right = false
				-- local is_top = true
				-- local treeTop = -1
				
				-- local treeTops = get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, b_x+1, b_y+1, b_l, 1)
				-- if #treeTops ~= 0 then
				-- 	treeTop = treeTops[1]
				-- 	is_right = true
				-- end
				-- treeTops = get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, b_x-1, b_y+1, b_l, 1)
				-- if #treeTops ~= 0 then
				-- 	treeTop = treeTops[1]
				-- end
				-- if treeTop == -1 then
				-- 	is_top = false
				-- end


				if (
					branch_above ~= -1
					-- is_top == false
					-- #get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, b_x-1, b_y-1, b_l, 1) == 0
					-- and #get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, b_x+1, b_y-1, b_l, 1) == 0
				) then
					-- fix_branch(branch_above)

					-- kill_entity(leaf_decor)
					-- local vine_artifacts = get_entities_at(ENT_TYPE.FLOOR_VINE_TREE_TOP, 0, b_x, b_y+1, b_l, 1)
					-- if #vine_artifacts ~= 0 then
					-- 	kill_entity(vine_artifacts[1])
					-- end
					-- vine_artifacts = get_entities_at(ENT_TYPE.DECORATION_TREE_VINE, 0, b_x, b_y, b_l, 1)
					-- if #vine_artifacts ~= 0 then
					-- 	kill_entity(vine_artifacts[1])
					-- end
					-- vine_artifacts = get_entities_at(ENT_TYPE.FLOOR_VINE, 0, b_x, b_y-2, b_l, 1)
					-- if #vine_artifacts ~= 0 then
					-- 	kill_entity(vine_artifacts[1])
					-- end


				end
				-- kill_entity(get_entities_at(ENT_TYPE.FLOOR_VINE, 0, b_x, b_y-2, b_l, 1)[1])
				-- kill_entity(entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE, 0)[1])
			end
		end
		-- treeParts = get_entities_by_type(ENT_TYPE.FLOOR_VINE_TREE_TOP)
		-- for _, leaf_decor in ipairs(treeParts) do
		-- 	kill_entity(leaf_decor)
		-- end


		-- find the decoration below it
		-- get the grid entity below it, add decoration to it. if it's 

		-- -- add branches to tops of trees, add leaf decorations
		-- treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_TOP)
		-- for _, treetop in ipairs(treeParts) do
		-- 	add_top_branches(treetop)
		-- end
	end
end

function module.create_hd_tree(x, y, l)
	-- create base
	local cur_trunk = spawn_grid_entity(ENT_TYPE.FLOOR_TREE_BASE, x, y, l)

	local max_height = 6
	-- if 1/3 chance passes, set maximum to 5
	if math.random(3) == 1 then max_height = 5 end

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
		if math.random(3) == 1 then
			decorate_tree(ENT_TYPE.DECORATION_TREE, decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, cur_trunk, -1, 0, 0.1, false), 0.03, 0.47, 0.5, false)
		end
		-- if if 1/3 chance passes, spawn branch on right side
		if math.random(3) == 1 then
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
		for _, decor in ipairs(get_entities_by_type(ENT_TYPE.DECORATION_TREE)) do
			local decor_ent = get_entity(decor)
			if (
				(-- ignore branch decorations
					decor_ent.animation_frame == 112
					or decor_ent.animation_frame == 124
					or decor_ent.animation_frame == 136
				) and math.random(15) == 1
			) then
				get_entity(decor):set_texture(hauntedface_texture_def)
				get_entity(decor).animation_frame = 124
			end
		end
	end
	
	-- decorate grass
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
		for _, decor in ipairs(get_entities_by_type(ENT_TYPE.DECORATION_JUNGLEBUSH)) do
			if (math.random(2) == 1) then
				get_entity(decor):set_texture(hauntedgrass_texture_def)
			end
		end
	end
end

return module