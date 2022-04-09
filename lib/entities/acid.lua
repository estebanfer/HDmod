local module = {}

local ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds
local acid_tick = ACID_POISONTIME

function module.init()
	acid_tick = ACID_POISONTIME
end

set_callback(function()
	-- Worm LEVEL
	if state.theme == THEME.EGGPLANT_WORLD then
		-- Acid damage
		for _, player in ipairs(players) do
			-- local spelunker_mov = get_entity(player):as_movable()
			local spelunker_swimming = test_flag(player.more_flags, 11)
			local poisoned = player:is_poisoned()
			local x, y, l = get_position(player.uid)
			if spelunker_swimming and player.health ~= 0 and not poisoned then
				if acid_tick <= 0 then
					spawn(ENT_TYPE.ITEM_ACIDSPIT, x, y, l, 0, 0)
					acid_tick = ACID_POISONTIME
				else
					acid_tick = acid_tick - 1
				end
			else
				acid_tick = ACID_POISONTIME
			end
		end
	end
end, ON.FRAME)


set_callback(function()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_interval(function()
            local fx = get_entities_by_type(ENT_TYPE.FX_WATER_SURFACE)
            for _,v in ipairs(fx) do
                local x, y, l = get_position(v)
                if math.random() < 0.003 then
                    spawn_entity(ENT_TYPE.ITEM_ACIDBUBBLE, x, y, l, 0, 0)
                end
            end 
        end, 35) -- 15)
	end
end, ON.LEVEL)

return module