local damsellib = require 'lib.entities.damsel'
local module = {}

---@enum CUSTOM_SHOP
local CUSTOM_SHOP = {
	NONE = -1,
	BOMBS = 100,
	TUTORIAL = 101,
}
module.CUSTOM_SHOP = CUSTOM_SHOP

---@type CUSTOM_SHOP
module.custom_shop = CUSTOM_SHOP.NONE
local custom_shop_bm = {
	type = CUSTOM_SHOP.NONE,
	rx = -1,
	ry = -1,
}

local RANDOM_BM_SHOPS = {
	SHOP_TYPE.GENERAL_STORE,
	SHOP_TYPE.SPECIALTY_SHOP,
	SHOP_TYPE.CLOTHING_SHOP,
	CUSTOM_SHOP.BOMBS,
	SHOP_TYPE.WEAPON_SHOP,
	SHOP_TYPE.PET_SHOP,
	SHOP_TYPE.HIRED_HAND_SHOP,
}

function module.set_blackmarket_shoprooms(room_gen_ctx)
	custom_shop_bm.rx, custom_shop_bm.ry, custom_shop_bm.type = -1, -1, CUSTOM_SHOP.NONE
	if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		---@type table<SHOP_TYPE|CUSTOM_SHOP, true>
		local spawned_random_shops = {}
		state.level_gen.shop_type = SHOP_TYPE.DICE_SHOP
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		unlockslib.UNLOCK_WI, unlockslib.UNLOCK_HI = 0, 0
		if unlockslib.LEVEL_UNLOCK ~= nil then
			unlockslib.UNLOCK_WI = prng:random_int(minw, maxw, PRNG_CLASS.LEVEL_GEN)
			unlockslib.UNLOCK_HI = prng:random_int(minh, unlockslib.UNLOCK_WI ~= maxw and maxh or maxh-1, PRNG_CLASS.LEVEL_GEN)
		end
		-- message("wi, hi: " .. unlockslib.UNLOCK_WI .. ", " .. unlockslib.UNLOCK_HI)
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					-- SORRY NOTHING
				elseif (hi == unlockslib.UNLOCK_HI and wi == unlockslib.UNLOCK_WI) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.HIRED_HAND_SHOP)
					spawned_random_shops[SHOP_TYPE.HIRED_HAND_SHOP] = true
				else
					local idx = prng:random_index(#RANDOM_BM_SHOPS, PRNG_CLASS.LEVEL_GEN) --[[@as SHOP_TYPE|CUSTOM_SHOP]]
					local shop_type = RANDOM_BM_SHOPS[idx]
					-- Prevent duplicated shops
					while spawned_random_shops[shop_type] or (unlockslib.LEVEL_UNLOCK ~= nil and shop_type == SHOP_TYPE.HIRED_HAND_SHOP) do
						idx = idx + 1
						if idx > #RANDOM_BM_SHOPS then idx = 1 end
						shop_type = RANDOM_BM_SHOPS[idx]
					end
					spawned_random_shops[shop_type] = true
					if shop_type == CUSTOM_SHOP.BOMBS then
						custom_shop_bm.rx, custom_shop_bm.ry = wi-1, hi-1
						custom_shop_bm.type = shop_type
						room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.GENERAL_STORE)
					else
						room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, shop_type)
					end
				end
			end
		end
		-- room_gen_ctx:set_shop_type(3, 2, LAYER.FRONT, SHOP_TYPE.HEDJET_SHOP)--unneeded
	end
end

-- black market shopkeepers
set_pre_tile_code_callback(function(x, y, layer)
    if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local ctx = PostRoomGenerationContext:new()
		local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
		local roomid = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
        ---@type Shopkeeper
        local s = get_entity(spawn_shopkeeper(x, y, layer, ROOM_TEMPLATE.SIDE))
		set_global_timeout(function()
			local c_ox, c_oy = -0.1, 0.89
			if not test_flag(s.flags, ENT_FLAG.FACING_LEFT) then
				flip_entity(s.uid)
			end
			if (
				roomid ~= roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
			) then
				local floor = get_entity(get_grid_entity_at(x, y-1, layer))
				if floor then
					local c = get_entity(spawn_entity_over(ENT_TYPE.DECORATION_SHOPFORE, floor.uid, c_ox, c_oy))
					c.animation_frame = 74
				end
			end
		end, 1)
		if (
			roomid == roomdeflib.HD_SUBCHUNKID.BLACKMARKET_ANKH
		) then
			local ankh_uid = spawn_grid_entity(ENT_TYPE.ITEM_PICKUP_ANKH, x-3, y, layer)
			add_item_to_shop(ankh_uid, s.uid)
			add_custom_name(ankh_uid, "Ankh")
			local ankh_mov = get_entity(ankh_uid)
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.SHOP_ITEM)
			ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
			spawn_entity_over(ENT_TYPE.FX_SALEICON, ankh_uid, 0, 0)
			spawn_entity_over(ENT_TYPE.FX_SALEDIALOG_CONTAINER, ankh_uid, 0, 0)
			ankh_mov.price = 50000
		end

		local rx, ry = get_room_index(x, y)
        ctx:set_room_template(rx, ry, layer, roomid == roomdeflib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT and ROOM_TEMPLATE.DICESHOP_LEFT or ROOM_TEMPLATE.SHOP)
        return true
    end
    return false
