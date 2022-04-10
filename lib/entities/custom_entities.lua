meta = {
    name = "Custom-Entities-Library",
    version = "1.0a",
    author = "Estebanfer",
    description = "A library for creating custom entities"
}


local FLAGS_BIT = { --https://github.com/Mr-Auto/spelunky2-lua-libs/blob/main/libraries/flags/flags.lua
0x1,
0x2,
0x4,
0x8,
0x10,
0x20,
0x40,
0x80,
0x100,
0x200,
0x400,
0x800,
0x1000,
0x2000,
0x4000,
0x8000,
0x10000,
0x20000,
0x40000,
0x80000,
0x100000,
0x200000,
0x400000,
0x800000,
0x1000000,
0x2000000,
0x4000000,
0x8000000,
0x10000000,
0x20000000,
0x40000000,
0x80000000,
}
local module = {}

---@class CustomEntityType
---@field set fun(ent: Entity, c_data: table, args: any): table | nil
---@field update_callback fun(ent: Entity, c_data: table): nil
---@field update fun(ent: Entity, c_data: table, c_type: table, c_type_id: integer): nil
---@field carry_type integer
---@field ent_type ENT_TYPE
---@field update_type integer
---@field entities table
---@field after_destroy_callback nil | function
---@field custom_powerup_id nil | integer
---@field pickup_callback nil | function
---@field entity_name nil | string
---@field texture_id nil | integer
---@field anim_frame nil | integer
---@field price nil | integer
---@field price_inflation nil | integer

---@type CustomEntityType[]
local custom_types = {}

local cb_update, cb_loading, cb_transition, cb_pre_level_gen, cb_post_level_gen, cb_clonegunshot = -1, -1, -1, -1, -1, -1
local didnt_init = true

---@class TransitionInfo
---@field custom_type_id integer
---@field data table


---@class PlayerTransitionInfo : TransitionInfo
---@field slot integer
---@field carry_type integer

---@type PlayerTransitionInfo[]
local custom_entities_t_info = {} --transition info


---@class HHTransitionInfo : TransitionInfo
---@field e_type integer
---@field hh_num integer
---@field leader_player_slot integer

---@type HHTransitionInfo[]
local custom_entities_t_info_hh = {}

---@type TransitionInfo[]
local custom_entities_t_info_storage = {}


---@class COG_DuatTransitionInfo : TransitionInfo
---@field slot integer

---For transition of powerups
---@type COG_DuatTransitionInfo[]
local custom_entities_t_info_cog_ankh = {}
local storage_pos = nil

local CARRY_TYPE = {
    HELD = 1,
    MOUNT = 2,
    BACK = 3,
    POWERUP = 4
}

local function has(arr, item)
    for _, v in ipairs(arr) do
        if v == item then
            return true
        end
    end
    return false
end

