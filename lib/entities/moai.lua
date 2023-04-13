local module = {}

optionslib.register_option_bool("hd_debug_punish_ball_breaks_moai", "Punish ball can break moai tiles", nil, true, true)

local moai_veil
local moai_diamond_cb

local MOAI_BORDER_MAIN_TEXTURE_DEF = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
MOAI_BORDER_MAIN_TEXTURE_DEF.texture_path = "res/border_main_moai.png"
module.MOAI_BORDER_MAIN_TEXTURE = define_texture(MOAI_BORDER_MAIN_TEXTURE_DEF)

local MOAI_VEIL_TEXTURE_DEF = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
MOAI_VEIL_TEXTURE_DEF.texture_path = "res/border_main_moai.png"
MOAI_VEIL_TEXTURE_DEF.tile_width = 384
MOAI_VEIL_TEXTURE_DEF.tile_height = 512
MOAI_VEIL_TEXTURE_DEF.sub_image_offset_x = 256
MOAI_VEIL_TEXTURE_DEF.sub_image_offset_y = 0
MOAI_VEIL_TEXTURE_DEF.sub_image_width = 384
MOAI_VEIL_TEXTURE_DEF.sub_image_height = 512
module.MOAI_VEIL_TEXTURE = define_texture(MOAI_VEIL_TEXTURE_DEF)

function module.init()
	moai_veil = nil
end

function module.create_moai_veil(x, y, l)
    moai_veil = spawn_entity(ENT_TYPE.DECORATION_GENERIC, x+1, y-1.5, l, 0, 0)
    local decoration = get_entity(moai_veil)
    decoration:set_texture(module.MOAI_VEIL_TEXTURE)
    decoration:set_draw_depth(get_type(ENT_TYPE.FLOOR_GENERIC).draw_depth)
    decoration.width, decoration.height = 3, 4
end

local function remove_moai_veil()
	if moai_veil then
		kill_entity(moai_veil)
		moai_veil = nil
	end
end

local function players_in_moai()
	local moai_hollow_aabb = AABB:new(
		roomgenlib.global_levelassembly.moai_exit.x-.5,
		roomgenlib.global_levelassembly.moai_exit.y+1.5,
		roomgenlib.global_levelassembly.moai_exit.x+.5,
		roomgenlib.global_levelassembly.moai_exit.y-1.5
	)
	moai_hollow_aabb:offset(0, 1)
	local _players_in_moai = get_entities_overlapping_hitbox(
		0, MASK.PLAYER,
		moai_hollow_aabb,
		LAYER.FRONT
	)
	return #_players_in_moai ~= 0
end

