local module = {}

function module.create_coffin_coop(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	local the_coffin = get_entity(coffin_uid)
	the_coffin.player_respawn = true
	return coffin_uid
end

function module.create_coffin_unlock(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	if unlockslib.LEVEL_UNLOCK ~= nil then
		--[[ 193 + unlock_num = ENT_TYPE.CHAR_* ]]
		set_contents(coffin_uid, 193 + unlockslib.HD_UNLOCKS[unlockslib.LEVEL_UNLOCK].unlock_id)
	end

	set_post_statemachine(coffin_uid, function()
		local coffin = get_entity(coffin_uid)
		if (
			coffin.animation_frame == 1
			and (
				unlockslib.LEVEL_UNLOCK ~= nil
				and (
					unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
				)
			)
		) then
			for i = 1, #unlockslib.RUN_UNLOCK_AREA, 1 do
				if unlockslib.RUN_UNLOCK_AREA[i].theme == state.theme then
					unlockslib.RUN_UNLOCK_AREA[i].unlocked = true 
					break
				end
			end
		end
	end)

	return coffin_uid
end

return module