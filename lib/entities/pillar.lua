local module = {}

local texture_pillar = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_STONE_3)
local texture_dragon = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
do
    texture_pillar.texture_path = "res/pillar_yama.png"
    texture_dragon.texture_path = "res/fountain_hell.png"
end

local function create_section(x, y, l, animation_frame)
    local ent = get_entity(spawn_entity(ENT_TYPE.BG_OLMEC_PILLAR, x, y, l, 0, 0))
    ent:set_texture(define_texture(texture_pillar))
    ent.animation_frame = animation_frame
	-- ent.width, ent.height = 2, 1
	-- ent.hitboxx, ent.hitboxy = 0.5, 0.5
end

-- animation frames are 0, 5, 10
-- minimum height is 3
function module.create_pillar(x, y, l, height)
    local min_height = 3
    if height < min_height then
        height = 3
    end
    -- create bottom section
    create_section(x, y, l, 10)

    -- create mid-sections
    for yi = 1, height-1, 1 do
        create_section(x, y+yi, l, 5)
        if yi == height-1 then
            local dragonhead = get_entity(spawn_entity(ENT_TYPE.BG_WATER_FOUNTAIN, x, y+yi, l, 0, 0)) 
            dragonhead:set_texture(define_texture(texture_dragon))
        end
    end
    
    -- create top section
    create_section(x, y+height, l, 0)
end

return module