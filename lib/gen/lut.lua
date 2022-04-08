--[[
    Lut Settings
]]

local module = {}

function module.add_lut()
    if state.theme == THEME.VOLCANA then
        local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_LUT_ORIGINAL_0)
        texture_def.texture_path = "res/lut_hell.png"
        local vlad_atmos_id = define_texture(texture_def)
        set_lut(vlad_atmos_id, LAYER.FRONT)
    end
end

return module