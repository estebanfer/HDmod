local module = {}

local function applyflags_to_quest(flags)
    if #flags > 0 then
        local flags_set = flags[1]
        for _, flag in ipairs(flags_set) do
            state.quest_flags = set_flag(state.quest_flags, flag)
        end
        if #flags > 1 then
            local flags_clear = flags[2]
            for _, flag in ipairs(flags_clear) do
                state.quest_flags = clr_flag(state.quest_flags, flag)
            end
        end
    else message("No quest flags") end
end

-- prevent dark levels for specific states
function module.clear_dark_level()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
		or worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING
		or state.theme == THEME.VOLCANA
		or state.theme == THEME.NEO_BABYLON
		or feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == true
	) then
		state.level_flags = clr_flag(state.level_flags, 18)
	end
end

local function changestate_onloading_targets(w_a, l_a, t_a, w_b, l_b, t_b)
	if roomgenlib.detect_same_levelstate(t_a, l_a, w_a) == true then
		-- if t_b == THEME.BASE_CAMP then
		-- 	state.screen_next = ON.CAMP
		-- end
		if test_flag(state.quest_flags, 1) == false then
			state.level_next = l_b
			state.world_next = w_b
			state.theme_next = t_b
			if t_b == THEME.BASE_CAMP then
				state.screen_next = ON.CAMP
			end
			-- if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
			-- 	state.screen_next = ON.LEVEL
			-- end
		end
	end
end

-- Used to "fake" world/theme/level
local function changestate_onlevel_fake(w_a, l_a, t_a, w_b, l_b, t_b)
	if roomgenlib.detect_same_levelstate(t_a, l_a, w_a) == true then
		state.level = l_b
		state.world = w_b
		state.theme = t_b
	end
end

local function changestate_samelevel_applyquestflags(w_a, l_a, t_a, flags_set, flags_clear)--w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if roomgenlib.detect_same_levelstate(t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
	end
end


-- # TODO: Revise `applyflags_to_*` method's `flags` parameter.
	-- From this:
		-- flags = {
			-- {ENT_FLAG.NO_GRAVITY},					-- set
			-- {ENT_FLAG.SOLID, ENT_FLAG.PICKUPABLE}	-- clear
		-- }
	-- To this:
		-- flags = {
			-- [ENT_FLAG.SOLID] = false,
			-- [ENT_FLAG.NO_GRAVITY] = true,
			-- [ENT_FLAG.PICKUPABLE] = false
		-- }
local function applyflags_to_level(flags)
    if #flags > 0 then
        local flags_set = flags[1]
        for _, flag in ipairs(flags_set) do
            state.level_flags = set_flag(state.level_flags, flag)
        end
        if #flags > 1 then
            local flags_clear = flags[2]
            for _, flag in ipairs(flags_clear) do
                state.level_flags = clr_flag(state.level_flags, flag)
            end
        end
    else message("No level flags") end
end

-- LEVEL HANDLING
local function onloading_levelrules()
	
	--[[
		Tutorial
	--]]
	
	-- Tutorial 1-3 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL) then
		changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
		changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
		changestate_onloading_targets(1,3,THEME.DWELLING,1,1,THEME.BASE_CAMP)
		return
	end
	
	--[[
		Testing
	--]]
	
	-- Testing 1-2 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING) then
		changestate_onloading_targets(1,1,state.theme,1,2,state.theme)
		changestate_onloading_targets(1,2,state.theme,1,1,THEME.BASE_CAMP)
		return
	end

	-- --[[
	-- 	Mines
	-- --]]

	-- -- Mines 1-1..3
    -- changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
    -- changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
	
	-- -- Mines 1-3 -> Mines 1-5(Fake 1-4)
    -- changestate_onloading_targets(1,3,THEME.DWELLING,1,5,THEME.DWELLING)

    -- -- Mines -> Jungle
    changestate_onloading_targets(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)

	-- --[[
	-- 	Jungle
	-- --]]

	-- -- Jungle 2-1..4
    -- changestate_onloading_targets(2,1,THEME.JUNGLE,2,2,THEME.JUNGLE)
    -- changestate_onloading_targets(2,2,THEME.JUNGLE,2,3,THEME.JUNGLE)
    -- changestate_onloading_targets(2,3,THEME.JUNGLE,2,4,THEME.JUNGLE)

    -- -- Jungle -> Ice Caves
    -- changestate_onloading_targets(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)

	-- --[[
	-- 	Worm
	-- --]]

	-- -- Worm(Jungle) 2-2 -> Jungle 2-4
	-- -- # TOTEST: Re-adjust level loading (remove changestate_onloading_targets() where scripted levelgen entrance doors take over)
	-- changestate_onloading_targets(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
	
	-- -- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	-- changestate_onloading_targets(3,2,THEME.EGGPLANT_WORLD,3,4,THEME.ICE_CAVES)

    
	-- --[[
	-- 	Ice Caves
	-- --]]
	-- 	-- # TOTEST: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
		
	-- -- Ice Caves 3-1..4
    -- changestate_onloading_targets(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
	
    -- -- Ice Caves -> Temple
    -- changestate_onloading_targets(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)

	-- --[[
	-- 	Mothership
	-- --]]
	
	-- -- Mothership(3-3) -> Ice Caves(3-4)
    -- changestate_onloading_targets(3,3,THEME.NEO_BABYLON,3,4,THEME.ICE_CAVES)
	
	-- --[[
	-- 	Temple
	-- --]]
	
	-- -- Temple 4-1..3
    -- changestate_onloading_targets(4,1,THEME.TEMPLE,4,2,THEME.TEMPLE)
    -- changestate_onloading_targets(4,2,THEME.TEMPLE,4,3,THEME.TEMPLE)

    -- -- Temple -> Olmec
    -- changestate_onloading_targets(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	City Of Gold
	-- --]]

    -- -- COG(4-3) -> Olmec
    -- changestate_onloading_targets(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	Hell
	-- --]]

    -- changestate_onloading_targets(5,1,THEME.VOLCANA,5,2,THEME.VOLCANA)
    -- changestate_onloading_targets(5,2,THEME.VOLCANA,5,3,THEME.VOLCANA)

	-- -- Hell -> Yama
	-- 	-- Build Yama in Tiamat's chamber.
	-- changestate_onloading_targets(5,3,THEME.VOLCANA,5,4,THEME.TIAMAT)

	-- if (
	-- 	state.screen_next == SCREEN.TRANSITION
	-- ) then
	-- 	message(F'onloading_levelrules(): Set loading target: state.*_next: s{state.screen_next}, w{state.world_next}, l{state.level_next}, t{state.theme_next}')
	-- end


	-- Demo Handling
	if (
		not options.hd_debug_demo_enable_all_worlds
		and state.level == 4
		and state.level_next == 1
		and state.world == demolib.DEMO_MAX_WORLD
		and state.screen_next == SCREEN.TRANSITION
	) then
		changestate_onloading_targets(state.world,state.level,state.theme,1,1,THEME.BASE_CAMP)
		set_global_timeout(function()
			if state.screen ~= ON.LEVEL then toast("Demo over. Thanks for playing!") end
		end, 30)
	end

