local celib = require "lib.entities.custom_entities"
-- local nosacrifice = require "../nosacrifice_items"

local module = {}

--turret can be freezed on HD, idk how to make that work there
--Spot distance for the trap is 6 tiles (?) and based on distance (circle), doesn't detect if 6 tiles below but on ground, doing a little jump makes it detect you

local BRIGHTNESS = 1.0
local BRIGHTNESS_MULTIPLIER = 1.75
local turret_light_colors = {
    Color:new(0.26, 0.87, 1, 1),
    Color:new(0.7, 0.09, 1, 1),
    Color:new(1, 0.09, 0.80, 1),
    Color:new(1, 0.25, 0.09, 1),
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function set_light_color(illumination, color_index)
    local color_lerp = 0.05
    local color, next_color = illumination.light1, turret_light_colors[color_index]
    color.red = lerp(color.red, next_color.r, color_lerp)
    color.green = lerp(color.green, next_color.g, color_lerp)
    color.blue = lerp(color.blue, next_color.b, color_lerp)
end

local function light_update(light_emitter)
    refresh_illumination(light_emitter)
    light_emitter.brightness = BRIGHTNESS
end

local turret_texture_id
do
    local turret_texture_def = TextureDefinition.new()
    turret_texture_def.width = 640
    turret_texture_def.height = 128
    turret_texture_def.tile_width = 128
    turret_texture_def.tile_height = 128

    turret_texture_def.texture_path = "res/turret.png"
    turret_texture_id = define_texture(turret_texture_def)
end

local function get_diffs(uid1, uid2)
    local x, y = get_position(uid1)
    local tx, ty = get_position(uid2)
    return tx - x, ty - y
end

---@param laser LightShot
local function laser_set(laser)
    ---@param _laser LightShot
    ---@param collider Movable
    -- user_data
    laser.user_data = {
        ent_type = HD_ENT_TYPE.ITEM_LASER_TURRET;
    };
    set_pre_collision2(laser.uid, function (_laser, collider)
        if collider.type.search_flags & (MASK.PLAYER | MASK.MOUNT | MASK.MONSTER) ~= 0 then
            if collider.invincibility_frames_timer == 0 then
                collider:damage(_laser.uid, 1, 60, _laser.velocityx*0.75, 0.1, 30)
            end
            _laser:destroy()
            return true
        end
    end)
end

local function spawn_turret_rubble(x, y, l, amount)
    for _=1, amount do
        local rub = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.5-0.25, prng:random_float(PRNG_CLASS.PARTICLES)*0.25))
        rub.animation_frame = 20
    end
end

---@param ent Movable
local function set_func(ent)
    ent.hitboxx = 0.4
    ent.hitboxy = 0.4
    ent.offsety = 0
    ent:set_texture(turret_texture_id)
    ent.health = 2
    if ent.overlay and ent.overlay.type.search_flags == MASK.FLOOR then
        ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end
    ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    ent.flags = clr_flag(ent.flags, 22)
    set_on_kill(ent.uid, function (e)
        local x, y, l = get_position(e.uid)
        get_entity(spawn(ENT_TYPE.FX_EXPLOSION, x, y, l, 0, 0)).last_owner_uid = e.last_owner_uid
        spawn_turret_rubble(x, y, l, 5)
    end)
    local light_emitter = create_illumination(turret_light_colors[1], 3, ent.uid)
    light_emitter.brightness = BRIGHTNESS
    light_emitter.brightness_multiplier = BRIGHTNESS_MULTIPLIER
    -- nosacrifice.add_uid(ent.uid)
    return {
        target_uid = -1,
        light_emitter = light_emitter
    }
end

local function shoot_laser(ent, xdiff, ydiff)
    local x, y, l = get_position(ent.uid)
    local dist = math.sqrt(xdiff*xdiff + ydiff*ydiff) * 3
    local vx, vy = xdiff / dist, ydiff / dist
    local laser = get_entity(spawn(ENT_TYPE.ITEM_LASERTRAP_SHOT, x+vx*2, y+vy*2, l, vx, vy))
    laser_set(laser)
    laser.angle = ent.angle
    commonlib.play_sound_at_entity(VANILLA_SOUND.TRAPS_LASERTRAP_TRIGGER, ent.uid)
end