end, "shopkeeper")

-- Since setting the shop type for the black market level prevents shops from getting decorations, decorate them ourselves.
function module.add_shop_decorations()
    if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		local shelf_frames = {-1, -1, 28, 29, 38, 39}
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					-- SORRY NOTHING
				else
					-- shelf decorations
					local corner_x, corner_y = locatelib.locate_game_corner_position_from_levelrooms_position(wi, hi)
					local x, y = corner_x+2, corner_y-4
					local shelf_start, shelf_end = 0, 5
					for i = shelf_start, shelf_end, 1 do
						local shelf = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y, LAYER.FRONT, 0, 0))
						local shelf_f = 17
						if i == shelf_start then
							shelf_f = 16
						elseif i == shelf_end then
							shelf_f = 18
						end
						shelf.animation_frame = shelf_f
						shelf:set_draw_depth(44)

						local floor_above = get_entity(get_grid_entity_at(x+i, y+1, LAYER.FRONT))
						if not floor_above or (floor_above and floor_above.type.id == ENT_TYPE.ITEM_LAMP) then
							-- item on shelf
							local s_f = shelf_frames[prng:random_index(#shelf_frames, PRNG_CLASS.LEVEL_GEN)]
							if s_f ~= -1 then
								local s_d = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y+.55, LAYER.FRONT, 0, 0))
								s_d.animation_frame = s_f
								s_d:set_draw_depth(44)
							end
							-- spiderweb over shelf
							if prng:random_chance(3, PRNG_CLASS.LEVEL_GEN) then
								local s_d = get_entity(spawn_entity(ENT_TYPE.BG_SHOP, x+i, y+.55, LAYER.FRONT, 0, 0))
								s_d.animation_frame = 19
								s_d:set_draw_depth(44)
							end
						end
					end
				end
			end
		end
	end
end

function module.postlevelgen_fix_customshop_sign()
	local shopsigns = get_entities_by(ENT_TYPE.DECORATION_SHOPSIGNICON, MASK.DECORATION, LAYER.FRONT)
	for _, uid in pairs(shopsigns) do
		local x, y = get_position(uid)
		local rx, ry = get_room_index(x, y)
		if (
			module.custom_shop == CUSTOM_SHOP.BOMBS
			or (
				custom_shop_bm.rx == rx
				and custom_shop_bm.ry == ry
				and custom_shop_bm.type == CUSTOM_SHOP.BOMBS
			)
		) then
			get_entity(uid).animation_frame = 99
		end
	end
end

