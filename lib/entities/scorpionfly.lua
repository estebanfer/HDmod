local module = {}

-- Setup texture sheet
local scorpionfly_texture_id
do
    local scorpionfly_texture_def = TextureDefinition.new()
    scorpionfly_texture_def.width = 1152
    scorpionfly_texture_def.height = 384
    scorpionfly_texture_def.tile_width = 128
    scorpionfly_texture_def.tile_height = 128
    scorpionfly_texture_def.texture_path = 'res/scorpionfly.png'
    scorpionfly_texture_id = define_texture(scorpionfly_texture_def)
end

-- Create a custom entity with the sacrafice value in HD
local MONS_SCORPIONFLY = EntityDB:new(ENT_TYPE.MONS_SCORPION)
MONS_SCORPIONFLY.sacrifice_value = 6

-- Animations
local ANIMATION_INFO = {
    IDLE = {
        start = 0;
        finish = 3;
        speed = 7;
    };
    WALK = {
        start = 9;
        finish = 13;
        speed = 6;
    };
    ATTACK = {
        start = 5;
        finish = 8;
        speed = 6;
    };
    FLY = {
        start = 18;
        finish = 23;
        speed = 3;
    };
    STUN = {
        start = 14;
        finish = 14;
        speed = 1;
    };
}

-- State enum
local SCORPIONFLY_STATE = {
    ATTACK = 1;
    FLY = 2;
    SCORPION = 3;
}

local function state_fly(self)
    -- No gravity 
    self.flags = set_flag(self.flags, ENT_FLAG.NO_GRAVITY)

    -- Position the scorpion around the mosquito
    if get_entity(self.user_data.mosquito.uid) ~= nil then
        local sx, sy, sl = get_position(self.user_data.mosquito.uid)
        move_entity(self.uid, sx, sy, 0, 0)
    end

    -- Remove the scorpions own AI
    self.jump_cooldown_timer = 100
    self.move_state = 30
    self.state = 30
    self.lock_input_timer = 5

    -- Scorpion faces the direction the mosqutio is moving
    if test_flag(self.flags, ENT_FLAG.FACING_LEFT) and not test_flag(self.user_data.mosquito.flags, ENT_FLAG.FACING_LEFT) then
        flip_entity(self.uid)       
    end
    if not test_flag(self.flags, ENT_FLAG.FACING_LEFT) and test_flag(self.user_data.mosquito.flags, ENT_FLAG.FACING_LEFT) then
        flip_entity(self.uid)       
    end

    -- Enter attack state when a player is in range
    for _, v in ipairs(get_entities_by({0}, MASK.PLAYER, self.layer)) do
        local char = get_entity(v)
        local dist = distance(char.uid, self.uid)
        if dist <= 5 then
            self.user_data.state = SCORPIONFLY_STATE.ATTACK
            self.user_data.target = char
            -- Kill the mosqutio since its no longer needed and we can't re-enter this state
            self.user_data.mosquito:destroy()
            break
        end
    end
end
local function state_chase(self)
    -- I was originally going to do this using a bat but there's no way to get rid of their obnoxious bat noises!
    local target = self.user_data.target
    -- No gravity 
    self.flags = set_flag(self.flags, ENT_FLAG.NO_GRAVITY)

    -- Remove the scorpions own AI
    self.jump_cooldown_timer = 100
    self.move_state = 30
    self.state = 30
    self.lock_input_timer = 5

    -- Move towards chased target
    if target ~= nil then
        local dist = distance(target.uid, self.uid)
        local tx, ty, _ = get_position(target.uid)
        local sx, sy, _ = get_position(self.uid)
        local abs_x = (sx - tx)
        local abs_y = (sy - ty)
        local move_rate = 0.0475
        local movex = (abs_x/dist)*move_rate
        local movey = (abs_y/dist)*move_rate
        -- Minimum speed for movex and movey
        if movex > 0 then
            if movex < 0.015 then
                movex = 0.015
            end
        elseif movex < 0 then
            if movex > -0.015 then
                movex = -0.015
            end            
        end
        if movey > 0 then
            if movey < 0.015 then
                movey = 0.015
            end
        elseif movey < 0 then
            if movey > -0.015 then
                movey = -0.015
            end            
        end
        if math.abs(abs_x) < 0.015 then
            movex = 0
        end
        if math.abs(abs_y) < 0.02 then
            movey = 0
        end
        move_entity(self.uid, sx-movex, sy-movey, 0, 0)
        -- Face direction moving
        if abs_x > 0 and not test_flag(self.flags, ENT_FLAG.FACING_LEFT) then
            flip_entity(self.uid)         
        end
        if abs_x < 0 and test_flag(self.flags, ENT_FLAG.FACING_LEFT) then
            flip_entity(self.uid)         
        end
    end
end
local function state_scorpion(self)
    -- This state just uses the regular scorpion AI for the most part, we just need to properly update the animations since we use a custom texture sheet

    -- ai state 1 == walk
    -- ai state 0 == idle
    -- ai state 5 =  attack
    if self.stun_timer == 0 then
        if self.move_state == 0 then
            if self.user_data.animation_info ~= ANIMATION_INFO.IDLE then
                self.user_data.animation_frame = 0
                self.user_data.animation_info = ANIMATION_INFO.IDLE
            end
        elseif self.move_state == 5 and not self:can_jump() then
            if self.user_data.animation_info ~= ANIMATION_INFO.ATTACK then
                self.user_data.animation_frame = 5
                self.user_data.animation_info = ANIMATION_INFO.ATTACK
            end
            -- Lock the animation to the last frame when falling
            if self.velocityy < 0 then
                self.user_data.animation_frame = 8
                self.user_data.animation_timer = 0
                self.animation_frame = 8
            end          
        elseif (self.move_state == 1) or (self.velocityx ~= 0 and self:can_jump()) then
            if self.user_data.animation_info ~= ANIMATION_INFO.WALK then
                self.user_data.animation_frame = 9
                self.user_data.animation_info = ANIMATION_INFO.WALK
            end
        end
    else
        self.user_data.animation_frame = 14
        self.user_data.animation_info = ANIMATION_INFO.STUN
    end