local function join(a, b)
    local result = {table.unpack(a)}
    table.move(b, 1, #b, #result + 1, result)
    return result
end

local function clone_chances(tabl)
    return {
        common = {table.unpack(tabl.common)},
        low = {table.unpack(tabl.low)},
        lower = {table.unpack(tabl.lower)}
    }
end

local all_shop_ents = {ENT_TYPE.ITEM_PICKUP_ROPEPILE, ENT_TYPE.ITEM_PICKUP_BOMBBAG, ENT_TYPE.ITEM_PICKUP_BOMBBOX, ENT_TYPE.ITEM_PICKUP_PARACHUTE, ENT_TYPE.ITEM_PICKUP_SPECTACLES, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY, ENT_TYPE.ITEM_PICKUP_COMPASS, ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, ENT_TYPE.ITEM_PICKUP_SPIKESHOES, ENT_TYPE.ITEM_PICKUP_PASTE, ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, ENT_TYPE.ITEM_WEBGUN, ENT_TYPE.ITEM_MACHETE, ENT_TYPE.ITEM_BOOMERANG, ENT_TYPE.ITEM_CAMERA, ENT_TYPE.ITEM_MATTOCK, ENT_TYPE.ITEM_TELEPORTER, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_METAL_SHIELD, ENT_TYPE.ITEM_PURCHASABLE_CAPE, ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK, ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK, ENT_TYPE.ITEM_PURCHASABLE_POWERPACK, ENT_TYPE.ITEM_PURCHASABLE_JETPACK, ENT_TYPE.ITEM_PRESENT, ENT_TYPE.ITEM_PICKUP_HEDJET, ENT_TYPE.ITEM_PICKUP_ROYALJELLY, ENT_TYPE.ITEM_ROCK, ENT_TYPE.ITEM_SKULL, ENT_TYPE.ITEM_POT, ENT_TYPE.ITEM_WOODEN_ARROW, ENT_TYPE.ITEM_PICKUP_COOKEDTURKEY, ENT_TYPE.ITEM_SHOTGUN, ENT_TYPE.ITEM_PLASMACANNON, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_WEBGUN, ENT_TYPE.ITEM_CROSSBOW}
local normal_shop_rooms = {ROOM_TEMPLATE.SHOP, ROOM_TEMPLATE.SHOP_LEFT, ROOM_TEMPLATE.SHOP_ENTRANCE_UP, ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT, ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN, ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT, ROOM_TEMPLATE.CURIOSHOP, ROOM_TEMPLATE.CURIOSHOP_LEFT, ROOM_TEMPLATE.CAVEMANSHOP, ROOM_TEMPLATE.CAVEMANSHOP_LEFT, ROOM_TEMPLATE.GHISTSHOP_BACKLAYER}
local DICESHOP_ITEMS = {ENT_TYPE.ITEM_PICKUP_BOMBBAG, ENT_TYPE.ITEM_PICKUP_BOMBBOX, ENT_TYPE.ITEM_PICKUP_ROPEPILE, ENT_TYPE.ITEM_PICKUP_COMPASS, ENT_TYPE.ITEM_PICKUP_PASTE, ENT_TYPE.ITEM_PICKUP_PARACHUTE, ENT_TYPE.ITEM_PURCHASABLE_CAPE, ENT_TYPE.ITEM_PICKUP_SPECTACLES, ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, ENT_TYPE.ITEM_PICKUP_SPIKESHOES, ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, ENT_TYPE.ITEM_MACHETE, ENT_TYPE.ITEM_BOOMERANG, ENT_TYPE.ITEM_CROSSBOW, ENT_TYPE.ITEM_SHOTGUN, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_WEBGUN, ENT_TYPE.ITEM_CAMERA, ENT_TYPE.ITEM_MATTOCK, ENT_TYPE.ITEM_PURCHASABLE_JETPACK, ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK, ENT_TYPE.ITEM_TELEPORTER, ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK, ENT_TYPE.ITEM_PURCHASABLE_POWERPACK}

local function new_chances()
    return {
        common = {},
        low = {},
        lower = {}
    }
end
local custom_types_shop = {} --SHOP_TYPE
for i = 0, 13 do
    custom_types_shop[i] = new_chances()
end
local custom_types_diceshop = new_chances()
local custom_types_tuskdiceshop = new_chances()
local custom_shop_items_set = false --if the set_pre_entity_spawn for custom shop items was already set

local shops_by_room_pos = {}

local custom_types_container = {
    [ENT_TYPE.ITEM_CRATE] = new_chances(),
    [ENT_TYPE.ITEM_PRESENT] = new_chances(),
    [ENT_TYPE.ITEM_GHIST_PRESENT] = new_chances()
}
module.ALL_CONTAINERS = {
    ENT_TYPE.ITEM_CRATE,
    ENT_TYPE.ITEM_PRESENT,
    ENT_TYPE.ITEM_GHIST_PRESENT
}
local custom_container_items_set = false
local custom_container_item_spawns_set = false
local nonflammable_backs_callbacks_set = false
local item_draw_callbacks_set = false
local entity_crust_callbacks_set = false
local clonegunshot_custom_id = -1

local just_burnt, last_burn = 0, 0 --for non_flammable backpacks

--chance type
module.CHANCE = {
    COMMON = "common",
    LOW = "low",
    LOWER = "lower"
}
--SHOP_TYPE
local SHOP_ROOM_TYPES = {
    GENERAL_STORE = 0,
    CLOTHING_SHOP = 1,
    WEAPON_SHOP = 2,
    SPECIALTY_SHOP = 3,
    HIRED_HAND_SHOP = 4,
    PET_SHOP = 5,
    HEDJET_SHOP = 8,
    TUN = 9,
    CAVEMAN = 10,
    TURKEY_SHOP = 11,
    GHIST_SHOP = 12,
    DICESHOP = ROOM_TEMPLATE.DICESHOP, --75
    TUSKDICESHOP = ROOM_TEMPLATE.TUSKDICESHOP,
}

---All common shops (not shops like ghist or hedjet shop)
module.ALL_SHOPS = {SHOP_ROOM_TYPES.GENERAL_STORE, SHOP_ROOM_TYPES.CLOTHING_SHOP, SHOP_ROOM_TYPES.WEAPON_SHOP, SHOP_ROOM_TYPES.SPECIALTY_SHOP, SHOP_ROOM_TYPES.HIRED_HAND_SHOP, SHOP_ROOM_TYPES.PET_SHOP, SHOP_ROOM_TYPES.DICESHOP, SHOP_ROOM_TYPES.TUSKDICESHOP, SHOP_ROOM_TYPES.TUN, SHOP_ROOM_TYPES.CAVEMAN, SHOP_ROOM_TYPES.TURKEY_SHOP}

local weapon_info = {
    [ENT_TYPE.ITEM_SHOTGUN] = {
        bullet = ENT_TYPE.ITEM_BULLET,
        bullet_off_y = 0.099998474121094,
        sound = VANILLA_SOUND.ITEMS_SHOTGUN_FIRE,
        shots = 0,
        callb_set = false,
        sound_callb_set = false
    },
    [ENT_TYPE.ITEM_FREEZERAY] = {
        bullet = ENT_TYPE.ITEM_FREEZERAYSHOT,
        bullet_off_y = 0.12000274658203,
        sound = VANILLA_SOUND.ITEMS_FREEZE_RAY,
        shots = 0,
        callb_set = false,
        sound_callb_set = false
    },
    [ENT_TYPE.ITEM_PLASMACANNON] = {
        bullet = ENT_TYPE.ITEM_PLASMACANNON_SHOT,
        bullet_off_y = 0.0,
        sound = VANILLA_SOUND.ITEMS_PLASMA_CANNON,
        shots = 0,
        callb_set = false,
        sound_callb_set = false
    },
    [ENT_TYPE.ITEM_CLONEGUN] = {
        bullet = ENT_TYPE.ITEM_CLONEGUNSHOT,
        bullet_off_y = 0.12000274658203,
        sound = VANILLA_SOUND.ITEMS_CLONE_GUN,
        shots = 0,
        callb_set = false,
        sound_callb_set = false
    },
}

module.UPDATE_TYPE = {
    FRAME = 0,
    POST_STATEMACHINE = 1,
    PRE_STATEMACHINE = 2
}

local function _set_custom_entity(uid, ent, custom_type_id, c_data, optional_args)
    local custom_type = custom_types[custom_type_id]
    c_data = custom_type.set(ent, c_data, custom_type_id, optional_args)
    if not c_data then
        c_data = {}
    end
    if custom_type.update_type ~= module.UPDATE_TYPE.FRAME then
        if custom_type.update_type == module.UPDATE_TYPE.POST_STATEMACHINE then
            c_data._statemachine = set_post_statemachine(uid, custom_type.update)
        else
            c_data._statemachine = set_pre_statemachine(uid, custom_type.update)
        end
        set_on_kill(uid, function()
            custom_type.entities[uid] = nil
            clear_entity_callback(uid, c_data._statemachine)
            if custom_type.after_destroy_callback then
                custom_type.after_destroy_callback(c_data, uid)
            end
        end)
    end
    custom_type.entities[uid] = c_data
end

local function set_transition_info(c_type_id, data, slot, carry_type)
    table.insert(custom_entities_t_info,
    {
        custom_type_id = c_type_id,
        data = data,
        slot = slot,
        carry_type = carry_type
    })
end

local function get_hh_number(char_uid, hh_info_cache)
    ---@type Player
    local char = get_entity(char_uid)
    if char.inventory.player_slot == -1 then
        if hh_info_cache[char] then
            local char_num, player_slot = table.unpack(hh_info_cache[char])
            return char_num + 1, player_slot
        end
        local char_num, player_slot = get_hh_number(char.linked_companion_parent, hh_info_cache)
        char_num = char_num + 1
        hh_info_cache[char_uid] = {char_num, player_slot}
        return char_num, player_slot
    else --is a player
        return 0, char.inventory.player_slot
    end
end

local function set_transition_info_hh(c_type_id, data, e_type, hh_uid, hh_info_cache)
    local hh_num, leader_player_slot = get_hh_number(hh_uid, hh_info_cache)
    table.insert(custom_entities_t_info_hh,
    {
        custom_type_id = c_type_id,
        data = data,
        e_type = e_type,
        hh_num = hh_num,
        leader_player_slot = leader_player_slot
    })
end

local function set_transition_info_storage(c_type_id, data, e_type)
    if custom_entities_t_info_storage[e_type] then
        table.insert(custom_entities_t_info_storage[e_type], {
            custom_type_id = c_type_id,
            data = data
        })
    else
        custom_entities_t_info_storage[e_type] = {
            {
                custom_type_id = c_type_id,
                data = data
            }
        }
    end
end

local is_portal = false
local function update_customs()
    is_portal = get_entities_by(ENT_TYPE.FX_PORTAL, MASK.FX, LAYER.BOTH)[1] ~= nil
    for c_type_id, c_type in ipairs(custom_types) do
        if c_type.update_type == module.UPDATE_TYPE.FRAME then
            for uid, c_data in pairs(c_type.entities) do
                local ent = get_entity(uid)
                if ent then
                    c_type.update(ent, c_data, c_type, c_type_id)
                else
                    if c_type.after_destroy_callback then
                        c_type.after_destroy_callback(c_data)
                    end
                    c_type.entities[uid] = nil
                end
            end
        end
    end
end

local function set_custom_items_waddler(items_zone, layer)
    local stored_items = get_entities_overlapping_hitbox(0, MASK.ITEM, items_zone, layer)
    for _, uid in ipairs(stored_items) do
        local ent = get_entity(uid)
        local custom_t_info = custom_entities_t_info_storage[ent.type.id]
        if custom_t_info and custom_t_info[1] then
            _set_custom_entity(uid, ent, custom_t_info[1].custom_type_id, custom_t_info[1].data)
            table.remove(custom_entities_t_info_storage[ent.type.id], 1)
        end
    end
end

local function set_custom_ents_from_previous(companions)
    for _, info in ipairs(custom_entities_t_info) do
        for _, p in ipairs(players) do
            if p.inventory.player_slot == info.slot then
                local custom_ent
                if info.carry_type == CARRY_TYPE.MOUNT then
                    custom_ent = p:topmost_mount()
                elseif info.carry_type == CARRY_TYPE.HELD then
                    custom_ent = p:get_held_entity()
                elseif info.carry_type == CARRY_TYPE.BACK then
                    custom_ent = get_entity(p:worn_backitem())
                elseif info.carry_type == CARRY_TYPE.POWERUP then
                    custom_ent = p
                end
                _set_custom_entity(custom_ent.uid, custom_ent, info.custom_type_id, info.data)
                break
            end
        end
    end
    local hh_info_cache = {}
    for _, info in pairs(custom_entities_t_info_hh) do
        for _, uid in ipairs(companions) do
            local hh_num, player_slot = get_hh_number(uid, hh_info_cache)
            local ent = get_entity(uid)
            if ent.type.id == info.e_type and hh_num == info.hh_num and player_slot == info.leader_player_slot then
                local custom_ent = ent:get_held_entity()
                if custom_ent then
                    _set_custom_entity(custom_ent.uid, custom_ent, info.custom_type_id, info.data)
                    break
                end
            end
        end
    end
    if storage_pos then
        set_custom_items_waddler(AABB:new(storage_pos.x-0.5, storage_pos.y+1.5, storage_pos.x+1.5, storage_pos.y), storage_pos.l)
    end
    storage_pos = nil
end

set_post_tile_code_callback(function(x, y, l)
    if not storage_pos then
        storage_pos = {['x'] = x, ['y'] = y, ['l'] = l}
    end
end, 'storage_floor')

local function get_types_cloneable(entity_uids)
    local ret = {}
    for _, uid in ipairs(entity_uids) do
        if not test_flag(get_entity_flags(uid), 32) then -- is always enabled when the entity is held by something
            local _type = get_entity_type(uid)
            ret[_type] = uid
        end
    end
    return ret
end
local CLONEABLE_MASK = MASK.PLAYER | MASK.MOUNT | MASK.MONSTER | MASK.ITEM

local function set_clonegunshot_custom_ent()
    local _clonegunshot_custom_id = module.new_custom_entity(function(entity)
        local hitbox = get_hitbox(entity.uid)
        return {
            last_overlapping = get_entities_overlapping_hitbox(0, CLONEABLE_MASK, hitbox, entity.layer)
        }
    end, function(entity, c_data)
        local hitbox = get_hitbox(entity.uid)
        c_data.last_overlapping = get_entities_overlapping_hitbox(0, CLONEABLE_MASK, hitbox, entity.layer)
    end, nil, ENT_TYPE.ITEM_CLONEGUNSHOT)

    module.add_after_destroy_callback(_clonegunshot_custom_id, function(c_data)
        local overlapping_types = get_types_cloneable(c_data.last_overlapping)
        for _, uid in ipairs(get_entities_by(ENT_TYPE.FX_TELEPORTSHADOW, MASK.ITEM, LAYER.BOTH)) do
            if get_entity_type(uid+1) ~= ENT_TYPE.FX_TELEPORTSHADOW then
                local spawned_uid = uid-1
                local spawned_ent = get_entity(spawned_uid)
                if spawned_ent.overlay and spawned_ent.overlay.uid == spawned_uid - 1 then --for jetpacks that spawn a FX_JETPACKFLAME and maybe other ents
                    spawned_uid = spawned_uid -1
                    spawned_ent = get_entity(spawned_uid)
                end
                local _type = get_entity_type(spawned_uid)
                local cloned_uid = overlapping_types[_type]
                if cloned_uid then
                    for id, c_type in ipairs(custom_types) do
                        if c_type.entities[cloned_uid] and c_type.carry_type ~= CARRY_TYPE.POWERUP then
                            _set_custom_entity(spawned_uid, spawned_ent, id, module.get_custom_entity(cloned_uid, id))
                        end
                    end
                end
            end
        end
    end)
    return _clonegunshot_custom_id
end

---init the lib callbacks
---@param game_frame boolean @Run on GAMEFRAME if `true`
---@param not_handle_clonegun boolean @disable handling cloning of custom entities
function module.custom_init(game_frame, not_handle_clonegun)
    if (game_frame) then
        cb_update = set_callback(function()
            update_customs()
        end, ON.GAMEFRAME)
    else
        cb_update = set_callback(function()
            update_customs()
        end, ON.FRAME)
    end

    if not not_handle_clonegun then
        if clonegunshot_custom_id == -1 then
            clonegunshot_custom_id = set_clonegunshot_custom_ent()
        end
        cb_clonegunshot = set_post_entity_spawn(function(entity)
            module.set_custom_entity(entity.uid, clonegunshot_custom_id)
        end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_CLONEGUNSHOT)
    end

    cb_loading = set_callback(function()
        if ((state.screen_next == SCREEN.TRANSITION and state.screen ~= SCREEN.SPACESHIP) or state.screen_next == SCREEN.SPACESHIP) then
            local is_storage_floor_there = get_entities_by(ENT_TYPE.FLOOR_STORAGE, MASK.FLOOR, LAYER.BOTH)[1] ~= nil
            if state.loading == 2 then
                local hh_info_cache = {}
                for c_id,c_type in ipairs(custom_types) do
                    for uid, c_data in pairs(c_type.entities) do
                        if c_type.carry_type == CARRY_TYPE.HELD then
                            ---@type Movable
                            local ent = get_entity(uid)
                            local holder
                            if not ent or ent.state == 24 or ent.last_state == 24 then
                                holder = c_data.last_holder
                            else
                                holder = ent.overlay
                            end
                            if holder and holder.type.search_flags & MASK.PLAYER == MASK.PLAYER then
                                if c_data.is_worn_backitem or holder:worn_backitem() == uid then
                                    set_transition_info(c_id, c_data, holder.inventory.player_slot, CARRY_TYPE.BACK)
                                elseif holder.inventory.player_slot == -1 then
                                    set_transition_info_hh(c_id, c_data, holder.type.id, holder.uid, hh_info_cache)
                                else
                                    set_transition_info(c_id, c_data, holder.inventory.player_slot, CARRY_TYPE.HELD)
                                end
                            elseif ent and is_storage_floor_there and ent.standing_on_uid and get_entity(ent.standing_on_uid).type.id == ENT_TYPE.FLOOR_STORAGE then
                                set_transition_info_storage(c_id, c_data, ent.type.id)
                            end
                        elseif c_type.carry_type == CARRY_TYPE.MOUNT then
                            ---@type Mount
                            local ent = get_entity(uid)
                            local holder, rider_uid
                            if not ent or ent.state == 24 or ent.last_state == 24 then
                                holder = c_data.last_holder
                                rider_uid = c_data.last_rider_uid
                            else
                                holder = ent.overlay
                                rider_uid = ent.rider_uid
                            end
                            if holder then
                                if holder.inventory.player_slot == -1 then
                                    set_transition_info_hh(c_id, c_data, holder.type.id, holder.uid, hh_info_cache)
                                else
                                    set_transition_info(c_id, c_data, holder.inventory.player_slot, CARRY_TYPE.HELD)
                                end
                            elseif rider_uid and rider_uid ~= -1 then
                                holder = get_entity(rider_uid)
                                if holder and holder.type.search_flags == MASK.PLAYER then
                                    set_transition_info(c_id, c_data, holder.inventory.player_slot, CARRY_TYPE.MOUNT)
                                end
                            end
                        elseif c_type.carry_type == CARRY_TYPE.POWERUP then
                            ---@type Player
                            local ent = get_entity(uid)
                            if ent then
                                set_transition_info(c_id, c_data, ent.inventory.player_slot, CARRY_TYPE.POWERUP)
                            end
                        end
                    end
                end
            elseif state.loading == 3 then
                for _,c_type in ipairs(custom_types) do
                    c_type.entities = {}
                end
            end
            if custom_entities_t_info_cog_ankh[1] then
                for _, info in ipairs(custom_entities_t_info_cog_ankh) do
                    set_transition_info(info.custom_type_id, info.data, info.slot, CARRY_TYPE.POWERUP)
                end
            end
            custom_entities_t_info_cog_ankh = {}
        end
    end, ON.LOADING)

    cb_transition = set_callback(function()
        local companions = get_entities_by(0, MASK.PLAYER, LAYER.FRONT)
        set_custom_ents_from_previous(companions)
    end, ON.TRANSITION)

    cb_post_level_gen = set_callback(function()
        if state.screen == 12 then
            local px, py, pl = get_position(players[1].uid)
            local companions = get_entities_at(0, MASK.PLAYER, px, py, pl, 2)
            set_custom_ents_from_previous(companions)
            custom_entities_t_info = {}
            custom_entities_t_info_hh = {}
        end
    end, ON.POST_LEVEL_GENERATION)

    cb_pre_level_gen = set_callback(function()
        shops_by_room_pos = {}
        for _,c_type in ipairs(custom_types) do
            c_type.entities = {}
        end
    end, ON.PRE_LEVEL_GENERATION)
end

---init the lib callbacks (checks if it was already init and uses GAMEFRAME by default)
function module.init()
    if didnt_init then
        module.custom_init(true)
        didnt_init = false
    end
end

---Stop the library callbacks (not the extras callbacks)
function module.stop()
    clear_callback(cb_update)
    clear_callback(cb_loading)
    clear_callback(cb_transition)
    clear_callback(cb_post_level_gen)
    clear_callback(cb_pre_level_gen)
    clear_callback(cb_clonegunshot)
    didnt_init = true
end

--update last_holder when there's a portal and the entity isn't entering it
local function update_custom_held_portal(ent, c_data)
    if is_portal and ent.state ~= 24 and ent.last_state ~= 24 and ent.overlay then --24 seems to be the state when entering portal
        c_data.last_holder = ent.overlay
        c_data.is_worn_backitem = ent.overlay.type.search_flags & MASK.PLAYER == MASK.PLAYER and ent.overlay:worn_backitem() == ent.uid
    end
end

local function update_custom_mount_portal(ent, c_data)
    if is_portal and ent.state ~= 24 and ent.last_state ~= 24 then
        c_data.last_holder = ent.overlay
        c_data.last_rider_uid = ent.rider_uid
    end
end

local function update_custom_held(ent, c_data, c_type)
    c_type.update_callback(ent, c_data)
    update_custom_held_portal(ent, c_data)
end

local function update_custom_mount(ent, c_data, c_type)
    c_type.update_callback(ent, c_data)
    update_custom_mount_portal(ent, c_data)
end

local function update_custom_ent(ent, c_data, c_type)
    c_type.update_callback(ent, c_data)
end

---@alias EntSet fun(ent: userdata, data: table, custom_id: integer, extra_args: any):table
---@alias EntUpdate fun(ent: userdata, c_data: table):nil

local function _new_custom_entity(set_func, _update_func, update_callback, carry_type, ent_type, update_type)
    if update_type == nil then
        update_type = module.UPDATE_TYPE.FRAME
    end

    local custom_id = #custom_types + 1
    local update_func
    if update_type == module.UPDATE_TYPE.FRAME then
        update_func = _update_func
    else --is post or pre statemachine
        update_func = function(entity)
            local custom_type = custom_types[custom_id]
            local c_data = custom_type.entities[entity.uid]
            _update_func(entity, c_data, custom_type)
        end
    end
    custom_types[custom_id] = {
        set = set_func,
        update_callback = update_callback,
        update = update_func,
        carry_type = carry_type,
        ent_type = ent_type,
        update_type = update_type,
        entities = {}
    }
    return custom_id, custom_types[custom_id]
end

---Create a new custom entity type
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param carry_type? integer @Use `CARRY_TYPE`
---@param ent_type? integer
---@param update_type? integer
---@return integer
function module.new_custom_entity(set_func, update_func, carry_type, ent_type, update_type)
    local update
    if carry_type == CARRY_TYPE.HELD then
        update = update_custom_held
    elseif carry_type == CARRY_TYPE.MOUNT then
        update = update_custom_mount
    else
        update = update_custom_ent
    end
    return _new_custom_entity(set_func, update, update_func, carry_type, ent_type, update_type)
end


local function custom_gun_update(ent, c_data, c_type)
    ent.cooldown = math.max(ent.cooldown, 2)
    local holder = ent.overlay
    if holder and holder.type.search_flags == MASK.PLAYER then --Other entities that can hold guns will never shoot when cooldown isn't zero, so only players, also to prevent activefloors
        if holder:is_button_pressed(BUTTON.WHIP) and ent.cooldown == 2 and holder.state ~= CHAR_STATE.DUCKING and holder.animation_frame ~= 18 then
            ent.cooldown = c_type.cooldown+2
            local recoil_dir = test_flag(holder.flags, ENT_FLAG.FACING_LEFT) and 1 or -1
            holder.velocityx = holder.velocityx + c_type.recoil_x*recoil_dir
            holder.velocityy = holder.velocityy + c_type.recoil_y
            c_type.shoot(ent, c_data)
        end
    end
    c_type.update_callback(ent, c_data)
    update_custom_held_portal(ent, c_data)
end

---Create a new custom entity type that is a gun
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param firefunc fun(ent:userdata, c_data:table):nil
---@param cooldown integer @Cooldown, in frames
---@param recoil_x number
---@param recoil_y number
---@param ent_type integer
---@return integer
function module.new_custom_gun(set_func, update_func, firefunc, cooldown, recoil_x, recoil_y, ent_type, update_type)
    local custom_id, custom_type = _new_custom_entity(set_func, custom_gun_update, update_func, CARRY_TYPE.HELD, ent_type, update_type)
    custom_type.shoot = firefunc
    custom_type.cooldown = cooldown
    custom_type.recoil_x = recoil_x
    custom_type.recoil_y = recoil_y
    return custom_id
end

---@class CustomTypeWeapon : CustomEntityType
---@field bulletfunc function
---@field mute_sound boolean
---@field cooldown integer
---@field recoil_x number
---@field recoil_y number

local function set_custom_bullet_callback(weapon_id)
    set_pre_entity_spawn(function(entity_type, x, y, layer, _, _)
        --horizontal offset probably isn't very useful to know cause it changes when being next to a wall
        --freezeray and clonegun bullet offset: 0.5, ~0.12
        --plasmacannon: ~0.3545, 0.0
        --shotgun: ~0.35, ~0.1
        local weapons_left = get_entities_at(weapon_id, MASK.ITEM, x-0.25, y-0.12, layer, 0.4)
        local last_left = #weapons_left
        local weapons = join(weapons_left, get_entities_at(weapon_id, MASK.ITEM, x+0.25, y-0.12, layer, 0.4))
        ---@type CustomTypeWeapon
        for _,c_type in ipairs(custom_types) do
            for i, weapon_uid in ipairs(weapons) do
                local c_data = c_type.entities[weapon_uid]
                if c_data and c_type.bulletfunc and weapon_info[c_type.ent_type].bullet == entity_type and (c_data.not_shot and c_data.not_shot ~= 0) then
                    local weapon = get_entity(weapon_uid)
                    ---@type Movable
                    local holder = weapon.overlay
                    if holder and ( (holder:is_button_pressed(BUTTON.WHIP) and holder.state ~= CHAR_STATE.DUCKING) or (holder.type.id == ENT_TYPE.MONS_CAVEMAN and holder.velocityy > 0.05 and holder.velocityy < 0.0501 and holder.state == CHAR_STATE.STANDING) ) and weapon.cooldown == 0 then
                        local wx, wy = get_position(weapon_uid)
                        if weapon_info[weapon_id].bullet_off_y+0.001 >= y-wy and weapon_info[weapon_id].bullet_off_y-0.001 <= y-wy
                        and test_flag(weapon.flags, ENT_FLAG.FACING_LEFT) == (i <= last_left) then
                            if c_type.mute_sound then
                                weapon_info[weapon_id].shots = weapon_info[weapon_id].shots + 1
                            end
                            if entity_type == ENT_TYPE.ITEM_BULLET then
                                c_data.not_shot = c_data.not_shot - 1
                            else
                                c_data.not_shot = false
                            end
                            if c_type.cooldown then
                                weapon.cooldown = c_type.cooldown+2
                            end
                            local recoil_dir = test_flag(holder.flags, ENT_FLAG.FACING_LEFT) and 1 or -1
                            holder.velocityx = holder.velocityx + c_type.recoil_x*recoil_dir
                            holder.velocityy = holder.velocityy + c_type.recoil_y

                            c_type.bulletfunc(weapon, c_data)
                            return spawn_entity(ENT_TYPE.ITEM_BULLET, 0, 0, layer, 0, 0)
                        end
                    end
                end
            end
        end
    end, SPAWN_TYPE.SYSTEMIC, MASK.ITEM, weapon_info[weapon_id].bullet)

    weapon_info[weapon_id].callb_set = true
end

local function custom_gun2_shotgun_update(ent, c_data, c_type)
    c_data.not_shot = 6
    c_type.update_callback(ent, c_data)
    update_custom_held_portal(ent, c_data)
end

local function custom_gun2_update(ent, c_data, c_type)
    c_data.not_shot = true
    c_type.update_callback(ent, c_data)
    update_custom_held_portal(ent, c_data)
end

---Create a new custom entity type that is a gun, is called for each bullet, so be careful with recoil with shotgun
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param bulletfunc fun(gun_ent:userdata, c_data:table):nil @Called for each bullet on pre_entity_spawn
---@param cooldown integer
---@param recoil_x number
---@param recoil_y number
---@param ent_type integer
---@param mute_sound boolean
---@return integer
function module.new_custom_gun2(set_func, update_func, bulletfunc, cooldown, recoil_x, recoil_y, ent_type, mute_sound, update_type)
    if not weapon_info[ent_type].callb_set then
        set_custom_bullet_callback(ent_type)
    end
    if mute_sound and not weapon_info[ent_type].sound_callb_set then
        --Crashes sometimes on OL, not on PL
        set_vanilla_sound_callback(weapon_info[ent_type].sound, VANILLA_SOUND_CALLBACK_TYPE.STARTED, function(sound)
            if weapon_info[ent_type].shots > 0 then
                sound:set_volume(0)
                sound:stop()
                weapon_info[ent_type].shots = weapon_info[ent_type].shots - 1
            end
        end)
        weapon_info[ent_type].sound_callb_set = true
    end

    local update = ent_type == ENT_TYPE.ITEM_SHOTGUN and custom_gun2_shotgun_update or custom_gun2_update
    local custom_id, custom_type = _new_custom_entity(set_func, update, update_func, CARRY_TYPE.HELD, ent_type, update_type)
    custom_type.bulletfunc = bulletfunc
    custom_type.cooldown = cooldown
    custom_type.recoil_x = recoil_x
    custom_type.recoil_y = recoil_y
    custom_type.not_shot = true
    custom_type.mute_sound = mute_sound
    return custom_id
end

local function spawn_replacement(ent, custom_id)
    local is_held_by_player = ent.overlay ~= nil and ent.overlay.type.search_flags == MASK.PLAYER
    local x, y, l = get_position(ent.uid)
    local vx, vy = 0, 0
    if not is_held_by_player then
        vx, vy = get_velocity(ent.uid)
    end
    local replacement_uid = spawn(custom_types[custom_id].ent_type, x, y, l, vx, vy)
    local replacement = get_entity(replacement_uid)
    module.set_custom_entity(replacement_uid, custom_id)
    if is_held_by_player then
        ent.overlay:pick_up(replacement)
    end
    ent:destroy()
    return replacement
end

local back_warn_sound = get_sound(VANILLA_SOUND.ITEMS_BACKPACK_WARN)

local custom_purchasable_back_flammable_update = function(ent, c_data, c_type)
    if not test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) then
        spawn_replacement(ent, c_type.toreplace_custom_id)
        c_data = nil
    else
        local danger_entities = get_entities_overlapping_hitbox({ENT_TYPE.MONS_MAGMAMAN, ENT_TYPE.ITEM_BULLET}, MASK.ANY, get_hitbox(ent.uid), ent.layer)
        if danger_entities[1] or ent.onfire_effect_timer > 0 then
            back_warn_sound:play()
            if ent.last_owner_uid ~= -1 then
                if get_entity(ent.last_owner_uid).type.search_flags == MASK.PLAYER then
                    get_entity(c_data.shop_owner).aggro_trigger = true
                else
                    ---@type Movable
                    local shop_owner = get_entity(c_data.shop_owner)
                    if shop_owner.holding_uid ~= -1 then
                        get_entity(shop_owner.holding_uid):trigger_action(shop_owner)
                    else
                        local ent_type = get_entity_type(c_data.shop_owner)
                        if ent_type == ENT_TYPE.MONS_SHOPKEEPER or ent_type == ENT_TYPE.MONS_MERCHANT then
                            local weapon_type = ent_type == ENT_TYPE.MONS_SHOPKEEPER and ENT_TYPE.ITEM_SHOTGUN or ENT_TYPE.ITEM_CROSSBOW
                            local weapon_uid = spawn(weapon_type, 0, 0, LAYER.FRONT, 0, 0)
                            pick_up(shop_owner.uid, weapon_uid)
                            get_entity(weapon_uid):trigger_action(shop_owner)
                            shop_owner.is_patrolling = true
                        end
                    end
                end
            end
            spawn_replacement(ent, c_type.toreplace_custom_id).explosion_trigger = true
            c_data = nil
        end
        c_type.update_callback(ent, c_data)
    end
