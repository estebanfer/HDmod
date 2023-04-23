commonlib = require 'lib.common'
worldlib = require 'lib.worldstate'
feelingslib = require 'lib.feelings'
doorslib = require 'lib.entities.doors'
validlib = require 'lib.spawning.valid'
createlib = require 'lib.spawning.create'
local giantfroglib = require 'lib.entities.giant_frog'
local bacteriumlib = require 'lib.entities.bacterium'
local eggsaclib = require 'lib.entities.eggsac'
local mshiplightlib = require 'lib.entities.mothership_light'
local piranhalib = require 'lib.entities.piranha'
wormtonguelib = require 'lib.entities.wormtongue'
tombstonelib = require 'lib.entities.tombstone'
turretlib = require 'lib.entities.laser_turret'
local alientanklib = require "lib.entities.alientank"
greenknightlib = require 'lib.entities.green_knight'
mammothlib = require 'lib.entities.mammoth'
tikitraplib = require 'lib.entities.tikitrap'
local damsellib = require 'lib.entities.damsel'
local arrowtraplib = require 'lib.entities.arrowtrap'
local hideyholelib = require 'lib.entities.hideyhole'
local webballlib = require 'lib.entities.web_ball'
local critterratlib = require 'lib.entities.critterrat'
local hawkmanlib = require "lib.entities.hawkman"
local snaillib = require 'lib.entities.snail'

local module = {}


--[[
	Extra spawns use the prefix `global_spawn_extra_*`
--]]

module.global_spawn_extra_blackmarket = define_extra_spawn(doorslib.create_door_exit_to_blackmarket, validlib.is_valid_blackmarket_spawn, 0, 0)

module.global_spawn_hideyhole = define_extra_spawn(hideyholelib.create_hideyhole_spawn, validlib.is_valid_hideyhole_spawn, 0, 0)

module.global_spawn_extra_hive_queenbee = define_extra_spawn(function(x, y, l) spawn_entity(ENT_TYPE.MONS_QUEENBEE, x+1, y, l, 0, 0) end, validlib.is_valid_queenbee_spawn, 0, 0)

module.global_spawn_extra_wormtongue = define_extra_spawn(wormtonguelib.create_wormtongue, validlib.is_valid_wormtongue_spawn, 0, 0)

module.global_spawn_extra_anubis = define_extra_spawn(createlib.create_anubis, validlib.is_valid_anubis_spawn, 0, 0)

-- cog door(?) -- # TOFIX: Currently using S2 COG door implementation. If it ends up spawning in lava, will need to manually prevent that and do it here.  


--[[
	Procedural spawns use the prefix `global_spawn_procedural_*`
--]]

module.global_spawn_procedural_spiderlair_ground_enemy = define_procedural_spawn("hd_procedural_spiderlair_ground_enemy", function(x, y, l) end, function(x, y, l) return false end)--throwaway method so we can define the chance in .lvl file and use it for ground enemy spawns

module.global_spawn_procedural_landmine = define_procedural_spawn("hd_procedural_landmine", function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LANDMINE, x, y, l) end, validlib.is_valid_landmine_spawn)
module.global_spawn_procedural_wetfur_landmine = define_procedural_spawn("hd_procedural_wetfur_landmine", function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LANDMINE, x, y, l) end, validlib.is_valid_landmine_spawn)

module.global_spawn_procedural_bouncetrap = define_procedural_spawn("hd_procedural_bouncetrap", function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, l) end, validlib.is_valid_bouncetrap_spawn)
module.global_spawn_procedural_wetfur_bouncetrap = define_procedural_spawn("hd_procedural_wetfur_bouncetrap", function(x, y, l) spawn_entity_snapped_to_floor(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, l) end, validlib.is_valid_bouncetrap_spawn)

module.global_spawn_procedural_caveman = define_procedural_spawn("hd_procedural_caveman", createlib.create_caveman, validlib.is_valid_caveman_spawn)
module.global_spawn_procedural_worm_jungle_caveman = define_procedural_spawn("hd_procedural_worm_jungle_caveman", createlib.create_caveman, validlib.is_valid_caveman_spawn)

module.global_spawn_procedural_scorpion = define_procedural_spawn("hd_procedural_scorpion", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCORPION, x, y, l) end, validlib.is_valid_scorpion_spawn)

