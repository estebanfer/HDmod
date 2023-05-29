spikeballlib = require 'lib.entities.spikeball_trap'
local removelib = require 'lib.spawning.remove'
local validlib = require 'lib.spawning.valid'
local pushblocklib = require 'lib.entities.pushblock'

local module = {}

module.GIANTSPIDER_SPAWNED = false

function module.init()
	module.GIANTSPIDER_SPAWNED = false
end

function module.create_embedded(ent_toembedin, entity_type)
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

function module.create_liquidfall(x, y, l, texture_path, is_lava)
	local is_lava = is_lava or false
	local type = ENT_TYPE.LOGICAL_WATER_DRAIN
	if is_lava == true then
		type = ENT_TYPE.LOGICAL_LAVA_DRAIN
	end
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0)
	texture_def.texture_path = texture_path
	local drain_texture = define_texture(texture_def)
	local drain_uid = spawn_entity(type, x, y, l, 0, 0)
	get_entity(drain_uid):set_texture(drain_texture)

	local backgrounds = entity_get_items_by(drain_uid, ENT_TYPE.BG_WATER_FOUNTAIN, 0)
	if #backgrounds ~= 0 then
		local texture_def2 = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_2)
		texture_def2.texture_path = texture_path
		local fountain_texture = define_texture(texture_def2)

		local fountain = get_entity(backgrounds[1])
		fountain:set_texture(fountain_texture)
	end
end

function module.create_regenblock(x, y, l)
	spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK, x, y, l)
	local regen_bg = get_entity(spawn_entity(ENT_TYPE.MIDBG, x, y, l, 0, 0))
	regen_bg:set_texture(TEXTURE.DATA_TEXTURES_FLOOR_SUNKEN_0)
	regen_bg.animation_frame = 137
	regen_bg:set_draw_depth(47)
	regen_bg.width, regen_bg.height = 1, 1
	-- regen_bg.tile_width, regen_bg.tile_height = regen_bg.width/10, regen_bg.height/10
	regen_bg.hitboxx, regen_bg.hitboxy = regen_bg.width/2, regen_bg.height/2
end

function module.create_yama(x, y, l)-- 20, 117 = 22.5 117.5
	spawn_entity(ENT_TYPE.MONS_YAMA, x+2.5, y+.5, l, 0, 0)
end

function module.create_anubis(x, y, l)
	get_entity(spawn_entity(ENT_TYPE.MONS_ANUBIS, x, y, l, 0, 0)).move_state = 5
end

function module.create_succubus(x, y, l) end

function module.create_caveman(x, y, l) spawn_on_floor(ENT_TYPE.MONS_CAVEMAN, x, y, l) end

function module.create_mantrap(x, y, l) spawn_on_floor(ENT_TYPE.MONS_MANTRAP, x, y, l) end

function module.create_tikiman(x, y, l) spawn_on_floor(ENT_TYPE.MONS_TIKIMAN, x, y, l) end

function module.create_firefrog(x, y, l) spawn_on_floor(ENT_TYPE.MONS_FIREFROG, x, y, l) end

function module.create_frog(x, y, l) spawn_on_floor(ENT_TYPE.MONS_FROG, x, y, l) end

function module.create_yeti(x, y, l) spawn_on_floor(ENT_TYPE.MONS_YETI, x, y, l) end

function module.create_critter_frog(x, y, l) end

function module.create_critter_maggot(x, y, l) end

function module.create_jiangshi(x, y, l) spawn_on_floor(ENT_TYPE.MONS_JIANGSHI, x, y, l) end

function module.create_hangspider(x, y, l)
	local uid = spawn_grid_entity(ENT_TYPE.MONS_HANGSPIDER, x, y, l)
	spawn_entity(ENT_TYPE.ITEM_WEB, x, y, l, 0, 0)
	spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, uid, 0, 0)
end

function module.create_bat(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_BAT, x, y, l) end

function module.create_spider(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SPIDER, x, y, l) end

function module.create_vampire(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_VAMPIRE, x, y, l) end

-- powderkeg / pushblock
function module.create_pushblock_powderkeg(x, y, l)
	-- local entity_here = get_grid_entity_at(x, y, l)
	-- if entity_here ~= -1 then
    --     -- get_entity(entity_here):destroy()
	-- 	kill_entity(entity_here)
	-- end
	removelib.remove_floor_and_embedded_at(x, y, l)

	local current_powderkeg_chance = get_procedural_spawn_chance(spawndeflib.global_spawn_procedural_powderkeg)
	if (
		current_powderkeg_chance ~= 0
		and prng:random_chance(current_powderkeg_chance, PRNG_CLASS.LEVEL_GEN)
	) then
		spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l)
	else
		pushblocklib.create_pushblock(x, y, l)
	end
end

function module.create_spikeball(x, y, l)
	removelib.remove_floor_and_embedded_at(x, y, l)
	spikeballlib.create_spikeball_trap(x, y, l)
end

function module.create_giantspider(x, y, l)
    spawn_entity(ENT_TYPE.MONS_GIANTSPIDER, x+.5, y, l, 0, 0)
    module.GIANTSPIDER_SPAWNED = true
end

function module.create_ufo(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_UFO, x, y, l) end

-- # TODO: Honey chance isn't completely same as HD, in HD it's 10% for upside down honey, and 9% for normal honey,
-- but the current implementation should be similar enough since it's 10% for each one
-- In case of changing this, also change from validlib and junglearea.lvl

function module.create_honey(x, y, l)
	local floor = get_grid_entity_at(x, y+1, l)
	if floor ~= -1 and prng:random_chance(2, PRNG_CLASS.LEVEL_GEN) then
		get_entity(spawn_entity_over(ENT_TYPE.ITEM_HONEY, floor, 0, -0.8)).animation_frame = 238
	else
		floor = get_grid_entity_at(x, y-1, l)
		if floor == -1 then return end
		spawn_entity_over(ENT_TYPE.ITEM_HONEY, floor, 0, 0.8)
	end
end

return module