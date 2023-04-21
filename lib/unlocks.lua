local module = {}

module.HD_UNLOCK_ID = {
    STARTER1 = 1,
    STARTER2 = 2,
    STARTER3 = 3,
    STARTER4 = 4,
    AREA_RAND1 = 5,
    AREA_RAND2 = 6,
    AREA_RAND3 = 7,
    AREA_RAND4 = 8,
    OLMEC_WIN = 9,
    WORM = 10,
    SPIDERLAIR = 11,
    YETIKINGDOM = 12,
    HAUNTEDCASTLE = 13,
    YAMA = 14,
    OLMEC_CHAMBER = 15,
    TIKIVILLAGE = 16,
    BLACKMARKET = 17,
    RUSHING_WATER = 18,
    MOTHERSHIP = 19,
    COG = 20
}

module.HD_UNLOCKS = {
    [module.HD_UNLOCK_ID.STARTER1] = { unlock_id = 19, unlocked = false },			--ENT_TYPE.CHAR_GUY_SPELUNKY
    [module.HD_UNLOCK_ID.STARTER2] = { unlock_id = 03, unlocked = false },			--ENT_TYPE.CHAR_COLIN_NORTHWARD
    [module.HD_UNLOCK_ID.STARTER3] = { unlock_id = 05, unlocked = false },			--ENT_TYPE.CHAR_BANDA
    [module.HD_UNLOCK_ID.STARTER4] = { unlock_id = 06, unlocked = false },			--ENT_TYPE.CHAR_GREEN_GIRL
    [module.HD_UNLOCK_ID.AREA_RAND1] = { unlock_id = 12, unlocked = false },		--ENT_TYPE.CHAR_TINA_FLAN
    [module.HD_UNLOCK_ID.AREA_RAND2] = { unlock_id = 01, unlocked = false },		--ENT_TYPE.CHAR_ANA_SPELUNKY
    [module.HD_UNLOCK_ID.AREA_RAND3] = { unlock_id = 02, unlocked = false },		--ENT_TYPE.CHAR_MARGARET_TUNNEL
    [module.HD_UNLOCK_ID.AREA_RAND4] = { unlock_id = 09, unlocked = false },		--ENT_TYPE.CHAR_COCO_VON_DIAMONDS
    [module.HD_UNLOCK_ID.OLMEC_WIN] = {
        unlock_id = 07,													--ENT_TYPE.CHAR_AMAZON
        unlocked = false
    },
    [module.HD_UNLOCK_ID.WORM] = {
        unlock_theme = THEME.EGGPLANT_WORLD,
        unlock_id = 16,													--ENT_TYPE.CHAR_PILOT
        unlocked = false
    },
    [module.HD_UNLOCK_ID.SPIDERLAIR] = {
        feeling = feelingslib.FEELING_ID.SPIDERLAIR,
        unlock_id = 13, unlocked = false },								--ENT_TYPE.CHAR_VALERIE_CRUMP
    [module.HD_UNLOCK_ID.YETIKINGDOM] = {
        feeling = feelingslib.FEELING_ID.YETIKINGDOM,
        unlock_id = 15, unlocked = false },								--ENT_TYPE.CHAR_DEMI_VON_DIAMONDS
    [module.HD_UNLOCK_ID.HAUNTEDCASTLE] = {
        feeling = feelingslib.FEELING_ID.HAUNTEDCASTLE,
        unlock_id = 17, unlocked = false },								--ENT_TYPE.CHAR_PRINCESS_AIRYN
    [module.HD_UNLOCK_ID.YAMA] = {
        unlock_id = 20,													--ENT_TYPE.CHAR_CLASSIC_GUY
        unlocked = false
    },
    [module.HD_UNLOCK_ID.OLMEC_CHAMBER] = {
        unlock_theme = THEME.OLMEC,
        unlock_id = 18, unlocked = false },								--ENT_TYPE.CHAR_DIRK_YAMAOKA
    [module.HD_UNLOCK_ID.TIKIVILLAGE] = {
        feeling = feelingslib.FEELING_ID.TIKIVILLAGE,
        unlock_id = 11, unlocked = false },								--ENT_TYPE.CHAR_OTAKU
    [module.HD_UNLOCK_ID.BLACKMARKET] = {
        feeling = feelingslib.FEELING_ID.BLACKMARKET,
        unlock_id = 04, unlocked = false },								--ENT_TYPE.CHAR_ROFFY_D_SLOTH
    [module.HD_UNLOCK_ID.RUSHING_WATER] = {
        feeling = feelingslib.FEELING_ID.RUSHING_WATER,
        unlock_id = 10, unlocked = false },								--ENT_TYPE.CHAR_MANFRED_TUNNEL
    [module.HD_UNLOCK_ID.MOTHERSHIP] = {
        unlock_theme = THEME.NEO_BABYLON,
        unlock_id = 08, unlocked = false },								--ENT_TYPE.CHAR_LISE_SYSTEM
    [module.HD_UNLOCK_ID.COG] = {
        unlock_theme = THEME.CITY_OF_GOLD,
        unlock_id = 14, unlocked = false },								--ENT_TYPE.CHAR_AU
}

