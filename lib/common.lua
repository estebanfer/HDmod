local module = {}

bool_to_number={ [true]=1, [false]=0 }

function module.teleport_mount(ent, x, y)
    if ent.overlay ~= nil then
        move_entity(ent.overlay.uid, x, y, 0, 0)
    else
        move_entity(ent.uid, x, y, 0, 0)
    end
    -- ent.more_flags = clr_flag(ent.more_flags, 16)
    set_camera_position(x, y)--wow this looks wrong, i think this auto-corrected at some point :/
end

function module.rotate(cx, cy, x, y, degrees)
	radians = degrees * (math.pi/180)
	rx = math.cos(radians) * (x - cx) - math.sin(radians) * (y - cy) + cx
	ry = math.sin(radians) * (x - cx) + math.cos(radians) * (y - cy) + cy
	result = {rx, ry}
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
  if not file_exists(file) then return {} end
  lines = {}
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

function module.TableFirstKey(t)
  local count = 0
  for k,_ in pairs(t) do return k end
  return nil
end

function module.TableFirstValue(t)
  local count = 0
  for _,v in pairs(t) do return v end
  return nil
end

function module.TableRandomElement(tbl)
	local t = {}
	if #tbl == 0 then return nil end
	for _, v in ipairs(tbl) do
		t[#t+1] = v
	end
	return t[math.random(1, #t)]
end

function module.TableConcat(t1, t2)
	for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function module.has(arr, item)
    for i, v in pairs(arr) do
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


return module