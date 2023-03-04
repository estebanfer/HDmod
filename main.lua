---@diagnostic disable: lowercase-global
commonlib = require 'lib.common'
demolib = require 'lib.demo'
worldlib = require 'lib.worldstate'
camplib = require 'lib.camp'
testlib = require 'lib.test'
touchupslib = require 'lib.gen.touchups'
backwalllib = require 'lib.gen.backwall'
require 'lib.gen.lut'
s2roomctxlib = require 'lib.gen.s2roomctx'
roomdeflib = require 'lib.gen.roomdef'
roomgenlib = require 'lib.gen.roomgen'
tiledeflib = require 'lib.gen.tiledef'
feelingslib = require 'lib.feelings'
unlockslib = require 'lib.unlocks'
cooplib = require 'lib.coop'
locatelib = require 'lib.locate'
custommusiclib = require 'lib.music.custommusic'

validlib = require 'lib.spawning.valid'
spawndeflib = require 'lib.spawning.spawndef'
createlib = require 'lib.spawning.create'
removelib = require 'lib.spawning.remove'
embedlib = require 'lib.spawning.embed'
hdtypelib = require 'lib.entities.hdtype'
botdlib = require 'lib.entities.botd'
wormtonguelib = require 'lib.entities.wormtongue'
ghostlib = require 'lib.entities.ghost'
olmeclib = require 'lib.entities.olmec'
boulderlib = require 'lib.entities.boulder'
idollib = require 'lib.entities.idol'
liquidlib = require 'lib.entities.liquid'
treelib = require 'lib.entities.tree'
ankhmoailib = require 'lib.entities.ankhmoai'
doorslib = require 'lib.entities.doors'
tombstonelib = require 'lib.entities.tombstone'
flagslib = require 'lib.flags'
decorlib = require 'lib.gen.decor'

meta.name = "HDmod - Demo"
meta.version = "1.03.1"
meta.description = "Spelunky HD's campaign in Spelunky 2"
meta.author = "Super Ninja Fat"

register_option_bool("hd_debug_boss_exits_unlock", "Debug: Unlock boss exits",														false)
register_option_bool("hd_debug_custom_level_music_disable", "Debug: Disable custom music for special levels",						false)
register_option_bool("hd_debug_custom_title_music_disable", "Debug: Disable custom music for the title screen",						false)
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

register_option_bool("disable_liquid_illumination", "Performance: Disable liquid illumination (water, acid)", "", false)

set_callback(function()
	game_manager.screen_title.ana_right_eyeball_torch_reflection.x, game_manager.screen_title.ana_right_eyeball_torch_reflection.y = -0.7, 0.05
	game_manager.screen_title.ana_left_eyeball_torch_reflection.x, game_manager.screen_title.ana_left_eyeball_torch_reflection.y = -0.55, 0.05
end, ON.TITLE)

set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		-- state.level_flags = set_flag(state.level_flags, 18) --force dark level
		-- message(F'ON.POST_ROOM_GENERATION - ON.LEVEL: {state.time_level}')

		if options.hd_debug_scripted_levelgen_disable == false then
			
			cooplib.detect_coop_coffin(room_gen_ctx)

			s2roomctxlib.unmark_setrooms(room_gen_ctx)

			-- Perform script-generated chunk creation
			roomgenlib.onlevel_generation_modification()

			s2roomctxlib.set_blackmarket_shoprooms(room_gen_ctx)

			roomgenlib.onlevel_generation_execution_phase_one()
			roomgenlib.onlevel_generation_execution_phase_two()

		end

		s2roomctxlib.assign_s2_room_templates(room_gen_ctx)

		spawndeflib.set_chances(room_gen_ctx)

	end
end, ON.POST_ROOM_GENERATION)

set_callback(function()
	if state.screen == SCREEN.LEVEL then
		
		roomgenlib.onlevel_generation_execution_phase_three()

		custommusiclib.on_start_level()

		--[[
			Procedural Spawn post_level_generation stuff
		--]]
		if options.hd_debug_scripted_levelgen_disable == false then
			if (
				worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL
			) then
				tombstonelib.set_ash_tombstone()

				s2roomctxlib.remove_bm_shopkeyp()

				backwalllib.set_backwall_bg()
				
				decorlib.change_decorations()
				
				touchupslib.postlevelgen_remove_items()
			end
		end
	end
end, ON.POST_LEVEL_GENERATION)

set_callback(function()
	-- message(F'ON.LEVEL: {state.time_level}')
	roomgenlib.onlevel_generation_execution_phase_four()

	treelib.onlevel_decorate_trees()
	
	touchupslib.onlevel_touchups()

	olmeclib.onlevel_olmec_init()

	feelingslib.onlevel_toastfeeling()

	liquidlib.spawn_liquid_illumination()
end, ON.LEVEL)

set_callback(function()
	-- Detect loading from a level into anything other than the options screen. This should capture every level ending scenario, including instant restarts and warps.
	if state.loading == 2 and state.screen == ON.LEVEL and state.screen_next ~= ON.OPTIONS then
		custommusiclib.on_end_level()
	end
	-- Check whether custom title music has been enabled/disabled in the options right before loading the title screen.
	-- Two loading events are checked because the script API sometimes misses one of them the first time the title screen loads.
	if (state.loading == 1 or state.loading == 2) and state.screen_next == ON.TITLE then
		custommusiclib.update_custom_title_music_enabled()
	end
end, ON.LOADING)