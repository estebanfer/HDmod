-- commonlib = require 'common'
-- wormtonguelib = require 'entities.wormtongue'

local module = {}

optionslib.register_option_bool("hd_debug_feelings_toast_disable", "Feelings - Disable script-enduced toasts", nil, false, true)
optionslib.register_option_bool("hd_debug_feelings_info", "Feelings - Show info", nil, false, true)

module.FEELING_ID = {
    UDJAT = 1,
    WORMTONGUE = 2,
    SPIDERLAIR = 3,
    SNAKEPIT = 4,
    RESTLESS = 5,
    RUSHING_WATER = 6,
    HIVE = 7,
    TIKIVILLAGE = 8,
    BLACKMARKET_ENTRANCE = 9,
    BLACKMARKET = 10,
    HAUNTEDCASTLE = 11,
    YETIKINGDOM = 12,
    UFO = 13,
    MOAI = 14,
    MOTHERSHIP_ENTRANCE = 15,
    SACRIFICIALPIT = 16,
    VLAD = 17,
    VAULT = 18,
    SNOW = 19,
    ICE_CAVES_POOL = 20,
    ANUBIS = 21,
    YAMA = 22
}

module.HD_FEELING_DEFAULTS = {
	[module.FEELING_ID.HIVE] = {
		chance = 10,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.UDJAT] = {
		themes = { THEME.DWELLING }
	},
	[module.FEELING_ID.WORMTONGUE] = {
		themes = { THEME.JUNGLE, THEME.ICE_CAVES }
	},
	[module.FEELING_ID.SPIDERLAIR] = {
		chance = 12,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.DWELLING },
		message = "My skin is crawling..."
	},
	[module.FEELING_ID.SNAKEPIT] = {
		chance = 10,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.DWELLING },
		message = "I hear snakes... I hate snakes!"
	},
	[module.FEELING_ID.RESTLESS] = {
		chance = 12,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.JUNGLE },
		message = "The dead are restless!"
	},
	[module.FEELING_ID.TIKIVILLAGE] = { -- RESIDENT TIK-EVIL: VILLAGE
		chance = 15,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.RUSHING_WATER] = {
		chance = 14,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.JUNGLE },
		message = "I hear rushing water!"
	},
	[module.FEELING_ID.BLACKMARKET_ENTRANCE] = {
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.BLACKMARKET] = {
		themes = { THEME.JUNGLE },
		message = "Welcome to the Black Market!"
	},
	[module.FEELING_ID.HAUNTEDCASTLE] = {
		themes = { THEME.JUNGLE },
		message = "A wolf howls in the distance..."
	},
	[module.FEELING_ID.YETIKINGDOM] = {
		chance = 10,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "It smells like wet fur in here."
	},
	[module.FEELING_ID.UFO] = {
		chance = 12,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "I sense a psychic presence here!"
	},
	[module.FEELING_ID.MOAI] = {
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.MOTHERSHIP_ENTRANCE] = {
		themes = { THEME.ICE_CAVES },
		message = "It feels like the fourth of July..."
	},
	[module.FEELING_ID.SACRIFICIALPIT] = {
		chance = 10,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.TEMPLE },
		message = "You hear prayers to Kali!"
	},
	[module.FEELING_ID.VLAD] = {
		themes = { THEME.VOLCANA },
		load = 1,
		message = "A horrible feeling of nausea comes over you!"
	},
	[module.FEELING_ID.YAMA] = {
		themes = { THEME.VOLCANA },
		load = 4
	},
	[module.FEELING_ID.VAULT] = {
		themes = {
			THEME.DWELLING,
			THEME.JUNGLE,
			THEME.ICE_CAVES,
			THEME.TEMPLE
		}
	},
	[module.FEELING_ID.SNOW] = {
		chance = 4,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.ICE_CAVES_POOL] = {
		chance = 15,
		-- chance = 1,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.ANUBIS] = {
		themes = { THEME.TEMPLE },
		load = 1,
	},
}

