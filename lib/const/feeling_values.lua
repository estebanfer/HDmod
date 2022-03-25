FEELING_ID = require 'feeling_ids'

local module = {}

module = {
	[FEELING_ID.HIVE] = {
		-- chance = 10,
		chance = 0,
		themes = { THEME.JUNGLE }
	},
	[FEELING_ID.UDJAT] = {
		themes = { THEME.DWELLING }
	},
	[FEELING_ID.WORMTONGUE] = {
		themes = { THEME.JUNGLE, THEME.ICE_CAVES }
	},
	[FEELING_ID.SPIDERLAIR] = {
		chance = 12,
		-- chance = 1,
		themes = { THEME.DWELLING },
		message = "My skin is crawling..."
	},
	[FEELING_ID.SNAKEPIT] = {
		chance = 10,
		-- chance = 0,
		themes = { THEME.DWELLING },
		message = "I hear snakes... I hate snakes!"
	},
	[FEELING_ID.RESTLESS] = {
		chance = 12,
		-- chance = 1,
		themes = { THEME.JUNGLE },
		message = "The dead are restless!"
	},
	[FEELING_ID.TIKIVILLAGE] = { -- RESIDENT TIK-EVIL: VILLAGE
		chance = 15,
		-- chance = 1,
		themes = { THEME.JUNGLE }
	},
	[FEELING_ID.RUSHING_WATER] = {
		chance = 14,
		-- chance = 1,
		themes = { THEME.JUNGLE },
		message = "I hear rushing water!"
	},
	[FEELING_ID.BLACKMARKET_ENTRANCE] = {
		themes = { THEME.JUNGLE }
	},
	[FEELING_ID.BLACKMARKET] = {
		themes = { THEME.JUNGLE },
		message = "Welcome to the Black Market!"
	},
	[FEELING_ID.HAUNTEDCASTLE] = {
		themes = { THEME.JUNGLE },
		message = "A wolf howls in the distance..."
	},
	[FEELING_ID.YETIKINGDOM] = {
		chance = 10,
		-- chance = 1,
		themes = { THEME.ICE_CAVES },
		message = "It smells like wet fur in here."
	},
	[FEELING_ID.UFO] = {
		chance = 12,
		-- chance = 0,
		themes = { THEME.ICE_CAVES },
		message = "I sense a psychic presence here!"
	},
	[FEELING_ID.MOAI] = {
		themes = { THEME.ICE_CAVES }
	},
	[FEELING_ID.MOTHERSHIP_ENTRANCE] = {
		themes = { THEME.ICE_CAVES },
		message = "It feels like the fourth of July..."
	},
	[FEELING_ID.SACRIFICIALPIT] = {
		chance = 10,
		-- chance = 0,
		themes = { THEME.TEMPLE },
		message = "You hear prayers to Kali!"
	},
	[FEELING_ID.VLAD] = {
		themes = { THEME.VOLCANA },
		load = 1,
		message = "A horrible feeling of nausea comes over you!"
	},
	[FEELING_ID.YAMA] = {
		themes = { THEME.VOLCANA },
		load = 4
	},
	[FEELING_ID.VAULT] = {
		themes = {
			THEME.DWELLING,
			THEME.JUNGLE,
			THEME.ICE_CAVES,
			THEME.TEMPLE
		}
	},
	[FEELING_ID.SNOW] = {
		chance = 4,
		themes = { THEME.ICE_CAVES }
	},
	[FEELING_ID.SNOWING] = {
		chance = 4,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[FEELING_ID.ICE_CAVES_POOL] = {
		chance = 15,
		-- chance = 0,
		themes = { THEME.ICE_CAVES }
	},
	[FEELING_ID.ANUBIS] = {
		themes = { THEME.TEMPLE },
		load = 1,
	},
}

return module