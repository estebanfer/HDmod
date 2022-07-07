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

local function check_empty_space(origin_x, origin_y, layer, width, height)
	for y = origin_y, origin_y+1-height, -1 do
		for x = origin_x, origin_x+width-1 do
			if get_grid_entity_at(x, y, layer) ~= -1 then
				return false
			end
		end
	end
	return true
end

local function detect_empty_nodoor(x, y, l)
	-- local entity_uids = get_entities_at(0, MASK.MONSTER | MASK.ITEM | MASK.FLOOR, x, y, l, 0.5)
	local entity_uids = get_entities_at(ENT_TYPE.FLOOR_DOOR_EXIT, 0, x, y, l, 0.5)
	local door_not_here = #entity_uids == 0
	return (
		get_grid_entity_at(x, y, l) == -1
		and door_not_here
	)
end

local shop_templates = {
	ROOM_TEMPLATE.SHOP,
	ROOM_TEMPLATE.SHOP_LEFT,
	ROOM_TEMPLATE.DICESHOP,
	ROOM_TEMPLATE.DICESHOP_LEFT
}
local function detect_shop_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		commonlib.has(shop_templates, get_room_template(rx, ry, l))
	)
end

local function detect_entrance_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE_DROP
	)
end

local nonshop_nontree_solids = {
	ENT_TYPE.FLOOR_ALTAR,
	ENT_TYPE.FLOOR_TREE_BASE,
	ENT_TYPE.FLOOR_TREE_TRUNK,
	ENT_TYPE.FLOOR_TREE_TOP,
	ENT_TYPE.FLOOR_IDOL_BLOCK
}
local function detect_solid_nonshop_nontree(x, y, l)
    local entity_here = get_grid_entity_at(x, y, l)
	if entity_here ~= -1 then
		local entity_type = get_entity_type(entity_here)
		local entity_flags = get_entity_flags(entity_here)
		return (
			test_flag(entity_flags, ENT_FLAG.SOLID) == true
			and test_flag(entity_flags, ENT_FLAG.SHOP_FLOOR) == false
			and not commonlib.has(nonshop_nontree_solids, entity_type)
		)
	end
	return false
end

local function is_solid_grid_entity(x, y, l)
    return test_flag(get_entity_flags(get_grid_entity_at(x, y, l)), ENT_FLAG.SOLID)
end

local function is_valid_monster_floor(x, y, l)
	local flags = get_entity_flags(get_grid_entity_at(x, y, l))
    return test_flag(flags, ENT_FLAG.SOLID) or test_flag(flags, ENT_FLAG.IS_PLATFORM)
end

local function default_ground_monster_condition(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
	and is_valid_monster_floor(x, y-1, l)
	and detect_entrance_room_template(x, y, l) == false
end

local function default_ceiling_entity_condition(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
	and is_solid_grid_entity(x, y+1, l)
	and get_grid_entity_at(x, y-1, l) == -1
	and get_grid_entity_at(x, y-2, l) == -1
	and detect_entrance_room_template(x, y, l) == false
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

local function spiderlair_ground_monster_condition(x, y, l)
	return run_spiderlair_ground_enemy_chance()
		and default_ground_monster_condition(x, y, l)
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
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)

		local entity_uid = get_grid_entity_at(x, y + 1, l)
        local entity_above = entity_uid ~= -1 and (
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)
        if entity_below == true and entity_above == true then
			local entity_uid = get_grid_entity_at(x - 1, y, l)
            local entity_left = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
			)

			entity_uid = get_grid_entity_at(x + 1, y, l)
            local entity_right = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
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

local blackmarket_invalid_floors = {
	ENT_TYPE.FLOORSTYLED_MINEWOOD,
	ENT_TYPE.FLOOR_BORDERTILE,
	ENT_TYPE.FLOORSTYLED_STONE,
	ENT_TYPE.FLOOR_TREE_BASE,
	ENT_TYPE.FLOOR_TREE_TRUNK,
	ENT_TYPE.FLOOR_TREE_TOP
}
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
				and not commonlib.has(blackmarket_invalid_floors, floor_type)
			)
			and (
				test_flag(floor_flags2, ENT_FLAG.SOLID) == true
				and test_flag(floor_flags2, ENT_FLAG.SHOP_FLOOR) == false
				and not commonlib.has(blackmarket_invalid_floors, floor_type2)
			)
		)
	end
	return false
end

function module.is_valid_landmine_spawn(x, y, l) return false end -- # TODO: Implement method for valid landmine spawn

function module.is_valid_bouncetrap_spawn(x, y, l) return false end -- # TODO: Implement method for valid bouncetrap spawn

module.is_valid_caveman_spawn = spiderlair_ground_monster_condition
module.is_valid_scorpion_spawn = spiderlair_ground_monster_condition
module.is_valid_cobra_spawn = spiderlair_ground_monster_condition
module.is_valid_snake_spawn = spiderlair_ground_monster_condition

