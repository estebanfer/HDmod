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
    -- Increase animation timer
    ent.user_data.animation_timer = ent.user_data.animation_timer + 1
    --- Animate the entity and reset the timer
    if ent.user_data.animation_timer >= ent.user_data.animation_speed then
        ent.user_data.animation_timer = 1
        -- Advance the animation
        ent.user_data.animation_frame = ent.user_data.animation_frame + 1
        -- Loop if the animation has reached the end
        if ent.user_data.animation_frame > ent.user_data.animation_end then
            ent.user_data.animation_frame = ent.user_data.animation_start
        end
    end
    -- Change the actual animation frame
    ent.animation_frame = ent.user_data.animation_frame
    -- Update the volume and panning of the mushy alien noises
    if ent.user_data.alien_sound ~= nil then
        commonlib.update_sound_volume(ent.user_data.alien_sound, ent.uid, 0.75)
    end
    -- Stop the base entity from attacking
    ent.next_attack_timer = 5
    -- Our own attack timer and spawning system
    if ent.lock_input_timer == 0 and ent.frozen_timer == 0 and ent.stun_timer == 0 then
        -- Ensure the player is in range first
        if players[1] ~= nil then
            if distance(players[1].uid, ent.uid) < 8.5 then
                ent.user_data.attack_timer = ent.user_data.attack_timer - 1
                -- Update the animation speed to reflect this
                ent.user_data.animation_speed = 5
            else
                ent.user_data.animation_speed = 7
            end
        end
    end
    -- Perform an attack
    if ent.user_data.attack_timer <= 0 then
        -- Spawn the shot
        local x, y, l = get_position(ent.uid)
        local lor = 1
        if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then lor = -1 end
        local atk = get_entity(spawn(ENT_TYPE.ITEM_SCEPTER_ANUBISSHOT, x+(0.5*lor), y+0.15, l, 0, 0))
        atk.last_owner_uid = ent.uid
        -- Reset the attack timer
        ent.user_data.attack_timer = ent.user_data.attack_timer_base
    end
end

local function alienlord_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent.move_state = 5
    -- Set health
    ent.health = 10
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(ent.x, ent.y)
	local _subchunk_id = locatelib.get_levelroom_at(roomx, roomy)
    if _subchunk_id == roomdeflib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_LEFT then
        ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_ALIENLORD;
        alien_sound = nil; -- The alien queen in vanilla S2 makes these gross squishy noises, I think they'd fit this entity as well

        -- ANIMATION
        animation_timer = 1;
        animation_speed = 5; -- Number of game frames before the animation_frame is increased
        animation_start = 0; -- What frame the animation goes back to before looping
        animation_end = 3; -- When the animation is this number, it will loop back to the start instead of increasing animation_frame
        animation_frame = 0; -- We need our own animation frame because the actual animation frame keeps getting changed by the statemachine

        -- ATTACK
        attack_timer = 150;
        attack_timer_base = 150; -- Not sure what the HD value is but we can just change it in the future
    };
    ent.animation_frame = ent.user_data.animation_start
    -- Play the squishy alien noises
    ent.user_data.alien_sound = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_ALIEN_QUEEN_LOOP, ent.uid, 0.75)
    -- Change the texture to our custom one
    set_timeout(function()
        ent:set_texture(alienlord_texture_id)
    end, 2)
    -- Stop the gross alien slime noises before death and move this entity out of bounds so we don't get the scepter drop
    ent:set_pre_kill(function()
        if ent.user_data.alien_sound ~= nil then
            ent.user_data.alien_sound:stop()
        end
        local x, y, l = get_position(ent.uid)
        -- Gibs and blood
        for _=1, 8 do
            local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x+math.random(-10, 10)/100, y+math.random(-10, 10)/100, l, math.random(-15, 15)/100, math.random(10, 15)/100))
            rubble.animation_frame = 42
        end
        for _=1, 10 do
            local rubble = get_entity(spawn(ENT_TYPE.ITEM_BLOOD, x+math.random(-10, 10)/100, y+math.random(-10, 10)/100, l, math.random(-15, 15)/100, math.random(10, 15)/100))
        end
        -- Gems
       spawn(ENT_TYPE.ITEM_RUBY, x, y, l, math.random(-15, 15)/100, math.random(10, 15)/100)
       spawn(ENT_TYPE.ITEM_SAPPHIRE, x, y, l, math.random(-15, 15)/100, math.random(10, 15)/100)
       -- Jetpack
       spawn(ENT_TYPE.ITEM_JETPACK, x, y-0.25, l, 0, 0)
        -- Sfx
        commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_KILLED_ENEMY, ent.uid, 1)
        -- Move base entity out of bounds
        ent.x = -900
    end)
    -- We should stop them too if this entity ever gets unloaded from memory, like if you ever restart near it
    ent:set_pre_dtor(function()
        if ent.user_data.alien_sound ~= nil then
            ent.user_data.alien_sound:stop()
        end
    end)
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
    local alienlord = spawn(ENT_TYPE.MONS_ANUBIS, x+.5, y-.65, l, 0, 0)
    alienlord_set(alienlord)
    set_post_statemachine(alienlord, alienlord_update)
    return alienlord
end

register_option_button("spawn_alienlord", "spawn_alienlord", 'spawn_alienlord', function()
    local x, y, l = get_position(players[1].uid)
    module.create_alienlord(x-5, y, l)
end)

return module