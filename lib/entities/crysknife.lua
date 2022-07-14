local celib = require 'lib.entities.custom_entities'

local crysknife_powerup_id, crysknife_pickup_id = -1, -1
local p_uid = -1
local mute_pick_sound = false

set_callback(function ()
	p_uid = -1
end, ON.PRE_LEVEL_GENERATION)

-- I should update the custom entities lib to make it not necessary to make a custom powerup for a pickup
local function crysknife_powerup_set(entity)
	set_pre_statemachine(entity.uid, function (p)
		p_uid = p.uid
	end)
end

local function crysknife_powerup_update(entity)
	p_uid = -1
end

set_pre_entity_spawn(function(entity_type, x, y, layer, overlay_entity, spawn_flags)
	if p_uid == -1 then return end
	mute_pick_sound = true

	local uid = spawn(ENT_TYPE.ITEM_EXCALIBUR, x, y, layer, 0, 0)
	get_entity(p_uid):pick_up(get_entity(uid))
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
	entity.animation_frame = 144
	entity.hitboxy = 0.2
end

local function crysknife_picked(_, player, _)
    celib.do_pickup_effect(player.uid, TEXTURE.DATA_TEXTURES_ITEMS_0, 144)
end

crysknife_powerup_id = celib.new_custom_powerup(crysknife_powerup_set, crysknife_powerup_update, TEXTURE.DATA_TEXTURES_ITEMS_0, 9, 0, nil, celib.UPDATE_TYPE.POST_STATEMACHINE)
crysknife_pickup_id = celib.new_custom_pickup(crysknife_pickup_set, function() end, crysknife_picked, crysknife_powerup_id, ENT_TYPE.ITEM_PICKUP_COMPASS)
celib.set_powerup_drop(crysknife_powerup_id, crysknife_pickup_id)

local module = {}

function module.create_crysknife(x, y, l)
	return celib.set_custom_entity(spawn_on_floor(ENT_TYPE.ITEM_PICKUP_COMPASS, x, y, l),
									crysknife_pickup_id)
end

return module