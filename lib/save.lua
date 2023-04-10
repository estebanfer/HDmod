local module = {}

local save_callbacks = {}
local load_callbacks = {}

-- Registers a callback to be executed before saving the save file. The callback signature is `nil function(save_data)`.
-- The `save_data` argument is a table containing the data that will be saved. It's shared between all registered save callbacks, and can be modified as needed.
function module.register_save_callback(callback)
    table.insert(save_callbacks, callback)
end

-- Registers a callback to be executed after loading the save file. The callback signature is `nil function(load_data)`.
-- The `load_data` argument is a table containing the data that was loaded. It's shared between all registered load callbacks.
function module.register_load_callback(callback)
    table.insert(load_callbacks, callback)
end

set_callback(function(save_ctx)
    local save_data = { format = 1 }
    for _, callback in ipairs(save_callbacks) do
        callback(save_data)
    end
    local success, result = pcall(function() return json.encode(save_data) end)
    if success then
        save_ctx:save(result)
    else
        print("Warning: Failed to encode save data as JSON: "..result)
    end
end, ON.SAVE)

set_callback(function(load_ctx)
    local load_data
    local load_json = load_ctx:load()
    -- load_json will be nil or empty if the save file is missing or empty.
    if load_json and load_json ~= "" then
        local success, result = pcall(function() return json.decode(load_json) end)
        if success then
            load_data = result
        else
            print("Warning: Failed to decode loaded data as JSON: "..result)
        end
    end
    if load_data == nil then
        load_data = { format = 1 }
    end
    for _, callback in ipairs(load_callbacks) do
        callback(load_data)
    end
end, ON.LOAD)

return module
