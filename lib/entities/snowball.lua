local module = {}
local celib = require "lib.entities.custom_entities"
local feelingslib = require "lib.feelings"
--[[ TODO:
    2. When the snowing level feeling occurs, replace all rocks in a level with this entity.
    3. Replace the rock's texture with the snowball texture
    4. When the rock damages something it looses its snowball texture and emits snow particles
]]

celib.init()

local function snowball_set(ent)
    ent.animation_frame = 222
end

local snowball_id = celib.new_custom_entity(snowball_set, function() end, celib.CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK)

function module.create_snowball(x, y, layer)
    local uid = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_ROCK, x, y, layer)
    celib.set_custom_entity(uid, snowball_id)
    return uid
end

set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if (
		spawn_flags & SPAWN_TYPE.SCRIPT == 0
        and (
            feelingslib.feeling_check(feelingslib.FEELING_ID.SNOWING)
            or feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)
        )
    ) then
        return module.create_snowball(x, y, l)
    end
end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, ENT_TYPE.ITEM_ROCK)

register_option_button("spawn snowball", "spawn snowball", "spawn snowball", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    module.create_snowball(x+2, y, l)
end)

return module