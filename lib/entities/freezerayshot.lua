mammothlib = require 'lib.entities.mammoth'

local module = {}

--modify ITEM_FREEZERAYSHOT to ignore lamassu with mammoth texture
function ignore_mammoth(ent, collision_ent)
    if collision_ent:get_texture() == mammothlib.mammoth_texture_id then
        return true
    end
end
set_post_entity_spawn(function(ent)
    set_pre_collision2(ent.uid, ignore_mammoth)
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_FREEZERAYSHOT)

return module



