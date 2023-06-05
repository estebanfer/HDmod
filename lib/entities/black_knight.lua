local celib = require "lib.entities.custom_entities"

local module = {}

local texture_id
do
    local texture_def = TextureDefinition.new();
    texture_def.width = 640;
    texture_def.height = 512;
    texture_def.tile_width = 128;
    texture_def.tile_height = 128;
    texture_def.texture_path = 'res/black_knight.png';
    texture_id = define_texture(texture_def);
end

local ANIMATION_FRAMES_ENUM = {
    IDLE = 1,
    WALK = 2,
    KO = 3,
    FLUNG1 = 4,
    FLUNG2 = 5,
    FLUNG3 = 6,
    FLUNG4 = 7,
}

local ANIMATION_FRAMES_BASE = {
    { 144 },
    { 145, 146, 147, 148, 149, 150, 151, 152 },
    { 153 },
    { 154 },
    { 155 },
    { 156 },
    { 157 },
}

local ANIMATION_FRAMES_RES = {
    { 0 },
    { 1, 2, 3, 4, 5, 6, 7, 8 },
    { 9 },
    { 10 },
    { 11 },
    { 12 },
    { 13 },
}

local function black_knight_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent:set_texture(texture_id)
    local x, y, l = get_position(uid)
    local shield = get_entity(spawn(ENT_TYPE.ITEM_METAL_SHIELD, x, y, l, 0, 0))

    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_BLACK_KNIGHT;
        hit_ground = true;
        jingle_timer = 40; -- Makes the knights armor jingle when 0
        picked_up = false; -- Used for custom pickup sound
    };

    --remove any item black knight may have
    local held_item = get_entity(ent.holding_uid)
    if held_item ~= nil then
        drop(ent.uid, held_item.uid)
        held_item:destroy()
    end
    --give him his shield
    pick_up(uid, shield.uid)
