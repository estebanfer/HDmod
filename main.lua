---@diagnostic disable: lowercase-global
commonlib = require 'lib.common'
savelib = require 'lib.save'
optionslib = require 'lib.options'
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
moailib = require 'lib.entities.moai'
doorslib = require 'lib.entities.doors'
tombstonelib = require 'lib.entities.tombstone'
flagslib = require 'lib.flags'
decorlib = require 'lib.gen.decor'
snowballlib = require 'lib.entities.snowball'
crystalmonkeylib = require 'lib.entities.crystal_monkey'
shopslib = require 'lib.entities.shops'
require "lib.entities.mammoth"
require "lib.entities.hdentnew"
require "lib.entities.custom_death_messages"

meta.name = "HDmod - Demo"
meta.version = "1.04"
meta.description = "Spelunky HD's campaign in Spelunky 2"
meta.author = "Super Ninja Fat"

optionslib.register_option_bool("hd_debug_info_boss", "Boss - Show info", nil, false, true)
optionslib.register_option_bool("hd_debug_scripted_enemies_show", "Enable visibility of entities used in custom entity behavior", nil, false, true)
optionslib.register_option_bool("hd_debug_scripted_levelgen_disable", "Level gen - Disable scripted level generation", nil, false, true)

set_callback(function()
	game_manager.screen_title.ana_right_eyeball_torch_reflection.x, game_manager.screen_title.ana_right_eyeball_torch_reflection.y = -0.7025, 0.165
	game_manager.screen_title.ana_left_eyeball_torch_reflection.x, game_manager.screen_title.ana_left_eyeball_torch_reflection.y = -0.62, 0.1725
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

			shopslib.set_blackmarket_shoprooms(room_gen_ctx)

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

				backwalllib.set_backwall_bg()
				
				decorlib.change_decorations()
				
				touchupslib.postlevelgen_remove_items()

				touchupslib.postlevelgen_spawn_dar_fog()

				touchupslib.postlevelgen_fix_door_ambient_sound()
				
				touchupslib.postlevelgen_replace_wooden_shields()
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