local module = {}

local INDENT = 5

local dev_sections = {}
local registered_options = {}
local warp_reset_run = false
local entity_spawners = {}
local entity_spawner_choice_string
local entity_spawner_section_open = false

local function reset_options()
    options = {}
    for _, option in ipairs(registered_options) do
        options[option.id] = option.default_value
    end
end

function module.register_option_bool(id, label, desc, default_value, is_debug)
    table.insert(registered_options, {
        id = id,
        type = "bool",
        label = label,
        desc = desc,
        default_value = default_value,
        is_debug = is_debug == true
    })
end

function module.register_option_string(id, label, desc, default_value, is_debug)
    table.insert(registered_options, {
        id = id,
        type = "string",
        label = label,
        desc = desc,
        default_value = default_value,
        is_debug = is_debug == true
    })
end

-- Registers an option that will be included in saves and loads, but will not be automatically displayed in the options UI.
function module.register_option_hidden(id, default_value)
    table.insert(registered_options, {
        id = id,
        default_value = default_value,
        is_hidden = true
    })
end

function module.register_entity_spawner(name, spawn_func, snap_to_grid)
    table.insert(entity_spawners, {
        name = name,
        spawn_func = spawn_func,
        snap_to_grid = snap_to_grid == true
    })
    entity_spawner_choice_string = nil
end

function module.register_dev_section(name, callback)
    table.insert(dev_sections, {
        name = name,
        callback = callback
    })
end

local function draw_registered_options(ctx, is_debug)
    for _, option in pairs(registered_options) do
        if not option.is_hidden and option.is_debug == is_debug then
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
    if ctx:win_button("Reset options") then
        reset_options()
    end
    ctx:win_text("Reset all options to their default values. This only affects script options, not saved game data such as shortcuts or character unlocks.")

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

local function reset_run()
    if warp_reset_run then
        state.quest_flags = set_flag(state.quest_flags, QUEST_FLAG.RESET)
    end
end

local function draw_warp_button(ctx, name, world, level, theme, world_state)
    if ctx:win_button(name) then
        reset_run()
        worldlib.HD_WORLDSTATE_STATE = world_state or worldlib.HD_WORLDSTATE_STATUS.NORMAL
        -- TODO: These warps can get redirected by flagslib.onloading_levelrules.
		feelingslib.set_preset_feelings = nil
        warp(world, level, theme)
    end
end

local function draw_feeling_button(ctx, name, world, level, theme, cb)
    if ctx:win_button(name) then
        reset_run()
        worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL
        -- TODO: These warps can get redirected by flagslib.onloading_levelrules.
        feelingslib.set_preset_feelings = cb
        warp(world, level, theme)
    end
end

module.register_dev_section("Warps", function(ctx)
    draw_warp_button(ctx, "Camp", 1, 1, THEME.BASE_CAMP)
    ctx:win_inline()
    draw_warp_button(ctx, "Tut 1", 1, 1, THEME.DWELLING, worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)
    ctx:win_inline()
    draw_warp_button(ctx, "Tut 2", 1, 2, THEME.DWELLING, worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)
    ctx:win_inline()
    draw_warp_button(ctx, "Tut 3", 1, 3, THEME.DWELLING, worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)

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

    draw_warp_button(ctx, "Test 1", 1, 1, THEME.DWELLING, worldlib.HD_WORLDSTATE_STATUS.TESTING)
    ctx:win_inline()
    draw_warp_button(ctx, "Test 2", 1, 1, THEME.DWELLING, worldlib.HD_WORLDSTATE_STATUS.TESTING)

    warp_reset_run = ctx:win_check("Reset run", warp_reset_run)

    draw_feeling_button(ctx, "Udjat", 1, 2, THEME.DWELLING, function ()
        feelingslib.feeling_set(feelingslib.FEELING_ID.UDJAT)
    end)
    ctx:win_inline()
    draw_feeling_button(ctx, "Snakepit", 1, 2, THEME.DWELLING, function ()
        feelingslib.feeling_set(feelingslib.FEELING_ID.SNAKEPIT)
    end)

    draw_feeling_button(ctx, "Black Market", 2, 2, THEME.JUNGLE, function ()
        feelingslib.feeling_set(feelingslib.FEELING_ID.BLACKMARKET)

        feelingslib.feeling_clear(feelingslib.FEELING_ID.VAULT)
        feelingslib.feeling_set(feelingslib.FEELING_ID.BLACKMARKET_ENTRANCE, {1})
        feelingslib.feeling_clear(feelingslib.FEELING_ID.RUSHING_WATER)
        feelingslib.feeling_clear(feelingslib.FEELING_ID.TIKIVILLAGE)
    end)
end)

