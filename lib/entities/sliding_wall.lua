idollib = require 'lib.entities.idol'
feelingslib = require 'lib.feelings'

local module = {}
local hc_sliding_wall_ceiling = nil

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

        local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_0)
        texture_def.texture_path = "res/floorstyled_temple_slidingwall.png"
        ceiling:set_texture(define_texture(texture_def))
        chain:set_texture(define_texture(texture_def))

        texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_1)
        texture_def.texture_path = "res/floorstyled_temple_slidingwall.png"
        wall:set_texture(define_texture(texture_def))
    end

    if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
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
                ent.state = 0
                return false
            end
        end, ON.FRAME)
    end
end
return module