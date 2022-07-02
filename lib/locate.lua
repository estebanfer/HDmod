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

-- translate game coordinates to levelrooms coordinates
function module.locate_levelrooms_position_from_game_position(e_x, e_y)
	local xmin, ymin, _, _ = get_bounds()
	local roomx = math.floor((e_x-(xmin+0.5))/CONST.ROOM_WIDTH)+1
	local roomy = math.floor(((ymin-0.5)-e_y)/CONST.ROOM_HEIGHT)+1
	return roomx, roomy
end

-- translate game coordinates to levelcode coordinates
function module.locate_levelcode_position_from_game_position(e_x, e_y)
	local _xmin, _ymin, _, _ = get_bounds()
	return e_x-(_xmin-0.5), (_ymin+0.5)-e_y
end

---Get levelcode using levelcode coordinates, returns 0 if not found
function module.get_levelcode_at(lx, ly)
    local levelcode = roomgenlib.global_levelassembly.modification.levelcode
    return levelcode[ly] and (levelcode[ly][lx] or 0) or 0
end

-- translate levelcode coordinates to levelrooms coordinates
function module.locate_levelrooms_position_from_levelcode_position(e_x, e_y)
	-- xmin, ymin, xmax, ymax = 1, 1, 4*10, 4*8
	local roomx, roomy = math.ceil(e_x/CONST.ROOM_WIDTH), math.ceil(e_y/CONST.ROOM_HEIGHT)
	return roomx, roomy
end

return module