end

local function custom_purchasable_back_nonflammable_update(ent, c_data, c_type)
    if not test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) then
        spawn_replacement(ent, c_type.toreplace_custom_id)
        c_data = nil
    else
        c_type.update_callback(ent, c_data)
    end
end

---Create a new custom entity type, use this for backpacks that spawn in shops
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param toreplace_custom_id integer
---@param flammable boolean
---@return integer
function module.new_custom_purchasable_back(set_func, update_func, toreplace_custom_id, flammable, update_type)
    local custom_id, custom_type
    local update, set
    if flammable then
        set = function(ent, c_data, c_type_id, args)
            ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
            ent.hitboxx = 0.3
            ent.hitboxy = 0.35
            ent.offsety = -0.03
            set_timeout(function()
                custom_type.entities[ent.uid].shop_owner = ent.last_owner_uid
            end, 1)
            return set_func(ent, c_data, c_type_id, args)
        end
        update = custom_purchasable_back_flammable_update
    else
        set = function(ent, c_data, c_type_id, args)
            ent.hitboxx = 0.3
            ent.hitboxy = 0.35
            ent.offsety = -0.03
            return set_func(ent, c_data, c_type_id, args)
        end
        update = custom_purchasable_back_nonflammable_update
    end
    custom_id, custom_type = _new_custom_entity(set, update, update_func, nil, ENT_TYPE.ITEM_ROCK, update_type)
    custom_type.toreplace_custom_id = toreplace_custom_id
    return custom_id
