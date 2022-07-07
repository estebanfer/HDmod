local module = {}

-- translate levelrooms coordinates to the tile in the top-left corner in game coordinates
function module.locate_game_corner_position_from_levelrooms_position(roomx, roomy)
	local xmin, ymin, _, _ = get_bounds()
	local tc_x = (roomx-1)*CONST.ROOM_WIDTH+(xmin+0.5)
	local tc_y = (ymin-0.5) - ((roomy-1)*(CONST.ROOM_HEIGHT))
	return tc_x, tc_y
end

-- -- translate levelrooms coordinates to the tile in the top-left corner in levelcode coordinates
-- function module.locate_cornerpos_levelassembly(roomx, roomy)
-- 	xmin, ymin = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
-- 	tc_x = (roomx-1)*CONST.ROOM_WIDTH+(xmin+0.5)
-- 	tc_y = (ymin-0.5) - ((roomy-1)*(CONST.ROOM_HEIGHT))
-- 	return tc_x, tc_y
-- end

--Get room at a levelroom cooridnate. returns -1 if not found
function module.get_levelroom_at(room_x, room_y)
	local levelrooms = roomgenlib.global_levelassembly.modification.levelrooms
	return (
		levelrooms[room_y] and
		levelrooms[room_y][room_x]
	) or
	(room_y == 5 and roomgenlib.global_levelassembly.modification.rowfive.levelrooms[room_x] or -1)
end

-- translate game coordinates to levelrooms coordinates
function module.locate_levelrooms_position_from_game_position(e_x, e_y)
	local roomx, roomy = get_room_index(e_x, e_y)
	return roomx+1, roomy+1
end

function module.get_levelroom_at_game_position(e_x, e_y)
	local room_x, room_y = module.locate_levelrooms_position_from_game_position(e_x, e_y)
	return module.get_levelroom_at(room_x, room_y)
end

-- translate game coordinates to levelcode coordinates
function module.locate_levelcode_position_from_game_position(e_x, e_y)
	local _xmin, _ymin, _, _ = get_bounds()
	return math.floor(e_x-(_xmin-0.5)), math.floor((_ymin+0.5)-e_y)
end

---Get levelcode using levelcode coordinates, returns 0 if not found
function module.get_levelcode_at(lx, ly)
    local levelcode = roomgenlib.global_levelassembly.modification.levelcode
    return levelcode[ly] and (levelcode[ly][lx] or 0) or 0
end

function module.get_levelcode_at_gpos(x, y)
	local lx, ly = module.locate_levelcode_position_from_game_position(x, y)
	return module.get_levelcode_at(lx, ly)
end

-- translate levelcode coordinates to levelrooms coordinates
function module.locate_levelrooms_position_from_levelcode_position(e_x, e_y)
	-- xmin, ymin, xmax, ymax = 1, 1, 4*10, 4*8
	local roomx, roomy = math.ceil(e_x/CONST.ROOM_WIDTH), math.ceil(e_y/CONST.ROOM_HEIGHT)
	return roomx, roomy
end

return module