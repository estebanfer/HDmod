local module = {}


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

function module.onlevel_decorate_trees()
	if (
		(state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE) and
		options.hd_og_tree_spawn == false
	) then
		-- remove tree vines
		local treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_BRANCH)
		for _, treebranch in ipairs(treeParts) do
			if entity_has_item_type(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP) then
				local treeVineTop = entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP, 0)[1]
				local _x, _y, _l = get_position(treeVineTop)
				
				-- don't kill it if it's the top
				if (
					#get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, _x-1, _y-1, _l, 1) == 0 and
					#get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, _x+1, _y-1, _l, 1) == 0
				) then
					kill_entity(treeVineTop)
				end
				
				kill_entity(get_entities_at(ENT_TYPE.FLOOR_VINE, 0, _x, _y-2, _l, 1)[1])
				kill_entity(entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE, 0)[1])
			end
		end
		treeParts = get_entities_by_type(ENT_TYPE.FLOOR_VINE_TREE_TOP)
		for _, treeVineTop in ipairs(treeParts) do
			kill_entity(treeVineTop)
		end
		-- add branches to tops of trees, add leaf decorations
		treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_TOP)
		for _, treetop in ipairs(treeParts) do
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
	end
end

return module