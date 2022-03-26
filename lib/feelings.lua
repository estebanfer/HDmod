local module = {}

module.FEELING_ID = {
    UDJAT = 1,
    WORMTONGUE = 2,
    SPIDERLAIR = 3,
    SNAKEPIT = 4,
    RESTLESS = 5,
    HIVE = 6,
    TIKIVILLAGE = 7,
    RUSHING_WATER = 8,
    BLACKMARKET_ENTRANCE = 9,
    BLACKMARKET = 10,
    HAUNTEDCASTLE = 11,
    YETIKINGDOM = 12,
    UFO = 13,
    MOAI = 14,
    MOTHERSHIP_ENTRANCE = 15,
    SACRIFICIALPIT = 16,
    VLAD = 17,
    VAULT = 18,
    SNOW = 19,
    SNOWING = 20,
    ICE_CAVES_POOL = 21,
    ANUBIS = 22,
    YAMA = 23
}

module.HD_FEELING_DEFAULTS = {
	[module.FEELING_ID.HIVE] = {
		-- chance = 10,
		chance = 0,
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.UDJAT] = {
		themes = { THEME.DWELLING }
	},
	[module.FEELING_ID.WORMTONGUE] = {
		themes = { THEME.JUNGLE, THEME.ICE_CAVES }
	},
	[module.FEELING_ID.SPIDERLAIR] = {
		chance = 12,
		-- chance = 1,
		themes = { THEME.DWELLING },
		message = "My skin is crawling..."
	},
	[module.FEELING_ID.SNAKEPIT] = {
		chance = 10,
		-- chance = 0,
		themes = { THEME.DWELLING },
		message = "I hear snakes... I hate snakes!"
	},
	[module.FEELING_ID.RESTLESS] = {
		chance = 12,
		-- chance = 1,
		themes = { THEME.JUNGLE },
		message = "The dead are restless!"
	},
	[module.FEELING_ID.TIKIVILLAGE] = { -- RESIDENT TIK-EVIL: VILLAGE
		chance = 15,
		-- chance = 1,
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.RUSHING_WATER] = {
		chance = 14,
		-- chance = 1,
		themes = { THEME.JUNGLE },
		message = "I hear rushing water!"
	},
	[module.FEELING_ID.BLACKMARKET_ENTRANCE] = {
		themes = { THEME.JUNGLE }
	},
	[module.FEELING_ID.BLACKMARKET] = {
		themes = { THEME.JUNGLE },
		message = "Welcome to the Black Market!"
	},
	[module.FEELING_ID.HAUNTEDCASTLE] = {
		themes = { THEME.JUNGLE },
		message = "A wolf howls in the distance..."
	},
	[module.FEELING_ID.YETIKINGDOM] = {
		chance = 10,
		-- chance = 1,
		themes = { THEME.ICE_CAVES },
		message = "It smells like wet fur in here."
	},
	[module.FEELING_ID.UFO] = {
		chance = 12,
		-- chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "I sense a psychic presence here!"
	},
	[module.FEELING_ID.MOAI] = {
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.MOTHERSHIP_ENTRANCE] = {
		themes = { THEME.ICE_CAVES },
		message = "It feels like the fourth of July..."
	},
	[module.FEELING_ID.SACRIFICIALPIT] = {
		chance = 10,
		-- chance = 0,
		themes = { THEME.TEMPLE },
		message = "You hear prayers to Kali!"
	},
	[module.FEELING_ID.VLAD] = {
		themes = { THEME.VOLCANA },
		load = 1,
		message = "A horrible feeling of nausea comes over you!"
	},
	[module.FEELING_ID.YAMA] = {
		themes = { THEME.VOLCANA },
		load = 4
	},
	[module.FEELING_ID.VAULT] = {
		themes = {
			THEME.DWELLING,
			THEME.JUNGLE,
			THEME.ICE_CAVES,
			THEME.TEMPLE
		}
	},
	[module.FEELING_ID.SNOW] = {
		chance = 4,
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.SNOWING] = {
		chance = 4,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.ICE_CAVES_POOL] = {
		chance = 15,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[module.FEELING_ID.ANUBIS] = {
		themes = { THEME.TEMPLE },
		load = 1,
	},
}

return module