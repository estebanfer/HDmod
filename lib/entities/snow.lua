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
                end
            end
        end
    end
end

return module