local module = {}

-- Subchunkid terminology
	-- 00 -- side				-- Empty/unassigned
	-- 01 -- path				-- Standard room (horizontal exit)
	-- 02 -- path_drop			-- Path to exit (vertical exit)
	-- 03 -- path_notop			-- Path to exit (horizontal exit)
	-- 04 -- path_drop_notop	-- Path to exit (vertical exit)
	-- 05 -- entrance			-- Player start (horizontal exit)
	-- 06 -- entrance_drop		-- Player start (vertical exit)
	-- 07 -- exit				-- Exit door (horizontal entrance)
	-- 08 -- exit_notop			-- Exit door (vertical entrance)

module.HD_SUBCHUNKID = {
    SIDE = 0,
    PATH = 1,
    PATH_DROP = 2,
    PATH_NOTOP = 3,
    PATH_DROP_NOTOP = 4,
    ENTRANCE = 5,
    ENTRANCE_DROP = 6,
    EXIT = 7,
    EXIT_NOTOP = 8,
    IDOL = 9,
    ALTAR = 10,
    MOAI = 15,
    COFFIN_COOP = 43,             -- HD: 43
    COFFIN_COOP_NOTOP = 45,       -- HD: 45
    COFFIN_COOP_DROP = 44,        -- HD: 44
    COFFIN_COOP_DROP_NOTOP = 46,  -- HD: 44
    COFFIN_UNLOCK_RIGHT = 73,
    COFFIN_UNLOCK_LEFT = 74,
    COFFIN_UNLOCK = 75,             -- HD: 43
    COFFIN_UNLOCK_NOTOP = 76,       -- HD: 45
    COFFIN_UNLOCK_DROP = 77,        -- HD: 44
    COFFIN_UNLOCK_DROP_NOTOP = 78,  -- HD: 44
    SHOP_REGULAR = 1000,
    SHOP_REGULAR_LEFT = 1001,
    SHOP_PRIZE = 1002,
    SHOP_PRIZE_LEFT = 1003,
    SHOP_BROTHEL = 1004,
    SHOP_BROTHEL_LEFT = 1005,
    SHOP_UNKNOWN1 = 1006,
    SHOP_UNKNOWN1_LEFT = 1007,
    SHOP_UNKNOWN2 = 1008,
    SHOP_UNKNOWN2_LEFT = 1009,
    VAULT = 1010,
    SNAKEPIT_TOP = 106,
    SNAKEPIT_MIDSECTION = 107,
    SNAKEPIT_BOTTOM = 108,
    
    SPIDERLAIR_RIGHTSIDE = 130,
    SPIDERLAIR_RIGHTSIDE_NOTOP = 131,
    SPIDERLAIR_RIGHTSIDE_DROP = 132,
    SPIDERLAIR_RIGHTSIDE_DROP_NOTOP = 133,
    SPIDERLAIR_LEFTSIDE = 134,
    SPIDERLAIR_LEFTSIDE_NOTOP = 135,
    SPIDERLAIR_LEFTSIDE_DROP = 136,
    SPIDERLAIR_LEFTSIDE_DROP_NOTOP = 137,
    SPIDERLAIR_LEFTSIDE_UNLOCK = 138,
    SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP = 139,
    
    BLACKMARKET_ANKH = 2010,
    BLACKMARKET_SHOP = 2011,
    
    TIKIVILLAGE_PATH = 1030,
    TIKIVILLAGE_PATH_DROP = 1031,
    TIKIVILLAGE_PATH_NOTOP = 1032,
    TIKIVILLAGE_PATH_DROP_NOTOP = 1033,
    
    TIKIVILLAGE_PATH_NOTOP_LEFT = 1034,
    TIKIVILLAGE_PATH_NOTOP_RIGHT = 1035,
    
    TIKIVILLAGE_PATH_DROP_NOTOP_LEFT = 1036,
    TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT = 1037,
    
    RUSHING_WATER_EXIT = 1101,
    RUSHING_WATER_PATH = 1102,
    RUSHING_WATER_SIDE = 1103,
    RUSHING_WATER_OLBITEY = 1104,
    RUSHING_WATER_BOTTOM = 1105,
    RUSHING_WATER_UNLOCK_LEFTSIDE = 1145,
    RUSHING_WATER_UNLOCK_RIGHTSIDE = 1146,
    
    WORM_CRYSKNIFE_LEFTSIDE = 1241,
    WORM_CRYSKNIFE_RIGHTSIDE = 1242,
    WORM_REGENBLOCK_STRUCTURE = 1275,
    
    COG_BOTD_LEFTSIDE = 126,
    COG_BOTD_RIGHTSIDE = 127,
    
    UFO_LEFTSIDE = 112,
    UFO_MIDDLE = 113,
    UFO_RIGHTSIDE = 114,
    
    YETIKINGDOM_YETIKING = 301,
    YETIKINGDOM_YETIKING_NOTOP = 302,
    
    ICE_CAVES_ROW_FIVE = 355,
    
    ICE_CAVES_POOL_SINGLE = 368,
    ICE_CAVES_POOL_DOUBLE_TOP = 369,
    ICE_CAVES_POOL_DOUBLE_BOTTOM = 370,
    
    MOTHERSHIPENTRANCE_TOP = 128,
    MOTHERSHIPENTRANCE_BOTTOM = 129,
    
    MOTHERSHIP_ALIENQUEEN = 2001,
    MOTHERSHIP_ALIENLORD = 2002,
    
    RESTLESS_TOMB = 147,
    RESTLESS_IDOL = 148,
    
    HAUNTEDCASTLE_SETROOM_1_2 = 200,
    HAUNTEDCASTLE_SETROOM_1_3 = 201,
    HAUNTEDCASTLE_MIDDLE = 202,
    HAUNTEDCASTLE_MIDDLE_DROP = 203,
    HAUNTEDCASTLE_BOTTOM = 204,
    HAUNTEDCASTLE_BOTTOM_NOTOP = 205,
    HAUNTEDCASTLE_WALL = 206,
    HAUNTEDCASTLE_WALL_DROP = 207,
    HAUNTEDCASTLE_GATE = 208,
    HAUNTEDCASTLE_GATE_NOTOP = 209,
    HAUNTEDCASTLE_MOAT = 210,
    HAUNTEDCASTLE_UNLOCK = 211,
    HAUNTEDCASTLE_EXIT = 212,
    HAUNTEDCASTLE_EXIT_NOTOP = 213,
    
    SACRIFICIALPIT_TOP = 116,
    SACRIFICIALPIT_MIDSECTION = 117,
    SACRIFICIALPIT_BOTTOM = 118,
    
    OLMEC_ROW_FIVE = 444,
    
    VLAD_TOP = 119,
    VLAD_MIDSECTION = 120,
    VLAD_BOTTOM = 121,
    
    YAMA_EXIT = 500,
    YAMA_ENTRANCE = 501,
    YAMA_TOP = 502,
    YAMA_LEFTSIDE = 503,
    YAMA_RIGHTSIDE = 504,
    YAMA_SETROOM_1_2 = 505,
    YAMA_SETROOM_1_3 = 506,
    YAMA_SETROOM_2_2 = 507,
    YAMA_SETROOM_2_3 = 508,
    YAMA_SETROOM_3_2 = 509,
    YAMA_SETROOM_3_3 = 510,
    YAMA_SETROOM_4_1 = 511,
    YAMA_SETROOM_4_3 = 512,
    YAMA_SETROOM_4_4 = 513
}

