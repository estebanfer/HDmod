local module = {}

local INDENT = 5

local dev_sections = {}
local registered_options = {}
local warp_reset_run = false
local entity_spawners = {}

function module.register_option_bool(id, label, desc, initial_value, is_debug)
    table.insert(registered_options, {
        id = id,
        type = "bool",
        label = label,
        desc = desc,
        initial_value = initial_value,
        is_debug = is_debug == true
    })
end

function module.register_option_string(id, label, desc, initial_value, is_debug)
    table.insert(registered_options, {
        id = id,
        type = "string",
        label = label,
        desc = desc,
        initial_value = initial_value,
        is_debug = is_debug == true
    })
end

function module.register_entity_spawner(name, spawn_func)
    table.insert(entity_spawners, {
        name = name,
        spawn_func = spawn_func
    })
end

function module.register_dev_section(name, callback)
    table.insert(dev_sections, {
        name = name,
        callback = callback
    })
end

local function draw_registered_options(ctx, is_debug)
    for _, option in pairs(registered_options) do
        if option.is_debug == is_debug then
            if option.type == "bool" then
                options[option.id] = ctx:win_check(option.label, options[option.id])
            elseif option.type == "string" then
                options[option.id] = ctx:win_input_text(option.label, options[option.id])
            end
            if option.desc then
                ctx:win_text(option.desc)
            end
        end
    end
end

local function draw_gui(ctx)
    draw_registered_options(ctx, false)
    ctx:win_section("Dev Tools", function()
        ctx:win_indent(INDENT)
        ctx:win_text("These features are meant for HDmod testing and development. They may be broken or unstable. Use them at your own risk.")
        for _, dev_section in pairs(dev_sections) do
            ctx:win_section(dev_section.name, function()
                ctx:win_indent(INDENT)
                dev_section.callback(ctx)
                ctx:win_indent(-INDENT)
            end)
        end
        ctx:win_indent(-INDENT)
    end)
end

module.register_dev_section("Debug Options", function(ctx)
    draw_registered_options(ctx, true)
end)

local function draw_warp_button(ctx, name, world, level, theme, is_tutorial)
    if ctx:win_button(name) then
        if warp_reset_run then
            state.quest_flags = QUEST_FLAG.RESET
        end
        if is_tutorial then
            worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
        else
            worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL
        end
        warp(world, level, theme)
    end
end

module.register_dev_section("Warps", function(ctx)
    draw_warp_button(ctx, "Camp", 1, 1, THEME.BASE_CAMP)
    ctx:win_inline()
    draw_warp_button(ctx, "T1", 1, 1, THEME.DWELLING, true)
    ctx:win_inline()
    draw_warp_button(ctx, "T2", 1, 2, THEME.DWELLING, true)
    ctx:win_inline()
    draw_warp_button(ctx, "T3", 1, 3, THEME.DWELLING, true)

    draw_warp_button(ctx, "1-1", 1, 1, THEME.DWELLING)
    ctx:win_inline()
    draw_warp_button(ctx, "1-2", 1, 2, THEME.DWELLING)
    ctx:win_inline()
    draw_warp_button(ctx, "1-3", 1, 3, THEME.DWELLING)
    ctx:win_inline()
    draw_warp_button(ctx, "1-4", 1, 4, THEME.DWELLING)

    draw_warp_button(ctx, "2-1", 2, 1, THEME.JUNGLE)
    ctx:win_inline()
    draw_warp_button(ctx, "2-2", 2, 2, THEME.JUNGLE)
    ctx:win_inline()
    draw_warp_button(ctx, "2-3", 2, 3, THEME.JUNGLE)
    ctx:win_inline()
    draw_warp_button(ctx, "2-4", 2, 4, THEME.JUNGLE)
    ctx:win_inline()
    draw_warp_button(ctx, "Worm (J)", 2, 2, THEME.EGGPLANT_WORLD)

    draw_warp_button(ctx, "3-1", 3, 1, THEME.ICE_CAVES)
    ctx:win_inline()
    draw_warp_button(ctx, "3-2", 3, 2, THEME.ICE_CAVES)
    ctx:win_inline()
    draw_warp_button(ctx, "3-3", 3, 3, THEME.ICE_CAVES)
    ctx:win_inline()
    draw_warp_button(ctx, "3-4", 3, 4, THEME.ICE_CAVES)
    ctx:win_inline()
    draw_warp_button(ctx, "Worm (IC)", 3, 2, THEME.EGGPLANT_WORLD)
    ctx:win_inline()
    draw_warp_button(ctx, "MS", 3, 3, THEME.NEO_BABYLON)

    draw_warp_button(ctx, "4-1", 4, 1, THEME.TEMPLE)
    ctx:win_inline()
    draw_warp_button(ctx, "4-2", 4, 2, THEME.TEMPLE)
    ctx:win_inline()
    draw_warp_button(ctx, "4-3", 4, 3, THEME.TEMPLE)
    ctx:win_inline()
    draw_warp_button(ctx, "4-4", 4, 4, THEME.OLMEC)
    ctx:win_inline()
    draw_warp_button(ctx, "CoG", 4, 3, THEME.CITY_OF_GOLD)

    draw_warp_button(ctx, "5-1", 5, 1, THEME.VOLCANA)
    ctx:win_inline()
    draw_warp_button(ctx, "5-2", 5, 2, THEME.VOLCANA)
    ctx:win_inline()
    draw_warp_button(ctx, "5-3", 5, 3, THEME.VOLCANA)
    ctx:win_inline()
    draw_warp_button(ctx, "5-4", 5, 4, THEME.VOLCANA)

    warp_reset_run = ctx:win_check("Reset run", warp_reset_run)
end)

module.register_dev_section("Entity Spawners", function(ctx)
    for _, entity_spawner in pairs(entity_spawners) do
        if ctx:win_button(entity_spawner.name) then
            entity_spawner.spawn_func()
        end
    end
end)

register_option_callback("", options, draw_gui)

set_callback(function()
    options = {}
    for _, option in ipairs(registered_options) do
        options[option.id] = option.initial_value
    end
end, ON.LOAD)

return module