local SHOP_ENTS = {ENT_TYPE.ITEM_PICKUP_ROPEPILE, ENT_TYPE.ITEM_PICKUP_BOMBBAG, ENT_TYPE.ITEM_PICKUP_BOMBBOX, ENT_TYPE.ITEM_PICKUP_PARACHUTE, ENT_TYPE.ITEM_PICKUP_SPECTACLES, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY, ENT_TYPE.ITEM_PICKUP_COMPASS, ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, ENT_TYPE.ITEM_PICKUP_SPIKESHOES, ENT_TYPE.ITEM_PICKUP_PASTE, ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, ENT_TYPE.ITEM_WEBGUN, ENT_TYPE.ITEM_MACHETE, ENT_TYPE.ITEM_BOOMERANG, ENT_TYPE.ITEM_CAMERA, ENT_TYPE.ITEM_MATTOCK, ENT_TYPE.ITEM_TELEPORTER, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_METAL_SHIELD, ENT_TYPE.ITEM_PURCHASABLE_CAPE, ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK, ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK, ENT_TYPE.ITEM_PURCHASABLE_POWERPACK, ENT_TYPE.ITEM_PURCHASABLE_JETPACK, ENT_TYPE.ITEM_PRESENT, ENT_TYPE.ITEM_SHOTGUN, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_CROSSBOW}
local NORMAL_SHOP_ROOMS = {ROOM_TEMPLATE.SHOP, ROOM_TEMPLATE.SHOP_LEFT, ROOM_TEMPLATE.SHOP_ENTRANCE_UP, ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT, ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN, ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT}
local DICESHOP_ITEMS = {ENT_TYPE.ITEM_PICKUP_BOMBBAG, ENT_TYPE.ITEM_PICKUP_BOMBBOX, ENT_TYPE.ITEM_PICKUP_ROPEPILE, ENT_TYPE.ITEM_PICKUP_COMPASS, ENT_TYPE.ITEM_PICKUP_PASTE, ENT_TYPE.ITEM_PICKUP_PARACHUTE, ENT_TYPE.ITEM_PURCHASABLE_CAPE, ENT_TYPE.ITEM_PICKUP_SPECTACLES, ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, ENT_TYPE.ITEM_PICKUP_SPIKESHOES, ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, ENT_TYPE.ITEM_MACHETE, ENT_TYPE.ITEM_BOOMERANG, ENT_TYPE.ITEM_CROSSBOW, ENT_TYPE.ITEM_SHOTGUN, ENT_TYPE.ITEM_FREEZERAY, ENT_TYPE.ITEM_WEBGUN, ENT_TYPE.ITEM_CAMERA, ENT_TYPE.ITEM_MATTOCK, ENT_TYPE.ITEM_PURCHASABLE_JETPACK, ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK, ENT_TYPE.ITEM_TELEPORTER, ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK, ENT_TYPE.ITEM_PURCHASABLE_POWERPACK}

local repeatable_shop_items = {
	ENT_TYPE.ITEM_PICKUP_BOMBBAG,
	ENT_TYPE.ITEM_PICKUP_BOMBBOX,
	ENT_TYPE.ITEM_PICKUP_ROPEPILE,
}

local shop_item_pools = {
	[SHOP_TYPE.GENERAL_STORE] = {
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_PICKUP_BOMBBOX,
		ENT_TYPE.ITEM_PICKUP_ROPEPILE,
		ENT_TYPE.ITEM_PICKUP_PARACHUTE,
		ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
		ENT_TYPE.ITEM_PICKUP_COMPASS,
	},
	[SHOP_TYPE.SPECIALTY_SHOP] = {
		ENT_TYPE.ITEM_PICKUP_BOMBBOX,
		ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
		ENT_TYPE.ITEM_PICKUP_COMPASS,
		ENT_TYPE.ITEM_PURCHASABLE_JETPACK,
		ENT_TYPE.ITEM_MATTOCK,
		ENT_TYPE.ITEM_WEBGUN,
		ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
		ENT_TYPE.ITEM_TELEPORTER,
		ENT_TYPE.ITEM_CAMERA,
		ENT_TYPE.ITEM_FREEZERAY,
	},
	[SHOP_TYPE.CLOTHING_SHOP] = {
		ENT_TYPE.ITEM_PICKUP_ROPEPILE,
		ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
		ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
		ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
		ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
		ENT_TYPE.ITEM_PURCHASABLE_CAPE,
		ENT_TYPE.ITEM_PICKUP_SPECTACLES,
	},
	[CUSTOM_SHOP.BOMBS] = {
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_PICKUP_BOMBBOX,
		ENT_TYPE.ITEM_PICKUP_PASTE,
	},
	[SHOP_TYPE.WEAPON_SHOP] = {
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_WEBGUN,
		ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
		ENT_TYPE.ITEM_MACHETE,
		ENT_TYPE.ITEM_SHOTGUN,
		ENT_TYPE.ITEM_BOOMERANG,
		ENT_TYPE.ITEM_FREEZERAY,
	},
	[SHOP_TYPE.DICE_SHOP] = {
		ENT_TYPE.ITEM_PICKUP_ROPEPILE,
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_PICKUP_BOMBBOX,
		ENT_TYPE.ITEM_PICKUP_SPECTACLES,
		ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
		ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
		ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
		ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
		ENT_TYPE.ITEM_PICKUP_PASTE,
		ENT_TYPE.ITEM_PICKUP_COMPASS,
		ENT_TYPE.ITEM_MATTOCK,
		ENT_TYPE.ITEM_BOOMERANG,
		ENT_TYPE.ITEM_MACHETE,
		ENT_TYPE.ITEM_WEBGUN,
		ENT_TYPE.ITEM_SHOTGUN,
		ENT_TYPE.ITEM_FREEZERAY,
		ENT_TYPE.ITEM_CAMERA,
		ENT_TYPE.ITEM_TELEPORTER,
		ENT_TYPE.ITEM_PICKUP_PARACHUTE,
		ENT_TYPE.ITEM_PURCHASABLE_CAPE,
		ENT_TYPE.ITEM_PURCHASABLE_JETPACK,
	},
	[CUSTOM_SHOP.TUTORIAL] = {
		ENT_TYPE.ITEM_PICKUP_BOMBBAG,
		ENT_TYPE.ITEM_PICKUP_ROPEPILE,
	},
}