end
local function black_knight_update(ent)
    -- animation_frame conversion handling
    local break_framesetting
    for frame_state_i, base_frames in ipairs(ANIMATION_FRAMES_BASE) do
        for frame_i, base_frame in ipairs(base_frames) do
            if ent.animation_frame == base_frame then
                ent.animation_frame = ANIMATION_FRAMES_RES[frame_state_i][frame_i]
                break_framesetting = true
                break
            end
        end
        if break_framesetting then break end
    end
    -- clang sound when landing
    if not ent.user_data.hit_ground and ent:can_jump() then
        if not test_flag(ent.flags, ENT_FLAG.DEAD) then
            local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
            audio:set_volume(0.65)
            audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, prng:random_int(2, 3, PRNG_CLASS.FX))
            audio:set_pitch(prng:random_int(60, 80, PRNG_CLASS.FX)/100)
        end
        -- Camera Shake
        -- Make sure a player is close enough first
        for _, v in ipairs(get_entities_by(0, MASK.PLAYER, ent.layer)) do
            local player = get_entity(v)
            if player ~= nil and not test_flag(ent.flags, ENT_FLAG.DEAD) then
                local dist = distance(ent.uid, player.uid)
                if dist <= 13 then
                    commonlib.shake_camera(10, 10, 4, 4, 4, false)
                    -- Landing SFX
                    local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_LAND, ent.uid, 1)
                    audio:set_volume(0.3)
                    break
                end
            end
        end
        ent.user_data.hit_ground = true
    end
    if ent.standing_on_uid == -1 then ent.user_data.hit_ground = false end
    -- more clangs when picking him up
    --[[ nah nvm
    if ent.overlay ~= nil then
        if not ent.user_data.picked_up then
            local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
            audio:set_volume(0.4)
            audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, prng:random_int(2, 3, PRNG_CLASS.FX))
            audio:set_pitch(prng:random_int(70, 90, PRNG_CLASS.FX)/100)
        end
        ent.user_data.picked_up = true
    end
    if ent.overlay == nil then
        ent.user_data.picked_up = false
    end
    ]]
    -- Jingle jangle jingle
    if ent:can_jump() and ent.movex ~= 0 then
        ent.user_data.jingle_timer = ent.user_data.jingle_timer - 1
        if ent.move_state == 6 then ent.user_data.jingle_timer = ent.user_data.jingle_timer - 1 end
        if ent.user_data.jingle_timer <= 0 then
            ent.user_data.jingle_timer = prng:random_int(30, 40, PRNG_CLASS.AI)
            local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
            audio:set_volume(0.4)
            audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, prng:random_int(2, 3, PRNG_CLASS.FX))
            audio:set_pitch(prng:random_int(90, 120, PRNG_CLASS.FX)/100)
        end
    end
    if test_flag(ent.flags, ENT_FLAG.DEAD) or ent.stun_timer ~= 0 then return end
    --wait for player to get near
    for _, v in ipairs(get_entities_by(0, MASK.PLAYER, ent.layer)) do
        local player = get_entity(v)
        if player ~= nil then
            local dist = distance(ent.uid, player.uid)
            if dist <= 5 then
                ent.chased_target_uid = player.uid
                ent.move_state = 6
                break
            end
        end
    end
    --give the tikiman a speedbost to his movement (as fast as shoppie)
    if ent.movex ~= 0 then
        ent.x = ent.x + 0.025*ent.movex
    end
    if ent.move_state == 6 then
        --aggro shoppie behavior from scratch
        for _, v in ipairs(get_entities_by(0, MASK.PLAYER, ent.layer)) do
            local char = get_entity(v)
            if char == nil then return end
            -- Make sure the character is alive before targetting
            if test_flag(char.flags, ENT_FLAG.DEAD) then return end
            local px, py, pl = get_position(char.uid)
            local x, y, l = get_position(ent.uid)
            -- Jump when player is above us
            if py > y and ent:can_jump() then
                ent.velocityy = 0.23
                -- SFX
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
                audio:set_volume(0.33)
                audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, prng:random_int(2, 3, PRNG_CLASS.FX))
                audio:set_pitch(prng:random_int(105, 130, PRNG_CLASS.FX)/100)
            end
            if math.abs(px-x) > 5 then
                --face the player when out of range
                local held_item = get_entity(ent.holding_uid)
                if held_item ~= nil then
                    held_item.flags = set_flag(held_item.flags, ENT_FLAG.FACING_LEFT)
                end
                ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
                ent.movex = -1
                if px > x then
                    if held_item ~= nil then
                        held_item.flags = clr_flag(held_item.flags, ENT_FLAG.FACING_LEFT)
                    end
                    ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
                    ent.movex = 1
                end
            end
            -- Flip when hitting a wall
            local held_item = get_entity(ent.holding_uid)
            local hb = get_hitbox(ent.uid, 0, 0.19, 0)
            for _, v in ipairs(get_entities_overlapping_hitbox({0}, MASK.FLOOR | MASK.ACTIVEFLOOR, hb, ent.layer)) do
                local w = get_entity(v)
                if test_flag(w.flags, ENT_FLAG.SOLID) and test_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS) then
                    if held_item ~= nil then
                        held_item.flags = set_flag(held_item.flags, ENT_FLAG.FACING_LEFT)
                    end
                    ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
                    ent.movex = -1
                    ent.x = ent.x-0.1                  
                end
            end
            local hb = get_hitbox(ent.uid, 0, -0.19, 0)
            for _, v in ipairs(get_entities_overlapping_hitbox({0}, MASK.FLOOR | MASK.ACTIVEFLOOR, hb, ent.layer)) do
                local w = get_entity(v)
                if test_flag(w.flags, ENT_FLAG.SOLID) and test_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS) then
                    if held_item ~= nil then
                        held_item.flags = clr_flag(held_item.flags, ENT_FLAG.FACING_LEFT)
                    end
                    ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
                    ent.movex = 1
                    ent.x = ent.x+0.1                  
                end
            end
            --pick up any shields
            for _, v in ipairs(get_entities_by_type(ENT_TYPE.ITEM_METAL_SHIELD)) do
                local shield = get_entity(v)
                if shield.overlay == nil then
                    if shield:overlaps_with(ent) and ent.holding_uid == -1 then
                        pick_up(ent.uid, v)
                    end
                end
            end
        end
        if ent.velocityx == 0 then
            ent.velocityx = 1*ent.movex
        end
    end

    --kill any webs the entity may run into
    for _, v in ipairs(get_entities_by_type(ENT_TYPE.ITEM_WEB)) do
        local web = get_entity(v)
        local wx, wy, wl = get_position(v)
        if web:overlaps_with(ent) then
            generate_world_particles(PARTICLEEMITTER.HITEFFECT_STARS_SMALL, v)
            for i=1, 3, 1 do
                commonlib.play_sound_at_entity(VANILLA_SOUND.TRAPS_STICKYTRAP_HIT, v, 0.25)
                local leaf = get_entity(spawn(ENT_TYPE.ITEM_LEAF, wx+(i-1)/3, wy, wl, 0, 0))
                leaf.width = 0.75
                leaf.height = 0.75
                leaf.animation_frame = 47
                leaf.fade_away_trigger = true
                web:destroy()
            end
        end
    end