module.register_dev_section("Feelings", function (ctx)
end)

-- Calculates the selected entity spawner position, or returns nil if the position can't be determined.
local function compute_entity_spawner_position()
    if players[1] then
        local entity_spawner = entity_spawners[options.entity_spawner_index]
        if entity_spawner then
            local x, y, l = get_position(players[1].uid)
            x = x + options.entity_spawner_offset_x
            y = y + options.entity_spawner_offset_y
            if entity_spawner.snap_to_grid then
                x = math.floor(x + 0.5)
                y = math.floor(y + 0.5)
            end
            return x, y, l
        end
    end
end

module.register_option_hidden("entity_spawner_index", 1)
module.register_option_hidden("entity_spawner_offset_x", -5)
module.register_option_hidden("entity_spawner_offset_y", 0)
module.register_option_hidden("entity_spawner_position_visible", true)
module.register_dev_section("Entity Spawner", function(ctx)
    entity_spawner_section_open = true
    if not entity_spawner_choice_string then
        local choice_names = {}
        for _, entity_spawner in pairs(entity_spawners) do
            table.insert(choice_names, entity_spawner.name)
        end
        entity_spawner_choice_string = table.concat(choice_names, "\0").."\0\0"
    end
    ctx:win_width(0.5)
    options.entity_spawner_index = ctx:win_combo("Entity", options.entity_spawner_index, entity_spawner_choice_string)

    ctx:win_text("Position (relative to player 1)")
    ctx:win_text("X")
    ctx:win_inline()
    ctx:win_width(0.4)
    options.entity_spawner_offset_x = ctx:win_drag_float("##entity_spawner_offset_x", options.entity_spawner_offset_x, -8, 8)
    ctx:win_inline()
    ctx:win_text("Y")
    ctx:win_width(0.4)
    ctx:win_inline()
    options.entity_spawner_offset_y = ctx:win_drag_float("##entity_spawner_offset_y", options.entity_spawner_offset_y, -4, 4)
    options.entity_spawner_position_visible = ctx:win_check("Show position in world", options.entity_spawner_position_visible)

    if ctx:win_button("Spawn entity") then
        local entity_spawner = entity_spawners[options.entity_spawner_index]
        if entity_spawner then
            local x, y, l = compute_entity_spawner_position()
            if x and y and l then
                entity_spawner.spawn_func(x, y, l)
            end
        end
    end
end)

local ENTITY_SPAWNER_LINE_UCOLOR = Color:new(0, 1, 1, 0.2):get_ucolor()
local ENTITY_SPAWNER_FILL_UCOLOR = Color:new(0, 1, 1, 0.1):get_ucolor()
set_callback(function(ctx)
    if entity_spawner_section_open and options.entity_spawner_position_visible then
        local world_x, world_y = compute_entity_spawner_position()
        if world_x and world_y then
            ctx:draw_layer(DRAW_LAYER.BACKGROUND)
            local screen_x1, screen_y1 = screen_position(world_x - 0.5, world_y + 0.5)
            local screen_x2, screen_y2 = screen_position(world_x + 0.5, world_y - 0.5)
            ctx:draw_rect(screen_x1, screen_y1, screen_x2, screen_y2, 2, 5, ENTITY_SPAWNER_LINE_UCOLOR)
            ctx:draw_rect_filled(screen_x1, screen_y1, screen_x2, screen_y2, 5, ENTITY_SPAWNER_FILL_UCOLOR)
        end
    end
    entity_spawner_section_open = false
end, ON.GUIFRAME)

register_option_callback("", options, draw_gui)

savelib.register_save_callback(function(save_data)
    save_data.options = options
end)

savelib.register_load_callback(function(load_data)
    -- Reset the options to their default values, and then overwrite them with any valid options in the load data.
    -- Options missing from the load data will keep their default values. Unrecognized options in the load data will be ignored.
    reset_options()
    if load_data.options then
        for _, option in ipairs(registered_options) do
            local load_value = load_data.options[option.id]
            if load_value ~= nil then
                options[option.id] = load_value
            end
        end
    end
end)

return module
