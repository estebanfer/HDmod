--[[
    Level Background stuff
]]

local module = {}

--[[
    Level/Setroom-Specific
--]]
local function level_specific()
    if state.theme == THEME.NEO_BABYLON then
        local backwalls = get_entities_by(ENT_TYPE.BG_LEVEL_BACKWALL, 0, LAYER.FRONT)
        -- message("#backwalls: " .. tostring(#backwalls))

        -- ice caves bg
        local backwall = get_entity(backwalls[1])
        backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_ICE_0)

        -- mothership bg
        local w, h = 40, 32
        local x, y, l = 22.5, 106.5, LAYER.FRONT
        backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
        backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
        backwall.animation_frame = 0
        backwall:set_draw_depth(49)
        backwall.width, backwall.height = w, h
        backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
        backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
    end
    
    if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
        local w, h = 30, 28
        local x, y, l = 17.5, 104.5, LAYER.FRONT
        local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
        backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_STONE_0)
        backwall.animation_frame = 0
        backwall:set_draw_depth(49)
        backwall.width, backwall.height = w, h
        backwall.tile_width, backwall.tile_height = backwall.width/4, backwall.height/4 -- divide by 4 for normal-sized brick
        backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
    end

    if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) then
        local w, h = 6, 8
        local x, y, l = 22.5, 94.5, LAYER.FRONT
        local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
        backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
        backwall.animation_frame = 0
        backwall:set_draw_depth(49)
        backwall.width, backwall.height = w, h
        backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
        backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
    end
end

--[[
    Room-Specific
--]]
local function room_specific()
    local level_w, level_h = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
    for y = 1, level_h, 1 do
        for x = 1, level_w, 1 do
            local _template_hd = roomgenlib.global_levelassembly.modification.levelrooms[y][x]
            local corner_x, corner_y = locatelib.locate_game_corner_position_from_levelrooms_position(x, y)
            if _template_hd == roomdeflib.HD_SUBCHUNKID.VLAD_BOTTOM then
                
                -- main tower
                local w, h = 10, (8*3)+3
                local _x, _y, _l = corner_x+4.5, corner_y+6, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(49)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

                -- vlad alcove
                w, h = 2, 2
                _x, _y, _l = corner_x+4.5, corner_y+20.5, LAYER.FRONT
                backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(49)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

                -- mother statue
                spawn_entity(ENT_TYPE.BG_CROWN_STATUE, corner_x+4.5, corner_y+(8*3)-7, _l, 0, 0)

            elseif _template_hd == roomdeflib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP then
                local w, h = 10, 8
                local _x, _y, _l = corner_x+4.5, corner_y-3.5, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(49)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
            end
        end
    end
end

function module.set_backwall_bg()
    level_specific()
    room_specific()
end

return module