end
local function burst_out_of_mantrap(ent, collision_ent)
    if collision_ent.type.id == ENT_TYPE.MONS_MANTRAP and not test_flag(ent.flags, ENT_FLAG.DEAD) then
        if collision_ent.stun_timer == 0 and collision_ent.move_state ~= 6 then
            local cx, cy, cl = get_position(collision_ent.uid)
            collision_ent.eaten_uid = ent.uid
            collision_ent.move_state = 6
            commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_MANTRAP_BITE, ent.uid)
            drop(ent.uid, ent.holding_uid)
            ent.flags = set_flag(ent.flags, ENT_FLAG.INVISIBLE)
            ent.flags = set_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
            ent.x = cx
            ent.y = cy
            attach_entity(collision_ent.uid, ent.uid)
            set_on_destroy(collision_ent.uid, function()
                ent.flags = clr_flag(ent.flags, ENT_FLAG.INVISIBLE)
                ent.flags = clr_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
                ent.move_state = 6
            end)
        end
        return true
    end
end
local function black_knight_death(ent, damage_dealer, damage_amount, velocityx, velocityy, stun_amount, iframes)
    -- We'll always do a little damgage sound effect when he gets hurt
    if not test_flag(ent.flags, ENT_FLAG.DEAD) then
        local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
        audio:set_volume(0.65)
        audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, prng:random_int(2, 3, PRNG_CLASS.FX))
        audio:set_pitch(prng:random_int(90, 110, PRNG_CLASS.FX)/100)
    end
    if ent.health - damage_amount <= 0 then
        --set it temporarily to tikiman makes no sound on death then set it back 1 frame later
        --technically its possible that if a tikiman and black knight die on the same frame, tikiman makes no sound, but he should never be near a black knight anyways
        local tikiman_db = get_type(ENT_TYPE.MONS_TIKIMAN)
        local sound_killed_by_player = tikiman_db.sound_killed_by_player
        local sound_killed_by_other = tikiman_db.sound_killed_by_other
        tikiman_db.sound_killed_by_player = -1
        tikiman_db.sound_killed_by_other = -1
        set_timeout(function()
            tikiman_db.sound_killed_by_player = sound_killed_by_player
            tikiman_db.sound_killed_by_other = sound_killed_by_other
        end, 1)
        --play a death sound, sounds weird otherwise
        local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.SHARED_DAMAGED, ent.uid)
        audio:set_volume(1)
        audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, 1)
    end
end

function module.create_black_knight(x, y, l)
    local black_knight = spawn(ENT_TYPE.MONS_TIKIMAN, x, y, l, 0, 0)
    black_knight_set(black_knight)
    set_post_statemachine(black_knight, black_knight_update)
    set_on_damage(black_knight, black_knight_death)
    set_pre_collision2(black_knight, burst_out_of_mantrap)
end
optionslib.register_entity_spawner("Black knight", module.create_black_knight)

return module