end

local function set_nonflammable_backs_callbacks()
    set_pre_entity_spawn(function(_, x, y, layer, _, _)
        if y == -123 then
            return spawn_entity_nonreplaceable(ENT_TYPE.ITEM_ROCK, x, y, layer, 0, 0)
        end
    end, SPAWN_TYPE.SYSTEMIC, MASK.EXPLOSION, ENT_TYPE.FX_EXPLOSION)

    set_vanilla_sound_callback(VANILLA_SOUND.ITEMS_BACKPACK_WARN, VANILLA_SOUND_CALLBACK_TYPE.STARTED, function(sound)
        if just_burnt > 0 and last_burn == get_frame()-1 then
            sound:set_volume(0)
            sound:stop()
            just_burnt = just_burnt - 1
        end
    end)
    nonflammable_backs_callbacks_set = true
end

local yellow = Color:yellow()

local function custom_back_flammable_update(ent, c_data, c_type)
    local holder = ent.overlay
    if holder and holder.type.search_flags == MASK.PLAYER then
        local backitem_uid = holder:worn_backitem()
        if backitem_uid == ent.uid then
            ent.fuel = 0
            c_type.update_callback(ent, c_data, holder)
            local holding = get_entity(holder.holding_uid)
            if holding and holding.type.id == ENT_TYPE.ITEM_JETPACK and not c_type.entities[holding.uid] then
                holder:unequip_backitem()
                holder:pick_up(holding)
            end
        elseif not c_type.entities[backitem_uid] then
            holder:unequip_backitem()
            holder:pick_up(ent)
        else
            c_type.update_callback(ent, c_data)
        end
    else
        c_type.update_callback(ent, c_data)
    end
    update_custom_held_portal(ent, c_data)
