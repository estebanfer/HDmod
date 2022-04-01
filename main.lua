commonlib = require 'lib.common'
demolib = require 'lib.demo'
worldlib = require 'lib.worldstate'
camplib = require 'lib.camp'
genlib = require 'lib.roomgen'
feelingslib = require 'lib.feelings'
unlockslib = require 'lib.unlocks'
locatelib = require 'lib.locate'

hdtypelib = require 'lib.entities.hdtype'
botdlib = require 'lib.entities.botd'
wormtonguelib = require 'lib.entities.wormtongue'
ghostlib = require 'lib.entities.ghost'
olmeclib = require 'lib.entities.olmec'
boulderlib = require 'lib.entities.boulder'
idollib = require 'lib.entities.idol'

meta.name = "HDmod - Demo"
meta.version = "1.02"
meta.description = "Spelunky HD's campaign in Spelunky 2"
meta.author = "Super Ninja Fat"

register_option_bool("hd_debug_boss_exits_unlock", "Debug: Unlock boss exits",														false)
register_option_bool("hd_debug_feelingtoast_disable", "Debug: Disable script-enduced feeling toasts",								false)
register_option_bool("hd_debug_info_boss", "Debug: Info - Bossfight",																false)
register_option_bool("hd_debug_info_boulder", "Debug: Info - Boulder",																false)
register_option_bool("hd_debug_info_feelings", "Debug: Info - Level Feelings",														false)
register_option_bool("hd_debug_info_path", "Debug: Info - Path",																	false)
register_option_bool("hd_debug_info_tongue", "Debug: Info - Wormtongue",															false)
register_option_bool("hd_debug_info_worldstate", "Debug: Info - Worldstate",														false)
register_option_bool("hd_debug_scripted_enemies_show", "Debug: Enable visibility of entities used in custom enemy behavior",		false)
register_option_bool("hd_debug_item_botd_give", "Debug: Start with item - Book of the Dead",										false)
register_option_bool("hd_debug_scripted_levelgen_disable", "Debug: Disable scripted level generation",								false)
register_option_string("hd_debug_scripted_levelgen_tilecodes_blacklist",
	"Debug: Blacklist scripted level generation tilecodes",
	""
)
register_option_bool("hd_debug_testing_door", "Debug: Enable testing door in camp",													false)
register_option_bool("hd_og_floorstyle_temple", "OG: Set temple's floorstyle to stone instead of temple",							false)	-- Defaults to S2
-- register_option_bool("hd_og_ankhprice", "OG: Set the Ankh price to a constant $50,000 like it was in HD",							false)	-- Defaults to S2
register_option_bool("hd_og_boulder_agro_disable", "OG: Boulder - Don't enrage shopkeepers",										false)	-- Defaults to HD
register_option_bool("hd_og_ghost_nosplit_disable", "OG: Ghost - Allow the ghost to split",											false)	-- Defaults to HD
register_option_bool("hd_og_ghost_slow_enable", "OG: Ghost - Set the ghost to its HD speed",										false)	-- Defaults to S2
register_option_bool("hd_og_ghost_time_disable", "OG: Ghost - Use S2 spawntimes: 2:30->3:00 and 2:00->2:30 when cursed.",			false)	-- Defaults to HD
register_option_bool("hd_og_cursepot_enable", "OG: Enable curse pot spawning",														false)	-- Defaults to HD
register_option_bool("hd_og_tree_spawn", "OG: Tree spawns - Spawn trees in S2 style instead of HD",									false)	-- Defaults to HD

-- # TODO: revise from the old system, removing old uses.
-- Then, rename it to `hd_og_use_s2_spawns`
-- Reimplement it into `is_valid_*_spawn` methods to change spawns.
register_option_bool("hd_og_procedural_spawns_disable", "OG: Use S2 instead of HD procedural spawning conditions",				false)	-- Defaults to HD

-- # TODO: Influence the velocity of the boulder on every frame.
-- register_option_bool("hd_og_boulder_phys", "OG: Boulder - Adjust to have the same physics as HD",									false)

local floor_types = {ENT_TYPE.FLOOR_GENERIC, ENT_TYPE.FLOOR_JUNGLE, ENT_TYPE.FLOORSTYLED_MINEWOOD, ENT_TYPE.FLOORSTYLED_STONE, ENT_TYPE.FLOORSTYLED_TEMPLE, ENT_TYPE.FLOORSTYLED_COG, ENT_TYPE.FLOORSTYLED_PAGODA, ENT_TYPE.FLOORSTYLED_BABYLON, ENT_TYPE.FLOORSTYLED_SUNKEN, ENT_TYPE.FLOORSTYLED_BEEHIVE, ENT_TYPE.FLOORSTYLED_VLAD, ENT_TYPE.FLOORSTYLED_MOTHERSHIP, ENT_TYPE.FLOORSTYLED_DUAT, ENT_TYPE.FLOORSTYLED_PALACE, ENT_TYPE.FLOORSTYLED_GUTS, ENT_TYPE.FLOOR_SURFACE}
local valid_floors = commonlib.TableConcat(floor_types, {ENT_TYPE.FLOOR_ICE})

ACID_POISONTIME = 270 -- For reference, HD's was 3-4 seconds
global_levelassembly = nil
POSTTILE_STARTBOOL = false
FRAG_PREVENTION_UID = nil
LEVEL_UNLOCK = nil
UNLOCK_WI, UNLOCK_HI = nil, nil
CHARACTER_UNLOCK_SPAWNED_DURING_RUN = false
COOP_COFFIN = false
acid_tick = ACID_POISONTIME
tombstone_blocks = {}
moai_veil = nil
HELL_Y = 86
DOOR_EXIT_TO_HAUNTEDCASTLE_POS = nil
DOOR_EXIT_TO_BLACKMARKET_POS = nil
DOOR_TESTING_UID = nil
DOOR_TUTORIAL_UID = nil

HD_THEMEORDER = {
	THEME.DWELLING,
	THEME.JUNGLE,
	THEME.ICE_CAVES,
	THEME.TEMPLE,
	THEME.VOLCANA
}

