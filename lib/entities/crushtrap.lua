local module = {}


local texture_id
do
    local texture_def = TextureDefinition.new()
    texture_def.width = 128
    texture_def.height = 128
    texture_def.tile_width = 128
    texture_def.tile_height = 128
    texture_def.texture_path = "res/crushtrap_stone.png"
    texture_id = define_texture(texture_def)
end

function module.create_crushtrap(x, y, l)
    local crushtrap = get_entity(spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, x, y, l))
    if options.hd_og_floorstyle_temple and state.theme ~= THEME.CITY_OF_GOLD then
        crushtrap:set_texture(texture_id)
        crushtrap.animation_frame = 0
    end
end

return module