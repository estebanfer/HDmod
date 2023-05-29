local module = {}

function module.create_liquidfall(x, y, l, texture_path, is_lava)
	local is_lava = is_lava or false
	local type = ENT_TYPE.LOGICAL_WATER_DRAIN
	if is_lava == true then
		type = ENT_TYPE.LOGICAL_LAVA_DRAIN
	end
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
	texture_def.texture_path = texture_path
	local drain_texture = define_texture(texture_def)
	local drain_uid = spawn_entity(type, x, y, l, 0, 0)
	get_entity(drain_uid):set_texture(drain_texture)

	local backgrounds = entity_get_items_by(drain_uid, ENT_TYPE.BG_WATER_FOUNTAIN, 0)
	if #backgrounds ~= 0 then
		local texture_def2 = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
		texture_def2.texture_path = texture_path
		local fountain_texture = define_texture(texture_def2)

		local fountain = get_entity(backgrounds[1])
		fountain:set_texture(fountain_texture)
	end
end

return module