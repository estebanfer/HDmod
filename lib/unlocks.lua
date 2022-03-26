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


-- # TODO: When placing an AREA_RAND* character coffin in the level, set an ON.FRAME check for unlocking it; if check passes, set RUN_UNLOCK_AREA[state.theme] = true
set_callback(function(save_ctx)
	local save_areaUnlocks_str = json.encode(module.RUN_UNLOCK_AREA)
	save_ctx:save(save_areaUnlocks_str)
end, ON.SAVE)

-- Load bools of the areas you've unlocked AREA_RAND* characters in
set_callback(function(load_ctx)
	local load_areaUnlocks_str = load_ctx:load()
	if load_areaUnlocks_str ~= "" then
		module.RUN_UNLOCK_AREA = json.decode(load_areaUnlocks_str)
	end
end, ON.LOAD)

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
function module.detect_if_area_unlock_not_unlocked_yet()
	-- module.RUN_UNLOCK_AREA[state.theme] ~= nil and module.RUN_UNLOCK_AREA[state.theme] == false
	for i = 1, #module.RUN_UNLOCK_AREA, 1 do
		if module.RUN_UNLOCK_AREA[i].theme == state.theme and module.RUN_UNLOCK_AREA[i].unlocked == false then
			return true
		end
	end
	return false
end

return module