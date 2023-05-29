local module = {}

module.bool_to_number = { [true]=1, [false]=0 }

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

function module.TableCopyRandomElement(tbl, prng_class)
	return module.TableCopy(tbl[prng:random_index(#tbl, prng_class)])
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

--This function isn't perfect yet but it's fine for now.
function module.play_sound_at_entity(snd, uid, volume)
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

-- When we use looped sounds, a function like this is useful for appropriately updating the panning and volume of a sound
function module.update_sound_volume(snd, uid, volume)
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

local function is_activefloor_at(x, y, layer)
  local hitbox = AABB:new(x - 0.05, y+0.05, x + 0.05, y - 0.05)
  local activefloors = get_entities_overlapping_hitbox(0, MASK.ACTIVEFLOOR, hitbox, layer)
  return activefloors[1] ~= nil
end
module.is_activefloor_at = is_activefloor_at

function module.is_solid_floor_at(x, y, layer)
  local floor = get_grid_entity_at(math.floor(x+0.5), math.floor(y+0.5), layer)
  if test_flag(get_entity_flags(floor), ENT_FLAG.SOLID) then return true end

  return is_activefloor_at(x, y, layer)
end

function module.is_standable_floor_at(x, y, layer)
  local floor = get_grid_entity_at(math.floor(x+0.5), math.floor(y+0.5), layer)
  local flags = get_entity_flags(floor)
  if floor ~= 0 and (test_flag(flags, ENT_FLAG.SOLID) or test_flag(flags, ENT_FLAG.IS_PLATFORM)) then
    return true
  end

  return is_activefloor_at(x, y, layer)
end

return module