module.is_valid_mantrap_spawn = default_ground_monster_condition
module.is_valid_tikiman_spawn = default_ground_monster_condition
module.is_valid_snail_spawn = default_ground_monster_condition
module.is_valid_firefrog_spawn = default_ground_monster_condition
module.is_valid_frog_spawn = default_ground_monster_condition

function module.is_valid_yeti_spawn(x, y, l) return false end -- # TODO: Implement method for valid yeti spawn

function module.is_valid_hawkman_spawn(x, y, l) return false end -- # TODO: Implement method for valid hawkman spawn

function module.is_valid_crocman_spawn(x, y, l) return false end -- # TODO: Implement method for valid crocman spawn

function module.is_valid_scorpionfly_spawn(x, y, l) return false end -- # TODO: Implement method for valid scorpionfly spawn

module.is_valid_critter_rat_spawn = spiderlair_ground_monster_condition -- # TODO: Implement method for valid critter_rat spawn

function module.is_valid_critter_frog_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_frog spawn

function module.is_valid_critter_maggot_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_maggot spawn

function module.is_valid_critter_penguin_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_penguin spawn

function module.is_valid_critter_locust_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_locust spawn

module.is_valid_jiangshi_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid jiangshi spawn

function module.is_valid_devil_spawn(x, y, l) return false end -- # TODO: Implement method for valid devil spawn

module.is_valid_greenknight_spawn = default_ground_monster_condition -- # TODO: Implement method for valid greenknight spawn

function module.is_valid_alientank_spawn(x, y, l) return false end -- # TODO: Implement method for valid alientank spawn

function module.is_valid_critter_fish_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_fish spawn

local function is_water_at(x, y)
	local lvlcode = locatelib.get_levelcode_at_gpos(x, y)
	return lvlcode == "w" or
		(lvlcode == "3" and get_grid_entity_at(x, y, LAYER.FRONT) == -1)
end

function module.is_valid_piranha_spawn(x, y, l)
	local _, room_y = locatelib.locate_levelrooms_position_from_game_position(x, y)
	return (is_water_at(x, y) and is_water_at(x, y+1))
		or (
			feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			and room_y == 5
			and get_grid_entity_at(x, y, l) == -1
		)
end -- # TODO: Implement method for valid piranha spawn

function module.is_valid_monkey_spawn(x, y, l)
	local floor = get_grid_entity_at(x, y, l)
	if floor ~= -1 then
		return commonlib.has({ENT_TYPE.FLOOR_VINE}, get_entity_type(floor))
	end
	return false
end

function module.is_valid_hangspider_spawn(x, y, l)
	return (
		default_ceiling_entity_condition(x, y, l)
		and get_grid_entity_at(x, y-3, l) == -1
	)
end -- # TODO: Implement method for valid hangspider spawn

module.is_valid_bat_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid bat spawn

module.is_valid_spider_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid spider spawn

module.is_valid_vampire_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid vampire spawn

function module.is_valid_imp_spawn(x, y, l) return false end -- # TODO: Implement method for valid imp spawn

function module.is_valid_scarab_spawn(x, y, l) return false end -- # TODO: Implement method for valid scarab spawn

