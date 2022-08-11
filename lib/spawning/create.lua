spikeballlib = require 'lib.entities.spikeball_trap'

local module = {}

module.GIANTSPIDER_SPAWNED = false
module.LOCKEDCHEST_KEY_SPAWNED = false

function module.init()
	module.GIANTSPIDER_SPAWNED = false
	module.LOCKEDCHEST_KEY_SPAWNED = false
end

function module.create_coffin_coop(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	local the_coffin = get_entity(coffin_uid)
	the_coffin.player_respawn = true
	return coffin_uid
end

-- # TODO: determining character unlock for coffin creation
function module.create_coffin_unlock(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	if unlockslib.LEVEL_UNLOCK ~= nil then
		--[[ 193 + unlock_num = ENT_TYPE.CHAR_* ]]
		set_contents(coffin_uid, 193 + unlockslib.HD_UNLOCKS[unlockslib.LEVEL_UNLOCK].unlock_id)
	end

	set_post_statemachine(coffin_uid, function()
		local coffin = get_entity(coffin_uid)
		if (
			coffin.animation_frame == 1
			and (
				unlockslib.LEVEL_UNLOCK ~= nil
				and (
					unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
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

function module.create_ceiling_chain(x, y, l)
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

function module.create_ceiling_chain_growable(x, y, l)
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
			floors_at_offset = get_entities_at(0, MASK.FLOOR, x, yi-1, LAYER.FRONT, 0.5)[1] ~= nil
			floors_at_offset = floors_at_offset or get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, yi-2, LAYER.FRONT, 0.5)[1] ~= nil
			if floors_at_offset then break end
		else break end
	end
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
function module.create_crysknife(x, y, l)
    spawn_entity(ENT_TYPE.ITEM_POWERPACK, x, y, l, 0, 0)--ENT_TYPE.ITEM_EXCALIBUR, x, y, layer, 0, 0)
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

function module.create_damsel(x, y, l)
	local pet_setting = get_setting(GAME_SETTING.PET_STYLE)
	local pet_type = math.random(ENT_TYPE.MONS_PET_CAT, ENT_TYPE.MONS_PET_CAT+2)
	if pet_setting == 0 then
		pet_type = ENT_TYPE.MONS_PET_DOG
	elseif pet_setting == 1 then
		pet_type = ENT_TYPE.MONS_PET_CAT
	elseif pet_setting == 2 then
		pet_type = ENT_TYPE.MONS_PET_HAMSTER
	end
	spawn_grid_entity(pet_type, x, y, l)
end

function module.create_idol(x, y, l)
	idollib.IDOL_X, idollib.IDOL_Y = x, y
	idollib.IDOL_UID = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_IDOL, idollib.IDOL_X, idollib.IDOL_Y, l)
	if state.theme == THEME.ICE_CAVES then
		-- .trap_triggered: "if you set it to true for the ice caves or volcano idol, the trap won't trigger"
		get_entity(idollib.IDOL_UID).trap_triggered = true
	end
end

function module.create_idol_crystalskull(x, y, l)
	idollib.IDOL_X, idollib.IDOL_Y = x, y
	idollib.IDOL_UID = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_MADAMETUSK_IDOL, idollib.IDOL_X, idollib.IDOL_Y, l)

	local entity = get_entity(idollib.IDOL_UID)
	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
	texture_def.texture_path = "res/items_dar_idol.png"
	entity:set_texture(define_texture(texture_def))
end

function module.create_yama(x, y, l)-- 20, 117 = 22.5 117.5
	spawn_entity(ENT_TYPE.MONS_YAMA, x+2.5, y+.5, l, 0, 0)
end

function module.create_anubis(x, y, l)
	get_entity(spawn_entity(ENT_TYPE.MONS_ANUBIS, x, y, l, 0, 0)).move_state = 5
end

function module.create_locked_chest_and_key(x, y, l)
	if module.LOCKEDCHEST_KEY_SPAWNED == false then
		spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST_KEY, x, y, l)
		module.LOCKEDCHEST_KEY_SPAWNED = true
	else
		spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_LOCKEDCHEST, x, y, l)
	end
	removelib.remove_damsel_spawn_item(x, y, l)
end

function module.create_succubus(x, y, l) end

function module.create_caveman(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_CAVEMAN, x, y, l) end

function module.create_mantrap(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_MANTRAP, x, y, l) end

function module.create_tikiman(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_TIKIMAN, x, y, l) end

function module.create_snail(x, y, l) spawn_on_floor(ENT_TYPE.MONS_HERMITCRAB, x, y, l) end

function module.create_firefrog(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_FIREFROG, x, y, l) end

function module.create_frog(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_FROG, x, y, l) end

function module.create_yeti(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_YETI, x, y, l) end

function module.create_hawkman(x, y, l) end

function module.create_scorpionfly(x, y, l) end

function module.create_critter_rat(x, y, l) end

function module.create_critter_frog(x, y, l) end

function module.create_critter_maggot(x, y, l) end

function module.create_jiangshi(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_JIANGSHI, x, y, l) end

function module.create_devil(x, y, l) end

function module.create_alientank(x, y, l) end

function module.create_piranha(x, y, l) end

function module.create_hangspider(x, y, l)
	local uid = spawn_grid_entity(ENT_TYPE.MONS_HANGSPIDER, x, y, l)
	spawn_entity(ENT_TYPE.ITEM_WEB, x, y, l, 0, 0)
	spawn_entity_over(ENT_TYPE.ITEM_HANGSTRAND, uid, 0, 0)
end

function module.create_bat(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_BAT, x, y, l) end

function module.create_spider(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_SPIDER, x, y, l) end

function module.create_vampire(x, y, l) spawn_grid_entity(ENT_TYPE.MONS_VAMPIRE, x, y, l) end

function module.create_mshiplight(x, y, l) end

function module.create_webnest(x, y, l)
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
		and math.random(current_powderkeg_chance) == 1
	) then
		spawn_entity(ENT_TYPE.ACTIVEFLOOR_POWDERKEG, x, y, l, 0, 0)
	else
		spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, l, 0, 0)
	end
end

function module.create_spikeball(x, y, l)
	removelib.remove_floor_and_embedded_at(x, y, l)
	spikeballlib.create_spikeball_trap(x, y, l)
end

function module.create_arrowtrap(x, y, l)
	-- local entity_here = get_grid_entity_at(x, y, l)
	-- if entity_here ~= -1 then
    --     -- get_entity(entity_here):destroy()
	-- 	kill_entity(entity_here)
	-- end
	removelib.remove_floor_and_embedded_at(x, y, l)
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
	if floor ~= -1 and math.random(2) == 1 then
		get_entity(spawn_entity_over(ENT_TYPE.ITEM_HONEY, floor, 0, -0.8)).animation_frame = 238
	else
		floor = get_grid_entity_at(x, y-1, l)
		if floor == -1 then return end
		spawn_entity_over(ENT_TYPE.ITEM_HONEY, floor, 0, 0.8)
	end
end

local function create_window(x, y, l, is_hc)
	local ent = get_entity(spawn_entity(ENT_TYPE.BG_VLAD_WINDOW, x, y-0.5, l, 0, 0))
	ent.width, ent.height = 1, 2
	ent.hitboxx, ent.hitboxy = 0.5, 1

	local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_VLAD_4)
	if is_hc == true then
		texture_def.texture_path = "res/hc_window.png"
	end
	ent:set_texture(define_texture(texture_def))
end

function module.create_hcastle_window(x, y, l)
	create_window(x, y, l, true)
end

function module.create_vlad_window(x, y, l)
	create_window(x, y, l, false)
end

return module