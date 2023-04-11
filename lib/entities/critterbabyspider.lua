local celib = require "lib.entities.custom_entities"

local module = {}

local critterbabyspider_texture_id
do
    local critterbabyspider_texture_def = TextureDefinition.new()
    
    critterbabyspider_texture_def.width = 128
    critterbabyspider_texture_def.height = 384
    critterbabyspider_texture_def.tile_width = 128
    critterbabyspider_texture_def.tile_height = 128
    critterbabyspider_texture_def.texture_path = 'res/babyspider.png'
    critterbabyspider_texture_id = define_texture(critterbabyspider_texture_def)
end

local function critterbabyspider_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent:set_texture(critterbabyspider_texture_id)
    ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
    ent.flags = set_flag(ent.flags, ENT_FLAG.PICKUPABLE)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    ent.flags = set_flag(ent.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
end
local function critterbabyspider_update(ent)
    -- print(tostring(ent.movex))
    if ent.overlay ~= nil then
        ent.movex = 0
        ent.lock_input_timer = 30
    end
    if ent.animation_frame <= 50 then
        ent.animation_frame = 0
    elseif ent.animation_frame > 50 and ent.animation_frame <= 52 then
        ent.animation_frame = 1
    elseif ent.animation_frame == 55 then
        ent.animation_frame = 2
    end
end

function module.create_critterbabyspider(x, y, l)
    local critterbabyspider = spawn(ENT_TYPE.MONS_SPIDER, x, y, l, 0, 0)
    critterbabyspider_set(critterbabyspider)
    set_post_statemachine(critterbabyspider, critterbabyspider_update)
    return critterbabyspider
end

optionslib.register_entity_spawner("Baby spider", module.create_critterbabyspider)

return module