local function get_custom_shop(roomx, roomy)
	if module.custom_shop ~= CUSTOM_SHOP.NONE then
		return module.custom_shop
	end
	return (custom_shop_bm.rx == roomx and custom_shop_bm.ry == roomy) and custom_shop_bm.type or CUSTOM_SHOP.NONE
end

--- Access as `spawned_by_roompos[room_y][room_x]`
local spawned_by_roompos = {}

local function get_random_shop_item(item_pool, spawned_items)
	if not commonlib.has(spawned_items, ENT_TYPE.ITEM_PRESENT) and prng:random_chance(20, PRNG_CLASS.LEVEL_GEN) then
		return ENT_TYPE.ITEM_PRESENT
	end
	local tospawn_idx = prng:random_index(#item_pool, PRNG_CLASS.LEVEL_GEN)
	local tospawn = item_pool[tospawn_idx]
	-- Made this way to imitate HD behavior
	while not commonlib.has(repeatable_shop_items, tospawn) and commonlib.has(spawned_items, tospawn) do
		tospawn_idx = tospawn_idx + 1
		if tospawn_idx > #item_pool then tospawn_idx = 1 end
		tospawn = item_pool[tospawn_idx]
	end
	return tospawn
end

set_pre_entity_spawn(function (entity_type, x, y, layer, _, spawn_flags)
	if (entity_type == ENT_TYPE.ITEM_SHOTGUN or entity_type == ENT_TYPE.ITEM_CROSSBOW) and y%1 > 0.04 and y%1 < 0.040001 then --when is a shotgun held by shopkeeper cause they're patrolling
		return
	end
	local rx, ry = get_room_index(x, y)
	local roomtype = get_room_template(rx, ry, layer)
	if commonlib.has(NORMAL_SHOP_ROOMS, roomtype) then
		if not spawned_by_roompos[ry] then
			spawned_by_roompos[ry] = {[rx] = {}}
		elseif not spawned_by_roompos[ry][rx] then
			spawned_by_roompos[ry][rx] = {}
		end
	else
		return
	end
	local custom_shop = get_custom_shop(rx, ry)
	local shop_type = custom_shop == -1 and state.level_gen.shop_type or custom_shop
	-- messpect(module.custom_shop, state.level_gen.shop_type, shop_type)
	local spawned_items = spawned_by_roompos[ry][rx]
	local item_pool = shop_item_pools[shop_type]
	if not item_pool then message("Warning: No item pool found") return end

	local tospawn = get_random_shop_item(item_pool, spawned_items)
	spawned_items[#spawned_items+1] = tospawn
	-- messpect(enum_get_name(ENT_TYPE, entity_type), enum_get_name(ENT_TYPE, tospawn), x, y, layer, enum_get_mask_names(SPAWN_TYPE, spawn_flags), enum_get_name(ROOM_TEMPLATE, roomtype))
	-- messpect(item_pool, spawned_items)
	return spawn_entity_nonreplaceable(tospawn, x, y, layer, 0, 0)
end, SPAWN_TYPE.LEVEL_GEN, MASK.ITEM, SHOP_ENTS)

set_pre_entity_spawn(function (entity_type, x, y, layer, _, spawn_flags)
	if x % 1 ~= 0 or not get_entities_at(ENT_TYPE.ITEM_DICE_PRIZE_DISPENSER, MASK.ITEM, x, y, LAYER.FRONT, 0.01)[1] then
		return
	end
	local rx, ry = get_room_index(x, y)
	local roomtype = get_room_template(rx, ry, layer)
	if roomtype == ROOM_TEMPLATE.DICESHOP or roomtype == ROOM_TEMPLATE.DICESHOP_LEFT then
		if not spawned_by_roompos[ry] then
			spawned_by_roompos[ry] = {[rx] = {}}
		elseif not spawned_by_roompos[ry][rx] then
			spawned_by_roompos[ry][rx] = {}
		end
	else
		return
	end

	local spawned_items = spawned_by_roompos[ry][rx]
	local item_pool = shop_item_pools[SHOP_TYPE.DICE_SHOP]

	local tospawn = get_random_shop_item(item_pool, spawned_items)
	spawned_items[#spawned_items+1] = tospawn
	-- messpect(enum_get_name(ENT_TYPE, entity_type), enum_get_name(ENT_TYPE, tospawn), x, y, layer, enum_get_mask_names(SPAWN_TYPE, spawn_flags))
	-- messpect(item_pool, spawned_items)
	return spawn_entity_nonreplaceable(tospawn, x, y, layer, 0, 0)
end, SPAWN_TYPE.SYSTEMIC, MASK.ITEM, DICESHOP_ITEMS)

---@param uids integer | integer[] 
---@param rx integer
---@param ry integer
---@param layer integer
local function add_to_shop(uids, rx, ry, layer)
	set_callback(function()
		local left, top = get_room_pos(rx, ry)
		local right, bottom = left + CONST.ROOM_WIDTH, top - CONST.ROOM_HEIGHT
		local shopkeeper = get_entities_overlapping_hitbox(ENT_TYPE.MONS_SHOPKEEPER, MASK.MONSTER, AABB:new(left, top, right, bottom), layer)[1]
		if shopkeeper then
			if type(uids) == "table" then
				for _, uid in pairs(uids) do
					add_item_to_shop(uid, shopkeeper)
				end
			else
				add_item_to_shop(uids, shopkeeper)
			end
		else
			message("Warning: No shop owner found")
		end
		clear_callback()
	end, ON.POST_LEVEL_GENERATION)
end

local function flip_by_shop_dir(uid, roomtype)
	if roomtype == ROOM_TEMPLATE.SHOP_LEFT or feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		set_entity_flags(uid, set_flag(get_entity_flags(uid), ENT_FLAG.FACING_LEFT))
	else
		set_entity_flags(uid, clr_flag(get_entity_flags(uid), ENT_FLAG.FACING_LEFT))
	end
end

---@param x integer
---@param y integer
---@param layer integer
---@return integer
local function spawn_shop_char(x, y, layer, room_template)
	local rx, ry = get_room_index(x, y)
	local uid
	if (
		unlockslib.LEVEL_UNLOCK ~= nil
		and (
			(unlockslib.UNLOCK_WI ~= nil and unlockslib.UNLOCK_WI == rx+1)
			and (unlockslib.UNLOCK_HI ~= nil and unlockslib.UNLOCK_HI == ry+1)
		)
	) then
		uid = spawn_companion(193 + unlockslib.HD_UNLOCKS[unlockslib.LEVEL_UNLOCK].unlock_id, x, y, layer)
		set_post_statemachine(uid, function(ent)
			if test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) == false then
				clear_callback()
				local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, 1000, 0, LAYER.FRONT, 0, 0)
				set_contents(coffin_uid, 193 + unlockslib.HD_UNLOCKS[unlockslib.LEVEL_UNLOCK].unlock_id)
				kill_entity(coffin_uid)
				cancel_speechbubble()
			end
		end)
		unlockslib.UNLOCK_HI, unlockslib.UNLOCK_WI = -1, -1
	else
		uid = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x, y, layer)
	end
	flip_by_shop_dir(uid, room_template)
	return uid
