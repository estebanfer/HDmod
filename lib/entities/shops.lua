module = {}

function module.set_blackmarket_shoprooms(room_gen_ctx)
	if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		state.level_gen.shop_type = SHOP_TYPE.DICE_SHOP
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
					-- SORRY NOTHING
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
    if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		prinspect("Blackmarket Shopkeeper handling!")
		local ctx = PostRoomGenerationContext:new()
		local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
		local roomid = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
        ---@type Shopkeeper
        local s = get_entity(spawn_shopkeeper(x, y, layer, ROOM_TEMPLATE.SIDE))
		set_global_timeout(function()
			local c_ox, c_oy = -0.1, 0.89
			if not test_flag(s.flags, ENT_FLAG.FACING_LEFT) then
				flip_entity(s.uid)
			end
			if (
				roomid ~= roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
			) then
				local floor = get_entity(get_grid_entity_at(x, y-1, layer))
				if floor then
					local c = get_entity(spawn_entity_over(ENT_TYPE.DECORATION_SHOPFORE, floor.uid, c_ox, c_oy))
					c.animation_frame = 74
				end
			end
		end, 1)
		if (
			roomid == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_ANKH
		) then
			local ankh_uid = spawn_grid_entity(ENT_TYPE.ITEM_PICKUP_ANKH, x-3, y, layer)
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
        ctx:set_room_template(rx, ry, layer, roomid == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT and ROOM_TEMPLATE.DICESHOP_LEFT or ROOM_TEMPLATE.SHOP)
		
        return true
    end
    return false
end, "shopkeeper")

-- Since setting the shop type for the black market level prevents shops from getting decorations, decorate them ourselves.
function module.add_shop_decorations()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		local shelf_frames = {-1, -1, 28, 29, 38, 39}
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					-- SORRY NOTHING
				else
					-- shelf decorations
					local corner_x, corner_y = locatelib.locate_game_corner_position_from_levelrooms_position(wi, hi)
					local x, y = corner_x+2, corner_y-4
					local shelf_start, shelf_end = 0, 5
					for i = shelf_start, shelf_end, 1 do
						local shelf = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y, LAYER.FRONT, 0, 0))
						local shelf_f = 17
						if i == shelf_start then
							shelf_f = 16
						elseif i == shelf_end then
							shelf_f = 18
						end
						shelf.animation_frame = shelf_f
						shelf:set_draw_depth(44)

						local floor_above = get_entity(get_grid_entity_at(x+i, y+1, LAYER.FRONT))
						if not floor_above or (floor_above and floor_above.type.id == ENT_TYPE.ITEM_LAMP) then
							-- item on shelf
							local s_f = shelf_frames[math.random(#shelf_frames)]
							if s_f ~= -1 then
								local s_d = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y+.55, LAYER.FRONT, 0, 0))
								s_d.animation_frame = s_f
								s_d:set_draw_depth(44)
							end
							-- spiderweb over shelf
							if math.random(3) == 1 then
								local s_d = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y+.55, LAYER.FRONT, 0, 0))
								s_d.animation_frame = 19
								s_d:set_draw_depth(44)
							end
						end
					end
				end
			end
		end
	end
end

return module