function module.is_valid_mshiplight_spawn(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
		and is_solid_grid_entity(x, y+1, l)
end -- # TODO: Implement method for valid mshiplight spawn

module.is_valid_lantern_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid lantern spawn

module.is_valid_webnest_spawn = default_ceiling_entity_condition -- # TODO: Implement method for valid webnest spawn

function module.is_valid_turret_spawn(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
		and get_entity_type(get_grid_entity_at(x, y+1, l)) == ENT_TYPE.FLOORSTYLED_MOTHERSHIP
		and check_empty_space(x-1, y, l, 3, 3)
end -- # TODO: Implement method for valid turret spawn

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
	-- need subchunkid of what room we're in
	local _subchunk_id = locatelib.get_levelroom_at_game_position(x, y)
	if (
		_subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_TOP
		or _subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_MIDSECTION
		or _subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_BOTTOM
	) then
		return false
	end

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
	-- need subchunkid of what room we're in
	-- # TOFIX: Prevent tikitraps from spawning in castle rooms.
	--[[ the following code returns as nil, though it should be showing up at this point...
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
	--]]
	-- need subchunkid of what room we're in
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	--prevent spawing in lake
	if roomy > 4 then return false end

	local _subchunk_id = locatelib.get_levelroom_at(roomx, roomy)
	if (
		_subchunk_id ~= roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_MOAT
		and (
			_subchunk_id >= 200
			and _subchunk_id <= 213
		)
	) then
		return false
	end

	if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then return false end

	if get_entity_type(get_grid_entity_at(x, y, l)) == ENT_TYPE.FLOOR_ALTAR
		or is_water_at(x, y) then
		return false
	end

	if (
		detect_empty_nodoor(x, y, l) == false
		-- or detect_empty_nodoor(x, y, l) == false
	) then return false end

	-- Does it have 3 spaces across unoccupied above it?
	local topleft2 = get_grid_entity_at(x-1, y+2, l)
	local topmid2 = get_grid_entity_at(x, y+2, l)
	local topright2 = get_grid_entity_at(x+1, y+2, l)
	if (topleft2 ~= -1 or topmid2 ~= -1 or topright2 ~= -1) then
		return false
	end

	-- Does it have at least one tile unoccupied next to it? (not counting tiki trap tiles)
	local topleft = get_grid_entity_at(x-1, y+1, l)
	local topright = get_grid_entity_at(x+1, y+1, l)
	local left = get_grid_entity_at(x-1, y, l)
	local right = get_grid_entity_at(x+1, y, l)
	local num_of_blocks = 0

	if (
		topleft ~= -1
		and commonlib.has(valid_floors, get_entity_type(topleft))
	) then
		num_of_blocks = num_of_blocks + 1
	end
	if (
		topright ~= -1
		and commonlib.has(valid_floors, get_entity_type(topright))
	) then
		num_of_blocks = num_of_blocks + 1
	end
	if (
		left ~= -1
		and commonlib.has(valid_floors, get_entity_type(left))
	) then
		num_of_blocks = num_of_blocks + 1
	end
	if (
		right ~= -1
		and commonlib.has(valid_floors, get_entity_type(right))
	) then
		num_of_blocks = num_of_blocks + 1
	end

	if num_of_blocks == 4 then return false end

	-- Is the top tiki part placed over an unoccupied space?
	local topmid = get_grid_entity_at(x, y+1, l)
	if topmid ~= -1 then return false end

	-- Does it have a block underneith?
	local bottom = get_grid_entity_at(x, y-1, l)
	if bottom ~= -1 then
		return commonlib.has(valid_floors, get_entity_type(bottom))
	end
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
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	-- prevent spawning in lake
	if roomy > 4 then return false end

	local _subchunk_id = locatelib.get_levelroom_at(roomx, roomy)
	if _subchunk_id == roomdeflib.HD_SUBCHUNKID.RESTLESS_TOMB then
		return false
	end

	local below_type = get_entity_type(get_grid_entity_at(x, y-1, l))
    return (
		-- _subchunk_id ~= genlib.HD_SUBCHUNKID.RESTLESS_TOMB and
		detect_empty_nodoor(x, y, l)
		and detect_empty_nodoor(x, y+1, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
		and below_type ~= ENT_TYPE.FLOORSTYLED_BEEHIVE
		and not is_water_at(x, y)
	)
end

function module.is_valid_giantfrog_spawn(x, y, l)
	return is_solid_grid_entity(x, y-1, l)
	and is_solid_grid_entity(x+1, y-1, l)
	and check_empty_space(x, y+1, l, 2, 2)
end -- # TODO: Implement method for valid giantfrog spawn

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
		and default_ground_monster_condition(x, y, l)
	)
end -- # TODO: Implement method for valid mammoth spawn

function module.is_valid_giantspider_spawn(x, y, l)
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
		and is_solid_grid_entity(x, y+1, l)
		and is_solid_grid_entity(x+1, y+1, l)
		and createlib.GIANTSPIDER_SPAWNED == false
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid giantspider spawn

function module.is_valid_bee_spawn(x, y, l)
	return get_entity_type(get_grid_entity_at(x, y+1, l)) == ENT_TYPE.FLOORSTYLED_BEEHIVE
		and check_empty_space(x, y, l, 1, 2)
end

function module.is_valid_honey_spawn(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
		and (
			get_entity_type(get_grid_entity_at(x, y+1, l)) == ENT_TYPE.FLOORSTYLED_BEEHIVE
			or get_entity_type(get_grid_entity_at(x, y-1, l)) == ENT_TYPE.FLOORSTYLED_BEEHIVE
		)
end

function module.is_valid_queenbee_spawn(x, y, l)
	local rx, ry = get_room_index(x, y)
	local levelrooms = roomgenlib.global_levelassembly.modification.levelrooms
	local _template_hd = levelrooms[ry+1] and (levelrooms[ry+1][rx+1] or 0) or 0
	return _template_hd >= 1300 and _template_hd < 1400 and check_empty_space(x, y, l, 3, 3)
end

function module.is_valid_ufo_spawn(x, y, l) return false end -- # TODO: Implement method for valid ufo spawn

function module.is_valid_bacterium_spawn(x, y, l)
	return get_grid_entity_at(x, y, l) == -1
	and (
		is_solid_grid_entity(x, y+1, l)
		or is_solid_grid_entity(x+1, y, l)
		or is_solid_grid_entity(x, y-1, l)
		or is_solid_grid_entity(x-1, y, l)
	)
end -- # TODO: Implement method for valid bacterium spawn

function module.is_valid_eggsac_spawn(x, y, l) return false end -- # TODO: Implement method for valid eggsac spawn

return module