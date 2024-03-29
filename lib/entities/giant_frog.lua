local module = {}
local celib = require "lib.entities.custom_entities"

local function b(flag) return (1 << (flag-1)) end

local ANIM_STATE = {
    IDLE = 0,
    IDLE_ANIM = 1,
    JUMPING = 2,
    SPITTING = 3,
    TURNING = 4,
    WALKING = 5
}
local FRAME_TIME = 4

local ANIMATIONS = {
    [ANIM_STATE.IDLE_ANIM] = {1, 2, 1, frames = 3},
    [ANIM_STATE.SPITTING] = {8, 7, 6, 5, 4, 3, frames = 6},
    [ANIM_STATE.JUMPING] = {11, 10, 9, frames = 3},
    [ANIM_STATE.TURNING] = {15, 14, 13, frames = 3},
    [ANIM_STATE.WALKING] = {23, 22, 21, 20, 19, 18, 17, loop = true, frames = 7},
}

local giant_frog_texture_id
do
    local giant_frog_texture_def = TextureDefinition.new()
    giant_frog_texture_def.width = 1536
    giant_frog_texture_def.height = 1024
    giant_frog_texture_def.tile_width = 256
    giant_frog_texture_def.tile_height = 256

    giant_frog_texture_def.texture_path = "res/giantfrog.png"
    giant_frog_texture_id = define_texture(giant_frog_texture_def)
end
-- frorg sounds :)))
local jump_sound = {
    create_sound('res/sounds/giantfrogjump1.wav'),
    create_sound('res/sounds/giantfrogjump2.wav'),
    create_sound('res/sounds/giantfrogjump3.wav'),
    create_sound('res/sounds/giantfrogjump4.wav'),
    create_sound('res/sounds/giantfrogjump5.wav'),
    create_sound('res/sounds/giantfrogjump6.wav')
}
-- # TODO these sounds aren't working for whatever reason, yet the jump_sounds work perfect
local land_sound = {
    create_sound('res/sounds/giantfrogland1.wav'),
    create_sound('res/sounds/giantfrogland2.wav'),
    create_sound('res/sounds/giantfrogland3.wav'),
    create_sound('res/sounds/giantfrogland4.wav'),
    create_sound('res/sounds/giantfrogland5.wav'),
    create_sound('res/sounds/giantfrogland6.wav')
}

local function gfrog_target_facing(frog_uid, player_uid)
    local x1 = get_position(player_uid)
    local x2 = get_position(frog_uid)
    return x1 - x2 < 0
end

local function set_animation(c_data, anim_state)
    c_data.animation_state = anim_state
    c_data.animation_timer = ANIMATIONS[anim_state].frames*FRAME_TIME
end

local function filter_solids(ent)
    return test_flag(ent.flags, ENT_FLAG.SOLID)
end

local function get_animation_frame(anim_state, anim_timer)
    return ANIMATIONS[anim_state][math.ceil(anim_timer / 4)]
end

local function spawn_frog_rubble(x, y, l, amount)
    for _=1, amount do
        get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.4-0.2, prng:random_float(PRNG_CLASS.PARTICLES)*0.2)).animation_frame = 12
    end
end

local function spawn_blood(x, y, l, amount)
    for _=1, amount do
        spawn(ENT_TYPE.ITEM_BLOOD, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.4-0.2, prng:random_float(PRNG_CLASS.PARTICLES)*0.2)
    end
end

--giant frogs spit only 5 frogs and then only jump (?)
---@param ent Frog
local function giant_frog_set(ent)
    ent.health = 8
    ent.hitboxx, ent.hitboxy = 0.600, 0.750
    ent.offsety = -0.215
    ent.width, ent.height = 2.0, 2.0
    ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    ent:set_texture(giant_frog_texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_GIANT_FROG;
        hit_ground = true; -- For landing SFX
        vyprev = 0; -- Previous velocityy value, used for determining if a fall was great enough for landing effects
    };
    ---@param dead_ent Frog
    set_on_kill(ent.uid, function (dead_ent)
        local x, y, l = get_position(dead_ent.uid)
        spawn_frog_rubble(x, y, l, 2)
        spawn_blood(x, y, l, 4)
        if prng:random_chance(3, PRNG_CLASS.AI) then
            spawn(ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, x, y, l, prng:random_float(PRNG_CLASS.AI)*0.2-0.1, prng:random_float(PRNG_CLASS.AI)*0.1+0.1)
        else
            spawn(ENT_TYPE.ITEM_EMERALD, x, y, l, prng:random_float(PRNG_CLASS.AI)*0.2-0.1, prng:random_float(PRNG_CLASS.AI)*0.1+0.1)
        end
    end)
    return {
        frogs_inside = 5,
        script_jumped = false,
        animation_state = ANIM_STATE.IDLE,
        animation_timer = 60,
        action_timer = prng:random_int(100, 200, PRNG_CLASS.AI)
    }
