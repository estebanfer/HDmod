local celib = require "lib.entities.custom_entities"
local animationlib = require "lib.entities.animation"
local commonlib = require "lib.common"

local module = {}

local texture_id
do
    local texture_def = TextureDefinition.new()
	texture_def.width = 768
	texture_def.height = 256
	texture_def.tile_width = 128
	texture_def.tile_height = 128
    texture_def.texture_path = 'res/worm_baby.png'
    texture_id = define_texture(texture_def)
end

local ANIMATION = {
    GROUND = {0, 1, 2, 3, 4, 5, frames = 6, frame_time = 4, loop = true},
    AIR = {6, 7, 8, 9, frames = 4, frame_time = 4, loop = true}
}

local BWORM_VELOCITY = 0.025
local BWORM_VELOCITY_CHASING = 0.045

local function update_onfloor(worm, chasing_player)
    local x, y, layer = get_position(worm.uid)
    local dir_sign = test_flag(worm.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
    local is_wall_ahead = commonlib.is_solid_floor_at(x + (0.6 * dir_sign), y, layer)
    local is_wall_behind = commonlib.is_solid_floor_at(x + (0.6 * -dir_sign), y, layer)
    local is_floor_ahead = commonlib.is_standable_floor_at(x + (0.6 * dir_sign), y-0.8, layer)
    local is_floor_behind = commonlib.is_standable_floor_at(x + (0.6 * -dir_sign), y-0.8, layer)

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
            if is_wall_ahead then
                worm.flags = flip_flag(worm.flags, ENT_FLAG.FACING_LEFT)
            end
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
    ent.price = 50 --exit_chase_timer
    ent:set_texture(texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_BABY_WORM,
        animation_state = ANIMATION.AIR,
        animation_timer = 0,
    };
    animationlib.set_animation(ent.user_data, ANIMATION.AIR)
end

---@param ent Frog
local function worm_baby_update(ent)
    --chase timer
    if ent.price > 0 then
        ent.price = ent.price - 1
    end
    local chasing_player = false
    if ent.price > 0 then
        chasing_player = true
    else
        for _, player in ipairs(players) do
            local _, y, _ = get_position(ent.uid)
            local _, py, _ = get_position(player.uid)
            if py-y-0.5 <= 0 then
                chasing_player = true
                break
            end
        end
    end
    local dir_sign = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
    if ent.standing_on_uid ~= -1 then
        update_onfloor(ent, chasing_player)
        if ent.user_data.animation_state == ANIMATION.AIR then
            animationlib.set_animation(ent.user_data, ANIMATION.GROUND)
        end
    else
        ent.velocityx = BWORM_VELOCITY * dir_sign
        if ent.user_data.animation_state == ANIMATION.GROUND then
            animationlib.set_animation(ent.user_data, ANIMATION.AIR)
        end
    end
    if ent.velocityx ~= 0.0 then
        --Change velocity if chasing a player
        if chasing_player then
            ent.velocityx = BWORM_VELOCITY_CHASING * dir_sign
        end
        --Add velocity if on air
        if ent.standing_on_uid == -1 then
            ent.velocityx = ent.velocityx + 0.015 * dir_sign
        end
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