module.global_spawn_procedural_cobra = define_procedural_spawn("hd_procedural_cobra", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_COBRA, x, y, l) end, validlib.is_valid_cobra_spawn)

module.global_spawn_procedural_snake = define_procedural_spawn("hd_procedural_snake", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SNAKE, x, y, l) end, validlib.is_valid_snake_spawn)

module.global_spawn_procedural_mantrap = define_procedural_spawn("hd_procedural_mantrap", createlib.create_mantrap, validlib.is_valid_mantrap_spawn)
module.global_spawn_procedural_hcastle_mantrap = define_procedural_spawn("hd_procedural_hcastle_mantrap", createlib.create_mantrap, validlib.is_valid_mantrap_spawn)
module.global_spawn_procedural_worm_jungle_mantrap = define_procedural_spawn("hd_procedural_worm_jungle_mantrap", createlib.create_mantrap, validlib.is_valid_mantrap_spawn)

module.global_spawn_procedural_tikiman = define_procedural_spawn("hd_procedural_tikiman", createlib.create_tikiman, validlib.is_valid_tikiman_spawn)
module.global_spawn_procedural_worm_jungle_tikiman = define_procedural_spawn("hd_procedural_worm_jungle_tikiman", createlib.create_tikiman, validlib.is_valid_tikiman_spawn)

module.global_spawn_procedural_snail = define_procedural_spawn("hd_procedural_snail", snaillib.create_snail, validlib.is_valid_snail_spawn)
module.global_spawn_procedural_hcastle_snail = define_procedural_spawn("hd_procedural_hcastle_snail", snaillib.create_snail, validlib.is_valid_snail_spawn)
module.global_spawn_procedural_worm_jungle_snail = define_procedural_spawn("hd_procedural_worm_jungle_snail", snaillib.create_snail, validlib.is_valid_snail_spawn)

module.global_spawn_procedural_firefrog = define_procedural_spawn("hd_procedural_firefrog", createlib.create_firefrog, validlib.is_valid_firefrog_spawn)
module.global_spawn_procedural_hcastle_firefrog = define_procedural_spawn("hd_procedural_hcastle_firefrog", createlib.create_firefrog, validlib.is_valid_firefrog_spawn)
module.global_spawn_procedural_worm_jungle_firefrog = define_procedural_spawn("hd_procedural_worm_jungle_firefrog", createlib.create_firefrog, validlib.is_valid_firefrog_spawn)

module.global_spawn_procedural_frog = define_procedural_spawn("hd_procedural_frog", createlib.create_frog, validlib.is_valid_frog_spawn)
module.global_spawn_procedural_hcastle_frog = define_procedural_spawn("hd_procedural_hcastle_frog", createlib.create_frog, validlib.is_valid_frog_spawn)
module.global_spawn_procedural_worm_jungle_frog = define_procedural_spawn("hd_procedural_worm_jungle_frog", createlib.create_frog, validlib.is_valid_frog_spawn)

module.global_spawn_procedural_yeti = define_procedural_spawn("hd_procedural_yeti", createlib.create_yeti, validlib.is_valid_yeti_spawn)
module.global_spawn_procedural_wetfur_yeti = define_procedural_spawn("hd_procedural_wetfur_yeti", createlib.create_yeti, validlib.is_valid_yeti_spawn)
module.global_spawn_procedural_worm_icecaves_yeti = define_procedural_spawn("hd_procedural_worm_icecaves_yeti", createlib.create_yeti, validlib.is_valid_yeti_spawn)

module.global_spawn_procedural_hawkman = define_procedural_spawn("hd_procedural_hawkman", hawkmanlib.create_hawkman, validlib.is_valid_hawkman_spawn)

module.global_spawn_procedural_crocman = define_procedural_spawn("hd_procedural_crocman", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CROCMAN, x, y, l) end, validlib.is_valid_crocman_spawn)

module.global_spawn_procedural_scorpionfly = define_procedural_spawn("hd_procedural_scorpionfly", createlib.create_scorpionfly, validlib.is_valid_scorpionfly_spawn)

module.global_spawn_procedural_critter_rat = define_procedural_spawn("hd_procedural_critter_rat", critterratlib.create_critterrat, validlib.is_valid_critter_rat_spawn)

