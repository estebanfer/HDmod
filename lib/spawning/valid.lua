local module = {}


--[[
	START PROCEDURAL/EXTRA SPAWN DEF
--]]

--[[
	-- Notes:
		-- kays:
			-- "I believe it's a 1/N chance that any possible place for that enemy to spawn, it spawns. so in your example, for level 2 about 1/20 of the possible tiles for that enemy to spawn will actually spawn it"
	
		-- Dr.BaconSlices (regarding the S2 screenshot with all dwelling enemies set to max spawn rates):
			--[[
				"Yup, all it does is roll that chance on any viable tile. There are a couple more quirks, or so I've heard,
				like enemies spawning with more air around them rather than in enclosed areas, whereas treasure is
				more likely to be in cramped places. And of course, it checks for viable tiles instead of any tile,
				so it won't place things inside of floors or other solids, within a liquid it isn't supposed to be in, etc.
				There's also stuff like bats generating along celiengs instead of the ground,
				but I don't think I need to explain that haha"
				"Oh yeah, I forgot to mention that. The priority is determined based on the list,
				which you can see here with 50 million bats but 0 spiders. I'm assuming both of
				their chances are set to 1,1,1,1 but you're still only seeing bats, and that's
				because they're generating in all of the places that spiders are able to."
			--]]
	-- Spawn requirements:
		-- Traps
			-- Notes:
				-- replaces FLOOR_* and FLOORSTYLED_* (so platforms count as spaces)
				-- don't spawn in place of gold/rocks/pots
			-- Arrow Trap:
				-- Notes:
					-- are the only damaging entity to spawn in the entrance 
				-- viable tiles:
					-- if there are two blocks and two spaces, mark the inside block for replacement, unless the trigger hitbox would touch the entrance door
				-- while spawning:
					-- don't spawn if it would result in its back touching another arrow trap
				
			-- Tiki Traps:
				-- Notes:
					-- Spawn after arrow traps
					-- are the only damaging entity to spawn in the entrance 
				-- viable space to place:
					-- Require a block on both sides of the block it's standing on
					-- Require a 3x2 space above the spawn
				-- viable tile to replace:
					-- 
				-- while spawning:
					-- don't spawn if it would result in its sides touching another tiki trap 
						-- HD doesn't check for this
--]]


local valid_floors = {ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOOR_JUNGLE, ENT_TYPE.FLOORSTYLED_MINEWOOD, ENT_TYPE.FLOORSTYLED_STONE, ENT_TYPE.FLOORSTYLED_TEMPLE, ENT_TYPE.FLOORSTYLED_COG, ENT_TYPE.FLOORSTYLED_PAGODA, ENT_TYPE.FLOORSTYLED_BABYLON, ENT_TYPE.FLOORSTYLED_SUNKEN, ENT_TYPE.FLOORSTYLED_BEEHIVE, ENT_TYPE.FLOORSTYLED_VLAD, ENT_TYPE.FLOORSTYLED_MOTHERSHIP, ENT_TYPE.FLOORSTYLED_DUAT, ENT_TYPE.FLOORSTYLED_PALACE, ENT_TYPE.FLOORSTYLED_GUTS, ENT_TYPE.FLOOR_SURFACE, ENT_TYPE.FLOOR_ICE}

local function detect_empty_nodoor(x, y, l)
	-- local entity_uids = get_entities_at(0, MASK.MONSTER | MASK.ITEM | MASK.FLOOR, x, y, l, 0.5)
	local entity_uids = get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, y, l, 0.5)
	local door_not_here = #entity_uids == 0
	return (
		get_grid_entity_at(x, y, l) == -1
		and door_not_here
	)
end

local function detect_shop_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		get_room_template(rx, ry, l) == ROOM_TEMPLATE.SHOP
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.SHOP_LEFT
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.DICESHOP
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.DICESHOP_LEFT
	)
end

local function detect_entrance_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE_DROP
	)
end

