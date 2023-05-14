blackknightlib = require 'lib.entities.black_knight'
turretlib = require 'lib.entities.laser_turret'
spikeballlib = require 'lib.entities.spikeball_trap'
tombstonelib = require 'lib.entities.tombstone'
babywormlib = require 'lib.entities.baby_worm'
tikitraplib = require 'lib.entities.tikitrap'
feelingslib = require 'lib.feelings'
slidingwalllib = require 'lib.entities.sliding_wall'
local crysknifelib = require 'lib.entities.crysknife'
treelib = require 'lib.entities.tree'
spikeslib = require 'lib.entities.spikes'
local damsellib = require 'lib.entities.damsel'
local hell_minibosslib = require 'lib.entities.hell_miniboss'
local alienlordlib = require 'lib.entities.alienlord'
local idollib = require 'lib.entities.idol'
local kingboneslib = require 'lib.entities.kingbones'
local pushblocklib = require 'lib.entities.pushblock'
local idolplatformlib = require 'lib.entities.idol_platform'
local ladderlib = require 'lib.entities.ladder'
local succubuslib = require 'lib.entities.succubus'

local module = {}

optionslib.register_option_bool("hd_og_floorstyle_temple", "OG: Set temple's floorstyle to stone instead of temple", nil, false) -- Defaults to S2
optionslib.register_option_bool("hd_unused_iceblockempty", "Unused: Enable unused Iceblock/empty tiles", nil, false)

