-- local celib = require "lib.entities.custom_entities"
local commonlib = require 'lib.common'

local module = {}

replace_drop(DROP.QUILLBACK_BOMBBAG, ENT_TYPE.ITEM_PICKUP_BOMBBOX)
replace_drop(DROP.QUILLBACK_COOKEDTURKEY, ENT_TYPE.FX_SHADOW)

local HELL_MINIBOSS_STATE = {
    WALK_TO_PLAYER = 20,
    THROW_BOMB = 21,
    JUMP = 22,
    TURNING = 23,
    JUMP_CUTSCENE = 24,
}
local HELL_MINIBOSS_AI_TIMER = {
    COOLDOWN_TIMER = 180,
    WALK_PAUSE_TIMER = 80
}
local horsehead_texture_id
local oxface_texture_id
do
    local horsehead_texture_def = TextureDefinition.new()
    horsehead_texture_def.width = 2048
    horsehead_texture_def.height = 1024
    horsehead_texture_def.tile_width = 256
    horsehead_texture_def.tile_height = 256
    horsehead_texture_def.texture_path = 'res/horsehead.png'
    horsehead_texture_id = define_texture(horsehead_texture_def)
    
    local oxface_texture_def = TextureDefinition.new()
    oxface_texture_def.width = 2048
    oxface_texture_def.height = 1024
    oxface_texture_def.tile_width = 256
    oxface_texture_def.tile_height = 256
    oxface_texture_def.texture_path = 'res/oxface.png'
    oxface_texture_id = define_texture(oxface_texture_def)
end

local function hell_miniboss_set(uid, texture_id)
    local ent = get_entity(uid)
    ent:set_texture(texture_id)
    local x, y, l = get_position(uid)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_HELL_MINIBOSS;
    };
    --repurposed variables
    ent.move_state = HELL_MINIBOSS_STATE.WALK_TO_PLAYER --logic
    ent.price = 0 --cooldown so whip doesnt hit multiple times
    ent.cooldown_timer = HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER --sequences the jump and bomb attack
    ent.walk_pause_timer = HELL_MINIBOSS_AI_TIMER.WALK_PAUSE_TIMER --same as vanilla
    ent.chatting_to_uid = 0 --used for whether or not entity is walking. 0 not walking 1 walking
