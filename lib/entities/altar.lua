local module = {}

local altar_texture_id
local banner_texture_id
do
    local altar_texture_def = TextureDefinition.new()
    altar_texture_def.width = 512
    altar_texture_def.height = 512
    altar_texture_def.tile_width = 512
    altar_texture_def.tile_height = 512
    altar_texture_def.texture_path = "res/hauntedcastle_altar.png"
    altar_texture_id = define_texture(altar_texture_def)

    local banner_texture_def = TextureDefinition.new()
    banner_texture_def.width = 256
    banner_texture_def.height = 512
    banner_texture_def.tile_width = 256
    banner_texture_def.tile_height = 512
    banner_texture_def.texture_path = "res/hauntedcastle_banner.png"
    banner_texture_id = define_texture(banner_texture_def)
end

function module.create_altar(x, y, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y, l)
end

function module.create_hc_altar(x, y, l)
    get_entity(spawn_entity(ENT_TYPE.BG_BASECAMP_SHORTCUTSTATIONBANNER, x+4, y+2, l, 0, 0)):set_texture(banner_texture_id)
    
    local bg = get_entity(spawn_entity(ENT_TYPE.BG_KALI_STATUE, x+.5, y+0.6, l, 0, 0))
    bg:set_texture(altar_texture_id)
    bg.width = 5.0--5.600
    bg.height = 5.0--7.000

    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y-1, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y-1, l)

    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y-1, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y, l)
    spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y-1, l)
end

return module