module.global_spawn_procedural_critter_frog = define_procedural_spawn("hd_procedural_critter_frog", createlib.create_critter_frog, validlib.is_valid_critter_frog_spawn)

module.global_spawn_procedural_worm_jungle_critter_maggot = define_procedural_spawn("hd_procedural_worm_jungle_critter_maggot", createlib.create_critter_maggot, validlib.is_valid_critter_maggot_spawn)

module.global_spawn_procedural_critter_penguin = define_procedural_spawn("hd_procedural_critter_penguin", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERPENGUIN, x, y, l) end, validlib.is_valid_critter_penguin_spawn)
module.global_spawn_procedural_wetfur_critter_penguin = define_procedural_spawn("hd_procedural_wetfur_critter_penguin", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERPENGUIN, x, y, l) end, validlib.is_valid_critter_penguin_spawn)

module.global_spawn_procedural_critter_locust = define_procedural_spawn("hd_procedural_critter_locust", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERLOCUST, x, y, l) end, validlib.is_valid_critter_locust_spawn)

module.global_spawn_procedural_jiangshi = define_procedural_spawn("hd_procedural_jiangshi", createlib.create_jiangshi, validlib.is_valid_jiangshi_spawn)
module.global_spawn_procedural_restless_jiangshi = define_procedural_spawn("hd_procedural_restless_jiangshi", createlib.create_jiangshi, validlib.is_valid_jiangshi_spawn)
module.global_spawn_procedural_hcastle_jiangshi = define_procedural_spawn("hd_procedural_hcastle_jiangshi", createlib.create_jiangshi, validlib.is_valid_jiangshi_spawn)
module.global_spawn_procedural_yama_jiangshi = define_procedural_spawn("hd_procedural_yama_jiangshi", createlib.create_jiangshi, validlib.is_valid_jiangshi_spawn)

module.global_spawn_procedural_devil = define_procedural_spawn("hd_procedural_devil", createlib.create_devil, validlib.is_valid_devil_spawn)
module.global_spawn_procedural_yama_devil = define_procedural_spawn("hd_procedural_yama_devil", createlib.create_devil, validlib.is_valid_devil_spawn)

module.global_spawn_procedural_hcastle_greenknight = define_procedural_spawn("hd_procedural_hcastle_greenknight", greenknightlib.create_greenknight, validlib.is_valid_greenknight_spawn)

module.global_spawn_procedural_alientank = define_procedural_spawn("hd_procedural_alientank", alientanklib.create_alientank, validlib.is_valid_alientank_spawn)

module.global_spawn_procedural_critter_fish = define_procedural_spawn("hd_procedural_critter_fish", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CRITTERFISH, x, y, l) end, validlib.is_valid_critter_fish_spawn)

module.global_spawn_procedural_piranha = define_procedural_spawn("hd_procedural_piranha", piranhalib.create_piranha, validlib.is_valid_piranha_spawn)
module.global_spawn_procedural_hcastle_piranha = define_procedural_spawn("hd_procedural_hcastle_piranha", piranhalib.create_piranha, validlib.is_valid_piranha_spawn)

module.global_spawn_procedural_monkey = define_procedural_spawn("hd_procedural_monkey", function(x, y, l) return false end, function(x, y, l) return false end)-- throwaway so we can obtain the value while in tiledef
module.global_spawn_procedural_worm_jungle_monkey = define_procedural_spawn("hd_procedural_worm_jungle_monkey", function(x, y, l) return false end, function(x, y, l) return false end)

module.global_spawn_procedural_hangspider = define_procedural_spawn("hd_procedural_hangspider", createlib.create_hangspider, validlib.is_valid_hangspider_spawn)
module.global_spawn_procedural_spiderlair_hangspider = define_procedural_spawn("hd_procedural_spiderlair_hangspider", createlib.create_hangspider, validlib.is_valid_hangspider_spawn)
module.global_spawn_procedural_restless_hangspider = define_procedural_spawn("hd_procedural_restless_hangspider", createlib.create_hangspider, validlib.is_valid_hangspider_spawn)
module.global_spawn_procedural_hcastle_hangspider = define_procedural_spawn("hd_procedural_hcastle_hangspider", createlib.create_hangspider, validlib.is_valid_hangspider_spawn)

