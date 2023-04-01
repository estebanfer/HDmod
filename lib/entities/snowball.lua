local module = {}
local celib = require "lib.entities.custom_entities"
--[[ TODO:
    2. When the snowing level feeling occurs, replace all rocks in a level with this entity.
    3. Replace the rock's texture with the snowball texture
    4. When the rock damages something it looses its snowball texture and emits snow particles
]]

local function snowball_set()
    -- animation_frame = 222
end

local snowball_id = celib.new_custom_entity(snowball_set, function() end, celib.CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK)

function module.create_snowball(grid_x, grid_y, layer)
    celib.spawn_custom_entity(snowball_id, grid_x, grid_y, layer, 0, 0)
end

register_option_button("spawn snowball", "spawn snowball", "spawn snowball", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    module.create_snowball(x+2, y, l)
end)

return module