local module = {}

local gargoyle_texture_id
do
    local gargoyle_texture_definition = TextureDefinition.new()
    gargoyle_texture_definition.width = 384
    gargoyle_texture_definition.height = 128
    gargoyle_texture_definition.tile_width = 128
    gargoyle_texture_definition.tile_height = 128

    gargoyle_texture_definition.texture_path = "res/gargoyles.png"
    gargoyle_texture_id = define_texture(gargoyle_texture_definition)
end

local function add_gargoyle(block_uid)
    local x, y, _ = get_position(block_uid)
    local decoration_uid = spawn_entity(ENT_TYPE.DECORATION_GENERIC, x, y, LAYER.FRONT, 0, 0)
    local decoration = get_entity(decoration_uid)
    
    decoration:set_texture(gargoyle_texture_id)
    
    decoration.animation_frame = 0
    if prng:random_chance(10, PRNG_CLASS.LEVEL_GEN) then
        decoration.animation_frame = 2
    elseif prng:random_chance(2, PRNG_CLASS.LEVEL_GEN) then
        decoration.animation_frame = 1
    end
    decoration.draw_depth = 10

    set_on_destroy(block_uid, function(entity)
        local decoration = get_entity(decoration_uid)
        decoration.flags = set_flag(decoration.flags, ENT_FLAG.INVISIBLE)
    end)
end

function module.add_gargoyles_to_hc()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
        local y = 120
        for x = 4, 30, 2 do
            add_gargoyle(get_grid_entity_at(x, y, LAYER.FRONT))
        end
    end
end

return module