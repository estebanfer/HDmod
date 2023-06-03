local roomdeflib = require 'lib.gen.roomdef'
local locatelib = require 'lib.locate'
local module = {}

local alienlord_texture_id
do
    local alienlord_texture_def = TextureDefinition.new()
    alienlord_texture_def.width = 1024
    alienlord_texture_def.height = 512
    alienlord_texture_def.tile_width = 256
    alienlord_texture_def.tile_height = 256
    alienlord_texture_def.texture_path = 'res/alienlord.png'
    alienlord_texture_id = define_texture(alienlord_texture_def)
end
local ANIMATION_INFO = {
    IDLE = {
        start = 0;
        finish = 3;
        speed = 5;
    };
    IDLE_FAST = {
        start = 0;
        finish = 3;
        speed = 7;
    };
    ATTACK = {
        start = 4;
        finish = 6;
        speed = 6;
    };
    CAMERA_STUN = {
        start = 7;
        finish = 7;
        speed = 1;
    };
}
local function alienlord_update(ent)
    ent.x, ent.y = ent.spawn_x, ent.spawn_y
    --- ANIMATION
    -- Increase animation timer
    ent.user_data.animation_timer = ent.user_data.animation_timer + 1
    --- Animate the entity and reset the timer
    if ent.user_data.animation_timer >= ent.user_data.animation_info.speed then
        ent.user_data.animation_timer = 1
        -- Advance the animation
        ent.user_data.animation_frame = ent.user_data.animation_frame + 1
        -- Loop if the animation has reached the end
        if ent.user_data.animation_frame > ent.user_data.animation_info.finish then
            ent.user_data.animation_frame = ent.user_data.animation_info.start
        end
    end
    -- Change the actual animation frame
    ent.animation_frame = ent.user_data.animation_frame
    ---

    -- Stop the base entity from attacking
    ent.next_attack_timer = 5
    -- Our own attack timer and spawning system
    if ent.lock_input_timer == 0 and ent.frozen_timer == 0 and ent.stun_timer == 0 then
        -- Ensure a character is in range first
        local player_in_range = false
        for _, v in ipairs(get_entities_by(0, MASK.PLAYER, ent.layer)) do
            if distance(ent.uid, v) < 8.5 then
                player_in_range = true
            end
        end
        if player_in_range or ent.user_data.attack_timer <= 12 then
            ent.user_data.attack_timer = ent.user_data.attack_timer - 1
            -- Update the animation speed to reflect this
            ent.user_data.animation_info = ANIMATION_INFO.IDLE
        else
            ent.user_data.animation_info = ANIMATION_INFO.IDLE_FAST
        end
    end
    -- Update animation info right before an attack
    if ent.user_data.attack_timer == 12 then
        ent.user_data.animation_info = ANIMATION_INFO.ATTACK
        ent.user_data.animation_timer = 0
        ent.user_data.animation_frame = ent.user_data.animation_info.start
    end
    if ent.user_data.attack_timer < 12 then
        ent.user_data.animation_info = ANIMATION_INFO.ATTACK        
    end
    if ent.user_data.attack_timer == 0 then
        -- Reset the attack timer
        ent.user_data.attack_timer = ent.user_data.attack_timer_base
        -- Perform an attack
        local x, y, l = get_position(ent.uid)
        local lor = 1
        if ent.user_data.facing_left then lor = -1 end
        local atk = get_entity(spawn(ENT_TYPE.ITEM_SCEPTER_ANUBISSHOT, x+(0.5*lor), y+0.15, l, 0, 0))
        atk.last_owner_uid = ent.uid
    end
    -- Camera stun
    if ent.stun_timer > 0 then
        ent.user_data.animation_info = ANIMATION_INFO.CAMERA_STUN
    end
    if ent.user_data.attack_timer <= 0 then

    end
    -- Force the alienlord to face a fixed direction based on if their room template was flipped
    if ent.user_data.facing_left then
        ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    else
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
end

