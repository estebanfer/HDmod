local module = {}

function players_in_moai()
	local moai_hollow_aabb = AABB:new(
		global_levelassembly.moai_exit.x-.5,
		global_levelassembly.moai_exit.y+1.5,
		global_levelassembly.moai_exit.x+.5,
		global_levelassembly.moai_exit.y-1.5
	)
	moai_hollow_aabb:offset(0, 1)
	local players_in_moai = get_entities_overlapping_hitbox(
		0, MASK.PLAYER,
		moai_hollow_aabb,
		LAYER.FRONT
	)
	return #players_in_moai ~= 0
end

set_callback(function()
	if options.hd_debug_scripted_levelgen_disable == false then
		set_timeout(function()
			local cb_moai_diamond = -1
			local cb_moai_hedjet = -1
			-- # TODO: Investigate if breaking/teleporting into the Moai in HD disables being able to get the hedjet.
			if feelingslib.feeling_check(feelingslib.FEELING_ID.MOAI) == true then
				cb_moai_diamond = set_interval(function()
					if players_in_moai() then
						kill_entity(moai_veil)
						spawn_entity(ENT_TYPE.ITEM_DIAMOND, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
						local sound = get_sound(VANILLA_SOUND.UI_SECRET)
						if sound ~= nil then sound:play() end
						clear_callback(cb_moai_hedjet)
						return false
					end
				end, 1)
				cb_moai_hedjet = set_interval(function()
					for i = 1, #players, 1 do
						if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_ANKH) and players[i].health == 0 then
							set_timeout(function()
								move_entity(players[i].uid, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y, LAYER.FRONT, 0, 0)
								kill_entity(moai_veil)
								spawn_entity(ENT_TYPE.ITEM_PICKUP_HEDJET, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
								local sound = get_sound(VANILLA_SOUND.UI_SECRET)
								if sound ~= nil then sound:play() end
								clear_callback(cb_moai_diamond)
							end, 3)
							return false
						end
					end
				end, 1)
			else
				set_interval(function()
					for i = 1, #players, 1 do
						if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_ANKH) and players[i].health == 0 then
							set_timeout(function()
								move_entity(players[1].uid, global_levelassembly.entrance.x, global_levelassembly.entrance.y, LAYER.FRONT, 0, 0)
							end, 3)
							return false
						end
					end
				end, 1)
			end

		end, 15)
	end
end, ON.LEVEL)

return module