end

local function become_scorpion(self, _, amount)
    if amount - self.health ~= 0 then
        local d = self.user_data
        -- Change state
        d.state = SCORPIONFLY_STATE.SCORPION
        -- Change gravity flag and restore state info
        self.flags = clr_flag(self.flags, ENT_FLAG.NO_GRAVITY)

        self.jump_cooldown_timer = 60
        self.move_state = 0
        self.state = 1
        self.lock_input_timer = 0

        -- Kill the extra entities used
        if get_entity(d.bee.uid) ~= nil then
            d.bee:destroy()
        end
    end
end

local function scorpionfly_update(self)
    -- ANIMATION
    -- Increase animation timer
    self.user_data.animation_timer = self.user_data.animation_timer + 1
    --- Animate the entity and reset the timer
    if self.user_data.animation_timer >= self.user_data.animation_info.speed then
        self.user_data.animation_timer = 1
        -- Advance the animation
        self.user_data.animation_frame = self.user_data.animation_frame + 1
        -- Loop if the animation has reached the end
        if self.user_data.animation_frame > self.user_data.animation_info.finish then
            self.user_data.animation_frame = self.user_data.animation_info.start
        end
    end
    -- Change the actual animation frame
    self.animation_frame = self.user_data.animation_frame

    -- Place the bee on the scorpionfly for the bees sound effects
    if self.user_data.bee.type.id == ENT_TYPE.MONS_BEE then
        self.user_data.bee.x = self.x
        self.user_data.bee.y = self.y
    end

    -- STATEMACHINE
    local d = self.user_data
    if d.state == SCORPIONFLY_STATE.FLY then
        state_fly(self)
    elseif d.state == SCORPIONFLY_STATE.ATTACK then
        state_chase(self)        
    elseif d.state == SCORPIONFLY_STATE.SCORPION then
        state_scorpion(self)
    end
end

local function scorpionfly_set(self)
    -- This custom type awards the player 6 favor like in HD
    self.type = MONS_SCORPIONFLY
    -- Userdata stuff
    self.user_data = {
        ent_type = HD_ENT_TYPE.MONS_SCORPIONFLY;

        -- ANIMATION
        animation_timer = 1;
        animation_frame = 0;
        animation_info = ANIMATION_INFO.FLY; -- Info about animation speed, start frame, stop frame

        -- AI 
        state = SCORPIONFLY_STATE.FLY;
        previous_state = SCORPIONFLY_STATE.FLY;

        target = nil;

        -- We use the mosquito for its wandering behavior
        mosquito = get_entity(spawn(ENT_TYPE.MONS_MOSQUITO, self.x, self.y, self.layer, 0, 0));
        -- Bee for the sound effects
        bee = get_entity(spawn(ENT_TYPE.MONS_BEE, self.x, self.y, self.layer, 0, 0));
    };
    self.user_data.animation_frame = self.user_data.animation_info.start
    -- Make the mosquito inactive
    self.user_data.mosquito.flags = set_flag(self.user_data.mosquito.flags, ENT_FLAG.INVISIBLE)
    self.user_data.mosquito.flags = set_flag(self.user_data.mosquito.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
    -- Same for the bee
    self.user_data.bee.flags = set_flag(self.user_data.bee.flags, ENT_FLAG.INVISIBLE)
    self.user_data.bee.flags = set_flag(self.user_data.bee.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
    -- Remove the mosquito sounds
    self.user_data.mosquito:set_post_update_state_machine(function(mosq)
        -- Remove the Mosquitos sound
        mosq.sound.playing = false
    end)
    -- No gravity since this starts as a flying entity
    self.flags = set_flag(self.flags, ENT_FLAG.NO_GRAVITY)
    self:set_texture(scorpionfly_texture_id)
    -- Set up the damage callback for turning the scorpionfly into a scorpion
    self:set_pre_damage(function(self, _, amount)
        become_scorpion(self, _, amount)
    end)
    -- Statemachine
    self:set_post_update_state_machine(scorpionfly_update)
    -- Custom gibs
    self:set_pre_kill(function(self)
        local sx, sy, sl = get_position(self.uid)
        -- Make our own rubble and blood
        -- TODO no idea how to color rubble right, the values I tweaked in OL dont transfer to these values
        local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, sx, sy, sl, -0.05, 0.015))
        rubble.color:set_rgba(255, 80, 20, 255)
        rubble.animation_frame = 39
        local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, sx, sy, sl, 0.05, 0.015))
        rubble.color:set_rgba(255, 80, 20, 255)
        rubble.animation_frame = 39
        -- Defeat sfx
        local audio = commonlib.play_vanilla_sound(VANILLA_SOUND.SHARED_DAMAGED, self.uid, 1, false)
        audio:set_volume(1)
        audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, 2)
        -- Spawn a spider for the blood
        local spider = get_entity(spawn(ENT_TYPE.MONS_SPIDER, sx, sy, sl, 0, 0))
        spider:kill(true, nil)
        -- move original entity OOB
        self.x = -900
    end)
end

function module.create_scorpionfly(x, y, l)
    local fly = get_entity(spawn(ENT_TYPE.MONS_SCORPION, x, y, l, 0, 0))
    scorpionfly_set(fly)
end

optionslib.register_entity_spawner("Scorpionfly", module.create_scorpionfly, false)

return module