end

local function custom_back_nonflammable_update(ent, c_data, c_type)
    local holder = ent.overlay
    if holder and holder.type.search_flags == MASK.PLAYER then
        local backitem_uid = holder:worn_backitem()
        if backitem_uid == ent.uid then
            ent.fuel = 0
            c_type.update_callback(ent, c_data, holder)

            local holding = get_entity(holder.holding_uid)
            if holding and holding.type.id == ENT_TYPE.ITEM_JETPACK and not c_type.entities[holding.uid] then
                holder:unequip_backitem()
                ent.flags = clr_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
                holder:pick_up(holding)
            end
        elseif not c_type.entities[backitem_uid] then
            holder:unequip_backitem()
            holder:pick_up(ent)
        else
            c_type.update_callback(ent, c_data)
        end
    else
        c_type.update_callback(ent, c_data)
        if test_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS) then
            ent.flags = clr_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
        end
    end
    if ent.explosion_trigger then
        ent.explosion_trigger = false
        ent.explosion_timer = 0
        just_burnt = just_burnt + 1
        last_burn = get_frame()
    end
    if test_flag(ent.flags, ENT_FLAG.DEAD) then
        move_entity(ent.uid, 0, -123, 0, 0)
    else
        update_custom_held_portal(ent, c_data)
    end
end

---Create a new custom entity type that is a backpack, using jetpack as base entity
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param flammable boolean @non-flammable backs might still generate the warning sound for a short time, might crash on OL but not on PL
---@return integer
function module.new_custom_backpack(set_func, update_func, flammable, update_type)
    local set, update
    if flammable then
        set = set_func
        update = custom_back_flammable_update
    else
        if not nonflammable_backs_callbacks_set then
            set_nonflammable_backs_callbacks()
        end
        set = function(ent, c_data, c_type_id, args)
            set_on_kill(ent.uid, function(entity)
                generate_world_particles(PARTICLEEMITTER.ITEM_CRUSHED_SPARKS, entity.uid)
                local x, y = get_position(entity.uid)
                create_illumination(yellow, 1.0, x, y).brightness = 2.0
                move_entity(entity.uid, 0, -123, 0, 0)
            end)
            ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
            return set_func(ent, c_data, c_type_id, args)
        end
        update = custom_back_nonflammable_update
    end
    local custom_id = _new_custom_entity(set, update, update_func, CARRY_TYPE.HELD, ENT_TYPE.ITEM_JETPACK, update_type)
    return custom_id
end

local player_items_draw = {{}, {}, {}, {}}
local item_height = 0.04 * (16.0/9.0)
local item_hud_color = Color:white()
item_hud_color.a = 0.4

local function set_item_draw_callbacks()
    if not item_draw_callbacks_set then
        set_callback(function(render_ctx)
            if not test_flag(state.pause, 1) and state.level_flags & (FLAGS_BIT[21] | FLAGS_BIT[22]) == 0 then --(state.screen == SCREEN.LEVEL or state.screen == SCREEN.CAMP) then --state.paused is probably flags, 1 is the pause menu
                for i, v in ipairs(player_items_draw) do
                    for i1, draw_info in ipairs(v) do
                        local y1, x1 = 0.74, -0.95+((i1-1)*0.04)+((i-1)*0.32)
                        --render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_HUD_1, 1, 0, x1, y1, x1 + 0.04, y1 - (0.04 * (16.0/9.0)), item_hud_color)
                        render_ctx:draw_screen_texture(draw_info.texture_id, draw_info.row, draw_info.column, x1, y1, x1 + 0.04, y1 - item_height, draw_info.color)
                    end
                end
            end
        end, ON.RENDER_POST_HUD)

        set_callback(function()
            local players_existing = 0
            for _, player in ipairs(players) do
                if test_flag(player.flags, ENT_FLAG.DEAD) and not entity_has_item_type(player.uid, ENT_TYPE.ITEM_POWERUP_ANKH) then
                    if player_items_draw[player.inventory.player_slot][1] then
                        player_items_draw[player.inventory.player_slot] = {}
                    end
                end
                players_existing = players_existing | FLAGS_BIT[player.inventory.player_slot]
            end
            for slot=1, state.items.player_count do
                if players_existing & FLAGS_BIT[slot] == 0 then
                    if player_items_draw[slot][1] then
                        player_items_draw[slot] = {}
                    end
                end
            end
        end, ON.GAMEFRAME)

        set_callback(function()
            player_items_draw = {{}, {}, {}, {}}
        end, ON.PRE_LEVEL_GENERATION)
        item_draw_callbacks_set = true
    end
