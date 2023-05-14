local module = {}

local validlib = require 'lib.spawning.valid'

local texture_id
do
    local texture_def = TextureDefinition.new()
    texture_def.width = 128
    texture_def.height = 512
    texture_def.tile_width = 128
    texture_def.tile_height = 128
    texture_def.texture_path = "res/ladder_gold.png"
    texture_id = define_texture(texture_def)
end

function module.create_ladder(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l) end

function module.create_ladder_platform(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l) end

function module.create_ladder_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l))
    ent:set_texture(texture_id)
    if ent.animation_frame == 4 then
        ent.animation_frame = 0
    elseif ent.animation_frame == 16 then
        ent.animation_frame = 1
    elseif ent.animation_frame == 40 then
        ent.animation_frame = 3
    end
end

function module.create_ladder_platform_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l))
    ent:set_texture(texture_id)
    ent.animation_frame = 2
end

local function _create_chain_single(ent_to_spawn_over)
    local chain = get_entity(spawn_entity_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ent_to_spawn_over.uid, 0, -1))
    if (
        ent_to_spawn_over.type.id == ENT_TYPE.FLOOR_GENERIC
        or ent_to_spawn_over.type.id == ENT_TYPE.FLOORSTYLED_VLAD
        or ent_to_spawn_over.type.id == ENT_TYPE.FLOOR_BORDERTILE
    ) then
        chain.animation_frame = 4
    end
    return chain
end

function module.create_ceiling_chain(x, y, l)
	local floors_at_offset = get_entities_at(0, MASK.FLOOR | MASK.ROPE, x, y+1, l, 0.5)
	if #floors_at_offset > 0 then
        _create_chain_single(get_entity(floors_at_offset[1]))
    end
end

function module.create_vine(x, y, l)
    local vine = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, y, l))

    local chance_id = spawndeflib.global_spawn_procedural_monkey
    if state.theme == THEME.EGGPLANT_WORLD then
        chance_id = spawndeflib.global_spawn_procedural_worm_jungle_monkey
    end
    local monkey_chance = get_procedural_spawn_chance(chance_id)
    if (
        (
            (state.theme == THEME.JUNGLE and feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false)
            or (state.theme == THEME.EGGPLANT_WORLD and state.world == 2)
        )
        and monkey_chance ~= 0
        and math.random(monkey_chance) == 1
    ) then
        spawn_entity_over(ENT_TYPE.MONS_MONKEY, vine.uid, 0, 0)
    end
end

local function _create_growable_climbable(x, y, l, is_chain)
    is_chain = is_chain or false
    local ent_to_spawn_over
    if is_chain then
        local floors_at_offset = get_entities_at(0, MASK.FLOOR, x, y+1, l, 0.5)
        if #floors_at_offset > 0 then ent_to_spawn_over = get_entity(floors_at_offset[1]) else return end
    end

	local yi = y
	while true do
        if is_chain then
            ent_to_spawn_over = _create_chain_single(ent_to_spawn_over)
        else
            spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, yi, l)
        end
        yi = yi - 1
        if not validlib.is_valid_climbable_space(x, yi, l) then break end
	end
end

function module.create_growable_ceiling_chain(x, y, l)
    _create_growable_climbable(x, y, l, true)
end

function module.create_growable_vine(x, y, l)
    -- spawn_grid_entity(ENT_TYPE.FLOOR_GROWABLE_VINE, x, y, l)
    _create_growable_climbable(x, y, l)
end

return module