-- retains HD tilenames
HD_TILENAME = {
	["0"] = {
		description = "Empty",
	},
	["#"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l, 0, 0) end
			},
			alternate = {
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l)
						if not options.hd_debug_item_botd_give then
							botdlib.create_botd(x, y, l)
						end
					end
				}
			},
		},
		description = "TNT Box",
	},
	["$"] = {
		description = "Roulette Item",
	},
	["%"] = {
		description = "Roulette Door",
	},
	["&"] = { -- 50% chance to spawn # TOTEST probably wrong
		phase_1 = {
			default = {
				function(x, y, l) create_liquidfall(x, y-2.5, l, "res/floor_jungle_fountain.png") end,
			},
			alternate = {
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l) create_liquidfall(x, y-3, l, "res/floorstyled_gold_fountain.png", true) end,
				},
				[THEME.TEMPLE] = {
					function(x, y, l) create_liquidfall(x, y-3, l, "res/floorstyled_temple_fountain.png", true) end,
				},
				[THEME.VOLCANA] = {
					function(x, y, l) create_liquidfall(x, y-3, l, "res/hell_fountain.png", true) end,
				},
			},
		},
		-- offset = { 0, -2.5 },
		-- alternate_offset = {
		-- 	[THEME.CITY_OF_GOLD] = { 0, 0 },
		-- 	[THEME.TEMPLE] = { 0, 0 },
		-- 	[THEME.VOLCANA] = { 0, 0 },
		-- },
		description = "Waterfall",
	},
	["*"] = {
		phase_1 = {
			default = {
				-- function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0) end,
			},
			alternate = {
				[THEME.NEO_BABYLON] = {
					function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PLASMACANNON, x, y, l, 0, 0) end,
				},
			},
		},
		-- hd_type = hdtypelib.HD_ENT.TRAP_SPIKEBALL
		-- spawn method for plasma cannon in HD spawned a tile under it, stylized
		description = "Spikeball",
	},
	["+"] = {
		phase_1 = {
			default = { function(x, y, l) return 0 end },--ENT_TYPE.BG_LEVEL_BACKWALL},
			alternate = {
				[THEME.ICE_CAVES] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l, 0, 0) end,
				},
			},
		},
		description = "Wooden Background",
	},
	[","] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l, 0, 0) end,
			},
		},
		description = "Terrain/Wood",
	},
	["-"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_THINICE, x, y, l, 0, 0) end,},
		},
		description = "Cracking Ice",
	},
	["."] = {
		-- S2 doesn't like spawning ANY floor in these places for some reason, so we're going to use S2 gen for this
		phase_1 = {
			default = {
				function(x, y, l)
					local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0))
					entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
				end,
			},
			alternate = {
				[THEME.TEMPLE] = {
					function(x, y, l)
						local entity = get_entity(spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0))
						entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
					end,
				}
			}
		},
		description = "Unmodified Terrain",
	},
	["1"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l, 0, 0) end,},
				[THEME.ICE_CAVES] = {
					function(x, y, l)
						if (
							feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM)
						) then
							if (math.random(6) == 1) then
								spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0)
							else
								spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l, 0, 0)
							end
						else
							spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0)
						end
					end,
				},
				[THEME.NEO_BABYLON] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l, 0, 0) end,},
				[THEME.OLMEC] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l, 0, 0) end,},
				[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0) end,},
				[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0) end,},
			},
		},
		description = "Terrain",
	},
	["2"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,
				function(x, y, l) return 0 end,
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					function(x, y, l)
						if math.random(2) == 1 then
							if math.random(10) == 1 then
								create_regenblock(x, y, l)
							else
								spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l, 0, 0)
							end
						else return 0 end
					end,
				},
				[THEME.NEO_BABYLON] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
				[THEME.OLMEC] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
				[THEME.TEMPLE] = {
					function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
			},
		},
		description = "Terrain/Empty",
	},
	["3"] = {
		phase_3 = {
			default = {
				function(x, y, l)
					local floors = get_entities_at(0, MASK.FLOOR, x, y, l, 0.5)
					if #floors == 0 then
						spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y)
						return ENT_TYPE.LIQUID_WATER
					end
				end,
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					function(x, y, l)
						local floors = get_entities_at(0, MASK.FLOOR, x, y, l, 0.5)
						if #floors == 0 then
							spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y)
							return ENT_TYPE.LIQUID_WATER
						end
					end,
				},
				[THEME.TEMPLE] = {
					function(x, y, l)
						local floors = get_entities_at(0, MASK.FLOOR, x, y, l, 0.5)
						if #floors == 0 then
							spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y)
							return ENT_TYPE.LIQUID_LAVA
						end
					end,
				},
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l)
						local floors = get_entities_at(0, MASK.FLOOR, x, y, l, 0.5)
						if #floors == 0 then
							spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y)
							return ENT_TYPE.LIQUID_LAVA
						end
					end,
				},
				[THEME.VOLCANA] = {
					function(x, y, l)
						local floors = get_entities_at(0, MASK.FLOOR, x, y, l, 0.5)
						if #floors == 0 then
							spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y)
							return ENT_TYPE.LIQUID_LAVA
						end
					end,
				},
			},
		},
		phase_1 = {
			default = {
				function(x, y, l)
					local uid = spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0)
					-- get_entity(uid):fix_decorations(true, true)
				end,
				function(x, y, l)
				end,
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					function(x, y, l)
						local uid = spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l, 0, 0)
						-- get_entity(uid):fix_decorations(true, true)
					end,
					function(x, y, l) return ENT_TYPE.LIQUID_WATER end,
				},
				[THEME.TEMPLE] = {
					function(x, y, l)
						local uid = spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0)
						-- get_entity(uid):fix_decorations(true, true)
					end,
					function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
				},
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l)
						local uid = spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0)
						-- get_entity(uid):fix_decorations(true, true)
					end,
					function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
				},
				[THEME.VOLCANA] = {
					function(x, y, l)
						local uid = spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0)
						-- get_entity(uid):fix_decorations(true, true)
					end,
					function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
				},
			},
		},
		description = "Terrain/Water",
	},
	["4"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0) end,},
		},
		description = "Pushblock",
	},
	["5"] = {
		description = "Ground Obstacle Block",
	},
	["6"] = {
		description = "Floating Obstacle Block",
	},
	["7"] = {
		phase_2 = {
			default = {
				function(x, y, l)
					floorsAtOffset = get_entities_at(0, MASK.FLOOR, x, y-1, LAYER.FRONT, 0.5)
					-- # TOTEST: If gems/gold/items are spawning over this, move this method to run after gems/gold/items get embedded. Then here, detect and remove any items already embedded.
					
					if #floorsAtOffset > 0 then
						local floor_uid = floorsAtOffset[1]
						-- local floor = get_entity(floor_uid)
						
						spawn_entity_over(ENT_TYPE.FLOOR_SPIKES, floor_uid, 0, 1)
						-- if state.theme == THEME.EGGPLANT_WORLD then
						-- 	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_GUTS_0)
						-- 	deco_texture = define_texture(texture_def)

						-- 	floor:add_decoration(FLOOR_SIDE.TOP)
							
						-- 	if floor.deco_top ~= -1 then
						-- 		local deco = get_entity(floor.deco_top)
						-- 		deco:set_texture(deco_texture)
						-- 	end
						-- end
					end
				end,
				function(x, y, l) return 0 end
			},
		},
		description = "Spikes/Empty",
	},
	["8"] = {
		description = "Door with Terrain Block",
	},
	["9"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					-- need subchunkid of what room we're in
					local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
					local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
					
					if (
						(_subchunk_id == genlib.HD_SUBCHUNKID.ENTRANCE)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.ENTRANCE_DROP)
					) then
						create_door_entrance(x, y, l)
					elseif (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_ENTRANCE) then
						create_door_entrance(x+0.5, y, l)
					elseif (
						(_subchunk_id == genlib.HD_SUBCHUNKID.EXIT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.EXIT_NOTOP)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.RUSHING_WATER_EXIT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP)
					) then
						-- spawn an exit door to the next level. Spawn a shopkeeper if agro.
						create_door_exit(x, y, l)
					elseif (_subchunk_id == genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP) then
						create_door_exit_to_mothership(x, y, l)
					elseif (_subchunk_id == genlib.HD_SUBCHUNKID.RESTLESS_TOMB) then
						-- Spawn king's tombstone
						local block_uid = spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP, x, y, l, 0, 0)
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
						texture_def.texture_path = "res/floormisc_tombstone_king.png"
						get_entity(block_uid):set_texture(define_texture(texture_def))
						
						-- 2 tiles down
						-- Spawn skeleton
						spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_BONES, x-0.1, y-2, l, 0, 0)
						local skull_uid = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_SKULL, x+0.1, y-2, l, 0, 0)
						flip_entity(skull_uid)

						-- Spawn Crown
						-- local dar_crown = get_entity(spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_DIAMOND, x, y-2, l, 0, 0))
						local dar_crown_uid = spawn_entity_over(ENT_TYPE.ITEM_DIAMOND, skull_uid, -0.15, 0.42)
						local dar_crown = get_entity(dar_crown_uid)
						-- # TODO: Setting the crown angled results in it staying angled when knocked off.
						-- Make an on frame method to adjust the angle after dismount
						-- dar_crown.angle = -0.15

						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
						texture_def.texture_path = "res/items_dar_crown.png"
						dar_crown:set_texture(define_texture(texture_def))

						-- 4 tiles down
						-- Spawn hidden entrance
						create_door_exit_to_hauntedcastle(x, y-4, l)
					elseif (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_EXIT) then
						create_door_ending(x, y, l)
					end
				end
			},
		},
		description = "Exit/Entrance/Special Door", -- old description: "Door without Platform"
	},
	[":"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCORPION, x, y, l, 0, 0) end,
			},
			alternate = {
				[THEME.JUNGLE] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_TIKIMAN, x, y, l, 0, 0) end,
					function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l, 0, 0) end,
				},
				[THEME.ICE_CAVES] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l, 0, 0) end,},
				[THEME.NEO_BABYLON] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l, 0, 0) end,
					function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l, 0, 0) end,
				}
			},
		},
		description = "World-specific Enemy Spawn",--"Scorpion from Mines Coffin",
	},
	[";"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					create_damsel(x, y, l)
					create_idol(x+1, y, l)
				end,
			},
			alternate = {
				-- force field spawning method, rows of 3.
				[THEME.ICE_CAVES] = {
					function(x, y, l) return 0 end,
				},
				[THEME.NEO_BABYLON] = {
					function(x, y, l) return 0 end,
				},
			}
		},
		description = "Damsel and Idol from Kalipit",
	},
	["="] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.VOLCANA] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l, 0, 0) end,
				}
			},
		},
		description = "Wood with Background",
	},
	["A"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					local idol_block_first = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_IDOL_BLOCK, x, y, l, 0, 0))
					local idol_block_second = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_IDOL_BLOCK, x+1, y, l, 0, 0))

					if state.theme ~= THEME.VOLCANA then
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0)
						texture_def.texture_path = "res/idol_platform_generic.png"
						if state.theme == THEME.TEMPLE then
							texture_def.texture_path = "res/idol_platform_temple.png"
						end

						idol_block_first:set_texture(define_texture(texture_def))
						idol_block_second:set_texture(define_texture(texture_def))
					end
					idol_block_second.animation_frame = idol_block_second.animation_frame + 1
				end,
			},
		},
		description = "Idol Platform", --"Mines Idol Platform",
	},
	["B"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					local block_uid = spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP, x, y, l, 0, 0)
					local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
					texture_def.texture_path = "res/floormisc_idoltrap_floor.png"
					get_entity(block_uid):set_texture(define_texture(texture_def))
					idollib.idoltrap_blocks[#idollib.idoltrap_blocks+1] = block_uid
				end,
			},
		},
		description = "Jungle/Temple Idol Platform",
	},
	["C"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					local block_uid = spawn(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0)
					local block = get_entity(block_uid)
					block.flags = set_flag(block.flags, ENT_FLAG.NO_GRAVITY)
					block.more_flags = set_flag(block.more_flags, 17)
					idollib.idoltrap_blocks[#idollib.idoltrap_blocks+1] = block_uid
				end,
			},
			alternate = {
				[THEME.VOLCANA] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0) end},
			},
		},
		description = "Temple Idol Trap Ceiling Block",--"Nonmovable Pushblock", -- also idol trap ceiling blocks
	},
	["D"] = {
		phase_1 = {
			default = {function(x, y, l)
				local slidingwall_ceiling = get_entity(spawn_entity(ENT_TYPE.FLOOR_SLIDINGWALL_CEILING, x, y, l, 0.0, 0.0))
				local slidingwall_chain = get_entity(spawn_over(ENT_TYPE.ITEM_SLIDINGWALL_CHAIN_LASTPIECE, slidingwall_ceiling.uid, 0, 0))
				local slidingwall = get_entity(spawn_over(ENT_TYPE.ACTIVEFLOOR_SLIDINGWALL, slidingwall_chain.uid, 0, -1.5))
				
				if state.theme == THEME.TEMPLE then
					local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_0)
					texture_def.texture_path = "res/floorstyled_temple_slidingwall.png"
					slidingwall_ceiling:set_texture(define_texture(texture_def))
					slidingwall_chain:set_texture(define_texture(texture_def))
	
					texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_PAGODA_1)
					texture_def.texture_path = "res/floorstyled_temple_slidingwall.png"
					slidingwall:set_texture(define_texture(texture_def))
				end

				-- spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x+1, y-1, l, 0, 0)

				--[[ this code causes the game to crash
				slidingwall_ceiling.active_floor_part_uid = slidingwall.uid
				slidingwall_ceiling.state = 1
				slidingwall_chain.attached_to_uid = -1
				slidingwall_chain.timer = -1
				slidingwall.ceiling = slidingwall_ceiling
				--]]

			end},
			tutorial = {
				function(x, y, l) create_damsel(x, y, l) end,
			},
		},
		--#TOTEST: Also used in tutorial level 3 placement {3, 4} as Damsel
		-- # TODO: door creation (should be same door as "%")
		description = "Door Gate", -- also used in temple idol trap
	},
	["E"] = {
		phase_1 = {
			tutorial = {
				function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_GOLDBAR, x, y, l, 0, 0) end,
			},
			default = {
				function(x, y, l)
					if math.random(10) == 1 then
						spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0)
					elseif math.random(5) == 1 then
						spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0)
					elseif math.random(2) == 2 then
						tile_to_spawn = ENT_TYPE.FLOOR_GENERIC
						if state.theme == THEME.OLMEC then
							tile_to_spawn = ENT_TYPE.FLOORSTYLED_STONE
						elseif state.theme == THEME.CITY_OF_GOLD then
							tile_to_spawn = ENT_TYPE.FLOORSTYLED_COG
						elseif state.theme == THEME.TEMPLE then
							tile_to_spawn = (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE)
						end
						spawn_grid_entity(tile_to_spawn, x, y, l, 0, 0)
					else
						return 0
					end
				end,
				-- function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,
				-- function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0) end,
				-- function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0) end,
				-- function(x, y, l) return 0 end,
			},
			-- alternate = {
			-- 	[THEME.OLMEC] = {
			-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l, 0, 0) end,
			-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0) end,
			-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0) end,
			-- 		function(x, y, l) return 0 end,
			-- 	},
			-- [THEME.TEMPLE] = {
			-- 	function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0) end,
			-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0) end,
			-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0) end,
			-- 	function(x, y, l) return 0 end,
			-- },
			-- [THEME.CITY_OF_GOLD] = {
			-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0) end,
			-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0) end,
			-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0) end,
			-- 	function(x, y, l) return 0 end,
			-- },
			-- },
		},
		description = "Terrain/Empty/Crate/Chest",
	},
	["F"] = {
		description = "Falling Platform Obstacle Block",
	},
	["G"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l, 0, 0) end,
			},
		},
		description = "Ladder (Strict)",
	},
	["H"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l, 0, 0) end,
			},
		},
		description = "Ladder Platform (Strict)",
	},
	["I"] = {
		phase_2 = {
			default = {
				function(x, y, l)
					-- Idol trap variants
					if state.theme == THEME.DWELLING then
						local statue = get_entity(spawn_entity(ENT_TYPE.BG_BOULDER_STATUE, x+0.5, y+2.5, l, 0, 0))
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_ICE_1)
						texture_def.texture_path = "res/deco_extra_idol_statue.png"
						statue:set_texture(define_texture(texture_def))
					end
					
					-- need subchunkid of what room we're in
					local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
					local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
					
					if (
						(_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT)
					) then
						hdtypelib.create_hd_type(hdtypelib.HD_ENT.TRAP_TIKI, x, y, l, false, 0, 0)
					elseif (
						(_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_2)
						-- or (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_3)
					) then
						for i = 0, 10, 2 do
							local uid = hdtypelib.create_hd_type(hdtypelib.HD_ENT.TRAP_TIKI, x, y+i, l, false, 0, 0)
							-- uid = get_entities_at(ENT_TYPE.FLOOR_TRAP_TOTEM, 0, x, y+i, l, .5)[1]
							if uid ~= -1 then
								get_entity(uid).animation_frame = 12
							end
						end
						for i = 0, 10, 2 do
							local uid = hdtypelib.create_hd_type(hdtypelib.HD_ENT.TRAP_TIKI, x+7, y+i, l, false, 0, 0)
							-- uid = get_entities_at(ENT_TYPE.FLOOR_TRAP_TOTEM, 0, x, y+i, l, .5)[1]
							if uid ~= -1 then
								get_entity(uid).animation_frame = 12
							end
						end
					else
						-- SORRY NOTHING 
					end
				end,
			},
		},
		phase_1 = {
			default = {
				function(x, y, l)
					-- need subchunkid of what room we're in
					local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
					local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
					
					if (
						(_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_2)
						or (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_3)
					) then
						-- SORRY NOTHING 
					else
						create_idol(x+0.5, y, l)
					end
				end,
			},
		},
		description = "Idol", -- sometimes a tikitrap if it's a character unlock
	},
	["J"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_entity(ENT_TYPE.MONS_GIANTFISH, x, y, l, 0, 0) end,
			},
		},
		description = "Ol' Bitey",
	},
	["K"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x, y, l, 0, 0) end,
			},
		},
		description = "Shopkeeper",
	},
	["L"] = {
		-- phase_4 = {
		-- 	alternate = {
		-- 		[THEME.NEO_BABYLON] = {
		-- 			function(x, y, l)
		-- 				spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_SHIELD, x, y, l, 0, 0)
		-- 				return 0
		-- 			end,
		-- 		},
		-- 	}
		-- },
		phase_3 = {
			alternate = {
				[THEME.VOLCANA] = {
					function(x, y, l) create_ceiling_chain(x, y, l) end,
				},
			}
		},
		phase_2 = {
			alternate = {
				[THEME.VOLCANA] = {
					function(x, y, l) return 0 end,
				},
			}
		},
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.JUNGLE] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, y, l, 0, 0) end,},
				[THEME.EGGPLANT_WORLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, y, l, 0, 0) end,},

				[THEME.NEO_BABYLON] = {
					function(x, y, l) return 0 end,
				},
				[THEME.VOLCANA] = {function(x, y, l) return 0 end},
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l)
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0)
						texture_def.texture_path = "res/floorstyled_gold_ladders.png"
						local ent_texture = define_texture(texture_def)
						local ent_uid = spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l)
						get_entity(ent_uid):set_texture(ent_texture)
					end
				},
			},
		},
		description = "Ladder", -- sometimes used as Vine or Chain
	},
	["M"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					embed_item(ENT_TYPE.ITEM_MATTOCK, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0), 128)
				end,
			},
			alternate = {
				[THEME.ICE_CAVES] = {
					function(x, y, l)
						embed_item(ENT_TYPE.ITEM_JETPACK, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0), 41)
					end
				},
			}
		},
		description = "World-Specific Crust Item", --"Crust Mattock from Snake Pit",
	},
	["N"] = {
		phase_1 = {
			-- # TODO: In HD this seems to be a chance of either a snake or a cobra
			tutorial = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l, 0, 0) end,},
			default = {
				function(x, y, l)
					if math.random(4) == 1 then
						spawn_grid_entity(ENT_TYPE.MONS_COBRA, x, y, l, 0, 0)
					else
						spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l, 0, 0)
					end
				end,
			},
			alternate = {
				[THEME.JUNGLE] = {
					function(x, y, l) spawn_entity(ENT_TYPE.ITEM_LITWALLTORCH, x, y, l, 0, 0) end,
				}
			}
		},
		description = "Snake from Snake Pit",
	},
	["O"] = {
		-- # TODO: Moai ankh respawn mechanics
		-- # TODO: Foreground Entity/Texture
		phase_3 = {
			default = {
				function(x, y, l)
					local moai_texture_indices = { 0, 1, 8, 9, 16, 17, 24, 25, 32 } -- yada yada lazy programming yada yada
					local moai_index = 1
					local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
					texture_def.texture_path = "res/border_main_moai.png"
					for yi = 0, -3, -1 do
						for xi = 0, 2, 1 do
							if (yi ~= 0 and xi == 1) then
								-- SORRY NOTHING
							else
								local block_uid = get_grid_entity_at(x+xi, y+yi, l)
								if block_uid ~= -1 then
									local moai_block = get_entity(block_uid)
									moai_block:set_texture(define_texture(texture_def))
									moai_block.animation_frame = moai_texture_indices[moai_index]
									moai_index = moai_index + 1
								end
							end
						end
					end
				end
			}
		},
		phase_1 = {
			default = {
				--[[
					# TOFIX: Moai animation_frames get overridden.
						Run global_timeout(s?) to set them.
						>Mr Auto:
							"`local x = 5
							set_global_timeout(function() message(x) end, frames)
							x = nil`
							will print 5 no matter the number of frames you input"
				--]]
				function(x, y, l)
					for yi = 0, -3, -1 do
						for xi = 0, 2, 1 do
							if (yi ~= 0 and xi == 1) then
								-- SORRY NOTHING
							else
								spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x+xi, y+yi, l, 0, 0)
							end
						end
					end
					create_door_exit_moai(x+1, y-3, l)
					moai_veil = spawn_entity(ENT_TYPE.DECORATION_GENERIC, x+1, y-1.5, l, 0, 0)
					local decoration = get_entity(moai_veil)
					local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
					texture_def.texture_path = "res/moai_overlay.png"
					texture_def.width, texture_def.height = 384, 512
					texture_def.tile_width, texture_def.tile_height = 384, 512
					
					decoration:set_texture(define_texture(texture_def))
					decoration.animation_frame = 2
					decoration:set_draw_depth(7)
					decoration.width, decoration.height = 3, 4
				end,
			},
		},
		description = "Moai Head",
	},
	["P"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l)
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0)
						texture_def.texture_path = "res/floorstyled_gold_ladders.png"
						local ent_texture = define_texture(texture_def)
						local ent_uid = spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l)
						get_entity(ent_uid):set_texture(ent_texture)
					end
				},
			}
		},
		description = "Ladder Platform (Strict)",
	},
	["Q"] = {
		phase_3 = {
			alternate = {
				[THEME.VOLCANA] = {function(x, y, l) create_ceiling_chain_growable(x, y, l) end},
			}
		},
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GROWABLE_VINE, x, y, l, 0, 0) end,},
			alternate = {
				-- [THEME.JUNGLE] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GROWABLE_VINE, x, y, l, 0, 0) end,},
				-- [THEME.EGGPLANT_WORLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GROWABLE_VINE, x, y, l, 0, 0) end,},
				[THEME.NEO_BABYLON] = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_ALIENQUEEN, x, y, l, 0, 0) end,},
				[THEME.VOLCANA] = {function(x, y, l) return 0 end},
			},
		},
		description = "Variable-Length Ladder/Vine",
	},
	["R"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_RUBY, x, y, l, 0, 0) end,},
		},
		description = "Ruby from Snakepit",
	},
	["S"] = {
		description = "Shop Items",
	},
	["T"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					spawn_tree(x, y, l)
				end,
			},
		},

		description = "Tree",
	},
	["U"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_VLAD, x+.5, y, l, 0, 0) end,},
			alternate = {
				-- Black Knight
				[THEME.JUNGLE] = {function(x, y, l) return 0 end},
			}
		},
		description = "Vlad",
	},
	["V"] = {
		description = "Vines Obstacle Block",
	},
	["W"] = {
		description = "Wanted Poster",--"Unknown: Something Shop-Related",
	},
	["X"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_GIANTSPIDER, x+0.5, y, l, 0, 0) end,},
			alternate = {
				-- Alien Lord
				--[[
					erictran:
					"he shouldnt be too hard to program, just take something like yeti king / queen,
					disable their AI, retexture them to use the alien lord from s1 and make him
					periodically spawn the anubis projectiles.
					
					well dont literally disable their ai, but set their move_state and state values
					to some arbitrary value to stop them from moving."
					-- Change projectile speed with `ScepterShot::speed`
				--]]

				[THEME.ICE_CAVES] = {function(x, y, l) return 0 end},
				[THEME.NEO_BABYLON] = {function(x, y, l) return 0 end},
				-- Horse Head & Ox Face
				[THEME.VOLCANA] = {function(x, y, l) return 0 end},
			}
		},
		description = "Giant Spider",
	},
	["Y"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_YETIKING, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MUMMY, x, y, l, 0, 0) end,},
				[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MUMMY, x, y, l, 0, 0) end,},
				[THEME.VOLCANA] = {
					function(x, y, l) create_yama(x, y, l) end
				},
			},
		},
		description = "Yeti King",
	},
	["Z"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l, 0, 0) end,},
		},
		description = "Beehive Tile with Background",
	},
	["a"] = {
		--#TOTEST: Also used in tutorial:
			-- 2nd level, placement {4,2}.
			-- 3rd level, placement {1,2}.
		phase_1 = {
			default = {
				function(x, y, l)
					local shopkeeper = spawn_shopkeeper(x+3, y, l, ROOM_TEMPLATE.SHOP_LEFT)
					ankh_uid = spawn_grid_entity(ENT_TYPE.ITEM_PICKUP_ANKH, x, y, l)
					add_item_to_shop(ankh_uid, shopkeeper)
					add_custom_name(ankh_uid, "Ankh")
					ankh_mov = get_entity(ankh_uid)
					ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.SHOP_ITEM)
					ankh_mov.flags = set_flag(ankh_mov.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
					spawn_entity_over(ENT_TYPE.FX_SALEICON, ankh_uid, 0, 0)
					spawn_entity_over(ENT_TYPE.FX_SALEDIALOG_CONTAINER, ankh_uid, 0, 0)

					-- if options.hd_og_ankhprice == true then
						ankh_mov.price = 50000
					-- else
						-- ankh_mov.price = -- # TODO: Figure out what S2 does to calculate hedject shop price
					-- end
				end,
			},
			tutorial = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_POT, x, y, l, 0, 0) end,},
		},
		description = "Ankh/Pot",
	},
	-- # TODO:
		-- Add alternative shop floor of FLOOR_GENERIC
		-- Modify all HD shop roomcodes to accommodate this.
	["b"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l, 0, 0))
					entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
				end,
			},
		},
		description = "Shop Floor",
	},
	["c"] = {
		phase_1 = {
			default = {
				function(x, y, l) create_idol_crystalskull(x+0.5, y, l) end,
			},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {
					function(x, y, l)
						if (math.random(2) == 2) then
							x = x + 10
						end
						create_crysknife(x, y, l)
					end
				},
			}
		},
		description = "Crystal Skull",
	},
	["d"] = {
		-- HD may spawn this as wood at times. The solution is to replace that tilecode with "v"
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.EGGPLANT_WORLD] = {function(x, y, l) create_regenblock(x, y, l) end,},
			},
		},
		description = "Jungle Terrain",
	},
	["e"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l, 0, 0) end,},
			tutorial = {
				function(x, y, l)
					set_contents(spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0), ENT_TYPE.ITEM_PICKUP_BOMBBAG)
				end,
			},
		},
		description = "Beehive Tile",
	},
	["f"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, l, 0, 0) end,},
		},
		description = "Falling Platform",
	},
	["g"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
					if global_levelassembly.modification.levelrooms[roomy] ~= nil then
						local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
					end
					local coffin_uid = nil
					if (
						_subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP
						or _subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP
						or _subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
						or _subchunk_id == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
					) then
						coffin_uid = create_coffin_coop(x+0.35, y, l)
					else
						coffin_uid = create_coffin_unlock(x+0.35, y, l)
					end
					if coffin_uid ~= nil then
						if state.theme == THEME.EGGPLANT_WORLD then
							coffin_e = get_entity(coffin_uid)
							coffin_e.flags = set_flag(coffin_e.flags, ENT_FLAG.NO_GRAVITY)
							coffin_e.velocityx = 0
							coffin_e.velocityy = 0
							local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_COFFINS_0)
							texture_def.texture_path = "res/coffins_worm.png"
							coffin_e:set_texture(define_texture(texture_def))
						end
					end
				end
			},
		},
		description = "Coffin",
	},
	["h"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l, 0, 0) end,},
			tutorial = {
				function(x, y, l)
					set_contents(spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0), ENT_TYPE.ITEM_PICKUP_ROPEPILE)
				end,
			},
			alternate = {
				[THEME.JUNGLE] = {
					function(x, y, l)
						local ent_uid = spawn_entity(ENT_TYPE.BG_BASECAMP_SHORTCUTSTATIONBANNER, x+4, y+2, l, 0, 0)
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_BASECAMP_3)
						texture_def.texture_path = "res/deco_basecamp_hauntedcastle_banner.png"
						get_entity(ent_uid):set_texture(define_texture(texture_def))
						
						-- # TODO: I think I'm screwing the sizing on this haunted castle altar bg entirely.
							-- Please fix (both here and the .ase file)
						ent_uid = spawn_entity(ENT_TYPE.BG_KALI_STATUE, x+.5, y+0.6, l, 0, 0)
						local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_JUNGLE_0)
						texture_def.texture_path = "res/deco_jungle_hauntedcastle.png"
						get_entity(ent_uid):set_texture(define_texture(texture_def))
						get_entity(ent_uid).width = 5.0--5.600
						get_entity(ent_uid).height = 5.0--7.000

						spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y-1, l, 0, 0)
						spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y-1, l, 0, 0)

						spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y, l, 0, 0)
						spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y-1, l, 0, 0)
						spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y, l, 0, 0)
						spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y-1, l, 0, 0)
					end,
				}
			},
		},
		description = "Vlad's Castle Brick",--Hell Terrain",
		--#TODO: in HD it's also the haunted castle altar
	},
	["i"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.JUNGLE] = {
					function(x, y, l)
						spawn_entity_over(ENT_TYPE.ITEM_LAVAPOT, spawn_entity(ENT_TYPE.ITEM_COOKFIRE, x, y, l, 0, 0), 0, 0.675)
					end,
				}
			},
		},
		description = "Ice Block",
	},
	["j"] = {
		phase_1 = {
			default = {
				-- function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l, 0, 0) end,
				function(x, y, l) return 0 end,
			},
		},
		description = "Unused (In classic this was 'Ice Block/Empty'", -- Old description: "Ice Block with Caveman".
	},
	["k"] = { -- Sign creation currently done in S2 gen
		phase_1 = {
			default = {
				function(x, y, l)
					spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l)

					-- #TOTEST: Scripted gen shopsign spawning: For some reason this is really unstable and breaks generation 1/4 of the time.
					-- Steps:
						-- 1.) Uncomment the following code back in
						-- 2.) Uncomment ROOMOBJECT.GENERIC roomcode definitions back in
						-- 3.) Toggle the relevant ignore flag in the Modlunky level editor for the regular shop and gambling shop roomcodes

					
					-- -- need subchunkid of what room we're in
					-- roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
					-- _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
						
					-- spawn_entity(ENT_TYPE.DECORATION_SHOPSIGN,
					-- (
					-- 	x+(
					-- 		(
					-- 			_subchunk_id == genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT or
					-- 			_subchunk_id == genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
					-- 		)
					-- 		and -0.5 or 0.5
					-- 	)
					-- ), y+2.5, l, 0, 0)
					-- -- # TODO: Spawn shop icon
				end,
			},
		},
		description = "Shop Entrance Sign",
	},
	["l"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_LAMP, x, y, l, 0, 0) end,},
		},
		description = "Shop Lantern",
	},
	["m"] = {
		phase_4 = {
			alternate = {
				[THEME.NEO_BABYLON] = {
					function(x, y, l)
						spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_ELEVATOR, x, y, l)
						-- need subchunkid of what room we're in
						roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
						_subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
						
						if (
							(_subchunk_id == genlib.HD_SUBCHUNKID.ENTRANCE_DROP)
						) then
							spawn_entity(ENT_TYPE.FLOOR_DOOR_PLATFORM, x, y-1, l, 0, 0)
						end
						return 0
					end,
				},
			}
		},
		phase_1 = {
			default = {
				function(x, y, l)
					local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l))
					entity.flags = set_flag(entity.flags, ENT_FLAG.TAKE_NO_DAMAGE)
				end,
			},
			alternate = {
				[THEME.NEO_BABYLON] = {
					function(x, y, l) return 0 end,
				},
			},
		},
		description = "Unbreakable Terrain",
	},
	["n"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					if math.random(10) == 1 then
						spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l, 0, 0)
					elseif math.random(2) == 1 then
						spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0)
					else
						return 0
					end
				end,
			},
		},
		description = "Terrain/Empty/Snake",
	},
	["o"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_ROCK, x, y, l, 0, 0) end,},
		},
		description = "Rock",
	},
	["p"] = {
		-- Appears to go unused.
		-- In HD it has no tilecode case, so I'm pretty sure it's unused.
		-- Appears in corners of the crystal idol room and at the bottom of a few ladders outside in the notop_drop rooms outside of the haunted castle.
		description = "Unused",--Treasure/Damsel",
	},
	["q"] = {
		-- # TODO: Trap Prevention.
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,},
			alternate = {
				[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0) end,},
				[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0) end,},
				[THEME.VOLCANA] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l, 0, 0) end,},
			},
		},
		description = "Obstacle-Resistant Terrain",
	},
	["r"] = {
		description = "Terrain/Stone", -- old description: Mines Terrain/Temple Terrain/Pushblock
		-- Used to be used for Temple Obstacle Block but had to be assigned to a new tilecode ("(") to avoid problems
		-- From 
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l, 0, 0) end,
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0) end,
				-- ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK
			},
			alternate = {
				[THEME.VOLCANA] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				}
			},
		},
	},
	["s"] = {
		-- # TODO: Use phase 3 to spawn on bedrock floor
		phase_2 = {
			default = {
				function(x, y, l)
					floorsAtOffset = get_entities_at(0, MASK.FLOOR, x, y-1, LAYER.FRONT, 0.5)
					-- # TOTEST: If gems/gold/items are spawning over this, move this method to run after gems/gold/items get embedded. Then here, detect and remove any items already embedded.
					
					if #floorsAtOffset > 0 then
						local floor_uid = floorsAtOffset[1]
						local floor = get_entity(floor_uid)
						local spikes_uid = spawn_entity_over(ENT_TYPE.FLOOR_SPIKES, floor_uid, 0, 1)
						if state.theme == THEME.EGGPLANT_WORLD then
							local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_EGGPLANT_0)
							deco_texture = define_texture(texture_def)

							floor:add_decoration(FLOOR_SIDE.TOP)
							
							if floor.deco_top ~= -1 then
								local deco = get_entity(floor.deco_top)
								deco:set_texture(deco_texture)
								deco.animation_frame = math.random(101, 103)
							end
						elseif state.theme == THEME.VOLCANA then
							-- need subchunkid of what room we're in
							local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
							local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
							if (
								_subchunk_id == genlib.HD_SUBCHUNKID.VLAD_TOP
								or _subchunk_id == genlib.HD_SUBCHUNKID.VLAD_MIDSECTION
								or _subchunk_id == genlib.HD_SUBCHUNKID.VLAD_BOTTOM
							) then
								local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_0)
								texture_def.texture_path = "res/vladspikes.png"
								get_entity(spikes_uid):set_texture(define_texture(texture_def))
							end
						end
					end
				end,
			}
		},
		description = "Spikes",
	},
	["t"] = {
		phase_1 = {
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l, 0, 0) end,
			},
			alternate = {
				[THEME.TEMPLE] = {
					function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
				[THEME.CITY_OF_GOLD] = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l, 0, 0) end,
					function(x, y, l) return 0 end,
				},
			}
		},
		-- # TODO: ????? Investigate in HD.
		description = "Temple/Castle Terrain",
	},
	["u"] = {
		phase_1 = {
			tutorial = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_BAT, x, y, l, 0, 0) end,},
			default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_VAMPIRE, x, y, l, 0, 0) end,},
		},
		description = "Vampire from Vlad's Tower",
	},
	["v"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l, 0, 0) end,},
		},
		description = "Wood",
	},
	["w"] = {
		phase_3 = {
			default = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y) return ENT_TYPE.LIQUID_WATER end,},
			alternate = {
				[THEME.TEMPLE] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
				[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
				[THEME.VOLCANA] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
			},
		},
		description = "Liquid",
	},
	["x"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y, l, 0, 0)
					spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y, l, 0, 0)
				end,
			},
		},
		description = "Kali Altar",
	},
	["y"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l, 0, 0))
				end
			},
			alternate = {
				[THEME.TEMPLE] = {
					function(x, y, l)
						embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l, 0, 0))
					end
				},
				[THEME.VOLCANA] = {
					function(x, y, l)
						embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l, 0, 0))
					end
				}
			}
		},
		description = "Crust Ruby in Terrain",
	},
	["z"] = {
		phase_1 = {
			tutorial = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l, 0, 0) end,
			},
			default = {
				function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l, 0, 0) end,
				function(x, y, l) return 0 end,
			},
			alternate = {
				[THEME.NEO_BABYLON] = {function(x, y, l) return 0 end,}, -- # TODO: spawn method for turret
				[THEME.CITY_OF_GOLD] = {function(x, y, l) return 0 end,},
				[THEME.VOLCANA] = {function(x, y, l) return 0 end,} -- bg columns
			},
		},
		-- # TODO: Temple has bg pillar as an alternative
		description = "Beehive Tile/Empty",
	},
	["|"] = {
		phase_1 = {
			default = {
				function(x, y, l)
					for yi = 0, -3, -1 do
						for xi = 0, 3, 1 do
							if (yi == -1 and (xi == 1 or xi == 2)) or (yi == -2 and (xi == 1 or xi == 2)) then
								-- SORRY NOTHING
							else
								local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+xi, y+yi, l, 0, 0))
								entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
							end
						end
					end
					spawn_entity(ENT_TYPE.ITEM_VAULTCHEST, x+1, y-2, l, 0, 0)
					spawn_entity(ENT_TYPE.ITEM_VAULTCHEST, x+2, y-2, l, 0, 0)
					local shopkeeper_uid = spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x+1, y-2, l, 0, 0)
					local shopkeeper = get_entity(shopkeeper_uid)
					
					if state.shoppie_aggro_next <= 0 then
						pick_up(shopkeeper_uid, spawn_entity(ENT_TYPE.ITEM_SHOTGUN, x+1, y-2, l, 0, 0))
					end
					shopkeeper.is_patrolling = true
					shopkeeper.move_state = 9
				end
			},
		},
		description = "Vault",
	},
	["~"] = {
		phase_1 = {
			default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, l, 0, 0) end,},
		},
		description = "Bounce Trap",
	},
	["!"] = {
		-- one occasion in tutorial it's an arrow trap
		description = "Tutorial Controls Display",
	},
	["("] = {
		-- Had to create a new tile for Temple's obstacle tile because there were conflictions with "r" in Jungle.
		description = "Temple Obstacle Block",
	}
		-- description = "Unknown",
}


HD_ROOMOBJECT = {}
HD_ROOMOBJECT.GENERIC = {
	
	-- # TODO: Shopkeeper room assigning
	-- room_x + room_y * 8
	-- https://discord.com/channels/150366712775180288/862012437892825108/873695668173148171
	
	-- Regular
	[genlib.HD_SUBCHUNKID.SHOP_REGULAR] = {
		--{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..KS000000bbbbbbbbbb"} -- original
		-- {"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..00000000bbbbbbbbbb"} -- hd accurate sync
		{"111111111111110011111100220000110l000200000000W00000000000000000000000bbbbbbbbbb"} -- hd accurate sync without sign block
		-- {"111111111111110011111100220001110l000200000000W00000000000k00000000000bbbbbbbbbb"} -- hd accurate sync
	},
	[genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT] = {
		--{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S000K..bbbbbbbbbb"} -- original
		-- {"11111111111111..11111...22..11..2000l.110.W0000...0k00000...00000000..bbbbbbbbbb"} -- hd accurate sync
		{"111111111111110011110000220011002000l01100W000000000000000000000000000bbbbbbbbbb"} -- hd accurate sync without sign block
		-- {"111111111111110011111000220011002000l01100W00000000k000000000000000000bbbbbbbbbb"} -- hd accurate sync
	},
	-- Prize Wheel
	[genlib.HD_SUBCHUNKID.SHOP_PRIZE] = {
		--{"11111111111111..1111....22...1.Kl00002.....000W0.0.0%00000k0.$%00S0000bbbbbbbbbb"} -- original
		-- {"11111111111111..1111....22...1.0l00002....0000W0.0.0000000k0.000000000bb0bbbbbbb"} -- hd accurate sync
		-- {"11111111111111001111000022000000l0000200000000W00000000000000000000000bb0bbbbbbb"} -- hd accurate sync without sign block (sync1)
		-- {"11111111111111001111000022000100l0000200000000W00000000000k00000000000bb0bbbbbbb"} -- hd accurate sync
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- s2
		{"111111111110000000010000l000000bbb000000000000W00l00000000000000000000bb0bbbbbbb"} -- s2 sync
	},
	[genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT] = {
		--{"11111111111111..11111...22......20000lK.0.W0000...0k00000%0.0000S00%$.bbbbbbbbbb"} -- original
		-- {"11111111111111..11111...22......20000l0.0.W00000..0k0000000.000000000.bbbbbbb0bb"} -- hd accurate sync
		-- {"1111111111111100111100002200000020000l0000W000000000000000000000000000bbbbbbb0bb"} -- hd accurate sync without sign block (sync1)
		-- {"1111111111111100111110002200000020000l0000W00000000k000000000000000000bbbbbbb0bb"} -- hd accurate sync
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- s2 sync
		{"1111111111100000000100000l0000000000bbb0l00W00000000000000000000000000bbbbbbb0bb"} -- s2 sync
	},
	-- Damzel
	[genlib.HD_SUBCHUNKID.SHOP_BROTHEL] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K00S0000bbbbbbbbbb"} -- original
	},
	[genlib.HD_SUBCHUNKID.SHOP_BROTHEL_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...0000S00K..bbbbbbbbbb"} -- original
	},
	-- Hiredhands(?)
	[genlib.HD_SUBCHUNKID.SHOP_UNKNOWN1] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0SSS000bbbbbbbbbb"} -- original
	},
	[genlib.HD_SUBCHUNKID.SHOP_UNKNOWN1_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000SSS0K..bbbbbbbbbb"} -- original
	},
	-- Hiredhands(?)
	[genlib.HD_SUBCHUNKID.SHOP_UNKNOWN2] = {
		{"11111111111111..111111..22...111.l0002.....000W0.0...00000k0..K0S0S000bbbbbbbbbb"} -- original
	},
	[genlib.HD_SUBCHUNKID.SHOP_UNKNOWN2_LEFT] = {
		{"11111111111111..11111...22..11..2000l.110.W0000...0k00000...000S0S0K..bbbbbbbbbb"} -- original
	},
	-- Vault
	[genlib.HD_SUBCHUNKID.VAULT] = {
		--{"11111111111111111111111|00011111100001111110EE0111111000011111111111111111111111"} -- original
		{"11111111111111111111111|00011111100001111110000111111000011111111111111111111111"}
		-- {"11111111111000000001100|00000110000000011000000001100000000110000000011111111111"} -- hd accurate sync
	},
	-- Altar
	[genlib.HD_SUBCHUNKID.ALTAR] = {
		{"220000002200000000000000000000000000000000000000000000x0000002211112201111111111"}
		-- {"00000000000000000000000000000000000000000000000000000000000000000000000000000000"} -- hd accurate sync
	},
	[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE] = {
		{"22222222220000000000000000000000000000000000000000000000000000000000000000000000"},
		{"11111111112222222222000000000000000000000000000000000000000000000000000000000000"},
		{"22211112220001111000000211200000011110000002112000000022000000000000000000000000"},
		{"11112211112112002112022000022000000000000000000000000000000000000000000000000000"}
	}
}
HD_ROOMOBJECT.TUTORIAL = {}
HD_ROOMOBJECT.TUTORIAL[1] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE,
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
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
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
HD_ROOMOBJECT.TUTORIAL[2] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
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
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE,
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
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
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
HD_ROOMOBJECT.TUTORIAL[3] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE,
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
			subchunk_id = genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT,
			placement = {2, 4},
			-- wow, okay, so comparing SHOP_REGULAR_LEFT's roomcode to the original shows that it's almost exactly the same
			-- with the exception of the overhead tiles not set to shopkeeper tiles
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT]) -- {{"111111111111111111111111221111112000l11101W0000...0k00000...000S000K..bbbbbbbbbb"}}
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
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
			placement = {4, 4},
			roomcodes = {{"111111111111111vvvvv00001v0000000000009000100v====001000111111111111111111111111"}}
		},
	}
}
HD_ROOMOBJECT.TESTING = {}
HD_ROOMOBJECT.TESTING[1] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
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
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
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
HD_ROOMOBJECT.TESTING[2] = {
	setRooms = {
		-- 1
		{
			-- prePath = false,
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
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE,
			placement = {2, 2},
			roomcodes = {{"00000000000LL09000001PP11111110LL00000000LL00LL00011111PP11100000LL00000000LL000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
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
HD_ROOMOBJECT.FEELINGS = {}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE] = {
	prePath = false,
	rooms = {
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
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HIVE].method = function()
	
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VAULT] = {
	prePath = false,
	method = function()
		if (
			detect_level_non_special()
		) then
			level_generation_method_nonaligned(
				{
					subchunk_id = genlib.HD_SUBCHUNKID.VAULT,
					roomcodes = (
						HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
						HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.VAULT] ~= nil
					) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.VAULT] or HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.VAULT]
				}
				,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			)
		end
	end
}

-- # TODO: Make method to remove pots during spiderlair
-- pots will not spawn on this level.
-- Spiders, spinner spiders, and webs appear much more frequently.
-- Spawn web nests (probably RED_LANTERN, remove  and reskin it)
-- Move pots into the void
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR] = {
	rooms = {
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE] = {
			{"11111111112X0211111100002X011100000002112222000210000000021022222000001111111111"},
			{"1111111111222221111100000X011101100002110X00001110000100021022212000001111111111"},
			{"1111111111222111X0110002000011000001021101110102100X0100021000011000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_NOTOP] = {
			{"1v000000v11vvv00vvv10X0v00vX0100000000012222000200000000021122222000001111111111"},
			{"1v000000v11vvv00vvv1000v00vX010vvv0000010X00002100000100011122212000001111111111"},
			{"1v000000v11vvv00vvv1000v00vX01000000000101110002000X0100021100011000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP_NOTOP] = {
			{"111v00v1112X0v00v111000v00v111000000v211111v00v2120X00000010000v00v000111v00v111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP] = {
			{"11111111112X0vvvv111000vX0v111000000021122220002120000000010222v00v000111v00v111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE] = {
			{"11111111111111112X02111X02000011200000000120002222012000000000000222221111111111"},
			{"11111111111111122222111X00000011200001100111000X00012000100000000212221111111111"},
			{"111111111111X01112221100002000112010000001201011100120001X0000000110001111111111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_NOTOP] = {
			{"1v000000v11vvv00vvv11X0v00vX0010000000000020002222112000000000000222221111111111"},
			{"1v000000v11vvv00vvv11X0v00v000100000vvv00012000X00111000100000000212221111111111"},
			{"1v000000v11vvv00vvv11X0v00v000100000000000200011101120001X0000000110001111111111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP_NOTOP] = {
			{"111v00v111111v00vX02111v00v000112v000000212v00v1110100000X00000v00v000111v00v111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP] = {
			{"1111111111111vvvvX02111vX0v000112000000021200022220100000000000v00v222111v00v111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK] = {
			{"1111111111111X0X000211100000011111100g010120001111012000000000000122221111111111"},
		},
		[genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP] = {
			{"1v000000v11vvv00vvv1X00000vX00000010000000g0102222111110000000000022221111111111"},
		},
	}
}

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].method = function()
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	--1.) Select room coordinates between x = 1..3 and y = 2..3
	local room_l_x, room_l_y = math.random(1, levelw-1), math.random(2, levelh-1)
	local room_r_x, room_r_y = room_l_x+1, room_l_y

	--2.) Replace room at y and x coord with SPIDERLAIR_LEFTSIDE*
	local path_to_replace = global_levelassembly.modification.levelrooms[room_l_y][room_l_x]
	local path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE

	if LEVEL_UNLOCK ~= nil then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK
	end

	if path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP then
		if LEVEL_UNLOCK ~= nil then
			path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_UNLOCK_NOTOP
		else
			path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_NOTOP
		end
	elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP
	elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_LEFTSIDE_DROP_NOTOP
	end
	levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].rooms[path_to_replace_with], room_l_y, room_l_x)

	--3.) Replace room at y and x+1 coord with SPIDERLAIR_RIGHTSIDE*	
	path_to_replace = global_levelassembly.modification.levelrooms[room_r_y][room_r_x]
	path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE
	if path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_NOTOP
	elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP
	elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
		path_to_replace_with = genlib.HD_SUBCHUNKID.SPIDERLAIR_RIGHTSIDE_DROP_NOTOP
	end
	levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SPIDERLAIR].rooms[path_to_replace_with], room_r_y, room_r_x)

end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT] = {
	prePath = true,
	rooms = {
		[genlib.HD_SUBCHUNKID.SNAKEPIT_TOP] = { -- grabs 4 and upwards from HD's path_drop roomcodes
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
		[genlib.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION] = {{"111000011111n0000n11111200211111n0000n11111200211111n0000n11111200211111n0000n11"}},
		[genlib.HD_SUBCHUNKID.SNAKEPIT_BOTTOM] = {{"111000011111n0000n1111100001111100N0001111N0110N11111NRRN1111111M111111111111111"}}
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = genlib.HD_SUBCHUNKID.SNAKEPIT_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[genlib.HD_SUBCHUNKID.SNAKEPIT_TOP]
		},
		{
			middle = {
				subchunk_id = genlib.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[genlib.HD_SUBCHUNKID.SNAKEPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = genlib.HD_SUBCHUNKID.SNAKEPIT_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SNAKEPIT].rooms[genlib.HD_SUBCHUNKID.SNAKEPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		1
	)
	
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS] = {
	prePath = false,
	rooms = {
		[genlib.HD_SUBCHUNKID.RESTLESS_IDOL] = {
			{"tttttttttttttttttttttt00c000tt0tt0A00tt00400000040ttt0tt0ttttt000000tt1111111111"}
		},
		[genlib.HD_SUBCHUNKID.RESTLESS_TOMB] = {
			{
				"000000000000000000000000900000021t1t1200211t0t112011rtttr11011r111r11111rrrrr111",
				"0000000000000000000000000900000021t1t1200211t0t112011rtttr11111r111r11111rrrrr11",
			}
		},
	},
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].method = function()
	state.level_flags = set_flag(state.level_flags, 8)
	-- # TODO: spawn particles for TOMB_FOG or the ghost fog
	if state.level ~= 4 then
		level_generation_method_nonaligned(
			{
				subchunk_id = genlib.HD_SUBCHUNKID.RESTLESS_TOMB,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[genlib.HD_SUBCHUNKID.RESTLESS_TOMB]
			}
			,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
		)
	end
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) == false then
		level_generation_method_nonaligned(
			{
				subchunk_id = genlib.HD_SUBCHUNKID.RESTLESS_IDOL,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[genlib.HD_SUBCHUNKID.RESTLESS_IDOL]
			}
			,feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
		)
	end
end

-- # TODO: Replace haunted castle roomcode altar tilecodes with new tilecode (or re-used) for torches
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.BLACKMARKET] = {
	prePath = false,
	chunkRules = {
		obstacleBlocks = {
			[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 2 -- default
				if (math.random(8) == 8) then
					range_start, range_end = 3, 5
				end
				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		},
	},
	setRooms = {
		-- 1
		{
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE_DROP,
			placement = {1, 1},
			roomcodes = {
				{
					"60000600000000000000000000000000000000000008000000000000000000000000000002112000",
					"11111111112222222222000000000000000000000008000000000000000000000000000002112000"
				}
			}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {1, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {1, 3},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {2, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {2, 3},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP,
			placement = {2, 4},
			roomcodes = {
				{"12G000002100P111100000G222200000G000000000G00000000000000022001G000211111P011111"},
			}
		},

		-- 3
		{
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP,
			placement = {3, 2},
			-- roomcodes = {{"000000000000000000000000220000002l00l200000000000000000000000000000000bbbbbbbbbb"}}
			roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT,
			placement = {3, 3},
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT])
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.BLACKMARKET_ANKH,
			placement = {3, 4},
			roomcodes = {{"000G011111000G000000000G00a0l0000bbbbbbb0000000000111111111111111111111111111111"}}
			-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
		},

		-- 4
		{
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_NOTOP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.PATH,
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
			subchunk_id = genlib.HD_SUBCHUNKID.PATH,
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
			subchunk_id = genlib.HD_SUBCHUNKID.EXIT,
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
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
}


HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE] = {
	prePath = false,
	chunkRules = {
		obstacleBlocks = {
			[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 2 -- default
				if (math.random(8) == 8) then
					range_start, range_end = 3, 5
				end
				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		},
	},
	setRooms = {
		-- 1
		{
			subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_UNLOCK,
			placement = {1, 1},
			roomcodes = {{"00000000000t0t0t0t0ttttttttttttttttttttt000400000tg00tt0000tttttU00000tttttttttt"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_SETROOM_1_2,
			placement = {1, 2},
			roomcodes = {
				-- # TODO: Figure out why "param_1 == 0" chooses the first roomcode.
				-- {"00000000000t0t0t0t0ttttttttttttttttttttt000000000t000000000t0U00000000tttttttttt"},
				{"00000000000t0t0t0t0ttttttttttttttttttttt0000000000tttt00tttt0000000000tttttttttt"},
			}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_SETROOM_1_3,
			placement = {1, 3},
			roomcodes = {{"00000000000t0t0t0t0ttttttttttttttttttttt0000000ttttttt000ttt00000N0ttttt000ttttt"}}
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.ENTRANCE_DROP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP,
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
			subchunk_id = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MOAT,
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
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE] = { -- basically "Castle Middle (notop/path/side)"
			{"0000000000000t000G00000ttttPtt0000000G000000000G00ttt0000G00ttttt00G00tttttttttt"},
			{"000000000000G000t000ttPtttt00000G000000000G000000000G0000ttt00G00ttttttttttttttt"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE_DROP] = { -- basically "Castle Middle drop"
			{"000G00G000tttPttPttt000G00G000000G00G000000tttt0000000000000tt000000ttttt0000ttt"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM] = { -- "Castle Bottom notop"
			{"0000000000tt000000tt000000000000000000000000tt00000000tt0000rrrrttrrrr1111111111"},
			{"0000000000tt000000000000000000000000000000000000tt0000rrrrttrrrrrrrrtt1111111111"},
			{"000000000000000000tt00000000000000000000tt00000000ttrrrr0000ttrrrrrrrr1111111111"},
			{"000000000000000000tt000000000000000000000000000000000T000000rrrrrrrrrr1111111111"},
			{"0000000000tt00000000000000000000000000000000000000000000T000rrrrrrrrrr1111111111"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM_NOTOP] = { -- "Castle Bottom notop"
			{"0000GG0000ttttPPtttt0000GG00000000GG00000000GG00000000GG0000rrrrrrrrrr1111111111"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL] = { -- "Castle Bottom Rightside"
			{"0000G00ttt000tG00tttttttPttttt0000G002tt0000G00ttt0000G00ttt0000G00ttttttttttttt"},
			{"0000G00ttt0000Pttttt0000G0tttt0000G002tt0000G00ttt000ttttttt0ttttttttttttttttttt"},
			-- {"0000000ttt00tt000ttt000000tttt00000002tt000ttttttt0000000ttttt000002tttttttttttt"}, -- unused
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP] = { -- "Castle Bottom Rightside drop"
			{"0000000ttt00000ttttt000000tttt0ttt0002tt00t0000ttt000000tttt000000tttttt0000tttt"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE] = { -- "Castle Bottom Rightside drop"
			{"0000000ttt0000000ttD0000000tt00000000tt000000000000000000N00rrrrrrrrrr1111111111"}, -- modified from original for sliding doors
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE_NOTOP] = {
			{"0000000ttt0000tttttD0000000tt0000tttttt0t000000000t000N00N00trrrrrrrrr1111111111"}, -- modified from original for sliding doors
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT] = {
			{"00000000000000000000000000000000000000000000h000000900000000rrrttttrrr1111111111"},
		},
		[genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP] = {
			{"0G00000000tPtt00tt000G000000000G000000000G00h000000G00000090rrrttttrrr1111111111"},
		},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = { -- never happends, but this IS different from regular jungle. Keep just in case.
			{"000000000022222"},
			{"000002222211111"},
			{"00000000000T022"},
			{"000000000020T02"},
			{"0000000000220T0"},
		},
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000ttt011111"},
		},
	},
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].method = function()
	state.level_flags = set_flag(state.level_flags, 8)
	-- # TODO: spawn particles for TOMB_FOG or the ghost fog
	
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 2, levelw-1, levelh

	assigned_exit = false
	assigned_entrance = false
	wi, hi = maxw, minh
	dropping = false
	
	
	while assigned_exit == false do
		pathid = math.random(2)
		ind_off_x, ind_off_y = 0, 0

		if pathid == genlib.HD_SUBCHUNKID.PATH then
			dir = 0
			if detect_sideblocked_both(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
				pathid = genlib.HD_SUBCHUNKID.PATH_DROP
			elseif detect_sideblocked_neither(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
				dir = (math.random(2) == 2) and 1 or -1
			else
				if detect_sideblocked_right(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = -1
				elseif detect_sideblocked_left(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = 1
				end
			end
			ind_off_x = dir
		end
		if pathid == genlib.HD_SUBCHUNKID.PATH and dropping == true then
			pathid = genlib.HD_SUBCHUNKID.PATH_NOTOP
			dropping = false
		end
		if pathid == genlib.HD_SUBCHUNKID.PATH_DROP then
			ind_off_y = 1
			if dropping == true then
				pathid = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP
			end
			dropping = true
		end

		if assigned_entrance == false then
			if pathid == genlib.HD_SUBCHUNKID.PATH_DROP then
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP
			else
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
			end
			assigned_entrance = true
		elseif hi == maxh then
			if wi == minw then
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP
			elseif wi == maxw then
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE_NOTOP
			else
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM_NOTOP
			end
			assigned_exit = true
		-- replace path with appropriate haunted castle path
		elseif wi == maxw then
			if pathid == genlib.HD_SUBCHUNKID.PATH or pathid == genlib.HD_SUBCHUNKID.PATH_NOTOP then
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
			else
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL_DROP
			end
		else
			if pathid == genlib.HD_SUBCHUNKID.PATH or pathid == genlib.HD_SUBCHUNKID.PATH_NOTOP then
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE
			else
				pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE_DROP
			end
		end

		global_levelassembly.modification.levelrooms[hi][wi] = pathid
		levelcode_inject_roomcode(pathid, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].rooms[pathid], hi, wi)

		if assigned_exit == false then -- preserve final coordinates for bugtesting purposes
			wi, hi = (wi+ind_off_x), (hi+ind_off_y)
		end
	end

	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			if global_levelassembly.modification.levelrooms[hi][wi] == nil then
				if hi == maxh then
					if wi == minw then
						pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT
					elseif wi == maxw then
						pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_GATE
					else
						pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_BOTTOM
					end
				elseif wi == maxw then
					pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_WALL
				else
					pathid = genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_MIDDLE
				end
				levelcode_inject_roomcode(pathid, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.HAUNTEDCASTLE].rooms[pathid], hi, wi)
			end
		end
	end

end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE] = {
	prePath = false,
	rooms = {
		-- Replaced all "d" tiles with "v"
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH] = {
			{
				"0000:0000000vvvvv00000v000v0000G00:00Gv0vPv===vPv0vG00000Gv00G00:00G00v=======v1",
				"00000:0000000vvvvv00000v000v000vG00:00G00vPv===vPv0vG00000Gv00G00:00G01v=======v"
			},
			{"00000000000000:0000000vvvv000000v+0v00000vv0vv0000000:0100001vv=v110T01111111111"},
			{"000000000000000:00000000vvvv000000v0+v000000vv0vv0000010:0000T011v=vv11111111111"},
		},
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP] = {
			{"111111111111v1111v1112v0000v210000:0000000v====v0000000000002q120021121111001111"},
			{"111111111111v1111v1112v0000v210000:0000000v====v00000000000021120021q21111001111"},
		},

		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP] = {
			{"00000000000000000000000000t0t00vvvvvt0t00v0000t0t000:0000it00v====ttt01111111111"},
			{"000000000000000000000t0t0000000t0tvvvvv00t0t0000v00ti0000:000ttt====v01111111111"},
		},
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT] = {
			{"1200000000vvvvv00000v000vv0000v0:00000001===vvv00011++00v00011110:00001111==v111"},
		},
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT] = {
			{"000000002100000vvvvv0000vv000v0000000:0v000vv====1000v00++110000:01111111v==1111"},
		},

		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP] = {
			{"000000000000vvvvvv0000v0+00v000000G:000000v=P==v0000v0G00v002qv2G02v121111G01111"},
			{"000000000000vvvvvv0000v00+0v000000:G000000v==P=v0000v00G0v002qv20G2v1211110G1111"},
		},
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT] = {
			{"12000000001v0vvvv0001v00+0v0001vv:G000001v==P==0001112G000001120G010001111G01111"},
		},
		[genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT] = {
			{"0000000021000vvvvvv1000v0+00v100000G:vv1000v=P===100000G211100010G021101110G1111"},
		},
		
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {
			{
				"11110011111111001111v00v00v00v0g00000::0v==v00v==v002100120000210012001111001111",
				"11110011111111001111v00v00v00v0::0000g00v==v00v==v002100120000210012001111001111",
			}
		},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {
			{
				"11110011111111001111v00v00v00v0g00000::0v==v00v==v002100120000210012001111001111",
				"11110011111111001111v00v00v00v0::0000g00v==v00v==v002100120000210012001111001111",
			}
		},
	},
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].method = function()
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	local levelh_start, levelh_end = 2, levelh-1
	local levelw_start, levelw_end = 1, levelw

	if LEVEL_UNLOCK ~= nil then
		local spots = {}
		-- build a collection of potential spots
		for room_y = levelh_start, levelh_end, 1 do
			for room_x = levelw_start, levelw_end, 1 do
				local subchunk_id = global_levelassembly.modification.levelrooms[room_y][room_x]
				if (
					(subchunk_id == genlib.HD_SUBCHUNKID.PATH_DROP or subchunk_id == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP)
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
			if spot.subchunk_id == genlib.HD_SUBCHUNKID.PATH_DROP then
				path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP
			elseif spot.subchunk_id == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
				path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP
			end
		end

		if path_to_replace_with ~= nil then
			levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].rooms[path_to_replace_with], spot.y, spot.x)
		end
	end
	
	for room_y = levelh_start, levelh_end, 1 do
		for room_x = levelw_start, levelw_end, 1 do
			path_to_replace = global_levelassembly.modification.levelrooms[room_y][room_x]
			path_to_replace_with = -1
			
			-- drop/drop_notop
			if (
				(path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP or path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP) and
				-- don't replace path_drop or path_drop_notop when room_y == 1
				-- (room_y ~= 1) and
				-- 2/5 chance not to replace path_drop or path_drop_notop
				(math.random(5) > 3)
			) then
				if path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP then
					path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP
				elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
					if (room_y == 2 or room_y == 3) and (room_x == 1) then
						path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT
					elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
						path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT
					else
						path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP
					end
				end
			end
		
			-- notop
			if (
				(path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP) and
				math.random(5) < 5 -- 1/5 chance not to replace path_notop
			) then
				if (room_y == 2 or room_y == 3) and (room_x == 1) then
					path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_LEFT
				elseif (room_y == 2 or room_y == 3) and (room_x == 4) then
					path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP_RIGHT
				else
					path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP
				end
			end
		
			-- path
			if (
				(path_to_replace == genlib.HD_SUBCHUNKID.PATH)
			) then
				path_to_replace_with = genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH
			end
		
			if path_to_replace_with ~= -1 then
				levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.TIKIVILLAGE].rooms[path_to_replace_with], room_y, room_x)
			end
		end
	end


end



HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER] = {
	prePath = false,
	rooms = {
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_EXIT] = {{"000000000000000900000221111220wwvvvvvvwwwwwwwwwwww000000000000000000000000000000"}},--"000000000000000900000221111220wwvvvvvvwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"}},
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_SIDE] = {
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
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_PATH] = {
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

		[genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE] = {{"00000000000000000000000000000,00000000000,,000000000,,00000000,,,,,,,,,00,,,,,,,"}},
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE] = {{"0000000000,000000000,,00000000,000000000,0000000,0,g0EEE0,,0,,,,,,,,,0,,,,,,,,00"}},
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY] = {{"0000000000000000000000000000000000000000000J00000000000000000000000000,,,,,,,,,,"}},
		[genlib.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM] = {
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
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	-- exit row
	for room_x = 1, levelw, 1 do
		path_to_replace = global_levelassembly.modification.levelrooms[levelh][room_x]
		path_to_replace_with = -1
		
		-- path
		if path_to_replace == genlib.HD_SUBCHUNKID.PATH or path_to_replace == nil then
			path_to_replace_with = genlib.HD_SUBCHUNKID.RUSHING_WATER_SIDE
		end
	
		-- path_notop
		if path_to_replace == genlib.HD_SUBCHUNKID.PATH or path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP then
			path_to_replace_with = genlib.HD_SUBCHUNKID.RUSHING_WATER_PATH
		end
	
		-- exit
		if (path_to_replace == genlib.HD_SUBCHUNKID.EXIT or path_to_replace == genlib.HD_SUBCHUNKID.EXIT_NOTOP) then
			path_to_replace_with = genlib.HD_SUBCHUNKID.RUSHING_WATER_EXIT
		end
	
		if path_to_replace_with ~= -1 then
			levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[path_to_replace_with], levelh, room_x)
		end
	end
	local struct_x_pool = {1, 2, 3, 4}
	if LEVEL_UNLOCK ~= nil then
		struct_x_pool = {1, 4}

		levelcode_inject_roomcode_rowfive(
			genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE,
			HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_LEFTSIDE],
			2
		)
		levelcode_inject_roomcode_rowfive(
			genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE,
			HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[genlib.HD_SUBCHUNKID.RUSHING_WATER_UNLOCK_RIGHTSIDE],
			3
		)
	end
	
	levelcode_inject_roomcode_rowfive(
		genlib.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY,
		HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[genlib.HD_SUBCHUNKID.RUSHING_WATER_OLBITEY],
		struct_x_pool[math.random(1, #struct_x_pool)]
	)
	-- inject rushing water side rooms
	for xi = 1, levelw, 1 do
		if global_levelassembly.modification.rowfive.levelrooms[xi] == nil then
			levelcode_inject_roomcode_rowfive(
				genlib.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM,
				HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RUSHING_WATER].rooms[genlib.HD_SUBCHUNKID.RUSHING_WATER_BOTTOM],
				xi
			)
		end
	end



	rowfive = {
		setRooms = {
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 1,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 2,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 3,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 4,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
		}
	}
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI] = {
	rooms = {
		[genlib.HD_SUBCHUNKID.MOAI] = {
			{
				"000000000000000O000000000000000000000000021110002002111mmm2000111111000000000000",
				"000000000000O000000000000000000000000000020001112002mmm1112000111111000000000000",
			}
		}
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y}
	minw, minh, maxw, maxh = 1, 2, levelw, levelh-1
	-- build a collection of potential spots
	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[hi][wi]
			if (
				(
					subchunk_id == nil and
					(
						(
							wi+1 <= maxw and
							(
								global_levelassembly.modification.levelrooms[hi][wi+1] ~= nil and
								global_levelassembly.modification.levelrooms[hi][wi+1] >= 1 and
								global_levelassembly.modification.levelrooms[hi][wi+1] <= 8
							)
						) or (
							wi-1 >= 1 and
							(
								global_levelassembly.modification.levelrooms[hi][wi-1] ~= nil and
								global_levelassembly.modification.levelrooms[hi][wi-1] >= 1 and
								global_levelassembly.modification.levelrooms[hi][wi-1] <= 8
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
	spot = spots[math.random(#spots)]

	levelcode_inject_roomcode(
		genlib.HD_SUBCHUNKID.MOAI,
		HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOAI].rooms[genlib.HD_SUBCHUNKID.MOAI],
		spot.y, spot.x
	)
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO] = {
	prePath = false,
	rooms = {
		[genlib.HD_SUBCHUNKID.UFO_LEFTSIDE] = {
			{"0000000000000+++++++0+++0000000+000000000+000000000++000000000++++++++0000000000"}
		},
		[genlib.HD_SUBCHUNKID.UFO_MIDDLE] = {
			{"0000000000++++++++++0000000000000000000000000000000000000000++++++++++0000000000"}
		},
		[genlib.HD_SUBCHUNKID.UFO_RIGHTSIDE] = {
			{"0022122111++++++11110+00002211000000X01100000000M10+;0021111+++++1+1110000222221"}
		},
	},
}
--[[
	# TODO: Provide option to enable safer path method for UFO.
	Here and in HD, UFO simply replaces subchunks without any concern for the path.
	This can result in it being significantly harder to traverse the level.

	What should be done is make it so the path at least passes through or around UFO_LEFTSIDE (considering it as a PATH_DROP or PATH_DROP_NOTOP).
	Note that this implimentation shouldn't be wrapping around UFO subchunks, but forcing the path to drop down and continue from there.
--]]
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 1, levelw, levelh

	drop_detected = false
	for room_x = 1, levelw, 1 do
		if global_levelassembly.modification.levelrooms[minh+1][room_x] == 3 then
			drop_detected = true
		end
	end

	wi, hi = maxw, minh+(drop_detected and 1 or 2)

	levelcode_inject_roomcode(genlib.HD_SUBCHUNKID.UFO_RIGHTSIDE, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_RIGHTSIDE], hi, wi)
	_mid_width_min = 0
	mid_width = math.random(_mid_width_min, maxw-2)
	for i = maxw-1, maxw-mid_width, -1 do
		levelcode_inject_roomcode(genlib.HD_SUBCHUNKID.UFO_MIDDLE, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_MIDDLE], hi, i)
	end
	levelcode_inject_roomcode(genlib.HD_SUBCHUNKID.UFO_LEFTSIDE, HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_LEFTSIDE], hi, maxw-mid_width-1)

	-- 	HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_LEFTSIDE]
	-- 	HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_MIDDLE]
	-- 	HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.UFO].rooms[genlib.HD_SUBCHUNKID.UFO_RIGHTSIDE]
end
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (
					CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					CHUNKBOOL_ALTAR = true
					return {altar = true}
				end
				
				return {index = math.random(2)}
			end,
			[genlib.HD_SUBCHUNKID.PATH] = function() return math.random(9) end,
			[genlib.HD_SUBCHUNKID.PATH_DROP] = function() return math.random(12) end,
			-- [genlib.HD_SUBCHUNKID.PATH_NOTOP] = function() return math.random(9) end,
			[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = function() return math.random(8) end,
		},
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
			{"00000000000010111100000000000000011010000050000000000000000000000000001111111111"},
			{"000000000011------11120000002112002200211200000021120022002111ssssss111111111111"},
		},
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001202111111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"00000000000060000000000000000000000000000000000000001112220002100000001110111111"},
			{"00000000000060000000000000000000000000000000000000002221110000000001201111110111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000000000111000"},
			{"11111111112222222222000000000000000000000008000000000000000000000000000000111000"},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
		},
		[genlib.HD_SUBCHUNKID.ALTAR] = {
			{"220000002200000000000000000000000000000000000000000000x00000022qqqq2201111111111"}
		},
		[genlib.HD_SUBCHUNKID.YETIKINGDOM_YETIKING] = {
			{"iiiiiiiiiijiiiiiiiij0jjjjjjjj0000000000000000000000000Y0000000::00::00iiiiiiiiii"}
		},
		[genlib.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_NOTOP] = {
			{"ii000000iijiii00iiij0jj0000jj0000000000000000000000000Y0000000::00::00iiiiiiiiii"}
		},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"0:::000000i-----i000i00000i000ig0000ii00i--0001i00i0000011i01sssss11101111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"000000:::0000i-----i000i00000i00ii000g0i00i1000--i0i1100000i0111sssss11111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"11111111112111111112022222222000000000000000g00000000011000002200002201111001111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"0000000000000000000022000000220000g000000000110000000000000002100001201111001111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000000g0000001--11--10010000001011ssssss111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"11111111112111111112022222222000000000000000g00000000011000002200002201111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"0000000000000000000022000000220000g000000000110000000000000002100001201111001111"}},
	},
	rowfive = {
		setRooms = {
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 1,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 2,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 3,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 4,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
		}
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	if LEVEL_UNLOCK ~= nil then
		level_generation_method_aligned(
			{
				left = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end

	spots = {}
		--{x, y, subchunk_id}
	minw, minh, maxw, maxh = 1, 2, levelw, levelh-1
	-- build a collection of potential spots
	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[hi][wi]
			if (
				(
					subchunk_id == nil and
					(
						(
							wi+1 <= maxw and
							(
								global_levelassembly.modification.levelrooms[hi][wi+1] ~= nil and
								global_levelassembly.modification.levelrooms[hi][wi+1] >= 1 and
								global_levelassembly.modification.levelrooms[hi][wi+1] <= 8
							)
						) or (
							wi-1 >= 1 and
							(
								global_levelassembly.modification.levelrooms[hi][wi-1] ~= nil and
								global_levelassembly.modification.levelrooms[hi][wi-1] >= 1 and
								global_levelassembly.modification.levelrooms[hi][wi-1] <= 8
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
	local subchunk_id_yeti = genlib.HD_SUBCHUNKID.YETIKINGDOM_YETIKING
	if spot.subchunk_id ~= nil then
		if (
			spot.subchunk_id == genlib.HD_SUBCHUNKID.PATH_NOTOP or
			spot.subchunk_id == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP
		) then
			subchunk_id_yeti = genlib.HD_SUBCHUNKID.YETIKINGDOM_YETIKING_NOTOP
		end
	end
	levelcode_inject_roomcode(
		subchunk_id_yeti,
		HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YETIKINGDOM].rooms[subchunk_id_yeti],
		spot.y, spot.x
	)
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE] = {
	prePath = true,
	rooms = {
		[genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP] = {
			{
				"++++++++++++000000++++090000++++++00++++++++00++++++++00++++++++00++++++++00++++",
				"++++++++++++000000++++000090++++++00++++++++00++++++++00++++++++00++++++++00++++",
			}
		},
		[genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM] = {{"++++00++++++++00++++++++00++++++++00++++++000000++0+++00+++000++00++000000000000"}}
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].rooms[genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP]
		},
		{
			bottom = {
				subchunk_id = genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE].rooms[genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_BOTTOM]
			}
		},
		{1, 4}
		-- ,0
	)
end
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT] = {
	prePath = true,
	rooms = {
		[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_TOP] = {{"0000000000000000000000000000000000000000000100100000110011000111;01110111BBBB111"}},
		[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION] = {{"11200002111120000211112000021111200002111120000211112000021111200002111120000211"}},
		[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM] = {{"112000021111200002111120000211113wwww311113wwww311113wwww31111yyyyyy111111111111"}}
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
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = genlib.HD_SUBCHUNKID.SACRIFICIALPIT_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_TOP]
		},
		{
			middle = {
				subchunk_id = genlib.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_MIDSECTION]
			},
			bottom = {
				subchunk_id = genlib.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.SACRIFICIALPIT].rooms[genlib.HD_SUBCHUNKID.SACRIFICIALPIT_BOTTOM]
			}
		},
		{1, 2, 3, 4},
		2
	)
end

HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD] = {
	prePath = true,
	rooms = {
		[genlib.HD_SUBCHUNKID.VLAD_TOP] = {{"0000hh000000shhhhs000shhhhhhs00hhhU0hhh0shh0000hhshhhh00hhhhhhQ0000Qhhhh000000hh"}},
		[genlib.HD_SUBCHUNKID.VLAD_MIDSECTION] = {{
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhhh00000hhhhQ0hhhhhhhh0qhhhhhh",
			"hh000000hhhh0V0000hhhh000000hhhh000000hhhh000000hhhh00000hhhhhhhhh0Qhhhhhhhhq0hh"
		}},
		[genlib.HD_SUBCHUNKID.VLAD_BOTTOM] = {{"hh0L00L0hhhhhL00Lhhh040L00L040hhhL00Lhhhhh0L00L0hh040ssss040hhshhhhshhhhhhhhhhhh"}},
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = genlib.HD_SUBCHUNKID.VLAD_TOP,
			roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[genlib.HD_SUBCHUNKID.VLAD_TOP]
		},
		{
			middle = {
				subchunk_id = genlib.HD_SUBCHUNKID.VLAD_MIDSECTION,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[genlib.HD_SUBCHUNKID.VLAD_MIDSECTION]
			},
			bottom = {
				subchunk_id = genlib.HD_SUBCHUNKID.VLAD_BOTTOM,
				roomcodes = HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.VLAD].rooms[genlib.HD_SUBCHUNKID.VLAD_BOTTOM]
			}
		},
		{1, 4},
		2
	)
end
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL] = {
	rooms = {
		[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE] = {{"000000000021------1221wwwwww12213wwww312013wwww310011333311002111111200022222200"}},
		-- single room of water
		-- subchunkid 68
		-- uses level_generation_method_nonaligned() after path gen

		-- uses level_generation_method_nonaligned() after path gen
		[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP] = {{"000000000021------1221wwwwww12213wwww312213wwww312213wwww312213wwww312213wwww312"}},
		-- top room of water
		-- subchunkid 69 *NICE*
		[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM] = {{"213wwww312213wwww312213wwww312213wwww312013wwww310011333311002111111200022222200"}},
		-- bottom room of water
		-- subchunkid 70
	}
}
-- # TODO: Ice caves sometimes injects these pool roomcodes into the level.
--[[
	UPDATE: Found the part of the code that places these rooms.
	steps:
		1. Post-path, select an unoccupied space.
		2. If 3/4 chance passes and the space under it is a sideroom, use two-room.
			Otherwise, spawn single room.
--]]
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				-- add room
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	spot = commonlib.TableRandomElement(spots)
	
	if (
		math.random(4) <= 3
		and (
			spot.y <= levelh - 1
			and global_levelassembly.modification.levelrooms[spot.y+1][spot.x] == nil
		)
	) then
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP,
			HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_TOP],
			spot.y, spot.x
		)
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM,
			HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_DOUBLE_BOTTOM],
			spot.y+1, spot.x
		)
	else
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE,
			HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.ICE_CAVES_POOL].rooms[genlib.HD_SUBCHUNKID.ICE_CAVES_POOL_SINGLE],
			spot.y, spot.x
		)
	end

end


HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA] = {
	prepath = false,
	rooms = {
		[genlib.HD_SUBCHUNKID.YAMA_LEFTSIDE] = {
			{"0000000000000070000000021207000000Q00120070000000021000000000Q000212000000000000"},
			{"00000000000000070000007021200002100Q00000000000070000000001202120000Q00000000000"},
			{"00000070000700001200010000L0000Q0020L000000000L000007000L020001200L0000000000000"},
			{"00070000000021000070000L000010000L0200Q0000L000000020L000700000L0021000000000000"},
			{"0000000000200000070000000001000010000L0000Q0020L001000000L0020007000000000100000"},
			{"00000000000070000002001000000000L000010000L0200Q0000L000000700000700010000010000"},
		},
		[genlib.HD_SUBCHUNKID.YAMA_RIGHTSIDE] = {
			{"0000000000000070000000021207000000Q00120070000000021000000000Q000212000000000000"},
			{"00000000000000070000007021200002100Q00000000000070000000001202120000Q00000000000"},
			{"00000070000700001200010000L0000Q0020L000000000L000007000L020001200L0000000000000"},
			{"00070000000021000070000L000010000L0200Q0000L000000020L000700000L0021000000000000"},
			{"0000000000200000070000000001000010000L0000Q0020L001000000L0020007000000000100000"},
			{"00000000000070000002001000000000L000010000L0200Q0000L000000700000700010000010000"},
		},
	}
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].setRooms = {
	-- 1
	-- {
	-- 	subchunk_id = genlib.HD_SUBCHUNKID.YAMA_TOP,
	-- 	placement = {1, 1},
	-- 	roomcodes = {{"0000Q000L000000000L0CCC00000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}}
	-- 	-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	-- },
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_1_2,
		placement = {1, 2},
		roomcodes = {{"0L00L0L0000L00L0L0000L00L000000000L000000000L000000000000Y0000000000000000000000"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_1_3,
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
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_LEFTSIDE,
		placement = {2, 1},
		roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[genlib.HD_SUBCHUNKID.YAMA_LEFTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_2_2,
		placement = {2, 2},
		roomcodes = {{"00000000000000000000000000000000000000000000000hhh0000000hyy0000000hyy0000000hyy"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_2_3,
		placement = {2, 3},
		roomcodes = {{"0000000000000000000000000000000000000000hhh0000000yyh0000000yyh0000000yyh0000000"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_RIGHTSIDE,
		placement = {2, 4},
		roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[genlib.HD_SUBCHUNKID.YAMA_RIGHTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},

	-- 3
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_LEFTSIDE,
		placement = {3, 1},
		roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[genlib.HD_SUBCHUNKID.YAMA_LEFTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_2,
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
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_3,
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
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_RIGHTSIDE,
		placement = {3, 4},
		roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].rooms[genlib.HD_SUBCHUNKID.YAMA_RIGHTSIDE])
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},

	-- 4
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_4_1,
		placement = {4, 1},
		roomcodes = {{"00000000000000000000000000000000000X00000&00qqq000000qqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_ENTRANCE,
		placement = {4, 2},
		roomcodes = {{"000000000000000000000000000000000000000000000z0009qqqqqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"000000000000000000000000000000000000000000000z0009qqqqqqqqqq00000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_4_3,
		placement = {4, 3},
		roomcodes = {{"00000000000000000000000000000000000000000000000000qqqqqqqqqqwwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
	{
		subchunk_id = genlib.HD_SUBCHUNKID.YAMA_SETROOM_4_4,
		placement = {4, 4},
		roomcodes = {{"0000000000000000000000000000000000X00000000qqq00&0qqqqqqq000wwwwwwwwwwwwwwwwwwww"}}
		-- roomcodes = {{"00000000000000000000000000000000000000000000000000000000000000000000000000000000"}}
	},
}
HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.YAMA].method = function()
	levelw, _ = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	exit_on_left = (math.random(2) == 1)
	
	if exit_on_left == true then
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.YAMA_EXIT,
			{{"0000Q000L000000000L009000000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}},
			1, 1
		)
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.YAMA_TOP,
			{{"0L000Q00000L000000000L00000CCC0L0h00hhhh000h00hhhh000h00hhhh000h00hhhh0000000000"}},
			1, levelw
		)
	else
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.YAMA_TOP,
			{{"0000Q000L000000000L0CCC00000L0hhhh00h0L0hhhh00h000hhhh00h000hhhh00h0000000000000"}},
			1, 1
		)
		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.YAMA_EXIT,
			{{"0L000Q00000L000000000L000000900L0h00hhhh000h00hhhh000h00hhhh000h00hhhh0000000000"}},
			1, levelw
		)
	end
end


HD_ROOMOBJECT.WORLDS = {}
HD_ROOMOBJECT.WORLDS[THEME.DWELLING] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				_, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

				if state.level == 1 then
					chunkPool_rand_index = math.random(9)
				elseif (
					CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					CHUNKBOOL_IDOL == true or
					_chunk_coords.hi == levelh
				) then
					chunkPool_rand_index = math.random(9)
				else
					if math.random(10) == 1 then
						CHUNKBOOL_IDOL = true
						return {idol = true}
					else
						chunkPool_rand_index = math.random(9)
					end
				end
				
				if chunkPool_rand_index == 4 and state.level < 3 then return {index = 2}
				else return {index = chunkPool_rand_index} end
			end,
			[genlib.HD_SUBCHUNKID.PATH_DROP] = function()
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
			[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = function()
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
			[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 32 -- default
				if (state.level < 3) then
					range_start, range_end = 1, 14
				else
					range_start, range_end = 15, 32
				end

				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
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
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000008000000000000000000L000000000P111111000L111111000L00111111111111111"},
			{"0000000000008000000000000000000000000L000111111P000111111L001111100L001111111111"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v1001111111101111111111",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1001111111101111111111"
			},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000002000000002"},
			{"11111111112222222222000000000000000000000008000000000000000000000000002000000002"},
			{"00000000000008000000000000000000L000000000P111111000Lvvvv11000L000v1111vvvv0v111"},
			{"0000000000008000000000000000000000000L000111111P00011vvvvL00111v000L00111v0vvvv1"},
			{
				"011111111001111111100vvvvvvvv00vv0000vv0000090000001v====v100111v000001111v0vv11",
				"011111111001111111100vvvvvvvv00vv0000vv0000009000001v====v1000000v111011vv0v1111"
			},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000006000060000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"00000000000010021110001001111000110111129012000000111111111021111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000111200100011110010021111011000000002109011111111102111111121111111111"},
		},
		[genlib.HD_SUBCHUNKID.IDOL] = {{"2200000022000000000000000000000000000000000000000000000000000000I000001111A01111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"vvvvvvvvvvv++++++++vvL00000g0vvPvvvvvvvv0L000000000L0:000:0011111111111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"vvvvvvvvvvv++++++++vvg000000LvvvvvvvvvPv00000000L000:000:0L011111111111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{""}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"vvvvvvvvvv0++++++++0vL00g000LvvPvvvvvvPv0L000000L00L000000L00L000000L01111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000L222222L0vPvvvvvvPvvL000000LvvL00g000Lvv========v"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"vvvvvvvvvvv++++++++vvL00g000LvvPvvvvvvPv0L000000L00L000000L00L000000L01111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000vvvvvv0000v0000v000L00g000L00Pv====vP00L0v00v0L00L000000L0111v00v111"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.JUNGLE] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (
					CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					CHUNKBOOL_IDOL == false and
					(
						feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false and feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) == false
					) and
					math.random(10) == 1
				) then
					CHUNKBOOL_IDOL = true
					return {idol = true}
				else
					chunkPool_rand_index = math.random(8)
				end
				
				return {index = chunkPool_rand_index}
			end,
		},
		obstacleBlocks = {
			[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 22 -- default
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

				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
		
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
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
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
			{"11111111111111111111120000002100000000000000000000022000022021120021121111001111"},
		},
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000000000000000000000000000000000000000000000000000002200000002111112002111"},
			{"000000000000000000000000000000000000000000000000002200000000112T0000001111001111"},
			{"00000000006000000000000000000000000000000000000000000000000000000000001000000001"},
			{"00000000000000000000000000000000000000000000000000000000000020000222221000011111"},
			{"00000000000000000000000000000000000000000000000000000000000022222000021111100001"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"01111111100222222220000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000080000000000000000000000000000000000001110000111"},
			{"60000600000000000000000000000000800000000000000000000000000000000000001110000111"},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"},
			{
				"1111111111L000011112L009000000L011000020L012000000021100000000220T00T01111111111",
				"1111111111211110000L000000900L020000110L000000210L00000011200T00T022001111111111"
			},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"20000000020000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.IDOL] = {{"01000000100000I0000001BBBBBB10010000001011wwwwww1111wwwwww11113wwww3111111111111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"ttttt11111t000000000tg0t000000ttttI0000000ttttt000ttttttt000rrrrrrrr001111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"11111ttttt000000000t000000tg0t00000Itttt000ttttt00000ttttttt00rrrrrrrr1111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}},       -- # TODO: See if unlock coffins can spawn as these. (I HIGHLY doubt it, though.)
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}}, --
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000tttt00000tttttt0000t0000t0000t0000t000000g0000001trrrrt101111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"000000000000000000000000g00000000tttt00000tt00tt00000000000001tt00tt1011rr00rr11"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000000000000000g00000000tttt00000tt00tt00000000000001tt00tt1011rr00rr11"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111122222000000"},
			{"211110222200000"},
			{"222220000000000"},
			{"111112111200000"},
		},
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000q1q0q111q"},
			{"00900q111q11111"},
			{"0090000100q212q"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD] = {
	level_dim = {w = 2, h = 12},
	-- unlockable coffin spawns at roomy == 11
	-- # TODO: When placing new roomcodes here, replace "v" tiles with "3"
	
	setRooms = {
		{
			-- prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.WORM_CRYSKNIFE_LEFTSIDE,
			placement = {6, 1},
			roomcodes = {
				{"0000000dd00011111110011333333w013wwwwwww013wwwwwww011cwwwwww00111111110000000000"}
			}
		},
		{
			-- prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.WORM_CRYSKNIFE_RIGHTSIDE,
			placement = {6, 2},
			roomcodes = {
				{"0dd00000000111111100w333333110wwwwwww310wwwwwww310wwwwwww11011111111000000000000"}
			}
		}
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"000000000000000000000001002000000000000000020020001s000000s111ssssss111111111111"},
			{"000000000000000000000002001000000000000000020020001s000000s111ssssss111111111111"},
			{"000000000000000000000002002000000000000000010010001s000000s111ssssss111111111111"}
		},
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"}
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000002021111120"},
			{"11111111112222222222000000000000000000000008000000000000000000000000002021111120"}
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"000000000000000000000000090000000111100001w3333w1001wwwwww1011wwwwww11133wwww331"},
			--{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"} -- unused
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"00000000000011111100000000000000000000000008000000000000000000000000001111111111"}
		},
		[genlib.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE] = {
			{"0dd0000dd02d0dddd0d20ddd00ddd02d0dddd0d20ddd00ddd000dddddd0011d0000d111111001111"}
		},

		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{""}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111001111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"11111111111100000011100000000100000000000000g00000100000000111000000111111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"10000000011100000011100000000100000000000000g00000100000000111000000111111001111"}},
	},
	
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
		},
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111122222000000"},
			{"211110222200000"},
			{"222220000000000"},
			{"111112111200000"},
		},
	},
}

HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].method = function()
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	local unlock_location_x, unlock_location_y = nil, nil

	-- Coffin
	if LEVEL_UNLOCK ~= nil then
		-- Select room coordinates between x = 1..2 and y = 11
		local unlock_location_x, unlock_location_y = math.random(1, levelw), 11
	
		local path_to_replace = global_levelassembly.modification.levelrooms[unlock_location_y][unlock_location_x]
		local path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK
	
		if path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP then
			path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP
		elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP then
			path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP
		elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
			path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP
		end
		levelcode_inject_roomcode(path_to_replace_with, HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[path_to_replace_with], unlock_location_y, unlock_location_x)
	end



	-- Replace two drop/drop_notop with WORM_REGENBLOCK_STRUCTURE.
	spots = {}
	for room_y = 1, levelh, 1 do
		for room_x = 1, levelw, 1 do
			path_to_replace = global_levelassembly.modification.levelrooms[room_y][room_x]
			path_to_replace_with = -1
			
			if (
				path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP
				or path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP_DROP
				and (
					unlock_location_x ~= nil and unlock_location_y ~= nil
					and unlock_location_x ~= room_x and unlock_location_y ~= room_y
				)
			) then
				table.insert(spots, {x = room_x, y = room_y})
			end
		
		end
	end
	if #spots ~= 0 then
		-- pick random place to fill
		local n = #spots
		local spot1_i = math.random(n)
		spot1 = spots[spot1_i]

		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE,
			HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[genlib.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE],
			spot1.y, spot1.x
		)

		spots[spot1_i] = nil
		commonlib.CompactList(spots, n)
		spot2 = spots[math.random(#spots)]

		levelcode_inject_roomcode(
			genlib.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE,
			HD_ROOMOBJECT.WORLDS[THEME.EGGPLANT_WORLD].rooms[genlib.HD_SUBCHUNKID.WORM_REGENBLOCK_STRUCTURE],
			spot2.y, spot2.x
		)
	end
	
end

function path_algorithm_icecaves_drop()
	if math.random(10) == 1 then
		return 13
	end
	local chunkpool_rand_index = math.random(state.level < 3 and 9 or 12)
	while (chunkpool_rand_index == 9) do
		chunkpool_rand_index = math.random(state.level < 3 and 9 or 12)
	end
	return chunkpool_rand_index
end
function path_algorithm_icecaves()
	if math.random(10) == 1 then
		return 13
	end
	return math.random(state.level < 3 and 9 or 12)--12 or 9)--TODO: Verify what FUN_004e0100() does (I think it's "hard")
end
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (math.random(2) == 2) then
					if (
						CHUNKBOOL_ALTAR == false and
						math.random(14) == 1
					) then
						CHUNKBOOL_ALTAR = true
						return {altar = true}
					elseif (
						CHUNKBOOL_IDOL == false and
						math.random(10) == 1
					) then
						CHUNKBOOL_IDOL = true
						return {idol = true}
					else
						chunkPool_rand_index = math.random(8)
					end
					
					return {index = chunkPool_rand_index}
				else
					return {index = path_algorithm_icecaves()+8} -- use path room algorithm + adjusted range 
				end
			end,
			[genlib.HD_SUBCHUNKID.PATH] = path_algorithm_icecaves,
			[genlib.HD_SUBCHUNKID.PATH_DROP] = path_algorithm_icecaves_drop,
			[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = path_algorithm_icecaves_drop
		},
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111111111",
				"00000000000000000000000000000000000000000080000000000000000000000000001111111111"
			},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000000011111110",
				"00000000000000000000000000000000000000000080000000000000000000000000000011111110"
			},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{
				"00000000000000000000000000000000000000000008000000000000000000000000001111qqq111",
				"0000000000000000000000000000000000000000008000000000000000000000000000111qqq1111"
			},
		},
		[genlib.HD_SUBCHUNKID.IDOL] = {{"00000000000000I000000000--00000000000000000000000000000000000000ss00000000110000"}},
		[genlib.HD_SUBCHUNKID.ALTAR] = {{"000000000000000000000000000000000000000000000000000000x0000002211112201111111111"}},
		[genlib.HD_SUBCHUNKID.VAULT] = {{
			--"02222222202111111112211|00011221100001122110EE0112211000011221111111120222222220"
			"02222222202111111112211|00011221100001122110000112211000011221111111120222222220"
			-- "02222222202000000002200|00000220000000022000000002200000000220000000020222222220" -- hd accurate sync
		}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"00:0000000iiii00f000i00:00000fig0i000000iiiiff0000iiii000ff00ii00000000000000000"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"0000000:00000f00iiiif00000:00i000000ig0i0000ffiiii0ff000iiii0000000ii00000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"0021111200021iiii12002i0000i20000000000000i0g00i0002iiiiii2000211112000002222000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"0000000000000000000000000000000000g000000fiiiiiif0000iiii00000000000000000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"0021111200021iiii12002i0000i20000000000000i0g00i0002iiiiii2000211112000002222000"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"0000000000000000000000000000000000g000000fiiiiiif0000iiii00000000000000000000000"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"000000000000000000000000g00000002111120000000000002111ff111200210012000000000000"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"000000000011111"},
			{"000001111122222"},
			{"111112222200000"},
			{"0jij00jij00jij0"},
		},
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.SIDE] = commonlib.TableConcat({
	{"20000000020000000000000000000000000000000000000000000000000000000000002000000002"},
	{"10000000001000000000111000000022201100000000220100000000010000000001110000000222"},
	{"00000000010000000001000000011100001102220010220000001000000011100000002220000000"},
	{"00000000000002112000000111100000f1111f000001111000f00211200f00021120000000000000"},
	{"0000000000000000000000220022000011ff11000011001200202100120220210012020002002000"},
	{"0jiiiiiij00jij00jij0jjii0jiij0000000jij0jjiij0iij00jiij0jijj0jiij000000jjiiiiijj"},
	{"0jiiiiiij00jij00jij00jii0jiijj0jij0000000jij0jiijj0jij0jiij000000jiij00jjiiiiijj"},
	{"011iiii110000jjjj0000000ii00000000jj00000000ii00000000jj00000000ii00000002222000"},
}, commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH]))
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH_DROP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH])
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH])
HD_ROOMOBJECT.WORLDS[THEME.ICE_CAVES].rooms[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
	{"00000000000000000000000000000000005000000000000000000000000000021111100000222211",
	"00000000000000000000000000000005000000000000000000000000000001111120001122220000"}
}

HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON] = {
	prePath = true,
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				chunkPool_rand_index = math.random(2)
				if math.random(10) == 1 then 
					chunkPool_rand_index = 3
				end
				return {index = chunkPool_rand_index}
			end,
		},
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
			{"00000000000000110000000022000010001100011000110001100000000120~0000~021111111111"},
			-- Zoo
			{"11110011110000000000010:00:01001111111100000000000m10:00:01m01111111101111111111"},
		},
		[genlib.HD_SUBCHUNKID.PATH] = {
			{"50000500000000000000000000000011111111115000050000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
			{"00000000000000000000000000000000002200000000000000000022000000000000001111001111"},
		},
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"000000000000000000000000000000000000000000000000000000mm000000000000001111111111"},
			{"0000000000000000000000000000000000~~0000000011000000001100000~001100~01111111111"},
		},
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"0000000000000000000000000000000000~~00000000110000000000000000~0000~001112002111"},
			{"000000000000000000000000000000000000000000000000000000mm000000000000001112002111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"}
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"000000000000000000000000000000000000000000000000000001mm100000219012001111111111"},
			{"000000000000000000000000000000000000000000000000000001mm100000210912001111111111"},
			{"0000000000000000000000000000000000~000000011111000011000110000009000001111111111"},
			{"00000000000000000000000000000000000~00000001111100001100011000000900001111111111"},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{"01000001000z00000z00000000000000000000000011011000011090110001111111001111111111"},
			{"001000001000z00000z0000000000000000000000001101100001109011000111111101111111111"},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"000000000000110011000010009100001111110000z0000z000000000000mm000000mm1111001111"},
			{"000000000000110011000019000100001111110000z0000z000000000000mm000000mm1111001111"},
		},
		
		[genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN] = {
			{
				"110000011010000000100000Q0000000000000000L00000L000110*01100L1111111L01111111111",
				"0110000011010000000100000Q0000000000000000L00000L000110*01100L1111111L1111111111",
				"1100000011100000001100000Q001100000000110LL11100010000010*0111000111111111001111",
				"110000001111000000011100Q0000011000000001000111LL010*010000011111000111111001111",
			},
		},
		[genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD] = {
			{ -- Alien Lord
				"0000000000000000000000111111000011X0000000110000000011111L000~111111~01111111111",
				"0000000000000000000000111111000000X01100000000110000L11111000~111111~01111111111"
			},
		},

		[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE] = {
			{"22222222220000000000000000000000000000000000000000000000000000000000000000000000"},
			{"11111111112222222222000000000000000000000000000000000000000000000000000000000000"},
			{"22211112220001111000000211200000011110000002112000000022000000000000000000000000"},
			{"11112211112112002112022000022000000000000000000000000000000000000000000000000000"},
		},

		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"11000000001111111110110010001011g00000001111100000000010000011000000~011111LLL11"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"000000001101111111110100010011000000g011000001111100000100000~0000001111LLL11111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"5000050000000000000000000000001111111111010z00z0100100g0001000001100001111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"500005000000000000000000000000101111110100000000000000g000000~001100~01111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"5000050000000000000000000000001111111111010z00z0100100g0001000001100001111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"500005000000000000000000000000101111110100000000000000g000000~001100~01111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"0000000000000011000000000000001000g000010000110000000000000000~0000~001112002111"}},
	},
	rowfive = {
		setRooms = {
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 1,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 2,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 3,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
			{
				subchunk_id = genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE,
				placement = 4,
				roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ICE_CAVES_ROW_FIVE])
			},
		}
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000001000010000"},
			{"000000000100001"},
			{"000000010000100"},
			{"000000000000000"},
		},
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"},
			{"009000212002120"},
			{"000000000092222"},
			{"000000000022229"},
			{"000001100119001"},
			{"000001001110091"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].method = function()
	level_generation_method_structure_vertical(
		{
			subchunk_id = genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN,
			roomcodes = HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENQUEEN]
		},
		nil,
		{1, 2, 3, 4}
	)

	-- # TODO: Make all HD_ROOMOBJECT.method functions have a prePath parameter. Then put below in prePath == false.
	--[[
		loop through top to bottom, replace the first two side rooms found with alienlord rooms
	--]]

	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 1, levelw, levelh

	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			local spawn_alienlord = false
			local pathid = global_levelassembly.modification.levelrooms[hi][wi]


			if pathid == genlib.HD_SUBCHUNKID.SIDE then
				if CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 == false then
					spawn_alienlord = true
					CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 = true
				elseif CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 == false then
					spawn_alienlord = true
					CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 = true
				else
					break
				end
			end

			if spawn_alienlord == true then
				levelcode_inject_roomcode(genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD, HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[genlib.HD_SUBCHUNKID.MOTHERSHIP_ALIENLORD], hi, wi)
			end
		end
	end
	

	if LEVEL_UNLOCK ~= nil then
		level_generation_method_aligned(
			{
				left = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = HD_ROOMOBJECT.WORLDS[THEME.NEO_BABYLON].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end
end

HD_ROOMOBJECT.WORLDS[THEME.TEMPLE] = {
	-- NOTE: All imported temple roomcodes have their "r" tiles replaced with "("
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				if (math.random(4) == 4) then
					chunkPool_rand_index = math.random(15, 24) -- use path roomcodes
				else
					if (
						CHUNKBOOL_ALTAR == false
						and math.random(14) == 1
					) then
						CHUNKBOOL_ALTAR = true
						return {altar = true}
					elseif (
						feelingslib.feeling_check(feelingslib.FEELING_ID.SACRIFICIALPIT) == false
						and CHUNKBOOL_IDOL == false
						and math.random(15) == 1
					) then
						CHUNKBOOL_IDOL = true
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
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
			{"1000000001100(000001100000000110000000011100000011000000000000000000001111111111"},
			{"1000000000100(000000100000000010000000001100000000000000000000000000001111111111"},
			{"0000000001000(000001000000000100000000010000000011000000000000000000001111111111"},
			{"0000000000000000000000000000000000&000000q3wwww3q0013wwww3101113w331111111111111"},
		},
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000000000000060000000000000001202000000"},
			{"00000000006000060000000000000000000000000500000000000000000000000000001111112021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111011200002111111001111"},
			{"0000000000006000000000000000000000000000000000000000q1122200021000000011101qqqq1"},
			{"000000000000600000000000000000000000000000000000000022211q0000000001201qqqq10111"},
			{"00000000000060000000000000000000000000000000000000002022020000100001001111001111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{"11111111110000000000000000000000000000000008000000000000000000000000001111111111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{"11111111110000000000000000000000000000000008000000000000000000000000002000000002"},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000000000000000"},
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			{"00000000000000000000000000000000000000000008000000000000000000000000000000000000"},
		},
		[genlib.HD_SUBCHUNKID.IDOL] = {{"11CCCCCC1111000000111D000000D11000000001100000000100000000000000I00000qqqqA0qqqq"}}, -- modified from original for sliding doors
		[genlib.HD_SUBCHUNKID.ALTAR] = {{"220000002200000000000000000000000000000000000000000000x0000000111111001111111111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{"111111111110001104004g00110400111000011010000000101wwwwwww111wwwwwww111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{"111111111100401100010040110g040110000111010000000111wwwwwww111wwwwwww11111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000222021112"},
			{"000000202021212"},
			{"111001111011111"},
			{"001110111111111"},
			{"211122222200000"},
			{"000220001100011"},
			{"220001100011000"},
			{"000000000000000"},
		},
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
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
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"00900q111q21112"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE] = commonlib.TableConcat({
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
}, commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH]))

HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
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
			prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.COG_BOTD_LEFTSIDE,
			placement = {3, 2},
			-- # TODO: alter this roomcode's altar (HAHHHH)
			roomcodes = {{"00000111110000011000000001100000Y00110001111111000000001100#00Y001100A1111111111"}}
		},
		{
			prePath = false,
			subchunk_id = genlib.HD_SUBCHUNKID.COG_BOTD_RIGHTSIDE,
			placement = {3, 3},
			roomcodes = {{"111110000000011000000001100Y000001111111000110000000011000000001100Y001111111111"}}
		}
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = commonlib.TableConcat(
			{
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][1],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][2],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][3],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][4],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][5],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][6],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][7],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][8],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][9],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][10],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][11],
				HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.SIDE][12]
			},
			commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH])
		),
		[genlib.HD_SUBCHUNKID.PATH] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH]),
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH_NOTOP]),
		[genlib.HD_SUBCHUNKID.PATH_DROP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH_DROP]),
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP]),
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
			{
				"011111110000000000000000000000000000000000z090z000011111110001111111001111111111",
				"0011111110000000000000000000000000000000000z090z00001111111000111111101111111111"
			},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
			{
				"011111110000000000000000000000000000000000z090z000011111110004000001001112002111",
				"0011111110000000000000000000000000000000000z090z00001111111000100000401112002111"
			},
		},
		[genlib.HD_SUBCHUNKID.EXIT] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.EXIT]),
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].rooms[genlib.HD_SUBCHUNKID.EXIT_NOTOP]),
		
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT] = {{""}},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_NOTOP] = {{""}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		-- [genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_DROP_NOTOP] = {{"000111100000110011000011g0110000011110000011111100000011000002201102201110000111"}},
		
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000000g000000000110000013wwww310013wwww31011133331111111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"100000000100000000001000g000011L011110L11P110011P10L000000L00L000000L01111001111"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[genlib.HD_OBSTACLEBLOCK.GROUND.tilename]),
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[genlib.HD_OBSTACLEBLOCK.AIR.tilename]),
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.TEMPLE].obstacleBlocks[genlib.HD_OBSTACLEBLOCK.DOOR.tilename]),
	},
}
HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD].method = function()
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 2, levelw, levelh
	--[[
		let the path generate as normal,
		then run this method to replace parts of it with the two middle setrooms and a few paths.
		Place paths along the sides and underneath where there isn't any.
	--]]

	for hi = minh, maxh, 1 do
		for wi = minw, maxw, 1 do
			pathid = -1
			
			if wi == minw or wi == maxw then
				if (hi == minh and
					(
						global_levelassembly.modification.levelrooms[hi][wi] == nil or
						(
							global_levelassembly.modification.levelrooms[hi][wi] ~= genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP and
							global_levelassembly.modification.levelrooms[hi][wi] ~= genlib.HD_SUBCHUNKID.PATH_NOTOP
						)
					)
				) then
					pathid = genlib.HD_SUBCHUNKID.PATH_DROP
				elseif hi == maxh then
					pathid = genlib.HD_SUBCHUNKID.PATH_NOTOP
				else
					pathid = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP
				end
			elseif hi == maxh then
				pathid = genlib.HD_SUBCHUNKID.PATH
			end

			if (
				global_levelassembly.modification.levelrooms[hi][wi] ~= nil and hi == maxh and
				(
					global_levelassembly.modification.levelrooms[hi][wi] == genlib.HD_SUBCHUNKID.EXIT or
					global_levelassembly.modification.levelrooms[hi][wi] == genlib.HD_SUBCHUNKID.EXIT_NOTOP
				)
			) then
				if ( -- exits under the middle setrooms can't be notop
					wi > minw and wi < maxw
				) then
					pathid = genlib.HD_SUBCHUNKID.EXIT
				elseif ( -- exits at corners have to be notop
					wi == minw or wi == maxw
				) then
					pathid = genlib.HD_SUBCHUNKID.EXIT_NOTOP
				end
			end

			if pathid ~= -1 then
				levelcode_inject_roomcode(pathid, HD_ROOMOBJECT.WORLDS[THEME.CITY_OF_GOLD].rooms[pathid], hi, wi)
			end
		end
	end
end

HD_ROOMOBJECT.WORLDS[THEME.OLMEC] = {
	level_dim = {w = 4, h = 2},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
			{"60000000000000000000000000000000000000000000000000600000000000000000000000000000"},
			{"00000600000000000000000000000000000000000000000000600000000000000000000000000000"},
			{"60000000000000000000000000000000000000000000000000000006000000000000000000000000"},
			{"60000600000000000000000000000000000000000000000000000000000000000000000000000000"},
			{"00000000000000000000000000000000000000000000000000600006000000000000000000000000"},
			{"00000000000000000000000000000000600000000000000000000000000000000000000000000000"},
		},
		[genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE] = {
			{"11111111111111111111111111111111111111111111111111111111111111111111111111111111"},
			{"11111111111222111111122211111111111111111111111111111111111111111111111111111111"},
			{"11111111111111111111111111111111122221111112222111111111111111111111111111111111"},
			{"11111111111111112221111111222111111111111111111111111111111111111111111111111111"},
			{"11111111111111111111111111111111111111111111111111122211111112221111111111111111"},
			{"11111111111111111111111111111111111111111111111111111111222111111122211111111111"},
		},
		[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK] = {
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
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"0EEE02111202220"},
			{"0000E0EEE121111"},
			{"E00001EEE011112"},
			{"1EE001111212200"},
			{"0EEE12111100221"},
			{"21112EEEEE11111"},
		},
	},
}
HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rowfive = {
	offsety = (-(3*CONST.ROOM_HEIGHT)-3),
	setRooms = {
		{
			subchunk_id = genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 1,
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 2,
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 3,
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
		{
			subchunk_id = genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE,
			placement = 4,
			roomcodes = commonlib.TableCopy(HD_ROOMOBJECT.WORLDS[THEME.OLMEC].rooms[genlib.HD_SUBCHUNKID.OLMEC_ROW_FIVE])
		},
	}
}

HD_ROOMOBJECT.WORLDS[THEME.VOLCANA] = {
	chunkRules = {
		rooms = {
			[genlib.HD_SUBCHUNKID.SIDE] = function(_chunk_coords)
				_, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

				if (
					CHUNKBOOL_ALTAR == false and
					math.random(14) == 1
				) then
					CHUNKBOOL_ALTAR = true
					return {altar = true}
				elseif (
					CHUNKBOOL_IDOL == false and
					_chunk_coords.hi ~= levelh
				) and math.random(10) == 1 then
					CHUNKBOOL_IDOL = true
					return {idol = true}
				else
					chunkPool_rand_index = math.random(9)
				end

				return {index = chunkPool_rand_index}
			end,
		},
		obstacleBlocks = {
			[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = function()
				range_start, range_end = 1, 2 -- default

				if (math.random(7) == 7) then
					range_start, range_end = 3, 5 -- iVar6 = uVar8 % 3 + 0x67;
				end

				chunkPool_rand_index = math.random(range_start, range_end)
				return chunkPool_rand_index
			end,
		}
	},
	rooms = {
		[genlib.HD_SUBCHUNKID.SIDE] = {
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
		[genlib.HD_SUBCHUNKID.PATH] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_NOTOP] = {
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
		[genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP] = {
			{"00000000006000060000000000000000000000006000060000000000000000000000000000000000"},
			{"00000000006000060000000000000000000000000000050000000000000000000000001200011111"},
			{"00000000006000060000000000000000000000005000000000000000000000000000001111100021"},
			{"00000000006000060000000000000000000000000000000000000000000002200002201112002111"},
			{"00000000000000220000000000000000200002000112002110011100111012000000211111001111"},
			{"001000010000L0110L0000L2112L0000L2112L0000L2112L0000L0110L0000001100001000000001"},
			{"00000000000f000000f00000000000000q00q00000010010000f010010f000010010001111001111"},
		},
		[genlib.HD_SUBCHUNKID.ENTRANCE] = {
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
		[genlib.HD_SUBCHUNKID.ENTRANCE_DROP] = {
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
		[genlib.HD_SUBCHUNKID.EXIT] = {
			-- {"000000000000100hhhh000100h00h000110h00h2001200000090111h==h011111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000hhhh001000h00h001002h00h0110000000021000h==h1110902111111111111111111"},
			{"60000600000000000000000000000000000000000008000000000000000000000000001111111111"},
			{"11111111112222222222000000000000000000000008000000000000000000000000001111111111"}
		},
		[genlib.HD_SUBCHUNKID.EXIT_NOTOP] = {
			-- {"00000000006000060000000000000000000000000008000000000000000000000000001111111111"}, --probably unused
			{"00000000000000000000000000000000000000000008000000000000000000000000001111111111"},
			-- {"000000000000100hhhh000100h00h000110h00h2001200000090111h==h011111111201111111111"}, -- # TOFIX: No exit spawns for this roomcode for some reason
			{"00000000000hhhh001000h00h001002h00h0110000000021000h==h1110902111111111111111111"},
		},
		[genlib.HD_SUBCHUNKID.IDOL] = {{"111111111101*1111*10001111110000000000000000I000000011A0110001*1111*101111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP] = {{"00000000000000000000001wwww100001wwww100011111111001100001100000g000001111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP] = {{"000000000000000000000011ww11000011ww1100011111111001100001100000g000001111111111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP] = {{"01111111100011111100000000000022000000220000g0000000001100000000QQ00001111001111"}},
		[genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP] = {{"01110011100011001100000000000022000000220000g0000000001100000000QQ00001111001111"}},
	},
	obstacleBlocks = {
		[genlib.HD_OBSTACLEBLOCK.GROUND.tilename] = {
			{"000000000022222"},
			{"000002222211111"},
			{"000000000000022"},
			{"00000sssss11111"},
			{"000000000022000"}
		},
		[genlib.HD_OBSTACLEBLOCK.AIR.tilename] = {
			{"111102222000000"},
			{"011110222200000"},
			{"222200000000000"},
			{"022220000000000"},
			{"011100222000000"},
			{"000000ssss01111"},
			{"00000ssss011110"},
		},
		[genlib.HD_OBSTACLEBLOCK.VINE.tilename] = {
			{"0hhh000u000000000000"},
			{"0hhh00u0u00000000000"},
			{"0hhh00uu000000000000"},
			{"0hh00hhhh0uhhu000000"},--uhhu0"}, -- the last row is unused in HD
			{"00hh00hhhh0uhhu00000"},--0uhhu"}, -- the last row is unused in HD
		},
		[genlib.HD_OBSTACLEBLOCK.DOOR.tilename] = {
			{"009000111011111"}
		},
	},
}


-- # TODO: For development of the new scripted level gen system, move tables/variables into here from init_onlevel() as needed.
function init_posttile_door()
	global_levelassembly = {}
end

-- post_tile-sensitive ON.START initializations
	-- Since ON.START runs on the first ON.SCREEN of a run, it runs after post_tile runs.
	-- Run this in post_tile to circumvent the issue.
function init_posttile_onstart()
	if POSTTILE_STARTBOOL == false then -- determine if you need to set new things
		POSTTILE_STARTBOOL = true
		feelingslib.init()
		wormtonguelib.tongue_spawned = false
		-- other stuff
	end
	-- message("wormtonguelib.tongue_spawned: " .. tostring(wormtonguelib.tongue_spawned))
end

function init_onlevel()
	tombstone_blocks = {}
	moai_veil = nil
	FRAG_PREVENTION_UID = nil
	DOOR_EXIT_TO_HAUNTEDCASTLE_POS = nil
	DOOR_EXIT_TO_BLACKMARKET_POS = nil

	
	CHUNKBOOL_IDOL = false
	CHUNKBOOL_ALTAR = false
	CHUNKBOOL_MOTHERSHIP_ALIENLORD_1 = false
	CHUNKBOOL_MOTHERSHIP_ALIENLORD_2 = false

	GIANTSPIDER_SPAWNED = false
	LOCKEDCHEST_KEY_SPAWNED = false
	
	LEVEL_UNLOCK = nil
	UNLOCK_WI, UNLOCK_HI = nil, nil

	COOP_COFFIN = false
	
	hdtypelib.init()
	botdlib.init()
	wormtonguelib.init()
	ghostlib.init()
	olmeclib.init()
	boulderlib.init()
	idollib.init()
	acid_tick = ACID_POISONTIME

end

function bubbles()
	local fx = get_entities_by_type(ENT_TYPE.FX_WATER_SURFACE)
	for i,v in ipairs(fx) do
		local x, y, l = get_position(v)
		if math.random() < 0.003 then
			spawn_entity(ENT_TYPE.ITEM_ACIDBUBBLE, x, y, l, 0, 0)
		end
	end
end

 -- Trix wrote this
function replace(ent1, ent2, x_mod, y_mod)
	affected = get_entities_by_type(ent1)
	for i,ent in ipairs(affected) do

		ex, ey, el = get_position(ent)
		e = get_entity(ent):as_movable()

		s = spawn(ent2, ex, ey, el, 0, 0)
		se = get_entity(s):as_movable()
		se.velocityx = e.velocityx*x_mod
		se.velocityy = e.velocityy*y_mod

		move_entity(ent, 0, 0, 0, 0)-- kill_entity(ent)
	end
end

function remove_damsel_spawn_item(x, y, l)
    local entity_uids = get_entities_at({
		ENT_TYPE.ITEM_CHEST,
		ENT_TYPE.ITEM_CRATE,
		ENT_TYPE.ITEM_RUBY,
		ENT_TYPE.ITEM_SAPPHIRE,
		ENT_TYPE.ITEM_EMERALD,
		ENT_TYPE.ITEM_GOLDBAR,
		ENT_TYPE.ITEM_GOLDBARS
	}, 0, x, y, l, 0.5)
	if #entity_uids ~= 0 then
		move_entity(entity_uids[1], 1000, 0, 0, 0)
	end
end

function remove_embedded_at(x, y, l)
	local entity_uids = get_entities_at({
		ENT_TYPE.EMBED_GOLD,
		ENT_TYPE.EMBED_GOLD_BIG,
		ENT_TYPE.ITEM_RUBY,
		ENT_TYPE.ITEM_SAPPHIRE,
		ENT_TYPE.ITEM_EMERALD,

		ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE,
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
		ENT_TYPE.ITEM_PICKUP_PARACHUTE,
		ENT_TYPE.ITEM_CAPE,
		ENT_TYPE.ITEM_JETPACK,
		ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
		ENT_TYPE.ITEM_HOVERPACK,
		ENT_TYPE.ITEM_POWERPACK,
		ENT_TYPE.ITEM_WEBGUN,
		ENT_TYPE.ITEM_SHOTGUN,
		ENT_TYPE.ITEM_FREEZERAY,
		ENT_TYPE.ITEM_CROSSBOW,
		ENT_TYPE.ITEM_CAMERA,
		ENT_TYPE.ITEM_TELEPORTER,
		ENT_TYPE.ITEM_MATTOCK,
		ENT_TYPE.ITEM_BOOMERANG,
		ENT_TYPE.ITEM_MACHETE
	}, 0, x, y, l, 0.5)
	if #entity_uids ~= 0 then
		-- message("Bye bye, embed! " .. x .. " " .. y)
		local entity = get_entity(entity_uids[1])
		-- entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
		entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
		-- move_entity(entity.uid, 1000, 0, 0, 0)
		entity:destroy()
	end
end

function remove_floor_and_embedded_at(x, y, l)
    local floor = get_grid_entity_at(x, y, l)
    if floor ~= -1 then
		remove_embedded_at(x, y, l)
        -- get_entity(floor):destroy()
		kill_entity(floor)
    end
end

function embed_item(enum, uid, frame)
	local x, y, l = get_position(uid)
	-- local ents = get_entities_at(0, 0, x, y, l, 0.1)
	-- if (#ents > 1) then return end
	remove_embedded_at(x, y, l)

	local entity = get_entity(spawn_entity_over(ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE, uid, 0, 0))
	entity.inside = enum
	entity.animation_frame = frame
	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
	return 0;
end

-- ha wrote this
	-- Break "3278409" up into setting/clearing specific flags.
	-- In testing, the mattock I embedded couldn't be picked up because it had ENT_FLAG.PASSES_THROUGH_OBJECTS enabled.
	
function embed_nonitem(enum, uid)
	local x, y, l = get_position(uid)
	-- local ents = get_entities_at(0, 0, x, y, l, 0.1)
	-- if (#ents > 1) then return end
	remove_embedded_at(x, y, l)

	local entitydb = get_type(enum)
	local previousdraw, previousflags = entitydb.draw_depth, entitydb.default_flags
	entitydb.draw_depth = 9
	entitydb.default_flags = 3278409 -- don't really need some flags for other things that dont explode, example is for jetpack
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.INVISIBLE)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
	-- entitydb.default_flags = set_flag(entitydb.default_flags, ENT_FLAG.NO_GRAVITY)
	-- entitydb.default_flags = clr_flag(entitydb.default_flags, ENT_FLAG.COLLIDES_WALLS)

	local entity = get_entity(spawn_entity_over(enum, uid, 0, 0))
	entitydb.draw_depth = previousdraw
	entitydb.default_flags = previousflags
--   apply_entity_db(entity.uid)
  
--   message("Spawned " .. tostring(entity.uid))
	return 0;
end
-- Example:
-- register_option_button('button', "Attempt to embed a Jetpack", function()
  -- first_level_entity = get_entities()[1] -- probably a floor
  -- embed(ENT_TYPE.ITEM_JETPACK, first_level_entity)
-- end)

-- # TODO: Use this as a base for distributing embedded treasure(? if needed)
-- Malacath wrote this
-- Randomly distributes treasure in minewood_floor
-- set_post_tile_code_callback(function(x, y, layer)
    -- local rand = math.random(100)
    -- if rand > 65 then
        -- local ents = get_entities_overlapping(ENT_TYPE.FLOORSTYLED_MINEWOOD, 0, x - 0.45, y - 0.45, x + 0.45, y + 0.45, layer);
        -- if #ents == 1 then -- if not 1 then something else was spawned here already
            -- if rand > 95 then
                -- spawn_entity_over(ENT_TYPE.ITEM_JETPACK, ents[1], 0, 0);
            -- elseif rand > 80 then
                -- spawn_entity_over(ENT_TYPE.EMBED_GOLD_BIG, ents[1], 0, 0);
            -- else
                -- spawn_entity_over(ENT_TYPE.EMBED_GOLD, ents[1], 0, 0);
            -- end
        -- end
    -- end
-- end, "minewood_floor")

--[[
	Run the chance for an area coffin to spawn.
	1 / (X - deaths), chance can't go better than 1/9
]]
function run_unlock_area_chance()
	if (
		state.world < 5
	) then
		area_and_deaths = 301 - savegame.deaths
		if state.world == 1 then
			area_and_deaths = 51 - savegame.deaths
		elseif state.world == 2 then
			area_and_deaths = 101 - savegame.deaths
		elseif state.world == 3 then
			area_and_deaths = 201 - savegame.deaths
		end

		chance = (area_and_deaths < 9) and 9 or area_and_deaths

		if math.random(chance) == 1 then
			return true
		end
	end
	return false
end

-- Set LEVEL_UNLOCK
function get_unlock()
	local unlock = nil
	if (
		CHARACTER_UNLOCK_SPAWNED_DURING_RUN == false
		and state.items.player_count == 1
	) then
		if (
			unlockslib.detect_if_area_unlock_not_unlocked_yet()
			and run_unlock_area_chance()
		) then -- AREA_RAND* unlocks
			rand_pool = {
				unlockslib.HD_UNLOCK_ID.AREA_RAND1,
				unlockslib.HD_UNLOCK_ID.AREA_RAND2,
				unlockslib.HD_UNLOCK_ID.AREA_RAND3,
				unlockslib.HD_UNLOCK_ID.AREA_RAND4
			}
			coffin_rand_pool = {}
			chunkPool_rand_index = 1
			n = #rand_pool
			for rand_index = 1, #rand_pool, 1 do
				if unlockslib.HD_UNLOCKS[rand_pool[rand_index]].unlocked == true then
					rand_pool[rand_index] = nil
				end
			end
			rand_pool = commonlib.CompactList(rand_pool, n)
			chunkPool_rand_index = math.random(1, #rand_pool)
			unlock = rand_pool[chunkPool_rand_index]
		else -- feeling/theme-based unlocks
			local unlockconditions_feeling = {}
			local unlockconditions_theme = {}
			for id, unlock_properties in pairs(unlockslib.HD_UNLOCKS) do
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
	LEVEL_UNLOCK = unlock
	if LEVEL_UNLOCK ~= nil then
		CHARACTER_UNLOCK_SPAWNED_DURING_RUN = true
	end
end

function create_coffin_coop(x, y, l)
	coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	the_coffin = get_entity(coffin_uid)
	the_coffin.player_respawn = true
	return coffin_uid
end

-- # TODO: determining character unlock for coffin creation
function create_coffin_unlock(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	if LEVEL_UNLOCK ~= nil then
		--[[ 193 + unlock_num = ENT_TYPE.CHAR_* ]]
		set_contents(coffin_uid, 193 + unlockslib.HD_UNLOCKS[LEVEL_UNLOCK].unlock_id)
	end

	set_post_statemachine(coffin_uid, function()
		local coffin = get_entity(coffin_uid)
		if (
			coffin.animation_frame == 1
			and (
				LEVEL_UNLOCK ~= nil
				and (
					LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
					or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
					or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
					or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
				)
			)
		) then
			for i = 1, #unlockslib.RUN_UNLOCK_AREA, 1 do
				if unlockslib.RUN_UNLOCK_AREA[i].theme == state.theme then
					unlockslib.RUN_UNLOCK_AREA[i].unlocked = true 
					break
				end
			end
		end
	end)

	return coffin_uid
end

function create_ceiling_chain(x, y, l)
	local ent_to_spawn_over = nil
	local floors_at_offset = get_entities_at(0, MASK.FLOOR | MASK.ROPE, x, y+1, l, 0.5)
	if #floors_at_offset > 0 then ent_to_spawn_over = floors_at_offset[1] end

	if (
		ent_to_spawn_over ~= nil
	) then
		local ent = get_entity(ent_to_spawn_over)

		ent_to_spawn_over = spawn_entity_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ent_to_spawn_over, 0, -1)
		if (
			ent.type.id == ENT_TYPE.FLOOR_GENERIC
			or ent.type.id == ENT_TYPE.FLOORSTYLED_VLAD
			or ent.type.id == ENT_TYPE.FLOOR_BORDERTILE
		) then
			get_entity(ent_to_spawn_over).animation_frame = 4
		end
	end
end

function create_ceiling_chain_growable(x, y, l)
	local ent_to_spawn_over = nil
	local floors_at_offset = get_entities_at(0, MASK.FLOOR, x, y+1, LAYER.FRONT, 0.5)
	if #floors_at_offset > 0 then ent_to_spawn_over = floors_at_offset[1] end
	
	local yi = y
	while true do
		if (
			ent_to_spawn_over ~= nil
		) then
			local ent = get_entity(ent_to_spawn_over)

			ent_to_spawn_over = spawn_entity_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ent_to_spawn_over, 0, -1)
			if (
				ent.type.id == ENT_TYPE.FLOOR_GENERIC
				or ent.type.id == ENT_TYPE.FLOORSTYLED_VLAD
				or ent.type.id == ENT_TYPE.FLOOR_BORDERTILE
			) then
				get_entity(ent_to_spawn_over).animation_frame = 4
			end
			yi = yi - 1
			floors_at_offset = get_entities_at(0, MASK.FLOOR, x, yi-1, LAYER.FRONT, 0.5)
			floors_at_offset = commonlib.TableConcat(floors_at_offset, get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, yi-2, LAYER.FRONT, 0.5))
			if #floors_at_offset > 0 then break end
		else break end
	end
end

function create_embedded(ent_toembedin, entity_type)
	if entity_type ~= ENT_TYPE.EMBED_GOLD and entity_type ~= ENT_TYPE.EMBED_GOLD_BIG then
		local entity_db = get_type(entity_type)
		local previous_draw, previous_flags = entity_db.draw_depth, entity_db.default_flags
		entity_db.draw_depth = 9
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.INVISIBLE)
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
		entity_db.default_flags = set_flag(entity_db.default_flags, ENT_FLAG.NO_GRAVITY)
		entity_db.default_flags = clr_flag(entity_db.default_flags, ENT_FLAG.COLLIDES_WALLS)
		local entity = get_entity(spawn_entity_over(entity_type, ent_toembedin, 0, 0))
		entity_db.draw_depth = previous_draw
		entity_db.default_flags = previous_flags
	else
		spawn_entity_over(entity_type, ent_toembedin, 0, 0)
	end
end

function create_door_ending(x, y, l)
	-- # TODO: Remove exit door from the editor and spawn it manually here.
	-- Why? Currently the exit door spawns tidepool-specific critters and ambience sounds, which will probably go away once an exit door isn't there initially.
	-- ALTERNATIVE: kill ambient entities and critters. May allow compass to work.
	-- # TOTEST: Test if the compass works for this. If not, use the method Mr Auto suggested (attatching the compass arrow entity to it)
	olmeclib.DOOR_ENDGAME_OLMEC_UID = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	set_door_target(olmeclib.DOOR_ENDGAME_OLMEC_UID, 4, 2, THEME.TIAMAT)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	if options.hd_debug_boss_exits_unlock == false then
		lock_door_at(x, y)
	end
	-- Olmec/Yama Win
	if state.theme == THEME.OLMEC then
		set_interval(exit_olmec, 1)
	elseif feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) then
		set_interval(exit_yama, 1)
	end
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
end

function create_door_entrance(x, y, l)
	-- # create the entrance door at the specified game coordinates.
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == true then
		get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_DECO_JUNGLE_2)
	end
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	if (
		test_flag(state.level_flags, 18) == true
		and state.theme ~= THEME.VOLCANA
	) then
		ent = get_entity(spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_TORCH, x, y, l, 0, 0))
		ent:light_up(true)
	end
	-- assign coordinates to a global variable to define the game coordinates the player needs to be
	global_levelassembly.entrance = {x = x, y = y}
	state.level_gen.spawn_x, state.level_gen.spawn_y = x, y
end

function create_door_testing(x, y, l)
	DOOR_TESTING_UID = spawn_door(x, y, l, 1, 1, THEME.DWELLING)--THEME.TIDE_POOL)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_3)
	get_entity(door_bg).animation_frame = 1
end

function create_door_tutorial(x, y, l)
	if demolib.DEMO_TUTORIAL_AVAILABLE == true then
		DOOR_TUTORIAL_UID = spawn_door(x, y, l, 1, 1, THEME.DWELLING)
	else
		local construction_sign = get_entity(spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, l, 0, 0))
		construction_sign:set_draw_depth(40)
	end
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
end

function create_door_exit(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity_over(ENT_TYPE.FX_COMPASS, door_target, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
	local _w, _l, _t = hd_exit_levelhandling()
	set_door_target(door_target, _w, _l, _t)
	-- spawn_door(x, y, l, state.world_next, state.level_next, state.theme_next)

	-- state.level_gen.exits.door1_x, state.level_gen.exits.door1_y = x, y
	
	-- local format_name = F'levelcode_bake_spawn(): Created Exit Door with targets: {state.world_next}, {state.level_next}, {state.theme_next}'
	-- message(format_name)
	if state.shoppie_aggro_next > 0 then
		local shopkeeper = get_entity(spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x, y, l, 0, 0))
		shopkeeper.is_patrolling = true
		-- shopkeeper.room_index(get_room_index(x, y)) -- fix this. Room index of shopkeeper value isn't in the same format as the value that get_rom_index outputs.
	end
end

function create_door_exit_moai(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	-- spawn_entity_over(ENT_TYPE.FX_COMPASS, door_target, 0, 0)
	-- spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg).animation_frame = 1
	local _w, _l, _t = hd_exit_levelhandling()
	set_door_target(door_target, _w, _l, _t)
	global_levelassembly.moai_exit = {x = x, y = y}
end

function create_door_exit_to_hell(x, y, l)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EGGPLANT_WORLD, x, y, l, 0, 0)
	set_door_target(door_target, 5, 1, THEME.VOLCANA)
	
	if botdlib.OBTAINED_BOOKOFDEAD == true then
		helldoor_e = get_entity(door_target):as_movable()
		helldoor_e.flags = set_flag(helldoor_e.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
		helldoor_e.flags = clr_flag(helldoor_e.flags, ENT_FLAG.LOCKED)
	end
end

-- creates mothership entrance
function create_door_exit_to_mothership(x, y, l)
	-- _door_uid = spawn_door(x, y, l, 3, 3, THEME.NEO_BABYLON)
	door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_BABYLON_1)
	get_entity(door_bg).animation_frame = 1
	set_door_target(door_target, 3, 3, THEME.NEO_BABYLON)
end

-- creates blackmarket entrance
function create_door_exit_to_blackmarket(x, y, l)
	spawn_entity(ENT_TYPE.LOGICAL_BLACKMARKET_DOOR, x, y, l, 0, 0)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	-- get_entity(door_bg):set_texture(TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_1)
	get_entity(door_bg).animation_frame = 1
	DOOR_EXIT_TO_BLACKMARKET_POS = {x = x, y = y}
	set_interval(entrance_blackmarket, 1)
end

function create_door_exit_to_hauntedcastle(x, y, l)
	spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, l, 0, 0)
	door_bg = spawn_entity(ENT_TYPE.BG_DOOR, x, y+0.31, l, 0, 0)
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_JUNGLE_2)
	texture_def.texture_path = "res/deco_jungle_hauntedcastle.png"
	get_entity(door_bg):set_texture(define_texture(texture_def))
	get_entity(door_bg).animation_frame = 1
	DOOR_EXIT_TO_HAUNTEDCASTLE_POS = {x = x, y = y}
	set_interval(entrance_hauntedcastle, 1)
end

-- # TODO: Revise to a new pickup. 
	-- IDEAS:
		-- Replace with actual crysknife
			-- Upgrade player whip damage?
			-- put crysknife animations in the empty space in items.png (animation_frame = 120 - 126 for crysknife) and then animating it behind the player
			-- Can't make player whip invisible, apparently, so that might be hard to do
		-- Permanent firewhip
		-- Just spawn a powerpack
			-- It's the spiritual successor to the crysknife, so its a fitting replacement
			-- I'm planning to make bacterium use FLOOR_THORN_VINE for damage, so allowing them to break with firewhip would play into HDs feature of being able to kill them.
			-- In HD a good way of dispatching bacterium was with bombs, but they moved fast and went up walls so it was hard to time correctly.
				-- So the powerpack would naturally balance things out by making bombs more effective against them.
function create_crysknife(x, y, l)
	spawn_entity(ENT_TYPE.ITEM_POWERPACK, x, y, l, 0, 0)--ENT_TYPE.ITEM_EXCALIBUR, x, y, layer, 0, 0)
end

function create_liquidfall(x, y, l, texture_path, is_lava)
	local is_lava = is_lava or false
	local type = ENT_TYPE.LOGICAL_WATER_DRAIN
	if is_lava == true then
		type = ENT_TYPE.LOGICAL_LAVA_DRAIN
	end
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
	texture_def.texture_path = texture_path
	drain_texture = define_texture(texture_def)
	local drain_uid = spawn_entity(type, x, y, l, 0, 0)
	get_entity(drain_uid):set_texture(drain_texture)

	local backgrounds = entity_get_items_by(drain_uid, ENT_TYPE.BG_WATER_FOUNTAIN, 0)
	if #backgrounds ~= 0 then
		local texture_def2 = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
		texture_def2.texture_path = texture_path
		fountain_texture = define_texture(texture_def2)

		local fountain = get_entity(backgrounds[1])
		fountain:set_texture(fountain_texture)
	end
end

function create_regenblock(x, y, l)
	spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK, x, y, l, 0, 0)
	local regen_bg = get_entity(spawn_entity(ENT_TYPE.MIDBG, x, y, l, 0, 0))
	regen_bg:set_texture(TEXTURE.DATA_TEXTURES_FLOOR_SUNKEN_0)
	regen_bg.animation_frame = 137
	regen_bg:set_draw_depth(47)
	regen_bg.width, regen_bg.height = 1, 1
	-- regen_bg.tile_width, regen_bg.tile_height = regen_bg.width/10, regen_bg.height/10
	regen_bg.hitboxx, regen_bg.hitboxy = regen_bg.width/2, regen_bg.height/2
end

function create_damsel(x, y, l)
	local pet_setting = get_setting(GAME_SETTING.PET_STYLE)
	local pet_type = math.random(ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_CAT+2)
	if pet_setting == 0 then
		pet_type = ENT_TYPE.MONS_PET_DOG
	elseif pet_setting == 1 then
		pet_type = ENT_TYPE.MONS_PET_CAT
	elseif pet_setting == 2 then
		pet_type = ENT_TYPE.MONS_PET_HAMSTER
	end
	spawn_grid_entity(pet_type, x, y, l, 0, 0)
end

function create_idol(x, y, l)
	idollib.IDOL_X, idollib.IDOL_Y = x, y
	idollib.IDOL_UID = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_IDOL, idollib.IDOL_X, idollib.IDOL_Y, l, 0, 0)
	if state.theme == THEME.ICE_CAVES then
		-- .trap_triggered: "if you set it to true for the ice caves or volcano idol, the trap won't trigger"
		get_entity(idollib.IDOL_UID).trap_triggered = true
	end
end

function create_idol_crystalskull(x, y, l)
	idollib.IDOL_X, idollib.IDOL_Y = x, y
	idollib.IDOL_UID = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_MADAMETUSK_IDOL, idollib.IDOL_X, idollib.IDOL_Y, l, 0, 0)

	local entity = get_entity(idollib.IDOL_UID)
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
	texture_def.texture_path = "res/items_dar_idol.png"
	entity:set_texture(define_texture(texture_def))
end

function detect_same_levelstate(t_a, l_a, w_a)
	if state.theme == t_a and state.level == l_a and state.world == w_a then return true else return false end
end

-- prevent dark levels for specific states
function clear_dark_level()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
		or worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING
		or state.theme == THEME.VOLCANA
		or state.theme == THEME.NEO_BABYLON
		or feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT) == true
		or feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == true
	) then
		state.level_flags = clr_flag(state.level_flags, 18)
	end
end

function remove_borderfloor()
	local xmin, _, xmax, ymax = get_bounds()
	for yi = ymax-0.5, (ymax-0.5)-2, -1 do
		for xi = xmin+0.5, xmax-0.5, 1 do
			local blocks = get_entities_at(0, MASK.FLOOR, xi, yi, LAYER.FRONT, 0.3)
			kill_entity(blocks[1])
		end
	end
end

function remove_entitytype_inventory(entity_type, inventory_entities)
	-- items = get_entities_by_type(inventory_entities)
	-- for r, inventoryitem in ipairs(items) do
	-- 	local mount = get_entity(inventoryitem):topmost()
	-- 	if mount ~= -1 and mount:as_container().type.id == entity_type then
	-- 		move_entity(inventoryitem, -r, 0, 0, 0)
	-- 		-- message("Should be hermitcrab: ".. mount.uid)
	-- 	end
	-- end
	for r, _uid in ipairs(get_entities_by_type(entity_type)) do
		for _, inventoryitem in ipairs(inventory_entities) do
			local items = entity_get_items_by(_uid, inventoryitem, 0)
			for _, _to_remove_uid in ipairs(items) do
				move_entity(_to_remove_uid, -r, 0, 0, 0)
				--[[
					-- # TODO: Find a better way to remove powderkegs and pushblocks. The following uncommented code does not remove it propperly.
					local entity = get_entity(_to_remove_uid)
					entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
					kill_entity(_to_remove_uid)
				]]
			end
		end
	end
	
end

function changestate_onloading_targets(w_a, l_a, t_a, w_b, l_b, t_b)
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		-- if t_b == THEME.BASE_CAMP then
		-- 	state.screen_next = ON.CAMP
		-- end
		if test_flag(state.quest_flags, 1) == false then
			state.level_next = l_b
			state.world_next = w_b
			state.theme_next = t_b
			if t_b == THEME.BASE_CAMP then
				state.screen_next = ON.CAMP
			end
			-- if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
			-- 	state.screen_next = ON.LEVEL
			-- end
		end
	end
end

-- Used to "fake" world/theme/level
function changestate_onlevel_fake(w_a, l_a, t_a, w_b, l_b, t_b)
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		state.level = l_b
		state.world = w_b
		state.theme = t_b
	end
end

function changestate_samelevel_applyquestflags(w_a, l_a, t_a, flags_set, flags_clear)--w_b, l_b, t_b, flags_set, flags_clear)
	flags_set = flags_set or {}
	flags_clear = flags_clear or {}
	if detect_same_levelstate(t_a, l_a, w_a) == true then
		applyflags_to_quest({flags_set, flags_clear})
	end
end

function entrance_force_feeling(_feeling_to_force)
	local x, y = nil, nil
	if _feeling_to_force == feelingslib.FEELING_ID.BLACKMARKET and DOOR_EXIT_TO_BLACKMARKET_POS ~= nil then
		x, y = DOOR_EXIT_TO_BLACKMARKET_POS.x, DOOR_EXIT_TO_BLACKMARKET_POS.y
	elseif _feeling_to_force == feelingslib.FEELING_ID.HAUNTEDCASTLE and DOOR_EXIT_TO_HAUNTEDCASTLE_POS ~= nil then
		x, y = DOOR_EXIT_TO_HAUNTEDCASTLE_POS.x, DOOR_EXIT_TO_HAUNTEDCASTLE_POS.y
	end

	if x ~= nil and y ~= nil then
		local door_exits_here = get_entities_at(0, ENT_TYPE.FLOOR_DOOR_EXIT, x, y, LAYER.FRONT, 0.5)
		local door_spawned =  #door_exits_here ~= 0
		local door_exit_ent = door_spawned == true and get_entity(door_exits_here[1]) or nil
		local floor_removed = #get_entities_at(0, MASK.FLOOR, x, y, LAYER.FRONT, 0.5) == 0

		if floor_removed == true and door_spawned == false then
			local door_target = spawn(ENT_TYPE.FLOOR_DOOR_EXIT, x, y, LAYER.FRONT, 0, 0)
			local _w, _l, _t = hd_exit_levelhandling()
			set_door_target(door_target, _w, _l, _t)

			local sound = get_sound(VANILLA_SOUND.UI_SECRET)
			if sound ~= nil then sound:play() end

			local door_spawned = true -- for those who can frame-perfect :spelunkoid:
			local door_exit_ent = get_entity(door_target)
		end
		if door_spawned == true then
			for i = 1, #players, 1 do
				if (
					door_exit_ent:overlaps_with(get_entity(players[i].uid)) == true and
					players[i].state == CHAR_STATE.ENTERING
				) then
					feelingslib.feeling_set_once(_feeling_to_force, {state.level+1})
					break;
				end
			end
		end
	end
end

function entrance_blackmarket()
	entrance_force_feeling(feelingslib.FEELING_ID.BLACKMARKET)
end

function entrance_hauntedcastle()
	entrance_force_feeling(feelingslib.FEELING_ID.HAUNTEDCASTLE)
end

-- # TODO: Either merge `exit_*BOSS*` methods or make exit_yama more specific
function exit_boss(yama)
	local yama = false or yama
	local win_state = WIN_STATE.NO_WIN
	for i = 1, #players, 1 do
		x, y, l = get_position(players[i].uid)
		if (
			-- (get_entity(olmeclib.DOOR_ENDGAME_OLMEC_UID).entered == true)
			(players[i].state == CHAR_STATE.ENTERING)
		) then
			if yama == false then
				if (y > 95) then
					win_state = WIN_STATE.TIAMAT_WIN
					-- state.theme = THEME.TIAMAT
					break
				end
			else
				win_state = WIN_STATE.HUNDUN_WIN
				-- state.theme = THEME.HUNDUN
				break
			end
		end
	end
	state.win_state = win_state
end

function exit_olmec()
	exit_boss()
end

function exit_yama()
	exit_boss(true)
end

function entrance_force_worldstate(_worldstate, _entrance_uid)
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
		door_entrance_ent = get_entity(_entrance_uid)
		if door_entrance_ent ~= nil then
			for i = 1, #players, 1 do
				if (
					door_entrance_ent:overlaps_with(get_entity(players[i].uid)) == true and
					players[i].state == CHAR_STATE.ENTERING
				) then
					worldlib.HD_WORLDSTATE_STATE = _worldstate
					break;
				end
			end
		end
	end
end

function entrance_testing()
	entrance_force_worldstate(worldlib.HD_WORLDSTATE_STATUS.TESTING, DOOR_TESTING_UID)
end

function entrance_tutorial()
	entrance_force_worldstate(worldlib.HD_WORLDSTATE_STATUS.TUTORIAL, DOOR_TUTORIAL_UID)
end

function testroom_level_1()
	--[[
		Coordinates of each floor:
		Top:	x = 13..32,	y = 112
		Middle:	x = 13..32,	y = 109
		Bottom:	x = 5..40,	y = 101
	--]]
	
	--[[
		Thanks for offering to help with this.
		The door below the rope at the camp will take you to the testing area.
	--]]

	--[[
		Here's the behavior inheritance feature, as examplified by the scorpionfly.

			- ****Here I'm using an imp instead of the bat for the agro behavior because bats make noise. I adjusted the
				script that removes hermitcrab items to support removing the imp's lavapot but that's not working for
				some reason. For now, just pause and use MOUSE 3 to move the lavapot out of the way to see it in action.

			- There are some HD enemies that weren't recreated in the sequal but had some of their behaviors
				used for new ones. Take the scorpion fly: In HD, an idle and pre-agro scorpionfly behaves like
				a mosquito. When agrod, it targets the player, heading toward them like a bat/imp. When it takes
				a point of damage, health is taken from it, it looses its wings and behaves like a scorpion.
				We can create a scorpionfly by "duct-taping" these enemies together and toggling the physics, AI,
				and visibility of each one at the appropriate times.

				Since there are several HD enemies that could be recreated this way, we should make a system for it.
				Maybe we could provide fields like "agro" and "idle" to assign uids to, and the way they are handled
				is through methods you can assign to run on each frame. That way we can reduce duplicate code.

				Another thing I'll point out is that the imp is invisible and the scorpion is colored red. Ideally we
				should be toggling the visibility of these enemies and reskin them with their HD frames (or at least in
				situations where they are using the same animations). The mosquito's idle state animation uses the same
				frames that the scorpion fly did; So does the imp for agro and the scorpion for all of its animations.
				res/monsters01_scorpionfly.png
				res/monstersbasic01_scorpionfly.png

				There are more enemy textures I've prepared to get some ideas across. They'll probably see a lot of
				changes so feel free to change them. The .ase files are in src/.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.SCORPIONFLY, 24, 108, LAYER.FRONT, false, 0, 0)
	
	--[[
		- now that I look back on it a lot of stuff like these HD_ENT fields:
			
				dangertype = HD_DANGERTYPE.FLOORTRAP,
				collisiontype = hdtypelib.HD_COLLISIONTYPE.FLOORTRAP,
			
			are just overcomplicating things so it might be better to just remove and start over with some things.
			Dangertype isn't used for anything so that can be removed, but some things like the collisiontype
			field might be useful in `is_valid_*_spawn` methods.
			Both the tikitrap and hangspider need to use spawn_entity_over for their creation, so maybe make an
			HD_ENT field for a method interacting with a passed-in uid.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.HANGSPIDER, 26, 104, LAYER.FRONT, false, 0, 0)
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.TRAP_TIKI, 14, 110, LAYER.FRONT, false, 0, 0)


	--[[
		- These last two are examples of enemies that require common flags, fields, and methods.
			In HD, the snail has 1 hp and doesn't leave a corpse. So what was needed was to remove the hermetcrab's
			backitem, set its health, and disable its corpse. The eggsac is a similar story: we're replacing the
			S2 maggots with wormbabies, which also have one health and no corpse.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.SNAIL, 24, 110, LAYER.FRONT, false, 0, 0)
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.EGGSAC, 28, 110, LAYER.FRONT, false, 0, 0)

	--[[
		- I've set up a bunch of procedural spawn methods to fill under the prefix `global_procedural_spawn_*`
	--]]

	-- thank you and good luck :derekapproves:
end

function testroom_level_2()
	
end

function onlevel_testroom()
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
		if state.level == 1 then
			testroom_level_1()
		elseif state.level == 2 then
			testroom_level_2()
		end
	end
end

function test_bacterium()
	-- Bacterium Creation
		-- FLOOR_THORN_VINE:
			-- flags = clr_flag(flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) -- indestructable (maybe need to clear this? Not sure yet)
			-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
			-- visible
			-- allow hurting player
			-- allow bombs to destroy them.
		-- ACTIVEFLOOR_BUSHBLOCK:
			-- invisible
			-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
			-- allow taking damage (unless it's already enabled by default)
		-- ITEM_ROCK:
			-- disable ai and physics
				-- re-enable once detached from surface
	-- Challenge: Let rock attatch to surface, move it on frame.

	-- Bacterium Behavior
		-- Bacterium Movement Script
		-- **Behavior is handled in onframe_manage_dangers()
		-- Class requirements:
		-- - Destination {float, float}
		-- - Angle int
		-- - Entity uid:
		-- - stun timeout (May be possible to track with the entity)
		-- # TODO: Bacterium Movement Script
		-- Detect whether it is owned by a wall and if the wall exists, and if not, attempt to adopt a wall within all
		-- 4 sides of it. If that fails, enable physics if not already.
		-- If it is owned by a wall, detect 
		-- PROTOTYPING:
		-- if {x, y} == destination, then:
		--   if "block to immediate right", then:
		--     if "block to immediate front", then:
		--       rotate -90d;
		--     end
		--     own block to immediate right;
		--   else:
		--     rotate 90d;
		--   end
		--   destination = {x, y} of immediate front
		-- go towards the destination;
		-- end
		-- **Get to the point where you can store a single bacterium in an array, get placed on a wall and toast the angle it's chosen to face.
end

define_tile_code("hd_door_tutorial")
define_tile_code("hd_door_testing")

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return 0
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_LEPRECHAUN)

set_pre_entity_spawn(function(type, x, y, l, _)
	local rx, ry = get_room_index(x, y)
	if (
		LEVEL_UNLOCK ~= nil
		and (
			(UNLOCK_WI ~= nil and UNLOCK_WI == rx+1)
			and (UNLOCK_HI ~= nil and UNLOCK_HI == ry+1)
		)
	) then
		local uid = spawn_grid_entity(193 + unlockslib.HD_UNLOCKS[LEVEL_UNLOCK].unlock_id, x, y, l)
		-- # TODO: Find a way to manually unlock the character upon liberation from a shop.
		--[[
			Cosine: "If you're forced to get hacky, then you could try spawning a coffin out of bounds somewhere with the same character in it. I did this in Overlunky with Liz locked and it worked:
			You'll have to suppress the unlock dialog since it'll be pointing to wherever the coffin was out of bounds."
			
			local coffin_id = spawn_entity(ENT_TYPE.ITEM_COFFIN, -100, -100, LAYER.FRONT, 0, 0)
			get_entity(coffin_id).inside = ENT_TYPE.CHAR_GREEN_GIRL
		]]
		-- set_post_statemachine(uid, function()
		-- 	local ent = get_entity(uid)
		-- 	if test_flag(ent.flags, ENT_FLAG.SHOP_ITEM) == false then
		-- 		-- Can't manually unlock characters this way
		-- 		-- savegame.characters = set_flag(savegame.characters, unlockslib.HD_UNLOCKS[LEVEL_UNLOCK].unlock_id)

		-- 		return false
		-- 	end
		-- end)
		return uid
	end
	-- return spawn_grid_entity(ENT_TYPE.CHAR_HIREDHAND, x, y, l)
end, SPAWN_TYPE.LEVEL_GEN, 0, ENT_TYPE.CHAR_HIREDHAND)

-- set_post_entity_spawn(function(entity)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN_FLOOR_SPREADING, 0)

set_post_tile_code_callback(function(x, y, layer)
	create_door_tutorial(x, y, layer)
	return true
end, "hd_door_tutorial")

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_testing_door == true then
		create_door_testing(x, y, layer)
	end
	return true
end, "hd_door_testing")

set_pre_tile_code_callback(function(x, y, layer)
	local type_to_use = ENT_TYPE.FLOOR_GENERIC

	if state.theme == THEME.TEMPLE then
		type_to_use = (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE)
	end

	local entity = get_entity(spawn_grid_entity(type_to_use, x, y, layer, 0, 0))
	entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)

	return true
end, "shop_wall")

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l, 0, 0)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
	return spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x, y, l, 0, 0)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

set_post_entity_spawn(function(entity)
	entity:fix_decorations(true, true)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP)

-- set_pre_tile_code_callback(function(x, y, layer)
	-- if state.theme == THEME.JUNGLE then
		-- if detect_s2market() == true and layer == LAYER.FRONT and y < 88 then
			-- -- spawn(ENT_TYPE., x, y, layer, 0, 0)
			-- return true
		-- end
	-- end
	-- spawn(ENT_TYPE.FLOOR_GENERIC, x, y, layer, 0, 0)
	
	-- return true
-- end, "floor")

-- `set_pre_tile_code_callback` todos:
	-- “floor” -- if state.camp and shortcuts discovered, then
		-- if state.transition, if transition between worm and next level then
			-- replace floor with worm guts
		-- end
		-- if transition from jungle to ice caves then
			-- replace stone with floor_jungle end if transition from ice caves to temple then replace quicksand with stone
		-- end
		-- if state.level and detect_s2market()
			-- if (within the coordinates of where water should be)
				-- replace with water
			-- if (within the coordinates of where border should be)
				-- return false
			-- if (within the coordinates of where void should be)
				-- replace with nothing
			-- end
	-- “border(?)” see if you can change styles from here
		-- if detect_s2market() and `within the coordinates of where water should be` then
			-- replace with water
		-- end

	-- “treasure” if state.theme == THEME.OLMEC (or temple?) then use the hd tilecode chance for treasure when in temple/olmec
	-- “regenerating_wall50%” if state.theme == THEME.EGGPLANTWORLD then use the hd tilecode chance for floor50%(“2”) when in the worm

set_post_tile_code_callback(function(x, y, layer)
	if options.hd_debug_scripted_levelgen_disable == false then

		-- leveldoor_sx = x-1
		-- leveldoor_sy = y
		-- leveldoor_sx2 = x+1
		-- leveldoor_sy2 = y+3
		-- door_ents_masks = {
			-- MASK.PLAYER,	-- players (duh)
			-- MASK.MOUNT,		-- player mounts
			-- MASK.MONSTER,	-- exit-aggroed shopkeepers
			-- MASK.ITEM,		-- player-held items; entrance-spawned pots, skulls, torches;
			-- MASK.LOGICAL,
		-- }
		-- door_ents_uids = {}
		-- for _, door_ent_mask in ipairs(door_ents_masks) do
			-- door_ents_uids = commonlib.TableConcat(door_ents_uids, get_entities_overlapping(
				-- 0,
				-- door_ent_mask,
				-- leveldoor_sx,
				-- leveldoor_sy,
				-- leveldoor_sx2,
				-- leveldoor_sy2,
				-- LAYER.FRONT
			-- ))
		-- end
		
		-- TEMPORARY: Remove floor to avoid telefragging the player.
		
		-- if (
		-- 	state.theme ~= THEME.OLMEC
		-- ) then
		-- 	-- door_ents_uids = get_entities_at(0, MASK.FLOOR, x, y, layer, 1)
		-- 	-- for _, door_ents_uid in ipairs(door_ents_uids) do
		-- 	-- 	kill_entity(door_ents_uid)
		-- 	-- end
		-- 	FRAG_PREVENTION_UID = get_grid_entity_at(x, y, layer)
		-- 	local entity = get_entity(FRAG_PREVENTION_UID)
		-- 	if entity ~= nil then
		-- 		entity.flags = clr_flag(entity.flags, ENT_FLAG.SOLID)
		-- 	end
		-- end

		-- message("post-door: " .. tostring(state.time_level))
	else
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y+1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y+1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y, layer, 0, 0)

		spawn_entity(ENT_TYPE.LOGICAL_PLATFORM_SPAWNER, x, y-1, layer, 0, 0)

		
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-1, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-2, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-3, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y-4, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+1, y-4, layer, 0, 0)
		spawn_entity(ENT_TYPE.FLOOR_GENERIC, x+2, y-4, layer, 0, 0)
		
		create_door_exit(x+2, y, layer)
	end
end, "door")


function create_yama(x, y, l)-- 20, 117 = 22.5 117.5
	spawn_entity(ENT_TYPE.MONS_YAMA, x+2.5, y+.5, l, 0, 0)
end

--[[
	START PROCEDURAL/EXTRA SPAWN DEF
--]]

--[[
	-- Notes:
		-- kays:
			-- "I believe it's a 1/N chance that any possible place for that enemy to spawn, it spawns. so in your example, for level 2 about 1/20 of the possible tiles for that enemy to spawn will actually spawn it"
	
		-- Dr.BaconSlices (regarding the S2 screenshot with all dwelling enemies set to max spawn rates):
			--[[
				"Yup, all it does is roll that chance on any viable tile. There are a couple more quirks, or so I've heard,
				like enemies spawning with more air around them rather than in enclosed areas, whereas treasure is
				more likely to be in cramped places. And of course, it checks for viable tiles instead of any tile,
				so it won't place things inside of floors or other solids, within a liquid it isn't supposed to be in, etc.
				There's also stuff like bats generating along celiengs instead of the ground,
				but I don't think I need to explain that haha"
				"Oh yeah, I forgot to mention that. The priority is determined based on the list,
				which you can see here with 50 million bats but 0 spiders. I'm assuming both of
				their chances are set to 1,1,1,1 but you're still only seeing bats, and that's
				because they're generating in all of the places that spiders are able to."
			--]]
	-- Spawn requirements:
		-- Traps
			-- Notes:
				-- replaces FLOOR_* and FLOORSTYLED_* (so platforms count as spaces)
				-- don't spawn in place of gold/rocks/pots
			-- Arrow Trap:
				-- Notes:
					-- are the only damaging entity to spawn in the entrance 
				-- viable tiles:
					-- if there are two blocks and two spaces, mark the inside block for replacement, unless the trigger hitbox would touch the entrance door
				-- while spawning:
					-- don't spawn if it would result in its back touching another arrow trap
				
			-- Tiki Traps:
				-- Notes:
					-- Spawn after arrow traps
					-- are the only damaging entity to spawn in the entrance 
				-- viable space to place:
					-- Require a block on both sides of the block it's standing on
					-- Require a 3x2 space above the spawn
				-- viable tile to replace:
					-- 
				-- while spawning:
					-- don't spawn if it would result in its sides touching another tiki trap 
						-- HD doesn't check for this
--]]

local function detect_floor_at(x, y, l)
	local floor = get_grid_entity_at(x, y, l)
	return floor ~= -1
end

local function detect_floor_below(x, y, l)
	local floor = get_grid_entity_at(x, y-1, l)
	return floor ~= -1
end

local function detect_floor_above(x, y, l)
	local floor = get_grid_entity_at(x, y+1, l)
	return floor ~= -1
end

local function detect_floor_left(x, y, l)
	local floor = get_grid_entity_at(x-1, y, l)
	return floor ~= -1
end

local function detect_floor_right(x, y, l)
	local floor = get_grid_entity_at(x+1, y, l)
	return floor ~= -1
end

local function detect_empty_nodoor(x, y, l)
	-- local entity_uids = get_entities_at(0, MASK.MONSTER | MASK.ITEM | MASK.FLOOR, x, y, l, 0.5)
	local entity_uids = get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, y, l, 0.5)
	local door_not_here = #entity_uids == 0
	return (
		get_grid_entity_at(x, y, l) == -1
		and door_not_here
	)
end

local function detect_shop_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		get_room_template(rx, ry, l) == ROOM_TEMPLATE.SHOP
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.SHOP_LEFT
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.DICESHOP
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.DICESHOP_LEFT
	)
end

local function detect_entrance_room_template(x, y, l) -- is this position inside an entrance room?
	local rx, ry = get_room_index(x, y)
	return (
		get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE
		or get_room_template(rx, ry, l) == ROOM_TEMPLATE.ENTRANCE_DROP
	)
end

local function detect_solid_nonshop_nontree(x, y, l)
    local entity_here = get_grid_entity_at(x, y, l)
	if entity_here ~= -1 then
		entity_here = get_entity(entity_here)
		return (
			test_flag(entity_here.flags, ENT_FLAG.SOLID) == true
			and test_flag(entity_here.flags, ENT_FLAG.SHOP_FLOOR) == false
			and test_flag(entity_here.flags, ENT_FLAG.SHOP_FLOOR) == false
			and entity_here.type.id ~= ENT_TYPE.FLOOR_ALTAR
			and entity_here.type.id ~= ENT_TYPE.FLOOR_TREE_BASE
			and entity_here.type.id ~= ENT_TYPE.FLOOR_TREE_TRUNK
			and entity_here.type.id ~= ENT_TYPE.FLOOR_TREE_TOP
			and entity_here.type.id ~= ENT_TYPE.FLOOR_IDOL_BLOCK
		)
	end
	return false
end

-- Only spawn in a space that has floor above, below, and at least one left or right of it
local function is_valid_damsel_spawn(x, y, l)
    local entity_uids = get_entities_at({
		ENT_TYPE.FLOOR_GENERIC,
		ENT_TYPE.FLOOR_BORDERTILE,
		ENT_TYPE.FLOORSTYLED_MINEWOOD,
		ENT_TYPE.FLOORSTYLED_STONE,
		ENT_TYPE.ACTIVEFLOOR_POWDERKEG,
		ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK,
		ENT_TYPE.FLOOR_LADDER,
		ENT_TYPE.FLOOR_LADDER_PLATFORM,
		ENT_TYPE.MONS_PET_DOG,
		ENT_TYPE.MONS_PET_CAT,
		ENT_TYPE.MONS_PET_HAMSTER,
		ENT_TYPE.ITEM_BONES,
		ENT_TYPE.ITEM_POT,
		ENT_TYPE.ITEM_SKULL,
		ENT_TYPE.ITEM_ROCK,
		ENT_TYPE.ITEM_CURSEDPOT,
		ENT_TYPE.ITEM_WEB,
		ENT_TYPE.MONS_SKELETON,

		ENT_TYPE.ITEM_LOCKEDCHEST_KEY,
		ENT_TYPE.ITEM_LOCKEDCHEST,
	}, 0, x, y, l, 0.5)
	local not_entity_here = #entity_uids == 0
    if not_entity_here == true then
		local entity_uid = get_grid_entity_at(x, y - 1, l)
        local entity_below = entity_uid ~= -1 and (
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
			and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)

		local entity_uid = get_grid_entity_at(x, y + 1, l)
        local entity_above = entity_uid ~= -1 and (
			test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
			and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
		)
        if entity_below == true and entity_above == true then
			local entity_uid = get_grid_entity_at(x - 1, y, l)
            local entity_left = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
				and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
			)

			entity_uid = get_grid_entity_at(x + 1, y, l)
            local entity_right = entity_uid ~= -1 and (
				test_flag(get_entity_flags(entity_uid), ENT_FLAG.IS_PLATFORM) == false
				and test_flag(get_entity_flags(entity_uid), ENT_FLAG.SOLID)
			)
            if (
				(entity_left == true or entity_right == true)
				and detect_shop_room_template(x, y, l) == false
			) then
				return true
			end
        end
    end
    return false
end

-- 4 spaces available
local function is_valid_anubis_spawn(x, y, l)
	local cx, cy = x+.5, y-.5
	local w, h = 2, 2
    local entity_uids = get_entities_overlapping_hitbox(
		0, MASK.FLOOR,
		AABB:new(
			cx-(w/2),
			cy+(h/2),
			cx+(w/2),
			cy-(h/2)
		),
		l
	)
	return (
		#entity_uids == 0
		and detect_entrance_room_template(x, y, l) == false
	)
end

-- in path room
-- space available: 3x4 for jungle, 3x3 for icecaves
local function is_valid_wormtongue_spawn(x, y, l)
	-- if (
	-- 	global_levelassembly ~= nil
	-- 	and global_levelassembly.modification ~= nil
	-- 	and global_levelassembly.modification.levelrooms ~= nil
	-- ) then

	-- end
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	-- local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
	if roomy < 5 then

		local cx, cy = x, y
		local w, h = 3, state.theme == THEME.JUNGLE and 3 or 4
		local entity_uids = get_entities_overlapping_hitbox(
			0, MASK.FLOOR,
			AABB:new(
				cx-(w/2),
				cy+(h/2),
				cx+(w/2),
				cy-((h/2)+(state.theme == THEME.JUNGLE and 1 or 0))
			),
			l
		)
		return (
			#entity_uids == 0
			and detect_shop_room_template(x, y, l) == false
		)
	end
	return false
end

local function is_valid_blackmarket_spawn(x, y, l)
	local floor_uid = get_grid_entity_at(x, y, l)
	local floor_uid2 = get_grid_entity_at(x, y-1, l)
	if (
		floor_uid ~= -1
		and floor_uid2 ~= -1
	) then
		local floor = get_entity(floor_uid)
		local floor_type = get_entity_type(floor_uid)

		local floor2 = get_entity(floor_uid2)
		local floor_type2 = get_entity_type(floor_uid2)
		return (
			(
				test_flag(floor.flags, ENT_FLAG.SOLID) == true
				and test_flag(floor.flags, ENT_FLAG.SHOP_FLOOR) == false
				and floor_type ~= ENT_TYPE.FLOOR_BORDERTILE
				and floor_type ~= ENT_TYPE.FLOORSTYLED_MINEWOOD
				and floor_type ~= ENT_TYPE.FLOORSTYLED_STONE
				and floor_type ~= ENT_TYPE.FLOOR_TREE_BASE
				and floor_type ~= ENT_TYPE.FLOOR_TREE_TRUNK
				and floor_type ~= ENT_TYPE.FLOOR_TREE_TOP
				-- and floor_type ~= ENT_TYPE.FLOOR_LADDER
				-- and floor_type ~= ENT_TYPE.FLOOR_LADDER_PLATFORM
			)
			and (
				test_flag(floor2.flags, ENT_FLAG.SOLID) == true
				and test_flag(floor2.flags, ENT_FLAG.SHOP_FLOOR) == false
				and floor_type2 ~= ENT_TYPE.FLOOR_BORDERTILE
				and floor_type2 ~= ENT_TYPE.FLOORSTYLED_MINEWOOD
				and floor_type2 ~= ENT_TYPE.FLOORSTYLED_STONE
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_BASE
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_TRUNK
				and floor_type2 ~= ENT_TYPE.FLOOR_TREE_TOP
				-- and floor_type2 ~= ENT_TYPE.FLOOR_LADDER
				-- and floor_type2 ~= ENT_TYPE.FLOOR_LADDER_PLATFORM
			)
		)
	end
	return false
end

--[[
	Extra spawns use the prefix `global_spawn_extra_*`
--]]

local global_spawn_extra_blackmarket = define_extra_spawn(create_door_exit_to_blackmarket, is_valid_blackmarket_spawn, 0, 0)

local global_spawn_extra_locked_chest_and_key = define_extra_spawn(function(x, y, l)
	if LOCKEDCHEST_KEY_SPAWNED == false then
		spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST_KEY, x, y, l)
		LOCKEDCHEST_KEY_SPAWNED = true
	else
		spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST, x, y, l)
	end
	remove_damsel_spawn_item(x, y, l)
end, is_valid_damsel_spawn, 0, 0)

local function create_succubus(x, y, l) end
local global_spawn_extra_succubus = define_extra_spawn(create_succubus, is_valid_damsel_spawn, 0, 0)

local global_spawn_extra_hive_queenbee = define_extra_spawn(function(x, y, l) spawn_entity(ENT_TYPE.MONS_QUEENBEE, x, y, l, 0, 0) end, nil, 0, 0)

local global_spawn_extra_wormtongue = define_extra_spawn(wormtonguelib.create_wormtongue, is_valid_wormtongue_spawn, 0, 0)

local function create_anubis(x, y, l)
	get_entity(spawn_entity(ENT_TYPE.MONS_ANUBIS, x, y, l, 0, 0)).move_state = 5
end
local global_spawn_extra_anubis = define_extra_spawn(create_anubis, is_valid_anubis_spawn, 0, 0)

-- cog door(?) -- # TOFIX: Currently using S2 COG door implementation. If it ends up spawning in lava, will need to manually prevent that and do it here.  


--[[
	Procedural spawns use the prefix `global_spawn_procedural_*`
--]]

local global_spawn_procedural_spiderlair_ground_enemy = define_procedural_spawn("hd_procedural_spiderlair_ground_enemy", function(x, y, l) end, function(x, y, l) return false end)--throwaway method so we can define the chance in .lvl file and use it for ground enemy spawns
local function run_spiderlair_ground_enemy_chance()
	--[[
		if not spiderlair
		or 1/3 chance passes
	]]
	local current_ground_chance = get_procedural_spawn_chance(global_spawn_procedural_spiderlair_ground_enemy)
	if (
		feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) == false
		or (
			current_ground_chance ~= 0
			and math.random(current_ground_chance) == 1
		)
	) then
		return true
	end
	return false
end

local function is_valid_landmine_spawn(x, y, l) return false end -- # TODO: Implement method for valid landmine spawn
local global_spawn_procedural_landmine = define_procedural_spawn("hd_procedural_landmine", function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_LANDMINE, x, y, l) end, is_valid_landmine_spawn)

local function is_valid_bouncetrap_spawn(x, y, l) return false end -- # TODO: Implement method for valid bouncetrap spawn
local global_spawn_procedural_bouncetrap = define_procedural_spawn("hd_procedural_bouncetrap", function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, l) end, is_valid_bouncetrap_spawn)

local function create_caveman(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l) end
local function is_valid_caveman_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid caveman spawn
local global_spawn_procedural_caveman = define_procedural_spawn("hd_procedural_caveman", create_caveman, is_valid_caveman_spawn)
local global_spawn_procedural_worm_jungle_caveman = define_procedural_spawn("hd_procedural_worm_jungle_caveman", create_caveman, is_valid_caveman_spawn)

local function is_valid_scorpion_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid scorpion spawn
local global_spawn_procedural_scorpion = define_procedural_spawn("hd_procedural_scorpion", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCORPION, x, y, l) end, is_valid_scorpion_spawn)

local function is_valid_cobra_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
	)
end -- # TODO: Implement method for valid cobra spawn
local global_spawn_procedural_cobra = define_procedural_spawn("hd_procedural_cobra", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_COBRA, x, y, l) end, is_valid_cobra_spawn)

local function is_valid_snake_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
	)
end -- # TODO: Implement method for valid snake spawn
local global_spawn_procedural_snake = define_procedural_spawn("hd_procedural_snake", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l) end, is_valid_snake_spawn)

local function create_mantrap(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MANTRAP, x, y, l) end
local function is_valid_mantrap_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_entrance_room_template(x, y, l) == false
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
	)
end -- # TODO: Implement method for valid mantrap spawn
local global_spawn_procedural_mantrap = define_procedural_spawn("hd_procedural_mantrap", create_mantrap, is_valid_mantrap_spawn)
local global_spawn_procedural_hcastle_mantrap = define_procedural_spawn("hd_procedural_hcastle_mantrap", create_mantrap, is_valid_mantrap_spawn)
local global_spawn_procedural_worm_jungle_mantrap = define_procedural_spawn("hd_procedural_worm_jungle_mantrap", create_mantrap, is_valid_mantrap_spawn)

local function create_tikiman(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_TIKIMAN, x, y, l) end
local function is_valid_tikiman_spawn(x, y, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid tikiman spawn
local global_spawn_procedural_tikiman = define_procedural_spawn("hd_procedural_tikiman", create_tikiman, is_valid_tikiman_spawn)
local global_spawn_procedural_worm_jungle_tikiman = define_procedural_spawn("hd_procedural_worm_jungle_tikiman", create_tikiman, is_valid_tikiman_spawn)

local function create_snail(x, y, l) hdtypelib.create_hd_type(hdtypelib.HD_ENT.SNAIL, x, y, l, false, 0, 0) end
local function is_valid_snail_spawn(x, y, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid snail spawn
local global_spawn_procedural_snail = define_procedural_spawn("hd_procedural_snail", create_snail, is_valid_snail_spawn)
local global_spawn_procedural_hcastle_snail = define_procedural_spawn("hd_procedural_hcastle_snail", create_snail, is_valid_snail_spawn)
local global_spawn_procedural_worm_jungle_snail = define_procedural_spawn("hd_procedural_worm_jungle_snail", create_snail, is_valid_snail_spawn)

local function create_firefrog(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_FIREFROG, x, y, l) end
local function is_valid_firefrog_spawn(x, y, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid firefrog spawn
local global_spawn_procedural_firefrog = define_procedural_spawn("hd_procedural_firefrog", create_firefrog, is_valid_firefrog_spawn)
local global_spawn_procedural_hcastle_firefrog = define_procedural_spawn("hd_procedural_hcastle_firefrog", create_firefrog, is_valid_firefrog_spawn)
local global_spawn_procedural_worm_jungle_firefrog = define_procedural_spawn("hd_procedural_worm_jungle_firefrog", create_firefrog, is_valid_firefrog_spawn)

local function create_frog(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_FROG, x, y, l) end
local function is_valid_frog_spawn(x, y, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid frog spawn
local global_spawn_procedural_frog = define_procedural_spawn("hd_procedural_frog", create_frog, is_valid_frog_spawn)
local global_spawn_procedural_hcastle_frog = define_procedural_spawn("hd_procedural_hcastle_frog", create_frog, is_valid_frog_spawn)
local global_spawn_procedural_worm_jungle_frog = define_procedural_spawn("hd_procedural_worm_jungle_frog", create_frog, is_valid_frog_spawn)

local function create_yeti(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l) end
local function is_valid_yeti_spawn(x, y, l) return false end -- # TODO: Implement method for valid yeti spawn
local global_spawn_procedural_yeti = define_procedural_spawn("hd_procedural_yeti", create_yeti, is_valid_yeti_spawn)
local global_spawn_procedural_worm_icecaves_yeti = define_procedural_spawn("hd_procedural_worm_icecaves_yeti", create_yeti, is_valid_yeti_spawn)

local function create_hawkman(x, y, l) end
local function is_valid_hawkman_spawn(x, y, l) return false end -- # TODO: Implement method for valid hawkman spawn
local global_spawn_procedural_hawkman = define_procedural_spawn("hd_procedural_hawkman", create_hawkman, is_valid_hawkman_spawn)

local function is_valid_crocman_spawn(x, y, l) return false end -- # TODO: Implement method for valid crocman spawn
local global_spawn_procedural_crocman = define_procedural_spawn("hd_procedural_crocman", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CROCMAN, x, y, l) end, is_valid_crocman_spawn)

local function create_scorpionfly(x, y, l) end
local function is_valid_scorpionfly_spawn(x, y, l) return false end -- # TODO: Implement method for valid scorpionfly spawn
local global_spawn_procedural_scorpionfly = define_procedural_spawn("hd_procedural_scorpionfly", create_scorpionfly, is_valid_scorpionfly_spawn)

local function create_critter_rat(x, y, l) end
local function is_valid_critter_rat_spawn(x, y, l)
	return (
		run_spiderlair_ground_enemy_chance()
		and detect_floor_at(x, y, l) == false
		and detect_floor_below(x, y, l) == true
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid critter_rat spawn
local global_spawn_procedural_critter_rat = define_procedural_spawn("hd_procedural_critter_rat", create_critter_rat, is_valid_critter_rat_spawn)

local function create_critter_frog(x, y, l) end
local function is_valid_critter_frog_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_frog spawn
local global_spawn_procedural_critter_frog = define_procedural_spawn("hd_procedural_critter_frog", create_critter_frog, is_valid_critter_frog_spawn)

local function create_critter_maggot(x, y, l) end
local function is_valid_critter_maggot_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_maggot spawn
local global_spawn_procedural_worm_jungle_critter_maggot = define_procedural_spawn("hd_procedural_worm_jungle_critter_maggot", create_critter_maggot, is_valid_critter_maggot_spawn)

local function is_valid_critter_penguin_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_penguin spawn
local global_spawn_procedural_critter_penguin = define_procedural_spawn("hd_procedural_critter_penguin", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERPENGUIN, x, y, l) end, is_valid_critter_penguin_spawn)

local function is_valid_critter_locust_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_locust spawn
local global_spawn_procedural_critter_locust = define_procedural_spawn("hd_procedural_critter_locust", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERLOCUST, x, y, l) end, is_valid_critter_locust_spawn)

local function create_jiangshi(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_JIANGSHI, x, y, l) end
local function is_valid_jiangshi_spawn(x, y, l) return false end -- # TODO: Implement method for valid jiangshi spawn
local global_spawn_procedural_jiangshi = define_procedural_spawn("hd_procedural_jiangshi", create_jiangshi, is_valid_jiangshi_spawn)
local global_spawn_procedural_restless_jiangshi = define_procedural_spawn("hd_procedural_restless_jiangshi", create_jiangshi, is_valid_jiangshi_spawn)
local global_spawn_procedural_hcastle_jiangshi = define_procedural_spawn("hd_procedural_hcastle_jiangshi", create_jiangshi, is_valid_jiangshi_spawn)
local global_spawn_procedural_yama_jiangshi = define_procedural_spawn("hd_procedural_yama_jiangshi", create_jiangshi, is_valid_jiangshi_spawn)

local function create_devil(x, y, l) end
local function is_valid_devil_spawn(x, y, l) return false end -- # TODO: Implement method for valid devil spawn
local global_spawn_procedural_devil = define_procedural_spawn("hd_procedural_devil", create_devil, is_valid_devil_spawn)
local global_spawn_procedural_yama_devil = define_procedural_spawn("hd_procedural_yama_devil", create_devil, is_valid_devil_spawn)

local function create_greenknight(x, y, l) end
local function is_valid_greenknight_spawn(x, y, l) return false end -- # TODO: Implement method for valid greenknight spawn
local global_spawn_procedural_hcastle_greenknight = define_procedural_spawn("hd_procedural_hcastle_greenknight", create_greenknight, is_valid_greenknight_spawn)

local function create_alientank(x, y, l) end
local function is_valid_alientank_spawn(x, y, l) return false end -- # TODO: Implement method for valid alientank spawn
local global_spawn_procedural_alientank = define_procedural_spawn("hd_procedural_alientank", create_alientank, is_valid_alientank_spawn)


local function is_valid_critter_fish_spawn(x, y, l) return false end -- # TODO: Implement method for valid critter_fish spawn
local global_spawn_procedural_critter_fish = define_procedural_spawn("hd_procedural_critter_fish", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERFISH, x, y, l) end, is_valid_critter_fish_spawn)

local function create_piranha(x, y, l) end
local function is_valid_piranha_spawn(x, y, l) return false end -- # TODO: Implement method for valid piranha spawn
local global_spawn_procedural_piranha = define_procedural_spawn("hd_procedural_piranha", create_piranha, is_valid_piranha_spawn)
local global_spawn_procedural_hcastle_piranha = define_procedural_spawn("hd_procedural_hcastle_piranha", create_piranha, is_valid_piranha_spawn)


local function is_valid_monkey_spawn(x, y, l) return false end -- # TODO: Implement method for valid monkey spawn
local global_spawn_procedural_monkey = define_procedural_spawn("hd_procedural_monkey", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MONKEY, x, y, l) end, is_valid_monkey_spawn)


local function create_hangspider(x, y, l)
	local uid = spawn_grid_entity(ENT_TYPE.MONS_HANGSPIDER, x, y, l)
	spawn_entity(ENT_TYPE.ITEM_WEB, x, y, l, 0, 0)
	spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, uid, 0, 0)
end
local function is_valid_hangspider_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	local floor_three_below = get_grid_entity_at(x, y-3, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_above(x, y, l) == true
		and detect_floor_below(x, y, l) == false
		and floor_two_below == -1
		and floor_three_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid hangspider spawn
local global_spawn_procedural_hangspider = define_procedural_spawn("hd_procedural_hangspider", create_hangspider, is_valid_hangspider_spawn)
local global_spawn_procedural_spiderlair_hangspider = define_procedural_spawn("hd_procedural_spiderlair_hangspider", create_hangspider, is_valid_hangspider_spawn)
local global_spawn_procedural_restless_hangspider = define_procedural_spawn("hd_procedural_restless_hangspider", create_hangspider, is_valid_hangspider_spawn)
local global_spawn_procedural_hcastle_hangspider = define_procedural_spawn("hd_procedural_hcastle_hangspider", create_hangspider, is_valid_hangspider_spawn)

local function create_bat(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_BAT, x, y, l) end
local function is_valid_bat_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_above(x, y, l) == true
		and detect_floor_below(x, y, l) == false
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid bat spawn
local global_spawn_procedural_bat = define_procedural_spawn("hd_procedural_bat", create_bat, is_valid_bat_spawn)
local global_spawn_procedural_hcastle_bat = define_procedural_spawn("hd_procedural_hcastle_bat", create_bat, is_valid_bat_spawn)
local global_spawn_procedural_worm_jungle_bat = define_procedural_spawn("hd_procedural_worm_jungle_bat", create_bat, is_valid_bat_spawn)
local global_spawn_procedural_yama_bat = define_procedural_spawn("hd_procedural_yama_bat", create_bat, is_valid_bat_spawn)

local function create_spider(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SPIDER, x, y, l) end
local function is_valid_spider_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_above(x, y, l) == true
		and detect_floor_below(x, y, l) == false
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid spider spawn
local global_spawn_procedural_spider = define_procedural_spawn("hd_procedural_spider", create_spider, is_valid_spider_spawn)
local global_spawn_procedural_spiderlair_spider = define_procedural_spawn("hd_procedural_spiderlair_spider", create_spider, is_valid_spider_spawn)

local function create_vampire(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_VAMPIRE, x, y, l) end
local function is_valid_vampire_spawn(x, y, l) return false end -- # TODO: Implement method for valid vampire spawn
local global_spawn_procedural_vampire = define_procedural_spawn("hd_procedural_vampire", create_vampire, is_valid_vampire_spawn)
local global_spawn_procedural_restless_vampire = define_procedural_spawn("hd_procedural_restless_vampire", create_vampire, is_valid_vampire_spawn)
local global_spawn_procedural_hcastle_vampire = define_procedural_spawn("hd_procedural_hcastle_vampire", create_vampire, is_valid_vampire_spawn)
local global_spawn_procedural_yama_vampire = define_procedural_spawn("hd_procedural_yama_vampire", create_vampire, is_valid_vampire_spawn)

local function is_valid_imp_spawn(x, y, l) return false end -- # TODO: Implement method for valid imp spawn
local global_spawn_procedural_imp = define_procedural_spawn("hd_procedural_imp", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_IMP, x, y, l) end, is_valid_imp_spawn)
local global_spawn_procedural_yama_imp = define_procedural_spawn("hd_procedural_yama_imp", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_IMP, x, y, l) end, is_valid_imp_spawn)

local function is_valid_scarab_spawn(x, y, l) return false end -- # TODO: Implement method for valid scarab spawn
local global_spawn_procedural_scarab = define_procedural_spawn("hd_procedural_scarab", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCARAB, x, y, l) end, is_valid_scarab_spawn)

local function create_mshiplight(x, y, l) end
local function is_valid_mshiplight_spawn(x, y, l) return false end -- # TODO: Implement method for valid mshiplight spawn
local global_spawn_procedural_mshiplight = define_procedural_spawn("hd_procedural_mshiplight", create_mshiplight, is_valid_mshiplight_spawn)

local function is_valid_lantern_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_above(x, y, l) == true
		and detect_floor_below(x, y, l) == false
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid lantern spawn
local global_spawn_procedural_dark_lantern = define_procedural_spawn("hd_procedural_dark_lantern", function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_LAMP, x, y, l) end, is_valid_lantern_spawn)

local function create_turret(x, y, l) end
local function is_valid_turret_spawn(x, y, l) return false end -- # TODO: Implement method for valid turret spawn
local global_spawn_procedural_ufo_turret = define_procedural_spawn("hd_procedural_ufo_turret", create_turret, is_valid_turret_spawn)
local global_spawn_procedural_mshipentrance_turret = define_procedural_spawn("hd_procedural_mshipentrance_turret", create_turret, is_valid_turret_spawn)

local function create_webnest(x, y, l)
	local block_uid = get_grid_entity_at(x, y+1, l)
	if block_uid ~= -1 then
		local lantern_uid = spawn_entity_over(ENT_TYPE.ITEM_REDLANTERN, block_uid, 0, -1)
		-- local lantern_flames = get_entities_by_type(ENT_TYPE.ITEM_REDLANTERNFLAME)
		-- if #lantern_flames ~= 0 then
		-- 	-- local lantern_flame = get_entity(lantern_flames[1])
		-- 	-- lantern_flame.flags = set_flag(lantern_flame, ENT_FLAG.DEAD)

		-- 	-- move_entity(lantern_flames[1].uid, 1000, 0, 0, 0)
		-- end
		local entity = get_entity(lantern_uid)
		local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
		texture_def.texture_path = "res/items_spiderlair_spidernest.png"
		entity:set_texture(define_texture(texture_def))
	end
end -- spawn_entity_over(ENT_TYPE.ITEM_REDLANTERN) the floor above (I think?)
local function is_valid_webnest_spawn(x, y, l)
	local floor_two_below = get_grid_entity_at(x, y-2, l)
	return (
		detect_floor_at(x, y, l) == false
		and detect_floor_above(x, y, l) == true
		and detect_floor_below(x, y, l) == false
		and floor_two_below == -1
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid webnest spawn
local global_spawn_procedural_spiderlair_webnest = define_procedural_spawn("hd_procedural_spiderlair_webnest", create_webnest, is_valid_webnest_spawn)


-- powderkeg / pushblock
local global_spawn_procedural_powderkeg = define_procedural_spawn("hd_procedural_powderkeg", function(x, y, l) end, function(x, y, l) return false end)--throwaway method so we can define the chance in .lvl file and use `global_spawn_procedural_pushblock` to spawn it
local function create_pushblock_powderkeg(x, y, l)
	-- local entity_here = get_grid_entity_at(x, y, l)
	-- if entity_here ~= -1 then
    --     -- get_entity(entity_here):destroy()
	-- 	kill_entity(entity_here)
	-- end
	remove_floor_and_embedded_at(x, y, l)

	local current_powderkeg_chance = get_procedural_spawn_chance(global_spawn_procedural_powderkeg)
	if (
		current_powderkeg_chance ~= 0
		and math.random(current_powderkeg_chance) == 1
	) then
		spawn_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l, 0, 0)
	else
		spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0)
	end
end
local function is_valid_pushblock_spawn(x, y, l)
	-- Replaces floor with spawn where it has floor underneath
    local above = get_grid_entity_at(x, y+1, l)
	if above ~= -1 then
		above = get_entity(above)
		if above.type.id == ENT_TYPE.FLOOR_ALTAR then
			return false
		end
	end
    return (
		detect_solid_nonshop_nontree(x, y, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
	)
end
local global_spawn_procedural_pushblock = define_procedural_spawn("hd_procedural_pushblock", create_pushblock_powderkeg, is_valid_pushblock_spawn)

local function create_spikeball(x, y, l) end
local function is_valid_spikeball_spawn(x, y, l) return false end -- # TODO: Implement method for valid spikeball spawn
local global_spawn_procedural_spikeball = define_procedural_spawn("hd_procedural_spikeball", create_spikeball, is_valid_spikeball_spawn)
local global_spawn_procedural_yama_spikeball = define_procedural_spawn("hd_procedural_yama_spikeball", create_spikeball, is_valid_spikeball_spawn)

local function create_arrowtrap(x, y, l)
	-- local entity_here = get_grid_entity_at(x, y, l)
	-- if entity_here ~= -1 then
    --     -- get_entity(entity_here):destroy()
	-- 	kill_entity(entity_here)
	-- end
	remove_floor_and_embedded_at(x, y, l)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_ARROW_TRAP, x, y, l)
    local left = get_grid_entity_at(x-1, y, l)
    local right = get_grid_entity_at(x+1, y, l)
	local flip = false
	if left == -1 and right == -1 then
		--math.randomseed(read_prng()[5])
		if prng:random() < 0.5 then
			flip = true
		end
	elseif left == -1 then
		flip = true
	end
	if flip == true then
		flip_entity(uid)
	end
	if test_flag(state.level_flags, 18) == true then
		spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, uid, 0, 0.35)
	end
	
	if state.theme == THEME.CITY_OF_GOLD then
		local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
		texture_def.texture_path = "res/floormisc_gold_trap.png"
		get_entity(uid):set_texture(define_texture(texture_def))
	end

end
local function is_valid_arrowtrap_spawn(x, y, l)
	local rx, ry = get_room_index(x, y)
    if y == state.level_gen.spawn_y and (rx >= state.level_gen.spawn_room_x-1 and rx <= state.level_gen.spawn_room_x+1) then return false end
    local floor = get_grid_entity_at(x, y, l)
    local left = get_grid_entity_at(x-1, y, l)
    local left2 = get_grid_entity_at(x-2, y, l)
    local right = get_grid_entity_at(x+1, y, l)
    local right2 = get_grid_entity_at(x+2, y, l)
    if floor ~= -1 and (
		(left == -1 and left2 == -1 and right ~= -1)
		or (left ~= -1 and right == -1 and right2 == -1)
	) then
        floor = get_entity(floor)
        return commonlib.has(valid_floors, floor.type.id)
    end
    return false
end -- # TODO: Implement method for valid arrowtrap spawn
local global_spawn_procedural_arrowtrap = define_procedural_spawn("hd_procedural_arrowtrap", create_arrowtrap, is_valid_arrowtrap_spawn)

local function create_tikitrap(x, y, l) end -- spawn_entity_over the floor above
local function is_valid_tikitrap_spawn(x, y, l)
	
	--[[
		-- # TODO: Implement method for valid tikitrap spawn
		-- Does it have a block underneith?
		-- Does it have at least 3 spaces across unoccupied above it?
		-- Does it have at least one tile unoccupied next to it? (not counting tiki trap tiles)
		-- Is the top tiki part placed over an unoccupied space?
	]]
	return false
end
local global_spawn_procedural_tikitrap = define_procedural_spawn("hd_procedural_tikitrap", create_tikitrap, is_valid_tikitrap_spawn)

local function is_valid_crushtrap_spawn(x, y, l)
	--[[
		-- # TODO: Implement method for valid crushtrap spawn
		-- Replace air
		-- Needs at least one block open on one side of it
		-- Needs at least one block occupide on one side of it
	]]
	return false
end
local global_spawn_procedural_crushtrap = define_procedural_spawn("hd_procedural_crushtrap", function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, x, y, l) end, is_valid_crushtrap_spawn)

local function create_tombstone(x, y, l)
	local block_uid = spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP, x, y, l, 0, 0)
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
	texture_def.texture_path = "res/floormisc_tombstone_rip.png"
	get_entity(block_uid):set_texture(define_texture(texture_def))
	tombstone_blocks[#tombstone_blocks+1] = block_uid
end
-- ash tombstone shotgun -- log all tombstones in an array upon creation, then set a callback to select one of them for ASH skin and shotgun.
local function is_valid_tombstone_spawn(x, y, l)
	-- need subchunkid of what room we're in
	-- # TOFIX: Prevent tombstones from spawning in RESTLESS_TOMB.
	--[[ the following code returns as nil, though it should be showing up at this point...
	local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
	local _subchunk_id = global_levelassembly.modification.levelrooms[roomy][roomx]
	--]]
	
    return (
		-- _subchunk_id ~= genlib.HD_SUBCHUNKID.RESTLESS_TOMB and
		detect_empty_nodoor(x, y, l)
		and detect_empty_nodoor(x, y+1, l)
		and detect_solid_nonshop_nontree(x, y - 1, l)
	)
end
local global_spawn_procedural_restless_tombstone = define_procedural_spawn("hd_procedural_restless_tombstone", create_tombstone, is_valid_tombstone_spawn)


local function create_giantfrog(x, y, l) end
local function is_valid_giantfrog_spawn(x, y, l) return false end -- # TODO: Implement method for valid giantfrog spawn
local global_spawn_procedural_giantfrog = define_procedural_spawn("hd_procedural_giantfrog", create_giantfrog, is_valid_giantfrog_spawn)

local function create_mammoth(x, y, l) end
local function is_valid_mammoth_spawn(x, y, l) return false end -- # TODO: Implement method for valid mammoth spawn
local global_spawn_procedural_mammoth = define_procedural_spawn("hd_procedural_mammoth", create_mammoth, is_valid_mammoth_spawn)


local function is_valid_giantspider_spawn(x, y, l)
	local floor_above_right = get_grid_entity_at(x+1, y+1, l)
	local cx, cy = x+.5, y-.5
	local w, h = 2, 2
	local entity_uids = get_entities_overlapping_hitbox(
		0, MASK.FLOOR,
		AABB:new(
			cx-(w/2),
			cy+(h/2),
			cx+(w/2),
			cy-(h/2)
		),
		l
	)
	return (
		#entity_uids == 0
		and detect_floor_above(x, y, l) == true
		and floor_above_right ~= -1
		and GIANTSPIDER_SPAWNED == false
		and detect_entrance_room_template(x, y, l) == false
	)
end -- # TODO: Implement method for valid giantspider spawn
local global_spawn_procedural_giantspider = define_procedural_spawn("hd_procedural_giantspider", function(x, y, l) spawn_entity(ENT_TYPE.MONS_GIANTSPIDER, x+.5, y, l, 0, 0) GIANTSPIDER_SPAWNED = true end, is_valid_giantspider_spawn)


local function is_valid_bee_spawn(x, y, l) return false end -- # TODO: Implement method for valid bee spawn
local global_spawn_procedural_hive_bee = define_procedural_spawn("hd_procedural_hive_bee", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_BEE, x, y, l) end, is_valid_bee_spawn)


local function create_ufo(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_UFO, x, y, l) end
local function is_valid_ufo_spawn(x, y, l) return false end -- # TODO: Implement method for valid ufo spawn
local global_spawn_procedural_ufo = define_procedural_spawn("hd_procedural_ufo", create_ufo, is_valid_ufo_spawn)
local global_spawn_procedural_worm_icecaves_ufo = define_procedural_spawn("hd_procedural_worm_icecaves_ufo", create_ufo, is_valid_ufo_spawn)


local function create_bacterium(x, y, l) end
local function is_valid_bacterium_spawn(x, y, l) return false end -- # TODO: Implement method for valid bacterium spawn
local global_spawn_procedural_worm_jungle_bacterium = define_procedural_spawn("hd_procedural_worm_jungle_bacterium", create_bacterium, is_valid_bacterium_spawn)
local global_spawn_procedural_worm_icecaves_bacterium = define_procedural_spawn("hd_procedural_worm_icecaves_bacterium", create_bacterium, is_valid_bacterium_spawn)


local function create_eggsac(x, y, l) end
local function is_valid_eggsac_spawn(x, y, l) return false end -- # TODO: Implement method for valid eggsac spawn
local global_spawn_procedural_worm_jungle_eggsac = define_procedural_spawn("hd_procedural_worm_jungle_eggsac", create_eggsac, is_valid_eggsac_spawn)
local global_spawn_procedural_worm_icecaves_eggsac = define_procedural_spawn("hd_procedural_worm_icecaves_eggsac", create_eggsac, is_valid_eggsac_spawn)


--[[ Template for defining procedural spawns:

	local function create_*(x, y, l) end
	local function is_valid_*_spawn(x, y, l) return false end -- # TODO: Implement method for valid * spawn
	local global_spawn_procedural_* = define_procedural_spawn("hd_procedural_*", create_*, is_valid_*_spawn)
--]]


--[[
	END PROCEDURAL SPAWN DEF
--]]


local s2_room_template_blackmarket_ankh = define_room_template("hdmod_blackmarket_ankh", ROOM_TEMPLATE_TYPE.SHOP)
local s2_room_template_blackmarket_shop = define_room_template("hdmod_blackmarket_shop", ROOM_TEMPLATE_TYPE.SHOP)


set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		init_posttile_onstart()
		if options.hd_debug_scripted_levelgen_disable == false then
			init_posttile_door()
			levelcreation_init()
			
			assign_s2_level_height()
		end
	end
end, ON.PRE_LEVEL_GENERATION)

set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		-- message(F'ON.POST_ROOM_GENERATION - ON.LEVEL: {state.time_level}')

		if options.hd_debug_scripted_levelgen_disable == false then
			
			detect_coop_coffin(room_gen_ctx)

			if state.theme == THEME.DWELLING and state.level == 4 then
				for x = 0, state.width - 1 do
					for y = 0, state.height - 1 do
						room_gen_ctx:unmark_as_set_room(x, y, LAYER.FRONT)
					end
				end
			end

			levelcreation()

			set_blackmarket_shoprooms(room_gen_ctx)

			onlevel_generation_execution_phase_one()
			onlevel_generation_execution_phase_two()

		end


		level_w, level_h = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		for y = 0, level_h - 1, 1 do
		    for x = 0, level_w - 1, 1 do
				local template_to_set = ROOM_TEMPLATE.SIDE
				local room_template_here = get_room_template(x, y, 0)

				if options.hd_debug_scripted_levelgen_disable == false then

					_template_hd = global_levelassembly.modification.levelrooms[y+1][x+1]

					if (
						state.theme == THEME.OLMEC
					) then
						if (x == 0 and y == 3) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (x == 3 and y == 3) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							-- template_to_set = ROOM_TEMPLATE.PATH_NORMAL
							template_to_set = room_template_here
						end
					elseif (
						feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
					) then
						if (_template_hd == genlib.HD_SUBCHUNKID.YAMA_ENTRANCE) then
							template_to_set = ROOM_TEMPLATE.ENTRANCE
						elseif (_template_hd == genlib.HD_SUBCHUNKID.YAMA_EXIT) then
							template_to_set = ROOM_TEMPLATE.EXIT
						else
							template_to_set = ROOM_TEMPLATE.SIDE
							-- template_to_set = room_template_here
						end
					else
						--[[
							Sync scripted level generation rooms with S2 generation rooms
						--]]
						
						--LevelGenSystem variables
						if (
							_template_hd == genlib.HD_SUBCHUNKID.ENTRANCE or
							_template_hd == genlib.HD_SUBCHUNKID.ENTRANCE_DROP
						) then
							state.level_gen.spawn_room_x, state.level_gen.spawn_room_y = x, y
						end
	
						-- normal paths
						if (
							(_template_hd >= 1) and (_template_hd <= 8)
						) then
							template_to_set = _template_hd
	
						-- tikivillage paths
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH then
							template_to_set = ROOM_TEMPLATE.PATH_NORMAL
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_LEFT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
						elseif _template_hd == genlib.HD_SUBCHUNKID.TIKIVILLAGE_PATH_DROP_NOTOP_RIGHT then
							template_to_set = ROOM_TEMPLATE.PATH_DROP_NOTOP
	
						-- flooded paths
						elseif _template_hd == genlib.HD_SUBCHUNKID.RUSHING_WATER_SIDE then
							template_to_set = ROOM_TEMPLATE.SIDE
						elseif _template_hd == genlib.HD_SUBCHUNKID.RUSHING_WATER_PATH_NOTOP then
							template_to_set = ROOM_TEMPLATE.PATH_NOTOP
						elseif _template_hd == genlib.HD_SUBCHUNKID.RUSHING_WATER_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
						
						-- hauntedcastle paths
						elseif _template_hd == genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT then
							template_to_set = ROOM_TEMPLATE.EXIT
						elseif _template_hd == genlib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP then
							template_to_set = ROOM_TEMPLATE.EXIT_NOTOP
	
						-- shop
						elseif (_template_hd == genlib.HD_SUBCHUNKID.SHOP_REGULAR) then
							if state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
								template_to_set = ROOM_TEMPLATE.DICESHOP
							else
								template_to_set = ROOM_TEMPLATE.SHOP
							end
						-- shop left
						elseif (_template_hd == genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT) then
							if state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
								template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
							else
								template_to_set = ROOM_TEMPLATE.SHOP_LEFT
							end
						-- prize wheel
						elseif (_template_hd == genlib.HD_SUBCHUNKID.SHOP_PRIZE) then
							template_to_set = ROOM_TEMPLATE.DICESHOP
						-- prize wheel left
						elseif (_template_hd == genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT) then
							template_to_set = ROOM_TEMPLATE.DICESHOP_LEFT
							
						-- vault
						elseif (_template_hd == genlib.HD_SUBCHUNKID.VAULT) then
							template_to_set = ROOM_TEMPLATE.VAULT
						
						-- altar
						elseif (_template_hd == genlib.HD_SUBCHUNKID.ALTAR) then
							template_to_set = ROOM_TEMPLATE.ALTAR
						
						-- idol
						elseif (_template_hd == genlib.HD_SUBCHUNKID.IDOL) then
							template_to_set = ROOM_TEMPLATE.IDOL
							
						-- black market
						elseif (_template_hd == genlib.HD_SUBCHUNKID.BLACKMARKET_SHOP) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT--s2_room_template_blackmarket_shop
						elseif (_template_hd == genlib.HD_SUBCHUNKID.BLACKMARKET_ANKH) then
							template_to_set = ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT--s2_room_template_blackmarket_ankh

						-- coop coffin
						
						elseif (_template_hd == genlib.HD_SUBCHUNKID.COFFIN_COOP) then
							template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER
						elseif (
							_template_hd == genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
							or _template_hd == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP
							or _template_hd == genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
						) then
							template_to_set = ROOM_TEMPLATE.COFFIN_PLAYER_VERTICAL

						end
					end
				else
					-- Set everything that's not the entrance to a side room
					if (
						(room_template_here == ROOM_TEMPLATE.ENTRANCE) or
						(room_template_here == ROOM_TEMPLATE.ENTRANCE_DROP)
					) then
						template_to_set = room_template_here
					end
				end
				room_gen_ctx:set_room_template(x, y, 0, template_to_set)
	        end
	    end
		
		if (
			feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM)
			or feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER)
			or state.theme == THEME.NEO_BABYLON
		) then
			for x = 0, level_w - 1, 1 do
				room_gen_ctx:set_room_template(x, level_h, 0, ROOM_TEMPLATE.SIDE)
			end
		end

		if options.hd_debug_scripted_levelgen_disable == false then
			if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
				if feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT) then -- set udjat global_spawn_extra
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_locked_chest_and_key, 2, 0)
				else -- unset
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_locked_chest_and_key, 0, 0)
				end
				
				if feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_giantspider, 0)
				else
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_hangspider, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_spider, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_webnest, 0)
				end

				if (
					test_flag(state.level_flags, 18) == false
					or state.theme ~= THEME.DWELLING
				) then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_dark_lantern, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.WORMTONGUE) == true then
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_wormtongue, 1, 0)
				else -- unset
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_wormtongue, 0, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET_ENTRANCE) == true then
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_blackmarket, 1, 0)
				else -- unset
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_blackmarket, 0, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_giantfrog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_mantrap, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_caveman, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_tikiman, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_snail, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_firefrog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_frog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_monkey, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_critter_frog, 0)
				else
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_restless_tombstone, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_restless_hangspider, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_restless_vampire, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_restless_jiangshi, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.HIVE) then
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_hive_queenbee, 1, 0)
				else
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_hive_queenbee, 0, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hive_bee, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_piranha, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_giantfrog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_mantrap, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_caveman, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_tikiman, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_snail, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_firefrog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_frog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_critter_frog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_critter_fish, 0)
				else
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_piranha, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_bat, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_hangspider, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_vampire, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_jiangshi, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_mantrap, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_greenknight, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_snail, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_firefrog, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hcastle_frog, 0)
				end

				if state.theme == THEME.EGGPLANT_WORLD then
					if state.world ~= 2 then
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_bacterium, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_eggsac, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_mantrap, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_caveman, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_tikiman, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_snail, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_firefrog, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_frog, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_bat, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_jungle_critter_maggot, 0)
					elseif state.world ~= 3 then
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_icecaves_bacterium, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_icecaves_eggsac, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_icecaves_yeti, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_worm_icecaves_ufo, 0)
					end
				end
				
				-- # TODO: Yeti Kingdom procedural spawn settings. Investigate HD's code to verify what needs to be set/restricted here.
				-- if feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM) then
				-- 	room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_, 0)
				-- else
				-- end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.UFO) == false then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_ufo_turret, 0)
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE) == false then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_mshipentrance_turret, 0)
				end
				
				if feelingslib.feeling_check(feelingslib.FEELING_ID.ANUBIS) then
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_anubis, 1, 0)
				else
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_anubis, 0, 0)
				end

				if state.theme == THEME.VOLCANA then
					if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true then
						room_gen_ctx:set_num_extra_spawns(global_spawn_extra_succubus, 0, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_bat, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_imp, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_jiangshi, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_vampire, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_devil, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_tikitrap, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spikeball, 0)
					else
						room_gen_ctx:set_num_extra_spawns(global_spawn_extra_succubus, 1, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_bat, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_imp, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_jiangshi, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_vampire, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_devil, 0)
						-- room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_tikitrap, 0)
						room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_spikeball, 0)
					end
				else
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_succubus, 0, 0)
				end

				--[[ procedural/extra spawn assign template
				if feelingslib.feeling_check(feelingslib.FEELING_ID.) then
					room_gen_ctx:set_num_extra_spawns(global_spawn_extra_, 0, 0)
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_, 0)
				else
				end
				--]]
			else -- remove every procedural/extra spawn that happends in world 1 for testing/tutorial
				if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
					room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_pushblock, 0)
				end
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_arrowtrap, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_giantspider, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_hangspider, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_bat, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spider, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_caveman, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_scorpion, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_cobra, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_snake, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_critter_rat, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_hangspider, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_spider, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_spiderlair_webnest, 0)
				room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_dark_lantern, 0)
			end
		end
	end
end, ON.POST_ROOM_GENERATION)

set_callback(function()
	if state.screen == SCREEN.LEVEL then
		onlevel_generation_execution_phase_three()
		--[[
			Procedural Spawn post_level_generation stuff
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
					local block_uid = tombstone_blocks[math.random(#tombstone_blocks)]
					local x, y, l = get_position(block_uid)
					
					local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORMISC_0)
					texture_def.texture_path = "res/floormisc_tombstone_ash.png"
					get_entity(block_uid):set_texture(define_texture(texture_def))

					embed_item(ENT_TYPE.ITEM_SHOTGUN, get_grid_entity_at(x, y-1, l), 48)
				end
				if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
					local shopkeeper_uids = get_entities_by(ENT_TYPE.MONS_SHOPKEEPER, 0, LAYER.FRONT)
					for _, shopkeeper_uid in pairs(shopkeeper_uids) do
						get_entity(shopkeeper_uid).has_key = false
					end
				end
			end
		end
		
		--[[
			Level Background stuff
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				local backwalls = get_entities_by(ENT_TYPE.BG_LEVEL_BACKWALL, 0, LAYER.FRONT)
				-- message("#backwalls: " .. tostring(#backwalls))
				
				--[[
					Room-Specific
				--]]
				if state.theme == THEME.NEO_BABYLON then
					-- ice caves bg
					local backwall = get_entity(backwalls[1])
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_ICE_0)

					-- mothership bg
					local w, h = 40, 32
					local x, y, l = 22.5, 106.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end
				
				if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
					local w, h = 30, 28
					local x, y, l = 17.5, 104.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_STONE_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/4, backwall.height/4 -- divide by 4 for normal-sized brick
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end

				if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) then
					local w, h = 6, 8
					local x, y, l = 22.5, 94.5, LAYER.FRONT
					local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
					backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
					backwall.animation_frame = 0
					backwall:set_draw_depth(49)
					backwall.width, backwall.height = w, h
					backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
					backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
				end

				--[[
					Room-Specific
				--]]
				level_w, level_h = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
				for y = 1, level_h, 1 do
					for x = 1, level_w, 1 do
						_template_hd = global_levelassembly.modification.levelrooms[y][x]
						local corner_x, corner_y = locatelib.locate_game_corner_position_from_levelrooms_position(x, y)
						if _template_hd == genlib.HD_SUBCHUNKID.VLAD_BOTTOM then
							
							-- main tower
							local w, h = 10, (8*3)+3
							local x, y, l = corner_x+4.5, corner_y+6, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

							-- vlad alcove
							local w, h = 2, 2
							local x, y, l = corner_x+4.5, corner_y+20.5, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_VLAD_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2

							-- mother statue
							spawn_entity(ENT_TYPE.BG_CROWN_STATUE, corner_x+4.5, corner_y+(8*3)-7, l, 0, 0)

						elseif _template_hd == genlib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP then
							local w, h = 10, 8
							local x, y, l = corner_x+4.5, corner_y-3.5, LAYER.FRONT
							local backwall = get_entity(spawn_entity(ENT_TYPE.BG_LEVEL_BACKWALL, x, y, l, 0, 0))
							backwall:set_texture(TEXTURE.DATA_TEXTURES_BG_MOTHERSHIP_0)
							backwall.animation_frame = 0
							backwall:set_draw_depth(49)
							backwall.width, backwall.height = w, h
							backwall.tile_width, backwall.tile_height = backwall.width/10, backwall.height/10
							backwall.hitboxx, backwall.hitboxy = backwall.width/2, backwall.height/2
						end
					end
				end
			end
		end

		--[[
			Tile Decorations
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				if (
					feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)
					or feelingslib.feeling_check(feelingslib.FEELING_ID.SNOWING)
				) then
					local floors = get_entities_by_type(ENT_TYPE.FLOOR_GENERIC)
					for _, floor_uid in pairs(floors) do
						local floor = get_entity(floor_uid)
						if floor.deco_top ~= -1 then
							local deco_top = get_entity(floor.deco_top)
							if (
								deco_top.animation_frame ~= 101
								and deco_top.animation_frame ~= 102
								and deco_top.animation_frame ~= 103
							) then
								deco_top.animation_frame = deco_top.animation_frame - 24
							end
						end
					end
				end
			end
			--[[
				Lut Settings
			]]
			
			if state.theme == THEME.VOLCANA then
				local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_LUT_ORIGINAL_0)
				texture_def.texture_path = "res/lut_hell.png"
				local vlad_atmos_id = define_texture(texture_def)
				set_lut(vlad_atmos_id, LAYER.FRONT)
			end
		end
	end
end, ON.POST_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.PRE_LEVEL_GENERATION: {state.time_level}')

-- 	-- if state.screen == ON.LEVEL then
-- 	-- 	if options.hd_debug_scripted_levelgen_disable == false then
-- 	-- 		onlevel_generation_execution_phase_one()
-- 	-- 		onlevel_generation_execution_phase_two() -- # TOTEST: ON.POST_LEVEL_GENERATION
-- 	-- 	end
-- 	-- end
-- end, ON.PRE_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.POST_LEVEL_GENERATION: {state.time_level}')


-- ON.CAMP
set_callback(function()
	-- oncamp_movetunnelman()
	-- oncamp_shortcuts()
	
	
	-- signs_back = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_BACK)
	-- signs_front = get_entities_by_type(ENT_TYPE.BG_TUTORIAL_SIGN_FRONT)
	-- x, y, l = 49, 90, LAYER.FRONT -- next to entrance
	
	-- pre_tile ON.START stuff
	worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL

	set_interval(entrance_tutorial, 1)
	if options.hd_debug_testing_door == true then
		set_interval(entrance_testing, 1)
	end

	state.camera.bounds_top = 93.9
	state.camera.bounds_bottom = 82.7
	state.camera.bounds_left = 8.5
	state.camera.bounds_right = 51.5

	state.camera.adjusted_focus_x = 41.55
	state.camera.adjusted_focus_y = 88.3

end, ON.CAMP)

set_callback(function()
	set_camp_camera_bounds_enabled(false)
end, ON.LOGO)

set_callback(function()
	game_manager.screen_title.ana_right_eyeball_torch_reflection.x, game_manager.screen_title.ana_right_eyeball_torch_reflection.y = -0.7, 0.05
	game_manager.screen_title.ana_left_eyeball_torch_reflection.x, game_manager.screen_title.ana_left_eyeball_torch_reflection.y = -0.55, 0.05
end, ON.TITLE)

-- ON.START
set_callback(function()
	onstart_init_options()
	-- Enable S2 udjat eye, S2 black market, and drill spawns to prevent them from spawning.
	changestate_samelevel_applyquestflags(state.world, state.level, state.theme, {17, 18, 19}, {})
	CHARACTER_UNLOCK_SPAWNED_DURING_RUN = false
end, ON.START)

set_callback(function()
	-- pre_tile ON.START stuff
	POSTTILE_STARTBOOL = false
	-- worldlib.HD_WORLDSTATE_STATE = worldlib.HD_WORLDSTATE_STATUS.NORMAL
	-- DOOR_TESTING_UID = nil
	-- DOOR_TUTORIAL_UID = nil
end, ON.RESET)

-- ON.LOADING
set_callback(function()
	onloading_levelrules()
	onloading_applyquestflags()
end, ON.LOADING)

set_callback(function()
	-- global_levelassembly = nil
end, ON.TRANSITION)

function levelcreation_init()
	init_onlevel()
	unlockslib.unlocks_load()
	-- onlevel_levelrules()
	
	if (
		(worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL)
		-- (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TUTORIAL)
		-- or (worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TESTING)
	) then
		feelingslib.onlevel_set_feelings()
	end
	clear_dark_level()
	feelingslib.onlevel_set_feelingToastMessage()
	-- Method to write override_path setrooms into path and levelcode
	--ONLEVEL_PRIORITY: 2 - Misc ON.LEVEL methods applied to the level in its unmodified form
end

function levelcreation()
	--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
	onlevel_generation_modification()
end

function assign_s2_level_height()
	
	local new_width = 4
	local new_height = 4

	if (--levels that already have a constant width and height
		state.theme ~= THEME.OLMEC
		and state.theme ~= THEME.EGGPLANT_WORLD
		and state.theme ~= THEME.CITY_OF_GOLD
		and state.theme ~= THEME.NEO_BABYLON
	) then
		if (
			(--echoes themes
				state.theme == THEME.DWELLING
				or state.theme == THEME.JUNGLE
				or state.theme == THEME.TEMPLE
				or state.theme == THEME.VOLCANA
			)
			and (
				state.height ~= 4
				and state.width ~= 4
			)
		) then
			new_width = 4
			new_height = 4
		end
	
		-- set height for rushing water
		if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
			new_height = 5
		end
		state.width = new_width
		state.height = new_height
	end
end

function detect_coop_coffin(room_gen_ctx)
	for y = 0, state.height - 1 do
		for x = 0, state.width - 1 do
			local room_template_here = get_room_template(x, y, 0)
			if (
				room_template_here == ROOM_TEMPLATE.COFFIN_PLAYER
				or room_template_here == ROOM_TEMPLATE.COFFIN_PLAYER_VERTICAL
			) then
				COOP_COFFIN = true
			end
		end
	end
end

function set_blackmarket_shoprooms(room_gen_ctx)

	if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) then
		local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		local minw, minh, maxw, maxh = 2, 1, levelw-1, levelh-1
		UNLOCK_WI, UNLOCK_HI = 0, 0
		if LEVEL_UNLOCK ~= nil then
			UNLOCK_WI = math.random(minw, maxw)
			UNLOCK_HI = math.random(minh, (UNLOCK_WI ~= maxw and maxh or maxh-1))
		end
		-- message("wi, hi: " .. UNLOCK_WI .. ", " .. UNLOCK_HI)
		for hi = minh, maxh, 1 do
			for wi = minw, maxw, 1 do
				if (hi == maxh and wi == maxw) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.DICE_SHOP)
				elseif (hi == UNLOCK_HI and wi == UNLOCK_WI) then
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, SHOP_TYPE.HIRED_HAND_SHOP)
				else
					room_gen_ctx:set_shop_type(wi-1, hi-1, LAYER.FRONT, math.random(0, 5))
				end
			end
		end
		-- room_gen_ctx:set_shop_type(1, 0, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 0, LAYER.FRONT, math.random(0, 5))

		-- room_gen_ctx:set_shop_type(1, 1, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 1, LAYER.FRONT, math.random(0, 5))

		-- room_gen_ctx:set_shop_type(1, 2, LAYER.FRONT, math.random(0, 5))
		-- room_gen_ctx:set_shop_type(2, 2, LAYER.FRONT, SHOP_TYPE.DICE_SHOP)

		-- room_gen_ctx:set_shop_type(3, 2, LAYER.FRONT, SHOP_TYPE.HEDJET_SHOP)--unneeded
	end

end

set_callback(function()
	-- message(F'ON.LEVEL: {state.time_level}')
	onlevel_generation_execution_phase_four()

-- --ONLEVEL_PRIORITY: 1 - Set level constants (ie, init_onlevel(), levelrules)
	-- Use a timeout since that seems to prevent loading some of the quillback level entities
	set_timeout(onlevel_levelrules, 20)

	-- TEMPORARY: move players and things they have to entrance point
	
	-- if (
	-- 	options.hd_debug_scripted_levelgen_disable == false and
	-- 	state.theme ~= THEME.OLMEC-- detect_level_non_boss()
	-- ) then
	-- 	for i = 1, #players, 1 do
	-- 		move_entity(players[i].uid, global_levelassembly.entrance.x, global_levelassembly.entrance.y, 0, 0)
	-- 	end
	-- 	local entity = get_entity(FRAG_PREVENTION_UID)
	-- 	if entity ~= nil then
	-- 		entity.flags = set_flag(entity.flags, ENT_FLAG.SOLID)
	-- 	end
	-- end
	
--ONLEVEL_PRIORITY: 4 - Set up dangers (LEVEL_DANGERS)
--ONLEVEL_PRIORITY: 5 - Remaining ON.LEVEL methods (ie, IDOL_UID)
	onstart_init_methods()
	onlevel_remove_cursedpot()
	onlevel_remove_mounts()

	onlevel_hide_yama()
	onlevel_acidbubbles()
	onlevel_ankh_respawn()
	onlevel_decorate_trees()
	onlevel_replace_border()
	onlevel_removeborderfloor()
	onlevel_create_impostorlake()
	onlevel_remove_boulderstatue()

	onlevel_testroom()

	olmeclib.onlevel_boss_init()
	if state.theme == THEME.OLMEC then
		create_door_ending(41, 98, LAYER.FRONT)--99, LAYER.FRONT)

		botdlib.set_hell_x()
		create_door_exit_to_hell(botdlib.hell_x, HELL_Y, LAYER.FRONT)
	end

	feelingslib.onlevel_toastfeeling()
end, ON.LEVEL)

set_callback(function()
	onframe_acidpoison()
end, ON.FRAME)

set_callback(function()
	onguiframe_ui_info_path()			-- debug
	onguiframe_ui_info_worldstate()		--
end, ON.GUIFRAME)



function onstart_init_options()	
	botdlib.OBTAINED_BOOKOFDEAD = options.hd_debug_item_botd_give
	if options.hd_og_ghost_time_disable == false then ghostlib.GHOST_TIME = 9000 end

	-- UI_BOTD_PLACEMENT_W = options.hd_ui_botd_a_w
	-- UI_BOTD_PLACEMENT_H = options.hd_ui_botd_b_h
	-- UI_BOTD_PLACEMENT_X = options.hd_ui_botd_c_x
	-- UI_BOTD_PLACEMENT_Y = options.hd_ui_botd_d_y
end

function onstart_init_methods()
	if (
		worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
	) then
		ghostlib.set_spawn_times()
	elseif(
		worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.NORMAL
		or feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true
	) then
		set_ghost_spawn_times(-1, -1)
	end
end

function hd_exit_levelhandling()
	-- local next_world, next_level, next_theme = state.world or 1, state.level or 1, state.theme or THEME.DWELLING
	local next_world, next_level, next_theme = state.world, state.level, state.theme

	if state.level < 4 then
		
		next_level = state.level + 1

		if state.theme == THEME.EGGPLANT_WORLD then
			next_level = 4
		elseif state.level == 3 then
			-- -- fake 1-4
			-- if state.theme == THEME.DWELLING then
			-- 	next_level = 5
			-- elseif
			if state.theme == THEME.TEMPLE or state.theme == THEME.CITY_OF_GOLD then
				return 4, 4, THEME.OLMEC
			end
		end
	else
		next_world = state.world + 1
		next_level = 1
	end
	next_theme = HD_THEMEORDER[next_world]

	return next_world, next_level, next_theme
end

-- LEVEL HANDLING
function onloading_levelrules()
	
	--[[
		Tutorial
	--]]
	
	-- Tutorial 1-3 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL) then
		changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
		changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
		changestate_onloading_targets(1,3,THEME.DWELLING,1,1,THEME.BASE_CAMP)
		return
	end
	
	--[[
		Testing
	--]]
	
	-- Testing 1-2 -> Camp
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING) then
		changestate_onloading_targets(1,1,state.theme,1,2,state.theme)
		changestate_onloading_targets(1,2,state.theme,1,1,THEME.BASE_CAMP)
		return
	end

	-- --[[
	-- 	Mines
	-- --]]

	-- -- Mines 1-1..3
    -- changestate_onloading_targets(1,1,THEME.DWELLING,1,2,THEME.DWELLING)
    -- changestate_onloading_targets(1,2,THEME.DWELLING,1,3,THEME.DWELLING)
	
	-- -- Mines 1-3 -> Mines 1-5(Fake 1-4)
    -- changestate_onloading_targets(1,3,THEME.DWELLING,1,5,THEME.DWELLING)

    -- -- Mines -> Jungle
    changestate_onloading_targets(1,4,THEME.DWELLING,2,1,THEME.JUNGLE)

	-- --[[
	-- 	Jungle
	-- --]]

	-- -- Jungle 2-1..4
    -- changestate_onloading_targets(2,1,THEME.JUNGLE,2,2,THEME.JUNGLE)
    -- changestate_onloading_targets(2,2,THEME.JUNGLE,2,3,THEME.JUNGLE)
    -- changestate_onloading_targets(2,3,THEME.JUNGLE,2,4,THEME.JUNGLE)

    -- -- Jungle -> Ice Caves
    -- changestate_onloading_targets(2,4,THEME.JUNGLE,3,1,THEME.ICE_CAVES)

	-- --[[
	-- 	Worm
	-- --]]

	-- -- Worm(Jungle) 2-2 -> Jungle 2-4
	-- -- # TOTEST: Re-adjust level loading (remove changestate_onloading_targets() where scripted levelgen entrance doors take over)
	-- changestate_onloading_targets(2,2,THEME.EGGPLANT_WORLD,2,4,THEME.JUNGLE)
	
	-- -- Worm(Ice Caves) 3-2 -> Ice Caves 3-4
	-- changestate_onloading_targets(3,2,THEME.EGGPLANT_WORLD,3,4,THEME.ICE_CAVES)

    
	-- --[[
	-- 	Ice Caves
	-- --]]
	-- 	-- # TOTEST: Test if there are differences for room generation chances for levels higher than 3-1 or 3-4.
		
	-- -- Ice Caves 3-1..4
    -- changestate_onloading_targets(3,1,THEME.ICE_CAVES,3,2,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,2,THEME.ICE_CAVES,3,3,THEME.ICE_CAVES)
    -- changestate_onloading_targets(3,3,THEME.ICE_CAVES,3,4,THEME.ICE_CAVES)
	
    -- -- Ice Caves -> Temple
    -- changestate_onloading_targets(3,4,THEME.ICE_CAVES,4,1,THEME.TEMPLE)

	-- --[[
	-- 	Mothership
	-- --]]
	
	-- -- Mothership(3-3) -> Ice Caves(3-4)
    -- changestate_onloading_targets(3,3,THEME.NEO_BABYLON,3,4,THEME.ICE_CAVES)
	
	-- --[[
	-- 	Temple
	-- --]]
	
	-- -- Temple 4-1..3
    -- changestate_onloading_targets(4,1,THEME.TEMPLE,4,2,THEME.TEMPLE)
    -- changestate_onloading_targets(4,2,THEME.TEMPLE,4,3,THEME.TEMPLE)

    -- -- Temple -> Olmec
    -- changestate_onloading_targets(4,3,THEME.TEMPLE,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	City Of Gold
	-- --]]

    -- -- COG(4-3) -> Olmec
    -- changestate_onloading_targets(4,3,THEME.CITY_OF_GOLD,4,4,THEME.OLMEC)
	
	-- --[[
	-- 	Hell
	-- --]]

    -- changestate_onloading_targets(5,1,THEME.VOLCANA,5,2,THEME.VOLCANA)
    -- changestate_onloading_targets(5,2,THEME.VOLCANA,5,3,THEME.VOLCANA)

	-- -- Hell -> Yama
	-- 	-- Build Yama in Tiamat's chamber.
	-- changestate_onloading_targets(5,3,THEME.VOLCANA,5,4,THEME.TIAMAT)

	-- -- local format_name = F'onloading_levelrules(): Set loading target. state.*_next: {state.world_next}, {state.level_next}, {state.theme_next}'
	-- -- message(format_name)

	-- Demo Handling
	if (
		state.level == 4
		and state.world == demolib.DEMO_MAX_WORLD
		and state.screen_next ~= ON.DEATH
	) then
		changestate_onloading_targets(state.world,state.level,state.theme,1,1,THEME.BASE_CAMP)
		set_global_timeout(function()
			if state.screen ~= ON.LEVEL then toast("Demo over. Thanks for playing!") end
		end, 30)
	end

end

-- executed with the assumption that onloading_levelrules() has already been run, applying state.*_next
function onloading_applyquestflags()
	flags_failsafe = {
		10, -- Disable Waddler's
		25, 26, -- Disable Moon and Star challenges.
		19 -- Disable drill -- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
	}
	for i = 1, #flags_failsafe, 1 do
		if test_flag(state.quest_flags, flags_failsafe[i]) == false then state.quest_flags = set_flag(state.quest_flags, flags_failsafe[i]) end
	end
end

-- CHUNK GENERATION - ON.LEVEL
-- Script-based roomcode and chunk generation
function onlevel_generation_modification()
	levelw, levelh = 4, 4
	if HD_ROOMOBJECT.WORLDS[state.theme].level_dim ~= nil then
		levelw, levelh = HD_ROOMOBJECT.WORLDS[state.theme].level_dim.w, HD_ROOMOBJECT.WORLDS[state.theme].level_dim.h
	end
	global_levelassembly.modification = {
		levelrooms = levelrooms_setn(levelw, levelh),
		levelcode = levelcode_setn(levelw, levelh),
		rowfive = {
			levelrooms = levelrooms_setn_rowfive(levelw),
			levelcode = levelcode_setn(levelw, 1),
		},
	}
	if (worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL) then
		
		get_unlock()

		gen_levelrooms_nonpath(true)
		if detect_level_allow_path_gen() then
			gen_levelrooms_path()
		end
		gen_levelrooms_nonpath(false)
		
		level_generation_method_world_coffin()

		level_generation_method_coffin_coop()

		level_generation_method_shops()
		
		level_generation_method_side()
	else
		-- testing setrooms
		if ((worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING) and (HD_ROOMOBJECT.TESTING[state.level].setRooms ~= nil)) then
			level_generation_method_setrooms(HD_ROOMOBJECT.TESTING[state.level].setRooms)
		end
	
		-- tutorial setrooms
		if ((worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL) and (HD_ROOMOBJECT.TUTORIAL[state.level].setRooms ~= nil)) then
			level_generation_method_setrooms(HD_ROOMOBJECT.TUTORIAL[state.level].setRooms)
		end
	end

	gen_levelcode_fill() -- global_levelassembly.modification.levelcode adjusting (obstacle chunks)

end

-- phase one of baking levelcode
	-- spawning most things
function onlevel_generation_execution_phase_one()
	gen_levelcode_phase_1()
	gen_levelcode_phase_1(true)
end

-- phase two of baking levelcode
	-- spawn_over entities, such as spikes
function onlevel_generation_execution_phase_two()
	gen_levelcode_phase_2()
	gen_levelcode_phase_2(true)
end
-- # TODO: More phases to fix crashing entities
	-- water
	-- chain(/vine?)
function onlevel_generation_execution_phase_three()
	gen_levelcode_phase_3()
	gen_levelcode_phase_3(true)
end

-- during on_level
	-- elevators
	-- force fields
function onlevel_generation_execution_phase_four()
	gen_levelcode_phase_4()
	gen_levelcode_phase_4(true)
end

function levelrooms_setn_rowfive(levelw)
	tw = {}
	commonlib.setn(tw, levelw)
	return tw
end

function levelrooms_setn(levelw, levelh)
	path = {}

	commonlib.setn(path, levelh)
	for hi = 1, levelh, 1 do
		tw = {}
		commonlib.setn(tw, levelw)
		path[hi] = tw
	end
	
	return path
end


function levelcode_setn(levelw, levelh)
	levelcodew, levelcodeh = levelw*10, levelh*8
	levelcode = {}

	commonlib.setn(levelcode, levelcodeh)
	for hi = 1, levelcodeh, 1 do
		tw = {}
		commonlib.setn(tw, levelcodew)
		levelcode[hi] = tw
	end

	return levelcode
end

-- LEVEL HANDLING
-- For cases where room generation is hardcoded to a theme's level
-- and as a result we need to fake the world/level number
function onlevel_levelrules()
	-- Dwelling 1-5 = 1-4 (Dwelling 1-3 -> Dwelling 1-4)
	-- changestate_onlevel_fake(1,5,THEME.DWELLING,1,4,THEME.DWELLING)
	
	-- TOTEST:
	-- Use S2 Black Market as Flooded Feeling
		-- HD and S2 differences:
			-- S2 black market spawns are 2-2..4
			-- HD spawns are 2-1..3
				-- Prevents the black market from being accessed upon exiting the worm
				-- Gives room for the next level to load as black market

	-- Disable dark levels and vaults "before" you enter the world:
		-- Technically load into a total of 4 hell levels; 5-5 and 5-1..3
		-- on.load 5-5, set state.quest_flags 3 and 2, then warp the player to 5-1
		
		-- -- Jungle 2-0 = 2-1
		-- -- Disable Moon challenge.
		-- changestate_onlevel_fake_applyquestflags(2,1,THEME.JUNGLE, {25}, {})
		-- -- Ice Caves 3-0 = 3-1
		-- -- Disable Waddler's
		-- changestate_onlevel_fake_applyquestflags(3,1,THEME.ICE_CAVES, {10}, {})
		-- -- Temple 4-0 = 4-1
		-- -- Disable Star challenge.
		-- changestate_onlevel_fake_applyquestflags(4,1,THEME.TEMPLE, {26}, {})
		-- -- Volcana 5-5 = 5-1
		-- -- Disable Moon challenge and drill
		-- 	-- OR: disable drill until you get to level 4, then enable it if you want to use drill level for yama
		-- changestate_onlevel_fake_applyquestflags(5,1,THEME.VOLCANA, {19, 25}, {})
		
	-- -- Volcana 5-1 -> Volcana 5-2
	-- changestate_onlevel_fake(5,5,THEME.VOLCANA,5,2,THEME.VOLCANA)
	-- -- Volcana 5-2 -> Volcana 5-3
	-- changestate_onlevel_fake(5,6,THEME.VOLCANA,5,3,THEME.VOLCANA)
end

function onlevel_create_impostorlake()
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) then
		local x, y = 22.5, 88.5--80.5
		local w, h = 40, 12
		spawn_impostor_lake(
			AABB:new(
				x-(w/2),
				y+(h/2),
				x+(w/2),
				y-(h/2)
			),
			LAYER.FRONT, ENT_TYPE.LIQUID_IMPOSTOR_LAKE, 1.0
		)
	end
end

function onlevel_removeborderfloor()
	if (
		state.theme == THEME.NEO_BABYLON
		-- or state.theme == THEME.OLMEC -- Lava touching the void ends up in a crash
	) then
		remove_borderfloor()
	end
end

function onlevel_replace_border()
	if (
		state.theme == THEME.EGGPLANT_WORLD
		or state.theme == THEME.VOLCANA
	) then
		
		local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
		if state.theme == THEME.EGGPLANT_WORLD then
			texture_def.texture_path = "res/worm_border.png"
		elseif state.theme == THEME.VOLCANA then
			texture_def.texture_path = "res/hell_border.png"
		end
		boneder_texture = define_texture(texture_def)

		local bonebordere = get_entities_by_type(ENT_TYPE.FLOOR_BORDERTILE) -- get all entities of these types
		for _, boneborder_uid in pairs(bonebordere) do 
			get_entity(boneborder_uid):set_texture(boneder_texture)

			local boneborderdecoratione = entity_get_items_by(boneborder_uid, ENT_TYPE.DECORATION_BORDER, 0)
			for _, boneborderdecoration_uid in pairs(boneborderdecoratione) do
				get_entity(boneborderdecoration_uid):set_texture(boneder_texture)
			end
		end
	end
end

function onlevel_remove_cursedpot()
	cursedpot_uids = get_entities_by_type(ENT_TYPE.ITEM_CURSEDPOT)
	if #cursedpot_uids > 0 and options.hd_og_cursepot_enable == false then
		xmin, ymin, _, _ = get_bounds()
		void_x = xmin - 3.5
		void_y = ymin
		spawn_entity(ENT_TYPE.FLOOR_BORDERTILE, void_x, void_y, LAYER.FRONT, 0, 0)
		for _, cursedpot_uid in ipairs(cursedpot_uids) do
			move_entity(cursedpot_uid, void_x, void_y+1, 0, 0)
		end
	end
end

function onlevel_remove_mounts()
	mounts = get_entities_by_type({
		ENT_TYPE.MOUNT_TURKEY
		-- ENT_TYPE.MOUNT_ROCKDOG,
		-- ENT_TYPE.MOUNT_AXOLOTL,
		-- ENT_TYPE.MOUNT_MECH
	})
	-- Avoid removing mounts players are riding or holding
	-- avoid = {}
	-- for i = 1, #players, 1 do
		-- holdingmount = get_entity(players[1].uid):as_movable().holding_uid
		-- mount = get_entity(players[1].uid):topmost()
		-- -- message(tostring(mount.uid))
		-- if (
			-- mount ~= players[1].uid and
			-- (
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_TURKEY or
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_ROCKDOG or
				-- mount:as_container().type.id == ENT_TYPE.MOUNT_AXOLOTL
			-- )
		-- ) then
			-- table.insert(avoid, mount)
		-- end
		-- if (
			-- holdingmount ~= -1 and
			-- (
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_TURKEY or
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_ROCKDOG or
				-- holdingmount:as_container().type.id == ENT_TYPE.MOUNT_AXOLOTL
			-- )
		-- ) then
			-- table.insert(avoid, holdingmount)
		-- end
	-- end
	if state.theme == THEME.DWELLING and (state.level == 2 or state.level == 3) then
		for t, mount in ipairs(mounts) do
			-- stop_remove = false
			-- for _, avoidmount in ipairs(avoid) do
				-- if mount == avoidmount then stop_remove = true end
			-- end
			mov = get_entity(mount):as_movable()
			if test_flag(mov.flags, ENT_FLAG.SHOP_ITEM) == false then --and stop_remove == false then
				move_entity(mount, 0, 0, 0, 0)
			end
		end
	end
end

function onlevel_acidbubbles()
	if state.theme == THEME.EGGPLANT_WORLD then
		set_interval(bubbles, 35) -- 15)
	end
end


function onlevel_ankh_respawn()
	if options.hd_debug_scripted_levelgen_disable == false then
		set_timeout(function()
			local cb_moai_diamond = -1
			local cb_moai_hedjet = -1
			-- # TODO: Investigate if breaking/teleporting into the Moai in HD disables being able to get the hedjet.
			if feelingslib.feeling_check(feelingslib.FEELING_ID.MOAI) == true then
				cb_moai_diamond = set_interval(function()
					if players_in_moai() then
						kill_entity(moai_veil)
						spawn_entity(ENT_TYPE.ITEM_DIAMOND, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
						local sound = get_sound(VANILLA_SOUND.UI_SECRET)
						if sound ~= nil then sound:play() end
						clear_callback(cb_moai_hedjet)
						return false
					end
				end, 1)
				cb_moai_hedjet = set_interval(function()
					for i = 1, #players, 1 do
						if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_ANKH) and players[i].health == 0 then
							set_timeout(function()
								move_entity(players[i].uid, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y, LAYER.FRONT, 0, 0)
								kill_entity(moai_veil)
								spawn_entity(ENT_TYPE.ITEM_PICKUP_HEDJET, global_levelassembly.moai_exit.x, global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
								local sound = get_sound(VANILLA_SOUND.UI_SECRET)
								if sound ~= nil then sound:play() end
								clear_callback(cb_moai_diamond)
							end, 3)
							return false
						end
					end
				end, 1)
			else
				set_interval(function()
					for i = 1, #players, 1 do
						if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_ANKH) and players[i].health == 0 then
							set_timeout(function()
								move_entity(players[1].uid, global_levelassembly.entrance.x, global_levelassembly.entrance.y, LAYER.FRONT, 0, 0)
							end, 3)
							return false
						end
					end
				end, 1)
			end

		end, 15)
	end
end

function onlevel_remove_boulderstatue()
	if state.theme == THEME.ICE_CAVES then
		boulderbackgrounds = get_entities_by_type(ENT_TYPE.BG_BOULDER_STATUE)
		if #boulderbackgrounds > 0 then
			kill_entity(boulderbackgrounds[1])
		end
	end
end

-- # TODO: Revise into HD_TILENAME["T"] and improve.
-- Use the following methods for a starting point:

-- HD-style tree decorating methods
function decorate_tree(e_type, p_uid, side, y_offset, radius, right)
	if p_uid == 0 then return 0 end
	p_x, p_y, p_l = get_position(p_uid)
	branches = get_entities_at(e_type, 0, p_x+side, p_y, p_l, radius)
	branch_uid = 0
	if #branches == 0 then
		branch_uid = spawn_entity_over(e_type, p_uid, side, y_offset)
		if e_type == ENT_TYPE.DECORATION_TREE then
			branch_e = get_entity(branch_uid)
			branch_e.animation_frame = 87+12*math.random(2)
		end
	else
		branch_uid = branches[1]
	end
	-- flip if you just created it and it's a 0x100 and it's on the left or if it's 0x200 and on the right.
	branch_e = get_entity(branch_uid)
	if branch_e ~= nil then
		-- flipped = test_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		if (#branches == 0 and branch_e.type.search_flags == 0x100 and side == -1) then -- to flip branches
			flip_entity(branch_uid)
		elseif (branch_e.type.search_flags == 0x200 and right == false) then -- to flip decorations
			branch_e.flags = set_flag(branch_e.flags, ENT_FLAG.FACING_LEFT)
		end
	end
	return branch_uid
end
function onlevel_decorate_trees()
	if (
		(state.theme == THEME.JUNGLE or state.theme == THEME.TEMPLE) and
		options.hd_og_tree_spawn == false
	) then
		-- remove tree vines
		treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_BRANCH)
		for _, treebranch in ipairs(treeParts) do
			if entity_has_item_type(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP) then
				treeVineTop = entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE_TOP, 0)[1]
				_x, _y, _l = get_position(treeVineTop)
				
				-- don't kill it if it's the top
				if (
					#get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, _x-1, _y-1, _l, 1) == 0 and
					#get_entities_at(ENT_TYPE.FLOOR_TREE_TOP, 0, _x+1, _y-1, _l, 1) == 0
				) then
					kill_entity(treeVineTop)
				end
				
				kill_entity(get_entities_at(ENT_TYPE.FLOOR_VINE, 0, _x, _y-2, _l, 1)[1])
				kill_entity(entity_get_items_by(treebranch, ENT_TYPE.DECORATION_TREE_VINE, 0)[1])
			end
		end
		treeParts = get_entities_by_type(ENT_TYPE.FLOOR_VINE_TREE_TOP)
		for _, treeVineTop in ipairs(treeParts) do
			kill_entity(treeVineTop)
		end
		-- add branches to tops of trees, add leaf decorations
		treeParts = get_entities_by_type(ENT_TYPE.FLOOR_TREE_TOP)
		for _, treetop in ipairs(treeParts) do
			branch_uid_left = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, -1, 0, 0.1, false)
			branch_uid_right = decorate_tree(ENT_TYPE.FLOOR_TREE_BRANCH, treetop, 1, 0, 0.1, false)
			if (
				feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false and
				feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false
			) then
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_left, 0.03, 0.47, 0.5, false)
				decorate_tree(ENT_TYPE.DECORATION_TREE_VINE_TOP, branch_uid_right, -0.03, 0.47, 0.5, true)
			else
				decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_left, 0.03, 0.47, 0.5, false)
				decorate_tree(ENT_TYPE.DECORATION_TREE, branch_uid_right, -0.03, 0.47, 0.5, true)
				-- # TODO: chance of grabbing the FLOOR_TREE_TRUNK below `treetop` and applying DECORATION_TREE with a reskin of a haunted face
			end
		end
	end
end


-- Use junglespear traps for idol trap blocks and other blocks that shouldn't have post-destruction decorations
set_post_entity_spawn(function(_entity)
	_spikes = entity_get_items_by(_entity.uid, ENT_TYPE.LOGICAL_JUNGLESPEAR_TRAP_TRIGGER, 0)
	for _, _spike in ipairs(_spikes) do
		kill_entity(_spike)
	end
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_JUNGLE_SPEAR_TRAP)


--[[
	SPAWN EXCEPTIONS
	Several areas in HD shouldn't spawn certain entities. The following code should fix that.
	Code adapted from JayTheBusinessGoose: https://github.com/jaythebusinessgoose/CustomLevels/blob/master/custom_levels.lua
--]]


local removed_procedural_spawns = {
	ENT_TYPE.ITEM_TORCH,
	ENT_TYPE.MONS_PET_DOG,
	ENT_TYPE.ITEM_BONES,
	ENT_TYPE.EMBED_GOLD,
	ENT_TYPE.EMBED_GOLD_BIG,
	ENT_TYPE.ITEM_POT,
	ENT_TYPE.ITEM_NUGGET,
	ENT_TYPE.ITEM_NUGGET_SMALL,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.ITEM_CHEST,
	ENT_TYPE.ITEM_CRATE,
	ENT_TYPE.MONS_PET_CAT,
	ENT_TYPE.MONS_PET_HAMSTER,
	ENT_TYPE.ITEM_ROCK,
	ENT_TYPE.ITEM_RUBY,
	ENT_TYPE.ITEM_CURSEDPOT,
	ENT_TYPE.ITEM_SAPPHIRE,
	ENT_TYPE.ITEM_EMERALD,
	ENT_TYPE.ITEM_WALLTORCH,
	ENT_TYPE.MONS_SCARAB,
	ENT_TYPE.ITEM_AUTOWALLTORCH,
	ENT_TYPE.ITEM_WEB,
	ENT_TYPE.ITEM_GOLDBAR,
	ENT_TYPE.ITEM_GOLDBARS,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.MONS_SKELETON,
}

local removed_embedded_items = {
    ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE,
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
    ENT_TYPE.ITEM_PICKUP_PARACHUTE,
    ENT_TYPE.ITEM_CAPE,
    ENT_TYPE.ITEM_JETPACK,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_HOVERPACK,
    ENT_TYPE.ITEM_POWERPACK,
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_CROSSBOW,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_BOOMERANG,
    ENT_TYPE.ITEM_MACHETE,
}


-- custom_level_state.procedural_spawn_callback = set_post_entity_spawn(function(entity, spawn_flags)
-- 	if (

-- 	) then return end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, removed_procedural_spawns)

local removed_embedded_currencies = {
    ENT_TYPE.EMBED_GOLD,
    ENT_TYPE.EMBED_GOLD_BIG,
    ENT_TYPE.ITEM_RUBY,
    ENT_TYPE.ITEM_SAPPHIRE,
    ENT_TYPE.ITEM_EMERALD,
}
-- set_post_entity_spawn(function(entity, spawn_flags)
-- 	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
-- 		if (
-- 			state.theme ~= THEME.NEO_BABYLON
-- 			and state.theme ~= THEME.EGGPLANT_WORLD
-- 			-- and (feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false)
-- 		) then
-- 			return
-- 		end
-- 	elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
-- 		if (
-- 			entity.type.id == ENT_TYPE.EMBED_GOLD
-- 			or entity.type.id == ENT_TYPE.EMBED_GOLD_BIG
-- 		) then
-- 			return
-- 		end
-- 	elseif worldlib.HD_WORLDSTATE_STATE ~= worldlib.HD_WORLDSTATE_STATUS.TESTING then
-- 		return
-- 	end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN, 0, removed_embedded_currencies)

-- set_post_entity_spawn(function(entity, spawn_flags) -- remove embedded items from tutorial/testing
-- 	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then return end
-- 	-- Do not remove spawns from a script.
-- 	if (spawn_flags & SPAWN_TYPE.SCRIPT) ~= 0 then return end
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	move_entity(entity.uid, 1000, 0, 0, 0)
-- 	entity:destroy()
-- end, SPAWN_TYPE.LEVEL_GEN, 0, removed_embedded_items)


--[[
	/SPAWN EXCEPTIONS
--]]


-- prevent tilecode entrance door entities from spawning
function remove_entrance_door_entity(_entity)
	if
		state.screen == ON.LEVEL
		and
		options.hd_debug_scripted_levelgen_disable == false
		and state.theme ~= THEME.OLMEC
	then
		kill_entity(_entity.uid)
	end
end
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.BG_DOOR)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.FLOOR_DOOR_ENTRANCE)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.LOGICAL_DOOR)
set_post_entity_spawn(remove_entrance_door_entity, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, ENT_TYPE.LOGICAL_PLATFORM_SPAWNER)


-- # TODO: Fix the following method. For some godforsaken reason it won't move the player.

-- -- move players and things they have to scripted entrance point
-- function move_entrance_door_entity(_entity)
-- 	_x, _y, _l = get_position(_entity.uid)
-- 	local _offset_x, _offset_y = _x-state.level_gen.spawn_x, _y-state.level_gen.spawn_y
-- 	if (
-- 		state.screen == ON.LEVEL and
-- 		options.hd_debug_scripted_levelgen_disable == false and
-- 		detect_level_non_boss()
-- 	) then
-- 		-- move_entity(_entity.uid, global_levelassembly.entrance.x+_offset_x, global_levelassembly.entrance.y+_offset_y, 0, 0)
-- 		move_entity(_entity.uid, global_levelassembly.entrance.x, global_levelassembly.entrance.y, 0, 0)
-- 		message("moved to: " .. global_levelassembly.entrance.x .. ", " .. global_levelassembly.entrance.y)
-- 	end
-- 	-- message("_offset_x, _offset_y: " .. _offset_x .. ", " .. _offset_y)
-- end
-- set_post_entity_spawn(move_entrance_door_entity,
-- SPAWN_TYPE.ANY,
-- -- SPAWN_TYPE.LEVEL_GEN,
-- -- SPAWN_TYPE.LEVEL_GEN_GENERAL,
-- -- SPAWN_TYPE.LEVEL_GEN_PROCEDURAL,
-- -- SPAWN_TYPE.LEVEL_GEN_TILE_CODE,
-- -- SPAWN_TYPE.SYSTEMIC,
-- MASK.PLAYER)

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY NOTHING
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_YAMA_PLATFORM)

-- set_pre_entity_spawn(function(ent_type, x, y, l, overlay)
-- 	-- SORRY NOTHING
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.BG_YAMA_BODY)

-- set_post_entity_spawn(function(entity)
--     entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.TAKE_NO_DAMAGE) -- Unneeded(?)
-- 	entity.flags = set_flag(entity.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
-- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_YAMA)
-- # TODO: Relocate MONS_YAMA to a better place. Can't move him to back layer, it triggers the slow music :(
	-- OR: improve hiding him. Could use set_post_entity_spawn.
function onlevel_hide_yama()
	if state.theme == THEME.EGGPLANT_WORLD then
		-- kill_entity(get_entities_by_type(ENT_TYPE.BG_YAMA_BODY)[1])
		-- for i, yama_floor in ipairs(get_entities_by_type(ENT_TYPE.FLOOR_YAMA_PLATFORM)) do
		-- 	kill_entity(yama_floor)
		-- end

		-- local yama = get_entity(get_entities_by_type(ENT_TYPE.MONS_YAMA)[1])
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.INVISIBLE)
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.TAKE_NO_DAMAGE) -- Unneeded(?)
		-- yama.flags = set_flag(yama.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
		-- move_entity(0, 1000, 0, 0)
	end
end

set_callback(function(text)
    if (
		text == "Your voice echoes in here..."
		or text == "You hear the beating of drums..."
		or text == "You hear the sounds of revelry!"
		or text == "You feel strangely at peace."
	) then -- this will only work when chosen language is English, unless you add all variants for all languages
        text = "" -- message won't be shown
	elseif (
		text == "Shortcut Station: Coming Soon! -Mama Tunnel"
		or text == "New shortcut coming soon! -Mama Tunnel"
	) then
		text = "Feature in development!"
    end
	return text
end, ON.TOAST)

function onframe_acidpoison()
	-- Worm LEVEL
	if state.theme == THEME.EGGPLANT_WORLD then
		-- Acid damage
		for i, player in ipairs(players) do
			-- local spelunker_mov = get_entity(player):as_movable()
			local spelunker_swimming = test_flag(player.more_flags, 11)
			local poisoned = player:is_poisoned()
			x, y, l = get_position(player.uid)
			if spelunker_swimming and player.health ~= 0 and not poisoned then
				if acid_tick <= 0 then
					spawn(ENT_TYPE.ITEM_ACIDSPIT, x, y, l, 0, 0)
					acid_tick = ACID_POISONTIME
				else
					acid_tick = acid_tick - 1
				end
			else
				acid_tick = ACID_POISONTIME
			end
		end
	end
end

function players_in_moai()
	local moai_hollow_aabb = AABB:new(
		global_levelassembly.moai_exit.x-.5,
		global_levelassembly.moai_exit.y+1.5,
		global_levelassembly.moai_exit.x+.5,
		global_levelassembly.moai_exit.y-1.5
	)
	moai_hollow_aabb:offset(0, 1)
	local players_in_moai = get_entities_overlapping_hitbox(
		0, MASK.PLAYER,
		moai_hollow_aabb,
		LAYER.FRONT
	)
	return #players_in_moai ~= 0
end


-- # TODO: Revise `applyflags_to_*` method's `flags` parameter.
	-- From this:
		-- flags = {
			-- {ENT_FLAG.NO_GRAVITY},					-- set
			-- {ENT_FLAG.SOLID, ENT_FLAG.PICKUPABLE}	-- clear
		-- }
	-- To this:
		-- flags = {
			-- [ENT_FLAG.SOLID] = false,
			-- [ENT_FLAG.NO_GRAVITY] = true,
			-- [ENT_FLAG.PICKUPABLE] = false
		-- }
function applyflags_to_level(flags)
	if #flags > 0 then
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			state.level_flags = set_flag(state.level_flags, flag)
		end
		if #flags > 1 then
			flags_clear = flags[2]
			for _, flag in ipairs(flags_clear) do
				state.level_flags = clr_flag(state.level_flags, flag)
			end
		end
	else message("No level flags") end
end

function applyflags_to_quest(flags)
	if #flags > 0 then
		flags_set = flags[1]
		for _, flag in ipairs(flags_set) do
			state.quest_flags = set_flag(state.quest_flags, flag)
		end
		if #flags > 1 then
			flags_clear = flags[2]
			for _, flag in ipairs(flags_clear) do
				state.quest_flags = clr_flag(state.quest_flags, flag)
			end
		end
	else message("No quest flags") end
end

function onguiframe_ui_info_worldstate()
	if (
		options.hd_debug_info_worldstate == true
		and (state.pause == 0 and (state.screen == 11 or state.screen == 12))
	) then
		text_x = -0.95
		text_y = -0.37
		white = rgba(255, 255, 255, 255)
		green = rgba(55, 200, 75, 255)

		hd_worldstate_debugtext_status = "UNKNOWN"
		color = white

		-- worldlib.HD_WORLDSTATE_STATE
		if worldlib.HD_WORLDSTATE_STATE ~= nil then
			if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
				hd_worldstate_debugtext_status = "NORMAL"
			elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL then
				hd_worldstate_debugtext_status = "TUTORIAL"
				color = green
			elseif worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
				hd_worldstate_debugtext_status = "TESTING"
				color = green
			end
		end
		draw_text(text_x, text_y, 0, "worldlib.HD_WORLDSTATE_STATE: " .. hd_worldstate_debugtext_status, color)

		text_y = text_y-0.1
		color = white

		-- door uid
		if DOOR_TUTORIAL_UID ~= nil and DOOR_TUTORIAL_UID >= 0 then color = green end
		draw_text(text_x, text_y, 0, "DOOR_TUTORIAL_UID: " .. tostring(DOOR_TUTORIAL_UID), color)

		text_y = text_y-0.1
		color = white

		-- overlaps with player 1
		door_entrance_ent = get_entity(DOOR_TUTORIAL_UID)
		door_testing_entered_text = "false"
		if door_entrance_ent:overlaps_with(get_entity(players[1].uid)) == true then
			door_testing_entered_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_text(text_x, text_y, 0, "OVERLAPS_WITH: " .. door_testing_entered_text, color)
		
		text_y = text_y-0.1
		color = white

		-- if player 1 state is entering
		player_entering_text = "false"
		if players[1].state == CHAR_STATE.ENTERING then
			player_entering_text = "true"
			color = green
		else door_testing_entered_text = "false" end
		draw_text(text_x, text_y, 0, "players[1].state == CHAR_STATE.ENTERING: " .. player_entering_text, color)

	end
end

function onguiframe_ui_info_path()
	if (
		options.hd_debug_info_path == true and
		-- (state.pause == 0 and state.screen == 12 and #players > 0) and
		global_levelassembly ~= nil
	) then
		text_x = -0.95
		text_y = -0.35
		white = rgba(255, 255, 255, 255)
		
		-- levelw, levelh = get_levelsize()
		levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		
		text_y_space = text_y
		for hi = 1, levelh, 1 do -- hi :)
			text_x_space = text_x
			for wi = 1, levelw, 1 do
				text_subchunkid = tostring(global_levelassembly.modification.levelrooms[hi][wi])
				if text_subchunkid == nil then text_subchunkid = "nil" end
				draw_text(text_x_space, text_y_space, 0, text_subchunkid, white)
				
				text_x_space = text_x_space+0.04
			end
			text_y_space = text_y_space-0.04
		end
	end
end


function level_generation_method_side()

	--[[
		ROOM CODES
	--]]
	-- worlds
	chunkcodes = (
		HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
		HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
		HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.SIDE] ~= nil
	) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.SIDE]
	-- feelings
	check_feeling_content = nil
	-- feelings
	for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
		if (
			feelingslib.feeling_check(feeling) == true and
			feelingContent.rooms ~= nil and
			feelingContent.rooms[genlib.HD_SUBCHUNKID.SIDE] ~= nil
		) then
			check_feeling_content = feelingContent.rooms[genlib.HD_SUBCHUNKID.SIDE]
		end
	end
	if check_feeling_content ~= nil then
		chunkcodes = check_feeling_content
	end

	if chunkcodes ~= nil then
		levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		for level_hi = 1, levelh, 1 do
			for level_wi = 1, levelw, 1 do
				subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
				if subchunk_id == nil then -- apply sideroom
					specified_index = math.random(#chunkcodes)
					side_results = nil
					if (
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
						HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[genlib.HD_SUBCHUNKID.SIDE] ~= nil
					) then
						side_results = HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[genlib.HD_SUBCHUNKID.SIDE]({wi = level_wi, hi = level_hi})
					end
					for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
						if (
							feelingslib.feeling_check(feeling) == true and
							feelingContent.chunkRules ~= nil and
							feelingContent.chunkRules.rooms ~= nil and
							feelingContent.chunkRules.rooms[genlib.HD_SUBCHUNKID.SIDE] ~= nil
						) then
							side_results = feelingContent.chunkRules.rooms[genlib.HD_SUBCHUNKID.SIDE]({wi = level_wi, hi = level_hi})
						end
					end
					
					if (side_results ~= nil) then
						specified_index = -1
						if (
							side_results.index == nil
						) then
							if side_results.altar ~= nil then
								altar_roomcodes = HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.ALTAR]
								check_feeling_content = nil
								for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
									if (
										feelingslib.feeling_check(feeling) == true and
										feelingContent.rooms ~= nil and
										feelingContent.rooms[genlib.HD_SUBCHUNKID.ALTAR] ~= nil
									) then
										check_feeling_content = feelingContent.rooms[genlib.HD_SUBCHUNKID.ALTAR]
									end
								end
								if check_feeling_content ~= nil then
									altar_roomcodes = check_feeling_content
								end
								if altar_roomcodes == nil then
									altar_roomcodes = HD_ROOMOBJECT.GENERIC[genlib.HD_SUBCHUNKID.ALTAR]
								end

								levelcode_inject_roomcode(
									genlib.HD_SUBCHUNKID.ALTAR,
									altar_roomcodes,
									level_hi, level_wi
								)
							elseif side_results.idol ~= nil then
								idol_roomcodes = HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.IDOL]
								check_feeling_content = nil
								for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
									if (
										feelingslib.feeling_check(feeling) == true and
										feelingContent.rooms ~= nil and
										feelingContent.rooms[genlib.HD_SUBCHUNKID.IDOL] ~= nil
									) then
										check_feeling_content = feelingContent.rooms[genlib.HD_SUBCHUNKID.IDOL]
									end
								end
								if check_feeling_content ~= nil then
									idol_roomcodes = check_feeling_content
								end
								levelcode_inject_roomcode(
									(
										feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) and
										genlib.HD_SUBCHUNKID.RESTLESS_IDOL or genlib.HD_SUBCHUNKID.IDOL
									),
									(
										feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) and
										HD_ROOMOBJECT.FEELINGS[feelingslib.FEELING_ID.RESTLESS].rooms[genlib.HD_SUBCHUNKID.RESTLESS_IDOL] or
										idol_roomcodes
									),
									level_hi, level_wi
								)
							end
						else
							specified_index = side_results.index
						end
					end

					if specified_index ~= -1 then

						levelcode_inject_roomcode(
							genlib.HD_SUBCHUNKID.SIDE,
							chunkcodes, -- HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.SIDE],
							level_hi, level_wi,
							-- rules
							specified_index
						)
					end
				end
			end
		end
	else
		message("level_generation_method_side: No roomcodes available for siderooms;")
	end
end

function level_generation_method_setrooms_rowfive(setRooms, prePath)
	for _, setroomcont in ipairs(setRooms) do
		if (setroomcont.prePath == nil and prePath == false) or (setroomcont.prePath ~= nil and setroomcont.prePath == prePath) then
			if setroomcont.placement == nil or setroomcont.subchunk_id == nil or setroomcont.roomcodes == nil then
				message("setroom params missing! Couldn't spawn.")
			else
				levelcode_inject_roomcode_rowfive(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement)
			end
		end
	end
end

function level_generation_method_setrooms(setRooms, prePath)
	prePath = prePath or false
	for _, setroomcont in ipairs(setRooms) do
		if (setroomcont.prePath == nil and prePath == false) or (setroomcont.prePath ~= nil and setroomcont.prePath == prePath) then
			if setroomcont.placement == nil or setroomcont.subchunk_id == nil or setroomcont.roomcodes == nil then
				message("setroom params missing! Couldn't spawn.")
			else
				levelcode_inject_roomcode(setroomcont.subchunk_id, setroomcont.roomcodes, setroomcont.placement[1], setroomcont.placement[2])
			end
		end
	end
end

--[[
	_nonaligned_room_type
		.subchunk_id
		.roomcodes
	_avoid_bottom
--]]
function level_generation_method_nonaligned(_nonaligned_room_type, _avoid_bottom)
	_avoid_bottom = _avoid_bottom or false
	
	
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y}

	-- build a collection of potential spots
	for level_hi = 1, levelh-(_avoid_bottom and 1 or 0), 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				-- add room
				table.insert(spots, {x = level_wi, y = level_hi})
			end
		end
	end

	-- pick random place to fill
	spot = commonlib.TableRandomElement(spots)

	levelcode_inject_roomcode(_nonaligned_room_type.subchunk_id, _nonaligned_room_type.roomcodes, spot.y, spot.x)
end

--[[
	_aligned_room_types
		.left
			.subchunk_id
			.roomcodes
		.right
			.subchunk_id
			.roomcodes
--]]
function level_generation_method_aligned(_aligned_room_types)
	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms

	spots = {}
		--{x, y, facing_left}

	-- build a collection of potential spots
	for level_hi = 1, levelh, 1 do
		for level_wi = 1, levelw, 1 do
			subchunk_id = global_levelassembly.modification.levelrooms[level_hi][level_wi]
			if subchunk_id == nil then
				if ( -- add right facing if there is a path on the right
					level_wi+1 <= levelw and
					(
						global_levelassembly.modification.levelrooms[level_hi][level_wi+1] ~= nil and
						global_levelassembly.modification.levelrooms[level_hi][level_wi+1] >= 1 and
						global_levelassembly.modification.levelrooms[level_hi][level_wi+1] <= 8
					)
				) then
					table.insert(spots, {x = level_wi, y = level_hi, facing_left = false})
				elseif (-- add left facing if there is a path on the left
					level_wi-1 >= 1 and
					(
						global_levelassembly.modification.levelrooms[level_hi][level_wi-1] ~= nil and
						global_levelassembly.modification.levelrooms[level_hi][level_wi-1] >= 1 and
						global_levelassembly.modification.levelrooms[level_hi][level_wi-1] <= 8
					)
				) then
					table.insert(spots, {x = level_wi, y = level_hi, facing_left = true})
				end
			end
		end
	end

	-- pick random place to fill
	spot = spots[math.random(#spots)]
	if spot ~= nil then
		levelcode_inject_roomcode(
			(spot.facing_left and _aligned_room_types.left.subchunk_id or _aligned_room_types.right.subchunk_id),
			(spot.facing_left and _aligned_room_types.left.roomcodes or _aligned_room_types.right.roomcodes),
			spot.y, spot.x
		)
	end
end

function detect_level_non_boss()
	return (
		state.theme ~= THEME.OLMEC
		and feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false
	)
end
function detect_level_non_special()
	return (
		state.theme ~= THEME.EGGPLANT_WORLD and
		state.theme ~= THEME.NEO_BABYLON and
		state.theme ~= THEME.CITY_OF_GOLD and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end
function detect_level_allow_path_gen()
	return (
		detect_level_non_boss() and
		-- state.theme ~= THEME.CITY_OF_GOLD and
		feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false and
		feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end

function detect_level_allow_coop_coffin()
	return (
		COOP_COFFIN == true
		and detect_level_non_boss()
		-- and state.theme ~= THEME.CITY_OF_GOLD
		and feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) == false
		and feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET) == false
	)
end

function level_generation_method_world_coffin()
	if (
		LEVEL_UNLOCK ~= nil
		and (
			LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
			or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
			or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
			or LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
		)
	) then
		level_generation_method_aligned(
			{
				left = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT,
					roomcodes = HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT]
				},
				right = {
					subchunk_id = genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT,
					roomcodes = HD_ROOMOBJECT.WORLDS[state.theme].rooms[genlib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT]
				}
			}
		)
	end
end

function level_generation_method_coffin_coop()
	if detect_level_allow_coop_coffin() then
		levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
		
		spots = {}
		for room_y = 1, levelh, 1 do
			for room_x = 1, levelw, 1 do
				path_to_replace = global_levelassembly.modification.levelrooms[room_y][room_x]
				path_to_replace_with = -1
				
				if path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP then
					path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP
				elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP then
					path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
				elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH_NOTOP then
					path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
				elseif path_to_replace == genlib.HD_SUBCHUNKID.PATH then
					path_to_replace_with = genlib.HD_SUBCHUNKID.COFFIN_COOP
				end
				
				if path_to_replace_with ~= -1 then
					table.insert(spots, {x = room_x, y = room_y, id = path_to_replace_with})
				end
			
			end
		end
		if #spots ~= 0 then
			-- pick random place to fill
			spot = spots[math.random(#spots)]
			roomcode = nil
			
			if (
				HD_ROOMOBJECT.WORLDS[state.theme].rooms ~= nil and
				HD_ROOMOBJECT.WORLDS[state.theme].rooms[spot.id] ~= nil
			) then
				roomcode = HD_ROOMOBJECT.WORLDS[state.theme].rooms[spot.id]
			end
			-- feelings
			for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
				if (
					feelingslib.feeling_check(feeling) == true and
					feelingContent.rooms ~= nil and
					feelingContent.rooms[spot.id] ~= nil
				) then
					roomcode = feelingContent.rooms[spot.id]
				end
			end

			levelcode_inject_roomcode(
				spot.id,
				roomcode,
				spot.y, spot.x
			)
		end
	end
end

function level_generation_method_shops()
	if (
		detect_same_levelstate(THEME.DWELLING, 1, 1) == false and
		state.theme ~= THEME.VOLCANA and
		detect_level_non_boss() and
		detect_level_non_special()
	) then
		if (math.random(state.level + ((state.world - 1) * 4)) <= 2) then
			shop_id_right = genlib.HD_SUBCHUNKID.SHOP_REGULAR
			shop_id_left = genlib.HD_SUBCHUNKID.SHOP_REGULAR_LEFT
			-- # TODO: Find real chance of spawning a dice shop.
			-- This is a temporary solution.
			if math.random(7) == 1 then
				state.level_gen.shop_type = SHOP_TYPE.DICE_SHOP
				shop_id_right = genlib.HD_SUBCHUNKID.SHOP_PRIZE
				shop_id_left = genlib.HD_SUBCHUNKID.SHOP_PRIZE_LEFT
			-- elseif state.level_gen.shop_type == SHOP_TYPE.DICE_SHOP then
			-- 	state.level_gen.shop_type = math.random(0, 5)
			end

			level_generation_method_aligned(
				{
					left = {
						subchunk_id = shop_id_left,
						roomcodes = HD_ROOMOBJECT.GENERIC[shop_id_left]
					},
					right = {
						subchunk_id = shop_id_right,
						roomcodes = HD_ROOMOBJECT.GENERIC[shop_id_right]
					}
				}
			)
		end
	end
end

function level_generation_method_structure_vertical(_structure_top, _structure_parts, _struct_x_pool, _mid_height_min)
	_mid_height_min = _mid_height_min or 0
	
	_, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	
	structx = _struct_x_pool[math.random(1, #_struct_x_pool)]

	-- spawn top
	levelcode_inject_roomcode(_structure_top.subchunk_id, _structure_top.roomcodes, 1, structx)

	if _structure_parts ~= nil then
		mid_height = (_mid_height_min == 0) and 0 or math.random(_mid_height_min, levelh-2)
		-- if _midheight_min == 0 then
		-- 	midheight = 0
		-- else
		-- 	midheight = math.random(_midheight_min, levelh-2)
		-- end

		-- spawn middle
		if _structure_parts.middle ~= nil then
			
			for i = 2, 1+mid_height, 1 do
				levelcode_inject_roomcode(_structure_parts.middle.subchunk_id, _structure_parts.middle.roomcodes, i, structx)
			end
		end
		-- spawn bottom
		if _structure_parts.bottom ~= nil then
			levelcode_inject_roomcode(_structure_parts.bottom.subchunk_id, _structure_parts.bottom.roomcodes, mid_height+2, structx)
		end
	end
end

function levelcode_inject_roomcode_rowfive(_subchunk_id, _roomPool, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	global_levelassembly.modification.rowfive.levelrooms[_level_wi] = _subchunk_id

	c_y = 1
	c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject_rowfive(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject_rowfive(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	chunkPool_rand_index = _specified_index
	chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			global_levelassembly.modification.rowfive.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function levelcode_inject_roomcode(_subchunk_id, _roomPool, _level_hi, _level_wi, _specified_index)
	_specified_index = _specified_index or math.random(#_roomPool)
	global_levelassembly.modification.levelrooms[_level_hi][_level_wi] = _subchunk_id

	c_y = ((_level_hi*CONST.ROOM_HEIGHT)-CONST.ROOM_HEIGHT)+1
	c_x = ((_level_wi*CONST.ROOM_WIDTH)-CONST.ROOM_WIDTH)+1
	
	-- message("levelcode_inject_roomcode: hi, wi: " .. _level_hi .. ", " .. _level_wi .. ";")
	-- prinspect(c_y, c_x)
	
	levelcode_inject(_roomPool, CONST.ROOM_HEIGHT, CONST.ROOM_WIDTH, c_y, c_x, _specified_index)
end

function levelcode_inject(_chunkPool, _c_dim_h, _c_dim_w, _c_y, _c_x, _specified_index)
	_specified_index = _specified_index or math.random(#_chunkPool)
	chunkPool_rand_index = _specified_index
	chunkCodeOrientation_index = math.random(#_chunkPool[chunkPool_rand_index])
	chunkcode = _chunkPool[chunkPool_rand_index][chunkCodeOrientation_index]
	i = 1
	for c_hi = _c_y, (_c_y+_c_dim_h)-1, 1 do
		for c_wi = _c_x, (_c_x+_c_dim_w)-1, 1 do
			global_levelassembly.modification.levelcode[c_hi][c_wi] = chunkcode:sub(i, i)
			i = i + 1
		end
	end
end

function gen_levelrooms_nonpath(prePath)
	
	if (
		(HD_ROOMOBJECT.WORLDS[state.theme].prePath == nil and prePath == false)
		or (HD_ROOMOBJECT.WORLDS[state.theme].prePath ~= nil and HD_ROOMOBJECT.WORLDS[state.theme].prePath == prePath)
	) then
		if HD_ROOMOBJECT.WORLDS[state.theme].method ~= nil then
			HD_ROOMOBJECT.WORLDS[state.theme].method()
		end
	end
	-- world setrooms
	if HD_ROOMOBJECT.WORLDS[state.theme].setRooms ~= nil then
		level_generation_method_setrooms(HD_ROOMOBJECT.WORLDS[state.theme].setRooms, prePath)
	end
	if (
		HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
		HD_ROOMOBJECT.WORLDS[state.theme].rowfive.setRooms ~= nil
	) then
		level_generation_method_setrooms_rowfive(HD_ROOMOBJECT.WORLDS[state.theme].rowfive.setRooms, prePath)
	end
	
	-- feeling structures
	for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
		if feelingslib.feeling_check(feeling) == true then
			if (feelingContent.prePath == nil and prePath == false) or (feelingContent.prePath ~= nil and feelingContent.prePath == prePath) then
				if feelingContent.method ~= nil then
					-- message("gen_levelrooms_nonpath: Executing feeling spawning method:")
					feelingContent.method()
				end
			end
			if feelingContent.setRooms ~= nil then
				level_generation_method_setrooms(feelingContent.setRooms, prePath)
			end
			if (
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.setRooms ~= nil
			) then
				level_generation_method_setrooms_rowfive(feelingContent.rowfive.setRooms, prePath)
			end
		end
	end

-- # TODO: Coffin Unlock Methods inside of the methods above
-- # TODO: Other Coffin Unlock Methods
--[[
	to right or left of path:
		- world unlock coffins
		- Mothership coffin
		- Yetikingdom
	top room, random x coord:
		- Olmec
	11th room down, replace path room at random x coord:
		- Worm
	top room, leftmost or rightmost:
		- COG
	replace specific roomid(s):
		- Spiderlair
		- Haunted Castle
		- Rushing Water
	middle two rows, replace path_drop or path_notop_drop:
		- Tikivillage
	replace shop:
		- Black Market
--]]
end

-- Edits to the levelcode
function gen_levelcode_fill()
	levelcode_chunks()
	levelcode_chunks(true)
end
 
function levelcode_chunks(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #global_levelassembly.modification.rowfive.levelrooms
	end
	
	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end

	for levelcode_yi = 1, c_hi_len, 1 do
		for levelcode_xi = 1, c_wi_len, 1 do
			local tilename = global_levelassembly.modification.levelcode[levelcode_yi][levelcode_xi]
			if rowfive == true then
				tilename = global_levelassembly.modification.rowfive.levelcode[levelcode_yi][levelcode_xi]
			end

			if genlib.HD_OBSTACLEBLOCK_TILENAME[tilename] ~= nil then
				chunkcodes = nil

				--[[
					CHUNK CODES
				--]]
				-- worlds
				if (
					HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename] ~= nil
				) then
					chunkcodes = HD_ROOMOBJECT.WORLDS[state.theme].obstacleBlocks[tilename]
				elseif genlib.HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes ~= nil then
					chunkcodes = genlib.HD_OBSTACLEBLOCK_TILENAME[tilename].chunkcodes
				end
				-- feelings
				for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.obstacleBlocks ~= nil and
						feelingContent.obstacleBlocks[tilename] ~= nil
					) then
						chunkcodes = feelingContent.obstacleBlocks[tilename]
					end
				end

				--[[
					CHUNK RULES
				--]]
				-- worlds
				chunkpool_rand_index = (
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename] ~= nil
				) and HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.obstacleBlocks[tilename]() or math.random(#chunkcodes)
				-- feelings
				for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.chunkRules ~= nil and
						feelingContent.chunkRules.obstacleBlocks ~= nil and
						feelingContent.chunkRules.obstacleBlocks[tilename] ~= nil
					) then
						chunkpool_rand_index = feelingContent.chunkRules.obstacleBlocks[tilename]()
					end
				end
	
				if chunkcodes ~= nil then
					c_dim_h, c_dim_w = genlib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[1], genlib.HD_OBSTACLEBLOCK_TILENAME[tilename].dim[2]
					if rowfive == true then
						levelcode_inject_rowfive(chunkcodes, c_dim_h, c_dim_w, levelcode_yi, levelcode_xi, chunkpool_rand_index)
					else
						levelcode_inject(chunkcodes, c_dim_h, c_dim_w, levelcode_yi, levelcode_xi, chunkpool_rand_index)
					end
				else
					message("levelcode_chunks: No chunkcodes available for tilename \"" .. tilename .. "\";")
				end
			end
		end
	end
end

function gen_levelcode_phase_1(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = HD_TILENAME[_tilechar], HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_1 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_1.default ~= nil then
						entity_type_pool = hd_tiletype.phase_1.default
					end
					if (
						hd_tiletype.phase_1.alternate ~= nil and
						hd_tiletype.phase_1.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_1.alternate[state.theme]
					elseif (
						hd_tiletype.phase_1.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_1.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = HD_TILENAME["w"]
					-- 	end
						
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end

function gen_levelcode_phase_2(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #global_levelassembly.modification.rowfive.levelrooms
	end

	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end


	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_2 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_2.default ~= nil then
						entity_type_pool = hd_tiletype.phase_2.default
					end
					if (
						hd_tiletype.phase_2.alternate ~= nil and
						hd_tiletype.phase_2.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_2.alternate[state.theme]
					elseif (
						hd_tiletype.phase_2.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_2.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
				end
			end
			x = x + 1
		end
		y = y - 1
	end
end


function gen_levelcode_phase_3(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = HD_TILENAME[_tilechar], HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_3 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_3.default ~= nil then
						entity_type_pool = hd_tiletype.phase_3.default
					end
					if (
						hd_tiletype.phase_3.alternate ~= nil and
						hd_tiletype.phase_3.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_3.alternate[state.theme]
					elseif (
						hd_tiletype.phase_3.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_3.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = HD_TILENAME["w"]
					-- 	end
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end


function gen_levelcode_phase_4(rowfive)
	rowfive = rowfive or false
	local levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	if rowfive == true then
		levelw = #global_levelassembly.modification.rowfive.levelrooms
	end
	
	local _sx, _sy = locatelib.locate_game_corner_position_from_levelrooms_position(1, 1) -- game coordinates of the topleft-most tile of the level
	local offsetx, offsety = 0, 0
	if rowfive == true then
		offsety = (
			HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive ~= nil and
			HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety ~= nil
		) and HD_ROOMOBJECT.WORLDS[state.theme].rowfive.offsety or -(levelh*CONST.ROOM_HEIGHT)
		local check_feeling_content = nil
		for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
			if (
				feelingslib.feeling_check(feeling) == true and
				feelingContent.rowfive ~= nil and
				feelingContent.rowfive.offsety ~= nil
			) then
				check_feeling_content = feelingContent.rowfive.offsety
			end
		end
		if check_feeling_content ~= nil then
			offsety = check_feeling_content
		end
	end
	-- if rowfive == true then
	-- 	message("rowfive y location: " .. tostring(_sy + offsety))
	-- end

	local c_hi_len = levelh*CONST.ROOM_HEIGHT
	local c_wi_len = levelw*CONST.ROOM_WIDTH
	if rowfive == true then
		c_hi_len = CONST.ROOM_HEIGHT
	end
	y = _sy + offsety
	for level_hi = 1, c_hi_len, 1 do
		x = _sx + offsetx
		for level_wi = 1, c_wi_len, 1 do
			_tilechar = global_levelassembly.modification.levelcode[level_hi][level_wi]
			if rowfive == true then
				_tilechar = global_levelassembly.modification.rowfive.levelcode[level_hi][level_wi]
			end
			hd_tiletype = HD_TILENAME[_tilechar]
			-- hd_tiletype, hd_tiletype_post = HD_TILENAME[_tilechar], HD_TILENAME[_tilechar]
			if hd_tiletype ~= nil and hd_tiletype.phase_4 ~= nil then
				if (
					options.hd_debug_scripted_levelgen_tilecodes_blacklist == nil or
					(
						options.hd_debug_scripted_levelgen_tilecodes_blacklist ~= nil and
						string.find(options.hd_debug_scripted_levelgen_tilecodes_blacklist, _tilechar) == nil
					)
				) then
					entity_type_pool = {}
					entity_type = 0
					if hd_tiletype.phase_4.default ~= nil then
						entity_type_pool = hd_tiletype.phase_4.default
					end
					if (
						hd_tiletype.phase_4.alternate ~= nil and
						hd_tiletype.phase_4.alternate[state.theme] ~= nil
					) then
						entity_type_pool = hd_tiletype.phase_4.alternate[state.theme]
					elseif (
						hd_tiletype.phase_4.tutorial ~= nil and
						worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TUTORIAL
					) then
						entity_type_pool = hd_tiletype.phase_4.tutorial
					end
					
					if #entity_type_pool > 0 then
						entity_type = commonlib.TableRandomElement(entity_type_pool)(x, y, LAYER.FRONT)
					end
					-- entType_is_liquid = (
					-- 	entity_type == ENT_TYPE.LIQUID_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_COARSE_WATER or
					-- 	entity_type == ENT_TYPE.LIQUID_IMPOSTOR_LAKE or
					-- 	entity_type == ENT_TYPE.LIQUID_LAVA or
					-- 	entity_type == ENT_TYPE.LIQUID_STAGNANT_LAVA
					-- )
					-- if entity_type == 0 then
					-- 	hd_tiletype_post = HD_TILENAME["0"]
					-- else
					-- 	if entity_type == ENT_TYPE.FLOOR_GENERIC then hd_tiletype_post = HD_TILENAME["1"]
					-- 	elseif entType_is_liquid then hd_tiletype_post = HD_TILENAME["w"]
					-- 	end
					-- end
				end
			end

			x = x + 1
		end
		y = y - 1
	end
end

-- the right side is blocked if:
function detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the right goes off of the path
		wi+1 > maxw
		or
		-- the space to the right has already been filled with a number
		path[hi][wi+1] ~= nil
	)
end

-- the left side is blocked
function detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space to the left goes off of the path
		wi-1 < minw
		or
		-- the space to the left has already been filled with a number
		path[hi][wi-1] ~= nil
	)
end

-- the under side is blocked
function detect_sideblocked_under(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space under goes off of the path
		hi+1 > maxh
		or
		-- the space under has already been filled with a number
		path[hi+1][wi] ~= nil
	)
end

-- the top side is blocked
function detect_sideblocked_top(path, wi, hi, minw, minh, maxw, maxh)
	return (
		-- the space above goes off of the path
		hi-1 < minh
		or
		-- the space above has already been filled with a number
		path[hi-1][wi] ~= nil
	)
end

-- both sides blocked off
function detect_sideblocked_both(path, wi, hi, minw, minh, maxw, maxh)
	return (
		detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh) and 
		detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh)
	)
end

-- both sides blocked off
function detect_sideblocked_neither(path, wi, hi, minw, minh, maxw, maxh)
	return (
		(false == detect_sideblocked_left(path, wi, hi, minw, minh, maxw, maxh)) and 
		(false == detect_sideblocked_right(path, wi, hi, minw, minh, maxw, maxh))
	)
end

-- Parameters
	-- spread
		-- forces the level to zig-zag from one side of the level to the other, only dropping upon reaching each side
		-- UPDATE: Turns out TikiVillage ended up never needing this *shrug*
	-- Reverse path
		-- swaps s2 exit/entrance codes:
			-- 5,6 = 7,8
			-- 7,8 = 5,6
		-- used for mothership level
function gen_levelrooms_path()
	-- spread = false
	reverse_path = (state.theme == THEME.NEO_BABYLON)

	levelw, levelh = #global_levelassembly.modification.levelrooms[1], #global_levelassembly.modification.levelrooms
	minw, minh, maxw, maxh = 1, 1, levelw, levelh
	-- message("levelw, levelh: " .. tostring(levelw) .. ", " .. tostring(levelh))

	-- build an array of unoccupied spaces to start winding downwards from
	rand_startindexes = {}
	for i = 1, levelw, 1 do
		if global_levelassembly.modification.levelrooms[1][i] == nil then
			rand_startindexes[#rand_startindexes+1] = i
		end
	end	
	
	assigned_exit = false
	assigned_entrance = false
	wi, hi = rand_startindexes[math.random(1, #rand_startindexes)], 1
	dropping = false

	-- don't spawn paths if roomcodes aren't available
	if HD_ROOMOBJECT.WORLDS[state.theme] == nil or
	(HD_ROOMOBJECT.WORLDS[state.theme] ~= nil and HD_ROOMOBJECT.WORLDS[state.theme].rooms == nil) then
		-- message("level_createpath: No pathRooms available in HD_ROOMOBJECT.WORLDS;")
	else
		while assigned_exit == false do
			pathid = math.random(2)
			ind_off_x, ind_off_y = 0, 0
			if (
				(
					-- num == 2 and
					detect_sideblocked_under(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh)
				)
				-- or spread == true
			) then
				pathid = genlib.HD_SUBCHUNKID.PATH
			end
			if pathid == genlib.HD_SUBCHUNKID.PATH then
				dir = 0
				if detect_sideblocked_both(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					pathid = genlib.HD_SUBCHUNKID.PATH_DROP
				elseif detect_sideblocked_neither(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					dir = (math.random(2) == 2) and 1 or -1
				else
					if detect_sideblocked_right(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
						dir = -1
					elseif detect_sideblocked_left(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
						dir = 1
					end
				end
				ind_off_x = dir
			end
			
			if pathid == genlib.HD_SUBCHUNKID.PATH and dropping == true then
				pathid = genlib.HD_SUBCHUNKID.PATH_NOTOP
				dropping = false
			end
			if pathid == genlib.HD_SUBCHUNKID.PATH_DROP then
				ind_off_y = 1
				if dropping == true then
					pathid = genlib.HD_SUBCHUNKID.PATH_DROP_NOTOP
				end
				dropping = true
			end
			if assigned_entrance == false then
				if pathid == genlib.HD_SUBCHUNKID.PATH_DROP then
					pathid = genlib.HD_SUBCHUNKID.ENTRANCE_DROP
					if reverse_path == true then
						pathid = genlib.HD_SUBCHUNKID.EXIT_NOTOP
					end
				else
					pathid = genlib.HD_SUBCHUNKID.ENTRANCE
					if reverse_path == true then
						pathid = genlib.HD_SUBCHUNKID.EXIT
					end
				end
				assigned_entrance = true
			elseif hi == maxh then
				if detect_sideblocked_both(global_levelassembly.modification.levelrooms, wi, hi, minw, minh, maxw, maxh) then
					assigned_exit = true
				else
					assigned_exit = (math.random(2) == 2)
				end
				if assigned_exit == true then
					if pathid == genlib.HD_SUBCHUNKID.PATH_NOTOP then
						pathid = genlib.HD_SUBCHUNKID.EXIT_NOTOP
						if reverse_path == true then
							pathid = genlib.HD_SUBCHUNKID.ENTRANCE_DROP
						end
					else
						pathid = genlib.HD_SUBCHUNKID.EXIT
						if reverse_path == true then
							pathid = genlib.HD_SUBCHUNKID.ENTRANCE
						end
					end
				end
			end
			global_levelassembly.modification.levelrooms[hi][wi] = pathid
			
			
			--[[
				ROOM CODES
			--]]
			-- worlds
			chunkcodes = (
				HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid] ~= nil
			) and HD_ROOMOBJECT.WORLDS[state.theme].rooms[pathid]
			-- feelings
			check_feeling_content = nil
			-- feelings
			for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
				if (
					feelingslib.feeling_check(feeling) == true and
					feelingContent.rooms ~= nil and
					feelingContent.rooms[pathid] ~= nil
				) then
					check_feeling_content = feelingContent.rooms[pathid]
				end
			end
			if check_feeling_content ~= nil then
				chunkcodes = check_feeling_content
			end

			if (
				chunkcodes ~= nil
			) then
				
				specified_index = math.random(#chunkcodes)
				if (
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms ~= nil and
					HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid] ~= nil
				) then
					specified_index = HD_ROOMOBJECT.WORLDS[state.theme].chunkRules.rooms[pathid]()
				end
				check_feeling_content = nil
				for feeling, feelingContent in pairs(HD_ROOMOBJECT.FEELINGS) do
					if (
						feelingslib.feeling_check(feeling) == true and
						feelingContent.chunkRules ~= nil and
						feelingContent.chunkRules.rooms ~= nil and
						feelingContent.chunkRules.rooms[pathid] ~= nil
					) then
						check_feeling_content = feelingContent.chunkRules.rooms[pathid]()
					end
				end
				if check_feeling_content ~= nil then
					specified_index = check_feeling_content
				end

				levelcode_inject_roomcode(
					pathid,
					chunkcodes,
					hi, wi,
					-- rules
					specified_index
				)
			-- else
			-- 	message("levelcreation_setlevelcode_path: No roomcode/num available! - num: " .. num .. "; hi, wi: " .. hi .. ", " .. wi .. ";")
			end

			if assigned_exit == false then -- preserve final coordinates for bugtesting purposes
				wi, hi = (wi+ind_off_x), (hi+ind_off_y)
			end
		end
	end
end


-- SHOPS
-- Hiredhand shops have 1-3 hiredhands
-- Damzel for sale: The price for a kiss will be $8000 in The Mines, and it will increase by $2000 every area, so the prices will be $8000, $10000, $12000 and $14000 for a Damsel kiss in the four areas shops can spawn in. The price for buying the Damsel will be an extra 50% over the kiss price, making the prices $12000, $15000, $18000 and $21000 for all zones.
-- If custom shop generation ever becomes possible:
	-- Determine item pool, allow enabling certain S2 specific items with register_option_bool()
	

-- Wheel Gambling Ideas:
-- Detect purchasing from the game when the player loses 5k and stands right next to a machine
-- You can set flag 20 to turn the machine back on. it just doesn't show a buy dialog but works
-- Hide the dice, without dice it just crashes. you can set its alpha/size to 0 and make it immovable, probably
-- The wheel visuals/spinning:
-- It's most likely doable using the empty item sprites
-- Just have a few immovable objects that rotate and are upscaled :0
-- You could just use a few empty subimages in the items.png file and assign anything else to that frame

-- JUNGLE
-- ENEMIES:
-- Giant Frog
-- - While moving left or right(?), make it "hop" using velocity.
--   - on jump, add velocity up and to the direction it's facing.
-- LEVEL:
-- Haunted level: Spawn tusk idol, make it add a ghost upon disturbing it
--  - (It adds a ghost if the ghost is already spawned. Not sure if 2:30 ghost spawns if skull idol is already tripped)
-- ENT_TYPE_DECORATION_VLAD above alter? Or other banner, idk
-- Black Knight: Cloned shopkeeper with a sheild+extra health.
-- Green Knight: Tikiman/Caveman with extra health.


-- WORM LEVEL
-- ENEMIES:
-- Egg Sack - Replace maggots with 1hp cave mole
-- Bacterium - Maze navigating algorithm run through an array tracking each.
-- If entered from jungle, spawn tikimen, cavemen, monkeys, frogs, firefrogs, bats, and snails.
-- If entered from icecaves, spawn UFOs, Yetis, and bats.

-- ICE_CAVES
-- ENEMIES:
-- Mammoth - Use an enemy that never agros and paces between ledges. Store a bool to fire icebeam on stopping its idle walking cycle.
--  - If runs into player while frozen, kill/damage player.
-- Snowball
	-- once it hits something (has a victim?), revert animation_frame and remove uid from danger_tracker.

-- TEMPLE
-- ENEMIES:
-- Hawk man: Shopkeeper clone without shotgun (Or non teleporting Croc Man???)

-- LEVEL:
-- Script in hell door spawning
-- The Book of the Dead on the player's HUD will writhe faster the closer the player is to the X-coordinate of the entrance (HELL_X)
-- 

-- SCRIPTED ROOMCODE GENERATION
	-- IDEAS:
		-- In a 2d list loop for each room to replace:
			-- 1: log a 2d table of the level path and rooms to replace
				-- 1: As you loop over each room:
					-- Log in separate 2d array `rooms_subchunkids`: Based on genlib.HD_SUBCHUNKID and whether the space contains a shopkeep, log subchunk ids as generated by the game.
						-- 0: Non-main path subchunk
						-- 1: Main path, goes L/R (also entrance/exit)
						-- 2: Main path, goes L/R and down (and up if it's below another 2)
						-- 3: Main path, goes L/R and up
						-- 1000: Shop (rename in the future?)
						-- 1001: Vault (rename in the future?)
						-- 1002: Kali (rename in the future?)
						-- 1003: Idol (rename in the future?)
				-- 2: Detect whether there's an exit. Without the exit, we can't move enemies. if there IS no exit, generate a new path with one or adjust the existing path to make one.
					-- UPDATE: May be possible to fix broken exit generation by preventing waddler's shop from spawning entirely.
					-- For instance, the ice caves can sometimes generate no exit on the 4th row.
					-- If no 1 subchunkid exists on the fourth row:
						-- if 2 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
						-- elseif 3 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
							-- replace 3 with 2, mark in `rooms_replaceids`
						-- elseif 1000 on the third row exists:
							-- add subchunk id 1 to the bottom row just below it.
							-- replace 3 with 2
								-- if vault, mark as 2 in `rooms_replaceids`
								-- elseif shop, mark as 3 in `rooms_replaceids`
				-- 3: Otherwise, here's where script-determined level paths would be managed
					-- For instance, given the chance to have a snake pit, adjust/replace the path with one that includes it.
				-- 4: Log in separate 2d array `rooms_replaceids`:
					-- if no roomcodes exist to replace the room:
						-- 0: Don't touch this room.
					-- if the room has in the path:
					-- 1: Replace this room.
					-- else:
						-- if it's vault, kali alter, or idol trap:
							-- 2: Maintain this room's structure and find a new place to move it to.
						-- if it's a shop:
							-- 3: Maintain this room's structure and find a new place to move it to. Maintain its orientation in relation to the path.
				-- 5: Log which rooms need to be flipped. loop over the path and log in separate 2d array `rooms_orientids`:
					-- if the subchunk id is not a 3:
						-- 0: Don't touch this room.
					-- if the replacement id is a 3:
						-- if the path id to the right of it is a 1, 2 or 3:
							-- 2: Facing right.
						-- if the path id to the left of it is a 1, 2 or 3:
							-- 3: Facing left.
			-- 2: Log uids of all overlapping enemies, move to exit
				-- Parameters
					-- optional table of ENT_TYPE
					-- Mask (default to any mask of 0x4)
				-- Method moves all found entities to the exit door and returns a table of their uids
				-- append each table into a 2d array based on the room they occupied
			-- 3: ???
			-- 4: Generate rooms, log generated rooms
				-- Parameters
					-- optional table of ENT_TYPE
					-- Path
				-- For rooms you replace, keep in mind:
					-- Checks to make sure killing/moving certain floors won't lead to problems, such as shops
						-- IDEA: TOTEST: If flag for shop floor is checked, uncheck it.
					-- Establish a system of methods/parameters for removing certain elements from rooms.
						-- Some scenarios:
							-- get_entities_overlapping() on LIQUID_WATER or LIQUID_LAVA to remove it, otherwise there'd be consequences.
						-- pushblocks/powderkegs, crates/goldbars, encrusted gems/items/goldbits/cavemen(?)
						-- Theme specific entities:
							-- falling platforms
						-- S2 Level feeling-specific entities:
							-- Restless:
								-- remove fog effect, music(? is that possible?)
								-- replace FLOOR_TOMB with normal
								-- remove restless-specific enemies
							-- Dark level: remove torches on rooms you replace
								-- Once all rooms to be replaced are replaced, place torches in those rooms.
				-- Determine roomcodes to use with global list constant (same way as LEVEL_DANGERS[state.theme]) and the current room
					-- global_feelings[*] overrides some or all rooms
				-- append each table into a 2d array based on the room they occupied
				-- for each room, process HD_TILENAME, spawn_entity()
					-- if (tilename == 2 or tilename == j) and math.random() >= 0.5
						-- spawn_entity()
						-- if tilename == 2
							-- mark as 1
						-- if tilename == j
							-- mark as i
					-- else
						-- mark as 0
				-- return into `postgen_roomcodes`
			-- 5: Once `rooms_roomcodes_postgen` is finished, gets baked into a full array of the characters
				-- `postgen_levelcode`
			-- 6: Move enemies from exit to designated rooms/custom spawning system
				-- Parameters
					-- `postgen_levelcode`
			-- 7: Final touchups. This MAY include level background details, ambient sounds.				
				-- If dark level, place torches in rooms you replaced earlier
					-- Once all rooms to be replaced are replaced, place torches in those rooms.
		-- Certain room constants may need to be recognized and marked for replacement. This includes:
			-- Tun rooms
				-- Constraints are ENT_TYPE.MONS_MERCHANT in the front layer
			-- Tun rooms
				-- Constraints are ENT_TYPE.MONS_THEIF in the front layer
			-- Shops and vaults in HELL
		-- Make the outline of a vault room tilecode `2` (50% chance to remove each outlining block)
		-- pass in tiles as nil to ignore.
			-- initialize an empty table t of size n: commonlib.setn(t, n)
		-- Black Market & Flooded Revamp:
			-- Replace S2 style black market with HD
				-- HD and S2 differences:
					-- S2 black market spawns are 2-2, 2-3, and 2-4
					-- HD spawns are 2-1, 2-2, and 2-3
						-- Prevents the black market from being accessed upon exiting the worm
						-- Gives room for the next level to load as black market
				-- script spawning LOGICAL_BLACKMARKET_DOOR
					-- if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET_ENTRANCE) == true
				-- In the roomcode generation, establish methods and parameters to make shop spawning possible
					-- Will need at least:
						-- 
				-- if detect_s2market() == true 
			-- Use S2 black market for flooded level feeling
				-- Set FLOODED: Detect when S2 black market spawns
					-- function onloading_setfeeling_load_flooded: roll HD_FEELING_FLOODED_CHANCE 4 times (or 3 if you're not going to try to extend the levels to allow S2 black market to spawn)
					-- for each roll: if true, return true
					-- if it returned true, set LOAD_FLOODED to true
						-- if detect_s2market() == true and LOAD_FLOODED == true, set HD_FEELING_FLOODED
			
	-- Roomcodes:
		-- Level Feelings:
			-- TIKI VILLAGE
				-- Notes:
					-- Tiki Village roomcodes never replace top (or bottom?) path
					-- Has no sideroom codes
					-- Unlockable coffin is always a path drop(?)
					-- Might(?) always generate with a zig-zag like path
				-- Roomcodes:
					-- 
			-- SNAKE PIT
				-- Notes:
					-- Doesn't have to link with main path
					-- I've seen it generate starting at the top level, idk about bottom
					-- Appears to occupy three side rooms vertically
				-- Ideas:
					-- Spawning conditions:
					-- If in dwelling and three side rooms vertically exist, have a random chance to replace them with snake pit.
				-- Roomcodes:
					--

-- bitwise notes:
-- print(3 & 5)  -- bitwise and
-- print(3 | 5)  -- bitwise or
-- print(3 ~ 5)  -- bitwise xor
-- print(7 >> 1) -- bitwise right shift
-- print(7 << 1) -- bitwise left shift
-- print(~7)     -- bitwise not

-- For mammoth behavior: If set, run it as a function: within the function, run a check on an array you pass in defining the `animation_frame`s you replace and the enemy you are having override its idle state.


-- # TODO: Implement system that reviews savedata to unlock coffins.
-- Some cases should be as simple as "If it's not unlocked yet, set this coffin to this character."
-- Other cases... well... involve filtering through multiple coffins in the same area,
-- giving a random character unlock, and level feeling specific unlocks.
-- Some may need to be enabled as unlocked from the beginning!

-- Character list: SUBJECT TO CHANGE.
-- - Decide whether original colors should be preserved, should we want to include reskins;
-- - (HD Little Jay = mint green; S2 Little Jay = Lime)
-- - Could just wing it and decide on case-by-case, ie, Roffy D Sloth -> PacoEspelanko
-- - But that may not make everyone happy; we want the mod to appeal to widest audience
-- - Heck, maybe we don't reskin any of them and leave it up to the users.
-- - But that's the problem, what coffins do we replace then...
-- - Maybe we make two versions: One to preserve HD's unlocks by color, and one for character equivalents

-- https://spelunky.fandom.com/wiki/Spelunkers
-- https://spelunky.fandom.com/wiki/Spelunky_2_Characters
-- ###HD EQUIVALENTS###
-- Spelunky Guy: 	Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_GUY_SPELUNKY
-- Solution:		Enable from the start via savedata.

-- Colin Northward:	Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_COLIN_NORTHWARD
-- Solution:		Already enabled(?)

-- Alto Singh:		Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_BANDA
-- Solution:		Enable from the start via savedata.

-- Liz Mutton:		Available from the beginning.
-- Replacement:		ENT_TYPE.CHAR_GREEN_GIRL
-- Solution:		Enable from the start via savedata.

-- Tina Flan:		Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.CHAR_TINA_FLAN
-- Solution:		No modifications necessary.

-- Lime:			Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.ROFFY_D_SLOTH
-- Solution:		RESKIN -> PacoEspelanko. https://spelunky.fyi/mods/m/pacoespelanko/

-- Margaret Tunnel:	Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.CHAR_MARGARET_TUNNEL
-- Solution:		IF NEEDED, lock from the start in savedata.

-- Cyan:			Random Coffin in one of the four areas, only one character can be found per area.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. https://spelunky.fyi/mods/m/cyan-from-hd/

-- Van Horsing:		Coffin at the top of the Haunted Castle level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. https://spelunky.fyi/mods/m/van-horsing-sprite-sheet-all-animations/

-- Jungle Warrior:	Defeat Olmec and get to the exit.
-- Replacement:		ENT_TYPE.CHAR_AMAZON
-- Solution:		No modifications necessary.

-- Meat Boy:		Dark green pod near the end of the Worm.
-- Replacement:		ENT_TYPE.CHAR_PILOT
-- Solution:		RESKIN -> Meat Boy. https://spelunky.fyi/mods/m/meat-boy-with-bandage-rope/

-- Yang:			Defeat King Yama and get to the exit.
-- Replacement:		ENT_TYPE.CHAR_CLASSIC_GUY
-- Solution:		RESKIN(?)

-- The Inuk:		Found inside a coffin in a Yeti Kingdom level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA.

-- The Round Girl:	Found inside a coffin in a Spider's Lair level.
-- Replacement:		ENT_TYPE.CHAR_VALERIE_CRUMP
-- Solution:		No modifications necessary.

-- Ninja:			Found inside a coffin in Olmec's Chamber.
-- Replacement:		ENT_TYPE.CHAR_DIRK_YAMAOKA
-- Solution:		No modifications necessary.

-- The Round Boy:	Found inside a coffin in a Tiki Village in the Jungle.
-- Replacement:		ENT_TYPE.OTAKU
-- Solution:		No modifications necessary.

-- Cyclops:			Can be bought from the Black Market for $10,000, or simply 'kidnapped'. May also be found in a coffin after seeing him in the Black Market.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA. S2 has a coffin in the black market.

-- Viking:			Found inside a coffin in a Flooded Cavern or "The Dead Are Restless" level.
-- Replacement:		ENT_TYPE.
-- Solution:		NO IDEA

-- Robot:			Found inside a capsule in the Mothership.
-- Replacement:		ENT_TYPE.CHAR_LISE_SYSTEM
-- Solution:		No modifications necessary.

-- Golden Monk:		Found inside a coffin in the City of Gold.
-- Replacement:		ENT_TYPE.CHAR_AU
-- Solution:		Literally no modifications necessary, maybe not even scripting anything.

-- ###UNDETERMINED###

-- Ana Spelunky:	ENT_TYPE.CHAR_ANA_SPELUNKY
-- Solution:		IF NEEDED, lock from the start in savedata.

-- Princess Airyn:	ENT_TYPE.CHAR_PRINCESS_AIRYN
-- Solution:		NO IDEA

-- Manfred Tunnel:	ENT_TYPE.CHAR_MANFRED_TUNNEL
-- Solution:		NO IDEA

-- Coco Von Diamonds:	ENT_TYPE.CHAR_COCO_VON_DIAMONDS
-- Solution:		NO IDEA

-- Demi Von Diamonds:	ENT_TYPE.CHAR_DEMI_VON_DIAMONDS
-- Solution:		

-- IDEA: Black Market unlock
-- if character hasn't been unlocked yet:
	-- if `blackmarket_char_witnessed` == false:
		--`blackmarket_char_witnessed` = true
		-- Have him up for sale in the black market
			-- if purchased or shopkeeprs agrod:
				-- unlock character
	-- if `blackmarket_char_witnessed` == true:
		-- found in coffin elsewhere (where?)

-- BORDERS
-- use https://spelunky.fyi/mods/m/sample-mod-custom-in-engine-textures/?c=2366
-- to replace border textures for:
	-- The Worm
	-- Hell (Volcana)
-- Reskin textures for:
	-- Tiamat (as Hell)
