local commonlib = require 'lib.common'

local module = {}

local vlad_spikes = {}
local wood_spikes_texture_id
local worm_spikes_texture_id
local vlad_spikes_texture_id
do
    local wood_spikes_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0)
    wood_spikes_texture_def.texture_path = "res/spikes_wood.png"
    wood_spikes_texture_id = define_texture(wood_spikes_texture_def)

    worm_spikes_texture_id = define_texture(get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_EGGPLANT_0))

    local vlad_spikes_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_0)
    vlad_spikes_texture_def.texture_path = "res/spikes_vlad.png"
    vlad_spikes_texture_id = define_texture(vlad_spikes_texture_def)
end

function module.init()
    vlad_spikes = {}
end

function module.create_spikes_over(floor_uid)
    ---@type Floor
    local floor = get_entity(floor_uid)
    local spikes_uid = spawn_entity_over(ENT_TYPE.FLOOR_SPIKES, floor_uid, 0, 1)
    local wood_in_mines = (
        state.theme == THEME.DWELLING
        and floor.type.id == ENT_TYPE.FLOORSTYLED_MINEWOOD
    )
    if (
        wood_in_mines
        or state.theme == THEME.EGGPLANT_WORLD
    ) then
        local deco_texture = wood_spikes_texture_id
        if state.theme == THEME.EGGPLANT_WORLD then
            deco_texture = worm_spikes_texture_id
        end
        floor:add_decoration(FLOOR_SIDE.TOP)
        if floor.deco_top ~= -1 then
            local deco = get_entity(floor.deco_top)
            deco:set_texture(deco_texture)
            deco.animation_frame = math.random(101, 103)
        end
    elseif state.theme == THEME.VOLCANA then
        if (
            get_entity_type(floor_uid) == ENT_TYPE.FLOORSTYLED_VLAD
        ) then
            get_entity(spikes_uid):set_texture(vlad_spikes_texture_id)
            vlad_spikes[#vlad_spikes+1] = spikes_uid
        end
    end
end

function module.detect_floor_and_create_spikes(x, y, l)
    local floorsAtOffset = get_entities_at(0, MASK.FLOOR, x, y-1, LAYER.FRONT, 0.5)
    -- # TOTEST: If gems/gold/items are spawning over this, move this method to run after gems/gold/items get embedded. Then here, detect and remove any items already embedded.
    
    if #floorsAtOffset > 0 then
        module.create_spikes_over(floorsAtOffset[1])
    end
end

set_post_entity_spawn(function(entity)
    local x, y, l = get_position(entity.uid)
    local spike_uid = get_grid_entity_at(x, y, l)
    if spike_uid ~= -1 then
        if commonlib.has(vlad_spikes, spike_uid) then
            entity:set_texture(vlad_spikes_texture_id)
        end
    end
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.DECORATION_SPIKES_BLOOD)

return module