-- retains HD tilenames
module.HD_TILENAME = {
	["0"] = {
		description = "Empty",
	},
	["#"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l) end
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
			}
		},
		description = "TNT Box",
	},
	["$"] = {
		description = "Roulette Item",
	},
	["%"] = {
		description = "Roulette Door",
	},
	["&"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) createlib.create_liquidfall(x, y-2.5, l, "res/fountain_jungle.png") end,
				},
				alternate = {
					[THEME.CITY_OF_GOLD] = {
						function(x, y, l) createlib.create_liquidfall(x, y-3, l, "res/fountain_gold.png", true) end,
					},
					[THEME.TEMPLE] = {
						function(x, y, l) createlib.create_liquidfall(x, y-3, l, "res/fountain_temple.png", true) end,
					},
					[THEME.VOLCANA] = {
						function(x, y, l) createlib.create_liquidfall(x, y-3, l, "res/fountain_hell.png", true) end,
					},
				},
			}
		},
		description = "Waterfall",
	},
	["*"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spikeballlib.create_spikeball_trap(x, y, l) end,
				},
				alternate = {
					[THEME.NEO_BABYLON] = {
						function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PLASMACANNON, x, y, l) end,
					},
				},
			}
		},
		-- hd_type = hdtypelib.HD_ENT.TRAP_SPIKEBALL
		-- spawn method for plasma cannon in HD spawned a tile under it, stylized
		description = "Spikeball",
	},
	["+"] = {
		phases = {
			[1] = {
				default = { function(x, y, l) return 0 end },--ENT_TYPE.BG_LEVEL_BACKWALL},
				alternate = {
					[THEME.ICE_CAVES] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l) end,
					},
				},
			}
		},
		description = "Wooden Background",
	},
	[","] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l) end,
				},
			}
		},
		description = "Terrain/Wood",
	},
	["-"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_THINICE, x, y, l) end,},
			}
		},
		description = "Cracking Ice",
	},
	["."] = {
		-- S2 doesn't like spawning ANY floor in these places for some reason, so we're going to use S2 gen for this
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l))
						entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
					end,
				},
				alternate = {
					[THEME.TEMPLE] = {
						function(x, y, l)
							local entity = get_entity(spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l))
							entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
						end,
					}
				}
			}
		},
		description = "Unmodified Terrain",
	},
	["1"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,},
				alternate = {
					[THEME.DWELLING] = {
						function(x, y, l)
							local chance = 80
							local block_above = get_grid_entity_at(x, y+1, l)
							local block_left = get_grid_entity_at(x-1, y, l)
							local to_spawn = ENT_TYPE.FLOOR_GENERIC
							if (--block above is ground or is not a woodblock
								block_above == -1
								or (block_above ~= -1 and commonlib.has({ENT_TYPE.FLOOR_GENERIC}, get_entity(block_above).type.id))
							) then
								if ( --(block left is not ground and is a woodblock) or (block right is not ground and is a woodblock)
								block_left ~= -1 and commonlib.has({ENT_TYPE.FLOORSTYLED_MINEWOOD}, get_entity(block_left).type.id)
								) then
									chance = 3
								end
							else
								chance = 2
							end
							if (math.random(chance) == 1) then
								to_spawn = ENT_TYPE.FLOORSTYLED_MINEWOOD
							end
							spawn_grid_entity(to_spawn, x, y, l)
						end
					},
					[THEME.EGGPLANT_WORLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l) end,},
					[THEME.ICE_CAVES] = {
						function(x, y, l)
							if (
								feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM)
							) then
								if (math.random(6) == 1) then
									spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
								else
									spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l)
								end
							else
								spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
							end
						end,
					},
					[THEME.NEO_BABYLON] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l) end,},
					[THEME.OLMEC] = {function(x, y, l) spawn_grid_entity((math.random(80) == 1) and ENT_TYPE.FLOOR_JUNGLE or ENT_TYPE.FLOORSTYLED_STONE, x, y, l) end,},
					[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity((math.random(80) == 1) and ENT_TYPE.FLOOR_JUNGLE or (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l) end,},
					[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l) end,},
				},
			}
		},
		description = "Terrain",
	},
	["2"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,
					function(x, y, l) return 0 end,
				},
				alternate = {
					[THEME.EGGPLANT_WORLD] = {
						function(x, y, l)
							if math.random(2) == 1 then
								if math.random(10) == 1 then
									createlib.create_regenblock(x, y, l)
								else
									spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l)
								end
							else return 0 end
						end,
					},
					[THEME.ICE_CAVES] = {
						function(x, y, l)
							if math.random(2) == 1 then
								if math.random(10) == 1 then
									spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l)
								else
									spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
								end
							else return 0 end
						end,
					},
					[THEME.NEO_BABYLON] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MOTHERSHIP, x, y, l) end,
						function(x, y, l) return 0 end,
					},
					[THEME.OLMEC] = {
						function(x, y, l)
							spawn_grid_entity((math.random(80) == 1) and ENT_TYPE.FLOOR_JUNGLE or ENT_TYPE.FLOORSTYLED_STONE, x, y, l)
						end,
						function(x, y, l) return 0 end,
					},
					[THEME.TEMPLE] = {
						function(x, y, l)
							spawn_grid_entity((math.random(80) == 1) and ENT_TYPE.FLOOR_JUNGLE or (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l)
						end,
						function(x, y, l) return 0 end,
					},
					[THEME.CITY_OF_GOLD] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l) end,
						function(x, y, l) return 0 end,
					},
				},
			}
		},
		description = "Terrain/Empty",
	},
	["3"] = {
		phases = {
			[3] = {
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
			[1] = {
				default = {
					function(x, y, l)
						local uid = spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
						-- get_entity(uid):fix_decorations(true, true)
					end,
					function(x, y, l)
					end,
				},
				alternate = {
					[THEME.EGGPLANT_WORLD] = {
						function(x, y, l)
							local uid = spawn_grid_entity(ENT_TYPE.FLOORSTYLED_GUTS, x, y, l)
							-- get_entity(uid):fix_decorations(true, true)
						end,
						function(x, y, l) return ENT_TYPE.LIQUID_WATER end,
					},
					[THEME.TEMPLE] = {
						function(x, y, l)
							local uid = spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l)
							-- get_entity(uid):fix_decorations(true, true)
						end,
						function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
					},
					[THEME.CITY_OF_GOLD] = {
						function(x, y, l)
							local uid = spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l)
							-- get_entity(uid):fix_decorations(true, true)
						end,
						function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
					},
					[THEME.VOLCANA] = {
						function(x, y, l)
							local uid = spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
							-- get_entity(uid):fix_decorations(true, true)
						end,
						function(x, y, l) return ENT_TYPE.LIQUID_LAVA end,
					},
				},
			},
		},
		description = "Terrain/Water",
	},
	["4"] = {
		phases = {
			[1] = {
				default = { pushblocklib.create_pushblock },
			}
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
		phases = {
			[2] = {
				default = {
					function(x, y, l)
						if math.random(3) == 1 then
							spikeslib.detect_floor_and_create_spikes(x, y, l)
						end
					end,
				},
			}
		},
		description = "Spikes/Empty",
	},
	["8"] = {
		description = "Door with Terrain Block",
	},
	["9"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						-- need subchunkid of what room we're in
						local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
						local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
						
						if (
							(_subchunk_id == roomdeflib.HD_SUBCHUNKID.ENTRANCE)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP)
						) then
							doorslib.create_door_entrance(x, y, l)
						elseif (_subchunk_id == roomdeflib.HD_SUBCHUNKID.YAMA_ENTRANCE) then
							doorslib.create_door_entrance(x+0.5, y, l)
						elseif (
							(_subchunk_id == roomdeflib.HD_SUBCHUNKID.EXIT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.EXIT_NOTOP)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.RUSHING_WATER_EXIT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.HAUNTEDCASTLE_EXIT_NOTOP)
						) then
							-- spawn an exit door to the next level. Spawn a shopkeeper if agro.
							doorslib.create_door_exit(x, y, l)
						elseif (_subchunk_id == roomdeflib.HD_SUBCHUNKID.MOTHERSHIPENTRANCE_TOP) then
							doorslib.create_door_exit_to_mothership(x, y, l)
						elseif (_subchunk_id == roomdeflib.HD_SUBCHUNKID.RESTLESS_TOMB) then
							tombstonelib.create_tombstone_king(x, y, l)
							kingboneslib.create_kingbones(x, y-2, l)
							doorslib.create_door_exit_to_hauntedcastle(x, y-4, l)
						elseif (_subchunk_id == roomdeflib.HD_SUBCHUNKID.YAMA_EXIT) then
							doorslib.create_door_ending(x, y, l)
						end
					end
				},
			}
		},
		description = "Exit/Entrance/Special Door", -- old description: "Door without Platform"
	},
	[":"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCORPION, x, y, l) end,
				},
				alternate = {
					[THEME.JUNGLE] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_TIKIMAN, x, y, l) end,
						function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l) end,
					},
					[THEME.ICE_CAVES] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l) end,},
					[THEME.NEO_BABYLON] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l) end,
						function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l) end,
					}
				},
			}
		},
		description = "World-specific Enemy Spawn",
	},
	[";"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						damsellib.create_damsel(x, y, l)
						idollib.create_idol(x+1, y, l)
					end,
				},
				alternate = {
					-- force field spawning method, rows of 3.
					[THEME.ICE_CAVES] = {
						function(x, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x+1, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x+2, y, l)
						end,
					},
					[THEME.NEO_BABYLON] = {
						function(x, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x+1, y, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x+2, y, l)
						end,
					},
				}
			}
		},
		description = "Damsel and Idol from Kalipit",
	},
	["="] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l) end,},
				alternate = {
					[THEME.VOLCANA] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l) end,
					}
				},
			}
		},
		description = "Wood with Background",
	},
	["A"] = {
		phases = {
			[1] = {
				default = { idolplatformlib.create_idol_platform },
			}
		},
		description = "Idol Platform",
	},
	["B"] = {
		phases = {
			[1] = {
				default = {
					idollib.create_idoltrap_floor
				},
			}
		},
		description = "Jungle/Temple Idol Platform",
	},
	["C"] = {
		phases = {
			[1] = {
				default = {
					idollib.create_idoltrap_ceiling
				},
				alternate = {
					[THEME.VOLCANA] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l) end},
				},
			}
		},
		description = "Temple Idol Trap Ceiling Block",
	},
	["D"] = {
		phases = {
			[1] = {
				default = {function(x, y, l)
					slidingwalllib.spawn_slidingwall(x, y, l, true)
				end},
				tutorial = {
					function(x, y, l) damsellib.create_damsel(x, y, l) end,
				},
			}
		},
		description = "Door Gate",
	},
	["E"] = {
		phases = {
			[1] = {
				tutorial = {
					function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_GOLDBAR, x, y, l) end,
				},
				default = {
					function(x, y, l)
						if feelingslib.feeling_check(feelingslib.FEELING_ID.RUSHING_WATER) == true then
							if math.random(10) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CHEST, x, y, l)
							elseif math.random(5) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CRATE, x, y, l)
							elseif math.random(2) == 2 then
								spawn_entity_snapped_to_floor(ENT_TYPE.FLOOR_GENERIC, x, y, l)
							else
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CHEST, x, y, l)
							end
						else
							if math.random(15) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CHEST, x, y, l)
							elseif math.random(10) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CRATE, x, y, l)
							elseif math.random(12) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_RUBY, x, y, l)
							elseif math.random(10) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_GOLDBARS, x, y, l)
							elseif math.random(8) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_SAPPHIRE, x, y, l)
							elseif math.random(6) == 1 then
								spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_EMERALD, x, y, l)
							else
								local tile_to_spawn = ENT_TYPE.FLOOR_GENERIC
								if state.theme == THEME.OLMEC then
									tile_to_spawn = ENT_TYPE.FLOORSTYLED_STONE
								elseif state.theme == THEME.CITY_OF_GOLD then
									tile_to_spawn = ENT_TYPE.FLOORSTYLED_COG
								elseif state.theme == THEME.TEMPLE then
									tile_to_spawn = (options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE)
								end
								spawn_grid_entity(tile_to_spawn, x, y, l)
							end
						end
					end,
					-- function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,
					-- function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l) end,
					-- function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l) end,
					-- function(x, y, l) return 0 end,
				},
				-- alternate = {
				-- 	[THEME.OLMEC] = {
				-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l) end,
				-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l) end,
				-- 		function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l) end,
				-- 		function(x, y, l) return 0 end,
				-- 	},
				-- [THEME.TEMPLE] = {
				-- 	function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l) end,
				-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l) end,
				-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l) end,
				-- 	function(x, y, l) return 0 end,
				-- },
				-- [THEME.CITY_OF_GOLD] = {
				-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l) end,
				-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l) end,
				-- 	function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l) end,
				-- 	function(x, y, l) return 0 end,
				-- },
				-- },
			}
		},
		description = "Terrain/Empty/Crate/Chest",
	},
	["F"] = {
		description = "Falling Platform Obstacle Block",
	},
	["G"] = {
		phases = {
			[1] = {
				default = { ladderlib.create_ladder },
			}
		},
		description = "Ladder (Strict)",
	},
	["H"] = {
		phases = {
			[1] = {
				default = { ladderlib.create_ladder_platform },
			}
		},
		description = "Ladder Platform (Strict)",
	},
	["I"] = {
		phases = {
			[2] = {
				default = {
					function(x, y, l)
						-- Idol trap variants
						if state.theme == THEME.DWELLING then
							spawn_entity(ENT_TYPE.BG_BOULDER_STATUE, x+0.5, y+2.5, l, 0, 0)
						end
						
						-- need subchunkid of what room we're in
						local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
						local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
						
						if (
							(_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT)
						) then
							tikitraplib.create_tikitrap(x, y, l)
						elseif (
							(_subchunk_id == roomdeflib.HD_SUBCHUNKID.YAMA_SETROOM_3_2)
							-- or (_subchunk_id == genlib.HD_SUBCHUNKID.YAMA_SETROOM_3_3)
						) then
							for i = 0, 10, 2 do
								local uid = tikitraplib.create_tikitrap(x, y+i, l)
								-- uid = get_entities_at(ENT_TYPE.FLOOR_TRAP_TOTEM, 0, x, y+i, l, .5)[1]
								if uid ~= -1 then
									get_entity(uid).animation_frame = 12
								end
							end
							for i = 0, 10, 2 do
								local uid = tikitraplib.create_tikitrap(x+7, y+i, l)
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
			[1] = {
				default = {
					function(x, y, l)
						-- need subchunkid of what room we're in
						local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
						local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
						
						if (
							(_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_RIGHT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_UNLOCK_LEFT)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.YAMA_SETROOM_3_2)
							or (_subchunk_id == roomdeflib.HD_SUBCHUNKID.YAMA_SETROOM_3_3)
						) then
							-- SORRY NOTHING 
						else
							idollib.create_idol(x+0.5, y, l)
						end
					end,
				},
			}
		},
		description = "Idol", -- sometimes a tikitrap if it's a character unlock
	},
	["J"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_entity(ENT_TYPE.MONS_GIANTFISH, x, y, l, 0, 0) end,
				},
			}
		},
		description = "Ol' Bitey",
	},
	["K"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_entity(ENT_TYPE.MONS_SHOPKEEPER, x, y, l, 0, 0) end,
				},
			}
		},
		description = "Shopkeeper",
	},
	["L"] = {
		-- phase_4 = {
		-- 	alternate = {
		-- 		[THEME.NEO_BABYLON] = {
		-- 			function(x, y, l)
		-- 				spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_SHIELD, x, y, l)
		-- 				return 0
		-- 			end,
		-- 		},
		-- 	}
		-- },
		phases = {
			[3] = {
				alternate = {
					[THEME.VOLCANA] = { ladderlib.create_ceiling_chain },
				}
			},
			[2] = {
				alternate = {
					[THEME.VOLCANA] = {
						function(x, y, l) return 0 end,
					},
				}
			},
			[1] = {
				default = { ladderlib.create_ladder },
				alternate = {
					[THEME.JUNGLE] = { ladderlib.create_vine },
					[THEME.EGGPLANT_WORLD] = { ladderlib.create_vine },
					[THEME.NEO_BABYLON] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_TIMED_FORCEFIELD, x, y, l) end,
					},
					[THEME.VOLCANA] = {function(x, y, l) return 0 end},
					[THEME.CITY_OF_GOLD] = { ladderlib.create_ladder_gold },
				},
			}
		},
		description = "Ladder", -- sometimes used as Vine or Chain
	},
	["M"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						embedlib.embed_item(ENT_TYPE.ITEM_MATTOCK, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l), 128)
					end,
				},
				alternate = {
					[THEME.ICE_CAVES] = {
						function(x, y, l)
							embedlib.embed_item(ENT_TYPE.ITEM_JETPACK, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l), 41)
						end
					},
				}
			}
		},
		description = "World-Specific Crust Item", --"Crust Mattock from Snake Pit",
	},
	["N"] = {
		phases = {
			[1] = {
				tutorial = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l) end,},
				default = {
					function(x, y, l)
						if math.random(4) == 1 then
							spawn_grid_entity(ENT_TYPE.MONS_COBRA, x, y, l)
						else
							spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l)
						end
					end,
				},
				alternate = {
					[THEME.JUNGLE] = {
						function(x, y, l) spawn_entity(ENT_TYPE.ITEM_LITWALLTORCH, x, y, l, 0, 0) end,
					}
				}
			}
		},
		description = "Snake from Snake Pit",
	},
	["O"] = {
		phases = {
			[3] = {
				default = {
					function(x, y, l)
						local moai_texture_indices = { 0, 1, 8, 9, 16, 17, 24, 25, 32 } -- yada yada lazy programming yada yada
						local moai_index = 1
						for yi = 0, -3, -1 do
							for xi = 0, 2, 1 do
								if (yi ~= 0 and xi == 1) then
									-- SORRY NOTHING
								else
									local block_uid = get_grid_entity_at(x+xi, y+yi, l)
									if block_uid ~= -1 then
										local moai_block = get_entity(block_uid)
										moai_block:set_texture(moailib.MOAI_BORDER_MAIN_TEXTURE)
										moai_block.animation_frame = moai_texture_indices[moai_index]
										moai_block:set_draw_depth(get_type(ENT_TYPE.FLOOR_GENERIC).draw_depth)
										moai_index = moai_index + 1
									end
								end
							end
						end
					end
				}
			},
			[1] = {
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
									spawn_grid_entity(ENT_TYPE.FLOOR_BORDERTILE_METAL, x+xi, y+yi, l)
								end
							end
						end
						doorslib.create_door_exit_moai(x+1, y-3, l)
						moailib.create_moai_veil(x, y, l)
					end,
				},
			},
		},
		description = "Moai Head",
	},
	["P"] = {
		phases = {
			[1] = {
				default = { ladderlib.create_ladder_platform },
				alternate = {
					[THEME.CITY_OF_GOLD] = { ladderlib.create_ladder_platform_gold },
				}
			}
		},
		description = "Ladder Platform (Strict)",
	},
	["Q"] = {
		phases = {
			[3] = {
				alternate = {
					[THEME.VOLCANA] = { ladderlib.create_growable_ceiling_chain },
				}
			},
			[1] = {
				default = { ladderlib.create_growable_vine },
				alternate = {
					[THEME.NEO_BABYLON] = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_ALIENQUEEN, x, y, l, 0, 0) end,},
					[THEME.VOLCANA] = {function(x, y, l) return 0 end},
				},
			},
		},
		description = "Variable-Length Ladder/Vine",
	},
	["R"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_RUBY, x, y, l) end,},
			}
		},
		description = "Ruby from Snakepit",
	},
	["S"] = {
		description = "Shop Items",
	},
	["T"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						treelib.create_hd_tree(x, y, l)
					end,
				},
			}
		},

		description = "Tree",
	},
	["U"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_VLAD, x+.5, y, l, 0, 0) end,},
				alternate = {
					-- Black Knight
					[THEME.JUNGLE] = {function(x, y, l)
						blackknightlib.create_black_knight(x, y, l)
					end},
				}
			}
		},
		description = "Vlad/Black Knight",
	},
	["V"] = {
		description = "Vines Obstacle Block",
	},
	["W"] = {
		description = "Wanted Poster",--"Unknown: Something Shop-Related",
	},
	["X"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_GIANTSPIDER, x+0.5, y, l, 0, 0) end,},
				alternate = {
					-- Alien Lord
					[THEME.ICE_CAVES] = {alienlordlib.create_alienlord},
					[THEME.NEO_BABYLON] = {alienlordlib.create_alienlord},
					-- Horse Head & Ox Face
					[THEME.VOLCANA] = {function(x, y, l)
						if x < 22 then
							hell_minibosslib.create_horsehead(x, y, l)
						else
							hell_minibosslib.create_oxface(x, y, l)
						end
					end},
				}
			}
		},
		description = "Giant Spider",
	},
	["Y"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_YETIKING, x, y, l, 0, 0) end,},
				alternate = {
					[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MUMMY, x, y, l) end,},
					[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MUMMY, x, y, l) end,},
					[THEME.VOLCANA] = {
						function(x, y, l) createlib.create_yama(x, y, l) end
					},
				},
			}
		},
		description = "Yeti King",
	},
	["Z"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l) end,},
			}
		},
		description = "Beehive Tile with Background",
	},
	["a"] = {
		--#TOTEST: Also used in tutorial:
			-- 2nd level, placement {4,2}.
			-- 3rd level, placement {1,2}.
		phases = {
			[1] = {
				default = {
					function(x, y, l) end,
				},
				tutorial = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_POT, x, y, l) end,},
			}
		},
		description = "Ankh/Pot",
	},
	["b"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l))
						entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
					end,
				},
			}
		},
		description = "Shop Floor",
	},
	["c"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) idollib.create_crystalskull(x+0.5, y, l) end,
				},
				alternate = {
					[THEME.EGGPLANT_WORLD] = {
						function(x, y, l)
							if (math.random(2) == 2) then
								x = x + 10
							end
							crysknifelib.create_crysknife(x, y, l)
						end
					},
				}
			}
		},
		description = "Crystal Skull",
	},
	["d"] = {
		-- HD may spawn this as wood at times. The solution is to replace that tilecode with "v"
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_JUNGLE, x, y, l) end,},
				alternate = {
					[THEME.EGGPLANT_WORLD] = {function(x, y, l) createlib.create_regenblock(x, y, l) end,},
				},
			}
		},
		description = "Jungle Terrain",
	},
	["e"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l) end,},
				tutorial = {
					function(x, y, l)
						set_contents(spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l), ENT_TYPE.ITEM_PICKUP_BOMBBAG)
					end,
				},
			}
		},
		description = "Beehive Tile",
	},
	["f"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, l) end,},
			}
		},
		description = "Falling Platform",
	},
	["g"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
						local _subchunk_id
						if roomgenlib.global_levelassembly.modification.levelrooms[roomy] ~= nil then
							_subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
						end
						local coffin_uid = nil
						if (
							_subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP
							or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP
							or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
							or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
						) then
							coffin_uid = createlib.create_coffin_coop(x+0.35, y, l)
						else
							coffin_uid = createlib.create_coffin_unlock(x+0.35, y, l)
						end
						if (
							coffin_uid ~= nil
							and (
								state.theme == THEME.EGGPLANT_WORLD
								or state.theme == THEME.NEO_BABYLON
							)
						) then
							local coffin_e = get_entity(coffin_uid)
							local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_COFFINS_0)
							if state.theme == THEME.EGGPLANT_WORLD then
								coffin_e.flags = set_flag(coffin_e.flags, ENT_FLAG.NO_GRAVITY)
								coffin_e.velocityx = 0
								coffin_e.velocityy = 0
								texture_def.texture_path = "res/coffin_worm.png"
							end
							if state.theme == THEME.NEO_BABYLON then
								texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_COFFINS_5)
							end
							coffin_e:set_texture(define_texture(texture_def))
						end
					end
				},
			}
		},
		description = "Coffin",
	},
	["h"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l) end,},
				tutorial = {
					function(x, y, l)
						set_contents(spawn_grid_entity(ENT_TYPE.ITEM_CRATE, x, y, l), ENT_TYPE.ITEM_PICKUP_ROPEPILE)
					end,
				},
				alternate = {
					[THEME.JUNGLE] = {
						function(x, y, l)
							local ent_uid = spawn_entity(ENT_TYPE.BG_BASECAMP_SHORTCUTSTATIONBANNER, x+4, y+2, l, 0, 0)
							local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_BASECAMP_3)
							texture_def.texture_path = "res/hauntedcastle_banner.png"
							get_entity(ent_uid):set_texture(define_texture(texture_def))
							
							ent_uid = spawn_entity(ENT_TYPE.BG_KALI_STATUE, x+.5, y+0.6, l, 0, 0)
							local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_DECO_JUNGLE_0)
							texture_def.texture_path = "res/hauntedcastle_deco.png"
							get_entity(ent_uid):set_texture(define_texture(texture_def))
							get_entity(ent_uid).width = 5.0--5.600
							get_entity(ent_uid).height = 5.0--7.000

							spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y-1, l)
							spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y-1, l)

							spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y, l)
							spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x-1, y-1, l)
							spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y, l)
							spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+2, y-1, l)
						end,
					}
				},
			}
		},
		description = "Vlad's Castle Brick",
	},
	["i"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l) end,},
				alternate = {
					[THEME.JUNGLE] = {
						function(x, y, l)
							spawn_entity_over(ENT_TYPE.ITEM_LAVAPOT, spawn_entity(ENT_TYPE.ITEM_COOKFIRE, x, y, l, 0, 0), 0, 0.675)
						end,
					}
				},
			}
		},
		description = "Ice Block",
	},
	["j"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						if (options.hd_unused_iceblockempty) then
							spawn_grid_entity(ENT_TYPE.FLOOR_ICE, x, y, l)
						else return 0 end
					end,
					function(x, y, l) return 0 end,
				},
			}
		},
		description = "Unused (In classic this was 'Ice Block/Empty'", -- Old description: "Ice Block with Caveman".
	},
	["k"] = { -- Sign creation currently done in S2 gen
		phases = {
			[1] = {
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
						-- _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
							
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
			}
		},
		description = "Shop Entrance Sign",
	},
	["l"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_LAMP, x, y, l) end,},
			}
		},
		description = "Shop Lantern",
	},
	["m"] = {
		phases = {
			[3] = {
				alternate = {
					[THEME.NEO_BABYLON] = {
						function(x, y, l)
							spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_ELEVATOR, x, y, l)
							-- need subchunkid of what room we're in
							local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
							local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
							
							if (
								(_subchunk_id == roomdeflib.HD_SUBCHUNKID.ENTRANCE_DROP)
							) then
								spawn_entity(ENT_TYPE.FLOOR_DOOR_PLATFORM, x, y-1, l, 0, 0)
							end
							return 0
						end,
					},
				}
			},
			[1] = {
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
		},
		description = "Unbreakable Terrain",
	},
	["n"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						if math.random(10) == 1 then
							spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l)
						elseif math.random(2) == 1 then
							spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l)
						else
							return 0
						end
					end,
				},
			}
		},
		description = "Terrain/Empty/Snake",
	},
	["o"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_ROCK, x, y, l) end,},
			}
		},
		description = "Rock",
	},
	["p"] = {
		-- Appears in corners of the crystal idol room and at the bottom of a few ladders outside in the notop_drop rooms outside of the haunted castle.
		description = "Unused (Was skeleton spawn in classic)",
	},
	["q"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,},
				alternate = {
					[THEME.TEMPLE] = {function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l) end,},
					[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l) end,},
					[THEME.VOLCANA] = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l) end,},
				},
			}
		},
		description = "Obstacle-Resistant Terrain",
	},
	["r"] = {
		description = "Terrain/Stone",
		-- Used to be used for Temple Obstacle Block but had to be assigned to a new tilecode ("(") to avoid problems
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l) end,
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l) end,
				},
				alternate = {
					[THEME.VOLCANA] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l) end,
						function(x, y, l) return 0 end,
					}
				},
			}
		},
	},
	["s"] = {
		phases = {
			[2] = {
				default = {
					function(x, y, l)
						spikeslib.detect_floor_and_create_spikes(x, y, l)
					end,
				}
			}
		},
		description = "Spikes",
	},
	["t"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x, y, l) end,
				},
				alternate = {
					[THEME.TEMPLE] = {
						function(x, y, l) spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l) end,
						function(x, y, l) return 0 end,
					},
					[THEME.CITY_OF_GOLD] = {
						function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_COG, x, y, l) end,
						function(x, y, l) return 0 end,
					},
				}
			}
		},
		description = "Temple/Castle Terrain",
	},
	["u"] = {
		phases = {
			[1] = {
				tutorial = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_BAT, x, y, l, 0, 0) end,},
				default = {function(x, y, l) spawn_entity(ENT_TYPE.MONS_VAMPIRE, x, y, l, 0, 0) end,},
			}
		},
		description = "Vampire from Vlad's Tower",
	},
	["v"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_MINEWOOD, x, y, l) end,},
			}
		},
		description = "Wood",
	},
	["w"] = {
		phases = {
			[3] = {
				default = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y) return ENT_TYPE.LIQUID_WATER end,},
				alternate = {
					[THEME.TEMPLE] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
					[THEME.CITY_OF_GOLD] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
					[THEME.VOLCANA] = {function(x, y, l) spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y) return ENT_TYPE.LIQUID_LAVA end,},
				},
			}
		},
		description = "Liquid",
	},
	["x"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x, y, l)
						spawn_grid_entity(ENT_TYPE.FLOOR_ALTAR, x+1, y, l)
					end,
				},
			}
		},
		description = "Kali Altar",
	},
	["y"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						embedlib.embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, x, y, l))
					end
				},
				alternate = {
					[THEME.TEMPLE] = {
						function(x, y, l)
							embedlib.embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity((options.hd_og_floorstyle_temple and ENT_TYPE.FLOORSTYLED_STONE or ENT_TYPE.FLOORSTYLED_TEMPLE), x, y, l))
						end
					},
					[THEME.VOLCANA] = {
						function(x, y, l)
							embedlib.embed_nonitem(ENT_TYPE.ITEM_RUBY, spawn_grid_entity(ENT_TYPE.FLOORSTYLED_VLAD, x, y, l))
						end
					}
				}
			}
		},
		description = "Crust Ruby in Terrain",
	},
	["z"] = {
		phases = {
			[1] = {
				tutorial = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_CHEST, x, y, l) end,
				},
				default = {
					function(x, y, l) spawn_grid_entity(ENT_TYPE.FLOORSTYLED_BEEHIVE, x, y, l) end,
					function(x, y, l) return 0 end,
				},
				alternate = {
					[THEME.NEO_BABYLON] = {function(x, y, l)
						turretlib.spawn_turret(x, y, l)
					end,},
					[THEME.CITY_OF_GOLD] = {function(x, y, l) return 0 end,},
					[THEME.VOLCANA] = {function(x, y, l) return 0 end,} -- bg columns
				},
			}
		},
		-- # TODO: Temple has bg pillar as an alternative
		description = "Beehive Tile/Empty",
	},
	["|"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						for yi = 0, -3, -1 do
							for xi = 0, 3, 1 do
								if (yi == -1 and (xi == 1 or xi == 2)) or (yi == -2 and (xi == 1 or xi == 2)) then
									-- SORRY NOTHING
								else
									local entity = get_entity(spawn_grid_entity(ENT_TYPE.FLOORSTYLED_STONE, x+xi, y+yi, l))
									entity.flags = set_flag(entity.flags, ENT_FLAG.SHOP_FLOOR)
								end
							end
						end
						spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_VAULTCHEST, x+1, y-2, l)
						spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_VAULTCHEST, x+2, y-2, l)
						local shopkeeper_uid = spawn_entity_snapped_to_floor(ENT_TYPE.MONS_SHOPKEEPER, x+1, y-2, l)
						local shopkeeper = get_entity(shopkeeper_uid)
						
						if state.shoppie_aggro_next <= 0 then
							pick_up(shopkeeper_uid, spawn_entity(ENT_TYPE.ITEM_SHOTGUN, x+1, y-2, l, 0, 0))
							shopkeeper.flags = set_flag(shopkeeper.flags, ENT_FLAG.CAN_BE_STOMPED)
							shopkeeper.flags = clr_flag(shopkeeper.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
						end
						shopkeeper.is_patrolling = true
						shopkeeper.move_state = 9
					end
				},
			}
		},
		description = "Vault",
	},
	["~"] = {
		phases = {
			[1] = {
				default = {function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, l) end,},
			}
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
	},
		-- description = "Unknown",
	[")"] = {
		phases = {
			[1] = {
				default = {
					function(x, y, l)
						spawn_grid_entity(ENT_TYPE.FLOOR_FORCEFIELD_TOP, x, y, l)
					end
				}
			}
		},
		description = "Forcefield top",
	}
}


return module