local function shoot_straight_laser(ent)
    local x, y, l = get_position(ent.uid)
    local dir_x = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -1 or 1
    local laser = get_entity(spawn(ENT_TYPE.ITEM_LASERTRAP_SHOT, x+dir_x*0.74, y, l, dir_x*0.4, 0))
    laser.last_owner_uid = ent.uid
    laser_set(laser)
    laser.angle = ent.angle
    commonlib.play_sound_at_entity(VANILLA_SOUND.TRAPS_LASERTRAP_TRIGGER, ent.uid)
end

local function move_to_angle(ent, to_angle, vel)
    local diff = to_angle - ent.angle
    if math.abs(diff) < vel then
        ent.angle = to_angle
    else
        ent.angle = diff > 0 and ent.angle + vel or ent.angle - vel 
    end
end

local MAX_DIST = 6
local function point_to_target(ent, c_data)
    local to_angle
    local xdiff, ydiff = get_diffs(ent.uid, c_data.target_uid)
    if math.sqrt(xdiff*xdiff + ydiff*ydiff) > MAX_DIST then
        c_data.target_uid = -1
        to_angle = -1.5708
    else
        if ydiff > 0 then
            to_angle = xdiff < 0 and 0.34906585 or -0.34906585 --20 deg, TODO: check angle in HD
        else
            to_angle = math.atan(ydiff / xdiff)
        end
    end
    to_angle = to_angle < 0 and math.pi + to_angle or to_angle
    return to_angle, xdiff, ydiff
end

local function point_up(turret)
    local to_angle
    turret.idle_counter = 0
    to_angle = test_flag(turret.flags, ENT_FLAG.FACING_LEFT) and -1.5708 or 1.5708
    turret.angle = to_angle
    return to_angle
end

local function update_func(ent, c_data)
    local to_angle = 0
    if ent.overlay then
        if ent.overlay.type.search_flags == MASK.FLOOR then --update, attached to ceiling
            if c_data.target_uid == -1 then
                local x, y, layer = get_position(ent.uid)
                local targets = get_entities_at(0, MASK.PLAYER, x, y, layer, MAX_DIST)
                if targets[1] then
                        c_data.target_uid = targets[1]
                        to_angle = point_to_target(ent, c_data)
                else
                    ent.idle_counter = 0
                    to_angle = 1.5708
                end
            else
                local xdiff, ydiff
                to_angle, xdiff, ydiff = point_to_target(ent, c_data)
                if ent.idle_counter >= 240 then
                    if math.abs(to_angle - ent.angle) < 0.1 and ydiff < -0.01 then
                        shoot_laser(ent, xdiff, ydiff)
                        ent.idle_counter = 0
                    end
                else
                    ent.idle_counter = ent.idle_counter + 1
                end
            end
            move_to_angle(ent, to_angle, 0.085)
        else --update, unattached
            if ent.overlay.type.search_flags & (MASK.PLAYER | MASK.MONSTER | MASK.MOUNT) ~= 0 then
                if ent.idle_counter > 240 then
                    shoot_straight_laser(ent)
                    ent.idle_counter = 0
                else
                    ent.idle_counter = ent.idle_counter + 1
                end
                ent.angle = 0
            else
                ent.angle = point_up(ent)
            end
        end
    else
        ent.angle = point_up(ent)
    end
    ent.animation_frame = math.min(math.floor(ent.idle_counter/60), 3)
    set_light_color(c_data.light_emitter, ent.animation_frame+1)
    light_update(c_data.light_emitter)
end

local turret_id = celib.new_custom_entity(set_func, update_func, celib.CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK)
celib.init()

function module.spawn_turret(x, y, l)
    local over, uid = get_grid_entity_at(x, y+1, l)
    if over ~= -1 then
        uid = spawn_over(ENT_TYPE.ITEM_ROCK, over, 0, -1)
        ---@type Floor
        local floor = get_entity(over)
        local deco_uid = spawn_over(ENT_TYPE.DECORATION_GENERIC, over, 0, -1)
        local deco = get_entity(deco_uid)
        deco:set_texture(turret_texture_id)
        deco.animation_frame = 4
        floor.deco_bottom = deco_uid
    else
        uid = spawn(ENT_TYPE.ITEM_ROCK, x, y, l, 0, 0)
    end
    celib.set_custom_entity(uid, turret_id)
end

optionslib.register_entity_spawner("Laser turret", module.spawn_turret, true)

return module