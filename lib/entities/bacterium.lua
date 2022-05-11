local module = {}
local celib = require "custom_entities"
local bacterium_id

local bacterium_texture_id
do
    local bacterium_texture_def = TextureDefinition.new()
    bacterium_texture_def.width = 640
    bacterium_texture_def.height = 128
    bacterium_texture_def.tile_width = 128
    bacterium_texture_def.tile_height = 128

    bacterium_texture_def.texture_path = "res/bacterium.png"
    bacterium_texture_id = define_texture(bacterium_texture_def)
end

local DIR_MAP = {
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
}
module.ATTACH_DIR = {
    TOP = 1,
    RIGHT = 2,
    BOTTOM = 3,
    LEFT = 4
}

local BACTERIUM_VEL = 0.055
local EXTRA_FLOOR_SEPARATION = 0.075
local HITBOX_SIZE = 0.4

local function spawn_blood(x, y, l, amount)
    for _=1, amount do
        spawn(ENT_TYPE.ITEM_BLOOD, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.4-0.2, prng:random_float(PRNG_CLASS.PARTICLES)*0.2)
    end
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
    spawn_blood(x, y, l, 3)
    if bacterium.frozen_timer == 0 then
        commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_KILLED_ENEMY, bacterium.uid)
    end
    spawn_bacterium_rubble(x, y, l, 2)
    bacterium:destroy()
end

--TODO: Crysknife, telefrag
---@param bacterium Movable
---@param attacker Movable
local function bacterium_damage(bacterium, attacker)
    if bacterium.frozen_timer == 0 then
        ---@type table
        local bacterium_info = celib.get_custom_entity(bacterium.uid, bacterium_id)
        if bacterium_info.stop_timer == 0 then
            bacterium_info.stop_timer = 60
        end
        local x, y, l = get_position(bacterium.uid)
        spawn_blood(x, y, l, 1)
        generate_world_particles(PARTICLEEMITTER.HITEFFECT_SMACK, bacterium.uid)
        bacterium.exit_invincibility_timer = 10
        commonlib.play_sound_at_entity(VANILLA_SOUND.TRAPS_STICKYTRAP_END, bacterium.uid)
        return true
    else
        bacterium_kill(bacterium)
    end
end

---@param ent Movable
local function bacterium_set(ent, _, _, attach_dir)
    ent.hitboxx, ent.hitboxy = HITBOX_SIZE, HITBOX_SIZE
    ent.width, ent.height = 1.25, 1.25
    ent.offsety = 0
    ent:set_texture(bacterium_texture_id)
    ent.health = 0
    ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.COLLIDES_WALLS)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
    set_on_damage(ent.uid, bacterium_damage)
    set_on_kill(ent.uid, bacterium_kill) --Telefrag

    local x, y, l = get_position(ent.uid)
    local is_inverse
    if math.random(2) == 1 then
        is_inverse = false
    else
        is_inverse = true
    end
    local dir_state = is_inverse and attach_dir % 4 + 1 or (attach_dir - 2) % 4 + 1
    local movex, movey = table.unpack(DIR_MAP[dir_state])
    local attach_off_x, attach_off_y = table.unpack(DIR_MAP[attach_dir])
    return {
        attached_floor_uid = get_solid_grid_entity(x+attach_off_x, y+attach_off_y, l),
        inverse = is_inverse,
        dir_state = dir_state,
        movex = movex,
        movey = movey,
        stop_timer = 0,
    }
end

local function will_collide_floor(ent, ent_info)
    local x, y, l = get_position(ent.uid)
    x = ent_info.movex == 0 and math.floor(x+0.5) or math.floor(x+((ent.hitboxx+EXTRA_FLOOR_SEPARATION)*ent_info.movex)+ent.velocityx+0.5)
    y = ent_info.movey == 0 and math.floor(y+0.5) or math.floor(y+((ent.hitboxy+EXTRA_FLOOR_SEPARATION)*ent_info.movey)+ent.velocityx+0.5)
    local floor_uid = get_solid_grid_entity(x, y, l)
    floor_uid = floor_uid ~= -1 and floor_uid or get_entities_overlapping_hitbox(0, MASK.ACTIVEFLOOR, get_hitbox(ent.uid, 0, ent.velocityx, ent.velocityy), l)[1]
    if floor_uid ~= nil then
        return floor_uid
    end
end

