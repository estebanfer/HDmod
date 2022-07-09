local module = {}

local gameframe_cb = -1
local ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds
local acid_tick = ACID_POISONTIME

local acid_color = Color:new(0.2, 0.75, 0.2, 1.0)
local water_color = Color:new(0.05, 0.25, 0.35, 1.0)
local acid_glow_color = Color:new(0.2, 1.0, 0.2, 1.0)
local water_emitters = {}
local water_index = 1

local function liquid_light_update()
    for _, emitter in ipairs(water_emitters) do
        refresh_illumination(emitter)
        emitter.brightness = 2.0
    end
end

local function acid_update()
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

	liquid_light_update()

	if get_frame() % 35 == 0 then
		local fx = get_entities_by_type(ENT_TYPE.FX_WATER_SURFACE)
		for _,v in ipairs(fx) do
			local x, y, l = get_position(v)
			if math.random() < 0.003 then
				spawn_entity(ENT_TYPE.ITEM_ACIDBUBBLE, x, y, l, 0, 0)
			end
			get_entity(v).color = acid_glow_color
		end
	end
end

set_callback(function ()
	if state.loading == 1 and state.screen_next ~= SCREEN.DEATH then
    	water_emitters = {}
    	water_index = 1
	end
end, ON.LOADING)

function module.spawn_liquid_illumination()
	clear_callback(gameframe_cb)
	gameframe_cb = -1

	if not options.disable_liquid_illumination then
		local light_color = state.theme == THEME.EGGPLANT_WORLD and acid_color or water_color
    	for _, uid in ipairs(get_entities_by(0, MASK.WATER, LAYER.BOTH)) do
    	    water_emitters[water_index] = create_illumination(light_color, 2, uid)
    	    water_index = water_index + 1
    	end
		local lake = get_entities_by(ENT_TYPE.LIQUID_IMPOSTOR_LAKE, MASK.LIQUID, LAYER.FRONT)[1]
		if lake then
			local emitter = create_illumination(light_color, 26, lake)
			emitter.type_flags = set_flag(0, 3)
			emitter.offset_y = -14.5
    	    water_emitters[water_index] = emitter
    	    water_index = water_index + 1
		end

		if state.theme == THEME.EGGPLANT_WORLD then
			gameframe_cb = set_callback(acid_update, ON.GAMEFRAME)
		elseif test_flag(get_level_flags(), 18) and (state.theme == THEME.JUNGLE or state.theme == THEME.ICE_CAVES) then
			gameframe_cb = set_callback(liquid_light_update, ON.GAMEFRAME)
		end
	end
end

function module.init()
	acid_tick = ACID_POISONTIME
end

return module