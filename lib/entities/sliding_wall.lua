idollib = require 'lib.entities.idol'
feelingslib = require 'lib.feelings'

local module = {}
local hc_sliding_wall_ceiling = nil
local temple_chain_ceiling_texture_id
local temple_slidingdoor_texture_id
local hc_slidingdoor_texture_id

do
    local temple_chain_ceiling_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_0)
    temple_chain_ceiling_texture_def.texture_path = "res/slidingwall_temple.png"
    temple_chain_ceiling_texture_id = define_texture(temple_chain_ceiling_texture_def)
    
    local temple_slidingdoor_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_1)
    temple_slidingdoor_texture_def.texture_path = "res/slidingwall_temple.png"
    temple_slidingdoor_texture_id = define_texture(temple_slidingdoor_texture_def)
    
    local hc_slidingdoor_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_1)
    hc_slidingdoor_texture_def.texture_path = "res/castledoor.png"
    hc_slidingdoor_texture_id = define_texture(hc_slidingdoor_texture_def)
end

function module.spawn_slidingwall(x, y, layer, up)
    local ceiling = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_SLIDINGWALL_CEILING, x, y, layer))
    local chain = get_entity(spawn_over(ENT_TYPE.ITEM_SLIDINGWALL_CHAIN_LASTPIECE, ceiling.uid, 0, 0))
    chain.attached_to_uid = -1
    ceiling.attached_piece = chain
    local wall = get_entity(spawn_over(ENT_TYPE.ACTIVEFLOOR_SLIDINGWALL, chain.uid, 0, -1.5))
    wall.ceiling = ceiling
    ceiling.active_floor_part_uid = wall.uid
    if up then ceiling.state = 1 end

    
    if state.theme == THEME.TEMPLE then
        idollib.sliding_wall_ceilings[#idollib.sliding_wall_ceilings+1] = ceiling.uid

        ceiling:set_texture(temple_chain_ceiling_texture_id)
        chain:set_texture(temple_chain_ceiling_texture_id)
        wall:set_texture(temple_slidingdoor_texture_id)
    end

    if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
        wall:set_texture(hc_slidingdoor_texture_id)

        hc_sliding_wall_ceiling = ceiling.uid

        set_callback(function()
            local overlapping_players = get_entities_overlapping_hitbox(
                0, MASK.PLAYER,
                AABB:new(
                    2.5,
                    118.5,
                    30.5,
                    92.5
                ),
                layer
            )
            if #overlapping_players > 0 then
                local ent = get_entity(hc_sliding_wall_ceiling)
                if ent ~= nil then
                    ent.state = 0
                end
                clear_callback()
            end
        end, ON.FRAME)
    end
end

set_post_entity_spawn(function(entity)
    if state.theme == THEME.TEMPLE then
        entity:set_texture(temple_chain_ceiling_texture_id)
    end
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_SLIDINGWALL_CHAIN)

return module