local module = {}
local celib = require "lib.entities.custom_entities"
local feelingslib = require "lib.feelings"
local commonlib = require "lib.common"
--#TODO: turn into a rock upon hitting floors 

celib.init()

local function spawn_snowball_rubble(x, y, l, amount)
    for _=1, amount do
        get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, 0, 0)).animation_frame = 64
    end
end

---@param ent Entity
local function turn_into_rock(ent)
    ent.animation_frame = 16
    ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    local x, y, l = get_position(ent.uid)
    spawn_snowball_rubble(x, y, l, 5)
    -- I changed this because the drone crashing sound just didn't sound right to me
    commonlib.play_sound_at_entity(VANILLA_SOUND.SHARED_LAND, ent.uid)
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
    -- Use ENT_MORE_FLAG.HIT_GROUND and ENT_MORE_FLAG.HIT_WALL to determine if the entity has the ground / wall
    ent:set_post_update_state_machine(function(self)
        -- If we hit the ground as a snowball at a sufficient velocityy turn into a rock
        if test_flag(self.more_flags, ENT_MORE_FLAG.HIT_GROUND) and self.velocityy < 0.2 and (self.animation_frame ~= 16) then
            turn_into_rock(self)
        end
        if test_flag(self.more_flags, ENT_MORE_FLAG.HIT_WALL) and math.abs(self.velocityx) > 0.05 and (self.animation_frame ~= 16) then
            turn_into_rock(self)
        end
        -- The entity statemachine doesn't actually clear these flags, so we have to do it here
        self.more_flags = clr_flag(self.more_flags, ENT_MORE_FLAG.HIT_GROUND)
        self.more_flags = clr_flag(self.more_flags, ENT_MORE_FLAG.HIT_WALL)
        -- Make the ball roll when thrown
        self.angle = self.angle + self.velocityx
        if self.animation_frame == 16 then self.angle = 0 end
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
-- This approach is kind of expensive, but this should guarantee that whenever an entity is damaged by a rock, it becomes a snowball
-- If you want, you can add items to the mask of things that will get this callback, but items are a very common item type
set_post_entity_spawn(function(self)
    self:set_pre_damage(function(self, damage_dealer)
        if damage_dealer ~= nil then
            if damage_dealer.type.id == ENT_TYPE.ITEM_ROCK and damage_dealer.animation_frame ~= 16 then
                turn_into_rock(damage_dealer)
            end
        end
    end)
end, SPAWN_TYPE.ANY, MASK.MONSTER | MASK.PLAYER | MASK.MOUNT)
register_option_button("spawn snowball", "spawn snowball", "spawn snowball", function ()
    local x, y, l = get_position(players[1].uid)
    x, y = math.floor(x), math.floor(y)
    module.create_snowball(x+2, y, l)
end)

return module