local module = {}
local celib = require "lib.entities.custom_entities"
--[[ TODO:
    1. Make a custom entity that uses a rock as the base
    2. When the snowing level feeling occurs, replace all rocks in a level with this entity.
    3. Replace the rock's texture with the snowball texture
    4. When the rock damages something it looses its snowball texture and emits snow particles
]]

return module