-- "5", "6", "8", "F", "V", "("
module.HD_OBSTACLEBLOCK = {
    GROUND = {
        tilename = "5",
        dim = {3,5}
    },
    AIR = {
        tilename = "6",
        dim = {3,5}
    },
    DOOR = {
        tilename = "8",
        dim = {3,5}
    },
    PLATFORM = {
        tilename = "F",
        dim = {3,3},
        chunkcodes = {
            {"0ff000000"},
            {"0000ff000"},
            {"0000000ff"},
            {"00f000000"},
            {"0000f0000"},
            {"0000000f0"},
            {"0ji000000"},
            {"0000ji000"},
            {"0000000ji"},
            {"00i000000"},
            {"0000i0000"},
            {"0000000i0"}
        }
    },
    VINE = {
        tilename = "V",
        dim = {4,5},
        chunkcodes = {
            {"L0L0LL0L0LL000LL0000"},
            {"L0L0LL0L0LL000L0000L"},
            {"0L0L00L0L00L0L0000L0"}
        }
    },
    TEMPLE = {
        tilename = "(",
        dim = {3,4},
        chunkcodes = {
            {"111100000000"},
            {"222200000000"},
            {"222022200000"},
            {"022202220000"},
            {"000011110000"},
            {"000011112222"},
            {"000022221111"},
            {"000002202112"},
            {"000020021221"}
        }
    },
}

module.HD_OBSTACLEBLOCK_TILENAME = {
    ["5"] = module.HD_OBSTACLEBLOCK.GROUND,
    ["6"] = module.HD_OBSTACLEBLOCK.AIR,
    ["8"] = module.HD_OBSTACLEBLOCK.DOOR,
    ["F"] = module.HD_OBSTACLEBLOCK.PLATFORM,
    ["V"] = module.HD_OBSTACLEBLOCK.VINE,
    ["("] = module.HD_OBSTACLEBLOCK.TEMPLE
}




module.global_levelassembly = nil

-- # TODO: For development of the new scripted level gen system, move tables/variables into here from init_onlevel() as needed.
function module.init_posttile_door()
	module.global_levelassembly = {}
end

set_callback(function()
	-- roomgenlib.global_levelassembly = nil
end, ON.TRANSITION)

return module