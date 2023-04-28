local module = {}

local hc_texture_id
do
    local hc_texture_def = TextureDefinition.new()
    hc_texture_def.width = 128
    hc_texture_def.height = 256
    hc_texture_def.tile_width = 128
    hc_texture_def.tile_height = 256
    hc_texture_def.texture_path = "res/hauntedcastle_window.png"
    hc_texture_id = define_texture(hc_texture_def)
end

local function create_window(x, y, l, _texture_id)
	local ent = get_entity(spawn_entity(ENT_TYPE.BG_VLAD_WINDOW, x, y-0.5, l, 0, 0))
	ent.width, ent.height = 1, 2
	ent.hitboxx, ent.hitboxy = 0.5, 1

	local window_texture_id = _texture_id or TEXTURE.DATA_TEXTURES_FLOORSTYLED_VLAD_4
	ent:set_texture(window_texture_id)
    if _texture_id then ent.animation_frame = 0 end
end

function module.create_hcastle_window(x, y, l)
	create_window(x, y, l, hc_texture_id)
end

module.create_vlad_window = create_window

return module