module.global_spawn_procedural_bat = define_procedural_spawn("hd_procedural_bat", createlib.create_bat, validlib.is_valid_bat_spawn)
module.global_spawn_procedural_hcastle_bat = define_procedural_spawn("hd_procedural_hcastle_bat", createlib.create_bat, validlib.is_valid_bat_spawn)
module.global_spawn_procedural_worm_jungle_bat = define_procedural_spawn("hd_procedural_worm_jungle_bat", createlib.create_bat, validlib.is_valid_bat_spawn)
module.global_spawn_procedural_yama_bat = define_procedural_spawn("hd_procedural_yama_bat", createlib.create_bat, validlib.is_valid_bat_spawn)

module.global_spawn_procedural_spider = define_procedural_spawn("hd_procedural_spider", createlib.create_spider, validlib.is_valid_spider_spawn)
module.global_spawn_procedural_spiderlair_spider = define_procedural_spawn("hd_procedural_spiderlair_spider", createlib.create_spider, validlib.is_valid_spider_spawn)

module.global_spawn_procedural_vampire = define_procedural_spawn("hd_procedural_vampire", createlib.create_vampire, validlib.is_valid_vampire_spawn)
module.global_spawn_procedural_restless_vampire = define_procedural_spawn("hd_procedural_restless_vampire", createlib.create_vampire, validlib.is_valid_vampire_spawn)
module.global_spawn_procedural_hcastle_vampire = define_procedural_spawn("hd_procedural_hcastle_vampire", createlib.create_vampire, validlib.is_valid_vampire_spawn)
module.global_spawn_procedural_yama_vampire = define_procedural_spawn("hd_procedural_yama_vampire", createlib.create_vampire, validlib.is_valid_vampire_spawn)

module.global_spawn_procedural_imp = define_procedural_spawn("hd_procedural_imp", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_IMP, x, y, l) end, validlib.is_valid_imp_spawn)
module.global_spawn_procedural_yama_imp = define_procedural_spawn("hd_procedural_yama_imp", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_IMP, x, y, l) end, validlib.is_valid_imp_spawn)

module.global_spawn_procedural_scarab = define_procedural_spawn("hd_procedural_scarab", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SCARAB, x, y, l) end, validlib.is_valid_scarab_spawn)

module.global_spawn_procedural_mshiplight = define_procedural_spawn("hd_procedural_mshiplight", mshiplightlib.create_mshiplight, validlib.is_valid_mshiplight_spawn)

module.global_spawn_procedural_dark_lantern = define_procedural_spawn("hd_procedural_dark_lantern", function(x, y, l) spawn_grid_entity(ENT_TYPE.ITEM_LAMP, x, y, l) end, validlib.is_valid_lantern_spawn)

module.global_spawn_procedural_turret = define_procedural_spawn("hd_procedural_turret", turretlib.spawn_turret, validlib.is_valid_turret_spawn)
module.global_spawn_procedural_ufofeeling_turret = define_procedural_spawn("hd_procedural_ufofeeling_turret", turretlib.spawn_turret, validlib.is_valid_turret_spawn)
module.global_spawn_procedural_mshipentrance_turret = define_procedural_spawn("hd_procedural_mshipentrance_turret", turretlib.spawn_turret, validlib.is_valid_turret_spawn)

module.global_spawn_procedural_spiderlair_webnest = define_procedural_spawn("hd_procedural_spiderlair_webnest", webballlib.create_webball, validlib.is_valid_webnest_spawn)

module.global_spawn_procedural_powderkeg = define_procedural_spawn("hd_procedural_powderkeg", function(x, y, l) end, function(x, y, l) return false end)--throwaway method so we can define the chance in .lvl file and use `global_spawn_procedural_pushblock` to spawn it
module.global_spawn_procedural_pushblock = define_procedural_spawn("hd_procedural_pushblock", createlib.create_pushblock_powderkeg, validlib.is_valid_pushblock_spawn)

module.global_spawn_procedural_spikeball = define_procedural_spawn("hd_procedural_spikeball", createlib.create_spikeball, validlib.is_valid_spikeball_spawn)
module.global_spawn_procedural_yama_spikeball = define_procedural_spawn("hd_procedural_yama_spikeball", createlib.create_spikeball, validlib.is_valid_spikeball_spawn)

