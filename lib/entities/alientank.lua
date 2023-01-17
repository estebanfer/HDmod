local module = {}
-- WIP: Animationlib, changing direction anim, shooting duration, bomb spawn,
-- player detection zone, movement when there's no floor next, ...?
local animationlib = require "animation"

local function b(flag) return (1 << (flag-1)) end

local TANK_STATE <const> = {
  IDLE = 0,
  CHANGING_DIRECTION = 1,
  RELOADING = 2 --waiting after shooting
}
local FRAME_TIME <const> = 4
local ANIMATIONS <const> = {
  IDLE = {2, 1, 0, loop = true, frames = 3},
  SHOOTING = {9, 8, 7, 6, frames = 4, frame_time = 2},
  CHANGING_DIRECTION = {5, 4, 3, frames = 3}
}

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
alientank_type.friction = 0
--alientank_type.sound_killed_by_player = VANILLA_SOUND

---@param tank Frog
local function alientank_update(tank)
  tank.pause = true
  local tank_data = tank.user_data
  if tank_data.state == TANK_STATE.IDLE then
    local dir_sign = test_flag(tank.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
    if tank.standing_on_uid ~= -1 then
      local x, y, layer = get_position(tank.uid)
      local hitbox = get_hitbox(tank.uid, 0, 0.101 * dir_sign, 0.0)
      hitbox:extrude(-0.1)
      local floors = get_entities_overlapping_hitbox(0, MASK.FLOOR | MASK.ACTIVEFLOOR, hitbox, tank.layer)
      floors = filter_entities(floors, function(e) return test_flag(e.flags, ENT_FLAG.SOLID) end)
      if floors[1] then
        tank_data.state = TANK_STATE.CHANGING_DIRECTION
        tank.velocityx = 0
        tank.idle_counter = 0
      end
    else
    end
    tank.velocityx = 0.025
    if test_flag(tank.flags, ENT_FLAG.FACING_LEFT) then
      tank.velocityx = tank.velocityx * -1
    end
    tank_data.bomb_timer = tank_data.bomb_timer - 1
    -- for alien as base
    -- if tank.state == 9 and tank.move_state == 1 then
    --   tank.move_state = 2
    -- end
    local spotted_player = false
    if tank_data.bomb_timer <= 0 then
      local x, y, layer = get_position(tank.uid)
      if get_entities_overlapping_hitbox(0, MASK.PLAYER, AABB:new(x-5, y+5, x+5, x-5), layer)[1] then
        if tank.standing_on_uid ~= -1 then
          tank.velocityx = 0.0
        end
        tank_data.state = TANK_STATE.RELOADING;
        tank_data.bomb_timer = 150
        tank_data.reload_timer = 200
        spotted_player = true
        animationlib.set_animation(tank_data, ANIMATIONS.SHOOTING, ANIMATIONS.SHOOTING.frame_time)
      end
    end
    if not spotted_player then
      if tank_data.animation_timer == 0 then
        animationlib.set_animation(tank_data, tank_data.animation_state, FRAME_TIME)
      end
    end
  elseif tank_data.state == TANK_STATE.CHANGING_DIRECTION then
    if tank_data.animation_timer == 0 then
      tank_data.state = TANK_STATE.IDLE
      animationlib.set_animation(tank_data, ANIMATIONS.IDLE, FRAME_TIME)
      tank.flags = tank.flags ~ b(ENT_FLAG.FACING_LEFT)
    end
  elseif tank_data.state == TANK_STATE.RELOADING then
    if tank_data.animation_timer == 0 then
      animationlib.set_animation(tank_data, ANIMATIONS.IDLE, FRAME_TIME)
      tank_data.state = TANK_STATE.IDLE
      local dir = test_flag(tank.flags, ENT_FLAG.FACING_LEFT) and -1.0 or 1.0
      local x, y, layer = get_position(tank.uid)
      spawn(ENT_TYPE.ITEM_BOMB, x + 0.12 * dir, y, layer, 0.08*dir, 0.05)
    end
  end
  --messpect(tank_data.animation_state, tank_data.animation_timer)
  tank.animation_frame = animationlib.get_animation_frame(tank_data.animation_state, tank_data.animation_timer)
  tank_data.animation_timer = tank_data.animation_timer - 1
end

---@param x integer
---@param y integer
---@param layer integer
local function alientank_spawn(x, y, layer)
  local uid = spawn(ENT_TYPE.MONS_FROG, x+1, y, layer, 0, 0)
  local tank = get_entity(uid)
  tank.type = alientank_type
  tank:set_texture(alien_tank_texture_id)
  tank.user_data = {
    bomb_timer = 60,
    reload_timer = 0,
    state = 0,
    animation_state = ANIMATIONS.IDLE,
    animation_timer = 0
  }
  animationlib.set_animation(tank.user_data, ANIMATIONS.IDLE, FRAME_TIME)
  set_post_statemachine(uid, alientank_update)
end

register_option_button("spawn_alien", "spawn alien", "", function() alientank_spawn(get_position(players[1].uid)) end)

return module
