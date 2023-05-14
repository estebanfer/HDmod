local module = {}

local generic_texture_id
local temple_texture_id
do
    local generic_texture_def = TextureDefinition.new()
    generic_texture_def.width = 256
    generic_texture_def.height = 256
    generic_texture_def.tile_width = 128
    generic_texture_def.tile_height = 128
    generic_texture_def.texture_path = "res/idol_platform_generic.png"
    generic_texture_id = define_texture(generic_texture_def)

    local temple_texture_def = TextureDefinition.new()
    temple_texture_def.width = 256
    temple_texture_def.height = 256
    temple_texture_def.tile_width = 128
    temple_texture_def.tile_height = 128
    temple_texture_def.texture_path = "res/idol_platform_temple.png"
    temple_texture_id = define_texture(temple_texture_def)
end

function module.create_idol_platform(x, y, l)
    local idol_block_first = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_IDOL_BLOCK, x, y, l))
    local idol_block_second = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_IDOL_BLOCK, x+1, y, l))
    idol_block_second.animation_frame = idol_block_second.animation_frame + 1

    if state.theme ~= THEME.VOLCANA then
        local texture_def = (state.theme == THEME.TEMPLE and not options.hd_og_floorstyle_temple) and temple_texture_id or generic_texture_id
        idol_block_first:set_texture(texture_def)
        idol_block_second:set_texture(texture_def)
        idol_block_first.animation_frame = 0
        idol_block_second.animation_frame = 1
        -- # TODO: create a post-destruction method to add decoration_generic on the opposite floor that isn't destroyed.
    end
end


return module