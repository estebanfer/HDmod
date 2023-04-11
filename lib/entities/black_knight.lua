local celib = require "lib.entities.custom_entities"

local module = {}

--obviously the custom shield will become a regular one when you leave the level
local black_knight_texture_id
do
    local black_knight_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERS01_0)
    black_knight_texture_def.texture_path = 'res/black_knight.png'
    black_knight_texture_id = define_texture(black_knight_texture_def)
end
local function black_knight_set(uid)
    ---@type Movable
    local ent = get_entity(uid)
    ent:set_texture(black_knight_texture_id)
    local x, y, l = get_position(uid)
    local shield = get_entity(spawn(ENT_TYPE.ITEM_METAL_SHIELD, x, y, l, 0, 0))

    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_BLACK_KNIGHT;
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
    if test_flag(ent.flags, ENT_FLAG.DEAD) or ent.stun_timer ~= 0 then return end
    --wait for player to get near
    for _, player in ipairs(players) do
        if player ~= nil then
            local dist = distance(ent.uid, player.uid)
            if dist <= 9 then
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
        for _, player in ipairs(players) do
            local px, py, pl = get_position(player.uid)
            local x, y, l = get_position(ent.uid)
            if py > y and ent.standing_on_uid ~= -1 then
                ent.velocityy = 0.23
            end
            if math.abs(px-x) > 5 then
                if ent.standing_on_uid ~= -1 then
                    ent.velocityy = 0.23
                end
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
        commonlib.play_sound_at_entity(VANILLA_SOUND.SHARED_DAMAGED, ent.uid)
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