local damsellib = require 'lib.entities.damsel'
local succubuslib = require 'lib.entities.succubus'

local module = {}

module.LOCKEDCHEST_SPAWNED = false
module.LOCKEDCHEST_KEY_SPAWNED = false
module.DAMSEL_SPAWNED = false

function module.init()
	module.LOCKEDCHEST_SPAWNED = false
	module.LOCKEDCHEST_KEY_SPAWNED = false
	module.DAMSEL_SPAWNED = false
	damsellib.init()
end

local function _spawn_hideyhole_damsel(x, y, l)
	removelib.remove_items_for_hideyhole_spawn(x, y, l)
	damsellib.set_curr_type()
	damsellib.create_damsel(x, y, l)
	module.DAMSEL_SPAWNED = true
end

function module.create_hideyhole_spawn(x, y, l)
	local pet_uids = get_entities_by_type({ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_HAMSTER}, MASK.MONSTER, LAYER.FRONT)
	if (
		-- state.theme ~= THEME.VOLCANA -- don't need to avoid spawning two damsels in hell
		-- and
		#pet_uids > 0 and get_entity(pet_uids[1]) ~= nil
	) then -- fake already having spawned the damsel
		damsellib.set_curr_type(get_entity(pet_uids[1]).type.id)
		module.DAMSEL_SPAWNED = true
	end

	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT)
	) then
		if module.DAMSEL_SPAWNED == false then
			_spawn_hideyhole_damsel(x, y, l)
		elseif module.LOCKEDCHEST_KEY_SPAWNED == false then
			module.LOCKEDCHEST_KEY_SPAWNED = true
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
			spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST_KEY, x, y, l)
		elseif module.LOCKEDCHEST_SPAWNED == false then
			module.LOCKEDCHEST_SPAWNED = true
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
			spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST, x, y, l)
		end
	elseif state.theme == THEME.VOLCANA then
		if module.DAMSEL_SPAWNED == false then
			_spawn_hideyhole_damsel(x, y, l)
		else
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
			succubuslib.create_succubus(x, y, l)
		end
	elseif module.DAMSEL_SPAWNED == false then
        _spawn_hideyhole_damsel(x, y, l)
	end
end

return module