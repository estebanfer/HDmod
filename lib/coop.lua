local module = {}

COOP_COFFIN = false

function module.init()
	COOP_COFFIN = false
end

function module.detect_coop_coffin(room_gen_ctx)
	for y = 0, state.height - 1 do
		for x = 0, state.width - 1 do
			local room_template_here = get_room_template(x, y, 0)
			if (
				room_template_here == ROOM_TEMPLATE.COFFIN_PLAYER
				or room_template_here == ROOM_TEMPLATE.COFFIN_PLAYER_VERTICAL
			) then
				COOP_COFFIN = true
			end
		end
	end
end

function module.detect_level_allow_coop_coffin()
	return (
		COOP_COFFIN == true
		and roomgenlib.detect_level_non_boss()
		-- and state.theme ~= THEME.CITY_OF_GOLD
		and feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false
		and feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end


return module