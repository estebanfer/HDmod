local bacteriumlib = require 'lib.entities.bacterium'
local celib = require 'lib.entities.custom_entities'
local module = {}

local DIR <const> = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
local DIR_ANGLE <const> = {math.pi, math.pi/2, 0, -math.pi/2}

local function spawn_eggsac(x, y, l, dir_i)
	local off_x, off_y = table.unpack(DIR[dir_i])
	local uid = spawn_over(ENT_TYPE.ITEM_EGGSAC, get_grid_entity_at(x+off_x, y+off_y, l), -off_x, -off_y)
	get_entity(uid).angle = DIR_ANGLE[dir_i]

	---Prevent collision with bacterium
	---@param eggsac EggSac
	---@param collider Movable
	set_pre_collision2(uid, function (eggsac, collider)
		if celib.get_custom_entity(collider.uid, bacteriumlib.id) then
			return true
		end
		return false
	end)
end

function module.create_eggsac(x, y, l)
	for dir_i, dir in ipairs(DIR) do
		local off_x, off_y = table.unpack(dir)
		if test_flag(get_entity_flags(get_grid_entity_at(x+off_x, y+off_y, l)), ENT_FLAG.SOLID) then
			spawn_eggsac(x, y, l, dir_i)
			return
		end
	end
	spawn_eggsac(x, y, l, 1)
end

return module