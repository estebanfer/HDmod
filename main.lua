commonlib = require 'lib.common'
demolib = require 'lib.demo'
worldlib = require 'lib.worldstate'
camplib = require 'lib.camp'
testlib = require 'lib.test'
touchupslib = require 'lib.gen.touchups'
backwalllib = require 'lib.gen.backwall'
lutlib = require 'lib.gen.lut'
s2roomctxlib = require 'lib.gen.s2roomctx'
roomdeflib = require 'lib.gen.roomdef'
roomgenlib = require 'lib.gen.roomgen'
tiledeflib = require 'lib.gen.tiledef'
feelingslib = require 'lib.feelings'
unlockslib = require 'lib.unlocks'
cooplib = require 'lib.coop'
locatelib = require 'lib.locate'

validlib = require 'lib.spawning.valid'
spawndeflib = require 'lib.spawning.spawndef'
createlib = require 'lib.spawning.create'
removelib = require 'lib.spawning.remove'
embedlib = require 'lib.spawning.embed'
hdtypelib = require 'lib.entities.hdtype'
botdlib = require 'lib.entities.botd'
wormtonguelib = require 'lib.entities.wormtongue'
ghostlib = require 'lib.entities.ghost'
snowlib = require 'lib.entities.snow'
olmeclib = require 'lib.entities.olmec'
boulderlib = require 'lib.entities.boulder'
idollib = require 'lib.entities.idol'
acidlib = require 'lib.entities.acid'
treelib = require 'lib.entities.tree'
ankhmoailib = require 'lib.entities.ankhmoai'
doorslib = require 'lib.entities.doors'
tombstonelib = require 'lib.entities.tombstone'
flagslib = require 'lib.flags'

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


set_callback(function()
	game_manager.screen_title.ana_right_eyeball_torch_reflection.x, game_manager.screen_title.ana_right_eyeball_torch_reflection.y = -0.7, 0.05
	game_manager.screen_title.ana_left_eyeball_torch_reflection.x, game_manager.screen_title.ana_left_eyeball_torch_reflection.y = -0.55, 0.05
end, ON.TITLE)

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

set_callback(function(room_gen_ctx)
	if state.screen == SCREEN.LEVEL then
		-- message(F'ON.POST_ROOM_GENERATION - ON.LEVEL: {state.time_level}')

		if options.hd_debug_scripted_levelgen_disable == false then
			
			cooplib.detect_coop_coffin(room_gen_ctx)

			s2roomctxlib.unmark_setrooms(room_gen_ctx)

			--ONLEVEL_PRIORITY: 3 - Perform any script-generated chunk creation
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

				lutlib.add_lut()

				snowlib.add_snow_to_floor()
			end
		end
	end
end, ON.POST_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.PRE_LEVEL_GENERATION: {state.time_level}')

-- 	-- if state.screen == ON.LEVEL then
-- 	-- 	if options.hd_debug_scripted_levelgen_disable == false then
-- 	-- 		roomgenlib.onlevel_generation_execution_phase_one()
-- 	-- 		roomgenlib.onlevel_generation_execution_phase_two() -- # TOTEST: ON.POST_LEVEL_GENERATION
-- 	-- 	end
-- 	-- end
-- end, ON.PRE_LEVEL_GENERATION)

-- set_callback(function()
-- 	message(F'ON.POST_LEVEL_GENERATION: {state.time_level}')

set_callback(function()
	-- message(F'ON.LEVEL: {state.time_level}')
	roomgenlib.onlevel_generation_execution_phase_four()

-- --ONLEVEL_PRIORITY: 1 - Set level constants (ie, init_onlevel(), levelrules)
	-- TEMPORARY: move players and things they have to entrance point
	
	-- if (
	-- 	options.hd_debug_scripted_levelgen_disable == false and
	-- 	state.theme ~= THEME.OLMEC-- detect_level_non_boss()
	-- ) then
	-- 	for i = 1, #players, 1 do
	-- 		move_entity(players[i].uid, roomgenlib.global_levelassembly.entrance.x, roomgenlib.global_levelassembly.entrance.y, 0, 0)
	-- 	end
	-- 	local entity = get_entity(FRAG_PREVENTION_UID)
	-- 	if entity ~= nil then
	-- 		entity.flags = set_flag(entity.flags, ENT_FLAG.SOLID)
	-- 	end
	-- end
	
--ONLEVEL_PRIORITY: 4 - Set up dangers (LEVEL_DANGERS)
--ONLEVEL_PRIORITY: 5 - Remaining ON.LEVEL methods (ie, IDOL_UID)
	treelib.onlevel_decorate_trees()
	
	touchupslib.onlevel_touchups()

	olmeclib.onlevel_olmec_init()

	feelingslib.onlevel_toastfeeling()
end, ON.LEVEL)


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
-- 		-- move_entity(_entity.uid, roomgenlib.global_levelassembly.entrance.x+_offset_x, roomgenlib.global_levelassembly.entrance.y+_offset_y, 0, 0)
-- 		move_entity(_entity.uid, roomgenlib.global_levelassembly.entrance.x, roomgenlib.global_levelassembly.entrance.y, 0, 0)
-- 		message("moved to: " .. roomgenlib.global_levelassembly.entrance.x .. ", " .. roomgenlib.global_levelassembly.entrance.y)
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