end

---Manually create item draw info for displaying as powerup in HUD, probably not needed for a normal powerup
---@param texture_id integer
---@param row integer
---@param column integer
---@param color? userdata
---@return table
function module.new_item_draw_info(texture_id, row, column, color)
    color = color ~= nil and color or item_hud_color
    return {
        texture_id = texture_id,
        row = row,
        column = column,
        color = color
    }
end

---add an item to be drawn on a player HUD, is cleared ON.PRE_LEVEL_GENERATION
---@param player_num integer
---@param item_draw_info table @Created with new_item_draw_info
---@return integer @returns position of `player_items_draw[player_num]` where the item will be drawn
function module.add_player_item_draw(player_num, item_draw_info)
    set_item_draw_callbacks()
    local new_pos = #player_items_draw[player_num]+1
    player_items_draw[player_num][new_pos] = item_draw_info
    return new_pos
end

local function custom_powerup_update(ent, c_data, c_type, _, c_type_id)
    c_type.update_callback(ent, c_data)
    if test_flag(ent.flags, ENT_FLAG.DEAD) then
        if not entity_has_item_type(ent.uid, ENT_TYPE.ITEM_POWERUP_ANKH) then
            if state.items.player_count ~= 1 then
                local x, y, l = get_position(ent.uid)
                module.spawn_custom_entity(c_type.custom_pickup_id, x, y, l, prng:random_float(PRNG_CLASS.PARTICLES)*0.2-0.1, 0.1)
            end
        end
        c_type.entities[ent.uid] = nil
    else
        if state.theme == THEME.CITY_OF_GOLD and ent.idle_counter == 19 and ent.standing_on_uid ~= -1 and ent:standing_on().type.id == ENT_TYPE.FLOOR_ALTAR and ent:has_powerup(ENT_TYPE.ITEM_POWERUP_ANKH) and ent.stun_timer > 0 then
            custom_entities_t_info_cog_ankh[#custom_entities_t_info_cog_ankh+1] = {
                custom_type_id = c_type_id,
                data = c_data,
                slot = ent.inventory.player_slot
            }
            c_type.entities[ent.uid] = nil
        end
    end
end

---Create a new custom entity type that is a powerup, the functions will be called on the player
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param texture_id integer
---@param row integer
---@param column integer
---@param color? userdata
---@return integer
function module.new_custom_powerup(set_func, update_func, texture_id, row, column, color, update_type)
    local item_draw_info = module.new_item_draw_info(texture_id, row, column, color)

    local set = function(ent, c_data, c_type_id, args)
        module.add_player_item_draw(ent.inventory.player_slot, item_draw_info)
        return set_func(ent, c_data, c_type_id, args)
    end
    local custom_id, custom_type = _new_custom_entity(set, custom_powerup_update, update_func, CARRY_TYPE.POWERUP, nil, update_type)
    custom_type.item_draw_info = item_draw_info
    return custom_id
end

---Set what a powerup will drop when the player dies
---@param custom_powerup_id integer @id of the custom powerup
---@param custom_pickup_id integer @id of the custom pickup that will be droped
function module.set_powerup_drop(custom_powerup_id, custom_pickup_id)
    custom_types[custom_powerup_id].custom_pickup_id = custom_pickup_id
end

local function custom_pickup_update(ent, c_data, c_type)
    c_type.update_callback(ent, c_data)
    if not test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) and ent.stand_counter > 15 and state.screen ~= SCREEN.TRANSITION then
        for _, player in pairs(players) do
            local has_powerup = custom_types[c_type.custom_powerup_id].entities[player.uid]
            if player.health > 0 and (state.items.player_count == 1 or not has_powerup) and player:overlaps_with(ent) then
                c_type.pickup_callback(ent, player, c_data, has_powerup)
                if not has_powerup then
                    module.set_custom_entity(player.uid, c_type.custom_powerup_id)
                end
                ent:destroy()
                break
            end
        end
    end
    update_custom_held_portal(ent, c_data)
end

---Create a new custom entity type
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param pickup_func fun(ent: userdata, player: userdata, c_data: table, has_powerup: boolean) @called when a player picks up the pickup, use `do_pickup_effect` to generate the effect easily
---@param custom_powerup_id integer
---@param ent_type? integer
---@return integer
function module.new_custom_pickup(set_func, update_func, pickup_func, custom_powerup_id, ent_type, update_type)
    local set = function(ent, c_data, c_type_id, args)
        ent.more_flags = set_flag(ent.more_flags, 22)
        ent.flags = set_flag(ent.flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
        return set_func(ent, c_data, c_type_id, args)
    end
    local custom_id, custom_type = _new_custom_entity(set, custom_pickup_update, update_func, CARRY_TYPE.HELD, ent_type, update_type)
    custom_type.pickup_callback = pickup_func
    custom_type.custom_powerup_id = custom_powerup_id
    return custom_id
end

local get_item_sound = get_sound(VANILLA_SOUND.UI_GET_ITEM1)

---Generate pickup fx on player, set a texture and animation_frame
---@param player_uid integer
---@param texture_id integer
---@param animation_frame integer
---@return userdata @returns the `FX_PICKUPEFFECT` entity
function module.do_pickup_effect(player_uid, texture_id, animation_frame)
    local pickup_fx = get_entity(spawn_entity_over(ENT_TYPE.FX_PICKUPEFFECT, player_uid, 0, 0))
    if texture_id then
        pickup_fx:set_texture(texture_id)
    end
    pickup_fx.animation_frame = animation_frame
    get_item_sound:play()
    return pickup_fx
end

local function spawn_pickup_replacement(ent, c_data, toreplace_custom_id)
    local powerup_id = custom_types[toreplace_custom_id].custom_powerup_id
    local buyer
    if ent.overlay and ent.overlay.search_flags == MASK.PLAYER then
        buyer = ent.overlay
    else
        for _, player in ipairs(players) do
            if ent:overlaps_with(player) and player.standing_on_uid ~= -1 and player:is_button_pressed(BUTTON.DOOR) then
                buyer = player
                break
            end
        end
    end
    if buyer then
        local has_powerup = module.get_custom_entity(buyer.uid, powerup_id)
        if has_powerup and state.items.player_count ~= 1 then
            spawn_replacement(ent, toreplace_custom_id)
        else
            if not has_powerup then
                module.set_custom_entity(buyer.uid, powerup_id)
            end
            custom_types[toreplace_custom_id].pickup_callback(ent, buyer, c_data, has_powerup)
            ent:destroy()
        end
    else
        spawn_replacement(ent, toreplace_custom_id)
    end
end

local function custom_purchasable_pickup_update(ent, c_data, c_type)
    c_type.update_callback(ent, c_data)
    if not test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) then
        spawn_pickup_replacement(ent, c_data, c_type.toreplace_custom_id)
    end
end

