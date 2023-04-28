local module = {}

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

return module