local module = {}

module.GHOST_TIME = 10800
GHOST_VELOCITY = 0.7
DANGER_GHOST_UIDS = {}

function module.init()
	DANGER_GHOST_UIDS = {}
end

set_callback(function()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
	) then
		set_ghost_spawn_times(module.GHOST_TIME, module.GHOST_TIME-1800)
	elseif(
		worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.NORMAL
		or feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
	) then
		set_ghost_spawn_times(-1, -1)
	end
end, ON.LEVEL)

set_callback(function()
	ghost_uids = get_entities_by_type({
		ENT_TYPE.MONS_GHOST
	})
	ghosttoset_uid = 0
	for _, found_ghost_uid in ipairs(ghost_uids) do
		accounted = 0
		for _, cur_ghost_uid in ipairs(DANGER_GHOST_UIDS) do
			if found_ghost_uid == cur_ghost_uid then accounted = cur_ghost_uid end
			
			ghost = get_entity(found_ghost_uid):as_ghost()
			-- message("timer: " .. tostring(ghost.split_timer) .. ", v_mult: " .. tostring(ghost.velocity_multiplier))
			if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		end
		if accounted == 0 then ghosttoset_uid = found_ghost_uid end
	end
	if ghosttoset_uid ~= 0 then
		ghost = get_entity(ghosttoset_uid):as_ghost()
		
		if (options.hd_og_ghost_slow_enable == true) then ghost.velocity_multiplier = GHOST_VELOCITY end
		if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		
		DANGER_GHOST_UIDS[#DANGER_GHOST_UIDS+1] = ghosttoset_uid
	end
end, ON.FRAME)

return module