module.global_spawn_procedural_arrowtrap = define_procedural_spawn("hd_procedural_arrowtrap", arrowtraplib.create_arrowtrap, validlib.is_valid_arrowtrap_spawn)

module.global_spawn_procedural_tikitrap = define_procedural_spawn("hd_procedural_tikitrap", tikitraplib.create_tikitrap_procedural, validlib.is_valid_tikitrap_spawn)

module.global_spawn_procedural_crushtrap = define_procedural_spawn("hd_procedural_crushtrap", function(x, y, l) spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, x, y, l) end, validlib.is_valid_crushtrap_spawn)

-- ash tombstone shotgun -- log all tombstones in an array upon creation, then set a callback to select one of them for ASH skin and shotgun.
module.global_spawn_procedural_restless_tombstone = define_procedural_spawn("hd_procedural_restless_tombstone", tombstonelib.create_tombstone_common, validlib.is_valid_tombstone_spawn)

module.global_spawn_procedural_giantfrog = define_procedural_spawn("hd_procedural_giantfrog", giantfroglib.create_giantfrog, validlib.is_valid_giantfrog_spawn)

module.global_spawn_procedural_mammoth = define_procedural_spawn("hd_procedural_mammoth", mammothlib.create_mammoth, validlib.is_valid_mammoth_spawn)

module.global_spawn_procedural_giantspider = define_procedural_spawn("hd_procedural_giantspider", createlib.create_giantspider, validlib.is_valid_giantspider_spawn)

module.global_spawn_procedural_hive_bee = define_procedural_spawn("hd_procedural_hive_bee", function(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_BEE, x, y, l) end, validlib.is_valid_bee_spawn)
module.global_spawn_procedural_hive_honey = define_procedural_spawn("hd_procedural_hive_honey", createlib.create_honey, validlib.is_valid_honey_spawn)

module.global_spawn_procedural_ufo = define_procedural_spawn("hd_procedural_ufo", createlib.create_ufo, validlib.is_valid_ufo_spawn)
module.global_spawn_procedural_worm_icecaves_ufo = define_procedural_spawn("hd_procedural_worm_icecaves_ufo", createlib.create_ufo, validlib.is_valid_ufo_spawn)

module.global_spawn_procedural_worm_jungle_bacterium = define_procedural_spawn("hd_procedural_worm_jungle_bacterium", bacteriumlib.create_bacterium, validlib.is_valid_bacterium_spawn)
module.global_spawn_procedural_worm_icecaves_bacterium = define_procedural_spawn("hd_procedural_worm_icecaves_bacterium", bacteriumlib.create_bacterium, validlib.is_valid_bacterium_spawn)

module.global_spawn_procedural_worm_jungle_eggsac = define_procedural_spawn("hd_procedural_worm_jungle_eggsac", eggsaclib.create_eggsac, validlib.is_valid_eggsac_spawn)
module.global_spawn_procedural_worm_icecaves_eggsac = define_procedural_spawn("hd_procedural_worm_icecaves_eggsac", eggsaclib.create_eggsac, validlib.is_valid_eggsac_spawn)

module.global_spawn_procedural_hcastle_window = define_procedural_spawn("hd_procedural_hcastle_window", createlib.create_hcastle_window, validlib.is_valid_hcastle_window_spawn)
module.global_spawn_procedural_vlad_window = define_procedural_spawn("hd_procedural_vlad_window", createlib.create_vlad_window, validlib.is_valid_vlad_window_spawn)

--[[ Template for defining procedural spawns:

	local function create_*(x, y, l) end
	local function is_valid_*_spawn(x, y, l) return false end
	local global_spawn_procedural_* = define_procedural_spawn("hd_procedural_*", create_*, is_valid_*_spawn)
--]]


--[[
	END PROCEDURAL SPAWN DEF
--]]

