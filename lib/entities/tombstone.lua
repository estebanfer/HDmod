local module = {}

module.tombstone_blocks = {}

function module.init()
	module.tombstone_blocks = {}
end

function module.create_tombstone(x, y, l)
	local block_uid = spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP, x, y, l, 0, 0)
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
	texture_def.texture_path = "res/floormisc_tombstone_rip.png"
	get_entity(block_uid):set_texture(define_texture(texture_def))
	module.tombstone_blocks[#module.tombstone_blocks+1] = block_uid
end

function module.set_ash_tombstone()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
        local block_uid = module.tombstone_blocks[math.random(#module.tombstone_blocks)]
        local x, y, l = get_position(block_uid)
        
        local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
        texture_def.texture_path = "res/floormisc_tombstone_ash.png"
        get_entity(block_uid):set_texture(define_texture(texture_def))

        embedlib.embed_item(ENT_TYPE.ITEM_SHOTGUN, get_grid_entity_at(x, y-1, l), 48)
    end
end

return module