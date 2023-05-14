commonlib = require 'lib.common'
feelingslib = require 'lib.feelings'
unlockslib = require 'lib.unlocks'

local module = {}

function module.init()
	module.CHUNKBOOL_IDOL = false
	module.CHUNKBOOL_ALTAR = false
	module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 = false
	module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 = false
end

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

	--H Hive, O Open (crystal skull or path), C Closed (not hive, crystal skull or path)
	--LEFT/RIGHT Open {
	HIVE_RIGHT_H_LEFT = 1300, --6
	HIVE_LEFT_H_RIGHT = 1301, --7
	HIVE_LEFT = 1302, --2
	HIVE_SIDES = 1303, --3
	HIVE_RIGHT = 1304, --5
	--} SIDE/UP Open (Should always be connected to hive, if not, its unused I think) {
	HIVE_UP = 1311, --1 unused?
	HIVE_H_UP = 1312, --2
	HIVE_UP_RIGHT_H_LEFT = 1313, --3
	HIVE_UP_RIGHT = 1314, --4 unused?
	HIVE_RIGHT_H_UP = 1315, --5
	HIVE_UP_LEFT_H_RIGHT = 1316, --6
	HIVE_UP_LEFT = 1317, --7 unused?
	HIVE_LEFT_H_UP = 1318, --8
	HIVE_UP_SIDES = 1319, -- unused?
	HIVE_SIDES_H_UP = 1320,
	--} SIDE/VERTICAL Open {
	HIVE_UP_DOWN_H_LEFT = 1321,
	HIVE_UP_DOWN_H_RIGHT = 1322,
	HIVE_UP_DOWN = 1323, --unused?
	HIVE_UP_H_DOWN = 1324, --unused?
	HIVE_UP_RIGHT_H_DOWN = 1325,
	HIVE_UP_LEFT_H_DOWN = 1326,
	--} SIDE/DOWN Open (There should always be a hive on sides or down, there can never be a hive up) {
	HIVE_SIDES_DOWN_H_UP = 1331, --unused?
	HIVE_SIDES_H_VERTICAL = 1332, --unused?
	HIVE_DOWN = 1333, --unused?
	HIVE_H_DOWN = 1334,
	HIVE_RIGHT_DOWN_H_LEFT = 1335,
	HIVE_RIGHT_DOWN = 1336, --unused?
	HIVE_RIGHT_H_DOWN = 1337,
	HIVE_DOWN_LEFT_H_RIGHT = 1338,
	HIVE_DOWN_LEFT = 1339,
	HIVE_LEFT_H_DOWN = 1340,
	HIVE_SIDES_H_DOWN = 1341,
	HIVE_SIDES_DOWN = 1342, --used on others when can't find a room (LEFT/RIGHT is the only I know where it can happen)
	--}
	HIVE_PRE_SIDES = 1350,
	HIVE_PRE_SIDE_UP = 1351,
	HIVE_PRE_SIDE_VERTICAL = 1352,
	HIVE_PRE_SIDE_DOWN = 1353,
    
    COG_BOTD_LEFTSIDE = 126,
    COG_BOTD_RIGHTSIDE = 127,
    
    UFO_LEFTSIDE = 112,
    UFO_MIDDLE = 113,
    UFO_RIGHTSIDE = 114,
    
    YETIKINGDOM_YETIKING = 301,
    YETIKINGDOM_YETIKING_NOTOP = 302,
    YETIKINGDOM_YETIKING_DROP = 303,
    YETIKINGDOM_YETIKING_DROP_NOTOP = 304,
    
    ICE_CAVES_ROW_FIVE = 355,
    
    ICE_CAVES_POOL_SINGLE = 368,
    ICE_CAVES_POOL_DOUBLE_TOP = 369,
    ICE_CAVES_POOL_DOUBLE_BOTTOM = 370,
    
    MOTHERSHIPENTRANCE_TOP = 128,
    MOTHERSHIPENTRANCE_BOTTOM = 129,
    
    MOTHERSHIP_ALIENQUEEN = 2001,
    MOTHERSHIP_ALIENLORD_RIGHT = 2002,
    MOTHERSHIP_ALIENLORD_LEFT = 2003,
    
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
    YAMA_ENTRANCE_2 = 502,
    YAMA_TOP = 503,
    YAMA_LEFTSIDE = 504,
    YAMA_RIGHTSIDE = 505,
    YAMA_SETROOM_1_2 = 506,
    YAMA_SETROOM_1_3 = 507,
    YAMA_SETROOM_2_2 = 508,
    YAMA_SETROOM_2_3 = 509,
    YAMA_SETROOM_3_2 = 510,
    YAMA_SETROOM_3_3 = 511,
    YAMA_SETROOM_4_1 = 512,
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