local global_feelings = nil
local MESSAGE_FEELING = nil
local tongue_spawned = false
local worm_visited = false
local mothership_visited = false

-- Should be used at the start of a run or warping into a run as a part of testing.
function module.init()
	global_feelings = commonlib.TableCopy(module.HD_FEELING_DEFAULTS)
	tongue_spawned = false
	worm_visited = false
	mothership_visited = false
end

set_callback(function()
	-- pre_tile ON.START
	global_feelings = nil
end, ON.CAMP)

set_callback(function()
	-- pre_tile ON.START
	global_feelings = nil
end, ON.RESET)

-- if multiple levels are passed in, a random level in the table is set
	-- NOTE: won't set to a past level
local function feeling_set(feeling, levels)
	local chance = 1
	if global_feelings[feeling].chance ~= nil then
		chance = global_feelings[feeling].chance
	end
	if chance ~= 0 then
		if math.random(1, chance) == 1 then
			local levels_indexed = {}
			for _, level in ipairs(levels) do
				if level >= state.level then
					levels_indexed[#levels_indexed+1] = level
				end
			end
			global_feelings[feeling].load = levels_indexed[math.random(1, #levels_indexed)]
			return true
		else return false end
	end
end

local function detect_feeling_themes(feeling)
	for _, feeling_theme in ipairs(global_feelings[feeling].themes) do
		if state.theme == feeling_theme then
			return true
		end
	end
	return false
end

-- -- won't set if already set to the current level or a past level
-- function feeling_set_once_future(feeling, levels, use_chance)
	-- if ( -- don't set it if it's on the correct theme and the level is set and it's set to the current level or a past level
		-- detect_feeling_themes(feeling) == false or
		-- (
			-- global_feelings[feeling].load ~= nil and
			-- global_feelings[feeling].load <= state.level
		-- )
	-- ) then return false
	-- else
		-- return feeling_set(feeling, levels, use_chance)
	-- end
-- end
-- won't set if the current theme doesn't match and load has already been set
function module.feeling_set_once(feeling, levels)
	if (
		detect_feeling_themes(feeling) == false or
		global_feelings[feeling].load ~= nil
	) then return false
	else
		return feeling_set(feeling, levels)
	end
end

function module.feeling_check(feeling)
	if (
		detect_feeling_themes(feeling) == true and
		state.level == global_feelings[feeling].load
	) then return true end
	return false
end


-- Set level feelings (not to be confused with `feeling_set`)
function module.onlevel_set_feelings()
	-- at the start of each world, reset all feelings
	if state.level == 1 then
		global_feelings = commonlib.TableCopy(module.HD_FEELING_DEFAULTS)
	end

	-- Vaults
	if state.theme ~= THEME.VOLCANA then
		module.feeling_set_once(module.FEELING_ID.VAULT, state.theme == THEME.DWELLING and {2, 3, 4} or {1, 2, 3, 4})
	elseif state.theme == THEME.TEMPLE then
		module.feeling_set_once(module.FEELING_ID.VAULT, {1, 2, 3})
	end
	
	--[[
		Mines
	--]]
	if state.theme == THEME.DWELLING then
		-- placing chest and key on levels 2..4
		if state.level == 2 then
			module.feeling_set_once(module.FEELING_ID.UDJAT, {2, 3, 4})
		end

		if (
			state.level >= 3
		) then
			feeling_set(module.FEELING_ID.SPIDERLAIR, {state.level})
		end

		-- spiderlair and snakepit cannot happen at the same time
		if (
			module.feeling_check(module.FEELING_ID.SPIDERLAIR) == false
			and state.level ~= 1
		) then
			feeling_set(module.FEELING_ID.SNAKEPIT, {state.level})
		end
	end
	--[[
		Jungle
	--]]
	if state.theme == THEME.JUNGLE then

		if state.level == 1 then
			module.feeling_set_once(module.FEELING_ID.BLACKMARKET_ENTRANCE, {1, 2, 3})
		end

		-- Restless cannot happen on haunted castle
		if module.feeling_check(module.FEELING_ID.HAUNTEDCASTLE) == false then
			feeling_set(module.FEELING_ID.RESTLESS, {state.level})
			feeling_set(module.FEELING_ID.HIVE, {state.level})
		end

		-- Haunted Castle and Black Market cannot have rushing water nor tikivillage
		if (
			module.feeling_check(module.FEELING_ID.HAUNTEDCASTLE) == false
			and module.feeling_check(module.FEELING_ID.BLACKMARKET) == false
		) then
			feeling_set(module.FEELING_ID.RUSHING_WATER, {state.level})
			
			-- tikivillage levels cannot be restless
			-- tikivillage and rushing water cannot happen at the same time
			if (
				module.feeling_check(module.FEELING_ID.RESTLESS) == false and
				module.feeling_check(module.FEELING_ID.RUSHING_WATER) == false
			) then
				feeling_set(module.FEELING_ID.TIKIVILLAGE, {state.level})
			end
		end
	end
	
	--[[
		Worm
	]]
	if state.theme == THEME.EGGPLANT_WORLD then
		worm_visited = true
	end

	-- Worm Tongue
	if (
		tongue_spawned == false
		and state.level == 1
		and (
			state.theme == THEME.JUNGLE or
			state.theme == THEME.ICE_CAVES
		)
		and module.feeling_check(module.FEELING_ID.RESTLESS) == false
	) then
		module.feeling_set_once(module.FEELING_ID.WORMTONGUE, {1})
		tongue_spawned = true
	end

	--[[
		Ice Caves
	--]]
	if state.theme == THEME.ICE_CAVES then
		
		feeling_set(module.FEELING_ID.SNOW, {state.level})

		if state.level == 2 then
			module.feeling_set_once(module.FEELING_ID.MOAI, {2, 3})
		end
		
		if state.level == 4 then
			if global_feelings[module.FEELING_ID.MOTHERSHIP_ENTRANCE].load == nil then
				-- This level feeling only, and always, occurs on level 3-4.
					-- The entrance to Mothership sends you to 3-3 with THEME.NEO_BABYLON.
					-- When you exit, you will return to the beginning of 3-4 and be forced to do the level again before entering the Temple.
					-- Only available once in a run
				module.feeling_set_once(module.FEELING_ID.MOTHERSHIP_ENTRANCE, {state.level})
			else
				global_feelings[module.FEELING_ID.MOTHERSHIP_ENTRANCE].load = nil
				if (worm_visited and mothership_visited) then
					feeling_set(module.FEELING_ID.MOAI, {4})
				else 
					feeling_set(module.FEELING_ID.YETIKINGDOM, {state.level})
				end
			end
		end
		
		if (
			module.feeling_check(module.FEELING_ID.MOAI) == false
			and state.level ~= 4
		) then
			feeling_set(module.FEELING_ID.YETIKINGDOM, {state.level})
		end
		
		if (
			module.feeling_check(module.FEELING_ID.YETIKINGDOM) == false
			and state.level ~= 4
		) then
			feeling_set(module.FEELING_ID.UFO, {state.level})
		end
		
		if (
			module.feeling_check(module.FEELING_ID.YETIKINGDOM) == false
			and module.feeling_check(module.FEELING_ID.UFO) == false
		) then
			feeling_set(module.FEELING_ID.ICE_CAVES_POOL, {state.level})
		end
	end
	--[[
		Temple
	--]]
	if state.theme == THEME.TEMPLE then
		feeling_set(module.FEELING_ID.SACRIFICIALPIT, {state.level})
	end
	--[[
		Mothership
	]]
	if state.theme == THEME.NEO_BABYLON then
		mothership_visited = true
	end
	
	-- Currently hardcoded but keeping this here just in case
	--[[
		Hell
	--]]
	-- if state.theme == THEME.VOLCANA and state.level == 1 then
		-- feeling_set(module.FEELING_ID.VLAD, {state.level})
	-- end
end

function module.onlevel_set_feelingToastMessage()
	-- theme message priorities are here (ie; rushingwater over restless)
	-- NOTES:
		-- Black Market, COG and Beehive are currently handled by the game
	
	local loadchecks = commonlib.TableCopy(global_feelings)
	
	local n = #loadchecks
	for feelingname, loadcheck in pairs(loadchecks) do
		if (
			-- detect_feeling_themes(feelingname) == false or
			-- (
				-- detect_feeling_themes(feelingname) == true and
				-- (
					-- (loadcheck.load == nil or loadcheck.message == nil) or
					-- (module.feeling_check(feelingname))
				-- )
			-- )
			module.feeling_check(feelingname) == false
		) then loadchecks[feelingname] = nil end
	end
	loadchecks = commonlib.CompactList(loadchecks, n)
	
	MESSAGE_FEELING = nil
	for feelingname, feeling in pairs(loadchecks) do
		-- Message Overrides may happen here:
		-- For example:
			-- if feelingname == module.FEELING_ID.RUSHING_WATER and module.feeling_check(module.FEELING_ID.RESTLESS) == true then break end
		MESSAGE_FEELING = feeling.message
	end
end

function module.onlevel_toastfeeling()
	if (
		MESSAGE_FEELING ~= nil and
		options.hd_debug_feelings_toast_disable == false
	) then
		cancel_toast()
		set_timeout(function()
			toast(MESSAGE_FEELING)
		end, 1)
	end
end

-- prevent hardcoded levelfeeling messages from occurring, also handle construction sign messages
set_callback(function(text)
    if (
		text == "Your voice echoes in here..."
		or text == "You hear the beating of drums..."
		or text == "You hear the sounds of revelry!"
		or text == "You feel strangely at peace."
	) then -- this will only work when chosen language is English, unless you add all variants for all languages
        text = "" -- message won't be shown
	elseif (
		text == "Shortcut Station: Coming Soon! -Mama Tunnel"
		or text == "New shortcut coming soon! -Mama Tunnel"
	) then
		text = "Feature in development!"
    end
	return text
end, ON.TOAST)


---@params draw_ctx GuiDrawContext
set_callback(function(draw_ctx)
	if options.hd_debug_feelings_info == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		local text_x = -0.95
		local text_y = -0.35
		local white = rgba(255, 255, 255, 255)
		local green = rgba(55, 200, 75, 255)
		
		local text_levelfeelings = "No Level Feelings"
		local feelings = 0
		
		for feelingname, feeling in pairs(global_feelings) do
			if module.feeling_check(feelingname) == true then
				feelings = feelings + 1
			end
		end
		if feelings ~= 0 then text_levelfeelings = (tostring(feelings) .. " Level Feelings") end
		
		draw_ctx:draw_text(text_x, text_y, 0, text_levelfeelings, white)
		text_y = text_y-0.035
		local color = white
		if MESSAGE_FEELING ~= nil then color = green end
		local text_message_feeling = ("MESSAGE_FEELING: " .. tostring(MESSAGE_FEELING))
		draw_ctx:draw_text(text_x, text_y, 0, text_message_feeling, color)
		text_y = text_y-0.04
		for feelingname, feeling in pairs(global_feelings) do
			color = white
			local text_message = ""
			
			local feeling_bool = module.feeling_check(feelingname)
			if feeling.message ~= nil then text_message = (": \"" .. feeling.message .. "\"") end
			if feeling_bool == true then color = green end
			
			local text_feeling = (feelingname) .. text_message
			
			draw_ctx:draw_text(text_x, text_y, 0, text_feeling, color)
			text_y = text_y-0.032
		end

	end
end, ON.GUIFRAME)

return module