local function detect_solid_nonshop_nontree(x, y, l)
    local entity_here = get_grid_entity_at(x, y, l)
	if entity_here ~= -1 then
		local entity_type = get_entity_type(entity_here)
		local entity_flags = get_entity_flags(entity_here)
		return (
			test_flag(entity_flags, ENT_FLAG.SOLID) == true
			and test_flag(entity_flags, ENT_FLAG.SHOP_FLOOR) == false
			and test_flag(entity_flags, ENT_FLAG.SHOP_FLOOR) == false
			and entity_type ~= ENT_TYPE.FLOOR_ALTAR
			and entity_type ~= ENT_TYPE.FLOOR_TREE_BASE
			and entity_type ~= ENT_TYPE.FLOOR_TREE_TRUNK
			and entity_type ~= ENT_TYPE.FLOOR_TREE_TOP
			and entity_type ~= ENT_TYPE.FLOOR_IDOL_BLOCK
		)
	end
	return false
end

local function is_solid_grid_entity(x, y, l)
    return test_flag(get_entity_flags(get_grid_entity_at(x, y, l)), ENT_FLAG.SOLID)
end


local function run_spiderlair_ground_enemy_chance()
	--[[
		if not spiderlair
		or 1/3 chance passes
	]]
	local current_ground_chance = get_procedural_spawn_chance(spawndeflib.global_spawn_procedural_spiderlair_ground_enemy)
	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == false
		or (
			current_ground_chance ~= 0
			and math.random(current_ground_chance) == 1
		)
	) then
		return true
	end
	return false
end

-- Only spawn in a space that has floor above, below, and at least one left or right of it
function module.is_valid_damsel_spawn(x, y, l)
    local entity_uids = get_entities_at({
		ENT_TYPE.FLOOR_GENERIC,
		ENT_TYPE.FLOOR_BORDERTILE,
		ENT_TYPE.FLOORSTYLED_MINEWOOD,
		ENT_TYPE.FLOORSTYLED_STONE,
		ENT_TYPE.ACTIVEFLOOR_POWDERKEG,
		ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
		ENT_TYPE.FLOOR_LADDER,
		ENT_TYPE.FLOOR_LADDER_PLATFORM,
		ENT_TYPE.MONS_PET_DOG,
		ENT_TYPE.MONS_PET_CAT,
		ENT_TYPE.MONS_PET_HAMSTER,
		ENT_TYPE.ITEM_BONES,
		ENT_TYPE.ITEM_POT,
		ENT_TYPE.ITEM_SKULL,
		ENT_TYPE.ITEM_ROCK,
		ENT_TYPE.ITEM_CURSEDPOT,
		ENT_TYPE.ITEM_WEB,
		ENT_TYPE.MONS_SKELETON,

		ENT_TYPE.ITEM_LOCKEDCHEST_KEY,
		ENT_TYPE.ITEM_LOCKEDCHEST,
	}, 0, x, y, l, 0.5)
	local not_entity_here = #entity_uids == 0
    if not_entity_here == true then
		local entity_uid = get_grid_entity_at(x, y - 1, l)
        local entity_below = entity_uid ~= -1 and (
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
			and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)

		local entity_uid = get_grid_entity_at(x, y + 1, l)
        local entity_above = entity_uid ~= -1 and (
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
			and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)
        if entity_below == true and entity_above == true then
			local entity_uid = get_grid_entity_at(x - 1, y, l)
            local entity_left = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
				and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
			)

			entity_uid = get_grid_entity_at(x + 1, y, l)
            local entity_right = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
				and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
			)
            if (
				(entity_left == true or entity_right == true)
				and detect_shop_room_template(x, y, l) == false
			) then
				return true
			end
        end
    end
    return false
end

-- 4 spaces available
function module.is_valid_anubis_spawn(x, y, l)
	local cx, cy = x+.5, y-.5
	local w, h = 2, 2
    local entity_uids = get_entities_overlapping_hitbox(
		0, MASK.FLOOR,
		AABB:new(
			cx-(w/2),
			cy+(h/2),
			cx+(w/2),
			cy-(h/2)
		),
		l
	)
	return (
		#entity_uids == 0
		and detect_entrance_room_template(x, y, l) == false
	)
