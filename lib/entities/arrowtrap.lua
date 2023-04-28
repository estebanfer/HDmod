local optionslib = require "lib.options"

local module = {}

local gold_texture_id
local temple_texture_id
do
    local temple_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
	temple_texture_def.width = 128
	temple_texture_def.height = 128
	temple_texture_def.tile_width = 128
	temple_texture_def.tile_height = 128
    temple_texture_def.texture_path = "res/arrowtrap_temple.png"
    temple_texture_id = define_texture(temple_texture_def)

    local gold_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
	gold_texture_def.width = 128
	gold_texture_def.height = 128
	gold_texture_def.tile_width = 128
	gold_texture_def.tile_height = 128
    gold_texture_def.texture_path = "res/arrowtrap_gold.png"
    gold_texture_id = define_texture(gold_texture_def)
end

function module.create_arrowtrap(x, y, l)
	removelib.remove_floor_and_embedded_at(x, y, l)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_ARROW_TRAP, x, y, l)
    local left = validlib.is_solid_grid_entity(x-1, y, l)
    local right = validlib.is_solid_grid_entity(x+1, y, l)
	local flip = false
	if not left and not right then
		--math.randomseed(read_prng()[5])
		if prng:random() < 0.5 then
			flip = true
		end
	elseif not left then
		flip = true
	end
	if flip == true then
		flip_entity(uid)
	end
	if test_flag(state.level_flags, 18) == true then
		spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, uid, 0, 0.35)
	end

	if state.theme == THEME.TEMPLE and not options.hd_og_floorstyle_temple then
		get_entity(uid):set_texture(temple_texture_id)
	elseif state.theme == THEME.CITY_OF_GOLD then
		get_entity(uid):set_texture(gold_texture_id)
	end
end

return module