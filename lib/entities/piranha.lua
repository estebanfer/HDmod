local nosacrifice = require "lib.entities.nosacrifice_items"
local celib = require "lib.entities.custom_entities"
local piranha_item_id

local function b(flag) return (1 << (flag-1)) end

local piranha_skeleton_tex_id
do
    local tex_def = TextureDefinition.new()
    tex_def.width = 2048
    tex_def.height = 2048
    tex_def.tile_width = 128
    tex_def.tile_height = 128

    tex_def.texture_path = "res/piranha_skeleton.png" 
    piranha_skeleton_tex_id = define_texture(tex_def)
end

local function filter_solids(ent)
    return test_flag(ent.flags, ENT_FLAG.SOLID)
end

local function set_piranha_skeleton(ent)
    ent.hitboxx = 0.35
    ent.hitboxy = 0.25
    nosacrifice.add_uid(ent.uid)
	ent.animation_frame = 105
    ent:set_texture(piranha_skeleton_tex_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_PIRANHA;
    };
end

local function get_solids_overlapping(hitbox, layer)
    return filter_entities(
		get_entities_overlapping_hitbox(0, MASK.FLOOR | MASK.ACTIVEFLOOR, hitbox, layer),
		filter_solids)
end

local function piranha_move(ent)
    local vx = test_flag(ent.flags, ENT_FLAG.FACING_LEFT) and -1 or 1
    if get_solids_overlapping(get_hitbox(ent.uid, 0, 0.01*vx), ent.layer)[1] then
        ent.flags = ent.flags ~ b(ENT_FLAG.FACING_LEFT)
        vx = vx * -1
    end
    ent.velocityx = vx * 0.05
    local hitbox = get_hitbox(ent.uid, 0, 0, 0.15):extrude(-0.2)
    if not get_entities_overlapping_hitbox(0, MASK.WATER, hitbox, ent.layer)[1] then
        ent.velocityy = ent.velocityy - 0.01
    else
        ent.velocityy = 0
    end
end

---@param ent Tadpole
local function chase_target(ent, px, py)
    --price betweem -30, -10 and 10, 30
    ent.price = ent.price > 0
        and (ent.price > 10 and ent.price - 1 or -30)
        or (ent.price < -10 and ent.price + 1 or 30)

    local tx, ty = get_position(ent.chased_target_uid)
    local xdiff, ydiff = tx - px, ty - py
    local dist = distance(ent.uid, ent.chased_target_uid) * 20
    local vx, vy = xdiff / dist, ydiff / dist
    local hitbox = get_hitbox(ent.uid, 0, vx, vy+0.15):extrude(-0.25)
    if not get_entities_overlapping_hitbox(0, MASK.WATER, hitbox, ent.layer)[1] then
        vy = math.min(ent.velocityy, 0.0)

        local vel_off = ent.price * 0.0015
        if math.abs(vx) < 0.035 then
            vx = vx + vel_off
        end
    elseif get_solids_overlapping(get_hitbox(ent.uid):offset(vx, vy):extrude(-0.025), ent.layer)[1] then
        local vel_off = ent.price * 0.0015
        if math.abs(vx) > math.abs(vy) then
            vy = vy + vel_off
        else
            vx = vx + vel_off
        end
    end
    --vel_off is for the thing that hd does when the piranha wants to move in a direction but there's a block there. I didn't look how it works in hd

    ent.velocityx, ent.velocityy = vx, vy
    ent.flags = xdiff > 0 and clr_flag(ent.flags, ENT_FLAG.FACING_LEFT) or set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
end

local function get_closest_targetable_player(piranha_uid, players_close)
    local ret_ent, last_dist = nil, 100.0
    for _, uid in ipairs(players_close) do
        ---@type Player
        local chased = get_entity(uid)
        if chased.wet_effect_timer == 300 then
            local dist = distance(piranha_uid, uid)
            if dist < last_dist then
                last_dist = dist
                ret_ent = chased
            end
        end
    end
    return ret_ent, last_dist
end

---@param ent Tadpole
local function piranha_update(ent)
    --ent.animation_frame = get_frame() % 8 --check how many frames piranha has
    if ent.wet_effect_timer < 300 and ent.standing_on_uid ~= -1 then
        if ent.wet_effect_timer < 150 then
            local x, y, l = get_position(ent.uid)
            celib.spawn_custom_entity(piranha_item_id, x, y, l, 0, 0)
            if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
                ent:destroy()
            else
                kill_entity(ent.uid)
            end
        end
        ent.lock_input_timer = 0
        ent.chased_target_uid = -1
        return
    end
    ent.lock_input_timer = 512

    ---@type Player | nil
    local chased = get_entity(ent.chased_target_uid)
    if not chased or distance(ent.uid, ent.chased_target_uid) > 6.0
        or (chased.wet_effect_timer ~= 300 or test_flag(chased.flags, ENT_FLAG.DEAD)) then
        local closest, dist = get_closest_targetable_player(ent.uid, get_entities_by(0, MASK.PLAYER, LAYER.FRONT))
        if closest and ((dist < 6.0 and not test_flag(closest.flags, ENT_FLAG.DEAD)) or chased == closest) then
            ent.chased_target_uid = closest.uid
            chased = closest ---@type Player | nil
        else
            chased = nil
            ent.chased_target_uid = -1
        end
    end
    if chased and chased.invincibility_frames_timer == 0 then
        local px, py = get_position(ent.uid)
        chase_target(ent, px, py)
    else
        piranha_move(ent)
    end
end

--[[register_option_button("spawn_piranha", "spawn_piranha", "spawn_piranha", function ()
    local x, y, l = get_position(players[1].uid)
    local uid = spawn(ENT_TYPE.MONS_TADPOLE, x, y, l, 0, 0)
    set_post_statemachine(uid, piranha_update)
end)]]

local function spawn_piranha_skeleton_rubble(x, y, l, amount)
    for _=1, amount do
        get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, 0, 0)).animation_frame = 6
    end
end

piranha_item_id = celib.new_custom_entity(set_piranha_skeleton, function() end, celib.CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK)

local module = {}

function module.create_piranha(x, y, l)
	local uid = spawn_grid_entity(ENT_TYPE.MONS_TADPOLE, x, y, l)
    set_post_statemachine(uid, piranha_update)
	if feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) then
		get_entity(uid):set_texture(piranha_skeleton_tex_id)
        ---@param ent Tadpole
        set_on_kill(uid, function (ent)
            commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_KILLED_ENEMY_BONES, ent.uid)
            local px, py, pl = get_position(ent.uid)
            move_entity(ent.uid, 500, -500, 0.0, 0.0)
            spawn_piranha_skeleton_rubble(px, py, pl, 2)
            ent:destroy()
        end)
	end
end

return module