end

-- in path room
-- space available: 3x4 for jungle, 3x3 for icecaves
function module.is_valid_wormtongue_spawn(x, y, l)
	-- if (
	-- 	roomgenlib.global_levelassembly ~= nil
	-- 	and roomgenlib.global_levelassembly.modification ~= nil
	-- 	and roomgenlib.global_levelassembly.modification.levelrooms ~= nil
	-- ) then

	-- end
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	-- local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
	if roomy < 5 then

		local cx, cy = x, y
		local w, h = 3, state.theme == THEME.JUNGLE and 3 or 4
		local entity_uids = get_entities_overlapping_hitbox(
			0, MASK.FLOOR,
			AABB:new(
				cx-(w/2),
				cy+(h/2),
				cx+(w/2),
				cy-((h/2)+(state.theme == THEME.JUNGLE and 1 or 0))
			),
			l
		)
		return (
			#entity_uids == 0
			and detect_shop_room_template(x, y, l) == false
		)
	end
	return false
end

function module.is_valid_blackmarket_spawn(x, y, l)
	local floor_uid = get_grid_entity_at(x, y, l)
	local floor_uid2 = get_grid_entity_at(x, y-1, l)
	if (
		floor_uid ~= -1
		and floor_uid2 ~= -1
	) then
		local floor_flags = get_entity_flags(floor_uid)
		local floor_type = get_entity_type(floor_uid)

		local floor_flags2 = get_entity_flags(floor_uid2)
		local floor_type2 = get_entity_type(floor_uid2)
		return (
			(
				test_flag(floor_flags, ENT_FLAG.SOLID) == true
				and test_flag(floor_flags, ENT_FLAG.SHOP_FLOOR) == false
				and floor_type ~= ENT_TYPE.FLOOR_BORDERTILE
				and floor_type ~= ENT_TYPE.FLOORSTYLED_MINEWOOD
				and floor_type ~= ENT_TYPE.FLOORSTYLED_STONE
				and floor_type ~= ENT_TYPE.FLOOR_TREE_BASE
				and floor_type ~= ENT_TYPE.FLOOR_TREE_TRUNK
				and floor_type ~= ENT_TYPE.FLOOR_TREE_TOP
				-- and floor_type ~= ENT_TYPE.FLOOR_LADDER
				-- and floor_type ~= ENT_TYPE.FLOOR_LADDER_PLATFORM
			)
			and (
				test_flag(floor_flags2, ENT_FLAG.SOLID) == true
				and test_flag(floor_flags2, ENT_FLAG.SHOP_FLOOR) == false
				and floor_type2 ~= ENT_TYPE.FLOOR_BORDERTILE
				and floor_type2 ~= ENT_TYPE.FLOORSTYLED_MINEWOOD
				and floor_type2 ~= ENT_TYPE.FLOORSTYLED_STONE
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_BASE
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_TRUNK
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_TOP
				-- and floor_type2 ~= ENT_TYPE.FLOOR_LADDER
				-- and floor_type2 ~= ENT_TYPE.FLOOR_LADDER_PLATFORM
			)
		)
	end
	return false
end

function module.is_valid_landmine_spawn(x, y, l) return false end -- # TODO: Implement method for valid landmine spawn

function module.is_valid_bouncetrap_spawn(x, y, l) return false end -- # TODO: Implement method for valid bouncetrap spawn

function module.is_valid_caveman_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid caveman spawn

function module.is_valid_scorpion_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid scorpion spawn

function module.is_valid_cobra_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
	)
end -- # TODO: Implement method for valid cobra spawn

function module.is_valid_snake_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
	)
end -- # TODO: Implement method for valid snake spawn

function module.is_valid_mantrap_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
	)
end -- # TODO: Implement method for valid mantrap spawn