end

-- executed with the assumption that onloading_levelrules() has already been run, applying state.*_next
local function onloading_applyquestflags()
	local flags_failsafe = {
		10, -- Disable Waddler's
		25, 26, -- Disable Moon and Star challenges.
		19 -- Disable drill -- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
	}
	for i = 1, #flags_failsafe, 1 do
		if test_flag(state.quest_flags, flags_failsafe[i]) == false then state.quest_flags = set_flag(state.quest_flags, flags_failsafe[i]) end
	end
end


-- LEVEL HANDLING
-- For cases where room generation is hardcoded to a theme's level
-- and as a result we need to fake the world/level number
local function onlevel_levelrules()
	-- Dwelling 1-5 = 1-4 (Dwelling 1-3 -> Dwelling 1-4)
	-- changestate_onlevel_fake(1,5,THEME.DWELLING,1,4,THEME.DWELLING)
	
	-- TOTEST:
	-- Use S2 Black Market as Flooded Feeling
		-- HD and S2 differences:
			-- S2 black market spawns are 2-2..4
			-- HD spawns are 2-1..3
				-- Prevents the black market from being accessed upon exiting the worm
				-- Gives room for the next level to load as black market

	-- Disable dark levels and vaults "before" you enter the world:
		-- Technically load into a total of 4 hell levels; 5-5 and 5-1..3
		-- on.load 5-5, set state.quest_flags 3 and 2, then warp the player to 5-1
		
		-- -- Jungle 2-0 = 2-1
		-- -- Disable Moon challenge.
		-- changestate_onlevel_fake_applyquestflags(2,1,THEME.JUNGLE, {25}, {})
		-- -- Ice Caves 3-0 = 3-1
		-- -- Disable Waddler's
		-- changestate_onlevel_fake_applyquestflags(3,1,THEME.ICE_CAVES, {10}, {})
		-- -- Temple 4-0 = 4-1
		-- -- Disable Star challenge.
		-- changestate_onlevel_fake_applyquestflags(4,1,THEME.TEMPLE, {26}, {})
		-- -- Volcana 5-5 = 5-1
		-- -- Disable Moon challenge and drill
		-- 	-- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
		-- changestate_onlevel_fake_applyquestflags(5,1,THEME.VOLCANA, {19, 25}, {})
		
	-- -- Volcana 5-1 -> Volcana 5-2
	-- changestate_onlevel_fake(5,5,THEME.VOLCANA,5,2,THEME.VOLCANA)
	-- -- Volcana 5-2 -> Volcana 5-3
	-- changestate_onlevel_fake(5,6,THEME.VOLCANA,5,3,THEME.VOLCANA)
end

set_callback(function()
	set_timeout(onlevel_levelrules, 20)
end, ON.LEVEL)

-- ON.START
set_callback(function()
	-- Enable S2 udjat eye, S2 black market, and drill spawns to prevent them from spawning.
	changestate_samelevel_applyquestflags(state.world, state.level, state.theme, {17, 18, 19}, {})
end, ON.START)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
	onloading_applyquestflags()
end, ON.LOADING)

return module