local module = {}

local IDOLTRAP_TRIGGER = false
module.IDOL_X = nil
module.IDOL_Y = nil
module.IDOL_UID = nil

local IDOLTRAP_JUNGLE_ACTIVATETIME = 15
local idoltrap_timeout = 0
module.idoltrap_blocks = {}
module.sliding_wall_ceilings = {}

function module.init()
	IDOLTRAP_TRIGGER = false
	module.IDOL_X = nil
	module.IDOL_Y = nil
	module.IDOL_UID = nil

	idoltrap_timeout = IDOLTRAP_JUNGLE_ACTIVATETIME
	module.idoltrap_blocks = {}
    module.sliding_wall_ceilings = {}
end

local function idol_disturbance()
	if module.IDOL_UID ~= nil then
		local x, y, l = get_position(module.IDOL_UID)
        ---@type Idol
		local _entity = get_entity(module.IDOL_UID)
		return (x ~= _entity.spawn_x or y ~= _entity.spawn_y)
	end
end

local function create_ghost_at_border()
	local xmin, _, xmax, _ = get_bounds()
	-- message("xmin: " .. xmin .. " ymin: " .. ymin .. " xmax: " .. xmax .. " ymax: " .. ymax)
	
	if #players > 0 then
		local p_x, p_y, p_l = get_position(players[1].uid)
		local bx_mid = (xmax - xmin)/2
		local gx = 0
		local gy = p_y
		if p_x > bx_mid then gx = xmax+5 else gx = xmin-5 end
		spawn(ENT_TYPE.MONS_GHOST, gx, gy, p_l, 0, 0)
		toast("A terrible chill runs up your spine!")
	-- else
		-- toast("A terrible chill r- ...wait, where are the players?!?")
	end
end

-- Idol trap activation
set_callback(function()
    if IDOLTRAP_TRIGGER == false and module.IDOL_UID ~= nil and idol_disturbance() then
        IDOLTRAP_TRIGGER = true
        if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == true then
            create_ghost_at_border()
        elseif state.theme == THEME.DWELLING and module.IDOL_X ~= nil and module.IDOL_Y ~= nil then
            spawn(ENT_TYPE.LOGICAL_BOULDERSPAWNER, module.IDOL_X, module.IDOL_Y, LAYER.FRONT, 0, 0)
        elseif state.theme == THEME.JUNGLE then
            -- Break the 6 blocks under it in a row, starting with the outside 2 going in
            if #module.idoltrap_blocks > 0 then
                kill_entity(module.idoltrap_blocks[1])
                kill_entity(module.idoltrap_blocks[6])
                set_timeout(function()
                    kill_entity(module.idoltrap_blocks[2])
                    kill_entity(module.idoltrap_blocks[5])
                end, idoltrap_timeout)
                set_timeout(function()
                    kill_entity(module.idoltrap_blocks[3])
                    kill_entity(module.idoltrap_blocks[4])
                end, idoltrap_timeout*2)
            end
        elseif state.theme == THEME.TEMPLE then
            if feelingslib.feeling_check(feelingslib.FEELING_ID.SACRIFICIALPIT) == true then -- Kali pit temple trap
                -- Break all 4 blocks under it at once
                for i = 1, #module.idoltrap_blocks, 1 do
                    kill_entity(module.idoltrap_blocks[i])
                end
            else -- Normal temple trap
                -- sliding doors
                for _, sliding_wall_ceiling in ipairs(module.sliding_wall_ceilings) do
                    local ent = get_entity(sliding_wall_ceiling)
                    ent.state = 0
                end

                local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_FLOORSTYLED_TEMPLE_0)
                texture_def.texture_path = "res/floorstyled_temple_idoltrap_ceiling_post.png"
                for i = 1, #module.idoltrap_blocks, 1 do
                    local floor = get_entity(module.idoltrap_blocks[i])
                    -- Code provided by Dregu
                    if floor ~= -1 then
                        local cx, cy, cl = get_position(floor.uid)
                        kill_entity(floor.uid)
                        local block = get_entity(spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, cx, cy, cl, 0, 0))
                        block.flags = set_flag(block.flags, ENT_FLAG.NO_GRAVITY)
                        block.more_flags = set_flag(block.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
                        block.velocityy = -0.01
                        
                        block:set_texture(define_texture(texture_def))
                        block.animation_frame = 27
                    end
                end
            end
        end
    elseif IDOLTRAP_TRIGGER == true and module.IDOL_UID ~= nil and state.theme == THEME.DWELLING then
        boulderlib.onframe_ownership_crush_prevention()
    end
end, ON.FRAME)

return module