module.RUN_UNLOCK_AREA = {} -- used to be `module.RUN_UNLOCK_AREA[THEME.DWELLING] = false` but that doesn't save into json well...
module.RUN_UNLOCK_AREA[#module.RUN_UNLOCK_AREA+1] = { theme = THEME.DWELLING, unlocked = false }
module.RUN_UNLOCK_AREA[#module.RUN_UNLOCK_AREA+1] = { theme = THEME.JUNGLE, unlocked = false }
module.RUN_UNLOCK_AREA[#module.RUN_UNLOCK_AREA+1] = { theme = THEME.ICE_CAVES, unlocked = false }
module.RUN_UNLOCK_AREA[#module.RUN_UNLOCK_AREA+1] = { theme = THEME.TEMPLE, unlocked = false }


module.LEVEL_UNLOCK = nil
module.UNLOCK_WI, module.UNLOCK_HI = nil, nil
module.CHARACTER_UNLOCK_SPAWNED_DURING_RUN = false

function module.init()
	module.LEVEL_UNLOCK = nil
	module.UNLOCK_WI, module.UNLOCK_HI = nil, nil
end

-- # TODO: When placing an AREA_RAND* character coffin in the level, set an ON.FRAME check for unlocking it; if check passes, set RUN_UNLOCK_AREA[state.theme] = true
savelib.register_save_callback(function(save_data)
	save_data.character_unlock_areas = module.RUN_UNLOCK_AREA
end)

-- Load bools of the areas you've unlocked AREA_RAND* characters in
savelib.register_load_callback(function(load_data)
	if load_data.format == nil and #load_data == 4 then
		-- Handle the old format where the entire save file is the character unlock areas.
		module.RUN_UNLOCK_AREA = load_data
	elseif load_data.character_unlock_areas then
		module.RUN_UNLOCK_AREA = load_data.character_unlock_areas
	end
end)

set_callback(function()
	module.unlocks_load()
end, ON.LOGO)


function module.unlocks_load()
	for id, unlock_properties in pairs(module.HD_UNLOCKS) do
		module.HD_UNLOCKS[id].unlocked = test_flag(savegame.characters, unlock_properties.unlock_id)
	end
	-- RUN_UNLOCK_AREA gets loaded in an ON.LOAD callback
end

--[[
	Detect if an area unlock has not been unlocked yet.
	Where can AREA unlocks spawn?
	- When it's in one of the four areas.
	- Any exceptions to this, such as special areas? Not that I'm aware of.
]]
local function detect_if_area_unlock_not_unlocked_yet()
	-- module.RUN_UNLOCK_AREA[state.theme] ~= nil and module.RUN_UNLOCK_AREA[state.theme] == false
	for i = 1, #module.RUN_UNLOCK_AREA, 1 do
		if module.RUN_UNLOCK_AREA[i].theme == state.theme and module.RUN_UNLOCK_AREA[i].unlocked == false then
			return true
		end
	end
	return false
end


--[[
	Run the chance for an area coffin to spawn.
	1 / (X - deaths), chance can't go better than 1/9
]]
local function run_unlock_area_chance()
	if (
		state.world < 5
	) then
		local area_and_deaths = 301 - savegame.deaths
		if state.world == 1 then
			area_and_deaths = 51 - savegame.deaths
		elseif state.world == 2 then
			area_and_deaths = 101 - savegame.deaths
		elseif state.world == 3 then
			area_and_deaths = 201 - savegame.deaths
		end

		local chance = (area_and_deaths < 9) and 9 or area_and_deaths

		if math.random(chance) == 1 then
			return true
		end
	end
	return false
end

-- Set module.LEVEL_UNLOCK
function module.get_unlock()
	local unlock = nil
	if (
		module.CHARACTER_UNLOCK_SPAWNED_DURING_RUN == false
		and state.items.player_count == 1
	) then
		if (
			detect_if_area_unlock_not_unlocked_yet()
			and run_unlock_area_chance()
		) then -- AREA_RAND* unlocks
			local rand_pool = {
				module.HD_UNLOCK_ID.AREA_RAND1,
				module.HD_UNLOCK_ID.AREA_RAND2,
				module.HD_UNLOCK_ID.AREA_RAND3,
				module.HD_UNLOCK_ID.AREA_RAND4
			}
			local coffin_rand_pool = {}
			local chunkPool_rand_index = 1
			local n = #rand_pool
			for rand_index = 1, #rand_pool, 1 do
				if module.HD_UNLOCKS[rand_pool[rand_index]].unlocked == true then
					rand_pool[rand_index] = nil
				end
			end
			rand_pool = commonlib.CompactList(rand_pool, n)
			if #rand_pool > 0 then
				chunkPool_rand_index = math.random(1, #rand_pool)
				unlock = rand_pool[chunkPool_rand_index]
			else
				-- # TODO: It's possible for there to be no area characters left to unlock if RUN_UNLOCK_AREA gets out of sync with the savegame data, which can happen if save.dat is deleted without also resetting character unlocks. This check is a failsafe to prevent this scenario from throwing an error. Is there a way to avoid this scenario entirely?
				print("Warning: Attempted to spawn area unlock coffin with no valid characters left to unlock.")
			end
		else -- feeling/theme-based unlocks
			local unlockconditions_feeling = {}
			local unlockconditions_theme = {}
			for id, unlock_properties in pairs(module.HD_UNLOCKS) do
				if unlock_properties.feeling ~= nil then
					unlockconditions_feeling[id] = unlock_properties
				elseif unlock_properties.unlock_theme ~= nil then
					unlockconditions_theme[id] = unlock_properties
				end
			end
			
			for id, unlock_properties in pairs(unlockconditions_theme) do
				if (
					unlock_properties.unlock_theme == state.theme
					and unlock_properties.unlocked == false
				) then
					unlock = id
				end
			end
			for id, unlock_properties in pairs(unlockconditions_feeling) do
				if (
					feelingslib.feeling_check(unlock_properties.feeling) == true
					and unlock_properties.unlocked == false
				) then
					-- Probably won't be overridden by theme
					unlock = id
				end
			end
		end
	end
	module.LEVEL_UNLOCK = unlock
	if module.LEVEL_UNLOCK ~= nil then
		module.CHARACTER_UNLOCK_SPAWNED_DURING_RUN = true
	end
end

-- black market unlock
set_pre_entity_spawn(function(type, x, y, l, _)
	local rx, ry = get_room_index(x, y)
	if (
		module.LEVEL_UNLOCK ~= nil
		and (
			(module.UNLOCK_WI ~= nil and module.UNLOCK_WI == rx+1)
			and (module.UNLOCK_HI ~= nil and module.UNLOCK_HI == ry+1)
		)
	) then
		local uid = spawn_grid_entity(193 + module.HD_UNLOCKS[module.LEVEL_UNLOCK].unlock_id, x, y, l)
		set_post_statemachine(uid, function(ent)
			if test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) == false then
				local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, 1000, 0, LAYER.FRONT, 0, 0)
				set_contents(coffin_uid, 193 + module.HD_UNLOCKS[module.LEVEL_UNLOCK].unlock_id)
				kill_entity(coffin_uid)
				cancel_speechbubble()
				clear_callback()
			end
		end)
		return uid
	end
	-- return spawn_grid_entity(ENT_TYPE.CHAR_HIREDHAND, x, y, l)
end, SPAWN_TYPE.LEVEL_GEN, 0, ENT_TYPE.CHAR_HIREDHAND)

set_callback(function()
	module.CHARACTER_UNLOCK_SPAWNED_DURING_RUN = false
end, ON.START)

return module