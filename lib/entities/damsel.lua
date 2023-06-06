local module = {}

local damsel_list = {ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_HAMSTER}

local pet_type

function module.init()
	pet_type = nil
end

-- Prioritizes library setting over parameter
function module.set_curr_type(_pet_type)
	pet_type = pet_type or _pet_type

	if not pet_type then
		local pet_setting = get_setting(GAME_SETTING.PET_STYLE)
		pet_type = damsel_list[prng:random_index(#damsel_list, PRNG_CLASS.PROCEDURAL_SPAWNS)]
		if pet_setting == 0 then
			pet_type = ENT_TYPE.MONS_PET_DOG
		elseif pet_setting == 1 then
			pet_type = ENT_TYPE.MONS_PET_CAT
		elseif pet_setting == 2 then
			pet_type = ENT_TYPE.MONS_PET_HAMSTER
		end
	end
end

function module.get_curr_type()
	-- if not pet_type then return
	return pet_type
end

function module.create_damsel(x, y, l)
	spawn_entity_snapped_to_floor(module.get_curr_type(), x, y, l)
end

return module