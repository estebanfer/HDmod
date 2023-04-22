--[[
    Level Background stuff
]]

pillarlib = require 'lib.entities.pillar'

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

        for _, uid in ipairs(
            get_entities_overlapping_hitbox(ENT_TYPE.BG_LEVEL_DECO, MASK.BG, AABB:new(2.5, 118.5, 30.5, 92.5), LAYER.FRONT)) do
            get_entity(uid):destroy()
        end
        -- for _, uid in ipairs(
        --     get_entities_overlapping_hitbox(ENT_TYPE.MIDBG, MASK.BG, AABB:new(2.5, 118.5, 31.5, 92.5), LAYER.FRONT)) do
        --     local ent = get_entity(uid)
        --     if (
        --         ent:get_texture() == TEXTURE.DATA_TEXTURES_FLOORSTYLED_STONE_2
        --         and ent.animation_frame >= 80
        --         and ent.animation_frame <= 95
        --     ) then
        --         ent:destroy()
        --     end
        -- end
    end

    if state.theme == THEME.CITY_OF_GOLD then
        local bg = get_entity(spawn_entity(ENT_TYPE.BG_KALI_STATUE, 22.5, 103, l, 0, 0))
        bg.width = 5.6
        bg.height = 7
        bg.hitboxx = 2.8
        bg.hitboxy = 3.5
    end

    if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) then
        -- throne backwall bricks
        local w, h = 6, 8
        local x, y, l = 22.5, 94.5, LAYER.FRONT
        local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
        backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
        backwall.animation_frame = 0
        backwall:set_draw_depth(49)
        backwall.width, backwall.height = w, h
        backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
        backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

        -- throne pillars
        pillarlib.create_pillar(19.5, 94, LAYER.FRONT, 4)
        pillarlib.create_pillar(25.5, 94, LAYER.FRONT, 4)
        
        for _, uid in ipairs(
            get_entities_overlapping_hitbox(ENT_TYPE.BG_LEVEL_DECO, MASK.BG, AABB:new(18.5, 98, 26.5, 90.5), LAYER.FRONT)) do
            get_entity(uid):destroy()
        end
    end
end

local function spawn_hive_bg(hive_x, hive_y, hive2_x, hive2_y)
    local function spawn_midbg_hive(x, y)
        local ent = get_entity(spawn_grid_entity(ENT_TYPE.MIDBG_BEEHIVE, x, y, LAYER.FRONT))
        ent.width, ent.height = 1.25, 1.25
        ent:set_draw_depth(44)
    end
    local x, y = get_room_pos(hive_x-1, hive_y-1)
    for _, uid in ipairs(
        get_entities_overlapping_hitbox(ENT_TYPE.BG_LEVEL_DECO, MASK.BG, AABB:new(x, y, x+10, y-8), LAYER.FRONT)) do
        get_entity(uid):destroy()
    end
    do
        local ent = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_DECO, x+5, y-4, LAYER.FRONT, 0, 0))
        ent:set_texture(TEXTURE.DATA_TEXTURES_BG_BEEHIVE_0)
        ent.width, ent.height = 10.0, 8.0
        ent.hitboxx, ent.hitboxy = 3.5, 3.5
        ent:set_draw_depth(49)
    end
    local lx, ly = (hive_x-1)*10 + 1, (hive_y-1)*8 + 1
    if locatelib.get_levelcode_at(lx, ly+3) == "0" and hive_x - 1 ~= hive2_x and hive_x > 1 then --left
        spawn_midbg_hive(x+0.5, y-3.5)
        spawn_midbg_hive(x+0.5, y-4.5)
    end
    if locatelib.get_levelcode_at(lx+9, ly+3) == "0" and hive_x + 1 ~= hive2_x and hive_x < 4 then --right
        spawn_midbg_hive(x+9.5, y-3.5)
        spawn_midbg_hive(x+9.5, y-4.5)
    end
    if locatelib.get_levelcode_at(lx+4, ly) == "0" and hive_y - 1 ~= hive2_y then --up
        spawn_midbg_hive(x+4.5, y-0.5)
        spawn_midbg_hive(x+5.5, y-0.5)
    end
    if locatelib.get_levelcode_at(lx+4, ly+7) == "0" and hive_y < 4 and hive_y + 1 ~= hive2_y then --down
        spawn_midbg_hive(x+4.5, y-7.5)
        spawn_midbg_hive(x+5.5, y-7.5)
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

                for _, uid in ipairs(
                    get_entities_overlapping_hitbox(ENT_TYPE.BG_LEVEL_DECO, MASK.BG, AABB:new(_x-(w/2), _y+(h/2), _x+(w/2), _y-(h/2)), LAYER.FRONT)) do
                    get_entity(uid):destroy()
                end

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
            elseif _template_hd == roomdeflib.HD_SUBCHUNKID.UFO_LEFTSIDE then
                --first chunk
                local w, h = 8, 6
                local _x, _y, _l = corner_x+6.5, corner_y-3.5, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(46)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
                --smaller second chunk
                local w, h = 2, 4
                local _x, _y, _l = corner_x+1.5, corner_y-3.5, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(46)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
            elseif _template_hd == roomdeflib.HD_SUBCHUNKID.UFO_MIDDLE then
                local w, h = 10, 6
                local _x, _y, _l = corner_x+5.5, corner_y-3.5, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(46)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
            elseif _template_hd == roomdeflib.HD_SUBCHUNKID.UFO_RIGHTSIDE then
                local w, h = 10, 6
                local _x, _y, _l = corner_x+5.5, corner_y-3.5, LAYER.FRONT
                local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, _x, _y, _l, 0, 0))
                backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
                backwall.animation_frame = 0
                backwall:set_draw_depth(46)
                backwall.width, backwall.height = w, h
                backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
                backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
            elseif _template_hd and _template_hd >= 1300 and _template_hd < 1400 then
                local hive2_x, hive2_y = -1, -1
                do -- find second beehive if exists
                    local ix = 0
                    local levelrooms = roomgenlib.global_levelassembly.modification.levelrooms
                    for iy = -1, 1 do
                        while ix < 2 do
                            local room = levelrooms[y+iy] and (levelrooms[y+iy][x+ix] or 0) or 0
                            if room >= 1300 and room < 1400 then
                                hive2_x, hive2_y = x+ix, y+iy
                            end
                            ix = ix + 2
                        end
                        ix = ix % 2 - 1
                    end
                end
                spawn_hive_bg(x, y, hive2_x, hive2_y)
            end
        end
    end
end

function module.set_backwall_bg()
    level_specific()
    room_specific()
end

return module