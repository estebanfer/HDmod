local hdtypelib = require 'lib.entities.hdtype'
local module = {}

local HELL_Y = 86

local BOSS_SEQUENCE = { ["CUTSCENE"] = 1, ["FIGHT"] = 2, ["DEAD"] = 3 }
local BOSS_STATE = nil

local OLMEC_UID = nil
local OLMEC_SEQUENCE = { ["STILL"] = 1, ["FALL"] = 2 }
local OLMEC_STATE = 0

module.DOOR_ENDGAME_OLMEC_UID = nil

function module.init()
	BOSS_STATE = nil

	OLMEC_UID = nil
	OLMEC_STATE = 0

	module.DOOR_ENDGAME_OLMEC_UID = nil
end

local function cutscene_move_olmec_pre()
	local olmecs = get_entities_by_type(ENT_TYPE.ACTIVEFLOOR_OLMEC)
	if #olmecs > 0 then
		OLMEC_UID = olmecs[1]
		move_entity(OLMEC_UID, 24.500, 99.500, 0, 0)
	end
end

local function cutscene_move_olmec_post()
	move_entity(OLMEC_UID, 22.500, 98.500, 0, 0)
end

local function cutscene_move_cavemen()
	-- # TODO: OLMEC cutscene - Once custom hawkman AI is done:
	-- create a hawkman and disable his ai
	-- set_timeout() to reenable his ai and set his stuntimer.
	-- **does set_timeout() work during cutscenes?
		-- if not, use set_global_timeout
			-- set_timeout() accounts for pausing the game while set_global_timeout() does not
	-- **consider problems for skipping the cutscene
	local cavemen = get_entities_by_type(ENT_TYPE.MONS_CAVEMAN)
	for i, caveman in ipairs(cavemen) do
		move_entity(caveman, 17.500+i, 98.05, 0, 0)--99.05, 0, 0)
	end
end

function module.onlevel_olmec_init()
	if state.theme == THEME.OLMEC then
		BOSS_STATE = BOSS_SEQUENCE.CUTSCENE
		cutscene_move_olmec_pre()
		cutscene_move_cavemen()
		
		doorslib.create_door_ending(41, 98, LAYER.FRONT)--99, LAYER.FRONT)

		botdlib.set_hell_x()
		doorslib.create_door_exit_to_hell(botdlib.hell_x, HELL_Y, LAYER.FRONT)
	end
end

local function onframe_olmec_cutscene() -- **Move to set_interval() that you can close later
	local c_logics = get_entities_by_type(ENT_TYPE.LOGICAL_CINEMATIC_ANCHOR)
	if #c_logics > 0 then
		local c_logics_e = get_entity(c_logics[1])
		local dead = test_flag(c_logics_e.flags, ENT_FLAG.DEAD)
		if dead == true then
			-- If you skip the cutscene before olmec smashes the blocks, this will teleport him outside of the map and crash.
			-- kill the blocks olmec would normally smash.
			for b = 1, 4, 1 do
				local blocks = get_entities_at({ENT_TYPE.FLOORSTYLED_STONE, ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK}, 0, 21+b, 97, LAYER.FRONT, 0.5)--98, LAYER.FRONT, 0.5)
				if #blocks > 0 then
					kill_entity(blocks[1])
				end
				b = b + 1
			end
			cutscene_move_olmec_post()
			BOSS_STATE = BOSS_SEQUENCE.FIGHT
		end
	end
end

local function olmec_attack(x, y, l)
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.OLMEC_SHOT, x, y, l, false, 0, 150)
end

local function onframe_olmec_behavior()
	---@type Olmec
	local olmec = get_entity(OLMEC_UID)
	if olmec ~= nil then
		-- Enemy Spawning: Detect when olmec is about to smash down
		if olmec.velocityy > -0.400 and olmec.velocityx == 0 and OLMEC_STATE == OLMEC_SEQUENCE.FALL then
			OLMEC_STATE = OLMEC_SEQUENCE.STILL
			local x, y, l = get_position(OLMEC_UID)
			-- 1/3 random chance each time olmec groundpounds, shoots 3 out in random directions upwards.
			-- if prng:random_chance(3, PRNG_CLASS.PARTICLES) then
				-- # TODO: This currently fires twice, even though we call it once. Fix that. Idea: Use a timeout variable to check time to refire.
				olmec_attack(x, y+2, l)
				-- olmec_attack(x, y+2.5, l)
				-- olmec_attack(x, y+2.5, l)
			-- end
		elseif olmec.velocityy < -0.400 then
			OLMEC_STATE = OLMEC_SEQUENCE.FALL
		end
	end
end

local function onframe_boss_wincheck()
	if BOSS_STATE == BOSS_SEQUENCE.FIGHT then
		---@type Olmec
		local olmec = get_entity(OLMEC_UID)
		if olmec ~= nil then
			if olmec.attack_phase == 3 then
				local sound = get_sound(VANILLA_SOUND.UI_SECRET)
				if sound ~= nil then sound:play() end
				BOSS_STATE = BOSS_SEQUENCE.DEAD
				local _olmec_door = get_entity(module.DOOR_ENDGAME_OLMEC_UID)
				_olmec_door.flags = set_flag(_olmec_door.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
				local _x, _y, _ = get_position(module.DOOR_ENDGAME_OLMEC_UID)
				-- unlock_door_at(41, 99)
				unlock_door_at(_x, _y)
			end
		end
	end
end

set_callback(function()
	if state.theme == THEME.OLMEC then
		if OLMEC_UID then
			if BOSS_STATE == BOSS_SEQUENCE.CUTSCENE then
				onframe_olmec_cutscene()
			elseif BOSS_STATE == BOSS_SEQUENCE.FIGHT then
				onframe_olmec_behavior()
				onframe_boss_wincheck()
			end
		end
	end
end, ON.FRAME)

---@param draw_ctx GuiDrawContext
set_callback(function(draw_ctx)
	if options.hd_debug_info_boss == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if state.theme == THEME.OLMEC and OLMEC_UID ~= nil then
			---@type Olmec
			local olmec = get_entity(OLMEC_UID)
			local text_x = -0.95
			local text_y = -0.50
			local white = rgba(255, 255, 255, 255)
			if olmec ~= nil then
				local olmec_attack_state = "UNKNOWN"
				if OLMEC_STATE == OLMEC_SEQUENCE.STILL then olmec_attack_state = "STILL"
				elseif OLMEC_STATE == OLMEC_SEQUENCE.FALL then olmec_attack_state = "FALL" end
				
				-- BOSS_SEQUENCE = { ["CUTSCENE"] = 1, ["FIGHT"] = 2, ["DEAD"] = 3 }
				local boss_attack_state = "UNKNOWN"
				if BOSS_STATE == BOSS_SEQUENCE.CUTSCENE then boss_attack_state = "CUTSCENE"
				elseif BOSS_STATE == BOSS_SEQUENCE.FIGHT then boss_attack_state = "FIGHT"
				elseif BOSS_STATE == BOSS_SEQUENCE.DEAD then boss_attack_state = "DEAD" end
				
				draw_ctx:draw_text(text_x, text_y, 0, "OLMEC_STATE: " .. olmec_attack_state, white)
				text_y = text_y - 0.1
				draw_ctx:draw_text(text_x, text_y, 0, "BOSS_STATE: " .. boss_attack_state, white)
			else draw_ctx:draw_text(text_x, text_y, 0, "olmec is nil", white) end
		end
	end
end, ON.GUIFRAME)

set_callback(function()
	force_olmec_phase_0(true)
end, ON.LOGO)

return module