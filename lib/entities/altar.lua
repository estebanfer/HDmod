local module = {}

function module.create_altar(x, y, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y, l)
end

function module.create_hc_altar(x, y, l)
    local ent_uid = spawn_entity(ENT_TYPE.BG_BASECAMP_SHORTCUTSTATIONBANNER, x+4, y+2, l, 0, 0)
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_BASECAMP_3)
    texture_def.texture_path = "res/hauntedcastle_banner.png"
    get_entity(ent_uid):set_texture(define_texture(texture_def))
    
    ent_uid = spawn_entity(ENT_TYPE.BG_KALI_STATUE, x+.5, y+0.6, l, 0, 0)
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_JUNGLE_0)
    texture_def.texture_path = "res/hauntedcastle_deco.png"
    get_entity(ent_uid):set_texture(define_texture(texture_def))
    get_entity(ent_uid).width = 5.0--5.600
    get_entity(ent_uid).height = 5.0--7.000

    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y-1, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y-1, l)

    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y-1, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y-1, l)
end

return module