local module = {}

function module.add_snow_to_floor()
    if (
        feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)
        or feelingslib.feeling_check(feelingslib.FEELING_ID.SNOWING)
    ) then
        local floors = get_entities_by_type(ENT_TYPE.FLOOR_GENERIC)
        for _, floor_uid in pairs(floors) do
            local floor = get_entity(floor_uid)
            if floor.deco_top ~= -1 then
                local deco_top = get_entity(floor.deco_top)
                if (
                    deco_top.animation_frame ~= 101
                    and deco_top.animation_frame ~= 102
                    and deco_top.animation_frame ~= 103
                ) then
                    deco_top.animation_frame = deco_top.animation_frame - 24
                    if get_grid_entity_at(floor.x, floor.y + 1, floor.layer) == -1 and prng:random_chance(60, PRNG_CLASS.LEVEL_DECO) then
                        -- Add a snowman decoration to the floor.
                        local scale = 0.6 + (0.2 * prng:random_float(PRNG_CLASS.LEVEL_DECO))
                        local offset_x = -0.15 + (0.3 * prng:random_float(PRNG_CLASS.LEVEL_DECO))
                        local offset_y = 0.5 + (0.4 * scale)
                        local snowman = get_entity(spawn_entity_over(ENT_TYPE.DECORATION_GENERIC, floor_uid, offset_x, offset_y))
                        snowman:set_texture(TEXTURE.DATA_TEXTURES_ITEMS_0)
                        snowman.animation_frame = 221
                        snowman:set_draw_depth(12)
                        snowman.width = prng:random_chance(2, PRNG_CLASS.LEVEL_DECO) and scale or -scale
                        snowman.height = scale
                    end
                end
            end
        end
    end
end

return module