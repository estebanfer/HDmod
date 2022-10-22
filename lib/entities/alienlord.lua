local roomdeflib = require 'lib.gen.roomdef'
local locatelib = require 'lib.locate'
local module = {}

local alienlord_texture_id
do
    local alienlord_texture_def = TextureDefinition.new()
    alienlord_texture_def.width = 1024
    alienlord_texture_def.height = 256
    alienlord_texture_def.tile_width = 256
    alienlord_texture_def.tile_height = 256
    alienlord_texture_def.texture_path = 'res/alienlord.png'
    alienlord_texture_id = define_texture(alienlord_texture_def)
end

local function alienlord_update(ent)
    ent.x, ent.y = ent.spawn_x, ent.spawn_y
    -- if ent.walk_pause_timer > 200 then
    --     ent.animation_frame = 0
    -- elseif ent.walk_pause_timer <= 200 and ent.walk_pause_timer > 100 then
    --     ent.animation_frame = 1
    -- elseif ent.walk_pause_timer <= 100 and ent.walk_pause_timer > 0 then
    --     ent.animation_frame = 2
    -- elseif ent.walk_pause_timer <= 0 then
    --     ent.animation_frame = 3
    --     ent.walk_pause_timer = 300
    -- end
end

local function alienlord_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent.move_state = 5
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(ent.x, ent.y)
	local _subchunk_id = locatelib.get_levelroom_at(roomx, roomy)
    if _subchunk_id == roomdeflib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_LEFT then
        ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
    -- ent.walk_pause_timer = 300
    set_timeout(function()
        ent:set_texture(alienlord_texture_id)
    end, 2)
end

set_post_entity_spawn(function(ent)
    if state.theme ~= THEME.TEMPLE then
        -- prinspect(ent.speed)
        ent.speed = 0.05
    end
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_SCEPTER_ANUBISSHOT)

--[[
    erictran:
    "he shouldnt be too hard to program, just take something like yeti king / queen,
    disable their AI, retexture them to use the alien lord from s1 and make him
    periodically spawn the anubis projectiles.
    
    well dont literally disable their ai, but set their move_state and state values
    to some arbitrary value to stop them from moving."
    -- Change projectile speed with `ScepterShot::speed`
--]]
function module.create_alienlord(x, y, l)
    local alienlord = spawn(ENT_TYPE.MONS_ANUBIS, x+.5, y-.5, l, 0, 0)
    alienlord_set(alienlord)
    set_post_statemachine(alienlord, alienlord_update)
    return alienlord
end

register_option_button("spawn_alienlord", "spawn_alienlord", 'spawn_alienlord', function()
    local x, y, l = get_position(players[1].uid)
    module.create_alienlord(x-5, y, l)
end)

return module