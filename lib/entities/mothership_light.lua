local module = {}
local celib = require "lib.entities.custom_entities"

local BRIGHTNESS = 1.0
local BRIGHTNESS_MULTIPLIER = 2.25
local mothership_light_color = Color:new(0.5, 0.5, 1, 1)

local mship_light_texture_id
do
    local mship_light_texture_def = TextureDefinition.new()
    mship_light_texture_def.width = 128
    mship_light_texture_def.height = 128
    mship_light_texture_def.tile_width = 128
    mship_light_texture_def.tile_height = 128

    mship_light_texture_def.texture_path = "res/mlamp.png"
    mship_light_texture_id = define_texture(mship_light_texture_def)
end

local function light_update(light_emitter)
    refresh_illumination(light_emitter)
    light_emitter.brightness = BRIGHTNESS
end

local function mothership_light_set(ent)
    ent.hitboxx = 0.35
    ent.hitboxy = 0.4
    ent:set_texture(mship_light_texture_id)
    local light_emitter = create_illumination(mothership_light_color, 3, ent.uid)
    light_emitter.brightness = BRIGHTNESS
    light_emitter.brightness_multiplier = BRIGHTNESS_MULTIPLIER
    return {
        light_emitter = light_emitter
    }
end

local function mothership_light_update(ent, c_data)
    if not ent.overlay or test_flag(ent.flags, ENT_FLAG.DEAD) then
        if math.random(8) == 1 then
            local x, y, l = get_position(ent.uid)
            spawn(ENT_TYPE.ITEM_SAPPHIRE_SMALL, x, y, l, math.random()*0.2-0.1, math.random()*0.1)
        elseif math.random(4) == 1 then
            local x, y, l = get_position(ent.uid)
            spawn(ENT_TYPE.ITEM_SAPPHIRE, x, y, l, math.random()*0.2-0.1, math.random()*0.1)
        end
        kill_entity(ent.uid)
    end
    light_update(c_data.light_emitter)
end

local mothership_light_id = celib.new_custom_entity(mothership_light_set, mothership_light_update)
celib.init()

function module.create_mshiplight(x, y, l)
    local uid = spawn_over(ENT_TYPE.ITEM_ICESPIRE, get_grid_entity_at(x, y+1, l), 0.0, -1.0)
    celib.set_custom_entity(uid, mothership_light_id)
end

optionslib.register_entity_spawner("Mothership light", module.create_mshiplight, true)

return module