end

local function face_target(mons_uid, target_uid)
    local mx = get_position(mons_uid)
    local tx = get_position(target_uid)
    if tx-mx < 0 then
        set_entity_flags(mons_uid, set_flag(get_entity_flags(mons_uid), ENT_FLAG.FACING_LEFT))
    else
        set_entity_flags(mons_uid, clr_flag(get_entity_flags(mons_uid), ENT_FLAG.FACING_LEFT))
    end
end

local function giant_frog_jump(ent)
    local vel_x = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -0.0525 or 0.0525
    ent.velocityx = vel_x
    ent.velocityy = 0.175
    -- Jump SFX
    --[[
    local audio = commonlib.play_vanilla_sound(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_JUMP, ent.uid, 1, false)
    audio:set_volume(1)
    ]]
    commonlib.play_custom_sound(jump_sound[prng:random_index(#jump_sound, PRNG_CLASS.FX)], ent.uid, 0.5, false)
end

local function giant_frog_spit(ent)
    local facing_left = test_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    local x, y, l = get_position(ent.uid)
    --ent.animation_frame = 0
    local vx = facing_left and -0.120 or 0.120
    local spawned = get_entity(spawn(ENT_TYPE.MONS_FROG, x+vx, y, l, vx, 0.07+prng:random_float(PRNG_CLASS.AI)*0.03))
    spawned.last_owner_uid = ent.uid
    if facing_left then
        spawned.flags = set_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    else
        spawned.flags = clr_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    end
    ent.idle_counter = 0
    commonlib.play_vanilla_sound(VANILLA_SOUND.ENEMIES_FROG_GIANT_OPEN, ent.uid, 1, false)
end

---@param ent Frog
local function update_giant_frog_animation(ent, c_data)
    if c_data.animation_state < ANIM_STATE.JUMPING and
    gfrog_target_facing(ent.uid, ent.chased_target_uid) ~= test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
        set_animation(c_data, ANIM_STATE.TURNING)
        c_data.action_timer = c_data.action_timer + 15
    end
    if c_data.animation_state == ANIM_STATE.IDLE then
        ent.animation_frame = 0
        if c_data.animation_timer == 0 then
            set_animation(c_data, ANIM_STATE.IDLE_ANIM)
        end
    else
        if c_data.animation_timer == 0 then
            if ANIMATIONS[c_data.animation_state].loop then
                c_data.animation_timer = ANIMATIONS[c_data.animation_state].frames*FRAME_TIME
                ent.animation_frame = get_animation_frame(c_data.animation_state, c_data.animation_timer)
            else
                ent.animation_frame = 0
                if c_data.animation_state == ANIM_STATE.JUMPING then
                    giant_frog_jump(ent)
                    c_data.script_jumped = true
                    ent.animation_frame = 12
                elseif c_data.animation_state == ANIM_STATE.TURNING then
                    ent.flags = ent.flags ~ b(ENT_FLAG.FACING_LEFT)
                end
                c_data.animation_state = ANIM_STATE.IDLE
                c_data.animation_timer = prng:random_int(20, 50, PRNG_CLASS.AI)
            end
        else
            ent.animation_frame = get_animation_frame(c_data.animation_state, c_data.animation_timer)
        end
    end
    c_data.animation_timer = c_data.animation_timer - 1
end
---comment
---@param ent Frog
---@param c_data any
local function giant_frog_update(ent, c_data)
    ent.jump_timer = 255
    if ent.frozen_timer > 0 then return end

    -- Landing SFX
    if not ent.user_data.hit_ground and ent:can_jump() then
        -- Make sure a player is close enough first
        for _, v in ipairs(get_entities_by(0, MASK.PLAYER, ent.layer)) do
            local player = get_entity(v)
            if player ~= nil and not test_flag(ent.flags, ENT_FLAG.DEAD) and ent.user_data.vyprev < -0.04 then
                local dist = distance(ent.uid, player.uid)
                if dist <= 13 then
                    commonlib.shake_camera(10, 10, 6, 6, 6, false)
                    -- Landing SFX
                    local audio = commonlib.play_vanilla_sound(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_LAND, ent.uid, 1, false)
                    break
                end
            end
        end
        ent.user_data.hit_ground = true
    end
    ent.user_data.vyprev = ent.velocityy
    if ent.standing_on_uid == -1 then ent.user_data.hit_ground = false end

    if ent.standing_on_uid ~= -1 and ent.state ~= CHAR_STATE.JUMPING then
        c_data.action_timer = c_data.action_timer - 1
        c_data.script_jumped = false
        if c_data.action_timer < 1 and distance(ent.uid, ent.chased_target_uid) <= 6 then
            if c_data.animation_state == ANIM_STATE.IDLE then
                face_target(ent.uid, ent.chased_target_uid)
                local time
                if c_data.frogs_inside == 0 or prng:random_chance(2, PRNG_CLASS.AI) then
                    if filter_entities(get_entities_overlapping_hitbox(0, MASK.FLOOR, get_hitbox(ent.uid, 0, 0, 0.8), ent.layer), filter_solids)[1] then
                        ent.move_state = 1
                        time = prng:random_int(50, 100, PRNG_CLASS.AI)
                        set_animation(c_data, ANIM_STATE.WALKING)
                    else
                        set_animation(c_data, ANIM_STATE.JUMPING)
                        time = prng:random_int(100, 200, PRNG_CLASS.AI)
                    end
                else
                    set_timeout(function()
                        -- Slight delay to the spawning of the frog so the animation syncs up better
                        if ent ~= nil then
                            giant_frog_spit(ent)                         
                        end
                    end, 8)
                    c_data.frogs_inside = c_data.frogs_inside - 1
                    set_animation(c_data, ANIM_STATE.SPITTING)
                    time = 200   
                end
                ent.animation_frame = get_animation_frame(c_data.animation_state, c_data.animation_timer)
                c_data.action_timer = time
            elseif c_data.animation_state == ANIM_STATE.WALKING then
                c_data.animation_state = ANIM_STATE.IDLE
                c_data.animation_timer = prng:random_int(20, 50, PRNG_CLASS.AI)
                c_data.action_timer = prng:random_int(100, 200, PRNG_CLASS.AI)
            else
                update_giant_frog_animation(ent, c_data)
            end
        else
            if c_data.animation_state == ANIM_STATE.WALKING then
                if filter_entities(get_entities_overlapping_hitbox(0, MASK.FLOOR, get_hitbox(ent.uid, 0, 0, 0.8), ent.layer), filter_solids)[1] then
                    ent.move_state = 1
                    local vel_x = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -0.05 or 0.05
                    if filter_entities(get_entities_overlapping_hitbox(0, MASK.FLOOR, get_hitbox(ent.uid, 0, vel_x), ent.layer), filter_solids)[1] then
                        vel_x = vel_x * -1
                        ent.flags = ent.flags ~ b(ENT_FLAG.FACING_LEFT)
                    end
                    ent.velocityx = vel_x
                else
                    c_data.animation_state = ANIM_STATE.IDLE
                    c_data.animation_timer = prng:random_int(20, 50, PRNG_CLASS.AI)
                    c_data.action_timer = prng:random_int(100, 200, PRNG_CLASS.AI)
                end
            end
            update_giant_frog_animation(ent, c_data)
        end
    elseif not c_data.script_jumped then
        ent.velocityx = math.min(math.abs(ent.velocityx), math.abs(0.035)) * (ent.velocityx > 0 and 1 or -1)
        ent.velocityy = math.min(ent.velocityy, 0)
        ent.animation_frame = 0
    else
        ent.animation_frame = 12
    end
end

local giant_frog_id = celib.new_custom_entity(giant_frog_set, giant_frog_update, nil, ENT_TYPE.MONS_FROG, celib.UPDATE_TYPE.POST_STATEMACHINE)

function module.create_giantfrog(grid_x, grid_y, layer)
    celib.spawn_custom_entity(giant_frog_id, grid_x+0.5, grid_y+0.465, layer, 0, 0)
end

optionslib.register_entity_spawner("Giant frog", module.create_giantfrog)

return module