local function alienlord_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    local x, y, l = get_position(ent.uid)
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
        alien_sound = nil; -- Points to an alienqueen entity that we have completely inactive and only use for accurate squishy meat sounds

        facing_left = false; -- Gets set to true if the room template was flipped

        -- ANIMATION
        animation_timer = 1;
        animation_frame = 0;
        animation_info = ANIMATION_INFO.IDLE; -- Info about animation speed, start frame, stop frame

        -- ATTACK
        attack_timer = 50;
        attack_timer_base = 150; -- Not sure what the HD value is but we can just change it in the future
    };
    ent.animation_frame = ent.user_data.animation_info.start
    -- Create an inactive alienqueen that gets removed whenever our active entity dies. We do this for the squishy alien SFX
    ent.user_data.alien_sound = get_entity(spawn(ENT_TYPE.MONS_ALIENQUEEN, x, y, l, 0, 0))
    ent.user_data.alien_sound.flags = set_flag(ent.user_data.alien_sound.flags, ENT_FLAG.INVISIBLE)
    ent.user_data.alien_sound.flags = set_flag(ent.user_data.alien_sound.flags, ENT_FLAG.PASSES_THROUGH_EVERYTHING)
    ent.user_data.alien_sound:set_post_update_state_machine(function(self)
        self.attack_cooldown_timer = 5
    end)
    -- Check if this is a left-facing alienlord
    local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(ent.x, ent.y)
    local _subchunk_id = locatelib.get_levelroom_at(roomx, roomy)
    if _subchunk_id == roomdeflib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_LEFT then
        ent.user_data.facing_left = true
    end
    if _subchunk_id == roomdeflib.HD_SUBCHUNKID.UFO_RIGHTSIDE then
        ent.user_data.facing_left = true
    end
    -- Alienqueen also creates a midbg below her that we need to remove. It's always her uid+3
    set_timeout(function()
        kill_entity(ent.user_data.alien_sound.uid+3, false)
    end, 1)
    -- Change the texture to our custom one
    set_timeout(function()
        ent:set_texture(alienlord_texture_id)
    end, 2)
    -- Effects after death
    ent:set_pre_kill(function()
        -- Remove alienqueen entity from the game
        if ent.user_data.alien_sound ~= nil then
            ent.user_data.alien_sound:destroy()
        end
        -- Gibs and blood
        for _=1, 8 do
            local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE,
                x+prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, y+prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, l,
                prng:random_int(-15, 15, PRNG_CLASS.PARTICLES)/100, prng:random_int(10, 15, PRNG_CLASS.PARTICLES)/100))
            rubble.animation_frame = 42
        end
        for _=1, 10 do
            get_entity(spawn(ENT_TYPE.ITEM_BLOOD,
                x+prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, y+prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, l,
                prng:random_int(-15, 15, PRNG_CLASS.PARTICLES)/100, prng:random_int(10, 15, PRNG_CLASS.PARTICLES)/100))
        end
        -- Gems
        local gems = {ENT_TYPE.ITEM_RUBY, ENT_TYPE.ITEM_SAPPHIRE, ENT_TYPE.ITEM_EMERALD}
        for _=1, 3 do
            spawn(gems[prng:random_index(3, PRNG_CLASS.EXTRA_SPAWNS)], x, y, l,
                prng:random_int(-15, 15, PRNG_CLASS.EXTRA_SPAWNS)/100, prng:random_int(10, 15, PRNG_CLASS.EXTRA_SPAWNS)/100)
        end
        -- Sfx
        commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_KILLED_ENEMY, ent.uid, 1)
        -- Move base entity out of bounds
        ent.x = -900
    end)
end
set_post_entity_spawn(function(ent)
    if state.theme ~= THEME.TEMPLE then
        ent.speed = 0.05
    end
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_SCEPTER_ANUBISSHOT)

function module.create_alienlord(x, y, l)
    local alienlord = spawn(ENT_TYPE.MONS_ANUBIS, x+.5, y-.65, l, 0, 0)
    alienlord_set(alienlord)
    set_post_statemachine(alienlord, alienlord_update)
    return alienlord
end

optionslib.register_entity_spawner("Alien lord", module.create_alienlord)

-- Stop the alienqueen from taking damage from the alienlord's attacks
set_post_entity_spawn(function(self)
    self:set_pre_damage(function(self, other)
        if other.last_owner_uid ~= -1 then
            local attacker = get_entity(other.last_owner_uid)
            if type(attacker.user_data) == "table" then
                if attacker.user_data.ent_type == HD_ENT_TYPE.MONS_ALIENLORD then
                    return true
                end
            end
        end
    end)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_ALIENQUEEN)

return module