module.HD_ROOMOBJECT = {}
module.HD_ROOMOBJECT.GENERIC = {
	
	-- # TODO: Shopkeeper room assigning
	-- room_x + room_y * 8
	-- https://discord.com/channels/150366712775180288/862012437892825108/873695668173148171
	
	-- Regular
	[module.HD_SUBCHUNKID.SHOP_REGULAR] = {
		--{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..KS000000bbbbbbbbbb"} -- original
		-- {"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..00000000bbbbbbbbbb"} -- hd accurate sync
		{"111111111111110011111100220000110l000200000000W00000000000000000000000bbbbbbbbbb"} -- hd accurate sync without sign block
		-- {"111111111111110011111100220001110l000200000000W00000000000k00000000000bbbbbbbbbb"} -- hd accurate sync
	},
	[module.HD_SUBCHUNKID.SHOP_REGULAR_LEFT] = {
		--{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S000K..bbbbbbbbbb"} -- original
		-- {"11111111111111..11111...22..11..2000l.110.W0000...0k00000...00000000..bbbbbbbbbb"} -- hd accurate sync
		{"111111111111110011110000220011002000l01100W000000000000000000000000000bbbbbbbbbb"} -- hd accurate sync without sign block
		-- {"111111111111110011111000220011002000l01100W00000000k000000000000000000bbbbbbbbbb"} -- hd accurate sync
	},
	-- Prize Wheel
	[module.HD_SUBCHUNKID.SHOP_PRIZE] = {
		--{"11111111111111..1111....22...1.Kl00002.....000W0.0.0%00000k0.$%00S0000bbbbbbbbbb"} -- original
		-- {"11111111111111..1111....22...1.0l00002....0000W0.0.0000000k0.000000000bb0bbbbbbb"} -- hd accurate sync
		-- {"11111111111111001111000022000000l0000200000000W00000000000000000000000bb0bbbbbbb"} -- hd accurate sync without sign block (sync1)
		-- {"11111111111111001111000022000100l0000200000000W00000000000k00000000000bb0bbbbbbb"} -- hd accurate sync
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- s2
		{"111111111110000000010000l000000bbb000000000000W00l00000000000000000000bb0bbbbbbb"} -- s2 sync
	},
	[module.HD_SUBCHUNKID.SHOP_PRIZE_LEFT] = {
		--{"11111111111111..11111...22......20000lK.0.W0000...0k00000%0.0000S00%$.bbbbbbbbbb"} -- original
		-- {"11111111111111..11111...22......20000l0.0.W00000..0k0000000.000000000.bbbbbbb0bb"} -- hd accurate sync
		-- {"1111111111111100111100002200000020000l0000W000000000000000000000000000bbbbbbb0bb"} -- hd accurate sync without sign block (sync1)
		-- {"1111111111111100111110002200000020000l0000W00000000k000000000000000000bbbbbbb0bb"} -- hd accurate sync
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- s2 sync
		{"1111111111100000000100000l0000000000bbb0l00W00000000000000000000000000bbbbbbb0bb"} -- s2 sync
	},
	-- Damzel
	[module.HD_SUBCHUNKID.SHOP_BROTHEL] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K00S0000bbbbbbbbbb"} -- original
	},
	[module.HD_SUBCHUNKID.SHOP_BROTHEL_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...0000S00K..bbbbbbbbbb"} -- original
	},
	-- Hiredhands(?)
	[module.HD_SUBCHUNKID.SHOP_UNKNOWN1] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0SSS000bbbbbbbbbb"} -- original
	},
	[module.HD_SUBCHUNKID.SHOP_UNKNOWN1_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000SSS0K..bbbbbbbbbb"} -- original
	},
	-- Hiredhands(?)
	[module.HD_SUBCHUNKID.SHOP_UNKNOWN2] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0S0S000bbbbbbbbbb"} -- original
	},
	[module.HD_SUBCHUNKID.SHOP_UNKNOWN2_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S0S0K..bbbbbbbbbb"} -- original
	},
	-- Vault
	[module.HD_SUBCHUNKID.VAULT] = {
		--{"11111111111111111111111|00011111100001111110EE0111111000011111111111111111111111"} -- original
		{"11111111111111111111111|00011111100001111110000111111000011111111111111111111111"}
		-- {"11111111111000000001100|00000110000000011000000001100000000110000000011111111111"} -- hd accurate sync
	},
	-- Altar
	[module.HD_SUBCHUNKID.ALTAR] = {
		{"220000002200000000000000000000000000000000000000000000x0000002211112201111111111"}
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- hd accurate sync
	},
	[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE] = {
		{"22222222220000000000000000000000000000000000000000000000000000000000000000000000"},
		{"11111111112222222222000000000000000000000000000000000000000000000000000000000000"},
		{"22211112220001111000000211200000011110000002112000000022000000000000000000000000"},
		{"11112211112112002112022000022000000000000000000000000000000000000000000000000000"}
	}
}
module.HD_ROOMOBJECT.TUTORIAL = {}
module.HD_ROOMOBJECT.TUTORIAL[1] = {
	setRooms = {
		-- 1
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 1},
			roomcodes = {{"11111111111111111122121111120010222220001000000000100000000010090000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"1111111111111111110001111100000000000000000000000!000000000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"1111111111222vv111000000000000000EE00000000vv00EE0000vv00vv0111vvN0vvN1111111vv1"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"1111111111222111111100022221110000000111000000vvv1000000v0010000000EE1111000v==1"}}
		},

		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"1111111111111111111111vvvv111100000001120L0EE000200Pvvvv00000LvvE000001Pvvvv1111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"11111111001111111200222221120000000110000000E110000001111R000000E111111100111110"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},
			roomcodes = {{"0000000000000000000000000000000000000000000000000000000!000011000000000000001111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000001100000000000000000000011110000000011000011111100N01111111111111111"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"0L111111110L011111110L000000000L000000000L00!000000L000000000L000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"0000000000000000000000EE000000001100000v0011000000001111100000111110001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"0000000000000110000000N0000000vvv000000000000N00000vvvvv000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"000000000000L000000000P11000E000L110011000L110000000L111000000L11100L01111111vPv"}}
		},

		-- 4
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {4, 1},
			roomcodes = {{"1111111112111111222022222200000000000000000900000000vvv0000v00vvv0000v1vvvvv111v"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"1111111111001EE0000000vvvv000000v00v0000000NE0001100v==vv00000111110001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"000000000000000000000000000000000000000000110011000011001111ssssss0R111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000L000E00000L000110000L000010000L000000000L000000000L0000000N0L01111111111"}}
		},
	}
}
module.HD_ROOMOBJECT.TUTORIAL[2] = {
	setRooms = {
		-- 1
		{
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"10001111110000000000z000000000111000000011L00000e0vvPvvvvv11vEL000Ev11vvL0vvvv11"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"1111111111000000000000000000000000000!000e000000001111N00000111110N0001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"11111111110110000000000000000000000000000000001110000001111s00000011111111111111"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 4},
			roomcodes = {{"111111111100000000010EEEE000010vvvv0090100vv001111ssvvss111111vv1111111111111111"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"11L00001111100L000001111P00000vvvvL00000v00vL00000vEE0L00000v==vvvv1111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"1111111111111111111111011110010u000u000u00000000000000!0000000000000001111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},
			roomcodes = {{"1111111111111110000011000000000000000011000000!011000000001100000000111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"1111111111000111111100000L000z111vvPvvvv11111L000011111L000011111L00L01111vvvvPv"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"111111111111111111vv1vvv1111v00eee0111vh0vvv0111v=000001111110001111111001111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"1100000011vv001111110v00111111h001111111=v11111111111111111111111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"11111111111111111111111001110011a0000u00111000000011e000N000111111111111111111vv"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"11111111L011101110L001100000L000000vvvvv000000E11111110011111111001111vvvv001111"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"10000000001000000000000!00000000000000001110101011RR10101011111s1s1s111111111111"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {4, 2},
			roomcodes = {{"11111111110000111000000000000000900000001111000!00111100000111110a00011111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"11100011v0011000000000000000v=0000000111000000001110N000001011111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00v00vv000v00EEvEE00v=vvvvvv0011111111100000001100000z00040011111111111111111111"}}
		},
	}
}
module.HD_ROOMOBJECT.TUTORIAL[3] = {
	setRooms = {
		-- 1
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE,
			placement = {1, 1},
			roomcodes = {{"1111111111vvvvvv2222v0000v0000v009000000v====v000011111100vv11111111vv1111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"22000000000000000!000000000000001000a0o00000011111vssssR1111v1111111111111111111"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"110011100000000010000000000000000000000v0000N0000v0o0111000v111111001v1111110001"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"0uvv10v00000vv000EEE000v00v===vvvv000000vv0v000001v00N00N00hvv=v1111111111111111"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"11111111110001111111z000022111110000000011000000vv11o00L000E11110Pvvvv11110L1111"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 2},
			roomcodes = {{"11111110011111110000000u0u00000o00000000v111110000v111110000v111110I001111111A01"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 3},-- "!" = arrow trap for this one, h = rope crate
			roomcodes = {{"1111111001011111000100111100110011110000!111vvv0001111vE0000h111vvvv001111110000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.SHOP_REGULAR_LEFT,
			placement = {2, 4},
			-- wow, okay, so comparing SHOP_REGULAR_LEFT's roomcode to the original shows that it's almost exactly the same
			-- with the exception of the overhead tiles not set to shopkeeper tiles
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.SHOP_REGULAR_LEFT]) -- {{"111111111111111111111111221111112000l11101W0000...0k00000...000S000K..bbbbbbbbbb"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"11110Lvvv111100L0000vvv0vvvvv0vE00000000vvvvv0000011v0v0000011v000001111v=v00011"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"111111111100000000000000000000000L011111000P11vvvv000L11v000000L040EEE111111v==="}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"11110000000000000N01000N0111111111111111vvvv111010000v100000EE00400000===v111111"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"111111111111111111111111111111111111111111111111110001100010000000000000100000D0"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"1100001111110011111100000000u00000a00000vvvvv00000h0000001101111111110111111111s"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"111111z0111111111011000000000000000000000000000000101010110o10101011111s1s1s1111"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"111111111111111111110000000u0000000!0000N0000000001100000000110001111111sss11111"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {4, 4},
			roomcodes = {{"111111111111111vvvvv00001v0000000000009000100v====001000111111111111111111111111"}}
		},
	}
}
module.HD_ROOMOBJECT.TESTING = {}
module.HD_ROOMOBJECT.TESTING[1] = {
	setRooms = {
		-- 1
		{
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {2, 3},
			roomcodes = {{"00000000000000090LL01111111PP10000000LL0000LL00LL0111PP11111000LL00000000LL00000"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000001111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"00000LL00000000LL00000000LL00000000LL00000000LL000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"000LL00000000LL00000000LL00000000LL00000000LL00000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000111111110000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
	}
}
module.HD_ROOMOBJECT.TESTING[2] = {
	setRooms = {
		-- 1
		{
			subchunk_id = -1,
			placement = {1, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {1, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		
		-- 2
		{
			subchunk_id = -1,
			placement = {2, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {2, 3},
			roomcodes = {{"00000000000000090LL01111111PP10000000LL0000LL00LL0111PP11111000LL00000000LL00000"}}
		},
		{
			subchunk_id = -1,
			placement = {2, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 3
		{
			subchunk_id = -1,
			placement = {3, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000001111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 2},
			roomcodes = {{"00000LL00000000LL00000000LL00000000LL00000000LL000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 3},
			roomcodes = {{"000LL00000000LL00000000LL00000000LL00000000LL00000111111111100000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {3, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000111111110000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = -1,
			placement = {4, 1},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 2},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 3},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = -1,
			placement = {4, 4},
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
	}
}
module.HD_ROOMOBJECT.FEELINGS = {}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE] = {
	rooms = {
		[module.HD_SUBCHUNKID.HIVE_RIGHT_H_LEFT] = {{"eeeeeeee11zzzzzzzeee0000000zee000000000000000000000000000zeezzzzzzzeeeeeeeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_LEFT_H_RIGHT] = {{"11eeeeeeeeeeezzzzzzzeez000000000000000000000000000eez0000000eeezzzzzzz11eeeeeeee"}},
		[module.HD_SUBCHUNKID.HIVE_LEFT] = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeeez00000zeeeezzzzzee11eeeeeee1"}},
		[module.HD_SUBCHUNKID.HIVE_SIDES] = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_RIGHT] = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez00000zeeeezzzzzeee1eeeeeee11"}},
		
		[module.HD_SUBCHUNKID.HIVE_UP] = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_H_UP]  = {{"ez000000zeez00zz00zeez00zz00zeez000000zeez000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_UP_RIGHT_H_LEFT]  = {{"eeee00ee11zzzz00zeee0000000zee000000000000000000000000000zeezzzzzzzeeeeeeeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_UP_RIGHT]  = {{"11ee00ee11eeez00zeeeeez0000zeeez00000000ez00000000eez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_RIGHT_H_UP]  = {{"ez000000zeez00zz00zeez00zz00zeez00000000ez00000000eez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_UP_LEFT_H_RIGHT]  = {{"11ee00eeeeeeez00zzzzeez000000000000000000000000000eez0000000eeezzzzzzz11eeeeeeee"}},
		[module.HD_SUBCHUNKID.HIVE_UP_LEFT]  = {{"11ee00ee11eeez00zeeeeez0000zee00000000ze00000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_LEFT_H_UP]  = {{"ez000000zeez00zz00zeez00zz00ze00000000ze00000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_UP_SIDES]  = {{"11ee00ee11eeez00zeeeeez0000zee00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		[module.HD_SUBCHUNKID.HIVE_SIDES_H_UP]  = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		
		[module.HD_SUBCHUNKID.HIVE_UP_DOWN_H_LEFT] = {{"11ee00ee11eeez00zeee0000000zee00000000ze00000000ze00000000zeeeez00zzee11ee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_UP_DOWN_H_RIGHT] = {{"11ee00ee11eeez00zeeeeez0000000ez00000000ez00000000ez00000000eezz00zeeeeeee00ee11"}},
		[module.HD_SUBCHUNKID.HIVE_UP_DOWN] = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeez000000zeeezz00zzeeeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_UP_H_DOWN] = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_UP_RIGHT_H_DOWN] = {{"11ee00ee11eeez00zeeeeez0000zeeez00000000ez00000000ez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_UP_LEFT_H_DOWN] = {{"11ee00ee11eeez00zeeeeez0000zee00000000ze00000000zeez00zz00zeez00zz00zeez000000ze"}},
		
		[module.HD_SUBCHUNKID.HIVE_SIDES_DOWN_H_UP] = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000ez000000zeeezz00zzeeeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_SIDES_H_VERTICAL] = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000ez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_DOWN] = {{"11eeeeee11eeezzzzeeeeez0000zeeez000000zeez000000zeez000000zeeezz00zzeeeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_H_DOWN] = {{"11eeeeee11eeezzzzeeeeez0000zeeez000000zeez000000zeez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_RIGHT_DOWN_H_LEFT] = {{"eeeeeeee11zzzzzzzeee0000000zee000000000000000000000000000zeezzzz00zeeeeeee00ee11"}},
		[module.HD_SUBCHUNKID.HIVE_RIGHT_DOWN] = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez000000zeeezz00zzeeeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_RIGHT_H_DOWN] = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_DOWN_LEFT_H_RIGHT] = {{"11eeeeeeeeeeezzzzzzzeez000000000000000000000000000ez00000000eezz00zzzzeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_DOWN_LEFT] = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeez000000zeeezz00zzeeeeee00eeee"}},
		[module.HD_SUBCHUNKID.HIVE_LEFT_H_DOWN] = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_SIDES_H_DOWN] = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000ez00zz00zeez00zz00zeez000000ze"}},
		[module.HD_SUBCHUNKID.HIVE_SIDES_DOWN] = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000ez000000zeeezz00zzeeeeee00eeee"}},

		-- This is an absolute abomination of a naming scheme, but that's for future-me to resolve.
		-- Resolutions I can only dream of. Imagine living in a post-hive-spawn-understanding world: World peace. Solving world hunger. The hive genlib.HD_SUBCHUNKID naming scheme not being a total cluster-truck.
		
		
		-- [genlib.HD_SUBCHUNKID.HIVE_LEFT_OPEN] = {{"11eeeeeeeeeeezzzzzzzeez000000000000000000000000000eez0000000eeezzzzzzz11eeeeeeee"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_LEFT_OPEN_AND_UP] = {{"11ee00eeeeeeez00zzzzeez000000000000000000000000000eez0000000eeezzzzzzz11eeeeeeee"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_LEFT_CLOSED] = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeeez00000zeeeezzzzzee11eeeeeee1"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_RIGHT_OPEN] = {{"eeeeeeee11zzzzzzzeee0000000zee000000000000000000000000000zeezzzzzzzeeeeeeeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_RIGHT_OPEN_AND_UP] = {{"eeee00ee11zzzz00zeee0000000zee000000000000000000000000000zeezzzzzzzeeeeeeeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_RIGHT_CLOSED] = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez00000zeeeezzzzzeee1eeeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_LEFT_RIGHT] = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_LEFT_RIGHT_AND_UP] = {{"11ee00ee11eeez00zeeeeez0000zee00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED] = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_ALT] = {{"ez000000zeez00zz00zeez00zz00zeez000000zeez000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_AND_RIGHT] = {{"11ee00ee11eeez00zeeeeez0000zeeez00000000ez00000000eez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_AND_LEFT] = {{"11ee00ee11eeez00zeeeeez0000zee00000000ze00000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_ALT_AND_RIGHT] = {{"ez000000zeez00zz00zeez00zz00zeez00000000ez00000000eez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_ALT_AND_LEFT] = {{"ez000000zeez00zz00zeez00zz00ze00000000ze00000000zeeez0000zeeeeezzzzeee11eeeeee11"}},
		-- [genlib.HD_SUBCHUNKID.HIVE_UP_CLOSED_ALT_AND_LEFT_AND_RIGHT] = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000eez0000zeeeeezzzzeee11eeeeee11"}},
		-- -- I give up
		-- -- ??? = {{"11ee00ee11eeez00zeee0000000zee00000000ze00000000ze00000000zeeeez00zzee11ee00eeee"}},
		-- -- ??? = {{"11ee00ee11eeez00zeeeeez0000000ez00000000ez00000000ez00000000eezz00zeeeeeee00ee11"}},
		-- -- ??? = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeez000000zeeezz00zzeeeeee00eeee"}},

		-- -- ??? = {{"11ee00ee11eeez00zeeeeez0000zeeez000000zeez000000zeez00zz00zeez00zz00zeez000000ze"}},
		-- -- ??? = {{"11ee00ee11eeez00zeeeeez0000zeeez00000000ez00000000ez00zz00zeez00zz00zeez000000ze"}},
		-- -- ??? = {{"11ee00ee11eeez00zeeeeez0000zee00000000ze00000000zeez00zz00zeez00zz00zeez000000ze"}},

		-- -- ??? = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000ez000000zeeezz00zzeeeeee00eeee"}},
		-- -- ??? = {{"ez000000zeez00zz00zeez00zz00ze00000000000000000000ez00zz00zeez00zz00zeez000000ze"}},
		
		-- -- ??? = {{"11eeeeee11eeezzzzeeeeez0000zeeez000000zeez000000zeez000000zeeezz00zzeeeeee00eeee"}}, -- down_closed
		-- -- ??? = {{"11eeeeee11eeezzzzeeeeez0000zeeez000000zeez000000zeez00zz00zeez00zz00zeez000000ze"}}, -- down_closed_alt

		-- -- ??? = {{"eeeeeeee11zzzzzzzeee0000000zee000000000000000000000000000zeezzzz00zeeeeeee00ee11"}},
		-- -- ??? = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez000000zeeezz00zzeeeeee00eeee"}},

		-- -- ??? = {{"1eeeeeee11eezzzzzeeeez00000zeeez00000000ez00000000ez00zz00zeez00zz00zeez000000ze"}},

		-- -- ??? = {{"11eeeeeeeeeeezzzzzzzeez000000000000000000000000000ez00000000eezz00zzzzeeee00eeee"}},
		-- -- ??? = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeez000000zeeezz00zzeeeeee00eeee"}},
		-- -- ??? = {{"11eeeeeee1eeezzzzzeeeez00000ze00000000ze00000000zeez00zz00zeez00zz00zeez000000ze"}},
		-- -- ??? = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000ez00zz00zeez00zz00zeez000000ze"}},
		-- -- ??? = {{"11eeeeee11eeezzzzeeeeez0000zee00000000000000000000ez000000zeeezz00zzeeeeee00eeee"}},
		-- -- there's 33 total room types, good god. In S2 there are TWO.
	}
}

local HIVE_TYPE <const> = {
	GROW_LEFT = 1,
	GROW_RIGHT = 2,
	GROW_UP = 3,
	GROW_DOWN = 4
}

local HIVE_OPEN <const> = {
	LEFT = 0x1,
	RIGHT = 0x2,
	UP = 0x4,
	DOWN = 0x8,
	SIDES = 0x3,
	H_LEFT = 0x10,
	H_RIGHT = 0x20,
	H_UP = 0x40,
	H_DOWN = 0x80,
}

local HIVE_BY_MASKS <const> = {
	[HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_LEFT,
	[HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_RIGHT,
	[HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES,
	[HIVE_OPEN.H_LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_RIGHT_H_LEFT,
	[HIVE_OPEN.H_RIGHT | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_LEFT_H_RIGHT,
	[HIVE_OPEN.H_LEFT] = module.HD_SUBCHUNKID.HIVE_RIGHT_H_LEFT,
	[HIVE_OPEN.H_RIGHT] = module.HD_SUBCHUNKID.HIVE_LEFT_H_RIGHT,
	--UP
	[HIVE_OPEN.UP] = module.HD_SUBCHUNKID.HIVE_UP,
	[HIVE_OPEN.H_UP] = module.HD_SUBCHUNKID.HIVE_H_UP,
	[HIVE_OPEN.UP | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_UP_LEFT,
	[HIVE_OPEN.UP | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_UP_RIGHT,
	[HIVE_OPEN.UP | HIVE_OPEN.LEFT | HIVE_OPEN.H_RIGHT] = module.HD_SUBCHUNKID.HIVE_UP_LEFT_H_RIGHT,
	[HIVE_OPEN.UP | HIVE_OPEN.RIGHT | HIVE_OPEN.H_LEFT] = module.HD_SUBCHUNKID.HIVE_UP_RIGHT_H_LEFT,
	[HIVE_OPEN.UP | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_UP_SIDES,
	[HIVE_OPEN.H_UP | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_RIGHT_H_UP,
	[HIVE_OPEN.H_UP | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_LEFT_H_UP,
	[HIVE_OPEN.H_UP | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES_H_UP,
	--VERTICAL
	[HIVE_OPEN.UP | HIVE_OPEN.DOWN] = module.HD_SUBCHUNKID.HIVE_UP_DOWN,
	[HIVE_OPEN.UP | HIVE_OPEN.H_DOWN] = module.HD_SUBCHUNKID.HIVE_UP_H_DOWN,
	[HIVE_OPEN.UP | HIVE_OPEN.DOWN | HIVE_OPEN.H_LEFT] = module.HD_SUBCHUNKID.HIVE_UP_DOWN_H_LEFT,
	[HIVE_OPEN.UP | HIVE_OPEN.DOWN | HIVE_OPEN.H_RIGHT] = module.HD_SUBCHUNKID.HIVE_UP_DOWN_H_RIGHT,
	[HIVE_OPEN.UP | HIVE_OPEN.RIGHT | HIVE_OPEN.H_DOWN] = module.HD_SUBCHUNKID.HIVE_UP_RIGHT_H_DOWN,
	[HIVE_OPEN.UP | HIVE_OPEN.LEFT | HIVE_OPEN.H_DOWN] = module.HD_SUBCHUNKID.HIVE_UP_LEFT_H_DOWN,
	--DOWN
	[HIVE_OPEN.DOWN] = module.HD_SUBCHUNKID.HIVE_DOWN,
	[HIVE_OPEN.H_DOWN] = module.HD_SUBCHUNKID.HIVE_H_DOWN,
	[HIVE_OPEN.DOWN | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_RIGHT_DOWN,
	[HIVE_OPEN.DOWN | HIVE_OPEN.RIGHT | HIVE_OPEN.H_LEFT] = module.HD_SUBCHUNKID.HIVE_RIGHT_DOWN_H_LEFT,
	[HIVE_OPEN.H_DOWN | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_RIGHT_H_DOWN,
	[HIVE_OPEN.DOWN | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_DOWN_LEFT,
	[HIVE_OPEN.DOWN | HIVE_OPEN.LEFT | HIVE_OPEN.H_RIGHT] = module.HD_SUBCHUNKID.HIVE_DOWN_LEFT_H_RIGHT,
	[HIVE_OPEN.H_DOWN | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_LEFT_H_DOWN,
	[HIVE_OPEN.DOWN | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES_DOWN,
	[HIVE_OPEN.H_DOWN | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES_DOWN,
	--unused [HIVE_OPEN.H_UP | HIVE_OPEN.DOWN | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES_DOWN_H_UP,
	--unused [HIVE_OPEN.H_UP | HIVE_OPEN.H_DOWN | HIVE_OPEN.LEFT | HIVE_OPEN.RIGHT] = module.HD_SUBCHUNKID.HIVE_SIDES_H_VERTICAL,
	--used when SIDES (or maybe others) don't find any valid room
	[HIVE_OPEN.RIGHT | HIVE_OPEN.DOWN | HIVE_OPEN.LEFT] = module.HD_SUBCHUNKID.HIVE_SIDES_DOWN,
}

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE].postPathMethod = function()
	local function is_path_drop(room_id)
		return room_id == module.HD_SUBCHUNKID.PATH_DROP
			or room_id == module.HD_SUBCHUNKID.ENTRANCE_DROP
			or room_id == module.HD_SUBCHUNKID.PATH_DROP_NOTOP
	end
	local function get_room(x, y)
		return roomgenlib.global_levelassembly.modification.levelrooms[y][x] or 0
	end
	local function is_room_cidol_or_path(x, y)
		local room = get_room(x, y)
		return (room > 0 and room < 9) or room == module.HD_SUBCHUNKID.RESTLESS_IDOL --paths or entrance/exit
	end
	local function choose_hive_room(hive_id, hive_x, hive_y, hive2_x, hive2_y)
		local room_mask = 0
		if hive_x > 1 and is_room_cidol_or_path(hive_x-1, hive_y) then
			room_mask = room_mask | HIVE_OPEN.LEFT
		elseif hive_x - 1 == hive2_x then
			room_mask = room_mask | HIVE_OPEN.H_LEFT
		end
		if hive_x < 4 and is_room_cidol_or_path(hive_x+1, hive_y) then
			room_mask = room_mask | HIVE_OPEN.RIGHT
		elseif hive_x + 1 == hive2_x then
			room_mask = room_mask | HIVE_OPEN.H_RIGHT
		end
		if hive_id == module.HD_SUBCHUNKID.HIVE_PRE_SIDE_VERTICAL then
			room_mask = room_mask | HIVE_OPEN.UP |  (hive_y+1 == hive2_y and HIVE_OPEN.H_DOWN or HIVE_OPEN.DOWN)
		elseif hive_id == module.HD_SUBCHUNKID.HIVE_PRE_SIDE_UP then
			room_mask = room_mask | (hive_y-1 == hive2_y and HIVE_OPEN.H_UP or HIVE_OPEN.UP)
		elseif hive_id == module.HD_SUBCHUNKID.HIVE_PRE_SIDE_DOWN then
			room_mask = room_mask | (hive_y+1 == hive2_y and HIVE_OPEN.H_DOWN or HIVE_OPEN.DOWN)
		end
		local hive_room = HIVE_BY_MASKS[room_mask]
		if not hive_room then
			hive_room = module.HD_SUBCHUNKID.HIVE_SIDES_DOWN
		end
		return hive_room
	end
	local ROOM_Y <const> = 3
	local room_x = 0
	for i = 1, 4, 1 do
		local subchunk_id = get_room(i, ROOM_Y)
		if subchunk_id == module.HD_SUBCHUNKID.SIDE then
			room_x = i
			break
		end
	end
	--if didn't find any available room then return
	if room_x == 0 then return end
	local room1_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDES
	local room2_x, room2_y = room_x, ROOM_Y
	local hive_type = math.random(1, 4)
	for i = 1, 4 do
		if hive_type == HIVE_TYPE.GROW_LEFT then
			if room_x > 1 then
				room2_x = room_x - 1
				break
			end
		elseif hive_type == HIVE_TYPE.GROW_RIGHT then
			if room_x < 4 then
				room2_x = room_x + 1
				break
			end
		elseif hive_type == HIVE_TYPE.GROW_UP then
			room2_y = ROOM_Y - 1
			room1_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_UP
			break
		elseif hive_type == HIVE_TYPE.GROW_DOWN then
			if roomgenlib.global_levelassembly.modification.levelrooms[ROOM_Y+1][room_x] == module.HD_SUBCHUNKID.EXIT
			or feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
				room2_x = 0
			else
				room2_y = ROOM_Y + 1
				room1_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_DOWN
			end
			break
		end
		hive_type = hive_type + 1
	end
	local room2_id
	if room2_x ~= 0 then
		local prev_room2_id = roomgenlib.global_levelassembly.modification.levelrooms[room2_y][room2_x]
		if (
			prev_room2_id == module.HD_SUBCHUNKID.PATH_DROP
			or room1_id == module.HD_SUBCHUNKID.HIVE_PRE_SIDE_UP
		) then
			local above_room_id = roomgenlib.global_levelassembly.modification.levelrooms[room2_y-1][room2_x]
			if 
				is_path_drop(above_room_id)
			then
				room2_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_VERTICAL
			else
				room2_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_DOWN
			end
		elseif prev_room2_id == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
			room2_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_VERTICAL
		elseif (
			prev_room2_id == module.HD_SUBCHUNKID.PATH_NOTOP
			or room1_id == module.HD_SUBCHUNKID.HIVE_PRE_SIDE_DOWN
		) then
			room2_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDE_UP
		else
			room2_id = module.HD_SUBCHUNKID.HIVE_PRE_SIDES
		end
		room2_id = choose_hive_room(room2_id, room2_x, room2_y, room_x, ROOM_Y)
		roomgenlib.levelcode_inject_roomcode(room2_id, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE].rooms[room2_id], room2_y, room2_x, 1)
	end
	room1_id = choose_hive_room(room1_id, room_x, ROOM_Y, room2_x, room2_y)
	roomgenlib.levelcode_inject_roomcode(room1_id, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE].rooms[room1_id], ROOM_Y, room_x, 1)
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VAULT] = {
	postPathMethod = function()
		if (
			roomgenlib.detect_level_non_special()
		) then
			roomgenlib.level_generation_method_nonaligned(
				{
					subchunk_id = module.HD_SUBCHUNKID.VAULT,
					roomcodes = (
						module.HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
						module.HD_ROOMOBJECT.WORLDS[state.theme].rooms[module.HD_SUBCHUNKID.VAULT] ~= nil
					) and module.HD_ROOMOBJECT.WORLDS[state.theme].rooms[module.HD_SUBCHUNKID.VAULT] or module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.VAULT]
				}
				,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			)
		end
	end
}

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR] = {
	rooms = {
		[module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE] = {
			{"11111111112X0211111100002X011100000002112222000210000000021022222000001111111111"},
			{"1111111111222221111100000X011101100002110X00001110000100021022212000001111111111"},
			{"1111111111222111X0110002000011000001021101110102100X0100021000011000001111111111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_NOTOP] = {
			{"1v000000v11vvv00vvv10X0v00vX0100000000012222000200000000021122222000001111111111"},
			{"1v000000v11vvv00vvv1000v00vX010vvv0000010X00002100000100011122212000001111111111"},
			{"1v000000v11vvv00vvv1000v00vX01000000000101110002000X0100021100011000001111111111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP_NOTOP] = {
			{"111v00v1112X0v00v111000v00v111000000v211111v00v2120X00000010000v00v000111v00v111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP] = {
			{"11111111112X0vvvv111000vX0v111000000021122220002120000000010222v00v000111v00v111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE] = {
			{"11111111111111112X02111X02000011200000000120002222012000000000000222221111111111"},
			{"11111111111111122222111X00000011200001100111000X00012000100000000212221111111111"},
			{"111111111111X01112221100002000112010000001201011100120001X0000000110001111111111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_NOTOP] = {
			{"1v000000v11vvv00vvv11X0v00vX0010000000000020002222112000000000000222221111111111"},
			{"1v000000v11vvv00vvv11X0v00v000100000vvv00012000X00111000100000000212221111111111"},
			{"1v000000v11vvv00vvv11X0v00v000100000000000200011101120001X0000000110001111111111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP_NOTOP] = {
			{"111v00v111111v00vX02111v00v000112v000000212v00v1110100000X00000v00v000111v00v111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP] = {
			{"1111111111111vvvvX02111vX0v000112000000021200022220100000000000v00v222111v00v111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK] = {
			{"1111111111111X0X000211100000011111100g010120001111012000000000000122221111111111"},
		},
		[module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP] = {
			{"1v000000v11vvv00vvv1X00000vX00000010000000g0102222111110000000000022221111111111"},
		},
	}
}

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	--1.) Select room coordinates between x = 1..3 and y = 2..3
	local room_l_x, room_l_y = math.random(1, levelw-1), math.random(2, levelh-1)
	local room_r_x, room_r_y = room_l_x+1, room_l_y

	--2.) Replace room at y and x coord with SPIDERLAIR_LEFTSIDE*
	local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_l_y][room_l_x]
	local path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE

	if unlockslib.LEVEL_UNLOCK ~= nil then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK
	end

	if path_to_replace == module.HD_SUBCHUNKID.PATH_NOTOP then
		if unlockslib.LEVEL_UNLOCK ~= nil then
			path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP
		else
			path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_NOTOP
		end
	elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP
	elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP_NOTOP
	end
	roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].rooms[path_to_replace_with], room_l_y, room_l_x)

	--3.) Replace room at y and x+1 coord with SPIDERLAIR_RIGHTSIDE*	
	path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_r_y][room_r_x]
	path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE
	if path_to_replace == module.HD_SUBCHUNKID.PATH_NOTOP then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_NOTOP
	elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP
	elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
		path_to_replace_with = module.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP_NOTOP
	end
	roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].rooms[path_to_replace_with], room_r_y, room_r_x)

end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT] = {
	rooms = {
		[module.HD_SUBCHUNKID.SNAKEPIT_TOP] = { -- grabs 4 and upwards from HD's path_drop roomcodes
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211200000002100000000000200000000000000000211120000211"},
			{"11111111111111112222211220000001200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
		},
		[module.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION] = {{"111000011111n0000n11111200211111n0000n11111200211111n0000n11111200211111n0000n11"}},
		[module.HD_SUBCHUNKID.SNAKEPIT_BOTTOM] = {{"111000011111n0000n1111100001111100N0001111N0110N11111NRRN1111111M111111111111111"}}
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].prePathMethod = function()
	roomgenlib.level_generation_method_structure_vertical(
		{
			subchunk_id = module.HD_SUBCHUNKID.SNAKEPIT_TOP,
			roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[module.HD_SUBCHUNKID.SNAKEPIT_TOP]
		},
		{
			middle = {
				subchunk_id = module.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[module.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = module.HD_SUBCHUNKID.SNAKEPIT_BOTTOM,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[module.HD_SUBCHUNKID.SNAKEPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		1
	)
	
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS] = {
	rooms = {
		[module.HD_SUBCHUNKID.RESTLESS_IDOL] = {
			{"tttttttttttttttttttttt00c000tt0tt0A00tt00400000040ttt0tt0ttttt000000tt1111111111"}
		},
		[module.HD_SUBCHUNKID.RESTLESS_TOMB] = {
			{
				"000000000000000000000000900000021t1t1200211t0t112011rtttr11011r111r11111rrrrr111",
				"0000000000000000000000000900000021t1t1200211t0t112011rtttr11111r111r11111rrrrr11",
			}
		},
	},
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].postPathMethod = function()
	state.level_flags = set_flag(state.level_flags, 8)
	if (
		state.level ~= 4
		and not feelingslib.hauntedcastle_spawned
	) then
		roomgenlib.level_generation_method_nonaligned(
			{
				subchunk_id = module.HD_SUBCHUNKID.RESTLESS_TOMB,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[module.HD_SUBCHUNKID.RESTLESS_TOMB]
			}
			,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
		)
		feelingslib.hauntedcastle_spawned = true
	end
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) == false then
		roomgenlib.level_generation_method_nonaligned(
			{
				subchunk_id = module.HD_SUBCHUNKID.RESTLESS_IDOL,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[module.HD_SUBCHUNKID.RESTLESS_IDOL]
			}
			,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
		)
	end
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.BLACKMARKET] = {
	chunkRules = {
		obstacleBlocks = {
			[module.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				local range_start, range_end = 1, 2 -- default
				if (math.random(8) == 8) then
					range_start, range_end = 3, 5
				end
				local chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		},
	},
	setRooms = {
		-- 1
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE_DROP,
			placement = {1, 1},
			roomcodes = {
				{
					"60000600000000000000000000000000000000000008000000000000000000000000000002112000",
					"11111111112222222222000000000000000000000008000000000000000000000000000002112000"
				}
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {1, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {1, 3},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP,
			placement = {1, 4},
			roomcodes = {
				{"12G000002100P111100000G222200000G000000000G000000000G000002200000002111111202111"},
				{"1200000G210001111P000002222G000000000G000000000G002200000G00112T0000001111202111"},
				{"12000000G160000011P000000000G000000000G0G0000000G0P1122000G0G0000000G011100001p1"},
				{"1200000G210001111P000002222G000000000G000000000G00000000000020000222221000111111"},
				{"12G000002100P111100000G222200000G000000000G0000000000000000022222000021111110001"},
				{"11111111111111111111120000002120000000020000000000022000022021120021121111001111"},
			}
		},
		
		-- 2
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {2, 1},
			roomcodes = {
				{"12G000002100P111100000G222200000G000000000G000000000G000002200000002111111202111"},
				{"1200000G210001111P000002222G000000000G000000000G002200000G00112T0000001111202111"},
				{"12000000G160000011P000000000G000000000G0G0000000G0P1122000G0G0000000G011100001p1"},
				{"1200000G210001111P000002222G000000000G000000000G00000000000020000222221000111111"},
				{"12G000002100P111100000G222200000G000000000G0000000000000000022222000021111110001"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {2, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {2, 3},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {2, 4},
			roomcodes = {
				{"12G000002100P111100000G222200000G000000000G00000000000000022001G000211111P011111"},
			}
		},

		-- 3
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {3, 1},
			roomcodes = {
				{"12G000002100P111100000G222200000G000000000G000000000G000002200000002111111202111"},
				{"1200000G210001111P000002222G000000000G000000000G002200000G00112T0000001111202111"},
				{"12000000G160000011P000000000G000000000G0G0000000G0P1122000G0G0000000G011100001p1"},
				{"1200000G210001111P000002222G000000000G000000000G00000000000020000222221000111111"},
				{"12G000002100P111100000G222200000G000000000G0000000000000000022222000021111110001"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {3, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.SHOP_PRIZE_LEFT,
			placement = {3, 3},
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.SHOP_PRIZE_LEFT])
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.BLACKMARKET_ANKH,
			placement = {3, 4},
			roomcodes = {{"000G011111000G000000000G0000l0000bbbbbbb0000000000111111111111111111111111111111"}}
			-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_NOTOP,
			placement = {4, 1},
			roomcodes = {
				{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
				{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
				{"00000000000000000000000000000050000500000000000000000000000011111111111111111111"},
				{"00000000000000000000000000000000000000000002222220001111111011111111111111111111"},
				{"00000000000000000000000000000000000000000000000221000002211100002211111111111111"},
				{"000000000000000000000000000000013wwww310013wwww310113wwww31111133331111111111111"},
				{"0000000000006000000000000000000000000000013wwww310113wwww31111133331111111111111"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH,
			placement = {4, 2},
			roomcodes = {
				{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
				{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
				{"60000600000000000000000000000050000500000000000000000000000011111111111111111111"},
				{"60000600000000000000000000000000000000000000000000000111110000111111001111111111"},
				{"1111111111V0000V000000000000000000000000000000000010000000011ssssssss11111111111"},
				{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
				{"000000000000000000000000000000013wwww310013wwww310113wwww31111133331111111111111"},
				{"0060000000000000000000000000000000000000013wwww310113wwww31111133331111111111111"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH,
			placement = {4, 3},
			roomcodes = {
				{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
				{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
				{"60000600000000000000000000000050000500000000000000000000000011111111111111111111"},
				{"60000600000000000000000000000000000000000000000000000111110000111111001111111111"},
				{"1111111111V0000V000000000000000000000000000000000010000000011ssssssss11111111111"},
				{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
				{"000000000000000000000000000000013wwww310013wwww310113wwww31111133331111111111111"},
				{"0060000000000000000000000000000000000000013wwww310113wwww31111133331111111111111"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.EXIT,
			placement = {4, 4},
			roomcodes = {
				{
					"60000600000000000000000000000000000000000008000000000000000000000000001111111111",
					"11111111112222222222000000000000000000000008000000000000000000000000001111111111",
				}
			}
		},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
}


module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE] = {
	chunkRules = {
		obstacleBlocks = {
			[module.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				local range_start, range_end = 1, 2 -- default
				if (math.random(8) == 8) then
					range_start, range_end = 3, 5
				end
				local chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		},
	},
	setRooms = {
		-- 1
		{
			subchunk_id = module.HD_SUBCHUNKID.HAUNTEDCASTLE_UNLOCK,
			placement = {1, 1},
			roomcodes = {
				-- # TODO: find out if this coffin-less room is supposed to be placed here. According to HD Toolbox, this never spawns, but I'm not so sure.
				-- {"00000000000t0t0t0t0ttttttttttttttttttttt000000000t000000000t0U00000000tttttttttt"},
				{"00000000000t0t0t0t0ttttttttttttttttttttt000400000tg00tt0000tttttU00000tttttttttt"}
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.HAUNTEDCASTLE_SETROOM_1_2,
			placement = {1, 2},
			roomcodes = {
				{"00000000000t0t0t0t0ttttttttttttttttttttt0000000000tttt00tttt0000000000tttttttttt"},
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.HAUNTEDCASTLE_SETROOM_1_3,
			placement = {1, 3},
			roomcodes = {{"00000000000t0t0t0t0ttttttttttttttttttttt0000000ttttttt000ttt00000N0ttttt000ttttt"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.ENTRANCE_DROP,
			placement = {1, 4},
			roomcodes = {
				{"00000000000000000000000000000000000000000008000000000000000000000000002021111120"},
				{"00000000000000000000000000000000000000000008000000000000000000000000000211111202"},
			}
		},
		
		-- 2
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {2, 1},
		-- 	roomcodes = {{""}}
		-- },
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {2, 2},
		-- 	roomcodes = {{""}}
		-- },
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {2, 3},
		-- 	roomcodes = {{""}}
		-- },
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {2, 4},
			roomcodes = {
				{"00G000000000P111100000G222200000G000000000G000000000G000002200000002111111202111"},
				{"0000000G000001111P000002222G000000000G000000000G002200000G00112T0000001111202111"},
				{"00000000G060000011P000000000G000000000G0G0000000G0P1122000G0G0000000G011100001p1"},
				{"0000000G000001111P000002222G000000000G000000000G00000000000020000222221000111111"},
				{"00G000000000P111100000G222200000G000000000G0000000000000000022222000021111110001"},
			}
		},

		-- 3
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {3, 1},
		-- 	roomcodes = {{""}}
		-- },
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {3, 2},
		-- 	roomcodes = {{""}}
		-- },
		-- {
		-- 	subchunk_id = -1,
		-- 	placement = {3, 3},
		-- 	roomcodes = {{""}}
		-- },
		{
			subchunk_id = module.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {3, 4},
			roomcodes = {
				{"00G000000000P111100000G222200000G000000000G000000000G000002200000002111111202111"},
				{"0000000G000001111P000002222G000000000G000000000G002200000G00112T0000001111202111"},
				{"00000000G060000011P000000000G000000000G0G0000000G0P1122000G0G0000000G011100001p1"},
				{"0000000G000001111P000002222G000000000G000000000G00000000000020000222221000111111"},
				{"00G000000000P111100000G222200000G000000000G0000000000000000022222000021111110001"},
			}
		},

		-- 4
		-- {
		-- 	subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT,
		-- 	placement = {4, 1},
		-- 	roomcodes = {{"00000000000000000000000000000000000000000000h000000900000000rrrttttrrr1111111111"}}
		-- },
		-- {
		-- 	subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM,
		-- 	placement = {4, 2},
		-- 	roomcodes = {
		-- 		{"0000000000tt000000tt000000000000000000000000tt00000000tt0000rrrrttrrrr1111111111"},
		-- 		{"0000000000tt000000000000000000000000000000000000tt0000rrrrttrrrrrrrrtt1111111111"},
		-- 		{"000000000000000000tt00000000000000000000tt00000000ttrrrr0000ttrrrrrrrr1111111111"},
		-- 		{"000000000000000000tt000000000000000000000000000000000T000000rrrrrrrrrr1111111111"},
		-- 		{"0000000000tt00000000000000000000000000000000000000000000T000rrrrrrrrrr1111111111"},
		-- 	}
		-- },
		-- {
		-- 	subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE,
		-- 	placement = {4, 3},
		-- 	roomcodes = {{"0000000ttt0000000ttt0000000ttD0000000ttD00000000000000000N00rrrrrrrrrr1111111111"}}
		-- },
		{
			subchunk_id = module.HD_SUBCHUNKID.HAUNTEDCASTLE_MOAT,
			placement = {4, 4},
			roomcodes = {{"000000000000000000000000000000000000000000000000000000000T00wwwww11111wwwww11111"}}
		},
	},
	rooms = {
		-- [genlib.HD_SUBCHUNKID.ENTRANCE] = { -- never happends
		-- 	{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
		-- },
		-- [genlib.HD_SUBCHUNKID.PATH] = { -- never happends
		-- 	{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
		-- 	{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
		-- 	{"60000600000000000000000000000050000500000000000000000000000011111111111111111111"},
		-- 	{"60000600000000000000000000000000000000000000000000000111110000111111001111111111"},
		-- 	{"1111111111V0000V000000000000000000000000000000000010000000011ssssssss11111111111"},
		-- 	{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
		-- 	{"000000000000000000000000000000013wwww310013wwww310113wwww31111133331111111111111"},
		-- 	{"0060000000000000000000000000000000000000013wwww310113wwww31111133331111111111111"},
		-- },
		-- [genlib.HD_SUBCHUNKID.PATH_NOTOP] = { -- never happends
		-- 	{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
		-- 	{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
		-- 	{"00000000000000000000000000000050000500000000000000000000000011111111111111111111"},
		-- 	{"00000000000000000000000000000000000000000002222220001111111011111111111111111111"},
		-- 	{"00000000000000000000000000000000000000000000000221000002211100002211111111111111"},
		-- 	{"000000000000000000000000000000013wwww310013wwww310113wwww31111133331111111111111"},
		-- 	{"0000000000006000000000000000000000000000013wwww310113wwww31111133331111111111111"},
		-- },
		-- [genlib.HD_SUBCHUNKID.PATH_DROP] = { -- never happends
		-- 	{"11111111111111111111120000002120000000020000000000022000022021120021121111001111"},
		-- },
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE] = { -- basically "Castle Middle (notop/path/side)"
			{"0000000000000t000G00000ttttPtt0000000G000000000G00ttt0000G00ttttt00G00tttttttttt"},
			{"000000000000G000t000ttPtttt00000G000000000G000000000G0000ttt00G00ttttttttttttttt"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE_DROP] = { -- basically "Castle Middle drop"
			{"000G00G000tttPttPttt000G00G000000G00G000000tttt0000000000000tt000000ttttt0000ttt"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM] = { -- "Castle Bottom notop"
			{"0000000000tt000000tt000000000000000000000000tt00000000tt0000rrrrttrrrr1111111111"},
			{"0000000000tt000000000000000000000000000000000000tt0000rrrrttrrrrrrrrtt1111111111"},
			{"000000000000000000tt00000000000000000000tt00000000ttrrrr0000ttrrrrrrrr1111111111"},
			{"000000000000000000tt000000000000000000000000000000000T000000rrrrrrrrrr1111111111"},
			{"0000000000tt00000000000000000000000000000000000000000000T000rrrrrrrrrr1111111111"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM_NOTOP] = { -- "Castle Bottom notop"
			{"0000GG0000ttttPPtttt0000GG00000000GG00000000GG00000000GG0000rrrrrrrrrr1111111111"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL] = { -- "Castle Bottom Rightside"
			{"0000G00ttt000tG00tttttttPttttt0000G002tt0000G00ttt0000G00ttt0000G00ttttttttttttt"},
			{"0000G00ttt0000Pttttt0000G0tttt0000G002tt0000G00ttt000ttttttt0ttttttttttttttttttt"},
			-- {"0000000ttt00tt000ttt000000tttt00000002tt000ttttttt0000000ttttt000002tttttttttttt"}, -- unused
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP] = { -- "Castle Bottom Rightside drop"
			{"0000000ttt00000ttttt000000tttt0ttt0002tt00t0000ttt000000tttt000000tttttt0000tttt"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE] = { -- "Castle Bottom Rightside drop"
			{"0000000ttt0000000ttD0000000tt00000000tt000000000000000000N00rrrrrrrrrr1111111111"}, -- modified from original for sliding doors
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE_NOTOP] = {
			{"0000000ttt0000tttttD0000000tt0000tttttt0t000000000t000N00N00trrrrrrrrr1111111111"}, -- modified from original for sliding doors
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT] = {
			{"00000000000000000000000000000000000000000000h000000900000000rrrttttrrr1111111111"},
		},
		[module.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP] = {
			{"0G00000000tPtt00tt000G000000000G000000000G00h000000G00000090rrrttttrrr1111111111"},
		},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = { -- never happends, but this IS different from regular jungle. Keep just in case.
			{"000000000022222"},
			{"000002222211111"},
			{"00000000000T022"},
			{"000000000020T02"},
			{"0000000000220T0"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000ttt011111"},
		},
	},
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].postPathMethod = function()
	state.level_flags = set_flag(state.level_flags, 8)
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	local minw, minh, maxw, maxh = 1, 2, levelw-1, levelh

	local assigned_exit = false
	local assigned_entrance = false
	local wi, hi = maxw, minh
	local dropping = false
	
	
	while assigned_exit == false do
		local pathid = math.random(2)
		local ind_off_x, ind_off_y = 0, 0

		if pathid == module.HD_SUBCHUNKID.PATH then
			local dir = 0
			if roomgenlib.detect_sideblocked_both(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
				pathid = module.HD_SUBCHUNKID.PATH_DROP
			elseif roomgenlib.detect_sideblocked_neither(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
				dir = (math.random(2) == 2) and 1 or -1
			else
				if roomgenlib.detect_sideblocked_right(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = -1
				elseif roomgenlib.detect_sideblocked_left(roomgenlib.global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = 1
				end
			end
			ind_off_x = dir
		end
		if pathid == module.HD_SUBCHUNKID.PATH and dropping == true then
			pathid = module.HD_SUBCHUNKID.PATH_NOTOP
			dropping = false
		end
		if pathid == module.HD_SUBCHUNKID.PATH_DROP then
			ind_off_y = 1
			if dropping == true then
				pathid = module.HD_SUBCHUNKID.PATH_DROP_NOTOP
			end
			dropping = true
		end

		if assigned_entrance == false then
			if pathid == module.HD_SUBCHUNKID.PATH_DROP then
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP
			else
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
			end
			assigned_entrance = true
		elseif hi == maxh then
			if wi == minw then
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP
			elseif wi == maxw then
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE_NOTOP
			else
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM_NOTOP
			end
			assigned_exit = true
		-- replace path with appropriate haunted castle path
		elseif wi == maxw then
			if pathid == module.HD_SUBCHUNKID.PATH or pathid == module.HD_SUBCHUNKID.PATH_NOTOP then
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
			else
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP
			end
		else
			if pathid == module.HD_SUBCHUNKID.PATH or pathid == module.HD_SUBCHUNKID.PATH_NOTOP then
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE
			else
				pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE_DROP
			end
		end

		roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] = pathid
		roomgenlib.levelcode_inject_roomcode(pathid, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].rooms[pathid], hi, wi)

		if assigned_exit == false then -- preserve final coordinates for bugtesting purposes
			wi, hi = (wi+ind_off_x), (hi+ind_off_y)
		end
	end

	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			if roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] == nil then
				local pathid
				if hi == maxh then
					if wi == minw then
						pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT
					elseif wi == maxw then
						pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE
					else
						pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM
					end
				elseif wi == maxw then
					pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
				else
					pathid = module.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE
				end
				roomgenlib.levelcode_inject_roomcode(pathid, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].rooms[pathid], hi, wi)
			end
		end
	end

end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE] = {
	rooms = {
		-- Replaced all "d" tiles with "v"
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH] = {
			{
				"0000:0000000vvvvv00000v000v0000G00:00Gv0vPv===vPv0vG00000Gv00G00:00G00v=======v1",
				"00000:0000000vvvvv00000v000v000vG00:00G00vPv===vPv0vG00000Gv00G00:00G01v=======v"
			},
			{"00000000000000:0000000vvvv000000v+0v00000vv0vv0000000:0100001vv=v110T01111111111"},
			{"000000000000000:00000000vvvv000000v0+v000000vv0vv0000010:0000T011v=vv11111111111"},
		},
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP] = {
			{"111111111111v1111v1112v0000v210000:0000000v====v0000000000002q120021121111001111"},
			{"111111111111v1111v1112v0000v210000:0000000v====v00000000000021120021q21111001111"},
		},

		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP] = {
			{"00000000000000000000000000t0t00vvvvvt0t00v0000t0t000:0000it00v====ttt01111111111"},
			{"000000000000000000000t0t0000000t0tvvvvv00t0t0000v00ti0000:000ttt====v01111111111"},
		},
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT] = {
			{"1200000000vvvvv00000v000vv0000v0:00000001===vvv00011++00v00011110:00001111==v111"},
		},
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT] = {
			{"000000002100000vvvvv0000vv000v0000000:0v000vv====1000v00++110000:01111111v==1111"},
		},

		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP] = {
			{"000000000000vvvvvv0000v0+00v000000G:000000v=P==v0000v0G00v002qv2G02v121111G01111"},
			{"000000000000vvvvvv0000v00+0v000000:G000000v==P=v0000v00G0v002qv20G2v1211110G1111"},
		},
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT] = {
			{"12000000001v0vvvv0001v00+0v0001vv:G000001v==P==0001112G000001120G010001111G01111"},
		},
		[module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT] = {
			{"0000000021000vvvvvv1000v0+00v100000G:vv1000v=P===100000G211100010G021101110G1111"},
		},
		
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {
			{
				"11110011111111001111v00v00v00v0g00000::0v==v00v==v002100120000210012001111001111",
				"11110011111111001111v00v00v00v0::0000g00v==v00v==v002100120000210012001111001111",
			}
		},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {
			{
				"11110011111111001111v00v00v00v0g00000::0v==v00v==v002100120000210012001111001111",
				"11110011111111001111v00v00v00v0::0000g00v==v00v==v002100120000210012001111001111",
			}
		},
	},
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	local levelh_start, levelh_end = 2, levelh-1
	local levelw_start, levelw_end = 1, levelw

	if unlockslib.LEVEL_UNLOCK ~= nil then
		local spots = {}
		-- build a collection of potential spots
		for room_y = levelh_start, levelh_end, 1 do
			for room_x = levelw_start, levelw_end, 1 do
				local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[room_y][room_x]
				if (
					(subchunk_id == module.HD_SUBCHUNKID.PATH_DROP or subchunk_id == module.HD_SUBCHUNKID.PATH_DROP_NOTOP)
				) then
					table.insert(spots, {x = room_x, y = room_y, subchunk_id = subchunk_id})
				end
			end
		end

		-- pick random place to fill
		local spot = spots[math.random(#spots)]
		local path_to_replace_with = nil
		if (
			spot ~= nil
			and spot.subchunk_id ~= nil
		) then
			if spot.subchunk_id == module.HD_SUBCHUNKID.PATH_DROP then
				path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP
			elseif spot.subchunk_id == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
				path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP
			end
		end

		if path_to_replace_with ~= nil then
			roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].rooms[path_to_replace_with], spot.y, spot.x)
		end
	end
	
	for room_y = levelh_start, levelh_end, 1 do
		for room_x = levelw_start, levelw_end, 1 do
			local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_y][room_x]
			local path_to_replace_with = -1
			
			-- drop/drop_notop
			if (
				(path_to_replace == module.HD_SUBCHUNKID.PATH_DROP or path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP) and
				-- don't replace path_drop or path_drop_notop when room_y == 1
				-- (room_y ~= 1) and
				-- 2/5 chance not to replace path_drop or path_drop_notop
				(math.random(5) > 3)
			) then
				if path_to_replace == module.HD_SUBCHUNKID.PATH_DROP then
					path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP
				elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
					if (room_y == 2 or room_y == 3) and (room_x == 1) then
						path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT
					elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
						path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT
					else
						path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP
					end
				end
			end
		
			-- notop
			if (
				(path_to_replace == module.HD_SUBCHUNKID.PATH_NOTOP) and
				math.random(5) < 5 -- 1/5 chance not to replace path_notop
			) then
				if (room_y == 2 or room_y == 3) and (room_x == 1) then
					path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT
				elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
					path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT
				else
					path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP
				end
			end
		
			-- path
			if (
				(path_to_replace == module.HD_SUBCHUNKID.PATH)
			) then
				path_to_replace_with = module.HD_SUBCHUNKID.TIKIVILLAGE_PATH
			end
		
			if path_to_replace_with ~= -1 then
				roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].rooms[path_to_replace_with], room_y, room_x)
			end
		end
	end


end



module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER] = {
	rooms = {
		[module.HD_SUBCHUNKID.RUSHING_WATER_EXIT] = {{"000000000000000900000221111220wwvvvvvvwwwwwwwwwwww000000000000000000000000000000"}},--"000000000000000900000221111220wwvvvvvvwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"}},
		[module.HD_SUBCHUNKID.RUSHING_WATER_SIDE] = {
			--[[ ORIGINAL (not impostorlake-adjusted)
				{"000000000000000000000001111000w,,vvvv,,wwwww,,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000001200000000vvwwwwwwww,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000000000021wwwwwwwwvvwwwwwwwww,wwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000000000000wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000001111000w,,vvvv,,wwww,vv,wwwwwwwvvwwwwwwww,,wwwwwwwwwwwwww"},
				{"000022000000021120000001111000w,,vvvv,,wwww,vv,wwwwwwwvvwwwwwwww,,wwwwwwwwwwwwww"},
				{"600006000000000000000000000000wwwvvvvwwwwwww,,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000022000000021120000221111220www,,,,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
			--]]
			{"000000000000000000000001111000w,,vvvv,,wwwww,,wwww000000000000000000000000000000"},
			{"000000000000000000001200000000vvwwwwwwww,wwwwwwwww000000000000000000000000000000"},
			{"000000000000000000000000000021wwwwwwwwvvwwwwwwwww,000000000000000000000000000000"},
			{"000000000000000000000000000000wwwwwwwwwwwwwwwwwwww000000000000000000000000000000"},
			{"000000000000000000000001111000w,,vvvv,,wwww,vv,www0000vv00000000,,00000000000000"},
			{"000022000000021120000001111000w,,vvvv,,wwww,vv,www0000vv00000000,,00000000000000"},
			{"600006000000000000000000000000wwwvvvvwwwwwww,,wwww000000000000000000000000000000"},
			{"000022000000021120000221111220www,,,,wwwwwwwwwwwww000000000000000000000000000000"},
		},
		[module.HD_SUBCHUNKID.RUSHING_WATER_PATH] = {
			--[[ ORIGINAL (not impostorlake-adjusted)
				{"000000000000000000000001111000w,,vvvv,,wwwww,,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000001200000000vvwwwwwwww,wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000000000021wwwwwwwwvvwwwwwwwww,wwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000000000000wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"},
				{"000000000000000000000001111000w,,vvvv,,wwww,vv,wwwwwwwvvwwwwwwww,,wwwwwwwwwwwwww"},
			--]]

			{"000000000000000000000001111000w,,vvvv,,wwwww,,wwww000000000000000000000000000000"},
			{"000000000000000000001200000000vvwwwwwwww,wwwwwwwww000000000000000000000000000000"},
			{"000000000000000000000000000021wwwwwwwwvvwwwwwwwww,000000000000000000000000000000"},
			{"000000000000000000000000000000wwwwwwwwwwwwwwwwwwww000000000000000000000000000000"},
			{"000000000000000000000001111000w,,vvvv,,wwww,vv,www0000vv00000000,,00000000000000"},
		},

		[module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE] = {{"00000000000000000000000000000,00000000000,,000000000,,00000000,,,,,,,,,00,,,,,,,"}},
		[module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE] = {{"0000000000,000000000,,00000000,000000000,0000000,0,g0EEE0,,0,,,,,,,,,0,,,,,,,,00"}},
		[module.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY] = {{"0000000000000000000000000000000000000000000J00000000000000000000000000,,,,,,,,,,"}},
		[module.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM] = {
			{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"},
			{"0000000000000000000000000000000000000000000000000000000000000000000000,,EE,,EE,,"},
			{"0000000000000000000000000000000000000000,,000000,,00000000000000000000,,EE,,EE,,"},
			{"0000000000000000000000000000000000000000,v,000000000,,0000000E,,vvvv00,,,,,,,,vv"},
			{"00000000000000000000000000000000000000000000000,v,000000,v00000000,v,00,,,,,,v,,"},
			{"000000000000000000000000vv0000000v,,v000000,,,,000000E,,E000v0v,,,,v0v,E,,,,,,E,"},
			{"000000000000000000000000000000000,,,,00000,,v,,,000,,v0vv,,00v0000E,,,,,vvvv,,,,"},
			{"000000000000000000000000000000000,,,,00000,,,v,,000,,vv0v,,0,,,E0000v0,,,,vvvv,,"},
		},
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	-- exit row
	for room_x = 1, levelw, 1 do
		local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[levelh][room_x]
		local path_to_replace_with = -1
		
		-- path
		if path_to_replace == module.HD_SUBCHUNKID.PATH or path_to_replace == nil then
			path_to_replace_with = module.HD_SUBCHUNKID.RUSHING_WATER_SIDE
		end
	
		-- path_notop
		if path_to_replace == module.HD_SUBCHUNKID.PATH or path_to_replace == module.HD_SUBCHUNKID.PATH_NOTOP then
			path_to_replace_with = module.HD_SUBCHUNKID.RUSHING_WATER_PATH
		end
	
		-- exit
		if (path_to_replace == module.HD_SUBCHUNKID.EXIT or path_to_replace == module.HD_SUBCHUNKID.EXIT_NOTOP) then
			path_to_replace_with = module.HD_SUBCHUNKID.RUSHING_WATER_EXIT
		end
	
		if path_to_replace_with ~= -1 then
			roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[path_to_replace_with], levelh, room_x)
		end
	end
	local struct_x_pool = {1, 2, 3, 4}
	if unlockslib.LEVEL_UNLOCK ~= nil then
		struct_x_pool = {1, 4}

		roomgenlib.levelcode_inject_roomcode_rowfive(
			module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE,
			module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE],
			2
		)
		roomgenlib.levelcode_inject_roomcode_rowfive(
			module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE,
			module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[module.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE],
			3
		)
	end
	
	roomgenlib.levelcode_inject_roomcode_rowfive(
		module.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY,
		module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[module.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY],
		struct_x_pool[math.random(1, #struct_x_pool)]
	)
	-- inject rushing water side rooms
	for xi = 1, levelw, 1 do
		if roomgenlib.global_levelassembly.modification.rowfive.levelrooms[xi] == nil then
			roomgenlib.levelcode_inject_roomcode_rowfive(
				module.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM,
				module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[module.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM],
				xi
			)
		end
	end
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI] = {
	rooms = {
		[module.HD_SUBCHUNKID.MOAI] = {
			{
				"000000000000000O000000000000000000000000021110002002111mmm2000111111000000000000",
				"000000000000O000000000000000000000000000020001112002mmm1112000111111000000000000",
			}
		}
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	local spots = {}
		--{x, y}
	local minw, minh, maxw, maxh = 1, 2, levelw, levelh-1
	-- build a collection of potential spots
	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[hi][wi]
			if (
				(
					subchunk_id == nil and
					(
						(
							wi+1 <= maxw and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] <= 8
							)
						) or (
							wi-1 >= 1 and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] <= 8
							)
						)
					)
				) or (
					subchunk_id ~= nil and
					(subchunk_id >= 1) and (subchunk_id <= 4)
				)
			) then
				table.insert(spots, {x = wi, y = hi})
			end
		end
	end

	-- pick random place to fill
	local spot = spots[math.random(#spots)]

	roomgenlib.levelcode_inject_roomcode(
		module.HD_SUBCHUNKID.MOAI,
		module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI].rooms[module.HD_SUBCHUNKID.MOAI],
		spot.y, spot.x
	)
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO] = {
	rooms = {
		[module.HD_SUBCHUNKID.UFO_LEFTSIDE] = {
			{"0000000000000+++++++0+++0000000+000000000+000000000++000000000++++++++0000000000"}
		},
		[module.HD_SUBCHUNKID.UFO_MIDDLE] = {
			{"0000000000++++++++++0000000000000000000000000000000000000000++++++++++0000000000"}
		},
		[module.HD_SUBCHUNKID.UFO_RIGHTSIDE] = {
			{"0022122111++)))+11110+00002211000000X01100000000M10+00021111++;001+1110000222221"}
		},
	},
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	local minw, minh, maxw, maxh = 1, 1, levelw, levelh

	local drop_detected = false
	for room_x = 1, levelw, 1 do
		if roomgenlib.global_levelassembly.modification.levelrooms[minh+1][room_x] == 3 then
			drop_detected = true
		end
	end

	local wi, hi = maxw, minh+(drop_detected and 1 or 2)

	roomgenlib.levelcode_inject_roomcode(module.HD_SUBCHUNKID.UFO_RIGHTSIDE, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[module.HD_SUBCHUNKID.UFO_RIGHTSIDE], hi, wi)
	local _mid_width_min = 0
	local mid_width = math.random(_mid_width_min, maxw-2)
	for i = maxw-1, maxw-mid_width, -1 do
		roomgenlib.levelcode_inject_roomcode(module.HD_SUBCHUNKID.UFO_MIDDLE, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[module.HD_SUBCHUNKID.UFO_MIDDLE], hi, i)
	end
	roomgenlib.levelcode_inject_roomcode(module.HD_SUBCHUNKID.UFO_LEFTSIDE, module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[module.HD_SUBCHUNKID.UFO_LEFTSIDE], hi, maxw-mid_width-1)

	-- 	module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_LEFTSIDE]
	-- 	module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_MIDDLE]
	-- 	module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_RIGHTSIDE]
end
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (
					module.CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					module.CHUNKBOOL_ALTAR = true
					return {altar = true}
				end
				
				return {index = math.random(2)}
			end,
			[module.HD_SUBCHUNKID.PATH] = function() return math.random(9) end,
			[module.HD_SUBCHUNKID.PATH_DROP] = function() return math.random(12) end,
			-- [genlib.HD_SUBCHUNKID.PATH_NOTOP] = function() return math.random(9) end,
			[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = function() return math.random(8) end,
		},
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{"000000000011------11120000002112002200211200000021120022002111ssssss111111111111"},
		},
		[module.HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000000050000000000000000000000000011111111111111111111"},
			{"60000600000000000000000600000000000000000000000000000222220000111111001111111111"},
			{"11111111112222222222000000000000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112022222222000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112211111111221111111120111111110022222222000000000001111111111"},
			{"6000060000000000000000000000000000000000000000000000000000000000000000----------"},
			{"6000060000000000000000000000000000000000000000000001------1021ssssss121111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001202111111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211100000002110000000000200000000000000000211120000211"},
			{"11111111111111112222111220000011200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000050000500000000000000000000000011111111111111111111"},
			{"00000000000000000000000600000000000000000000000000000111110000111111001111111111"},
			{"00000000000111111110001111110000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{"10000000011112002111111200211100000000000022222000111111111111111111111111111111"},
			{"0000000000600006000000000000000000000000000000000000000000000000000000----------"},
			{"0000000000600006000000000000000000000000000000000001------1021ssssss121111111111"}
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001202111111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000000000111000"},
			{"11111111112222222222000000000000000000000008000000000000000000000000000000111000"},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
		},
		[module.HD_SUBCHUNKID.ALTAR] = {
			{"220000002200000000000000000000000000000000000000000000x00000022qqqq2201111111111"}
		},
		[module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING] = {
			{"iiiiiiiiiijiiiiiiiij0jjjjjjjj0000000000000000000000000Y0000000::00::00iiiiiiiiii"}
		},
		[module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_NOTOP] = {
			{"ii000000iijiii00iiij0jj0000jj0000000000000000000000000Y0000000::00::00iiiiiiiiii"}
		},
		[module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_DROP] = {
			{"iiiiiiiiiijiiiiiiiij0jjjjjjjj0000000000000000000000000Y0000000::00::00iii----iii"}
		},
		[module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_DROP_NOTOP] = {
			{"ii000000iijiii00iiij0jj0000jj0000000000000000000000000Y0000000::00::00iii----iii"}
		},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"0:::000000i-----i000i00000i000ig0000ii00i--0001i00i0000011i01sssss11101111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"000000:::0000i-----i000i00000i00ii000g0i00i1000--i0i1100000i0111sssss11111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"11111111112111111112022222222000000000000000g00000000011000002200002201111001111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"0000000000000000000022000000220000g000000000110000000000000002100001201111001111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"11111111112111111112022222222000000000000000g00000000011000002200002201111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"0000000000000000000022000000220000g000000000110000000000000002100001201111001111"}},
	},
	rowfive = {
		setRooms = {
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 1,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 2,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 3,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 4,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
		}
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"111110000000000"},
			{"000001111000000"},
			{"000000111100000"},
			{"000000000011111"},
			{"000002020017177"},
			{"000000202071717"},
			{"000000020277171"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000222021112"},
			{"000002010077117"},
			{"000000010271177"},
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"022220000022220"},
			{"222200000002222"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000111000000"},
			{"000000111002220"},
			{"000000222001110"},
			{"000000022001111"},
			{"000002220011100"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	if unlockslib.LEVEL_UNLOCK ~= nil then
		roomgenlib.level_generation_method_aligned(
			{
				left = {
					subchunk_id = module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end

	local spots = {}
		--{x, y, subchunk_id}
	local minw, minh, maxw, maxh = 1, 2, levelw, levelh-1
	-- build a collection of potential spots
	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[hi][wi]
			if (
				(
					subchunk_id == nil and
					(
						(
							wi+1 <= maxw and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi+1] <= 8
							)
						) or (
							wi-1 >= 1 and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[hi][wi-1] <= 8
							)
						)
					)
				) or (
					subchunk_id ~= nil and
					(subchunk_id >= 1) and (subchunk_id <= 4)
				)
			) then
				table.insert(spots, {x = wi, y = hi, subchunk_id = subchunk_id})
			end
		end
	end

	-- pick random place to fill
	local spot = spots[math.random(#spots)]
	local subchunk_id_yeti = module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING
	if spot.subchunk_id ~= nil then
		if spot.subchunk_id == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
			subchunk_id_yeti = module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_DROP_NOTOP
		elseif spot.subchunk_id == module.HD_SUBCHUNKID.PATH_DROP then
			subchunk_id_yeti = module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_DROP
		elseif spot.subchunk_id == module.HD_SUBCHUNKID.PATH_NOTOP then
			subchunk_id_yeti = module.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_NOTOP
		end
	end
	roomgenlib.levelcode_inject_roomcode(
		subchunk_id_yeti,
		module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[subchunk_id_yeti],
		spot.y, spot.x
	)
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE] = {
	rooms = {
		[module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP] = {
			{
				"++++++++++++000000++++090000++++++00++++++++00++++++++00++++++++00++++++++00++++",
				"++++++++++++000000++++000090++++++00++++++++00++++++++00++++++++00++++++++00++++",
			}
		},
		[module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM] = {{"++++00++++++++00++++++++00++++++++00++++++000000++0+++00+++000++00++000000000000"}}
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].prePathMethod = function()
	roomgenlib.level_generation_method_structure_vertical(
		{
			subchunk_id = module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP,
			roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].rooms[module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP]
		},
		{
			bottom = {
				subchunk_id = module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].rooms[module.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM]
			}
		},
		{1, 4}
		-- ,0
	)
end
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT] = {
	rooms = {
		[module.HD_SUBCHUNKID.SACRIFICIALPIT_TOP] = {{"0000000000000000000000000000000000000000000100100000110011000111;01110111BBBB111"}},
		[module.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION] = {{"11200002111120000211112000021111200002111120000211112000021111200002111120000211"}},
		[module.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM] = {{"112000021111200002111120000211113wwww311113wwww311113wwww31111yyyyyy111111111111"}}
	}
}

-- Notes:
	-- start from top
	-- seems to always be top to bottom
-- Spawn steps:
	-- 116
		-- levelw, levelh = get_levelsize()
		-- structx = math.random(1, levelw)
		-- spawn 116 at 1, structx
	-- 117
		-- _, levelh = get_levelsize()
		-- struct_midheight = levelh-2
		-- for i = 1, struct_midheight, 1 do
			-- spawn 117 at i, structx
		-- end
	-- 118
		-- spawn 118 at structx, struct_midheight+1
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].prePathMethod = function()
	roomgenlib.level_generation_method_structure_vertical(
		{
			subchunk_id = module.HD_SUBCHUNKID.SACRIFICIALPIT_TOP,
			roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[module.HD_SUBCHUNKID.SACRIFICIALPIT_TOP]
		},
		{
			middle = {
				subchunk_id = module.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[module.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = module.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[module.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		2
	)
end

module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD] = {
	rooms = {
		[module.HD_SUBCHUNKID.VLAD_TOP] = {{"0000hh000000shhhhs000shhhhhhs00hhhU0hhh0shh0000hhshhhh00hhhhhhQ0000Qhhhh000000hh"}},
		[module.HD_SUBCHUNKID.VLAD_MIDSECTION] = {{
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhhh00000hhhhQ0hhhhhhhh0qhhhhhh",
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhh00000hhhhhhhhh0Qhhhhhhhhq0hh"
		}},
		[module.HD_SUBCHUNKID.VLAD_BOTTOM] = {{"hh0L00L0hhhhhL00Lhhh040L00L040hhhL00Lhhhhh0L00L0hh040ssss040hhshhhhshhhhhhhhhhhh"}},
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].prePathMethod = function()
	roomgenlib.level_generation_method_structure_vertical(
		{
			subchunk_id = module.HD_SUBCHUNKID.VLAD_TOP,
			roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[module.HD_SUBCHUNKID.VLAD_TOP]
		},
		{
			middle = {
				subchunk_id = module.HD_SUBCHUNKID.VLAD_MIDSECTION,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[module.HD_SUBCHUNKID.VLAD_MIDSECTION]
			},
			bottom = {
				subchunk_id = module.HD_SUBCHUNKID.VLAD_BOTTOM,
				roomcodes = module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[module.HD_SUBCHUNKID.VLAD_BOTTOM]
			}
		},
		{1, 4},
		2
	)
end
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL] = {
	rooms = {
		[module.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE] = {{"000000000021------1221wwwwww12213wwww312013wwww310011333311002111111200022222200"}},
		[module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP] = {{"000000000021------1221wwwwww12213wwww312213wwww312213wwww312213wwww312213wwww312"}},
		[module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM] = {{"213wwww312213wwww312213wwww312213wwww312013wwww310011333311002111111200022222200"}},
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

	local spots = {}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	local spot = commonlib.TableCopyRandomElement(spots)
	
	if (
		math.random(4) <= 3
		and (
			spot.y <= levelh - 1
			and roomgenlib.global_levelassembly.modification.levelrooms[spot.y+1][spot.x] == nil
		)
	) then
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP,
			module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP],
			spot.y, spot.x
		)
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM,
			module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[module.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM],
			spot.y+1, spot.x
		)
	else
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE,
			module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[module.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE],
			spot.y, spot.x
		)
	end

end


module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA] = {
	rooms = {
		[module.HD_SUBCHUNKID.YAMA_LEFTSIDE] = {
			{"0000000000000070000000021207000000Q00120070000000021000000000Q000212000000000000"},
			{"00000000000000070000007021200002100Q00000000000070000000001202120000Q00000000000"},
			{"00000070000700001200010000L0000Q0020L000000000L000007000L020001200L0000000000000"},
			{"00070000000021000070000L000010000L0200Q0000L000000020L000700000L0021000000000000"},
			{"0000000000200000070000000001000010000L0000Q0020L001000000L0020007000000000100000"},
			{"00000000000070000002001000000000L000010000L0200Q0000L000000700000700010000010000"},
		},
		[module.HD_SUBCHUNKID.YAMA_RIGHTSIDE] = {
			{"0000000000000070000000021207000000Q00120070000000021000000000Q000212000000000000"},
			{"00000000000000070000007021200002100Q00000000000070000000001202120000Q00000000000"},
			{"00000070000700001200010000L0000Q0020L000000000L000007000L020001200L0000000000000"},
			{"00070000000021000070000L000010000L0200Q0000L000000020L000700000L0021000000000000"},
			{"0000000000200000070000000001000010000L0000Q0020L001000000L0020007000000000100000"},
			{"00000000000070000002001000000000L000010000L0200Q0000L000000700000700010000010000"},
		},
	}
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].setRooms = {
	-- 1
	-- {
	-- 	subchunk_id = genlib.HD_SUBCHUNKID.YAMA_TOP,
	-- 	placement = {1, 1},
	-- 	roomcodes = {{"0000Q000L000000000L0CCC00000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}}
	-- 	-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	-- },
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_1_2,
		placement = {1, 2},
		roomcodes = {{"0L00L0L0000L00L0L0000L00L000000000L000000000L000000000000Y0000000000000000000000"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_1_3,
		placement = {1, 3},
		roomcodes = {{"000L0L00L0000L0L00L000000L00L000000L000000000L0000000000000000000000000000000000"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	-- {
	-- 	subchunk_id = genlib.HD_SUBCHUNKID.YAMA_TOP,
	-- 	placement = {1, 4},
	-- 	roomcodes = {{"0L000Q00000L000000000L00000CCC0L0h00hhhh000h00hhhh000h00hhhh000h00hhhh0000000000"}}
	-- 	-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	-- },
	
	-- 2
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_LEFTSIDE,
		placement = {2, 1},
		roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[module.HD_SUBCHUNKID.YAMA_LEFTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_2_2,
		placement = {2, 2},
		roomcodes = {{"00000000000000000000000000000000000000000000000hhh0000000hyy0000000hyy0000000hyy"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_2_3,
		placement = {2, 3},
		roomcodes = {{"0000000000000000000000000000000000000000hhh0000000yyh0000000yyh0000000yyh0000000"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_RIGHTSIDE,
		placement = {2, 4},
		roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[module.HD_SUBCHUNKID.YAMA_RIGHTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},

	-- 3
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_LEFTSIDE,
		placement = {3, 1},
		roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[module.HD_SUBCHUNKID.YAMA_LEFTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_3_2,
		placement = {3, 2},
		roomcodes = {
			{
				"0000000hyy0000200hyy0000000hyy0000000hyy0020000hyy0000000hyy000000Ihyy000200hhyy",
				"0000000hyy0000100hyy0000200hyy0100000hyy0200000hyy0000100hyy000020Ihyy000000hhyy"
			}
		}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_3_3,
		placement = {3, 3},
		roomcodes = {
			{
			  "yyh0000000yyh0020000yyh0000000yyh0000000yyh0000200yyh0000000yyh0000000yyhh020000",
			  "yyh0000000yyh0010000yyh0020000yyh0000010yyh0000020yyh0010000yyh0020000yyhh000000"
			}
		}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_RIGHTSIDE,
		placement = {3, 4},
		roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[module.HD_SUBCHUNKID.YAMA_RIGHTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},

	-- 4
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_4_1,
		placement = {4, 1},
		roomcodes = {{"00000000000000000000000000000000000X00000&00qqq000000qqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_ENTRANCE,
		placement = {4, 2},
		roomcodes = {{"000000000000000000000000000000000000000000000z0009qqqqqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"000000000000000000000000000000000000000000000z0009qqqqqqqqqq00000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_ENTRANCE_2,
		placement = {4, 3},
		roomcodes = {{"00000000000000000000000000000000000000000000000000qqqqqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = module.HD_SUBCHUNKID.YAMA_SETROOM_4_4,
		placement = {4, 4},
		roomcodes = {{"0000000000000000000000000000000000X00000000qqq00&0qqqqqqq000wwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
}
module.HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].postPathMethod = function()
	local levelw, _ = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	local exit_on_left = (math.random(2) == 1)
	
	if exit_on_left == true then
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.YAMA_EXIT,
			{{"0000Q000L000000000L009000000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}},
			1, 1
		)
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.YAMA_TOP,
			{{"0L000Q00000L000000000L00000CCC0L0h00hhhh000h00hhhh000h00hhhh000h00hhhh0000000000"}},
			1, levelw
		)
	else
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.YAMA_TOP,
			{{"0000Q000L000000000L0CCC00000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}},
			1, 1
		)
		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.YAMA_EXIT,
			{{"0L000Q00000L000000000L000000900L0h00hhhh000h00hhhh000h00hhhh000h00hhhh0000000000"}},
			1, levelw
		)
	end
end


module.HD_ROOMOBJECT.WORLDS = {}
module.HD_ROOMOBJECT.WORLDS[THEME.DWELLING] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				local _, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

				local chunkPool_rand_index
				if state.level == 1 then
					chunkPool_rand_index = math.random(9)
				elseif (
					module.CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					module.CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					module.CHUNKBOOL_IDOL == true or
					_chunk_coords.hi == levelh
				) then
					chunkPool_rand_index = math.random(9)
				else
					if math.random(10) == 1 then
						module.CHUNKBOOL_IDOL = true
						return {idol = true}
					else
						chunkPool_rand_index = math.random(9)
					end
				end
				
				if chunkPool_rand_index == 4 and state.level < 3 then return {index = 2}
				else return {index = chunkPool_rand_index} end
			end,
			[module.HD_SUBCHUNKID.PATH_DROP] = function()
				local range_start, range_end = 1, 12
				local chunkpool_rand_index = math.random(range_start, range_end)
				if (
					feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == true
					and (chunkpool_rand_index > 1 and chunkpool_rand_index < 6)
				) then
					chunkpool_rand_index = chunkpool_rand_index + 11
				end
				return chunkpool_rand_index
			end,
			[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = function()
				local range_start, range_end = 1, 8
				local chunkpool_rand_index = math.random(range_start, range_end)
				if (
					feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == true
					and (chunkpool_rand_index > 1 and chunkpool_rand_index < 6)
				) then
					chunkpool_rand_index = chunkpool_rand_index + 7
				end
				return chunkpool_rand_index
			end,
		},
		obstacleBlocks = {
			[module.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				local range_start, range_end = 1, 32 -- default
				if (state.level < 3) then
					range_start, range_end = 1, 14
				else
					range_start, range_end = 15, 32
				end

				local chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{
				"110000000040L600000011P000000011L000000011L5000000110000000011000000001111111111",
				"00000000110060000L040000000P110000000L110050000L11000000001100000000111111111111"
			},
			{"00000000110060000L040000000P110000000L110050000L11000000001100000000111111111111"},
			{"11000000110#000000#0111100111111200002112200000022110000001111200002111111111111"},-- if state.level < 3 then use case 2 instead
			{
				"11111111112000L000021vvvP0vvv11v0vL0v0v10000L000001v=v11v=v111111111111111111111",
				"111111111120000L00021vvv0Pvvv11v0v0Lv0v100000L00001v=v11v=v111111111111111111111"
			},
			{"11111111110221111220002111120000022220000002222000002111120002211112201111111111"},
			{"11111111111112222111112000021111102201111120000211111022011111200002111112222111"},
			{
				"11111111110000000000110000001111222222111111111111012222221200000000201100000011",-- 1/4 chance
				"11111111110000000000110000001111222222111111111111212222221002000000001100000011",-- 1/4 chance
				"11111111110000000000110000001111222222111111111111112222221112000000211100000011",-- 2/4 chance
				"11111111110000000000110000001111222222111111111111112222221112000000211100000011",-- 
			},
			{"121111112100L2112L0011P1111P1111L2112L1111L1111L1111L1221L1100L0000L001111221111"},
		},
		[module.HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000000050000000000000000000000000011111111111111111111"},
			{"60000600000000000000000600000000000000000000000000000222220000111111001111111111"},
			{"11111111112222222222000000000000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112022222222000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112211111111201111111100111111110022222222000000000001111111111"},
			{
				"1111111111000000000L111111111P000000000L5000050000000000000000000000001111111111",
				"1111111111L000000000P111111111L0000000005000050000000000000000000000001111111111"
			},
			{"000000000000L0000L0000PvvvvP0000L0000L0000PvvvvP0000L1111L0000L1111L001111111111"},
			{"00000000000111111110001111110000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{
				"2222222222000000000000000000L00vvvvvvvP00v050000L0vv000000L0v0000000L01111111111",
				"222222222200000000000L000000000Pvvvvvvv00L500000v00L000000vv0L0000000v1111111111"
			},
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000600006000000000000000000000000600006000000000000000000000000"},
			{"00000000000000000000600006000000000000000000050000000000000000000000001202111111"},
			{"00000000000000000000600006000000000000005000000000000000000000000000001111112021"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211200000002100000000000200000000000000000211120000211"},
			{"11111111111111112222211220000001200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
			
			--spiderlair
			{"00000000000000000000600006000000000000000000050000000000000000000000001200021111"},
			{"00000000000000000000600006000000000000005000000000000000000000000000001111200021"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110011111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111100111"},
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},-- empty case (extra chance)
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},--
			{"00000000000000000000000600000000000000000000000000000111110000111111001111111111"},
			{"00000000000111111110001111110000000000005000050000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{"10000000011112002111111200211100000000000022222000011111111011111111111111111111"},
			{
				"0000000000000000000000000000L00vvvvvvvP00v050000L0vv000000L0v0000000L01111111111",
				"000000000000000000000L000000000Pvvvvvvv00L500000v00L000000vv0L0000000v1111111111"
			},
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000000000000000600006000000000000000000000000600006000000000000000000000000"},
			{"00000000000000000000600006000000000000000000050000000000000000000000001202111111"},
			{"00000000000000000000600006000000000000005000000000000000000000000000001111112021"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000000000000600006000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},

			--spiderlair
			{"00000000000000000000600006000000000000000000050000000000000000000000001200021111"},
			{"00000000000000000000600006000000000000005000000000000000000000000000001111200021"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110011111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111100111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000008000000000000000000L000000000P111111000L111111000L00111111111111111"},
			{"0000000000008000000000000000000000000L000111111P000111111L001111100L001111111111"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v1001111111101111111111",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1001111111101111111111"
			},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000002000000002"},
			{"11111111112222222222000000000000000000000008000000000000000000000000002000000002"},
			{"00000000000008000000000000000000L000000000P111111000Lvvvv11000L000v1111vvvv0v111"},
			{"0000000000008000000000000000000000000L000111111P00011vvvvL00111v000L00111v0vvvv1"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v100111v000001111v0vv11",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1000000v111011vv0v1111"
			},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
		},
		[module.HD_SUBCHUNKID.IDOL] = {{"2200000022000000000000000000000000000000000000000000000000000000I000001111A01111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"vvvvvvvvvvv++++++++vvL00000g0vvPvvvvvvvv0L000000000L0:000:0011111111111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"vvvvvvvvvvv++++++++vvg000000LvvvvvvvvvPv00000000L000:000:0L011111111111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{""}},
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"vvvvvvvvvv0++++++++0vL00g000LvvPvvvvvvPv0L000000L00L000000L00L000000L01111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000L222222L0vPvvvvvvPvvL000000LvvL00g000Lvv========v"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"vvvvvvvvvvv++++++++vvL00g000LvvPvvvvvvPv0L000000L00L000000L00L000000L01111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000vvvvvv0000v0000v000L00g000L00Pv====vP00L0v00v0L00L000000L0111v00v111"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"011100020000000"},
			{"000001111000000"},
			{"000000111100000"},
			{"000000000011111"},
			{"000002020017177"},
			{"000000202071717"},
			{"000000020277171"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000222021112"},

			{"000002010077117"},
			{"000000010271177"},
			{"0010000#0002120"},
			{"000001111000000"},
			{"000000111100000"},
			{"000000000011111"},
			{"000000020077177"},
			{"000000010077777"},
			{"000000020077177"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000077"},
			{"011100222070007"},
			{"001110022277000"},
			{"000000222021112"},
			{"000002010077177"},
			{"000000010277177"},
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"022220000022220"},
			{"222200000002222"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000111000000"},
			{"000000111002220"},
			{"000000222001110"},
			{"000000022001111"},
			{"000002220011100"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.JUNGLE] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (
					module.CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					module.CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					module.CHUNKBOOL_IDOL == false and
					(
						feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false and feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) == false
					) and
					math.random(10) == 1
				) then
					module.CHUNKBOOL_IDOL = true
					return {idol = true}
				else
					local chunkPool_rand_index = math.random(8)
					return {index = chunkPool_rand_index}
				end
			end,
		},
		obstacleBlocks = {
			[module.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				local range_start, range_end = 1, 22 -- default
				if (state.level < 3) then
					if (math.random(6) == 6) then -- if (uVar8 % 6 == 0)
						range_start, range_end = 17, 19 -- iVar6 = uVar8 % 3 + 100;
					else
						range_start, range_end = 1, 8 -- iVar6 = (uVar8 & 7) + 1;
					end
				else
					if (math.random(6) == 6) then -- if (uVar8 % 6 == 0)
						range_start, range_end = 20, 22 -- iVar6 = uVar8 % 3 + 0x67;
					else
						range_start, range_end = 9, 16 -- iVar6 = (uVar8 & 7) + 9;
					end
				end

				local chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
		
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{"111111111111V0000211120000021100000002110000000211112000021111120021111111001111"},
			{"1111111111112V000011112000002111200000001120000000112000021111120021111111001111"},
			{"11120021111100000222120000021100000002220000000211112000022211177T71111111111111"},
			{"1112002111222000001111200000212220000000112000000022200002111117T771111111111111"},-- empty case statement (2x more chance)
			{"1112002111222000001111200000212220000000112000000022200002111117T771111111111111"},--
			{
				"111111111112000Q0211120000021112000002111200000211112000021111120021111112002111",
				"11111111111200Q00211120000021112000002111200000211112000021111120021111112002111"
			},
			{"000000000001wwwwww1011wwwwww11113wwww311113wwww311113wwww31111133331111111111111"},
			{"00000000000000rr0000000rttr00000rrrrrr0000V0000000000000000000000000002000000002"},
		},
		[module.HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000050000500000000000000000000000011111111111111111111"},
			{"60000600000000000000000000000000000000000000000000000111110000111111001111111111"},
			{"2222222222000000000000000000000000tt000000r0220r0000t0tt0t000rtrttrtr01111111111"},
			{
				"0L000000001L111111110L222222200L000000000002002000011122111011200002111111111111",
				"00000000L011111111L102222222L000000000L00002002000011122111011200002111111111111"
			},
			{"1111111111V0000V000000000000000000000000000000000010000000011ssssssss11111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"000000000000000000000000&000000q3wwww3q0013wwww310113wwww31111133331111111111111"},
			{"0060000000000000000000000000000000&000000q3wwww3q0113wwww31111133331111111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
			{"11111111111111111111120000002100000000000000000000022000022021120021121111001111"},
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000005000050000000000000000000000001111111111"},
			{
				"0000000000000000000000000000000000500000000000000000T000000011111111111111111111",
				"000000000000000000000000000000050000000000000000000000000T0011111111111111111111"
			},
			{
				"00000000000000000000000000000000000000000002222220001111111011111111111111111111",
				"00000000000000000000000000000000000000000222222000011111110011111111111111111111"
			},
			{
				"00000000000000000000000000000000000000000000000220000002211100002211111111111111",
				"00000000000000000000000000000000000000000220000000111220000011112200001111111111"
			},
			{"000000000000000000000000&000000q3wwww3q0013wwww310113wwww31111133331111111111111"},
			{"00000000000060000000000000000000000000000q3wwww3q0113wwww31111133331111111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"01111111100222222220000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000080000000000000000000000000000000000001110000111"},
			{"60000600000000000000000000000000800000000000000000000000000000000000001110000111"},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{
				"1111111111L000011112L009000000L011000020L012000000021100000000220T00T01111111111",
				"1111111111211110000L000000900L020000110L000000210L00000011200T00T022001111111111"
			},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.IDOL] = {{"01000000100000I0000001BBBBBB10010000001011wwwwww1111wwwwww11113wwww3111111111111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"ttttt11111t000000000tg0t000000ttttI0000000ttttt000ttttttt000rrrrrrrr001111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"11111ttttt000000000t000000tg0t00000Itttt000ttttt00000ttttttt00rrrrrrrr1111111111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"000000000000000000000000g00000000tttt00000tt00tt00000000000001tt00tt1011rr00rr11"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000000000000000g00000000tttt00000tt00tt00000000000001tt00tt1011rr00rr11"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000000022222"},--1
			{"0000022222q111q"},--2
			{"0q000q100011122"},--3
			{"000q00001q22111"},--4
			{"00020q00201001q"},--5
			{"000000200102001"},--6
			{"02000q10q010710"},--7
			{"000200q01q01701"},--8
			{"000000000077777"},--9
			{"000007777711111"},--10
			{"0q000q100011177"},--0xb
			{"000q00001q77111"},--0xc
			{"00020q00201771q"},--0xd
			{"000000200102771"},--0xe
			{"02000q10q010717"},--0xf
			{"000200q01q71701"},--0x10
			{"00000000000T022"},--100
			{"000000000020T02"},--0x65
			{"0000000000220T0"},--0x66
			{"00000000000T077"},--0x67
			{"000000000070T07"},--0x68
			{"0000000000770T0"},--0x69 -- nice
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111122222000000"},
			{"211110222200000"},
			{"222220000000000"},
			{"111112111200000"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000q1q0q111q"},
			{"00900q111q11111"},
			{"0090000100q212q"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD] = {
	level_dim = {w = 2, h = 12},
	
	setRooms = {
		{
			subchunk_id = module.HD_SUBCHUNKID.WORM_CRYSKNIFE_LEFTSIDE,
			placement = {6, 1},
			roomcodes = {
				{"0000000dd00011111110011333333w013wwwwwww013wwwwwww011cwwwwww00111111110000000000"}
			}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.WORM_CRYSKNIFE_RIGHTSIDE,
			placement = {6, 2},
			roomcodes = {
				{"0dd00000000111111100w333333110wwwwwww310wwwwwww310wwwwwww11011111111000000000000"}
			}
		}
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"00100001000111121101010000010221011101010001000000012101101101000100002111112121"},
			{"00100001000111121121010000000221110111010200000000011010111000001000101212112112"},
			{"0010000100011000011021wwwwww1221wwwwww12011wwww110021111112000000000001111111111"},
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{"00000100000110011111011100011001100001100110001110011110011000001000001110101111"},
			{
				"00000000000021200000000L002120212L000Q000L0L0000000L0L0000000L000000000000000000",
				"00000000000000021200021200L00000Q000L212000000L0L0000000L0L000000000L00000000000"
			},
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00200001000111101101010000010221011101010001000000012101101101000100002111110121"},
			{"00100002000111101121010000000221110111010200000000011010111000001000101210112112"},

			{"0010000100011000011021wwwwww1221wwwwww12011wwww110021111112000000000001112002111"},
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{"00000100000110011111011100011001100001100110001110011110011000001000001110101111"},
			{
				"00000000000021200000000L002120212L000Q000L0L0000000L0L0000000L000000000000000000",
				"00000000000000021200021200L00000Q000L212000000L0L0000000L0L000000000L00000000000"
			}
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"000000000000000000000001002000000000000000020020001s000000s111ssssss111111111111"},
			{"000000000000000000000002001000000000000000020020001s000000s111ssssss111111111111"},
			{"000000000000000000000002002000000000000000010010001s000000s111ssssss111111111111"}
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00200001000111101101010000010221011101010001000000012101101101000100002111110121"},
			{"00100002000111101121010000000221110111010200000000011010111000001000101210112112"},
			{"0000000000011000011001wwwwww1001wwwwww10011wwww110021111112000000000001112002111"},
			{
				"0000000000111000000000L000000011L000000011L001110011L011Q11000001202101110120211",
				"000000000000000001110000000L000000000L110011100L11011Q110L1101202100001120210111"
			},
			{"00000000010110011111011100011001100001100110001110011110011000001000001110101111"},
			{
				"00000000000021200000000L002120212L000Q000L0L0000000L0L0000000L000000000000000000",
				"00000000000000021200021200L00000Q000L212000000L0L0000000L0L000000000L00000000000"
			}
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"}
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000002021111120"},
			{"11111111112222222222000000000000000000000008000000000000000000000000002021111120"}
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"000000000000000000000000090000000111100001w3333w1001wwwwww1011wwwwww11133wwww331"},
			--{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"} -- unused
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"}
		},
		[module.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE] = {
			{"0dd0000dd02d0dddd0d20ddd00ddd02d0dddd0d20ddd00ddd000dddddd0011d0000d111111001111"}
		},

		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{""}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111001111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111001111"}},
	},
	
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111122222000000"},
			{"211110222200000"},
			{"222220000000000"},
			{"111112111200000"},
		},
	},
}

module.HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	local unlock_location_x, unlock_location_y = nil, nil

	-- Coffin
	if unlockslib.LEVEL_UNLOCK ~= nil then
		-- Select room coordinates between x = 1..2 and y = 11
		unlock_location_x, unlock_location_y = math.random(1, levelw), 11
	
		local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[unlock_location_y][unlock_location_x]
		local path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK
	
		if path_to_replace == module.HD_SUBCHUNKID.PATH_NOTOP then
			path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP
		elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP then
			path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP
		elseif path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP then
			path_to_replace_with = module.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP
		end
		roomgenlib.levelcode_inject_roomcode(path_to_replace_with, module.HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[path_to_replace_with], unlock_location_y, unlock_location_x)
	end



	-- Replace two drop/drop_notop with WORM_REGENBLOCK_STRUCTURE.
	local spots = {}
	for room_y = 1, levelh, 1 do
		for room_x = 1, levelw, 1 do
			local path_to_replace = roomgenlib.global_levelassembly.modification.levelrooms[room_y][room_x]
			local path_to_replace_with = -1
			
			if (
				(path_to_replace == module.HD_SUBCHUNKID.PATH_DROP
				or path_to_replace == module.HD_SUBCHUNKID.PATH_DROP_NOTOP)
				and ( unlock_location_x ~= room_x and unlock_location_y ~= room_y )
			) then
				table.insert(spots, {x = room_x, y = room_y})
			end
		
		end
	end
	if #spots ~= 0 then
		-- pick random place to fill
		local n = #spots
		local spot1_i = math.random(n)
		local spot1 = spots[spot1_i]

		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE,
			module.HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[module.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE],
			spot1.y, spot1.x
		)

		table.remove(spots, n)
		local spot2 = spots[math.random(#spots)]

		--TODO: check if spot2 being nil still happens, SNF said it could have been due to using CompactList instead of table.remove
		--This return is just to be sure to not get an error on hdmod showcase
		if not spot2 then return end

		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE,
			module.HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[module.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE],
			spot2.y, spot2.x
		)
	end
	
end

local function path_algorithm_icecaves_drop()
	if math.random(10) == 1 then
		return 13
	end
	local chunkpool_rand_index = math.random(state.level < 3 and 9 or 12)
	while (chunkpool_rand_index == 9) do
		chunkpool_rand_index = math.random(state.level < 3 and 9 or 12)
	end
	return chunkpool_rand_index
end
local function path_algorithm_icecaves()
	if math.random(10) == 1 then
		return 13
	end
	return math.random(state.level < 3 and 9 or 12)--12 or 9)--TODO: Verify what FUN_004e0100() does (I think it's "hard")
end
module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (math.random(2) == 2) then
					if (
						module.CHUNKBOOL_ALTAR == false and
						math.random(14) == 1
					) then
						module.CHUNKBOOL_ALTAR = true
						return {altar = true}
					elseif (
						module.CHUNKBOOL_IDOL == false and
						math.random(10) == 1
					) then
						module.CHUNKBOOL_IDOL = true
						return {idol = true}
					else
						local chunkPool_rand_index = math.random(8)
						return {index = chunkPool_rand_index}
					end
				else
					return {index = path_algorithm_icecaves()+8} -- use path room algorithm + adjusted range 
				end
			end,
			[module.HD_SUBCHUNKID.PATH] = path_algorithm_icecaves,
			[module.HD_SUBCHUNKID.PATH_DROP] = path_algorithm_icecaves_drop,
			[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = path_algorithm_icecaves_drop
		},
	},
	rooms = {
		[module.HD_SUBCHUNKID.PATH] = {
			{
				"0111100000110010000000011000i1000000000011200ii0001120000000000000000011iiii0000",
				"000001111000000100111i000110000000000000000ii00211000000021100000000000000iiii11"
			},
			{
				"00000000000000000000000000000000000000001100000001200000000200000000000000000000",
				"00000000000000000000000000000000000000001000000011200000000200000000000000000000"
			},
			{"01111200001111112000111111200000002120001120000000112021200000001120001111120000"},
			{"00002111100002111111000211111100021200000000000211000212021100021100000000211111"},
			{
				"000000000000000000jj00f2100iii000210000000021110ii000021100100000211000000002111",
				"0000000000jj00000000iii0012f000000012000ii01112000100112000000112000001112000000"
			},
			{"000000000000000000000000000000F00F00F0000000000000000000000000000000000000000000"},
			{"00000000000000000000000000000000000000000iiiiiiii00021ii120000022220000000000000"},
			{"000000000000000000000iiiiiiii00021ii12000002222000000000000000000000000000000000"},
			{"0011111100000222200000000000000000000000jjjjjjjjjjiiiiiiiiii00000000001111111111"},
			-- hard
			{
				"000000000000000000000000000000000000010000100001f00f1000000000000000000000000000",
				"00000000000000000000000000000000100000000f1000010000000001f000000000000000000000"
			},
			{
				"000000000000000000000000i000f000000000000f0000000000000i000000000000000000000000",
				"000000000000000000000f000i0000000000000000000000f00000i0000000000000000000000000"
			},
			{"00000000000000000000000000000000000000001100000011000ssss00000011110000000000000"},
			{"00000000000000000000000000000000005000000000000000000000000000021111100000222211",
			"00000000000000000000000000000005000000000000000000000000000001111120001122220000"} -- path_notop
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111111111",
				"00000000000000000000000000000000000000000080000000000000000000000000001111111111"
			},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000000011111110",
				"00000000000000000000000000000000000000000080000000000000000000000000000011111110"
			},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[module.HD_SUBCHUNKID.IDOL] = {{"00000000000000I000000000--00000000000000000000000000000000000000ss00000000110000"}},
		[module.HD_SUBCHUNKID.ALTAR] = {{"000000000000000000000000000000000000000000000000000000x0000002211112201111111111"}},
		[module.HD_SUBCHUNKID.VAULT] = {{
			--"02222222202111111112211|00011221100001122110EE0112211000011221111111120222222220"
			"02222222202111111112211|00011221100001122110000112211000011221111111120222222220"
			-- "02222222202000000002200|00000220000000022000000002200000000220000000020222222220" -- hd accurate sync
		}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"00:0000000iiii00f000i00:00000fig0i000000iiiiff0000iiii000ff00ii00000000000000000"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"0000000:00000f00iiiif00000:00i000000ig0i0000ffiiii0ff000iiii0000000ii00000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"0021111200021iiii12002i0000i20000000000000i0g00i0002iiiiii2000211112000002222000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"0000000000000000000000000000000000g000000fiiiiiif0000iiii00000000000000000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"0021111200021iiii12002i0000i20000000000000i0g00i0002iiiiii2000211112000002222000"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000000g000000fiiiiiif0000iiii00000000000000000000000"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"111110000000000"},
			{"000001111100000"},
			{"000000000011111"},
			{"000002020010100"},
			{"000000202001010"},
			{"000000020200101"},
			{"000002220011100"},
			{"000000222001110"},
			{"000000022200111"},
			{"111002220000000"},
			{"011100222000000"},
			{"001110022200000"},
			{"000000222021112"},
			{"000002010000110"},
			{"000000010201100"},
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"000000000011111"},
			{"000001111122222"},
			{"111112222200000"},
			{"0jij00jij00jij0"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.SIDE] = {
	{"20000000020000000000000000000000000000000000000000000000000000000000002000000002"},
	{"10000000001000000000111000000022201100000000220100000000010000000001110000000222"},
	{"00000000010000000001000000011100001102220010220000001000000011100000002220000000"},
	{"00000000000002112000000111100000f1111f000001111000f00211200f00021120000000000000"},
	{"0000000000000000000000220022000011ff11000011001200202100120220210012020002002000"},
	{"0jiiiiiij00jij00jij0jjii0jiij0000000jij0jjiij0iij00jiij0jijj0jiij000000jjiiiiijj"},
	{"0jiiiiiij00jij00jij00jii0jiijj0jij0000000jij0jiijj0jij0jiij000000jiij00jjiiiiijj"},
	{"011iiii110000jjjj0000000ii00000000jj00000000ii00000000jj00000000ii00000002222000"},
 	table.unpack(commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH]))
}
module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH_DROP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH])
module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH])
module.HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[module.HD_SUBCHUNKID.PATH_NOTOP] = {
	{"00000000000000000000000000000000005000000000000000000000000000021111100000222211",
	"00000000000000000000000000000005000000000000000000000000000001111120001122220000"}
}

module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				local chunkPool_rand_index = math.random(2)
				if math.random(10) == 1 then 
					chunkPool_rand_index = 3
				end
				return {index = chunkPool_rand_index}
			end,
		},
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
			{"00000000000000110000000022000010001100011000110001100000000120~0000~021111111111"},
			-- Zoo
			{"11110011110000000000010:00:01001111111100000000000m10:00:01m01111111101111111111"},
		},
		[module.HD_SUBCHUNKID.PATH] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000002200000000000000000022000000000000001111001111"},
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"000000000000000000000000000000000000000000000000000000mm000000000000001111111111"},
			{"0000000000000000000000000000000000~~0000000011000000001100000~001100~01111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"0000000000000000000000000000000000~~00000000110000000000000000~0000~001112002111"},
			{"000000000000000000000000000000000000000000000000000000mm000000000000001112002111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"}
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"000000000000000000000000000000000000000000000000000001mm100000219012001111111111"},
			{"000000000000000000000000000000000000000000000000000001mm100000210912001111111111"},
			{"0000000000000000000000000000000000~000000011111000011000110000009000001111111111"},
			{"00000000000000000000000000000000000~00000001111100001100011000000900001111111111"},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{"01000001000z00000z00000000000000000000000011011000011090110001111111001111111111"},
			{"001000001000z00000z0000000000000000000000001101100001109011000111111101111111111"},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"000000000000110011000010009100001111110000z0000z000000000000mm000000mm1111001111"},
			{"000000000000110011000019000100001111110000z0000z000000000000mm000000mm1111001111"},
		},
		
		[module.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN] = {
			{
				"1)00000)10)0000000)00000Q0000000000000000L00000L000110*01100L1111111L01111111111",
				"01)00000)10)0000000)00000Q0000000000000000L00000L000110*01100L1111111L1111111111",
				"1)00000011100000001100000Q001100000000110LL11100010000010*0111000111111111001111",
				"11000000)111000000011100Q0000011000000001000111LL010*010000011111000111111001111",
			},
		},
		[module.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_RIGHT] = {
			{
				"000000000000000000000011111)000011X0000000110000000011111L000~111111~01111111111",
			},
		},
		[module.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_LEFT] = {
			{
				"0000000000000000000000)11111000000X01100000000110000L11111000~111111~01111111111"
			},
		},

		[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE] = {
			{"22222222220000000000000000000000000000000000000000000000000000000000000000000000"},
			{"11111111112222222222000000000000000000000000000000000000000000000000000000000000"},
			{"22211112220001111000000211200000011110000002112000000022000000000000000000000000"},
			{"11112211112112002112022000022000000000000000000000000000000000000000000000000000"},
		},

		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"110000000011111)))10110010001011g00000001111100000000010000011000000~011111;0011"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"000000001101)))111110100010011000000g011000001111100000100000~0000001111;0011111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"5000050000000000000000000000001111111111010z00z0100100g0001000001100001111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"500005000000000000000000000000101111110100000000000000g000000~001100~01111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"5000050000000000000000000000001111111111010z00z0100100g0001000001100001111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"500005000000000000000000000000101111110100000000000000g000000~001100~01111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
	},
	rowfive = {
		setRooms = {
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 1,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 2,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 3,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 4,
				roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.GENERIC[module.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
		}
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000001000010000"},
			{"000000000100001"},
			{"000000010000100"},
			{"000000000000000"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].prePathMethod = function()
	roomgenlib.level_generation_method_structure_vertical(
		{
			subchunk_id = module.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN,
			roomcodes = module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[module.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN]
		},
		nil,
		{1, 2, 3, 4}
	)
end

module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].postPathMethod = function()
	--[[
		loop through top to bottom, replace the first two side rooms found with alienlord rooms
	--]]

	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	local minw, minh, maxw, maxh = 1, 1, levelw, levelh

	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			local spawn_alienlord = false
			local pathid = roomgenlib.global_levelassembly.modification.levelrooms[hi][wi]


			if pathid == nil then
				if module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 == false then
					spawn_alienlord = true
					module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 = true
				elseif module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 == false then
					spawn_alienlord = true
					module.CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 = true
				else
					break
				end
			end

			if spawn_alienlord == true then
				local subchunkid = math.random(2) == 1 and module.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_RIGHT or module.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD_LEFT
				roomgenlib.levelcode_inject_roomcode(subchunkid, module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[subchunkid], hi, wi)
			end
		end
	end
	

	if unlockslib.LEVEL_UNLOCK ~= nil then
		roomgenlib.level_generation_method_aligned(
			{
				left = {
					subchunk_id = module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = module.HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end
end

module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE] = {
	-- NOTE: All imported temple roomcodes have their "r" tiles replaced with "("
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				local chunkPool_rand_index
				if (math.random(4) == 4) then
					chunkPool_rand_index = math.random(15, 24) -- use path roomcodes
				else
					if (
						module.CHUNKBOOL_ALTAR == false
						and math.random(14) == 1
					) then
						module.CHUNKBOOL_ALTAR = true
						return {altar = true}
					elseif (
						feelingslib.feeling_check(feelingslib.FEELING_ID.SACRIFICIALPIT) == false
						and module.CHUNKBOOL_IDOL == false
						and math.random(15) == 1
					) then
						module.CHUNKBOOL_IDOL = true
						return {idol = true}
					else
						chunkPool_rand_index = math.random(14)
					end
				end
				

				
				return {index = chunkPool_rand_index}
			end,
		},
	},
	rooms = {
		[module.HD_SUBCHUNKID.PATH] = {
			{
				"1000000001200(00000210000000011000000001110000001100000000000000Y00000qqqqqqqqqq",
				"1000000001200(000002100000000110000000011100000011000000000000000000001111111111"
			},
			{
				"1000000000100(00000010000000001000000000110000000000000000000000Y00000qqqqqqqqqq",
				"1000000000100(000000100000000010000000001100000000000000000000000000001111111111"
			},
			{
				"0000000001000(00000100000000010000000001000000001100000000000000Y00000qqqqqqqqqq",
				"0000000001000(000001000000000100000000010000000011000000000000000000001111111111"
			},
			{"0000000001000(000001000000000100000000010000000011000022000000011110001111111111"},
			{
				"110000001100L0000L0011P(000P1111L0000L1111L0000L1102L0000L200000Y00000qqqqqqqqqq",
				"110000001100L0000L0011P(000P1111L0000L1111L0000L1102L0000L2000000000001111111111"
			},
			{
				"1111111111111111111111111111111111111111111111111100000000000000Y00000qqqqqqqqqq",
				"11111111111111111111111111111111111111111111111111000000000000000000001111111111"
			},
			{
				"1000000001000(00000010000000011000000001111111111100000000000000Y00000qqqqqqqqqq",
				"1000000001000(000000100000000110000000011111111111000000000000000000001111111111"
			},
			{"120(000021000000000012000000211220LL02211111PP11110011LL11000000LL00001111111111"},
			{
				"1111111111240000004211011110111200000021111111111100000000000000Y00000qqqqqqqqqq",
				"11111111112400000042110111101112000000211111111111000000000000000000001111111111"
			},
			{
				"0000000000000000000000000000000000&000000qqwwwwwq0013wwww3101113w331111111111111",
				"0000000000000000000000000000000000&000000qwwwwwqq0013wwww3101113w331111111111111"
			}
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000000000000060000000000000001202000000"},
			{"00000000006000060000000000000000000000000500000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111011200002111111001111"},
			{"0000000000006000000000000000000000000000000000000000q1122200021000000011101qqqq1"},
			{"000000000000600000000000000000000000000000000000000022211q0000000001201qqqq10111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"11111111112222111111000002211100000002110000000000200000000000000000211120000211"},
			{"11111111111111112222111220000011200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"},
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"1000000001100(000001100000000110000000011100000011000000000000000000001111111111"},
			{"1000000000100(000000100000000010000000001100000000000000000000000000001111111111"},
			{"0000000001000(000001000000000100000000010000000011000000000000000000001111111111"},
			{"0000000000000000000000000000000000&000000q3wwww3q0013wwww3101113w331111111111111"},
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000000000000060000000000000001202000000"},
			{"00000000006000060000000000000000000000000500000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111011200002111111001111"},
			{"0000000000006000000000000000000000000000000000000000q1122200021000000011101qqqq1"},
			{"000000000000600000000000000000000000000000000000000022211q0000000001201qqqq10111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{"11111111110000000000000000000000000000000008000000000000000000000000001111111111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"11111111110000000000000000000000000000000008000000000000000000000000002000000002"},
		},
		[module.HD_SUBCHUNKID.EXIT] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000000000000000"},
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000000000000000"},
		},
		[module.HD_SUBCHUNKID.IDOL] = {{"11CCCCCC1111000000111D000000D11000000001100000000100000000000000I00000qqqqA0qqqq"}}, -- modified from original for sliding doors
		[module.HD_SUBCHUNKID.ALTAR] = {{"220000002200000000000000000000000000000000000000000000x0000000111111001111111111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"111111111110001104004g00110400111000011010000000101wwwwwww111wwwwwww111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"111111111100401100010040110g040110000111010000000111wwwwwww111wwwwwww11111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000222021112"},
			{"000000202021212"},
			{"111001111011111"},
			{"001110111111111"},
			{"211122222200000"},
			{"000220001100011"},
			{"220001100011000"},
			{"000000000000000"},
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"022220000022220"},
			{"222200000002222"},
			{"222002220000000"},
			{"022200222000000"},
			{"002220022200000"},
			{"000000111000000"},
			{"000000111002220"},
			{"000000222001110"},
			{"000002010000111"},
			{"000000010211100"},
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"00900q111q21112"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE] = {
	{"11111000001111100000111110000011111000001111150000111110000011111000001111111111"},
	{"00000111110000011111000001111100000111115000011111000001111100000111111111111111"},
	{"11000000001110000000211100000011111000002211110000111111100022211111001111111111"},
	{"00000000110000000111000000111200000111110000111122000111111100111112221111111111"},
	{"11111111110000000000111111100011111100001111100000111100000011100000001100000011"},
	{"11111111110000000000000111111100001111110000011111000000111100000001111100000011"},
	{"11111111112000000002110122101111000000111101221011200000000220012210021100000011"},
	{"11111111110002112000110011001111102201111100110011020111102000021120001111111111"},
	{"1111111111000000000011011110111101111011100111100111wwwwww1111wwwwww111111111111"},
	{
		"11ttttt0111111111011110ttttt11110111111111ttttt011111111101111Ettttt111111111111" -- original
		-- "11222220111111111011110222221111011111111122222011111111101111E22222111111111111" -- guess
	},
	{
		"1111111111110ttttE11110111111111ttttt0111111111011110ttttt1111011111111100000011" -- original
		-- "11111111111102222E11110111111111222220111111111011110222221111011111111100000011" -- guess
	},
	{"111111111111111111111111EE1111110111101111E1111E111111EE111111111111111111111111"},
	{"1000000001000000000010000000011000000001100000000100T0000T000dddddddd01111111111"},
	{"10000000010021111200100000000110000000011111001111111200211111120021111111001111"},
	table.unpack(commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH]))
}
module.HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				local chunkPool_rand_index
				if (math.random(4) == 4) then
					chunkPool_rand_index = math.random(13, 22) -- use path roomcodes
				end
				chunkPool_rand_index = math.random(12)
				
				return {index = chunkPool_rand_index}
			end,
		},
	},
	setRooms = {
		{
			subchunk_id = module.HD_SUBCHUNKID.COG_BOTD_LEFTSIDE,
			placement = {3, 2},
			roomcodes = {{"00000111110000011000000001100000Y00110001111111000000001100#00Y001100A1111111111"}}
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.COG_BOTD_RIGHTSIDE,
			placement = {3, 3},
			roomcodes = {{"111110000000011000000001100Y000001111111000110000000011000000001100Y001111111111"}}
		}
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][1],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][2],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][3],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][4],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][5],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][6],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][7],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][8],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][9],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][10],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][11],
				module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.SIDE][12],
				table.unpack(commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH]))
		},
		[module.HD_SUBCHUNKID.PATH] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH]),
		[module.HD_SUBCHUNKID.PATH_NOTOP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH_NOTOP]),
		[module.HD_SUBCHUNKID.PATH_DROP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH_DROP]),
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.PATH_DROP_NOTOP]),
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{
				"011111110000000000000000000000000000000000z090z000011111110001111111001111111111",
				"0011111110000000000000000000000000000000000z090z00001111111000111111101111111111"
			},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
				"011111110000000000000000000000000000000000z090z000011111110004000001001112002111",
				"0011111110000000000000000000000000000000000z090z00001111111000100000401112002111"
			},
		},
		[module.HD_SUBCHUNKID.EXIT] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.EXIT]),
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[module.HD_SUBCHUNKID.EXIT_NOTOP]),
		
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{""}},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[module.HD_OBSTACLEBLOCK.GROUND.tilename]),
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[module.HD_OBSTACLEBLOCK.AIR.tilename]),
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[module.HD_OBSTACLEBLOCK.DOOR.tilename]),
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD].postPathMethod = function()
	local levelw, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms
	
	--[[
		viable coffin spots are:
		- next to a path
		- replacing a path_drop
	]]
	
	if unlockslib.LEVEL_UNLOCK ~= nil then
		local spots = {}
		for wi = 1, levelw, 1 do
			local subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[1][wi]
			if (
				(
					subchunk_id == nil
					and (
						(
							wi+1 <= levelw and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi+1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi+1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi+1] <= 8
							)
						) or (
							wi-1 >= 1 and
							(
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi-1] ~= nil and
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi-1] >= 1 and
								roomgenlib.global_levelassembly.modification.levelrooms[1][wi-1] <= 8
							)
						)
					)
				)
				or (
					subchunk_id ~= nil
					and subchunk_id == module.HD_SUBCHUNKID.PATH_DROP
				)
			) then
				table.insert(spots, {x = wi})
			end
		end
		-- pick random place to fill
		local spot = spots[math.random(#spots)]

		roomgenlib.levelcode_inject_roomcode(
			module.HD_SUBCHUNKID.COFFIN_UNLOCK,
			module.HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK],
			1, spot.x
		)
	end

	--[[
		let the path generate as normal,
		then run this method to replace parts of it with the two middle setrooms and a few paths.
		Place paths along the sides and underneath where there isn't any.
	--]]

	local minw, minh, maxw, maxh = 1, 2, levelw, levelh
	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			local pathid = -1
			
			if wi == minw or wi == maxw then
				if (hi == minh and
					(
						roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] == nil or
						(
							roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] ~= module.HD_SUBCHUNKID.PATH_DROP_NOTOP and
							roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] ~= module.HD_SUBCHUNKID.PATH_NOTOP
						)
					)
				) then
					pathid = module.HD_SUBCHUNKID.PATH_DROP
				elseif hi == maxh then
					pathid = module.HD_SUBCHUNKID.PATH_NOTOP
				else
					pathid = module.HD_SUBCHUNKID.PATH_DROP_NOTOP
				end
			elseif hi == maxh then
				pathid = module.HD_SUBCHUNKID.PATH
			end

			if (
				roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] ~= nil and hi == maxh and
				(
					roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] == module.HD_SUBCHUNKID.EXIT or
					roomgenlib.global_levelassembly.modification.levelrooms[hi][wi] == module.HD_SUBCHUNKID.EXIT_NOTOP
				)
			) then
				if ( -- exits under the middle setrooms can't be notop
					wi > minw and wi < maxw
				) then
					pathid = module.HD_SUBCHUNKID.EXIT
				elseif ( -- exits at corners have to be notop
					wi == minw or wi == maxw
				) then
					pathid = module.HD_SUBCHUNKID.EXIT_NOTOP
				end
			end

			if pathid ~= -1 then
				roomgenlib.levelcode_inject_roomcode(pathid, module.HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD].rooms[pathid], hi, wi)
			end
		end
	end
end

module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC] = {
	level_dim = {w = 4, h = 2},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"60000000000000000000000000000000000000000000000000600000000000000000000000000000"},
			{"00000600000000000000000000000000000000000000000000600000000000000000000000000000"},
			{"60000000000000000000000000000000000000000000000000000006000000000000000000000000"},
			{"60000600000000000000000000000000000000000000000000000000000000000000000000000000"},
			{"00000000000000000000000000000000000000000000000000600006000000000000000000000000"},
			{"00000000000000000000000000000000600000000000000000000000000000000000000000000000"},
		},
		[module.HD_SUBCHUNKID.OLMEC_ROW_FIVE] = {
			{"11111111111111111111111111111111111111111111111111111111111111111111111111111111"},
			{"11111111111222111111122211111111111111111111111111111111111111111111111111111111"},
			{"11111111111111111111111111111111122221111112222111111111111111111111111111111111"},
			{"11111111111111112221111111222111111111111111111111111111111111111111111111111111"},
			{"11111111111111111111111111111111111111111111111111122211111112221111111111111111"},
			{"11111111111111111111111111111111111111111111111111111111222111111122211111111111"},
		},
		[module.HD_SUBCHUNKID.COFFIN_UNLOCK] = {
			-- Spawn steps:
				-- levelw, _ = get_levelsize()
				-- structx = math.random(levelw)
				-- spawn 74 at 1, structx
			{
				"00000100000E110111E001100001100E100001E00110g00110001111110000000000000000000000",
				"00001000000E111011E001100001100E100001E00110g00110001111110000000000000000000000"
			}
		},
		-- [genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{""}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"0EEE02111202220"},
			{"0000E0EEE121111"},
			{"E00001EEE011112"},
			{"1EE001111212200"},
			{"0EEE12111100221"},
			{"21112EEEEE11111"},
		},
	},
}
module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rowfive = {
	offsety = (-(3*CONST.ROOM_HEIGHT)-3),
	setRooms = {
		{
			subchunk_id = module.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 1,
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[module.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 2,
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[module.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 3,
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[module.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = module.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 4,
			roomcodes = commonlib.TableCopy(module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[module.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
	}
}
module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].prePathMethod = function()
	if unlockslib.LEVEL_UNLOCK ~= nil then
		roomgenlib.level_generation_method_structure_vertical(
			{
				subchunk_id = module.HD_SUBCHUNKID.COFFIN_UNLOCK,
				roomcodes = module.HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[module.HD_SUBCHUNKID.COFFIN_UNLOCK]
			},
			nil,
			{1, 2, 3, 4}
		)
	end
end

module.HD_ROOMOBJECT.WORLDS[THEME.VOLCANA] = {
	chunkRules = {
		rooms = {
			[module.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				local _, levelh = #roomgenlib.global_levelassembly.modification.levelrooms[1], #roomgenlib.global_levelassembly.modification.levelrooms

				if (
					module.CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					module.CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					module.CHUNKBOOL_IDOL == false and
					_chunk_coords.hi ~= levelh
				) and math.random(10) == 1 then
					module.CHUNKBOOL_IDOL = true
					return {idol = true}
				else
					local chunkPool_rand_index = math.random(9)
					return {index = chunkPool_rand_index}
				end

			end,
		},
		obstacleBlocks = {
			[module.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				local range_start, range_end = 1, 2 -- default

				if (math.random(7) == 7) then
					range_start, range_end = 3, 5 -- iVar6 = uVar8 % 3 + 0x67;
				end

				local chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[module.HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{"50000500000000000000000000000011111111111111111111022222222000000000001100000011"},
			{"00011110000002112000000022000011200002110112002110022000022000002200001111111111"},
			{
			  "00002110000000211100000021120011200211110112002110022000022000000000001122112211",
			  "00011200000011120000000112000011112002110112002110022000022000000000001122112211"
			},
			{
			  "0000050000001000000000L000000011L111111111L111111100L211120000L21120001001111001",
			  "500000000000000001000000000L001111111L111111111L110021112L000002112L001001111001"
			},
			{"11111111110221111220002111120000022220000002222000002111120002211112201111111111"},
			{"11111111111112222111112000021111102201111120000211111022011111200002111112222111"},
			{"11111111110000000000110000001111222222111111111111112222221122000000221100000011"},
			{"00000000000000hh00000000hh0000h0&0hh0&0hhwwwhhwwwhhwwwhhwwwhhhwwhhwwhh1111111111"},
		},
		[module.HD_SUBCHUNKID.PATH] = {
			{"60000600000000000000000000000000000000000050000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000005000050000000000000000000000001111111111"},
			{"60000600000000000000000000000000050000000000000000000000000011111111111111111111"},
			{"60000600000000000000000600000000000000000000000000000222220000111111001111111111"},
			{"11111111112222222222000000000000000000000050000000000000000000000000001111111111"},
			{"11111111112111111112022222222000000000000050000000000000000000000000001111111111"},
			{"00000000000000q00000000020000000q010q0000020102000q0101010q01s1s1s1s1s1111111111"},
			{
			  "000000011000001100L00110L000L000L0L000L000L00000L000L000000000000000001100000011",
			  "01100000000L001100000L000L01100L000L0L000L00000L000000000L0000000000001100000011"
			},
			{"00011110000002112000000022000011200002110112002110022000022000002200001111111111"},
			{"0000000000000hhhh000000h00h00000hhhhhh0000hh00hh000hhhhhhhh00h00hh00h0hh0hhhh0hh"},
			{"00000000000000000000000000000000000000000021111200021111112021111111121111111111"},
			{
			  "00000000000111000000001110000001110000000011150000011100000000111000001112111111",
			  "00000000000000001110000001110000000011105000011100000000111000000111001111112111"
			},
			{
				"0000000000000000000000000000000000&00000013wwww310013wwww3101113w331111111111111",--000000000000000000000000&000000000000000013wwww310013wwww31011133331111111111111
				"00000000000000000000000000000000000&0000013wwww310013wwww31011133w31111111111111",--0000000000000000000000000&00000000000000013wwww310013wwww31011133331111111111111
			},
			{"hhhhhhhhhhh00000000h00rr00rr00h00000000hh========h000000000000000000001111111111"}
		},
		[module.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001200011111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111100021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"001000010000L0110L0000L2112L0000L2112L0000L2112L0000L0110L0000001100001000000001"},
			{"00000000000f000000f00000000000000q00q00000010010000f010010f000010010001111001111"},
			{"11111111112222222222000000000000000000000000000000000000000000000000001120000211"},
			{"50000500000000000000000000000011111111110211111120002222220000000000001100000011"},
			{"11111111112222111111000002211100000002110000000000200000000000000000211120000211"},
			{"11111111111111112222111220000011200000000000000000000000000012000000001120000211"},
			{"11111111112111111112021111112000211112000002112000000022000002200002201111001111"}
		},
		[module.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"00000000000000000000000000000000000000000050000000000000000000000000001111111111"},
			{
			"hhq0000hhhh000000q0q00qhqh0000h=h0000q=q0000q000000010h1200000002122201111111111",
			"hhh0000qhhh0q000000h0000hqhq00h=q0000h=h00000q000000021h010002221200001111111111"
			},
			{"hhhq00qhhhq00000000q000q00q000q==h00h==q0000000000000000000000000000001111111111"},
			{"00000000000000000000000600000000000000000000000000000111110000111111001111111111"},
			{"000000000000000000000000000000000000000000210012000021001200ssssssssss1111111111"},
			{"00000000000000000000000000000000000000000021111200021111112001111111101111111111"},
			{"10000000011112002111111200211110000000010022222200001111110002111111201111111111"},
			{"00000000000000000000000000000000ffffff000000000000020000002011ssssss111111111111"},
			{
				"0000000000000000000000000000000000&00000013wwww310013wwww3101113w331111111111111",--000000000000000000000000&000000000000000013wwww310013wwww31011133331111111111111
				"00000000000000000000000000000000000&0000013wwww310013wwww31011133w31111111111111",--0000000000000000000000000&00000000000000013wwww310013wwww31011133331111111111111
			}
		},
		[module.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001200011111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111100021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"001000010000L0110L0000L2112L0000L2112L0000L2112L0000L0110L0000001100001000000001"},
			{"00000000000f000000f00000000000000q00q00000010010000f010010f000010010001111001111"},
		},
		[module.HD_SUBCHUNKID.ENTRANCE] = {
			{
			"1100000L002h09000L00hhhhhhhL00h000000L000050000L000000000L0000000000001111111111",
			"00L000001100L00090h200Lhhhhhhh00L000000h00L500000000L000000000000000001111111111"
			},
			{
			"0000000000000900000000hhh0000000hhhh000000hhhhh00000hhhhhh000hhhh222001111111111",
			"0000000000000000900000000hhh000000hhhh00000hhhhh0000hhhhhh0000222hhhh01111111111"
			},
			{
			"000L00L0000hhL00Lhh00hhL00Lhh00hhL00Lhh00hhL00Lhh00hh0900hh01hh====hh11hhhhhhhh1",
			"000L00L0000hhL00Lhh00hhL00Lhh00hhL00Lhh00hhL00Lhh00hh0090hh01hh====hh11hhhhhhhh1"
			},
		},
		[module.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
			"1100000L002h09000L00hhhhhhhL00h060000L000000000L000000000L0000000000001111001111",
			"00L000001100L00090h200Lhhhhhhh00L600000h00L000000000L000000000000000001111001111"
			},
			{
			"0000000000000900000000hhh0000000hhhh000000hhhhh00000hhhhhh000hhhh000001111101111",
			"0000000000000000900000000hhh000000hhhh00000hhhhh0000hhhhhh0000000hhhh01111011111"
			},
			{
			"000L00L0000hhL00Lhh00hhL00Lhh00hhL00Lhh00hh0000hh00hh0900hh01hh==0=hh11hhhh0hhh1",
			"000L00L0000hhL00Lhh00hhL00Lhh00hhL00Lhh00hh0000hh00hh0090hh01hh=0==hh11hhh0hhhh1"
			}
		},
		-- # TODO: Verify that these are the correct arrangements of exit roomcodes.
		[module.HD_SUBCHUNKID.EXIT] = {
			-- {"000000000000100hhhh000100h00h000110h00h2001200000090111h==h011111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000hhhh001000h00h001002h00h0110000000021000h==h1110902111111111111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"}
		},
		[module.HD_SUBCHUNKID.EXIT_NOTOP] = {
			-- {"00000000006000060000000000000000000000000008000000000000000000000000001111111111"}, --probably unused
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"000000000000100hhhh000100h00h000110h00h2001200000090111h==h011111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000hhhh001000h00h001002h00h0110000000021000h==h1110902111111111111111111"},
		},
		[module.HD_SUBCHUNKID.IDOL] = {{"111111111101*1111*10001111110000000000000000I000000011A0110001*1111*101111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP] = {{"00000000000000000000001wwww100001wwww100011111111001100001100000g000001111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000011ww11000011ww1100011111111001100001100000g000001111111111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"01111111100011111100000000000022000000220000g0000000001100000000QQ00001111001111"}},
		[module.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"01110011100011001100000000000022000000220000g0000000001100000000QQ00001111001111"}},
	},
	obstacleBlocks = {
		[module.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000000022222"},
			{"000002222211111"},
			{"000000000000022"},
			{"00000sssss11111"},
			{"000000000022000"}
		},
		[module.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111102222000000"},
			{"011110222200000"},
			{"222200000000000"},
			{"022220000000000"},
			{"011100222000000"},
			{"000000ssss01111"},
			{"00000ssss011110"},
		},
		[module.HD_OBSTACLEBLOCK.VINE.tilename] = {
			{"0hhh000u000000000000"},
			{"0hhh00u0u00000000000"},
			{"0hhh00uu000000000000"},
			{"0hh00hhhh0uhhu000000"},--uhhu0"}, -- the last row is unused in HD
			{"00hh00hhhh0uhhu00000"},--0uhhu"}, -- the last row is unused in HD
		},
		[module.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"}
		},
	},
}

return module