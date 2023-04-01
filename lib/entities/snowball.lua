local module = {}
local celib = require "lib.entities.custom_entities"
local feelingslib = require "lib.feelings"
local commonlib = require "lib.common"
--#TODO: turn into a rock upon hitting floors 

celib.init()

local function spawn_snowball_rubble(x, y, l, amount)
    for _=1, amount do
        get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, 0, 0)).animation_frame = 6
    end
end

---@param ent Entity
local function turn_into_rock(ent)
    ent.animation_frame = 16
    ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    local x, y, l = get_position(ent.uid)
    spawn_snowball_rubble(x, y, l, 5)
    commonlib.play_sound_at_entity(VANILLA_SOUND.CRITTERS_DRONE_CRASH, ent.uid)
end

---@param self Entity
local function check_for_damage(self, damage_dealer, damage_amount, velocity_x, velocity_y, stun_amount, iframes)
    if (self.animation_frame ~= 16) then
        turn_into_rock(self)
    end
end

---@param ent Movable
local function snowball_set(ent)
    ent.animation_frame = 222
    ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    set_on_damage(ent.uid, check_for_damage)
    ent:set_pre_on_collision2(function (self, other_entity)
        if (self.animation_frame ~= 16 and (self.velocityx >= math.abs(0.1) or self.velocityy >= math.abs(0.1))) then
            turn_into_rock(self)
        end
    end)
end

local snowball_id = celib.new_custom_entity(snowball_set, function() end, celib.CARRY_TYPE.HELD, ENT_TYPE.ITEM_ROCK)

function module.create_snowball(x, y, layer)
    local uid = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_ROCK, x, y, layer)
    celib.set_custom_entity(uid, snowball_id)
    return uid
end

set_pre_entity_spawn(function(ent_type, x, y, l, overlay, spawn_flags)
    if (
		spawn_flags & SPAWN_TYPE.SCRIPT == 0
        and (
            feelingslib.feeling_check(feelingslib.FEELING_ID.SNOWING)
            or feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)
        )
    ) then
        return module.create_snowball(x, y, l)
    end
end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, ENT_TYPE.ITEM_ROCK)

register_option_button("spawn snowball", "spawn snowball", "spawn snowball", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    module.create_snowball(x+2, y, l)
end)

return module