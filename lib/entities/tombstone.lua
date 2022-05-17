local module = {}

module.tombstone_blocks = {}
local tombstones_texture_id
do
    local texture_def = TextureDefinition.new()
    texture_def.width = 384
    texture_def.height = 128
    texture_def.tile_width = 128
    texture_def.tile_height = 128
	texture_def.texture_path = "res/tombstones.png"
	tombstones_texture_id = define_texture(texture_def)
end

function module.init()
	module.tombstone_blocks = {}
end

function module.spawn_tombstone(x, y, l)
    local tomb_uid = spawn(ENT_TYPE.FLOOR_EGGPLANT_ALTAR, x, y, l, 0, 0)
    set_entity_flags2(tomb_uid, set_flag(get_entity_flags2(tomb_uid), 22))
    local tomb = get_entity(tomb_uid)
    tomb:set_texture(tombstones_texture_id)
    return tomb_uid, tomb
end

function module.create_tombstone(x, y, l)
    local tomb_uid, tomb = module.spawn_tombstone(x, y, l)
    tomb.animation_frame = 0

	module.tombstone_blocks[#module.tombstone_blocks+1] = tomb_uid
end

function module.set_ash_tombstone()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
        local tomb_uid = module.tombstone_blocks[math.random(#module.tombstone_blocks)]
        get_entity(tomb_uid).animation_frame = 1
        
        local x, y, l = get_position(tomb_uid)
        embedlib.embed_item(ENT_TYPE.ITEM_SHOTGUN, get_grid_entity_at(x, y-1, l), 48)
    end
end

return module