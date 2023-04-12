local module = {}

-- Original on Spelunky HD:
-- if quiet on one tile: only decrease reload timer on reloading state
-- if moving: always decrease reload timer (though doesn't seem correct)
-- Reload timer: time it stays without moving after shooting
-- Bomb timer: time til it will be able to shoot

local animationlib = require "animation"

local function b(flag) return (1 << (flag-1)) end

local function is_activefloor_at(x, y, layer)
  local hitbox = AABB:new(x - 0.05, y+0.05, x + 0.05, y - 0.05)
  local activefloors = get_entities_overlapping_hitbox(0, MASK.ACTIVEFLOOR, hitbox, layer)
  return activefloors[1] ~= nil
end

local function is_solid_floor_at(x, y, layer)
  local floor = get_grid_entity_at(math.floor(x+0.5), math.floor(y+0.5), layer)
  if test_flag(get_entity_flags(floor), ENT_FLAG.SOLID) then return true end

  return is_activefloor_at(x, y, layer)
end

local function is_standable_floor_at(x, y, layer)
  local floor = get_grid_entity_at(math.floor(x+0.5), math.floor(y+0.5), layer)
  local flags = get_entity_flags(floor)
  if floor ~= 0 and (test_flag(flags, ENT_FLAG.SOLID) or test_flag(flags, ENT_FLAG.IS_PLATFORM)) then
    return true
  end

  return is_activefloor_at(x, y, layer)
end

local TANK_STATE <const> = {
  IDLE = 0,
  CHANGING_DIRECTION = 1,
  RELOADING = 2 --shooting / waiting after shooting
}
local FRAME_TIME <const> = 4
local ANIMATIONS <const> = {
  NONE = {0, loop = true, frames = 1, frame_time = 4},
  IDLE = {2, 1, 0, loop = true, frames = 3, frame_time = 4},
  SHOOTING = {9, 8, 7, 6, frames = 4, frame_time = 2},
  CHANGING_DIRECTION = {5, 4, 3, frames = 3, frame_time = 4}
}
local TANK_VELOCITY <const> = 0.025

local alien_tank_texture_id
do
    local alien_tank_texture_def = TextureDefinition.new()
    alien_tank_texture_def.width = 640
    alien_tank_texture_def.height = 256
    alien_tank_texture_def.tile_width = 128
    alien_tank_texture_def.tile_height = 128

    alien_tank_texture_def.texture_path = "res/monsters01_alientank.png"
    alien_tank_texture_id = define_texture(alien_tank_texture_def)
end

local alientank_type = EntityDB:new(get_type(ENT_TYPE.MONS_FROG))
alientank_type.friction = 0.0

local function alientank_update_onfloor(tank, tank_data)
  local x, y, layer = get_position(tank.uid)
  local dir_sign = test_flag(tank.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
  if (is_solid_floor_at(x + (0.6 * dir_sign), y, layer)
      or not is_standable_floor_at(x + (0.6 * dir_sign), y-0.8, layer))
  then
    if (not is_solid_floor_at(x + (0.6 * -dir_sign), y, layer)
      and is_standable_floor_at(x + (0.6 * -dir_sign), y-0.8, layer))
    then
      tank_data.state = TANK_STATE.CHANGING_DIRECTION
      animationlib.set_animation(tank_data, ANIMATIONS.CHANGING_DIRECTION)
      tank.velocityx = 0.0
      tank.idle_counter = 0
    else
      tank.velocityx = 0.0
      local target = get_entities_at(0, MASK.PLAYER, x, y, layer, 4.0)[1]
      if target then
        local px = get_position(target)
        if (px - x < 0) ~= test_flag(tank.flags, ENT_FLAG.FACING_LEFT) then
          tank_data.state = TANK_STATE.CHANGING_DIRECTION
          animationlib.set_animation(tank_data, ANIMATIONS.CHANGING_DIRECTION)
          tank_data.reload_timer = prng:random_int(50, 100, PRNG_CLASS.PARTICLES)
          tank.idle_counter = 0
        end
      end
    end
  else
    tank.velocityx = TANK_VELOCITY
    if test_flag(tank.flags, ENT_FLAG.FACING_LEFT) then
      tank.velocityx = tank.velocityx * -1
    end
    tank_data.reload_timer = tank_data.reload_timer - 1
    if tank_data.reload_timer <= 0 then
      tank_data.reload_timer = prng:random_int(50, 100, PRNG_CLASS.PARTICLES)
    end
  end
end

local function alientank_update_idle(tank, tank_data)
  if tank_data.animation_state == ANIMATIONS.IDLE and tank.velocityx == 0.0 then
    animationlib.set_animation(tank_data, ANIMATIONS.NONE)
  elseif tank_data.animation_state == ANIMATIONS.NONE and tank.velocityx ~= 0.0 then
    animationlib.set_animation(tank_data, ANIMATIONS.IDLE)
  end
  if tank.stun_timer > 0 then
    if tank.standing_on_uid ~= -1 then
      tank.velocityx = 0
    end
    return
  end

  if tank.standing_on_uid == -1 then
    -- do not bounce on walls when on air
    if (tank.velocityx > 0) == test_flag(tank.flags, ENT_FLAG.FACING_LEFT) then
      tank.velocityx = 0
    end
    -- Continue moving after touching spring trap
    -- The tank gets updated as it was on floor when touching the spring trap in HD,
    -- making it to not be stuck there on certain situations, so we have to do the same
    if tank.velocityy > 0.28
        and get_entity_type(get_grid_entity_at(math.floor(tank.x+.5), math.floor(tank.y+.5), tank.layer)) == ENT_TYPE.FLOOR_SPRING_TRAP
    then
      -- make it be closer to the floor for the floor checks
      tank.y = tank.y - 0.5
      alientank_update_onfloor(tank, tank_data)
      tank.y = tank.y + 0.5
    end
  else
    alientank_update_onfloor(tank, tank_data)
  end
  tank_data.bomb_timer = math.max(tank_data.bomb_timer - 1, 0)
  if tank_data.bomb_timer <= 0 then
    local x, y, layer = get_position(tank.uid)
    local target = get_entities_at(0, MASK.PLAYER, x, y, layer, 6.0)[1]
    local px, py = get_position(target or -1)
    if target and (px - x < 0) == test_flag(tank.flags, ENT_FLAG.FACING_LEFT)
      and y - 2.0 <= py then
      tank_data.state = TANK_STATE.RELOADING;
      tank_data.bomb_timer = 150
      animationlib.set_animation(tank_data, ANIMATIONS.SHOOTING)
    end
  end
end

local function alientank_update_reloading(tank, tank_data)
  if tank_data.animation_state == ANIMATIONS.SHOOTING
      and tank_data.animation_timer == 4
  then
    local dir = test_flag(tank.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
    local x, y, layer = get_position(tank.uid)
    local bomb_uid = spawn(ENT_TYPE.ITEM_BOMB, x + 0.6 * dir, y + 0.1, layer, 0.12*dir, 0.08)
    local floor_at = get_entities_overlapping_hitbox(0, MASK.FLOOR | MASK.ACTIVEFLOOR, get_hitbox(bomb_uid), layer)[1]
    if floor_at and test_flag(get_entity_flags(floor_at), ENT_FLAG.SOLID) then
      local bomb = get_entity(bomb_uid)
      local floor_x = get_position(floor_at)
      bomb.x = floor_x + ((get_entity(floor_at).hitboxx + bomb.hitboxx) * -dir)
    end
    commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMEC_BOMB_SPAWN, tank.uid):set_pitch(1.15)
  end
  if tank_data.animation_timer == 0 then
    animationlib.set_animation(tank_data, ANIMATIONS.NONE)
  end

  if tank.stun_timer > 0 then return end

  if tank_data.animation_state == ANIMATIONS.NONE and tank_data.reload_timer <= 0 then
    animationlib.set_animation(tank_data, ANIMATIONS.IDLE)
    tank_data.state = TANK_STATE.IDLE
    tank_data.reload_timer = 200
  else
    tank_data.reload_timer = tank_data.reload_timer - 1
    -- stop moving, not immediately
    if tank.standing_on_uid ~= -1 then
      if math.abs(tank.velocityx) > 0.015 then
        tank.velocityx = tank.velocityx + (0.015 * (tank.velocityx > 0 and -1.0 or 1.0))
      else
        tank.velocityx = 0.0
      end
    end
  end
end

---@param tank Frog
local function alientank_update(tank)
  tank.pause = true
  local tank_data = tank.user_data

  -- check for camera stun (stun timer is set to 1 when camera-stunned, couldn't find any better way to detect camera stun)
  if tank.stun_timer == 1 then
    if not tank_data.is_stunned or (
        --make sure to not un-stun if someone took a photo again
        tank_data.last_stun_timer == 2
        and test_flag(tank.flags, ENT_FLAG.FACING_LEFT) == tank_data.was_facing_left
    ) then
      tank_data.is_stunned = not tank_data.is_stunned
    end
    if tank_data.is_stunned then
      --undo frog camera stun flip
      tank.flags = tank_data.was_facing_left
        and set_flag(tank.flags, ENT_FLAG.FACING_LEFT)
        or clr_flag(tank.flags, ENT_FLAG.FACING_LEFT)
      tank.stun_timer = 75
      tank.velocityx = 0.0
    end
  end
  tank_data.last_stun_timer = tank.stun_timer
  
  if tank_data.state == TANK_STATE.IDLE then
    alientank_update_idle(tank, tank_data)
  elseif tank_data.state == TANK_STATE.CHANGING_DIRECTION then
    if tank_data.animation_timer == 0 then
      tank_data.state = TANK_STATE.IDLE
      animationlib.set_animation(tank_data, ANIMATIONS.IDLE)
      tank.flags = flip_flag(tank.flags, ENT_FLAG.FACING_LEFT)
      tank_data.was_facing_left = test_flag(tank.flags, ENT_FLAG.FACING_LEFT)
    end
  elseif tank_data.state == TANK_STATE.RELOADING then
    alientank_update_reloading(tank, tank_data)
  end
  tank.animation_frame = animationlib.get_animation_frame(tank_data.animation_state, tank_data.animation_timer)
  tank_data.animation_timer = animationlib.update_timer(tank_data.animation_state, tank_data.animation_timer)
end

function set_alientank(uid)
  local tank = get_entity(uid)
  tank.type = alientank_type
  tank.width, tank.height = 1.25, 1.25
  tank.hitboxx = 0.3
  tank.hitboxy = 0.425
  tank.offsety = -0.05
  tank:set_texture(alien_tank_texture_id)
  tank.user_data = {
    bomb_timer = 60,
    reload_timer = prng:random_int(50, 100, PRNG_CLASS.PARTICLES),
    state = 0,
    animation_state = ANIMATIONS.IDLE,
    animation_timer = 0,
    -- To detect if the facing direction was changed by camera
    was_facing_left = test_flag(tank.flags, ENT_FLAG.FACING_LEFT),
    -- More variables to make camera stun work properly
    last_stun_timer = 0,
    is_stunned = false,
  }
  animationlib.set_animation(tank.user_data, ANIMATIONS.IDLE)
  set_post_statemachine(uid, alientank_update)
end

function spawn_alientank(x, y, layer)
  local uid = spawn(ENT_TYPE.MONS_FROG, x, y, layer, 0, 0)
  set_alientank(uid)
end

---@param x integer
---@param y integer
---@param layer integer
function module.create_alientank(x, y, layer)
  local uid = spawn_entity_snapped_to_floor(ENT_TYPE.MONS_FROG, x, y, layer, 0, 0)
  set_alientank(uid)
end

optionslib.register_entity_spawner("Alien tank", spawn_alientank)

return module
