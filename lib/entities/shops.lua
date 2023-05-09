module = {}

function module.set_blackmarket_shoprooms(room_gen_ctx)
	if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		unlockslib.UNLOCK_WI, unlockslib.UNLOCK_HI = 0, 0
		if unlockslib.LEVEL_UNLOCK ~= nil then
			unlockslib.UNLOCK_WI = math.random(minw, maxw)
			unlockslib.UNLOCK_HI = math.random(minh, (unlockslib.UNLOCK_WI ~= maxw and maxh or maxh-1))
		end
		-- message("wi, hi: " .. unlockslib.UNLOCK_WI .. ", " .. unlockslib.UNLOCK_HI)
        local damsel_shop_spawned = false
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.DICE_SHOP)
				elseif (hi == unlockslib.UNLOCK_HI and wi == unlockslib.UNLOCK_WI) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.HIRED_HAND_SHOP)
				else
                    local shop_type = math.random((damsel_shop_spawned and 4 or 5))
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, shop_type)
                    if shop_type == 5 then damsel_shop_spawned = true end
				end
			end
		end
		-- room_gen_ctx:set_shop_type(3, 2, LAYER.FRONT, SHOP_TYPE.HEDJET_SHOP)--unneeded
	end
end

-- black market shopkeepers
set_pre_tile_code_callback(function(x, y, layer)
    local ctx = PostRoomGenerationContext:new()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
        ---@type Shopkeeper
        local s = get_entity(spawn_shopkeeper(x, y, layer, ROOM_TEMPLATE.SIDE))
        if not test_flag(s.flags, ENT_FLAG.FACING_LEFT) then
            set_global_timeout(function()
                flip_entity(s.uid)
                for _, uid in pairs(get_entity(get_grid_entity_at(x, y-1, layer)):get_items()) do
                    local ent = get_entity(uid)
                    if ent.type.id == ENT_TYPE.DECORATION_SHOPFORE then
                        flip_entity(ent.uid)
                        ent.x = -0.1
                    end
                end
            end, 1)
        end
		local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
		if (
			roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx] == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_ANKH
		) then
			local ankh_uid = spawn_grid_entity(ENT_TYPE.ITEM_PICKUP_ANKH, x-3, y, layer)
			prinspect(ankh_uid)
			add_item_to_shop(ankh_uid, s.uid)
			add_custom_name(ankh_uid, "Ankh")
			local ankh_mov = get_entity(ankh_uid)
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.SHOP_ITEM)
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
			spawn_entity_over(ENT_TYPE.FX_SALEICON, ankh_uid, 0, 0)
			spawn_entity_over(ENT_TYPE.FX_SALEDIALOG_CONTAINER, ankh_uid, 0, 0)
			ankh_mov.price = 50000
		end

		local rx, ry = get_room_index(x, y)
        ctx:set_room_template(rx, ry, layer, ROOM_TEMPLATE.SHOP)
		
        return true
    end
    return false
end, "shopkeeper")

return module