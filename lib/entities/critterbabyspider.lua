local celib = require "lib.entities.custom_entities"

local module = {}

local critterbabyspider_texture_id
do
    local critterbabyspider_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERSBASIC01_0)
    critterbabyspider_texture_def.texture_path = 'res/critterbabyspider.png'
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
    print(tostring(ent.movex))
    if ent.overlay ~= nil then
        ent.movex = 0
        ent.lock_input_timer = 30
    end
end

function module.create_critterbabyspider(x, y, l)
    local critterbabyspider = spawn(ENT_TYPE.MONS_SPIDER, x, y, l, 0, 0)
    critterbabyspider_set(critterbabyspider)
    set_post_statemachine(critterbabyspider, critterbabyspider_update)
end

register_option_button("spawn_critterbabyspider", "spawn_critterbabyspider", 'spawn_critterbabyspider', function()
     local x, y, l = get_position(players[1].uid)
     module.create_critterbabyspider(x-5, y, l)
end)

return module