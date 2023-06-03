local module = {}

local validlib = require 'lib.spawning.valid'

local gold_texture_id
local uvula_texture_id
do
    local gold_texture_def = TextureDefinition.new()
    gold_texture_def.width = 128
    gold_texture_def.height = 512
    gold_texture_def.tile_width = 128
    gold_texture_def.tile_height = 128
    gold_texture_def.texture_path = "res/ladder_gold.png"
    gold_texture_id = define_texture(gold_texture_def)

    uvula_texture_id = TEXTURE.DATA_TEXTURES_FLOOR_EGGPLANT_0
end

local ANIMATION_FRAMES_ENUM = {
    GOLD_LADDER = 1,
    GOLD_LADDER_PLATFORM = 2,
    CLIMBABLE = 3,
}

local ANIMATION_FRAMES_BASE = {
    { 4, 16, 40 },
    { 2 },
    { 4, 16, 28 },
}
local ANIMATION_FRAMES_RES = {
    { 0, 1, 3 },
    { 2 },
    { 4, 16, 28 },
}

function module.create_ladder(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l) end

function module.create_ladder_platform(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l) end

function module.create_ladder_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l))
    ent:set_texture(gold_texture_id)
    for i = 1, #ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.GOLD_LADDER], 1 do
        if ent.animation_frame == ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.GOLD_LADDER][i] then
            ent.animation_frame = ANIMATION_FRAMES_RES[ANIMATION_FRAMES_ENUM.GOLD_LADDER][i]
        end
    end
end

function module.create_ladder_platform_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l))
    ent:set_texture(gold_texture_id)
    ent.animation_frame = ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.GOLD_LADDER_PLATFORM][1]
end

local function _recursively_kill_climbable(climbable_uid, type)
    local climbables_attached_to = entity_get_items_by(climbable_uid, type, MASK.ITEM)
    if #climbables_attached_to > 0 then
        _recursively_kill_climbable(climbables_attached_to[1], type)
    else
        kill_entity(climbable_uid)
    end
    kill_entity(climbable_uid)
end

local function set_post_destruction_for_climbable(floor, climbable, type)
    floor:set_post_destroy(function(ent)
        _recursively_kill_climbable(climbable.uid, type)
    end)
end

local function _create_climbable_single(x, y, l, to_attach_to, type)
    local is_ropelike = (type == ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN or type == ENT_TYPE.ITEM_STICKYTRAP_PIECE)
    local is_uvula = type == ENT_TYPE.ITEM_STICKYTRAP_PIECE
    local is_top = to_attach_to.type.id ~= type
    local climbable = get_entity(is_ropelike and spawn_entity_over(type, to_attach_to.uid, 0, -1) or spawn_grid_entity(type, x, y, l))
    
    if is_uvula then
        climbable:set_texture(uvula_texture_id)
    end
    climbable.animation_frame = ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.CLIMBABLE][3]
    if is_top then
        --I have NO idea why but the animation frame gets set to 16 if I don't apply it with a timeout here
        set_global_timeout(function()
            climbable.animation_frame = ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.CLIMBABLE][1]
        end, 1)
        if is_uvula then
            set_post_destruction_for_climbable(to_attach_to, climbable, type)
        end
    else
        to_attach_to.animation_frame = ANIMATION_FRAMES_BASE[ANIMATION_FRAMES_ENUM.CLIMBABLE][2]
    end
    return climbable
end

function module.create_ceiling_chain(x, y, l)
	local entities_at_offset = get_entities_at(0, MASK.FLOOR | MASK.ROPE, x, y+1, l, 0.5)
	if #entities_at_offset > 0 then
        _create_climbable_single(x, y, l, get_entity(entities_at_offset[1]), ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN)
    end
end

local function spawn_monkey_on_climbable(climbable_uid)
    local monkey_chance = get_procedural_spawn_chance(state.theme == THEME.EGGPLANT_WORLD and spawndeflib.global_spawn_procedural_worm_jungle_monkey or spawndeflib.global_spawn_procedural_monkey)
    if (
        (
            (state.theme == THEME.JUNGLE and feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false)
            or (state.theme == THEME.EGGPLANT_WORLD and state.world == 2)
        )
        and monkey_chance ~= 0
        and prng:random_chance(monkey_chance, PRNG_CLASS.LEVEL_GEN)
    ) then
        spawn_entity_over(ENT_TYPE.MONS_MONKEY, climbable_uid, 0, 0)
    end
end

function module.create_uvula(x, y, l)
	local entities_at_offset = get_entities_at(0, MASK.FLOOR | MASK.ITEM, x, y+1, l, 0.5)
	if #entities_at_offset > 0 then
        spawn_monkey_on_climbable(_create_climbable_single(x, y, l, get_entity(entities_at_offset[1]), ENT_TYPE.ITEM_STICKYTRAP_PIECE).uid)
    end
end

function module.create_vine(x, y, l)
    spawn_monkey_on_climbable(spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, y, l))
end

local function _create_growable_climbable(x, y, l, type)
    local to_attach_to = get_entity(get_grid_entity_at(x, y+1, l))
    if to_attach_to then
        local yi = y
        while true do
            to_attach_to = _create_climbable_single(x, yi, l, to_attach_to, type)
            yi = yi - 1
            if not validlib.is_valid_climbable_space(x, yi, l) then
                break
            end
        end
    end
end

function module.create_growable_uvula(x, y, l)
    _create_growable_climbable(x, y, l, ENT_TYPE.ITEM_STICKYTRAP_PIECE)
end

function module.create_growable_ceiling_chain(x, y, l)
    _create_growable_climbable(x, y, l, ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN)
end

function module.create_growable_vine(x, y, l)
    _create_growable_climbable(x, y, l, ENT_TYPE.FLOOR_VINE)
end

return module