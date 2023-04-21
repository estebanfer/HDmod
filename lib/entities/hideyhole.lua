local damsellib = require 'lib.entities.damsel'

local module = {}

module.LOCKEDCHEST_SPAWNED = false
module.LOCKEDCHEST_KEY_SPAWNED = false
module.DAMSEL_SPAWNED = false

function module.init()
	module.LOCKEDCHEST_SPAWNED = false
	module.LOCKEDCHEST_KEY_SPAWNED = false
	module.DAMSEL_SPAWNED = false
end

function module.create_hideyhole_spawn(x, y, l)
	if (
		state.theme ~= THEME.VOLCANA -- don't need to avoid spawning two damsels in hell
		and #get_entities_by_type({ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_DOG, ENT_TYPE.MONS_PET_HAMSTER}, MASK.MONSTER, LAYER.FRONT) ~= 0
	) then -- fake already having spawned the damsel
		module.DAMSEL_SPAWNED = true
	end

	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT)
	) then
		if module.DAMSEL_SPAWNED == false then
			module.DAMSEL_SPAWNED = true
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
            damsellib.create_damsel(x, y, l)
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
			module.DAMSEL_SPAWNED = true
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
			damsellib.create_damsel(x, y, l)
		else
            removelib.remove_items_for_hideyhole_spawn(x, y, l)
			-- # TODO: create succubus here
		end
	elseif module.DAMSEL_SPAWNED == false then
        module.DAMSEL_SPAWNED = true
        removelib.remove_items_for_hideyhole_spawn(x, y, l)
        damsellib.create_damsel(x, y, l)
	end
end

return module