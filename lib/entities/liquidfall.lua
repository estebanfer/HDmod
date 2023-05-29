local module = {}

local jungle_head_texture_id
local jungle_drain_texture_id
local gold_head_texture_id
local gold_drain_texture_id
local temple_head_texture_id
local temple_drain_texture_id
local temple_head_stone_texture_id
local temple_drain_stone_texture_id
local hell_head_texture_id
local hell_drain_texture_id

do
    local jungle_head_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
    jungle_head_texture_def.texture_path = "res/fountain_jungle.png"
    jungle_head_texture_id = define_texture(jungle_head_texture_def)
    local jungle_drain_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
    jungle_drain_texture_def.texture_path = "res/fountain_jungle.png"
    jungle_drain_texture_id = define_texture(jungle_drain_texture_def)
    
    local gold_head_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
    gold_head_texture_def.texture_path = "res/fountain_gold.png"
    gold_head_texture_id = define_texture(gold_head_texture_def)
    local gold_drain_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
    gold_drain_texture_def.texture_path = "res/fountain_gold.png"
    gold_drain_texture_id = define_texture(gold_drain_texture_def)

    local temple_head_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
    temple_head_texture_def.texture_path = "res/fountain_temple.png"
    temple_head_texture_id = define_texture(temple_head_texture_def)
    local temple_drain_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
    temple_drain_texture_def.texture_path = "res/fountain_temple.png"
    temple_drain_texture_id = define_texture(temple_drain_texture_def)

    local temple_head_stone_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
    temple_head_stone_texture_def.texture_path = "res/fountain_temple_stone.png"
    temple_head_stone_texture_id = define_texture(temple_head_stone_texture_def)
    local temple_drain_stone_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
    temple_drain_stone_texture_def.texture_path = "res/fountain_temple.png"
    temple_drain_stone_texture_id = define_texture(temple_drain_stone_texture_def)

    local hell_head_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
    hell_head_texture_def.texture_path = "res/fountain_hell.png"
    hell_head_texture_id = define_texture(hell_head_texture_def)
    local hell_drain_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
    hell_drain_texture_def.texture_path = "res/fountain_temple.png"
    hell_drain_texture_id = define_texture(hell_drain_texture_def)
end

local function create_liquidfall(x, y, l, head_texture_id, drain_texture_id, is_lava)
	local is_lava = is_lava or false
	local type = ENT_TYPE.LOGICAL_WATER_DRAIN
	if is_lava == true then
		type = ENT_TYPE.LOGICAL_LAVA_DRAIN
	end
	local drain_uid = spawn_entity(type, x, y, l, 0, 0)
	get_entity(drain_uid):set_texture(head_texture_id)

	local backgrounds = entity_get_items_by(drain_uid, ENT_TYPE.BG_WATER_FOUNTAIN, 0)
	if #backgrounds ~= 0 then get_entity(backgrounds[1]):set_texture(drain_texture_id) end
end

function module.create_liquidfall_from_theme(x, y, l)
    if state.theme == THEME.CITY_OF_GOLD then
        create_liquidfall(x, y-3, l, gold_head_texture_id, gold_drain_texture_id, true)
    elseif state.theme == THEME.TEMPLE then
        create_liquidfall(x, y-3, l, (options.hd_og_floorstyle_temple and temple_head_stone_texture_id or temple_head_texture_id), (options.hd_og_floorstyle_temple and temple_drain_stone_texture_id or temple_drain_texture_id), true)
    elseif state.theme == THEME.VOLCANA then
        create_liquidfall(x, y-3, l, hell_head_texture_id, hell_drain_texture_id, true)
    else
        create_liquidfall(x, y-2.5, l, jungle_head_texture_id, jungle_drain_texture_id)
    end
end

return module