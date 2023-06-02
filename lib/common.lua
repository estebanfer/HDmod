local module = {}

module.bool_to_number = { [true]=1, [false]=0 }
-- Empty table that refers to currently playing looped sounds. Stops and destroys them if the entity they're playing from didnt die
module.looped_sounds = {}

function module.teleport_mount(ent, x, y)
    if ent.overlay ~= nil then
        move_entity(ent.overlay.uid, x, y, 0, 0)
    else
        move_entity(ent.uid, x, y, 0, 0)
    end
    -- ent.more_flags = clr_flag(ent.more_flags, 16)
    --set_camera_position(x, y)--wow this looks wrong, i think this auto-corrected at some point :/ (it was deprecated)
    state.camera.adjusted_focus_x = x
    state.camera.adjusted_focus_y = y
end

function module.rotate(cx, cy, x, y, degrees)
	local radians = degrees * (math.pi/180)
	local rx = math.cos(radians) * (x - cx) - math.sin(radians) * (y - cy) + cx
	local ry = math.sin(radians) * (x - cx) + math.cos(radians) * (y - cy) + cy
	local result = {rx, ry}
	return result
end

function module.file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function module.lines_from(file)
  if not module.file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function module.CompactList(list, prev_size)
	local j=0
	for i=1,prev_size do
		if list[i]~=nil then
			j=j+1
			list[j]=list[i]
		end
	end
	for i=j+1,prev_size do
		list[i]=nil
	end
	return list
end

function module.TableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

--Use key = next(t)
--function module.TableFirstKey(t)

--Use _, value = next(t)
--function module.TableFirstValue(t)

function module.TableCopyRandomElement(tbl)
	return module.TableCopy(tbl[math.random(#tbl)])
end

---appends elements of t2 to t1 and returns t1
function module.TableConcat(t1, t2)
	for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function module.has(arr, item)
    for _, v in pairs(arr) do
        if v == item then
            return true
        end
    end
    return false
end

function module.map(tbl, f)
	local t = {}
	for k, v in ipairs(tbl) do
		t[k] = f(v)
	end
	return t
end

function module.TableCopy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[module.TableCopy(k, s)] = module.TableCopy(v, s) end
  return res
end

function module.setn(t,n)
	setmetatable(t,{__len=function() return n end})
end

function module.shake_camera(countdown_start, countdown, amplitude, multiplier_x, multiplier_y, uniform_shake)
  state.camera.shake_countdown_start = countdown_start
  state.camera.shake_countdown = countdown
  state.camera.shake_amplitude = amplitude
  state.camera.shake_multiplier_x = multiplier_x
  state.camera.shake_multiplier_y = multiplier_y
  state.camera.uniform_shake = uniform_shake
end
-- This function is better than the built-in API one because it properly supports looping sounds and returns the audio object for future adjustments
function module.play_vanilla_sound(snd, uid, volume, loops)
  local ent = get_entity(uid)
  local sound = get_sound(snd)
  local audio = sound:play(true)
  local x, y, _ = get_position(ent.uid)
  local sx, sy = screen_position(x, y)
  local cx, cy = state.camera.adjusted_focus_x, state.camera.adjusted_focus_y
  local d = screen_distance(math.abs(math.sqrt((sx-cx)^2+(sy-cy)^2)))
  if get_entity(state.camera.focused_entity_uid) ~= nil then
    d = screen_distance(distance(ent.uid, state.camera.focused_entity_uid))
  end
  audio:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx))
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy))
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
  audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, volume)
  -- if this is a looped sound, set that up
  if loops then
    -- update the sound volume using the entities statemachine
    ent:set_post_update_state_machine(function()
      module.update_vanilla_sound(audio, uid, volume)
    end)
    -- stop the loop when the entity dies
    ent:set_pre_kill(function(self)
      audio:stop(true)  
    end)
  end
  audio:set_pause(false, SOUND_TYPE.SFX)
  return audio
end
function module.update_vanilla_sound(snd, uid, volume)
  local ent = get_entity(uid)
  local x, y, _ = get_position(ent.uid)
  local sx, sy = screen_position(x, y)
  local cx, cy = state.camera.adjusted_focus_x, state.camera.adjusted_focus_y
  local d = screen_distance(math.abs(math.sqrt((sx-cx)^2+(sy-cy)^2)))
  if get_entity(state.camera.focused_entity_uid) ~= nil then
    d = screen_distance(distance(ent.uid, state.camera.focused_entity_uid))
  end
  snd:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx))
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy))
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
  snd:set_parameter(VANILLA_SOUND_PARAM.VALUE, volume)
