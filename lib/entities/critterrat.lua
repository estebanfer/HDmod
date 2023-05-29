local celib = require "lib.entities.custom_entities"
local commonlib = require 'lib.common'

local module = {}

local critterrat_texture_id
do
    local critterrat_texture_def = TextureDefinition.new()
    critterrat_texture_def.width = 384
    critterrat_texture_def.height = 256
    critterrat_texture_def.tile_width = 128
    critterrat_texture_def.tile_height = 128
    critterrat_texture_def.texture_path = 'res/gustaf.png'
    critterrat_texture_id = define_texture(critterrat_texture_def)
end

local function critterrat_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent:set_texture(critterrat_texture_id)
    ent.walk_pause_timer = prng:random_int(150, 300, PRNG_CLASS.AI) --randomize this so they dont all stand up at the same time
end
local function critterrat_update(ent)
    --flip entity based on movex

    --reroute base entity walking frames
    if ent.animation_frame == 3 then
        ent.animation_frame = 0
    elseif ent.animation_frame == 4 then
        ent.animation_frame = 1
    elseif ent.animation_frame == 5 then
        ent.animation_frame = 2
    end

    if ent.movex == -1 then
        ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
    if ent.movex == 1 then
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
    if ent.movex ~= 0 then
        ent.x = ent.x + 0.03*ent.movex
    end
    --cancel walk_pause_timer early and use it for the standing
    if ent.move_state == 5 and ent.walk_pause_timer < 5 then
        ent.move_state = 1
        ent.walk_pause_timer = 230 + prng:random_int(-15, 15, PRNG_CLASS.AI)
    end
    if ent.move_state == 1 and ent.walk_pause_timer < 90 then
        ent.move_state = 5
        ent.movex = 0
        ent.walk_pause_timer = 25
    end
    if ent.move_state == 5 then
        if ent.walk_pause_timer <= 25 and ent.walk_pause_timer > 21 then
            ent.animation_frame = 3
        elseif ent.walk_pause_timer <= 21 and ent.walk_pause_timer > 17 then
            ent.animation_frame = 4
        elseif ent.walk_pause_timer <= 17 and ent.walk_pause_timer > 13 then
            ent.animation_frame = 5
        elseif ent.walk_pause_timer <= 13 and ent.walk_pause_timer > 9 then
            ent.animation_frame = 4
        else
            ent.animation_frame = 3
        end
        --hacky solution to stop from getting frozen in this state when the player is nearby
        for _, player in ipairs(players) do
            local x, y, _ = get_position(ent.uid)
            local px, py, _ = get_position(player.uid)
            if math.abs(px-x) < 3 and math.abs(py-y) < 1 then
                ent.move_state = 1
                ent.walk_pause_timer = 230 + prng:random_int(-15, 15, PRNG_CLASS.AI)
            end
        end
    end
    --sfx when hitting walls
    if math.abs(ent.velocityx) + math.abs(ent.velocityy) > 0.03 then --make sure overall velocity is high enough for these checks
        if test_flag(ent.more_flags, ENT_MORE_FLAG.HIT_GROUND) then
            commonlib.play_sound_at_entity(VANILLA_SOUND.CRITTERS_PENGUIN_JUMP1, ent.uid)
            ent.more_flags = clr_flag(ent.more_flags, ENT_MORE_FLAG.HIT_GROUND)
        end
        if test_flag(ent.more_flags, ENT_MORE_FLAG.HIT_WALL) then
            commonlib.play_sound_at_entity(VANILLA_SOUND.CRITTERS_PENGUIN_JUMP1, ent.uid)
            ent.more_flags = clr_flag(ent.more_flags, ENT_MORE_FLAG.HIT_WALL)
        end
    end
    if ent.overlay ~= nil then
        ent.more_flags = clr_flag(ent.more_flags, ENT_MORE_FLAG.HIT_GROUND)
        ent.more_flags = clr_flag(ent.more_flags, ENT_MORE_FLAG.HIT_WALL)
    end
end

function module.create_critterrat(x, y, l)
    local critterrat = spawn(ENT_TYPE.MONS_CRITTERCRAB, x, y, l, 0, 0)
    critterrat_set(critterrat)
    set_post_statemachine(critterrat, critterrat_update)
end

optionslib.register_entity_spawner("Rat", module.create_critterrat)

return module