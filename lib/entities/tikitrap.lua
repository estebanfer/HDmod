local module = {}
local gold_spear_texture_id
local spear_texture_id
do
    local spear_texture_def = TextureDefinition.new()
    spear_texture_def.width = 128
    spear_texture_def.height = 128
    spear_texture_def.tile_width = 128
    spear_texture_def.tile_height = 128
    spear_texture_def.texture_path = "res/spear_head.png"
    spear_texture_id = define_texture(spear_texture_def)

    local gold_spear_texture_def = TextureDefinition.new()
    gold_spear_texture_def.width = 128
    gold_spear_texture_def.height = 128
    gold_spear_texture_def.tile_width = 128
    gold_spear_texture_def.tile_height = 128
    gold_spear_texture_def.texture_path = "res/spear_head_gold.png"
    gold_spear_texture_id = define_texture(gold_spear_texture_def)
end

function module.create_tikitrap(x, y, l)
	removelib.remove_floor_and_embedded_at(x, y, l)
	local floor_uid = get_grid_entity_at(x, y-1, l)
    local uid = -1
    local type = state.theme == THEME.CITY_OF_GOLD and ENT_TYPE.FLOOR_LION_TRAP or ENT_TYPE.FLOOR_TOTEM_TRAP
    if floor_uid ~= -1 then
        uid = spawn_entity_over(type, floor_uid, 0, 1)
        local s_head = spawn_entity_over(type, uid, 0, 1)
    end

    return uid
end

set_callback(function()
    if test_flag(state.level_flags, 18) == true then
        local totems = get_entities_by({ENT_TYPE.FLOOR_TOTEM_TRAP, ENT_TYPE.FLOOR_LION_TRAP}, 0, LAYER.FRONT)
        for _t, totem in pairs(totems) do
            local flames = entity_get_items_by(totem, ENT_TYPE.FX_SMALLFLAME, 0)
            for _f, flame_uid in pairs(flames) do
                -- print(flame_uid)
                local flame = get_entity(flame_uid)
                if flame.x < 0 then
                    flame.x = -0.24
                else
                    flame.x = 0.24
                end
                flame.y = 0.04
            end
        end
    end
end, ON.POST_LEVEL_GENERATION)

function module.create_tikitrap_procedural(x, y, l)
    module.create_tikitrap(x, y, l)
end

set_post_entity_spawn(function(entity)
    entity.spawn_entity_type = ENT_TYPE.ITEM_LION_SPEAR
    -- entity.first_sound_id = VANILLA_SOUND.TRAPS_LIONTRAP_TRIGGER
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.FLOOR_TOTEM_TRAP)

set_post_entity_spawn(function(entity)
    entity:set_texture(state.theme == THEME.CITY_OF_GOLD and gold_spear_texture_id or spear_texture_id)
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_LION_SPEAR)

return module