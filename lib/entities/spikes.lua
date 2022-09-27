local commonlib = require 'lib.common'

local module = {}

module.vlad_spikes = {}
local vlad_spikes_texture_id
do
    local vlad_spikes_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_0)
    vlad_spikes_texture_def.texture_path = "res/vladspikes.png"
    vlad_spikes_texture_id = define_texture(vlad_spikes_texture_def)
end

function module.init()
    module.vlad_spikes = {}
end

set_post_entity_spawn(function(entity)
    local x, y, l = get_position(entity.uid)
    local spike_uid = get_grid_entity_at(x, y, l)
    if spike_uid ~= -1 then
        if commonlib.has(module.vlad_spikes, spike_uid) then
            entity:set_texture(vlad_spikes_texture_id)
        end
    end
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.DECORATION_SPIKES_BLOOD)

return module