end
-- Vanilla sounds aren't fmod events that have parameters so we need to set them up differently
function module.play_custom_sound(snd, uid, volume, loops)
  local ent = get_entity(uid)
  local audio = nil
  audio = snd:play(false)
  local x, y, _ = get_position(ent.uid)
  local sx, sy = screen_position(x, y)
  local cx, cy = state.camera.adjusted_focus_x, state.camera.adjusted_focus_y
  local d = screen_distance(math.abs(math.sqrt((sx-cx)^2+(sy-cy)^2)))
  if get_entity(state.camera.focused_entity_uid) ~= nil then
    d = screen_distance(distance(ent.uid, state.camera.focused_entity_uid))
  end
  -- Setup pan and volume since we cant use fmod audio parameters
  module.update_custom_sound(audio, uid, volume)
  -- If this is a looped sound, set that up
  if loops then
    audio:set_looping(SOUND_LOOP_MODE.LOOP)
    -- update the sound volume using the entities statemachine
    ent:set_post_update_state_machine(function()
      module.update_custom_sound(audio, uid, volume)
    end)
    -- stop the loop when the entity dies
    ent:set_pre_kill(function(self)
      audio:stop(true)  
    end)
  end
  audio:set_pause(false, SOUND_TYPE.SFX)
  return audio
end
function module.update_custom_sound(snd, uid, volume)
  -- Setup sound
  local ent = get_entity(uid)
  local x, y, _ = get_position(ent.uid)
  local sx, sy = screen_position(x, y)
  local fx, _, _ = 0, 0, 0
  local cx, cy = state.camera.adjusted_focus_x, state.camera.adjusted_focus_y
  local d = screen_distance(math.abs(math.sqrt((sx-cx)^2+(sy-cy)^2)))
  local td = math.abs(math.sqrt((sx-cx)^2+(sy-cy)^2))
  fx = state.camera.adjusted_focus_x
  if get_entity(state.camera.focused_entity_uid) ~= nil then
    d = screen_distance(distance(ent.uid, state.camera.focused_entity_uid))
    td = distance(ent.uid, state.camera.focused_entity_uid)
    fx, _ ,_ = get_position(state.camera.focused_entity_uid)
  end
  -- Set panning / volume
  if td > 2 then
    snd:set_pan(((x-fx)/15))
  else
    snd:set_pan(0)
  end
  if td > 3 then
    snd:set_volume(volume-(((distance(uid, state.camera.focused_entity_uid)/15)*volume)))
    if volume-(((distance(uid, state.camera.focused_entity_uid)/15)*volume)) <= 0 then
      snd:set_volume(0)
    end
  else
    snd:set_volume(volume)
  end
end
-- Stop looped sounds that may or may not be playing
function module.clear_looped_sounds()
  for _, audio in ipairs(module.looped_sounds) do
      audio:stop(true)
  end
  module.looped_sounds = {}
end
set_callback(module.clear_looped_sounds, ON.TRANSITION)
set_callback(module.clear_looped_sounds, ON.PRE_LEVEL_GENERATION)

-- This function is deprecated and should not be used
function module.play_sound_at_entity(snd, uid, volume, sound_loops, amplitude)
  message('play_sound_at_entity is old, you should be using play_vanilla_sound or play_custom_sound but ig i cant stop you :)')
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
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx)*1.5)
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy)*1.5)
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
  audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
  audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, v)
  
  audio:set_pause(false)

  return audio 
end
function module.update_sound_volume(snd, uid, volume, amplitude)
  local v = 0.5
  if volume ~= nil then
      v = volume
  end
  local ent = get_entity(uid)
  local x, y, _ = get_position(ent.uid)
  local sx, sy = screen_position(x, y)
  local d = screen_distance(distance(ent.uid, ent.uid))
  if players[1] ~= nil then
      d = screen_distance(distance(ent.uid, players[1].uid))
  end
  snd:set_pan(d)
  snd:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx)*1.5)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy)*1.5)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
  snd:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
  snd:set_parameter(VANILLA_SOUND_PARAM.VALUE, v)
end

-- Useful for doing animations, check if an entity is within a certain distance of another, etc.
function module.in_range(x, y1, y2)
  if x >= y1 and x <= y2 then
      return true
  end
  return false
end

return module