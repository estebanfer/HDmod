local module = {}

--[[
	Coordinates of each floor:
	Top:	x = 13..32,	y = 112
	Middle:	x = 13..32,	y = 109
	Bottom:	x = 5..40,	y = 101
]]
local function testroom_level_1()

end

local function testroom_level_2()
	
end

set_callback(function()
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
		if state.level == 1 then
			testroom_level_1()
		elseif state.level == 2 then
			testroom_level_2()
		end
	end
end, ON.LEVEL)

return module