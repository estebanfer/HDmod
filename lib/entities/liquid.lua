local module = {}
require "hdentnew"

optionslib.register_option_bool("disable_liquid_illumination", "Performance: Disable liquid illumination (water, acid)", nil, false)

local gameframe_cb = -1
local ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds

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

local acid_immune_hd_ents = {
	HD_ENT_TYPE.MONS_BACTERIUM,
	HD_ENT_TYPE.MONS_BABY_WORM,
	--TODO: Critter maggot
}

local function acid_update()
	for _, uid in pairs(get_entities_by(0, MASK.PLAYER | MASK.MOUNT | MASK.MONSTER, LAYER.FRONT)) do
		---@type Movable
		local ent = get_entity(uid)
		if not ent.user_data then
			ent.user_data = { acid_tick = ACID_POISONTIME }
		elseif not ent.user_data.acid_tick then
			ent.user_data.acid_tick = ACID_POISONTIME
		end
		local acid_tick = ent.user_data.acid_tick
		local is_swimming = test_flag(ent.more_flags, ENT_MORE_FLAG.SWIMMING)
		local poisoned = ent:is_poisoned()
		if is_swimming and ent.health ~= 0 and not poisoned
				and (not ent.user_data.ent_type or not commonlib.has(acid_immune_hd_ents, ent.user_data.ent_type)) then
			if acid_tick <= 0 then
				poison_entity(uid)
				ent.user_data.acid_tick = ACID_POISONTIME
				-- messpect("POISONED", uid)
			else
				ent.user_data.acid_tick = acid_tick - 1
			end
		else
			ent.user_data.acid_tick = ACID_POISONTIME
		end
		-- if is_swimming and commonlib.has(acid_immune_hd_ents, ent.user_data.ent_type) and not ent.user_data.done then
		-- 	messpect("NO POISON", ent.uid)
		-- 	ent.user_data.done = true
		-- end
	end

	liquid_light_update()

	if get_frame() % 35 == 0 then
		local fx = get_entities_by_type(ENT_TYPE.FX_WATER_SURFACE)
		for _, uid in ipairs(fx) do
			if math.random() < 0.003 then
				---@type ParticleEmitterInfo | nil
				local bubbles_particle = generate_world_particles(PARTICLEEMITTER.POISONEDEFFECT_BUBBLES_BURST, uid)
				set_timeout(function ()
					if get_entity(uid) then
						local x, y, l = get_position(uid)
						spawn_entity(ENT_TYPE.ITEM_ACIDBUBBLE, x, y, l, 0, 0)
					end
				end, 60)
				set_interval(function()
					-- MUST extinguish the particle emitter if the entity doesn't exist anymore (or crash)
					if not get_entity(uid) or bubbles_particle == nil then
						---@cast bubbles_particle ParticleEmitterInfo
						extinguish_particles(bubbles_particle)
						bubbles_particle = nil
						return false
					end
				end, 1)
				set_timeout(function()
					---@cast bubbles_particle ParticleEmitterInfo
					extinguish_particles(bubbles_particle)
					bubbles_particle = nil
				end, 75)
			end
			get_entity(uid).color = acid_glow_color
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

return module