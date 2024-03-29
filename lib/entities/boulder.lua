local module = {}

optionslib.register_option_bool("hd_debug_boulder_info", "Boulder - Show info", nil, false, true)

local BOULDER_UID = nil
local BOULDER_SX = nil
local BOULDER_SY = nil
local BOULDER_SX2 = nil
local BOULDER_SY2 = nil
local BOULDER_CRUSHPREVENTION_EDGE = 0.15
local BOULDER_CRUSHPREVENTION_HEIGHT = 0.3
local BOULDER_CRUSHPREVENTION_VELOCITY = 0.16
local BOULDER_CRUSHPREVENTION_MULTIPLIER = 2.5
local BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
local BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
local BOULDER_DEBUG_PLAYERTOUCH = false

function module.init()
	BOULDER_UID = nil
	BOULDER_SX = nil
	BOULDER_SY = nil
	BOULDER_SX2 = nil
	BOULDER_SY2 = nil
	BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
	BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
	BOULDER_DEBUG_PLAYERTOUCH = false
end

function module.onframe_ownership_crush_prevention()
    if BOULDER_UID == nil then -- boulder ownership
        local boulders = get_entities_by_type(ENT_TYPE.ACTIVEFLOOR_BOULDER)
        if boulders[1] then
            BOULDER_UID = boulders[1]
            -- Obtain the last owner of the idol upon disturbing it. If no owner caused it, THEN select the first player alive.
            local boulder = get_entity(BOULDER_UID)

            for i, player in ipairs(players) do
                boulder.last_owner_uid = player.uid
            end
        end
    else -- boulder crush prevention
        ---@type Boulder
        local boulder = get_entity(BOULDER_UID)
        if boulder ~= nil then
            boulder = get_entity(BOULDER_UID)
            local x, y, l = get_position(BOULDER_UID)
            BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
            BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
            if boulder.velocityx >= BOULDER_CRUSHPREVENTION_VELOCITY or boulder.velocityx <= -BOULDER_CRUSHPREVENTION_VELOCITY then
                BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE*BOULDER_CRUSHPREVENTION_MULTIPLIER
                BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT*BOULDER_CRUSHPREVENTION_MULTIPLIER
            else 
                BOULDER_CRUSHPREVENTION_EDGE_CUR = BOULDER_CRUSHPREVENTION_EDGE
                BOULDER_CRUSHPREVENTION_HEIGHT_CUR = BOULDER_CRUSHPREVENTION_HEIGHT
            end
            BOULDER_SX = ((x - boulder.hitboxx)-BOULDER_CRUSHPREVENTION_EDGE_CUR)
            BOULDER_SY = ((y + boulder.hitboxy)+BOULDER_CRUSHPREVENTION_HEIGHT_CUR)
            BOULDER_SX2 = ((x + boulder.hitboxx)+BOULDER_CRUSHPREVENTION_EDGE_CUR)
            BOULDER_SY2 = ((y + boulder.hitboxy)-BOULDER_CRUSHPREVENTION_EDGE_CUR)
            local blocks = get_entities_overlapping_hitbox(
                {ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, ENT_TYPE.ACTIVEFLOOR_POWDERKEG},
                0,
                AABB:new(
                    BOULDER_SX,
                    BOULDER_SY,
                    BOULDER_SX2,
                    BOULDER_SY2
                ),
                LAYER.FRONT
            )
            for _, block in ipairs(blocks) do
                kill_entity(block)
            end
            if options.hd_debug_boulder_info == true then
                local touching = get_entities_overlapping_hitbox(
                    0,
                    0x1,
                    AABB:new(
                        BOULDER_SX,
                        BOULDER_SY,
                        BOULDER_SX2,
                        BOULDER_SY2
                    ),
                    LAYER.FRONT
                )
                if touching[1] then BOULDER_DEBUG_PLAYERTOUCH = true else BOULDER_DEBUG_PLAYERTOUCH = false end
            end
        -- else message("Boulder crushed :(")
        end
    end
end

---@param draw_ctx GuiDrawContext
set_callback(function(draw_ctx)
	if options.hd_debug_boulder_info == true and (state.pause == 0 and state.screen == 12 and #players > 0) then
		if (
			state.theme == THEME.DWELLING and
			(state.level == 2 or state.level == 3 or state.level == 4)
		) then
			local text_x = -0.95
			local text_y = -0.45
			local green_hitbox = rgba(153, 196, 19, 170)
			local white = rgba(255, 255, 255, 255)
            local text_boulder_uid
			if BOULDER_UID == nil then text_boulder_uid = "No Boulder Onscreen"
			else text_boulder_uid = tostring(BOULDER_UID) end
			
			local sx = BOULDER_SX
			local sy = BOULDER_SY
			local sx2 = BOULDER_SX2
			local sy2 = BOULDER_SY2
			
			draw_ctx:draw_text(text_x, text_y, 0, "BOULDER_UID: " .. text_boulder_uid, white)
			
			if BOULDER_UID ~= nil and sx ~= nil and sy ~= nil and sx2 ~= nil and sy2 ~= nil then
				text_y = text_y-0.1

				draw_ctx:draw_rect_filled(screen_aabb(AABB:new(sx, sy, sx2, sy2)), 0, green_hitbox)
				
				local text_boulder_sx = tostring(sx)
				local text_boulder_sy = tostring(sy)
				local text_boulder_sx2 = tostring(sx2)
				local text_boulder_sy2 = tostring(sy2)
                local text_boulder_touching
				if BOULDER_DEBUG_PLAYERTOUCH == true then text_boulder_touching = "Touching!" else text_boulder_touching = "Not Touching." end
				
				draw_ctx:draw_text(text_x, text_y, 0, "SX: " .. text_boulder_sx, white)
				text_y = text_y-0.1
				draw_ctx:draw_text(text_x, text_y, 0, "SY: " .. text_boulder_sy, white)
				text_y = text_y-0.1
				draw_ctx:draw_text(text_x, text_y, 0, "SX2: " .. text_boulder_sx2, white)
				text_y = text_y-0.1
				draw_ctx:draw_text(text_x, text_y, 0, "SY2: " .. text_boulder_sy2, white)
				text_y = text_y-0.1
				
				draw_ctx:draw_text(text_x, text_y, 0, "Player touching top of hitbox: " .. text_boulder_touching, white)
			end
		end
	end
end, ON.GUIFRAME)

return module