set_callback(function()
	if options.hd_debug_scripted_levelgen_disable == false then
		if feelingslib.feeling_check(feelingslib.FEELING_ID.MOAI) then
			moai_diamond_cb = set_interval(function()
				if players_in_moai() then
					remove_moai_veil()
					spawn_entity(ENT_TYPE.ITEM_DIAMOND, roomgenlib.global_levelassembly.moai_exit.x, roomgenlib.global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
					local sound = get_sound(VANILLA_SOUND.UI_SECRET)
					if sound then sound:play() end
					moai_diamond_cb = nil
					return false
				end
			end, 1)
		end
	end
end, ON.LEVEL)

set_post_entity_spawn(function(ent)
	if feelingslib.feeling_check(feelingslib.FEELING_ID.MOAI) then
		local pre_update_spawn_x, pre_update_spawn_y
		ent:set_pre_update_state_machine(function(ent)
			if ent.timer1 == 324 then
				-- The ankh is going to move the player to the spawn point during this update. Set the spawn point to be inside the moai.
				pre_update_spawn_x = state.level_gen.spawn_x
				pre_update_spawn_y = state.level_gen.spawn_y
				state.level_gen.spawn_x = roomgenlib.global_levelassembly.moai_exit.x
				state.level_gen.spawn_y = roomgenlib.global_levelassembly.moai_exit.y
				clear_callback()
			end
		end)
		ent:set_post_update_state_machine(function(ent)
			if pre_update_spawn_x then
				-- The player has been moved to inside the moai. Set the spawn point back to its original value and spawn the hedjet.
				state.level_gen.spawn_x = pre_update_spawn_x
				state.level_gen.spawn_y = pre_update_spawn_y
				remove_moai_veil()
				spawn_entity(ENT_TYPE.ITEM_PICKUP_HEDJET, roomgenlib.global_levelassembly.moai_exit.x, roomgenlib.global_levelassembly.moai_exit.y + 2, LAYER.FRONT, 0, 0)
				local sound = get_sound(VANILLA_SOUND.UI_SECRET)
				if sound then sound:play() end
				if moai_diamond_cb then
					clear_callback(moai_diamond_cb)
					moai_diamond_cb = nil
				end
				clear_callback()
			end
		end)
	end
end, SPAWN_TYPE.ANY, MASK.LOGICAL, ENT_TYPE.ITEM_POWERUP_ANKH)

local function add_moai_break_decoration(x, y, l, side)
	if x >= roomgenlib.global_levelassembly.moai_exit.x - 1 and x <= roomgenlib.global_levelassembly.moai_exit.x + 1
		and y >= roomgenlib.global_levelassembly.moai_exit.y and y <= roomgenlib.global_levelassembly.moai_exit.y + 3
	then
		local floor_ent = get_entity(get_grid_entity_at(x, y, l))
		if floor_ent and floor_ent.type.id == ENT_TYPE.FLOOR_BORDERTILE_METAL then
			local decor_ent = get_entity(spawn_entity_over(ENT_TYPE.DECORATION_GENERIC, floor_ent.uid, 0, 0))
			decor_ent:set_texture(module.MOAI_BORDER_MAIN_TEXTURE)
			decor_ent:set_draw_depth(floor_ent.draw_depth - 1)
			if side == FLOOR_SIDE.LEFT then
				decor_ent.x = -0.5
				decor_ent.animation_frame = prng:random_int(5, 7, PRNG_CLASS.LEVEL_DECO)
				decor_ent.flags = set_flag(decor_ent.flags, ENT_FLAG.FACING_LEFT)
			elseif side == FLOOR_SIDE.RIGHT then
				decor_ent.x = 0.5
				decor_ent.animation_frame = prng:random_int(5, 7, PRNG_CLASS.LEVEL_DECO)
			elseif side == FLOOR_SIDE.BOTTOM then
				decor_ent.y = -0.5
				decor_ent.animation_frame = prng:random_int(21, 23, PRNG_CLASS.LEVEL_DECO)
			elseif side == FLOOR_SIDE.TOP then
				decor_ent.y = 0.5
				decor_ent.animation_frame = prng:random_int(13, 15, PRNG_CLASS.LEVEL_DECO)
			end
		end
	end
end

set_post_entity_spawn(function(ent)
	if options.hd_debug_punish_ball_breaks_moai and feelingslib.feeling_check(feelingslib.FEELING_ID.MOAI) then
		local pre_update_timer
		ent:set_pre_update_state_machine(function(ent)
			pre_update_timer = ent.timer
		end)
		ent:set_post_update_state_machine(function(ent)
			if pre_update_timer == 0 and ent.timer > 0 and ent.standing_on_uid ~= -1 and ent.attached_to_uid ~= -1 then
				-- The ball tried to break a floor during this update. Check if the floor still exists and is a moai tile or the ground below it. The standing_on_uid takes one more frame to update even if the ball destroyed the floor.
				local floor_ent = get_entity(ent.standing_on_uid)
				if floor_ent and (floor_ent.type.id == ENT_TYPE.FLOOR_BORDERTILE_METAL or floor_ent.type.id == ENT_TYPE.FLOOR_GENERIC) then
					local x, y, l = get_position(floor_ent.uid)
					if x >= roomgenlib.global_levelassembly.moai_exit.x - 1 and x <= roomgenlib.global_levelassembly.moai_exit.x + 1
						and y >= roomgenlib.global_levelassembly.moai_exit.y - 1 and y <= roomgenlib.global_levelassembly.moai_exit.y + 3
					then
						local rubble_spawn_cb = set_post_entity_spawn(function(rubble_ent)
							rubble_ent.animation_frame = 40
						end, SPAWN_TYPE.ANY, MASK.FX, ENT_TYPE.ITEM_RUBBLE)
						floor_ent:kill(false, nil)
						clear_callback(rubble_spawn_cb)
						remove_moai_veil()
						if y >= roomgenlib.global_levelassembly.moai_exit.y then
							add_moai_break_decoration(x - 1, y, l, FLOOR_SIDE.RIGHT)
							add_moai_break_decoration(x + 1, y, l, FLOOR_SIDE.LEFT)
							add_moai_break_decoration(x, y - 1, l, FLOOR_SIDE.TOP)
							add_moai_break_decoration(x, y + 1, l, FLOOR_SIDE.BOTTOM)
						end
					end
				end
			end
		end)
	end
end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_PUNISHBALL)

return module