local function will_be_out_of_attached(ent, ent_info)
    local ox, oy = get_position(ent_info.attached_floor_uid)
    --messpect(ent_info.movex, math.abs(ent.x + ent.velocityx - ent.hitboxx*ent_info.movex - ox), ent_info.movey, math.abs(ent.y + ent.velocityy - ent.hitboxy*ent_info.movey - oy))
    if (ent_info.movex ~= 0 and ent_info.movex*(ent.x + ent.velocityx - (ent.hitboxx+EXTRA_FLOOR_SEPARATION)*ent_info.movex - ox) > 0.5)
    or (ent_info.movey ~= 0 and ent_info.movey*(ent.y + ent.velocityy - (ent.hitboxx+EXTRA_FLOOR_SEPARATION)*ent_info.movey - oy) > 0.5)  then
        return true
    end
    return false
end

local function update_move(ent, ent_info, ox, oy)
    ent.x = ent_info.movex == 0 and ent.x or ox + (ent.hitboxx+EXTRA_FLOOR_SEPARATION) * 2 * ent_info.movex --+ ent.velocityx
    ent.y = ent_info.movey == 0 and ent.y or oy + (ent.hitboxy+EXTRA_FLOOR_SEPARATION) * 2 * ent_info.movey --+ ent.velocityy
    
    ent_info.movex, ent_info.movey = table.unpack(DIR_MAP[ent_info.dir_state])
    ent.velocityx = ent_info.movex*BACTERIUM_VEL
    ent.velocityy = ent_info.movey*BACTERIUM_VEL
end

---@param ent Movable
---@param ent_info any
local function bacterium_update(ent, ent_info)
    if get_entity(ent_info.attached_floor_uid) then
        if ent.frozen_timer ~= 0 then
            ent_info.stop_timer = ent.frozen_timer
        end
        if ent_info.stop_timer == 0 and not test_flag(ent.more_flags, 9) then
            ent.velocityx = ent_info.movex*BACTERIUM_VEL
            ent.velocityy = ent_info.movey*BACTERIUM_VEL
        else
            ent.velocityx = 0
            ent.velocityy = ent.frozen_timer == 0 and 0 or 0.01 --Frozen entities always move down
        end
        --messpect(ent_info.dir_state, ent_info.attached_floor_uid)
        if will_be_out_of_attached(ent, ent_info) then
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
    if ent_info.stop_timer ~= 0 then
        ent_info.stop_timer = ent_info.stop_timer - 1
    end
end

bacterium_id = celib.new_custom_entity(bacterium_set, bacterium_update, nil, ENT_TYPE.MONS_MANTRAP, celib.UPDATE_TYPE.POST_STATEMACHINE)

celib.init()

register_option_button("spawn_bacterium", "spawn bacterium", "spawn bacterium", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    local uid = spawn(ENT_TYPE.MONS_MANTRAP, x, y, l, 0, 0)
    local attach_dir = module.ATTACH_DIR.BOTTOM
    celib.set_custom_entity(uid, bacterium_id, attach_dir)
    local off_x, off_y = DIR_MAP[attach_dir][1], DIR_MAP[attach_dir][2]
    off_x = off_x - off_x * (HITBOX_SIZE+EXTRA_FLOOR_SEPARATION)*2
    off_y = off_y - off_y * (HITBOX_SIZE+EXTRA_FLOOR_SEPARATION)*2
    x, y = get_position(uid)
    move_entity(uid, x+off_x, y+off_y, 0, 0)
end)

local function spawn_bacterium(grid_x, grid_y, layer, attach_dir)
    local uid = spawn(ENT_TYPE.MONS_MANTRAP, grid_x, grid_y, layer, 0, 0)
    celib.set_custom_entity(uid, bacterium_id, attach_dir)
    local off_x, off_y = DIR_MAP[attach_dir][1], DIR_MAP[attach_dir][2]
    off_x = off_x - off_x * (HITBOX_SIZE+EXTRA_FLOOR_SEPARATION)*2
    off_y = off_y - off_y * (HITBOX_SIZE+EXTRA_FLOOR_SEPARATION)*2
    local x, y = get_position(uid)
    move_entity(uid, x+off_x, y+off_y, 0, 0)
end

function module.create_bacterium(x, y, layer)
    for dir_i, dir in ipairs(DIR_MAP) do
        local off_x, off_y = table.unpack(dir)
        if test_flag(get_entity_flags(get_grid_entity_at(x+off_x, y+off_y, layer)), ENT_FLAG.SOLID) then
            spawn_bacterium(x, y, layer, dir_i)
            return
        end
    end
    spawn_bacterium(x, y, layer, 1)
end

return module