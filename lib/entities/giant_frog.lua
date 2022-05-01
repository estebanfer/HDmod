local celib = require "custom_entities"
local logger = require "logger"

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

    giant_frog_texture_def.texture_path = "giant_frog.png"
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

--giant frogs spit only 5 frogs and then only jump (?)
---@param ent Frog
local function giant_frog_set(ent)
    ent.health = 10
    ent.hitboxx, ent.hitboxy = 0.640, 0.700
    ent.offsety = -0.2
    ent.width, ent.height = 2.0, 2.0
    ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    ent:set_texture(giant_frog_texture_id)
    return {
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
    local spawned = get_entity(spawn(ENT_TYPE.MONS_FROG, x+vx, y+0.1, l, vx, 0.1025))
    spawned.last_owner_uid = ent.uid
    if facing_left then
        spawned.flags = set_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    else
        spawned.flags = clr_flag(spawned.flags, ENT_FLAG.FACING_LEFT)
    end
    ent.idle_counter = 0
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
    ent.pause = true
    if ent.standing_on_uid ~= -1 and ent.state ~= CHAR_STATE.JUMPING then
        c_data.action_timer = c_data.action_timer - 1
        c_data.script_jumped = false
        if c_data.action_timer < 1 then
            if c_data.animation_state == ANIM_STATE.IDLE then
                face_target(ent.uid, ent.chased_target_uid)
                local time
                if math.random(2) == 1 then
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
                    set_animation(c_data, ANIM_STATE.SPITTING)
                    time = 200
                end
                ent.animation_frame = get_animation_frame(c_data.animation_state, c_data.animation_timer)
                c_data.action_timer = time
                messpect(time)
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
    logger.log_text_uid(tostring(c_data.script_jumped), ent.uid)
    logger.log_text_uid(tostring(c_data.action_timer), ent.uid)
    logger.log_text_uid(tostring(c_data.animation_state), ent.uid)
end

local giant_frog_id = celib.new_custom_entity(giant_frog_set, giant_frog_update, nil, ENT_TYPE, celib.UPDATE_TYPE.POST_STATEMACHINE)

local function spawn_frog()
    local x, y, l = get_position(players[1].uid)
    celib.set_custom_entity(spawn(ENT_TYPE.MONS_FROG, x+2, y, l, 0, 0), giant_frog_id)
end

register_option_button("spawn_frog", "spawn g frog", "", spawn_frog)