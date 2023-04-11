local module = {}

local moai_veil
local moai_diamond_cb

function module.init()
	moai_veil = nil
end

function module.create_moai_veil(x, y, l)
    moai_veil = spawn_entity(ENT_TYPE.DECORATION_GENERIC, x+1, y-1.5, l, 0, 0)
    local decoration = get_entity(moai_veil)
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_BORDER_MAIN_0)
    texture_def.texture_path = "res/moai_overlay.png"
    texture_def.width, texture_def.height = 384, 512
    texture_def.tile_width, texture_def.tile_height = 384, 512

    decoration:set_texture(define_texture(texture_def))
    decoration.animation_frame = 2
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

return module