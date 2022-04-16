local module = {}

local gameframe_cb = -1
local ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds
local acid_tick = ACID_POISONTIME

local acid_color = Color:new(0.2, 0.75, 0.2, 1.0)
local acid_glow_color = Color:new(0.2, 1.0, 0.2, 1.0)
local water_emitters = {}
local water_index = 1

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

    for _, emitter in ipairs(water_emitters) do
        refresh_illumination(emitter)
        emitter.brightness = 2.0
    end

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
	if state.theme == THEME.EGGPLANT_WORLD then
		if gameframe_cb == -1 then
			gameframe_cb = set_callback(acid_update, ON.GAMEFRAME)
		end
	else
		clear_callback(gameframe_cb)
		gameframe_cb = -1
	end
end, ON.POST_LEVEL_GENERATION)

set_callback(function ()
	if state.loading == 1 and state.screen_next ~= SCREEN.DEATH then
    	water_emitters = {}
    	water_index = 1
	end
end, ON.LOADING)

function module.spawn_acid_illumination()
	if not options.disable_acid_illumination then
    	for _, uid in ipairs(get_entities_by(0, MASK.WATER, LAYER.BOTH)) do
    	    water_emitters[water_index] = create_illumination(acid_color, 2, uid)
    	    water_index = water_index + 1
    	end
	end
end

function module.init()
	acid_tick = ACID_POISONTIME
end

return module