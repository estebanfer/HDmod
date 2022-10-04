local removelib = require 'lib.spawning.remove'

local module = {}
local damsel_list = {ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_HAMSTER}

function module.create_damsel(x, y, l)
	local pet_setting = get_setting(GAME_SETTING.PET_STYLE)
	local pet_type = damsel_list[prng:random_index(#damsel_list, PRNG_CLASS.PROCEDURAL_SPAWNS)]
	if pet_setting == 0 then
		pet_type = ENT_TYPE.MONS_PET_DOG
	elseif pet_setting == 1 then
		pet_type = ENT_TYPE.MONS_PET_CAT
	elseif pet_setting == 2 then
		pet_type = ENT_TYPE.MONS_PET_HAMSTER
	end
	spawn_entity_snapped_to_floor(pet_type, x, y, l)
end

return module