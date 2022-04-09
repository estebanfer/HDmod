--[[
    Lut Settings
]]

local vlad_atmos_id
do
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_LUT_ORIGINAL_0)
    texture_def.texture_path = "res/lut_hell.png"
    vlad_atmos_id = define_texture(texture_def)
end

set_callback(function ()
    if state.theme == THEME.VOLCANA then
        set_lut(vlad_atmos_id, LAYER.FRONT)
    else
        reset_lut(LAYER.FRONT)
    end
end, ON.POST_LEVEL_GENERATION)