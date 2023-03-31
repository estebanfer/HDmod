local module = {}
local celib = require "lib.entities.custom_entities"

local function b(flag) return (1 << (flag-1)) end

ANIM_STATE = {
    IDLE = 0,
    IDLE_ANIM = 1,
    JUMPING = 2,
    SPITTING = 3,
    TURNING = 4,
    WALKING = 5
}
local FRAME_TIME = 4

ANIMATIONS = {
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

    giant_frog_texture_def.texture_path = "res/giant_frog_hd.png"
    giant_frog_texture_id = define_texture(giant_frog_texture_def)
end

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
    ---@param dead_ent Frog
    set_on_kill(ent.uid, function (dead_ent)
        local x, y, l = get_position(dead_ent.uid)
        spawn_frog_rubble(x, y, l, 2)
        spawn_blood(x, y, l, 4)
        if math.random(1, 3) == 1 then
            spawn(ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.2-0.1, prng:random_float(PRNG_CLASS.PARTICLES)*0.1+0.1)
        else
            spawn(ENT_TYPE.ITEM_EMERALD, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.2-0.1, prng:random_float(PRNG_CLASS.PARTICLES)*0.1+0.1)
        end
    end)
    return {
        frogs_inside = 5,
        script_jumped = false,
        animation_state = ANIM_STATE.IDLE,
        animation_timer = 60,
        action_timer = math.random(100, 200)
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
end

local function giant_frog_spit(ent)
    local facing_left = test_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    local x, y, l = get_position(ent.uid)
    --ent.animation_frame = 0
    local vx = facing_left and -0.120 or 0.120
    local spawned = get_entity(spawn(ENT_TYPE.MONS_FROG, x+vx, y, l, vx, 0.07+math.random()*0.03))
    spawned.last_owner_uid = ent.uid
    if facing_left then
        spawned.flags = set_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    else
        spawned.flags = clr_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    end
    ent.idle_counter = 0
    commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_FROG_GIANT_OPEN, ent.uid)
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
                c_data.animation_timer = math.random(20, 50)
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

    if ent.standing_on_uid ~= -1 and ent.state ~= CHAR_STATE.JUMPING then
        c_data.action_timer = c_data.action_timer - 1
        c_data.script_jumped = false
        if c_data.action_timer < 1 and distance(ent.uid, ent.chased_target_uid) <= 6 then
            if c_data.animation_state == ANIM_STATE.IDLE then
                face_target(ent.uid, ent.chased_target_uid)
                local time
                if c_data.frogs_inside == 0 or math.random(2) == 1 then
                    if filter_entities(get_entities_overlapping_hitbox(0, MASK.FLOOR, get_hitbox(ent.uid, 0, 0, 0.8), ent.layer), filter_solids)[1] then
                        ent.move_state = 1
                        time = math.random(50, 100)
                        set_animation(c_data, ANIM_STATE.WALKING)
                    else
                        set_animation(c_data, ANIM_STATE.JUMPING)
                        time = math.random(100, 200)
                    end
                else
                    giant_frog_spit(ent)
                    c_data.frogs_inside = c_data.frogs_inside - 1
                    set_animation(c_data, ANIM_STATE.SPITTING)
                    time = 200
                end
                ent.animation_frame = get_animation_frame(c_data.animation_state, c_data.animation_timer)
                c_data.action_timer = time
            elseif c_data.animation_state == ANIM_STATE.WALKING then
                c_data.animation_state = ANIM_STATE.IDLE
                c_data.animation_timer = math.random(20, 50)
                c_data.action_timer = math.random(100, 200)
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
                    c_data.animation_timer = math.random(20, 50)
                    c_data.action_timer = math.random(100, 200)
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

--[[local function spawn_frog_debug()
    local x, y, l = get_position(players[1].uid)
    celib.set_custom_entity(spawn(ENT_TYPE.MONS_FROG, x+2, y, l, 0, 0), giant_frog_id)
end
register_option_button("spawn_frog", "spawn giant frog", "", spawn_frog_debug)]]

function module.create_giantfrog(grid_x, grid_y, layer)
    celib.spawn_custom_entity(giant_frog_id, grid_x+0.5, grid_y+0.465, layer, 0, 0)
end


return module