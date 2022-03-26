local module = {}

-- register_option_float("hd_ui_botd_a_w", "UI: botd width", 0.08, 0.0, 99.0)
-- register_option_float("hd_ui_botd_b_h", "UI: botd height", 0.12, 0.0, 99.0)
-- register_option_float("hd_ui_botd_c_x", "UI: botd x", 0.2, -999.0, 999.0)
-- register_option_float("hd_ui_botd_d_y", "UI: botd y", 0.93, -999.0, 999.0)
-- register_option_float("hd_ui_botd_e_squash", "UI: botd uvx shifting rate", 0.25, -5.0, 5.0)

BOOKOFDEAD_TIC_LIMIT = 5
BOOKOFDEAD_RANGE = 14

module.hell_x = 0
module.bookofdead_tick = 0
module.bookofdead_frames_index = 1
BOOKOFDEAD_FRAMES = 4
BOOKOFDEAD_SQUASH = (1/BOOKOFDEAD_FRAMES) --options.hd_ui_botd_e_squash

module.OBTAINED_BOOKOFDEAD = false

UI_BOTD_IMG_ID, UI_BOTD_IMG_W, UI_BOTD_IMG_H = create_image('res/bookofdead.png')
UI_BOTD_PLACEMENT_W = 0.08
UI_BOTD_PLACEMENT_H = 0.12
UI_BOTD_PLACEMENT_X = 0.2
UI_BOTD_PLACEMENT_Y = 0.93

function module.create_botd(x, y, l)
    local bookofdead_pickup_id = spawn(ENT_TYPE.ITEM_PICKUP_TABLETOFDESTINY, x+0.5, y, l, 0, 0)
    local book_ = get_entity(bookofdead_pickup_id):as_movable()
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
    texture_def.texture_path = "res/items_botd.png"
    book_:set_texture(define_texture(texture_def))
end

-- removes all types of an entity from any player that has it.
function remove_player_item(powerup, player)
	local powerup_uids = get_entities_by_type(powerup)
	for i = 1, #powerup_uids, 1 do
		for j = 1, #players, 1 do
			if entity_has_item_uid(players[j].uid, powerup_uids[i]) then
				entity_remove_item(players[j].uid, powerup_uids[i])
			end
		end
	end
end

function module.set_hell_x()
    module.hell_x = math.random(4, 41)
end

function animate_bookofdead(tick_limit)
	if module.bookofdead_tick <= tick_limit then
		module.bookofdead_tick = module.bookofdead_tick + 1
	else
		if module.bookofdead_frames_index == BOOKOFDEAD_FRAMES then
			module.bookofdead_frames_index = 1
		else
			module.bookofdead_frames_index = module.bookofdead_frames_index + 1
		end
		module.bookofdead_tick = 0
	end
end

-- Book of dead animating
set_callback(function()
	if state.pause == 0 and state.screen == 12 and #players > 0 then
		if module.OBTAINED_BOOKOFDEAD == true then
			local w = UI_BOTD_PLACEMENT_W
			local h = UI_BOTD_PLACEMENT_H
			local x = UI_BOTD_PLACEMENT_X
			local y = UI_BOTD_PLACEMENT_Y
			local uvx1 = 0
			local uvy1 = 0
			local uvx2 = BOOKOFDEAD_SQUASH
			local uvy2 = 1
			
			if state.theme == THEME.OLMEC then
				local hellx_min = module.hell_x - math.floor(BOOKOFDEAD_RANGE/2)
				local hellx_max = module.hell_x + math.floor(BOOKOFDEAD_RANGE/2)
				local p_x, p_y, p_l = get_position(players[1].uid)
				if (p_x >= hellx_min) and (p_x <= hellx_max) then
					animate_bookofdead(0.6*((p_x - module.hell_x)^2) + BOOKOFDEAD_TIC_LIMIT)
				else
					bookofdead_tick = 0
					module.bookofdead_frames_index = 1
				end
			elseif state.theme == THEME.VOLCANA then
				if state.level == 1 then
					animate_bookofdead(12)
				elseif state.level == 2 then
					animate_bookofdead(8)
				elseif state.level == 3 then
					animate_bookofdead(4)
				else
					animate_bookofdead(2)
				end
			end
			
			uvx1 = -BOOKOFDEAD_SQUASH*(module.bookofdead_frames_index-1)
			uvx2 = BOOKOFDEAD_SQUASH - BOOKOFDEAD_SQUASH*(module.bookofdead_frames_index-1)
			
			-- draw_text(x-0.1, y, 0, tostring(bookofdead_tick), rgba(234, 234, 234, 255))
			-- draw_text(x-0.1, y-0.1, 0, tostring(module.bookofdead_frames_index), rgba(234, 234, 234, 255))
			draw_image(UI_BOTD_IMG_ID, x, y, x+w, y-h, uvx1, uvy1, uvx2, uvy2, 0xffffffff)
		end
	end
end, ON.GUIFRAME)


-- # TODO: Turn into a custom inventory system that works for all players.
set_callback(function()
    if module.OBTAINED_BOOKOFDEAD == false then
        for i = 1, #players, 1 do
            if entity_has_item_type(players[i].uid, ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) then
                -- # TODO: Move into the method that spawns Anubis II in COG
                toast("Death to the defiler!")
                module.OBTAINED_BOOKOFDEAD = true
                set_timeout(function() remove_player_item(ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY) end, 1)
            end
        end
    end
end, ON.FRAME)

return module