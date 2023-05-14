local module = {}

local s2_room_template_blackmarket_ankh = define_room_template("hdmod_blackmarket_ankh", ROOM_TEMPLATE_TYPE.SHOP)
local s2_room_template_blackmarket_shop = define_room_template("hdmod_blackmarket_shop", ROOM_TEMPLATE_TYPE.SHOP)


function module.unmark_setrooms(room_gen_ctx)
    if state.theme == THEME.DWELLING and state.level == 4 then
        for x = 0, state.width - 1 do
            for y = 0, state.height - 1 do
                room_gen_ctx:unmark_as_set_room(x, y, LAYER.FRONT)
            end
        end
    end
end

function module.assign_s2_room_templates(room_gen_ctx)
    
		local level_w, level_h = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		for y = 0, level_h - 1, 1 do
		    for x = 0, level_w - 1, 1 do
				local template_to_set = ROOM_TEMPLATE.SIDE
				local room_template_here = get_room_template(x, y, 0)

				if options.hd_debug_scripted_levelgen_disable == false then

					local _template_hd = roomgenlib.global_levelassembly.modification.levelrooms[y+1][x+1]

					if (
						state.theme == THEME.OLMEC
					) then
						if (x == 0 and y == 3) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (x == 3 and y == 3) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							-- template_to_set = ROOM_TEMPLATE.PATH_NORMAL
							template_to_set = room_template_here
						end
					elseif (
						feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
					) then
						if (
							_template_hd == roomdeflib.HD_SUBCHUNKID.YAMA_ENTRANCE
							or _template_hd == roomdeflib.HD_SUBCHUNKID.YAMA_ENTRANCE_2
						) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.YAMA_EXIT) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							template_to_set = ROOM_TEMPLATE.SIDE
							-- template_to_set = room_template_here
						end
					else
						--[[
							Sync scripted level generation rooms with S2 generation rooms
						--]]
						
						--LevelGenSystem variables
						if (
							_template_hd == roomdeflib.HD_SUBCHUNKID.ENTRANCE or
							_template_hd == roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP
						) then
							state.level_gen.spawn_room_x, state.level_gen.spawn_room_y = x, y
						end
	
						-- normal paths
						if (
							(_template_hd >= 1) and (_template_hd <= 8)
						) then
							template_to_set = _template_hd
	
						-- tikivillage paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH then
							template_to_set = ROOM_TEMPLATE.PATH_NORMAL
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
	
						-- flooded paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_SIDE then
							template_to_set = ROOM_TEMPLATE.SIDE
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
						
						-- hauntedcastle paths
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT
						elseif _template_hd == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
	
						-- shop
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR) then
							template_to_set = ROOM_TEMPLATE.SHOP
						-- shop left
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT) then
							template_to_set = ROOM_TEMPLATE.SHOP_LEFT
						-- prize wheel
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE) then
							template_to_set = ROOM_TEMPLATE.DICESHOP
						-- prize wheel left
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT) then
							template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
							
						-- vault
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.VAULT) then
							template_to_set = ROOM_TEMPLATE.VAULT
						
						-- altar
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.ALTAR) then
							template_to_set = ROOM_TEMPLATE.ALTAR
						
						-- idol
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.IDOL) then
							template_to_set = ROOM_TEMPLATE.IDOL
							
						-- black market
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_SHOP) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT--s2_room_template_blackmarket_shop
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_ANKH) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT--s2_room_template_blackmarket_ankh

						-- coop coffin
						
						elseif (_template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP) then
							if state.level == 4 and state.world == 1 then
								template_to_set = ROOM_TEMPLATE.PATH_NORMAL
							else
								template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER
							end
						elseif (
							_template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
							or _template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP
							or _template_hd == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
						) then
							if state.level == 4 and state.world == 1 then
								template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
							else
								template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER_VERTICAL
							end

						end
					end
				else
					-- Set everything that's not the entrance to a side room
					if (
						(room_template_here == ROOM_TEMPLATE.ENTRANCE) or
						(room_template_here == ROOM_TEMPLATE.ENTRANCE_DROP)
					) then
						template_to_set = room_template_here
					end
				end
				room_gen_ctx:set_room_template(x, y, 0, template_to_set)
	        end
	    end
        
		if (
			feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM)
			or feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			or state.theme == THEME.NEO_BABYLON
		) then
			for x = 0, level_w - 1, 1 do
				room_gen_ctx:set_room_template(x, level_h, 0, ROOM_TEMPLATE.SIDE)
			end
		end
end

return module