function module.is_valid_tikiman_spawn(x, y, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid tikiman spawn

function module.is_valid_snail_spawn(x, y, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid snail spawn

function module.is_valid_firefrog_spawn(x, y, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid firefrog spawn

function module.is_valid_frog_spawn(x, y, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid frog spawn

function module.is_valid_yeti_spawn(x, y, l) return false end -- # TODO: Implement method for valid yeti spawn

function module.is_valid_hawkman_spawn(x, y, l) return false end -- # TODO: Implement method for valid hawkman spawn

function module.is_valid_crocman_spawn(x, y, l) return false end -- # TODO: Implement method for valid crocman spawn

function module.is_valid_scorpionfly_spawn(x, y, l) return false end -- # TODO: Implement method for valid scorpionfly spawn

function module.is_valid_critter_rat_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid critter_rat spawn

function module.is_valid_critter_frog_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_frog spawn

function module.is_valid_critter_maggot_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_maggot spawn

function module.is_valid_critter_penguin_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_penguin spawn

function module.is_valid_critter_locust_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_locust spawn

function module.is_valid_jiangshi_spawn(x, y, l) return false end -- # TODO: Implement method for valid jiangshi spawn

function module.is_valid_devil_spawn(x, y, l) return false end -- # TODO: Implement method for valid devil spawn

function module.is_valid_greenknight_spawn(x, y, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid greenknight spawn

function module.is_valid_alientank_spawn(x, y, l) return false end -- # TODO: Implement method for valid alientank spawn

function module.is_valid_critter_fish_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_fish spawn

function module.is_valid_piranha_spawn(x, y, l) return false end -- # TODO: Implement method for valid piranha spawn

function module.is_valid_monkey_spawn(x, y, l)
	local floor = get_grid_entity_at(x, y, l)
	if floor ~= -1 then
		return commonlib.has({ENT_TYPE.FLOOR_VINE}, get_entity_type(floor))
	end
	return false
end

function module.is_valid_hangspider_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	local floor_three_below = get_grid_entity_at(x, y-3, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y+1, l) ~= -1
		and get_grid_entity_at(x, y-1, l) == -1
		and floor_two_below == -1
		and floor_three_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid hangspider spawn

function module.is_valid_bat_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y+1, l) ~= -1
		and get_grid_entity_at(x, y-1, l) == -1
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid bat spawn

function module.is_valid_spider_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y+1, l) ~= -1
		and get_grid_entity_at(x, y-1, l) == -1
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid spider spawn

function module.is_valid_vampire_spawn(x, y, l) return false end -- # TODO: Implement method for valid vampire spawn

function module.is_valid_imp_spawn(x, y, l) return false end -- # TODO: Implement method for valid imp spawn

function module.is_valid_scarab_spawn(x, y, l) return false end -- # TODO: Implement method for valid scarab spawn

function module.is_valid_mshiplight_spawn(x, y, l) return false end -- # TODO: Implement method for valid mshiplight spawn

function module.is_valid_lantern_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y+1, l) ~= -1
		and get_grid_entity_at(x, y-1, l) == -1
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid lantern spawn

function module.is_valid_turret_spawn(x, y, l)
	if (
		get_grid_entity_at(x, y, l) == -1
		and is_solid_grid_entity(x, y+1, l)
		and get_entity_type(get_grid_entity_at(x, y+1, l)) == ENT_TYPE.FLOORSTYLED_MOTHERSHIP
		and get_grid_entity_at(x, y-1, l) == -1
	) then
		return true
    end
    return false
end -- # TODO: Implement method for valid turret spawn

function module.is_valid_webnest_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y+1, l) ~= -1
		and get_grid_entity_at(x, y-1, l) == -1
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid webnest spawn

function module.is_valid_pushblock_spawn(x, y, l)
	-- Replaces floor with spawn where it has floor underneath
    local above = get_grid_entity_at(x, y+1, l)
	if above ~= -1 then
		if get_entity_type(above) == ENT_TYPE.FLOOR_ALTAR then
			return false
		end
	end
    return (
		detect_solid_nonshop_nontree(x, y, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
	)
end

function module.is_valid_spikeball_spawn(x, y, l)
	local above = get_grid_entity_at(x, y+1, l)
	if above ~= -1 then
		if get_entity_type(above) == ENT_TYPE.FLOOR_ALTAR then
			return false
		end
	end
    return (
		detect_solid_nonshop_nontree(x, y, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
	)
end -- # TODO: Implement method for valid spikeball spawn

function module.is_valid_arrowtrap_spawn(x, y, l)
	local rx, ry = get_room_index(x, y)
    if y == state.level_gen.spawn_y and (rx >= state.level_gen.spawn_room_x-1 and rx <= state.level_gen.spawn_room_x+1) then return false end
    local floor = get_grid_entity_at(x, y, l)
    local left = get_grid_entity_at(x-1, y, l)
    local left2 = get_grid_entity_at(x-2, y, l)
    local right = get_grid_entity_at(x+1, y, l)
    local right2 = get_grid_entity_at(x+2, y, l)
    if floor ~= -1 and (
		(left == -1 and left2 == -1 and right ~= -1)
		or (left ~= -1 and right == -1 and right2 == -1)
	) then
        return commonlib.has(valid_floors, get_entity_type(floor))
    end
    return false
end -- # TODO: Implement method for valid arrowtrap spawn

function module.is_valid_tikitrap_spawn(x, y, l)
	--[[
		-- # TODO: Implement method for valid tikitrap spawn
		-- Does it have a block underneith?
		-- Does it have at least 3 spaces across unoccupied above it?
		-- Does it have at least one tile unoccupied next to it? (not counting tiki trap tiles)
		-- Is the top tiki part placed over an unoccupied space?
	]]
	return false
end

function module.is_valid_crushtrap_spawn(x, y, l)
	--[[
		-- # TODO: Implement method for valid crushtrap spawn
		-- Replace air
		-- Needs at least one block open on one side of it
		-- Needs at least one block occupide on one side of it
	]]
	return false
end

function module.is_valid_tombstone_spawn(x, y, l)
	-- need subchunkid of what room we're in
	-- # TOFIX: Prevent tombstones from spawning in RESTLESS_TOMB.
	--[[ the following code returns as nil, though it should be showing up at this point...
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
	--]]
    return (
		-- _subchunk_id ~= genlib.HD_SUBCHUNKID.RESTLESS_TOMB and
		detect_empty_nodoor(x, y, l)
		and detect_empty_nodoor(x, y+1, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
	)
end

function module.is_valid_giantfrog_spawn(x, y, l) return false end -- # TODO: Implement method for valid giantfrog spawn

function module.is_valid_mammoth_spawn(x, y, l)
	local cx, cy = x-1.5, y+1.5
	local w, h = 4, 2
    local entity_uids = get_entities_overlapping_hitbox(
		0, MASK.FLOOR,
		AABB:new(
			cx-(w/2),
			cy+(h/2),
			cx+(w/2),
			cy-(h/2)
		),
		l
	)
	return (
		#entity_uids == 0
		and get_grid_entity_at(x, y, l) == -1
		and get_grid_entity_at(x, y-1, l) ~= -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid mammoth spawn

function module.is_valid_giantspider_spawn(x, y, l)
	local floor_above_right = get_grid_entity_at(x+1, y+1, l)
	local cx, cy = x+.5, y-.5
	local w, h = 2, 2
	local entity_uids = get_entities_overlapping_hitbox(
		0, MASK.FLOOR,
		AABB:new(
			cx-(w/2),
			cy+(h/2),
			cx+(w/2),
			cy-(h/2)
		),
		l
	)
	return (
		#entity_uids == 0
		and get_grid_entity_at(x, y+1, l) ~= -1
		and floor_above_right ~= -1
		and createlib.GIANTSPIDER_SPAWNED == false
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid giantspider spawn

function module.is_valid_bee_spawn(x, y, l) return false end -- # TODO: Implement method for valid bee spawn

function module.is_valid_ufo_spawn(x, y, l) return false end -- # TODO: Implement method for valid ufo spawn

function module.is_valid_bacterium_spawn(x, y, l) return false end -- # TODO: Implement method for valid bacterium spawn

function module.is_valid_eggsac_spawn(x, y, l) return false end -- # TODO: Implement method for valid eggsac spawn

return module