---Create a new custom entity type
---@param set_func EntSet @Called when the entity is set manually, on transitions, and when cloned
---@param update_func EntUpdate @Called on `FRAME` or `GAMEFRAME`, depending on the init
---@param toreplace_custom_id integer @id of the custom entity that will replace this when bought / shopkeeper angry
---@return integer
function module.new_custom_purchasable_pickup(set_func, update_func, toreplace_custom_id, update_type)
    local set = function(ent, c_data, c_type_id, args)
        ent.more_flags = set_flag(ent.more_flags, 22)
        ent.flags = set_flag(ent.flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
        ent.width, ent.height = 1.25, 1.25
        ent.hitboxx, ent.hitboxy = 0.3, 0.38
        ent.offsety = -0.05
        return set_func(ent, c_data, c_type_id, args)
    end
    local custom_id, custom_type = _new_custom_entity(set, custom_purchasable_pickup_update, update_func, CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK, update_type)
    custom_type.toreplace_custom_id = toreplace_custom_id
    return custom_id
end

---Set an entity to be a custom one
---@param uid integer
---@param custom_type_id integer @id of the custom entity type
---@param optional_args any @any type of value that will be recived on the entity set function, use as table if you want to pass more arguments
function module.set_custom_entity(uid, custom_type_id, optional_args)
    local ent = get_entity(uid)
    _set_custom_entity(uid, ent, custom_type_id, nil, optional_args)
end

---Spawn a custom entity, make sure to have defined the ent_type on the custom ent type to use this
---@param custom_type_id integer @id of the custom entity type
---@param x integer
---@param y integer
---@param l integer
---@param vel_x number
---@param vel_y number
---@param optional_args any @any type of value that will be recived on the entity set function, use as table if you want to pass more arguments
function module.spawn_custom_entity(custom_type_id, x, y, l, vel_x, vel_y, optional_args)
    local uid = spawn(custom_types[custom_type_id].ent_type, x, y, l, vel_x, vel_y)
    local ent = get_entity(uid)
    _set_custom_entity(uid, ent, custom_type_id, nil, optional_args)
end

---Add a callback after the entity doesn't exist anymore
---@param custom_ent_id integer
---@param callback EntUpdate
function module.add_after_destroy_callback(custom_ent_id, callback)
    custom_types[custom_ent_id].after_destroy_callback = callback
end

---Get the data of a custom entity, returns nil if doesn't exist
---@param ent_uid integer
---@param custom_ent_id integer
---@return table?
function module.get_custom_entity(ent_uid, custom_ent_id)
    return custom_types[custom_ent_id].entities[ent_uid]
end

local function get_custom_item(custom_types_table, is_from_shop)
    if not custom_types_table[1] then
        return
    end
    local index = prng:random_index(#custom_types_table, PRNG_CLASS.EXTRA_SPAWNS)
    local custom_type_id = custom_types_table[index]
    if is_from_shop and custom_types[custom_type_id].max_one then
        custom_types_table[index] = custom_types_table[#custom_types_table]
        custom_types_table[#custom_types_table] = nil
    end
    return custom_type_id, custom_types[custom_type_id].ent_type
end

local function get_custom_item_from_chances(chances_table, is_from_shop)
    local chance = prng:random_float(PRNG_CLASS.EXTRA_SPAWNS)
    local custom_type_id, entity_type
    if chance < 0.3 then
        custom_type_id, entity_type = get_custom_item(chances_table.common, is_from_shop)
    elseif chance < 0.45 then
        custom_type_id, entity_type = get_custom_item(chances_table.low, is_from_shop)
    elseif chance < 0.5 then
        custom_type_id, entity_type = get_custom_item(chances_table.lower, is_from_shop)
    end
    return custom_type_id, entity_type
end

---Only for shops
local function spawn_custom_item_random(shop_chances, x, y, l)
    local custom_type_id, entity_type = get_custom_item_from_chances(shop_chances, true)
    if custom_type_id then
        local uid = spawn_entity_nonreplaceable(entity_type, x, y, l, 0, 0)
        module.set_custom_entity(uid, custom_type_id)
        return uid
    end
end

local function add_shop_chances_by_pos(shop_chances, rx, ry, l)
    if shops_by_room_pos[rx] then
        if shops_by_room_pos[rx][ry] then
            shops_by_room_pos[rx][ry][l] = shop_chances
        else
            shops_by_room_pos[rx][ry] = {[l] = shop_chances}
        end
    else
        shops_by_room_pos[rx] = {
            [ry] = {[l] = shop_chances}
        }
    end
end

local function spawn_custom_random_item_roomtype(roomtype, rx, ry, x, y, l)
    local shop_chances
    if has(normal_shop_rooms, roomtype) then
        shop_chances = clone_chances(l == LAYER.FRONT and custom_types_shop[state.level_gen.shop_type] or custom_types_shop[state.level_gen.backlayer_shop_type])
        add_shop_chances_by_pos(shop_chances, rx, ry, l)
    else
        return nil
    end
    return spawn_custom_item_random(shop_chances, x, y, l)
end

local function set_custom_shop_spawns()
    set_pre_entity_spawn(function(type, x, y, l, _)
        if (type == ENT_TYPE.ITEM_SHOTGUN or type == ENT_TYPE.ITEM_CROSSBOW) and y%1 > 0.04 and y%1 < 0.040001 then --when is a shotgun held by shopkeeper cause they're patrolling
            return
        end
        local rx, ry = get_room_index(x, y)
        if shops_by_room_pos[rx] and shops_by_room_pos[rx][ry] and shops_by_room_pos[rx][ry][l] then
            return spawn_custom_item_random(shops_by_room_pos[rx][ry][l], x, y, l)
        else
            local roomtype = get_room_template(rx, ry, l)
            return spawn_custom_random_item_roomtype(roomtype, rx, ry, x, y, l)
        end
    end, SPAWN_TYPE.LEVEL_GEN, MASK.ANY, all_shop_ents)
    set_pre_entity_spawn(function(_, x, y, l, _)
        local rx, ry = get_room_index(x, y)
        local roomtype = get_room_template(rx, ry, l)
        if x % 1 == 0 and get_entities_at(ENT_TYPE.ITEM_DICE_PRIZE_DISPENSER, MASK.ANY, x, y, LAYER.FRONT, 0.01)[1] then
            if roomtype == ROOM_TEMPLATE.DICESHOP or roomtype == ROOM_TEMPLATE.DICESHOP_LEFT then
                if shops_by_room_pos[rx] and shops_by_room_pos[rx][ry] and shops_by_room_pos[rx][ry][l] then
                    return spawn_custom_item_random(shops_by_room_pos[rx][ry][l], x, y, l)
                else
                    local shop_chances = clone_chances(custom_types_diceshop)
                    add_shop_chances_by_pos(shop_chances, rx, ry, l)
                    return spawn_custom_item_random(shop_chances, x, y, l)
                end
            elseif roomtype == ROOM_TEMPLATE.TUSKDICESHOP or roomtype == ROOM_TEMPLATE.TUSKDICESHOP_LEFT then
                if shops_by_room_pos[rx] and shops_by_room_pos[rx][ry] and shops_by_room_pos[rx][ry][l] then
                    return spawn_custom_item_random(shops_by_room_pos[rx][ry][l], x, y, l)
                else
                    local shop_chances = clone_chances(custom_types_tuskdiceshop)
                    add_shop_chances_by_pos(shop_chances, rx, ry, l)
                    return spawn_custom_item_random(custom_types_tuskdiceshop, x, y, l)
                end
            end
        end
    end, SPAWN_TYPE.SYSTEMIC, MASK.ANY, DICESHOP_ITEMS)
    custom_shop_items_set = true
end

local function _add_custom_shop_chance(custom_ent_id, chance_type, shop_type)
    if shop_type <= 13 then
        table.insert(custom_types_shop[shop_type][chance_type], custom_ent_id)
    elseif shop_type == SHOP_ROOM_TYPES.DICESHOP then
        table.insert(custom_types_diceshop[chance_type], custom_ent_id)
    elseif shop_type == SHOP_ROOM_TYPES.TUSKDICESHOP then
        table.insert(custom_types_tuskdiceshop[chance_type], custom_ent_id)
    end
end

---Add chance to be in a shop or shops, use `SHOP_TYPE` (that uses SHOP_TYPE and ROOM_TEMPLATE from the scripting api) and `CHANCE` from the library.
---Doesn't replace hhs or mounts, only items
---@param custom_ent_id integer
---@param chance_type any @Use CHANCE.*
---@param shop_types integer | integer[]
---@param max_one? boolean @Limit the entity to only spawn max one time per shop
function module.add_custom_shop_chance(custom_ent_id, chance_type, shop_types, max_one)
    if not custom_shop_items_set then
        set_custom_shop_spawns()
    end
    custom_types[custom_ent_id].max_one = max_one
    if type(shop_types) == "table" then
        for _, shop_type in ipairs(shop_types) do
            _add_custom_shop_chance(custom_ent_id, chance_type, shop_type)
        end
    else
        _add_custom_shop_chance(custom_ent_id, chance_type, shop_types)
    end
end

local toreplace_container_content = {
    custom_type_id = nil,
    entity_type = nil,
    random_velocity = nil
}

local function replace_inside_with_custom_entity(container, custom_type_id, entity_type, random_velocity)
    container.inside = ENT_TYPE.ITEM_TUTORIAL_MONSTER_SIGN
    toreplace_container_content.custom_type_id = custom_type_id
    toreplace_container_content.entity_type = entity_type
    toreplace_container_content.random_velocity = random_velocity
end

local function set_custom_container_item_spawns()
    set_pre_entity_spawn(function(_, x, y, layer, _, _) --this is immediately called after the kill or open, will work even when opening many crates at the same time
        if toreplace_container_content.custom_type_id then
            local vx, vy = 0, 0
            if toreplace_container_content.random_velocity then
                vx, vy = prng:random_float(PRNG_CLASS.EXTRA_SPAWNS)*0.2-0.1, 0.1
            end
            local uid = spawn(toreplace_container_content.entity_type, x, y, layer, vx, vy)
            module.set_custom_entity(uid, toreplace_container_content.custom_type_id)

            toreplace_container_content.custom_type_id = nil
            return uid
        end
    end, SPAWN_TYPE.SYSTEMIC, MASK.ANY, ENT_TYPE.ITEM_TUTORIAL_MONSTER_SIGN)
    custom_container_item_spawns_set = true
end

local function set_custom_container_spawns()
    local function customize_random_drop(container)
        local custom_type_id, entity_type = get_custom_item_from_chances(custom_types_container[container.type.id], false)
        if custom_type_id then
            replace_inside_with_custom_entity(container, custom_type_id, entity_type, true)
        end
    end

    set_post_entity_spawn(function(container)
        set_on_kill(container.uid, customize_random_drop)
        set_on_open(container.uid, customize_random_drop)
    end, SPAWN_TYPE.ANY, MASK.ANY, {ENT_TYPE.ITEM_CRATE, ENT_TYPE.ITEM_PRESENT, ENT_TYPE.ITEM_GHIST_PRESENT})
    if not custom_container_item_spawns_set then
        set_custom_container_item_spawns()
    end
    custom_container_items_set = true
end

---Add chance of a custom entity to be in a container
---@param custom_ent_id integer
---@param chance_type any @Use CHANCE.*
---@param container_types integer | integer[]
function module.add_custom_container_chance(custom_ent_id, chance_type, container_types)
    if not custom_container_items_set then
        set_custom_container_spawns()
    end
    if type(container_types) == "table" then
        for _, container_type in ipairs(container_types) do
            table.insert(custom_types_container[container_type][chance_type], custom_ent_id)
        end
    else
        table.insert(custom_types_container[container_types][chance_type], custom_ent_id)
    end
end

---Made for the set_callback, for some reason you need to wait one frame and get the entity again to make it work
---@param entity userdata
---@param base_price integer
---@param inflation integer
function module.set_price(entity, base_price, inflation)
    set_timeout(function()
        local _, y, l = get_position(entity.uid)
        if test_flag(state.presence_flags, 2) and y < 80 and l == LAYER.BACK then --if black market
            get_entity(entity.uid).price = base_price+inflation
        else
            get_entity(entity.uid).price = base_price+(state.level_count*inflation)
        end
    end, 1)
end

---@class CrustItemChance
---@field chance number
---@field ent_type integer
---@field custom_type_id integer

---@type CrustItemChance[]
local crust_item_chances = {}


local function set_custom_entity_in_alive_embedded_on_ice(container_uid, floor_uid, custom_type_id, ent_type)
    local function customize_drop()
        replace_inside_with_custom_entity(get_entity(container_uid), custom_type_id, ent_type, false)
    end
    set_on_kill(floor_uid, customize_drop)
end

local function spawn_entity_in_crust(ent_type, custom_type_id, floor_uid, texture_id, anim_frame)
    local uid = spawn_entity_over(ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE, floor_uid, 0, 0)
    set_custom_entity_in_alive_embedded_on_ice(uid, floor_uid, custom_type_id, ent_type)
    local ent = get_entity(uid)
    ent.inside = ENT_TYPE.FX_SHADOW
    ent:set_texture(texture_id)
    ent.animation_frame = anim_frame
    ent:set_draw_depth(9)
    if not test_flag(state.special_visibility_flags, 1) then
        ent.flags = set_flag(ent.flags, ENT_FLAG.INVISIBLE)
    end
end

local function filter_noitem_floors(floors)
    local new_floors = {}
    for _, v in ipairs(floors) do
        if not entity_get_items_by(v, {ENT_TYPE.EMBED_GOLD, ENT_TYPE.EMBED_GOLD_BIG}, MASK.DECORATION)[1]
        and not entity_get_items_by(v, 0, MASK.ITEM)[1] then
            table.insert(new_floors, v)
        end
    end
    return new_floors
end

local VALID_ITEM_FLOORS = {ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOOR_SURFACE, ENT_TYPE.FLOOR_JUNGLE, ENT_TYPE.FLOOR_TUNNEL_CURRENT, ENT_TYPE.FLOOR_TUNNEL_NEXT, ENT_TYPE.FLOOR_PEN, ENT_TYPE.FLOOR_TOMB, ENT_TYPE.FLOORSTYLED_BABYLON, ENT_TYPE.FLOORSTYLED_BEEHIVE, ENT_TYPE.FLOORSTYLED_COG, ENT_TYPE.FLOORSTYLED_DUAT, ENT_TYPE.FLOORSTYLED_GUTS, ENT_TYPE.FLOORSTYLED_MINEWOOD, ENT_TYPE.FLOORSTYLED_MOTHERSHIP, ENT_TYPE.FLOORSTYLED_PAGODA, ENT_TYPE.FLOORSTYLED_STONE, ENT_TYPE.FLOORSTYLED_SUNKEN, ENT_TYPE.FLOORSTYLED_TEMPLE, ENT_TYPE.FLOORSTYLED_VLAD}

local function spawn_item_on_random_floor(ent_type, custom_type_id)
    local floors = filter_noitem_floors(get_entities_by(VALID_ITEM_FLOORS, MASK.FLOOR, LAYER.BOTH))
    if floors[1] then
        local floor_uid = floors[prng:random_index(#floors, PRNG_CLASS.PROCEDURAL_SPAWNS)]
        local custom_type = custom_types[custom_type_id]
        spawn_entity_in_crust(ent_type, custom_type_id, floor_uid, custom_type.texture_id, custom_type.anim_frame)
    end
end

local function set_entity_crust_callbacks()
    set_callback(function()
        for _, crust_item_chance in ipairs(crust_item_chances) do
            if prng:random_float(PRNG_CLASS.PROCEDURAL_SPAWNS) <= crust_item_chance.chance then
                spawn_item_on_random_floor(crust_item_chance.ent_type, crust_item_chance.custom_type_id)
            end
        end
    end, ON.POST_LEVEL_GENERATION)
    if custom_container_item_spawns_set then
        set_custom_container_item_spawns()
    end
end

---Add chance for an item to be in crust, **must have used** `add_custom_entity_info` so it can use the correct texture
---@param custom_id any
---@param chance any
function module.add_custom_entity_crust_chance(custom_id, chance)
    if not entity_crust_callbacks_set then
        set_entity_crust_callbacks()
    end
    crust_item_chances[#crust_item_chances+1] = {
        chance = chance,
        ent_type = custom_types[custom_id].ent_type,
        custom_type_id = custom_id
    }
end

---set some entity info on the custom entity type, can be used with set_entity_info_from_custom_id() on the entity set function to use less lines of code.
---@param custom_id integer
---@param name string
---@param texture_id integer
---@param anim_frame integer
---@param price? integer
---@param price_inflation? integer
---@return nil
function module.add_custom_entity_info(custom_id, name, texture_id, anim_frame, price, price_inflation)
    local custom_type = custom_types[custom_id]
    custom_type.entity_name = name
    custom_type.texture_id = texture_id
    custom_type.anim_frame = anim_frame
    if price then
        custom_type.price = price
        custom_type.price_inflation = price_inflation
    end
end

---Set the entity info from custom entity id, sets texture, animation frame, name, and price (if it has a price)
---@param ent userdata
---@param custom_id integer
---@return nil
function module.set_entity_info_from_custom_id(ent, custom_id)
    local custom_type = custom_types[custom_id]
    add_custom_name(ent.uid, custom_type.entity_name)
    ent:set_texture(custom_type.texture_id)
    ent.animation_frame = custom_type.anim_frame
    if custom_type.price then
        module.set_price(ent, custom_type.price, custom_type.price_inflation)
    end
end

---define a custom tilecode for the entity and it's `pre_tile_code_callback`
---@param custom_id integer
---@param tilecode_name string
---@param spawn_to_floor boolean
---@return nil
function module.define_custom_entity_tilecode(custom_id, tilecode_name, spawn_to_floor)
    custom_types[custom_id].tilecode_name = tilecode_name
    define_tile_code(tilecode_name)
    local spawn_func
    if spawn_to_floor then
        spawn_func = spawn_on_floor
    else
        spawn_func = spawn_grid_entity
    end
    set_pre_tile_code_callback(function (x, y, layer)
        module.set_custom_entity(spawn_func(custom_types[custom_id].ent_type, x, y, layer), custom_id)
    end, tilecode_name)
end

function module.unset_custom_entity(uid, custom_id)
    if custom_types[custom_id].entities[uid] and custom_types[custom_id].entities[uid]._statemachine then
        clear_entity_callback(uid, custom_types[custom_id].entities[uid]._statemachine)
    end
    custom_types[custom_id].entities[uid] = nil
end

module.custom_types = custom_types --array of custom types
module.SHOP_TYPE = SHOP_ROOM_TYPES
module.CARRY_TYPE = {
    HELD = 1,
    MOUNT = 2,
    POWERUP = 4
}

exports = module
return module