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

    module = {}

    module.SIDE = 0
    module.PATH = 1
    module.PATH_DROP = 2
    module.PATH_NOTOP = 3
    module.PATH_DROP_NOTOP = 4
    module.ENTRANCE = 5
    module.ENTRANCE_DROP = 6
    module.EXIT = 7
    module.EXIT_NOTOP = 8
    
    module.IDOL = 9
    
    module.ALTAR = 10
    
    module.MOAI = 15
    
    module.COFFIN_COOP = 43             -- HD: 43
    module.COFFIN_COOP_NOTOP = 45       -- HD: 45
    module.COFFIN_COOP_DROP = 44        -- HD: 44
    module.COFFIN_COOP_DROP_NOTOP = 46  -- HD: 44
    
    module.COFFIN_UNLOCK_RIGHT = 73
    module.COFFIN_UNLOCK_LEFT = 74
    module.COFFIN_UNLOCK = 75             -- HD: 43
    module.COFFIN_UNLOCK_NOTOP = 76       -- HD: 45
    module.COFFIN_UNLOCK_DROP = 77        -- HD: 44
    module.COFFIN_UNLOCK_DROP_NOTOP = 78  -- HD: 44
    
    module.SHOP_REGULAR = 1000
    module.SHOP_REGULAR_LEFT = 1001
    module.SHOP_PRIZE = 1002
    module.SHOP_PRIZE_LEFT = 1003
    module.SHOP_BROTHEL = 1004
    module.SHOP_BROTHEL_LEFT = 1005
    module.SHOP_UNKNOWN1 = 1006
    module.SHOP_UNKNOWN1_LEFT = 1007
    module.SHOP_UNKNOWN2 = 1008
    module.SHOP_UNKNOWN2_LEFT = 1009
    
    module.VAULT = 1010
    
    module.SNAKEPIT_TOP = 106
    module.SNAKEPIT_MIDSECTION = 107
    module.SNAKEPIT_BOTTOM = 108
    
    
    module.SPIDERLAIR_RIGHTSIDE = 130
    module.SPIDERLAIR_RIGHTSIDE_NOTOP = 131
    module.SPIDERLAIR_RIGHTSIDE_DROP = 132
    module.SPIDERLAIR_RIGHTSIDE_DROP_NOTOP = 133
    module.SPIDERLAIR_LEFTSIDE = 134
    module.SPIDERLAIR_LEFTSIDE_NOTOP = 135
    module.SPIDERLAIR_LEFTSIDE_DROP = 136
    module.SPIDERLAIR_LEFTSIDE_DROP_NOTOP = 137
    module.SPIDERLAIR_LEFTSIDE_UNLOCK = 138
    module.SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP = 139
    
    module.BLACKMARKET_ANKH = 2010
    module.BLACKMARKET_SHOP = 2011
    
    module.TIKIVILLAGE_PATH = 1030
    module.TIKIVILLAGE_PATH_DROP = 1031
    module.TIKIVILLAGE_PATH_NOTOP = 1032
    module.TIKIVILLAGE_PATH_DROP_NOTOP = 1033
    
    module.TIKIVILLAGE_PATH_NOTOP_LEFT = 1034
    module.TIKIVILLAGE_PATH_NOTOP_RIGHT = 1035
    
    module.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT = 1036
    module.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT = 1037
    
    module.RUSHING_WATER_EXIT = 1101
    module.RUSHING_WATER_PATH = 1102
    module.RUSHING_WATER_SIDE = 1103
    module.RUSHING_WATER_OLBITEY = 1104
    module.RUSHING_WATER_BOTTOM = 1105
    module.RUSHING_WATER_UNLOCK_LEFTSIDE = 1145
    module.RUSHING_WATER_UNLOCK_RIGHTSIDE = 1146
    
    module.WORM_CRYSKNIFE_LEFTSIDE = 1241
    module.WORM_CRYSKNIFE_RIGHTSIDE = 1242
    module.WORM_REGENBLOCK_STRUCTURE = 1275
    
    module.COG_BOTD_LEFTSIDE = 126
    module.COG_BOTD_RIGHTSIDE = 127
    
    module.UFO_LEFTSIDE = 112
    module.UFO_MIDDLE = 113
    module.UFO_RIGHTSIDE = 114
    
    module.YETIKINGDOM_YETIKING = 301
    module.YETIKINGDOM_YETIKING_NOTOP = 302
    
    module.ICE_CAVES_ROW_FIVE = 355
    
    module.ICE_CAVES_POOL_SINGLE = 368
    module.ICE_CAVES_POOL_DOUBLE_TOP = 369
    module.ICE_CAVES_POOL_DOUBLE_BOTTOM = 370
    
    module.MOTHERSHIPENTRANCE_TOP = 128
    module.MOTHERSHIPENTRANCE_BOTTOM = 129
    
    module.MOTHERSHIP_ALIENQUEEN = 2001
    module.MOTHERSHIP_ALIENLORD = 2002
    
    module.RESTLESS_TOMB = 147
    module.RESTLESS_IDOL = 148
    
    module.HAUNTEDCASTLE_SETROOM_1_2 = 200
    module.HAUNTEDCASTLE_SETROOM_1_3 = 201
    module.HAUNTEDCASTLE_MIDDLE = 202
    module.HAUNTEDCASTLE_MIDDLE_DROP = 203
    module.HAUNTEDCASTLE_BOTTOM = 204
    module.HAUNTEDCASTLE_BOTTOM_NOTOP = 205
    module.HAUNTEDCASTLE_WALL = 206
    module.HAUNTEDCASTLE_WALL_DROP = 207
    module.HAUNTEDCASTLE_GATE = 208
    module.HAUNTEDCASTLE_GATE_NOTOP = 209
    module.HAUNTEDCASTLE_MOAT = 210
    module.HAUNTEDCASTLE_UNLOCK = 211
    module.HAUNTEDCASTLE_EXIT = 212
    module.HAUNTEDCASTLE_EXIT_NOTOP = 213
    
    module.SACRIFICIALPIT_TOP = 116
    module.SACRIFICIALPIT_MIDSECTION = 117
    module.SACRIFICIALPIT_BOTTOM = 118
    
    module.OLMEC_ROW_FIVE = 444
    
    module.VLAD_TOP = 119
    module.VLAD_MIDSECTION = 120
    module.VLAD_BOTTOM = 121
    
    module.YAMA_EXIT = 500
    module.YAMA_ENTRANCE = 501
    module.YAMA_TOP = 502
    module.YAMA_LEFTSIDE = 503
    module.YAMA_RIGHTSIDE = 504
    module.YAMA_SETROOM_1_2 = 505
    module.YAMA_SETROOM_1_3 = 506
    module.YAMA_SETROOM_2_2 = 507
    module.YAMA_SETROOM_2_3 = 508
    module.YAMA_SETROOM_3_2 = 509
    module.YAMA_SETROOM_3_3 = 510
    module.YAMA_SETROOM_4_1 = 511
    module.YAMA_SETROOM_4_3 = 512
    module.YAMA_SETROOM_4_4 = 513
    

return module