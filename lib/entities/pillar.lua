local module = {}

local pillar_texture_id

local dragon_texture_id
do
    local pillar_texture_def = TextureDefinition.new()
    pillar_texture_def.width = 256
    pillar_texture_def.height = 384
    pillar_texture_def.tile_width = 256
    pillar_texture_def.tile_height = 128
    pillar_texture_def.texture_path = "res/pillar_yama.png"
    pillar_texture_id = define_texture(pillar_texture_def)

    local dragon_texture_def = TextureDefinition.new()
    dragon_texture_def.width = 386
    dragon_texture_def.height = 256
    dragon_texture_def.tile_width = 256
    dragon_texture_def.tile_height = 256
    dragon_texture_def.texture_path = "res/fountain_hell.png"
    dragon_texture_id = define_texture(dragon_texture_def)
end

local function create_section(x, y, l, animation_frame)
    local ent = get_entity(spawn_entity(ENT_TYPE.BG_OLMEC_PILLAR, x, y, l, 0, 0))
    ent:set_texture(pillar_texture_id)
    ent.animation_frame = animation_frame
	-- ent.width, ent.height = 2, 1
	-- ent.hitboxx, ent.hitboxy = 0.5, 0.5
end

local PILLAR_FRAMES <const> = {
    TOP = 0,
    MIDDLE = 1,
    BOTTOM = 2
}
-- animation frames are 0, 5, 10
-- minimum height is 3
function module.create_pillar(x, y, l, height)
    local min_height = 3
    if height < min_height then
        height = 3
    end
    -- create bottom section
    create_section(x, y, l, PILLAR_FRAMES.BOTTOM)

    -- create mid-sections
    for yi = 1, height-1, 1 do
        create_section(x, y+yi, l, PILLAR_FRAMES.MIDDLE)
        if yi == height-1 then
            local dragonhead = get_entity(spawn_entity(ENT_TYPE.BG_WATER_FOUNTAIN, x, y+yi, l, 0, 0)) 
            dragonhead:set_texture(dragon_texture_id)
            dragonhead.animation_frame = 0
        end
    end
    
    -- create top section
    create_section(x, y+height, l, PILLAR_FRAMES.TOP)
end

return module