local module = {}

function module.embed_item(enum, uid, frame)
	local x, y, l = get_position(uid)
	-- local ents = get_entities_at(0, 0, x, y, l, 0.1)
	-- if (#ents > 1) then return end
	removelib.remove_embedded_at(x, y, l)

	local entity = get_entity(spawn_entity_over(ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE, uid, 0, 0))
	entity.inside = enum
	entity.animation_frame = frame
	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
	return 0;
end

-- ha wrote this
	-- Break "3278409" up into setting/clearing specific flags.
	-- In testing, the mattock I embedded couldn't be picked up because it had ENT_FLAG.PASSES_THROUGH_OBJECTS enabled.

function module.embed_nonitem(enum, uid)
	local x, y, l = get_position(uid)
	-- local ents = get_entities_at(0, 0, x, y, l, 0.1)
	-- if (#ents > 1) then return end
	removelib.remove_embedded_at(x, y, l)

	local entitydb = get_type(enum)
	local previousdraw, previousflags = entitydb.draw_depth, entitydb.default_flags
	entitydb.draw_depth = 9
	entitydb.default_flags = 3278409 -- don't really need some flags for other things that dont explode, example is for jetpack
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.INVISIBLE)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.NO_GRAVITY)
	-- entitydb.default_flags = clr_flag(entitydb.default_flags, ENT_FLAG.COLLIDES_WALLS)

	local entity = get_entity(spawn_entity_over(enum, uid, 0, 0))
	entitydb.draw_depth = previousdraw
	entitydb.default_flags = previousflags
--   apply_entity_db(entity.uid)
  
--   message("Spawned " .. tostring(entity.uid))
	return 0;
end

return module