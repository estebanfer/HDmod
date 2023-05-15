local celib = require "lib.entities.custom_entities"
local animationlib = require "lib.entities.animation"
local commonlib = require "lib.common"

local module = {}
local texture_id
do
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERSBASIC01_0)
    texture_def.texture_path = 'res/worm_baby.png'
    texture_id = define_texture(texture_def)
end

local ANIMATION = {
    GROUND = {148, 149, 150, 151, 152, 153, frames = 6, frame_time = 4, loop = true},
    AIR = {144, 145, 146, 147, frames = 4, frame_time = 4, loop = true}
}

local BWORM_VELOCITY = 0.025
local BWORM_VELOCITY_CHASING = 0.045

local function update_onfloor(worm)
    local x, y, layer = get_position(worm.uid)
    local dir_sign = test_flag(worm.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
    local is_wall_ahead = commonlib.is_solid_floor_at(x + (0.6 * dir_sign), y, layer)
    local is_wall_behind = commonlib.is_solid_floor_at(x + (0.6 * -dir_sign), y, layer)
    local is_floor_ahead = commonlib.is_standable_floor_at(x + (0.6 * dir_sign), y-0.8, layer)
    local is_floor_behind = commonlib.is_standable_floor_at(x + (0.6 * -dir_sign), y-0.8, layer)
    local chasing_player = worm.user_data.chasing_player

    if is_wall_ahead and is_wall_behind then
        worm.velocityx = 0.0
    elseif (
        is_wall_ahead
        or (not chasing_player and not is_floor_ahead)
    ) then
        if (
            not is_wall_behind
            and (chasing_player or is_floor_behind)
        ) then
            worm.flags = flip_flag(worm.flags, ENT_FLAG.FACING_LEFT)
            worm.velocityx = BWORM_VELOCITY
            if test_flag(worm.flags, ENT_FLAG.FACING_LEFT) then
                worm.velocityx = worm.velocityx * -1
            end
        else
            worm.velocityx = 0.0
        end
    else
        worm.velocityx = BWORM_VELOCITY
        if test_flag(worm.flags, ENT_FLAG.FACING_LEFT) then
            worm.velocityx = worm.velocityx * -1
        end
    end
end

local worm_type = EntityDB:new(get_type(ENT_TYPE.MONS_FROG))
worm_type.friction = 0.0

local function worm_baby_set(uid)
    local ent = get_entity(uid) --[[@as Frog]]
    ent.type = worm_type
    ent.width, ent.height = 1.25, 1.25
    ent.offsety = -0.11
    ent.hitboxy = 0.325
    ent.pause = true
    ent.price = 0 --exit_chase_timer
    ent:set_texture(texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_BABY_WORM,
        chasing_player = false,
        animation_state = ANIMATION.AIR,
        animation_timer = 0,
    };
    animationlib.set_animation(ent.user_data, ANIMATION.AIR)
end

---@param ent Frog
local function worm_baby_update(ent)
    ent.animation_frame = 145
    --chase timer
    if ent.price > 0 then
        ent.price = ent.price - 1
    end
    --lock jump behavior
    ent.jump_timer = 180
    --statemachine
    ent.move_state = 20
    if ent.standing_on_uid ~= -1 then
        update_onfloor(ent)
        if ent.user_data.animation_state == ANIMATION.AIR then
            animationlib.set_animation(ent.user_data, ANIMATION.GROUND)
        end
    elseif ent.user_data.animation_state == ANIMATION.GROUND then
        animationlib.set_animation(ent.user_data, ANIMATION.AIR)
    end
    for _, player in ipairs(players) do
        local _, y, _ = get_position(ent.uid)
        local _, py, _ = get_position(player.uid)
        if py-y-0.5 <= 0 then
            ent.user_data.chasing_player = true
            ent.price = 15
            break
        end
    end
    if ent.price == 0 then
        ent.user_data.chasing_player = false
    end
    if ent.user_data.chasing_player and ent.velocityx ~= 0.0 then
        local dir_sign = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
        ent.velocityx = BWORM_VELOCITY_CHASING * dir_sign
    end
    ent.animation_frame = animationlib.get_animation_frame(ent.user_data)
    animationlib.update_timer(ent.user_data)
end
function module.create_worm_baby(x, y, l)
    local worm_baby = spawn(ENT_TYPE.MONS_FROG, x, y, l, 0, 0)
    worm_baby_set(worm_baby)
    set_post_statemachine(worm_baby, worm_baby_update)
end

set_pre_entity_spawn(function (e_type, x, y, l)
    module.create_worm_baby(x, y, l)
    return spawn_grid_entity(ENT_TYPE.FX_SHADOW, 0, 0, LAYER.FRONT)
end, SPAWN_TYPE.ANY, MASK.MONSTER, ENT_TYPE.MONS_GRUB)

optionslib.register_entity_spawner("Worm Baby", module.create_worm_baby)

return module