end
local function hell_miniboss_update(ent)
    if players[1] == nil then return end
    ent.lock_input_timer = 1
    --move_state 2
    --ent.chased_target_uid = players[1].uid
    --this should be the jump state.. it gives the entity those intense quillback stomp SFX and looks + feels awesome .
    --manage timers
    --price (for whip cooldown)
    if ent.price > 0 then
        ent.price = ent.price - 1
    end
    --statemachine
    if ent.move_state == HELL_MINIBOSS_STATE.WALK_TO_PLAYER then --WALK TO PLAYER
        --move based on walk_pause_timer and chatting_to_uid
        ent.walk_pause_timer = ent.walk_pause_timer - 1
        if ent.walk_pause_timer == 0 then
            local x, y, l = get_position(ent.uid)
            local px, py, pl = get_position(players[1].uid)
            ent.walk_pause_timer = HELL_MINIBOSS_AI_TIMER.WALK_PAUSE_TIMER + math.random(-10, 20) --random deviation so they look less robotic
            if ent.chatting_to_uid == 1 then
                ent.chatting_to_uid = 0
            else
                ent.chatting_to_uid = 1
            end
            --if the player is close enough, do an attack
            if math.abs(px-x) <= 4 then
                ent.move_state = HELL_MINIBOSS_STATE.JUMP
                ent.state = 12
                if math.random(3) == 1 then
                    ent.move_state = HELL_MINIBOSS_STATE.THROW_BOMB
                end
                ent.cooldown_timer = HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER
            end
            --determine if we should turn around to face the player
            if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and px > x then
                ent.move_state = HELL_MINIBOSS_STATE.TURNING
                ent.cooldown_timer = 13
                ent.animation_frame = 14
                ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
            end
            if not test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and px < x then
                ent.move_state = HELL_MINIBOSS_STATE.TURNING
                ent.cooldown_timer = 13
                ent.animation_frame = 14
                ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
            end
        end
        local move_dir = 1
        if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
            move_dir = -1
        end
        ent.velocityx = (0.035*ent.chatting_to_uid)*move_dir
    elseif ent.move_state == HELL_MINIBOSS_STATE.TURNING then --TURNING
        ent.cooldown_timer = ent.cooldown_timer - 1
        if ent.cooldown_timer < 8 then
            ent.animation_frame = 14
        else
            ent.animation_frame = 15
        end
        if ent.cooldown_timer == 0 then
            ent.move_state = HELL_MINIBOSS_STATE.WALK_TO_PLAYER
            ent.cooldown_timer = HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER
        end
    elseif ent.move_state == HELL_MINIBOSS_STATE.JUMP then --JUMP
        ent.chased_target_uid = -1
        local move_dir = 1
        if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
            move_dir = -1
        end
        if ent.cooldown_timer == HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 then
            ent.velocityy = 0.25
            commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_JUMP, ent.uid)
        end
        if ent.cooldown_timer < HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 then
            ent.velocityx = (0.075)*move_dir
        end
        --animations
        if ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-5 then
            ent.animation_frame = 9
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-5 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-10 then
            ent.animation_frame = 10
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-10 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 then
            ent.animation_frame = 11
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-20 then
            ent.animation_frame = 12
        end
        ent.cooldown_timer = ent.cooldown_timer - 1
        if (ent.standing_on_uid ~= -1 and ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-20) then
            ent.move_state = HELL_MINIBOSS_STATE.WALK_TO_PLAYER
            ent.cooldown_timer = HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER
            ent.chatting_to_uid = 0
            ent.walk_pause_timer = 25 + math.random(-10, 5)
            commonlib.shake_camera(10, 10, 4, 4, 4, false)
            commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_STOMP, ent.uid)
        end
    elseif ent.move_state == HELL_MINIBOSS_STATE.THROW_BOMB then --THROW BOMB
        ent.cooldown_timer = ent.cooldown_timer - 1
        if ent.cooldown_timer == HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-16 then
            local x, y, l = get_position(ent.uid)
            local move_dir = 1
            if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
                move_dir = -1
            end
            spawn(ENT_TYPE.ITEM_BOMB, x+0.7*move_dir, y-0.1, l, 0.15*move_dir, 0.004)
            commonlib.play_sound_at_entity(VANILLA_SOUND.PLAYER_TOSS_ROPE, ent.uid)
        end
        if ent.cooldown_timer == HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-35 then
            ent.move_state = HELL_MINIBOSS_STATE.WALK_TO_PLAYER
            ent.cooldown_timer = HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER
            ent.chatting_to_uid = 0
            ent.walk_pause_timer = 45 + math.random(-10, 10)
        end
        --animations
        if ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-5 then
            ent.animation_frame = 17
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-5 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-10 then
            ent.animation_frame = 18
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-10 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 then
            ent.animation_frame = 19
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-15 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-20 then
            ent.animation_frame = 20
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-20 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-25 then
            ent.animation_frame = 21
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-25 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-30 then
            ent.animation_frame = 22
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-30 and ent.cooldown_timer > HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-35 then
            ent.animation_frame = 23
        elseif ent.cooldown_timer <= HELL_MINIBOSS_AI_TIMER.COOLDOWN_TIMER-35 then
            ent.animation_frame = 24
        else
            ent.animation_frame = 0
        end
    end
end
local function take_damage_from_whip(ent, collision_ent)
    if collision_ent.type.id == ENT_TYPE.ITEM_WHIP and ent.price == 0 then
        ent.price = 10
        ent:damage(collision_ent.overlay.uid, 1, 0, 0, 0.075, 10)
    end
end

---@param is_horsehead boolean defaults to horsehead
local function create_hell_miniboss(x, y, l, is_horsehead)
    is_horsehead = is_horsehead or false
    local hell_miniboss = spawn(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, l, 0, 0)
    hell_miniboss_set(hell_miniboss, is_horsehead and horsehead_texture_id or oxface_texture_id)
    set_post_statemachine(hell_miniboss, hell_miniboss_update)
    set_pre_collision2(hell_miniboss, take_damage_from_whip)
end

function module.create_horsehead(x, y, l)
    create_hell_miniboss(x, y, l, true)
end

function module.create_oxface(x, y, l)
    create_hell_miniboss(x, y, l, false)
end

optionslib.register_entity_spawner("Horse Head", module.create_horsehead)
optionslib.register_entity_spawner("Ox Face", module.create_oxface)

return module