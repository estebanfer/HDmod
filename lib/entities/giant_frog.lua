local celib = require "custom_entities"
local logger = require "logger"

--giant frogs spit only 5 frogs and then only jump (?)
---@param ent Frog
local function giant_frog_set(ent)
    ent.health = 10
    ent.hitboxx, ent.hitboxy = 0.640, 0.700
    ent.width, ent.height = 2.0, 2.0
    ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    return {
        spitting = false,
        script_jumped = false
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

---comment
---@param ent Monster
---@param c_data any
local function giant_frog_update(ent, c_data)
    if ent.standing_on_uid ~= -1 and ent.state ~= CHAR_STATE.JUMPING then
        c_data.script_jumped = false
        if ent.jump_timer == 0 then
            face_target(ent.uid, ent.chased_target_uid)
            if math.random(2) == 1 then
                giant_frog_jump(ent)
            else
                giant_frog_spit(ent)
                c_data.spitting = true
            end
            local time = math.random(180, 255)
            ent.jump_timer = time
            messpect(time)
            c_data.script_jumped = true
        else
            if c_data.spitting then
                --ent.animation_frame = math.floor(ent.idle_counter / 2)
                if ent.idle_counter > 8 then
                    c_data.spitting = false
                end
            end
        end
    elseif not c_data.script_jumped then
        ent.velocityx = math.min(math.abs(ent.velocityx), math.abs(0.035)) * (ent.velocityx > 0 and 1 or -1)
        ent.velocityy = math.min(ent.velocityy, 0)
    end
    logger.log_text_uid(tostring(c_data.script_jumped), ent.uid)
    logger.log_text_uid(tostring(c_data.spitting), ent.uid)
    logger.log_text_uid(tostring(ent.jump_timer), ent.uid)
end

local giant_frog_id = celib.new_custom_entity(giant_frog_set, giant_frog_update, nil, ENT_TYPE, celib.UPDATE_TYPE.POST_STATEMACHINE)

local function spawn_frog()
    local x, y, l = get_position(players[1].uid)
    celib.set_custom_entity(spawn(ENT_TYPE.MONS_FROG, x+2, y, l, 0, 0), giant_frog_id)
end

register_option_button("spawn_frog", "spawn g frog", "", spawn_frog)