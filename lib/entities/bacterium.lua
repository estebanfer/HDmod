local celib = require "custom_entities"

local bacterium_texture_id
do
    local bacterium_texture_def = TextureDefinition.new()
    bacterium_texture_def.width = 640
    bacterium_texture_def.height = 128
    bacterium_texture_def.tile_width = 128
    bacterium_texture_def.tile_height = 128

    bacterium_texture_def.texture_path = "bacterium.png"
    bacterium_texture_id = define_texture(bacterium_texture_def)
end

local MOVE_MAP = {
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
}
local BACTERIUM_VEL = 0.055

local function spawn_blood(x, y, l)
    spawn(ENT_TYPE.ITEM_BLOOD, x, y, l, math.random()*0.4-0.2, math.random()*0.2)
end

local function play_sound_at_entity(snd, uid, volume)
    local v = 0.5
    if volume ~= nil then
        v = volume
    end
    local ent = get_entity(uid)
    local sound = get_sound(snd)
    local audio = sound:play(true)
    local x, y, _ = get_position(ent.uid)
    local sx, sy = screen_position(x, y)
    local d = screen_distance(distance(ent.uid, ent.uid))
    if players[1] ~= nil then
        d = screen_distance(distance(ent.uid, players[1].uid))
    end
    audio:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
    audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx))
    audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy))
    audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
    audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
    audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, v)
    
    audio:set_pause(false)
  end

local function get_solid_grid_entity(x, y, l)
    local uid = get_grid_entity_at(x, y, l)
    return test_flag(get_entity_flags(uid), ENT_FLAG.SOLID) and uid or -1
end

local function spawn_bacterium_rubble(x, y, l, amount)
    for _=1, amount do
        get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, 0, 0)).animation_frame = 54
    end
end

local function bacterium_kill(bacterium)
    local x, y, l = get_position(bacterium.uid)
    spawn_blood(x, y, l)
    spawn_blood(x, y, l)
    spawn_blood(x, y, l)
    play_sound_at_entity(VANILLA_SOUND.ENEMIES_KILLED_ENEMY, bacterium.uid)
    spawn_bacterium_rubble(x, y, l, 2)
    bacterium:destroy()
end

---@param bacterium Movable
---@param attacker Movable
local function bacterium_damage(bacterium, attacker)
    messpect(enum_get_name(ENT_TYPE, attacker.type.id))
    if attacker.type.id == ENT_TYPE.ITEM_FREEZERAYSHOT then
        if bacterium.frozen_timer == 0 then
            spawn_over(ENT_TYPE.ITEM_ICECAGE, bacterium.uid, 0, 0)
            bacterium.flags = set_flag(bacterium.flags, ENT_FLAG.CAN_BE_STOMPED)
        end
        bacterium.frozen_timer = 120
        bacterium.stun_timer = 120
        play_sound_at_entity(VANILLA_SOUND.ITEMS_FREEZE_RAY_HIT, bacterium.uid)
        generate_world_particles(PARTICLEEMITTER.BLUESPARKS, bacterium.uid)
        kill_entity(attacker.uid)
        return true
    elseif bacterium.frozen_timer == 0 then
        if bacterium.stun_timer == 0 then
            bacterium.stun_timer = 60
        end
        local x, y, l = get_position(bacterium.uid)
        spawn_blood(x, y, l)
        generate_world_particles(PARTICLEEMITTER.HITEFFECT_SMACK, bacterium.uid)
        bacterium.exit_invincibility_timer = 10
        play_sound_at_entity(VANILLA_SOUND.TRAPS_STICKYTRAP_END, bacterium.uid)
        return true
    else
        bacterium_kill(bacterium)
    end
end

---@param ent Movable
local function bacterium_set(ent)
    ent.hitboxx, ent.hitboxy = 0.45, 0.45
    ent.width, ent.height = 1.25, 1.25
    ent.offsety = 0
    ent:set_texture(bacterium_texture_id)
    ent.health = 0
    ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.INTERACT_WITH_WEBS)
    set_on_damage(ent.uid, bacterium_damage)

    local x, y, l = get_position(ent.uid)
    messpect(get_solid_grid_entity(x, y-1, l))
    local is_inverse
    if math.random(2) == 1 then
        is_inverse = false
    else
        is_inverse = true
    end
    return {
        attached_floor_uid = get_solid_grid_entity(x, y-1, l),
        inverse = is_inverse,
        dir_state = 2,
        movex = is_inverse and -1 or 1,
        movey = 0
    }
end

local function will_collide_floor(ent, ent_info)
    local x, y, l = get_position(ent.uid)
    x = ent_info.movex == 0 and math.floor(x+0.5) or math.floor(x+(ent.hitboxx*ent_info.movex)+ent.velocityx+0.5)
    y = ent_info.movey == 0 and math.floor(y+0.5) or math.floor(y+(ent.hitboxy*ent_info.movey)+ent.velocityx+0.5)
    local floor_uid = get_solid_grid_entity(x, y, l)
    floor_uid = floor_uid ~= -1 and floor_uid or get_entities_overlapping_hitbox(0, MASK.ACTIVEFLOOR, get_hitbox(ent.uid, 0, ent.velocityx, ent.velocityy), l)[1]
    if floor_uid ~= nil then
        return floor_uid
    end
