local module = {}

optionslib.register_option_bool("hd_og_ghost_nosplit_disable", "OG: Ghost - Allow the ghost to split", nil, false) -- Defaults to HD
optionslib.register_option_bool("hd_og_ghost_slow_enable", "OG: Ghost - Set the ghost to its HD speed", nil, false) -- Defaults to S2
optionslib.register_option_bool("hd_og_ghost_time_disable", "OG: Ghost - Use S2 spawn times",
	"Ghost appears at 3:00 instead of 2:30, or 2:30 instead of 2:00 when cursed.", false) -- Defaults to HD

local GHOST_TIME = 10800
local GHOST_VELOCITY = 0.7
local DANGER_GHOST_UIDS = {}

function module.init()
	DANGER_GHOST_UIDS = {}
end

set_callback(function()
	if options.hd_og_ghost_time_disable == false then GHOST_TIME = 9000 end
end, ON.START)

set_callback(function()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
	) then
		set_ghost_spawn_times(GHOST_TIME, GHOST_TIME-1800)
	elseif(
		worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.NORMAL
		or feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
	) then
		set_ghost_spawn_times(-1, -1)
	end
end, ON.LEVEL)

-- # TODO: Optimize this
set_callback(function()
	local ghost_uids = get_entities_by_type({
		ENT_TYPE.MONS_GHOST
	})
	local ghosttoset_uid = 0
	for _, found_ghost_uid in ipairs(ghost_uids) do
		local accounted = 0
		for _, cur_ghost_uid in ipairs(DANGER_GHOST_UIDS) do
			if found_ghost_uid == cur_ghost_uid then accounted = cur_ghost_uid end
			
			local ghost = get_entity(found_ghost_uid)
			-- message("timer: " .. tostring(ghost.split_timer) .. ", v_mult: " .. tostring(ghost.velocity_multiplier))
			if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		end
		if accounted == 0 then ghosttoset_uid = found_ghost_uid end
	end
	if ghosttoset_uid ~= 0 then
		local ghost = get_entity(ghosttoset_uid)
		
		if (options.hd_og_ghost_slow_enable == true) then ghost.velocity_multiplier = GHOST_VELOCITY end
		if (options.hd_og_ghost_nosplit_disable == false) then ghost.split_timer = 0 end
		
		DANGER_GHOST_UIDS[#DANGER_GHOST_UIDS+1] = ghosttoset_uid
	end
end, ON.FRAME)

return module