---comment
---@param room_gen_ctx PostRoomGenerationContext
function module.set_chances(room_gen_ctx)
    if options.hd_debug_scripted_levelgen_disable == false then
        if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.NORMAL then
            local num_of_spawns = 0
            if (
                feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == false
                and state.theme ~= THEME.OLMEC
            ) then
                if feelingslib.feeling_check(feelingslib.FEELING_ID.UDJAT) then
                    num_of_spawns = 3
                elseif state.theme == THEME.VOLCANA then
                    num_of_spawns = 2
                else
                    num_of_spawns = 1
                end
            end
            room_gen_ctx:set_num_extra_spawns(module.global_spawn_hideyhole, num_of_spawns, 0)

            
            if feelingslib.feeling_check(feelingslib.FEELING_ID.SPIDERLAIR) then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_giantspider, 0)
            else
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_hangspider, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_spider, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_webnest, 0)
            end

            if (
                test_flag(state.level_flags, 18) == false
                or state.theme ~= THEME.DWELLING
            ) then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_dark_lantern, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.WORMTONGUE) == true then
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_wormtongue, 1, 0)
            else -- unset
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_wormtongue, 0, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.BLACKMARKET_ENTRANCE) == true then
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_blackmarket, 1, 0)
            else -- unset
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_blackmarket, 0, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_giantfrog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_mantrap, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_caveman, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_tikiman, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_snail, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_firefrog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_frog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_monkey, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_critter_frog, 0)
            else
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_restless_tombstone, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_restless_hangspider, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_restless_vampire, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_restless_jiangshi, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.HIVE) then
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_hive_queenbee, 1, 0)
                --room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hive_bee, 2)
            else
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_hive_queenbee, 0, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hive_bee, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hive_honey, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.HAUNTEDCASTLE) then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_piranha, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_giantfrog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_mantrap, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_caveman, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_tikiman, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_snail, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_firefrog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_frog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_critter_frog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_critter_fish, 0)
            else
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_piranha, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_bat, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_hangspider, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_vampire, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_jiangshi, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_mantrap, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_greenknight, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_snail, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_firefrog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_frog, 0)
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hcastle_window, 0)
            end

            if state.theme == THEME.EGGPLANT_WORLD then
                if state.world ~= 2 then
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_bacterium, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_eggsac, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_mantrap, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_caveman, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_tikiman, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_snail, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_firefrog, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_frog, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_bat, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_monkey, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_jungle_critter_maggot, 0)
                elseif state.world ~= 3 then
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_icecaves_bacterium, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_icecaves_eggsac, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_icecaves_yeti, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_worm_icecaves_ufo, 0)
                end
            end
            
            if feelingslib.feeling_check(feelingslib.FEELING_ID.YETIKINGDOM) then
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_landmine, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_bouncetrap, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yeti, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_critter_penguin, 0)
            else
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_wetfur_landmine, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_wetfur_bouncetrap, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_wetfur_yeti, 0)
            	room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_wetfur_critter_penguin, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.UFO) == false then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_ufofeeling_turret, 0)
            end

            if feelingslib.feeling_check(feelingslib.FEELING_ID.MOTHERSHIP_ENTRANCE) == false then
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_mshipentrance_turret, 0)
            end
            
            if feelingslib.feeling_check(feelingslib.FEELING_ID.ANUBIS) then
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_anubis, 1, 0)
            else
                room_gen_ctx:set_num_extra_spawns(module.global_spawn_extra_anubis, 0, 0)
            end

            if state.theme == THEME.VOLCANA then
                if feelingslib.feeling_check(feelingslib.FEELING_ID.VLAD) == false then
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_vlad_window, 0)
                end

                if feelingslib.feeling_check(feelingslib.FEELING_ID.YAMA) == true then
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_bat, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_imp, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_jiangshi, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_vampire, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_devil, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_tikitrap, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spikeball, 0)
                else
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_bat, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_imp, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_jiangshi, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_vampire, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_devil, 0)
                    -- room_gen_ctx:set_procedural_spawn_chance(global_spawn_procedural_yama_tikitrap, 0)
                    room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_yama_spikeball, 0)
                end
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
                room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_pushblock, 0)
            end
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_arrowtrap, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_giantspider, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_hangspider, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_bat, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spider, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_caveman, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_scorpion, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_cobra, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_snake, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_critter_rat, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_hangspider, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_spider, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_spiderlair_webnest, 0)
            room_gen_ctx:set_procedural_spawn_chance(module.global_spawn_procedural_dark_lantern, 0)
        end
    end
end


return module