end

local function will_be_out_of_owner(ent, ent_info)
    local ox, oy = get_position(ent_info.attached_floor_uid)
    --messpect(ent_info.movex, math.abs(ent.x + ent.velocityx - ent.hitboxx*ent_info.movex - ox), ent_info.movey, math.abs(ent.y + ent.velocityy - ent.hitboxy*ent_info.movey - oy))
    if (ent_info.movex ~= 0 and ent_info.movex*(ent.x + ent.velocityx - ent.hitboxx*ent_info.movex - ox) > 0.5)
    or (ent_info.movey ~= 0 and ent_info.movey*(ent.y + ent.velocityy - ent.hitboxy*ent_info.movey - oy) > 0.5)  then
        return true
    end
    return false
end

local function update_move(ent, ent_info, ox, oy)
    ent.x = ent_info.movex == 0 and ent.x or ox + (ent.hitboxx+0.025) * 2 * ent_info.movex --+ ent.velocityx
    ent.y = ent_info.movey == 0 and ent.y or oy + (ent.hitboxy+0.025) * 2 * ent_info.movey --+ ent.velocityy
    
    ent_info.movex, ent_info.movey = table.unpack(MOVE_MAP[ent_info.dir_state])
    ent.velocityx = ent_info.movex*BACTERIUM_VEL
    ent.velocityy = ent_info.movey*BACTERIUM_VEL
end

---comment
---@param ent Movable
---@param ent_info any
local function bacterium_update(ent, ent_info)
    if get_entity(ent_info.attached_floor_uid) then
        if ent.stun_timer == 0 then
            ent.velocityx = ent_info.movex*BACTERIUM_VEL
            ent.velocityy = ent_info.movey*BACTERIUM_VEL
        else
            ent.velocityx = 0
            ent.velocityy = ent.frozen_timer == 0 and 0 or 0.01
        end
        --messpect(ent_info.dir_state, ent_info.attached_floor_uid)
        if will_be_out_of_owner(ent, ent_info) then
            local ox, oy, ol = get_position(ent_info.attached_floor_uid)
            local next_floor_uid = get_solid_grid_entity(ox+ent_info.movex, oy+ent_info.movey, ol)
            if next_floor_uid ~= -1 then
                ent_info.attached_floor_uid = next_floor_uid
            else
                ent_info.dir_state = ent_info.inverse and (ent_info.dir_state - 2) % 4 + 1 or ent_info.dir_state % 4 + 1
                update_move(ent, ent_info, ox, oy)
            end
        else
            local uid = will_collide_floor(ent, ent_info)
            if uid then
                ent_info.dir_state = ent_info.inverse and ent_info.dir_state % 4 + 1 or (ent_info.dir_state - 2) % 4 + 1
                ent_info.movex, ent_info.movey = ent_info.movex*-1, ent_info.movey*-1
                ent_info.attached_floor_uid = uid
                local ox, oy, ol = get_position(uid)
                update_move(ent, ent_info, ox, oy)
            end
        end
    else
        if ent.standing_on_uid ~= -1 then
            ent_info.attached_floor_uid = ent.standing_on_uid
            ent.standing_on_uid = -1
            ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
            ent.flags = clr_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS)
        else
            ent.flags = clr_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
            ent.flags = set_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS)
        end
    end
    if ent.frozen_timer == 0 then
        if ent:is_on_fire() then
            bacterium_kill(ent)
        end
        for _,p_uid in ipairs(get_entities_overlapping_hitbox(0, MASK.PLAYER, get_hitbox(ent.uid), LAYER.PLAYER)) do
            local player = get_entity(p_uid)
            if not test_flag(player.flags, ENT_FLAG.PASSES_THROUGH_EVERYTHING) then
                if player.invincibility_frames_timer == 0 then
                    local x = get_position(ent.uid)
                    local px = get_position(p_uid)
                    player:damage(ent.uid, 1, 0, px > x and 0.1 or -0.1, 0.1, 60)
                end
                bacterium_kill(ent)
            end
        end
        ent.animation_frame = math.floor(ent.idle_counter / 5)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    end
end

local bacterium_id = celib.new_custom_entity(bacterium_set, bacterium_update, nil, ENT_TYPE.ITEM_ROCK, celib.UPDATE_TYPE.POST_STATEMACHINE)

celib.init()

register_option_button("spawn_bacterium", "spawn bacterium", "spawn bacterium", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    local uid = spawn(ENT_TYPE.ITEM_ROCK, x, y, l, 0, 0)
    celib.set_custom_entity(uid, bacterium_id)
end)