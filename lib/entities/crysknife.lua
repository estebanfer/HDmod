local celib = require 'lib.entities.custom_entities'

--#TODO:
-- check if it has a correct interaction with laser turret
-- increase damage?

local crysknife_powerup_id, crysknife_pickup_id = -1, -1
local p_uid = -1
local mute_pick_sound = false

local crysknife_texture_id
do
	local crysknife_texture_def = TextureDefinition.new()
	crysknife_texture_def.width = 512
	crysknife_texture_def.height = 128
	crysknife_texture_def.tile_width = 128
	crysknife_texture_def.tile_height = 128

	crysknife_texture_def.texture_path = "res/crysknife.png"
	crysknife_texture_id = define_texture(crysknife_texture_def)
end

set_callback(function ()
	p_uid = -1
end, ON.PRE_LEVEL_GENERATION)

-- I should update the custom entities lib to make it not necessary to make a custom powerup for a pickup
local function crysknife_powerup_set(entity)
	set_pre_statemachine(entity.uid, function (p)
		if test_flag(p.flags, ENT_FLAG.DEAD) and not entity_has_item_type(p.uid, ENT_TYPE.ITEM_POWERUP_ANKH) then
			p_uid = -1
			clear_callback()
		else
			p_uid = p.uid
		end
	end)
end

local function crysknife_powerup_update(entity)
	p_uid = -1
end

set_pre_entity_spawn(function(entity_type, x, y, layer, overlay_entity, spawn_flags)
	if p_uid == -1 then return end
	mute_pick_sound = true

	local uid = spawn(ENT_TYPE.ITEM_EXCALIBUR, x, y, layer, 0, 0)
	local entity = get_entity(uid)
	entity:set_texture(crysknife_texture_id)
	get_entity(p_uid):pick_up(entity)

	set_post_statemachine(uid, function(e)
		if e.state ~= 12 then e:destroy() end
	end)
	return uid
end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_WHIP)

set_vanilla_sound_callback(VANILLA_SOUND.SHARED_PICK_UP, VANILLA_SOUND_CALLBACK_TYPE.CREATED, function (sound)
	if mute_pick_sound then
		sound:set_volume(0)
		sound:stop()
		mute_pick_sound = false
	end
end)


---@param entity Movable
local function crysknife_pickup_set(entity)
	entity:set_texture(crysknife_texture_id)
	entity.animation_frame = 144
	entity.hitboxy = 0.125
end

local function crysknife_picked(_, player, _)
	celib.do_pickup_effect(player.uid, crysknife_texture_id, 144)
end

crysknife_powerup_id = celib.new_custom_powerup(crysknife_powerup_set, crysknife_powerup_update, crysknife_texture_id, 9, 0, nil, celib.UPDATE_TYPE.POST_STATEMACHINE)
crysknife_pickup_id = celib.new_custom_pickup(crysknife_pickup_set, function() end, crysknife_picked, crysknife_powerup_id, ENT_TYPE.ITEM_PICKUP_COMPASS)
celib.set_powerup_drop(crysknife_powerup_id, crysknife_pickup_id)

local module = {}

function module.create_crysknife(x, y, l)
	return celib.set_custom_entity(
		spawn_on_floor(ENT_TYPE.ITEM_PICKUP_COMPASS, x, y, l),
		crysknife_pickup_id
	)
end

optionslib.register_entity_spawner("Crysknife", module.create_crysknife)

return module