local module = {}

local arrowtrap_gold_texture_id
local arrowtrap_temple_texture_id
do
    local arrowtrap_temple_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
    arrowtrap_temple_texture_def.texture_path = "res/temple_arrow_trap.png"
    arrowtrap_temple_texture_id = define_texture(arrowtrap_temple_texture_def)

    local arrowtrap_gold_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
    arrowtrap_gold_texture_def.texture_path = "res/floormisc_gold_trap.png"
    arrowtrap_gold_texture_id = define_texture(arrowtrap_gold_texture_def)
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

	if state.theme == THEME.TEMPLE then
		get_entity(uid):set_texture(arrowtrap_temple_texture_id)
	elseif state.theme == THEME.CITY_OF_GOLD then
		get_entity(uid):set_texture(arrowtrap_gold_texture_id)
	end
end

return module