end

set_pre_tile_code_callback(function (x, y, layer, room_template)
	local rx, ry = get_room_index(x, y)
	local offs_dir = room_template == ROOM_TEMPLATE.SHOP and 1 or -1
	if commonlib.has(NORMAL_SHOP_ROOMS, room_template) then
		-- TODO: Black market unlock char
		if state.level_gen.shop_type == SHOP_TYPE.HIRED_HAND_SHOP then
			local uids = {}
			if prng:random_chance(100, PRNG_CLASS.LEVEL_GEN) then
				for i = 1, 3 do
					uids[i] = spawn_shop_char(x + (i * offs_dir), y, layer, room_template)
				end
			elseif prng:random_chance(20, PRNG_CLASS.LEVEL_GEN) then
				uids[1] = spawn_shop_char(x + (1 * offs_dir), y, layer, room_template)
				uids[2] = spawn_shop_char(x + (3 * offs_dir), y, layer, room_template)
			else
				uids[1] = spawn_shop_char(x + (2 * offs_dir), y, layer, room_template)
			end
			add_to_shop(uids, rx, ry, layer)
			return true
		elseif state.level_gen.shop_type == SHOP_TYPE.PET_SHOP then
			damsellib.set_curr_type()
			local pet_type = damsellib.get_curr_type()
			local uid = spawn_entity_snapped_to_floor(pet_type, x + (2 * offs_dir), y, layer)
			flip_by_shop_dir(uid, room_template)
			add_to_shop(uid, rx, ry, layer)
			return true
		end
	end
end, "shop_item")

return module