local module = {}

module.HD_WORLDSTATE_STATUS = { ["NORMAL"] = 1, ["TUTORIAL"] = 2, ["TESTING"] = 3}
module.HD_WORLDSTATE_STATE = module.HD_WORLDSTATE_STATUS.NORMAL

---@param draw_ctx GuiDrawContext
set_callback(function(draw_ctx)
	if (
		options.hd_debug_info_worldstate == true
		and (state.pause == 0 and (state.screen == 11 or state.screen == 12))
	) then
		local text_x = -0.95
		local text_y = -0.37
		local white = rgba(255, 255, 255, 255)
		local green = rgba(55, 200, 75, 255)

		local hd_worldstate_debugtext_status = "UNKNOWN"
		local color = white

		-- worldlib.HD_WORLDSTATE_STATE
		if worldlib.HD_WORLDSTATE_STATE ~= nil then
			if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
				hd_worldstate_debugtext_status = "NORMAL"
			elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
				hd_worldstate_debugtext_status = "TUTORIAL"
				color = green
			elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
				hd_worldstate_debugtext_status = "TESTING"
				color = green
			end
		end
		draw_ctx:draw_text(text_x, text_y, 0, "HD_WORLDSTATE_STATE: " .. hd_worldstate_debugtext_status, color)

		text_y = text_y-0.1
		color = white

		-- door uid
		if camplib.DOOR_TUTORIAL_UID ~= nil and camplib.DOOR_TUTORIAL_UID >= 0 then color = green end
		draw_ctx:draw_text(text_x, text_y, 0, "DOOR_TUTORIAL_UID: " .. tostring(camplib.DOOR_TUTORIAL_UID), color)

		text_y = text_y-0.1
		color = white

		-- overlaps with player 1
		local door_entrance_ent = get_entity(camplib.DOOR_TUTORIAL_UID)
		local door_testing_entered_text = "false"
		if door_entrance_ent:overlaps_with(get_entity(players[1].uid)) == true then
			door_testing_entered_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_ctx:draw_text(text_x, text_y, 0, "OVERLAPS_WITH: " .. door_testing_entered_text, color)
		
		text_y = text_y-0.1
		color = white

		-- if player 1 state is entering
		local player_entering_text = "false"
		if players[1].state == CHAR_STATE.ENTERING then
			player_entering_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_ctx:draw_text(text_x, text_y, 0, "players[1].state == CHAR_STATE.ENTERING: " .. player_entering_text, color)

	end
end, ON.GUIFRAME)

return module