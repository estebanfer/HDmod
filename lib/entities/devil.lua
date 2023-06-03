local module = {}

-- Setup texture sheet
local devil_texture_id
do
    local devil_texture_def = TextureDefinition.new()
    devil_texture_def.width = 1152
    devil_texture_def.height = 384
    devil_texture_def.tile_width = 128
    devil_texture_def.tile_height = 128
    devil_texture_def.texture_path = 'res/devil.png'
    devil_texture_id = define_texture(devil_texture_def)
end
-- Sound effect path
local devil_charge = create_sound('res/sounds/devilcharge.wav')
local devil_defeat = create_sound('res/sounds/devildeath.wav')
local demon_sound_volume = 0.4

-- Animations
local ANIMATION_INFO = {
    IDLE = {
        start = 0;
        finish = 0;
        speed = 1;
    };
    WALK = {
        start = 1;
        finish = 8;
        speed = 7;
    };
    CHARGE_JUMP = {
        start = 9;
        finish = 11;
        speed = 4;
    };
    JUMP = {
        start = 12;
        finish = 12;
        speed = 1;
    };
    CHARGE = {
        start = 18;
        finish = 25;
        speed = 5;
    };
    -- For the stun  frames we are going to see what the game puts the animation frame to by default and translate that over to our texture sheet
}

-- State enum
local DEVIL_STATE = {
    VANILLA = 1;
    CHARGE = 2;
    JUMP = 3;
}
local function animate_entity(self)
    if self.user_data.custom_animation then
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
    end
end

local function state_jump(self)
    -- Stop tikiman from being able to enter state 6
    if self.move_state == 6 then
        self.move_state = 0
    end
    -- Reduce jump timer
    self.user_data.jump_delay = self.user_data.jump_delay - 1
    -- Jump at 0
    if self.user_data.jump_delay == 0 then
        self.velocityy = 0.31
        -- Sound effect
        local audio = devil_charge:play()
        local x, y, _ = get_position(self.uid)
        local sx, sy = screen_position(x, y)
        local d = screen_distance(distance(self.uid, self.uid))
        if players[1] ~= nil then
            d = screen_distance(distance(self.uid, players[1].uid))
        end
        audio:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx)*1.5)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy)*1.5)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
        audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, demon_sound_volume)
        audio:set_volume(demon_sound_volume)
        
        audio:set_pause(false)
        -- Jump sound
        set_timeout(function()
            local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_JUMP, self.uid)
            audio:set_volume(1)        
        end, 1)
        
    end
    -- Jumping animation
    if self.user_data.jump_delay <= 0 then
        self.user_data.animation_info = ANIMATION_INFO.JUMP
        self.user_data.animation_frame = 12
        -- Destroy walls that he jumps into
        local hb = get_hitbox(self.uid, -0.125, 0, 0.3)
        for _, v in ipairs(get_entities_overlapping_hitbox({0}, MASK.FLOOR | MASK.ACTIVEFLOOR, hb, self.layer)) do
            local w = get_entity(v)
            if test_flag(w.flags, ENT_FLAG.SOLID) and not test_flag(w.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) and test_flag(self.flags, ENT_FLAG.COLLIDES_WALLS) then
                -- Destroy the wall + knockback and stun the devil
                w:kill(false, self)
                self.velocityy = 0.11
                self.velocityx = 0.07
                self.user_data.state = DEVIL_STATE.VANILLA
                self:stun(30)     
                commonlib.shake_camera(10, 10, 5, 5, 5, false)
                -- Collision sound
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_LAND, self.uid)
                audio:set_volume(demon_sound_volume)
                break 
            end
        end
    end
    -- Exit this state if we get stunned by some outside source (whipped by player or stuck in web)
    if self.stun_timer ~= 0 or test_flag(self.flags, ENT_FLAG.DEAD) then
        self.user_data.state = DEVIL_STATE.VANILLA 
        self.user_data.animation_info = ANIMATION_INFO.IDLE
        self.animation_frame = 13
        self.user_data.animation_frame = 13       
    end
    -- Return to vanilla state when landing
    if self:can_jump() and self.user_data.jump_delay <= -10 then
        self.user_data.state = DEVIL_STATE.VANILLA
        self.user_data.animation_info = ANIMATION_INFO.IDLE
        self.user_data.animation_frame = 0
        self.user_data.jump_delay = 7
        self.user_data.jump_cooldown = 30
    end
end
local function state_charge(self)
    -- Keep running until we hit a wall
    -- Speed boost
    if self.movex ~= 0 then
        self.x = self.x + 0.025*self.movex
    end
    -- Detect wall and destroy it
    if not test_flag(self.flags, ENT_FLAG.FACING_LEFT) then
        local hb = get_hitbox(self.uid, -0.125, 0.37, 0)
        for _, v in ipairs(get_entities_overlapping_hitbox({0}, MASK.FLOOR | MASK.ACTIVEFLOOR, hb, self.layer)) do
            local w = get_entity(v)
            if test_flag(w.flags, ENT_FLAG.SOLID) and not test_flag(w.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) and test_flag(self.flags, ENT_FLAG.COLLIDES_WALLS) then
                -- Destroy the wall + knockback and stun the devil
                w:kill(false, self)
                self.velocityy = 0.11
                self.velocityx = -0.07
                self.user_data.state = DEVIL_STATE.VANILLA
                self:stun(240)
                commonlib.shake_camera(10, 10, 5, 5, 5, false)
                -- Collision sound
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_LAND, self.uid)
                audio:set_volume(demon_sound_volume)
                break
            end
        end
    else
        local hb = get_hitbox(self.uid, -0.125, -0.37, 0)
        for _, v in ipairs(get_entities_overlapping_hitbox({0}, MASK.FLOOR | MASK.ACTIVEFLOOR, hb, self.layer)) do
            local w = get_entity(v)
            if test_flag(w.flags, ENT_FLAG.SOLID) and not test_flag(w.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) and test_flag(self.flags, ENT_FLAG.COLLIDES_WALLS) then
                -- Destroy the wall + knockback and stun the devil
                w:kill(false, self)
                self.velocityy = 0.11
                self.velocityx = 0.07
                self.user_data.state = DEVIL_STATE.VANILLA
                self:stun(240)     
                commonlib.shake_camera(10, 10, 5, 5, 5, false)
                -- Collision sound
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_BOSS_CAVEMAN_LAND, self.uid)
                audio:set_volume(demon_sound_volume)
                break 
            end
        end
    end
    -- Exit this state if we get stunned by some outside source (whipped by player or stuck in web)
    if self.move_state ~= 6 or self.stun_timer ~= 0 or test_flag(self.flags, ENT_FLAG.DEAD) then
        self.user_data.state = DEVIL_STATE.VANILLA 
        self.user_data.animation_info = ANIMATION_INFO.IDLE
        self.animation_frame = 13
        self.user_data.animation_frame = 13       
    end
end
local function state_vanilla(self)
    if self.stun_timer == 0 and not test_flag(self.flags, ENT_FLAG.DEAD) then
        self.user_data.custom_animation = true
        -- Idle
        if self:can_jump() and self.velocityx == 0 then
            if self.user_data.animation_info ~= ANIMATION_INFO.IDLE then
                self.user_data.animation_frame = 0
                self.user_data.animation_info = ANIMATION_INFO.IDLE
            end
        elseif self:can_jump() and self.velocityx ~= 0 then
            if self.user_data.animation_info ~= ANIMATION_INFO.WALK then
                self.user_data.animation_frame = 1
                self.user_data.animation_info = ANIMATION_INFO.WALK
            end            
        end
        -- Start charging if we enter state 6 (aggro range for tikiman)
        if self.move_state == 6 then
            self.user_data.state = DEVIL_STATE.CHARGE
            -- Sound effect
            local audio = devil_charge:play()
            local x, y, _ = get_position(self.uid)
            local sx, sy = screen_position(x, y)
            local d = screen_distance(distance(self.uid, self.uid))
            if players[1] ~= nil then
                d = screen_distance(distance(self.uid, players[1].uid))
            end
            audio:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
            audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx)*1.5)
            audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy)*1.5)
            audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
            audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
            audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, demon_sound_volume)
            audio:set_volume(demon_sound_volume)
            
            audio:set_pause(false)

            -- Update animation info
            self.user_data.animation_info = ANIMATION_INFO.CHARGE
            self.user_data.animation_frame = 18
        end
        -- Detect if we should enter the jump attack state
        -- Reduce jump cooldown
        if self.user_data.jump_cooldown > 0 then
            self.user_data.jump_cooldown = self.user_data.jump_cooldown - 1
        end
        local hb = get_hitbox(self.uid)
        hb.top = hb.top+4.8
        for _, v in ipairs(get_entities_by({0}, MASK.PLAYER, self.layer)) do
            local char = get_entity(v)
            if char:overlaps_with(hb) and self:can_jump() and self.user_data.jump_cooldown == 0 then
                local sx, sy, _ = get_position(self.uid)
                local px, py, _ = get_position(players[1].uid)
                if py > sy then
                    self.user_data.state = DEVIL_STATE.JUMP
                    self.user_data.animation_frame = 9
                    self.user_data.animation_info = ANIMATION_INFO.CHARGE_JUMP
                end
            end
        end
    else
        -- Don't use custom animations
        self.user_data.custom_animation = false
        if self.animation_frame == 153 then
            self.animation_frame = 17
        elseif self.animation_frame == 154 then
            self.animation_frame = 13
        elseif self.animation_frame == 155 then
            self.animation_frame = 14
        elseif self.animation_frame == 156 then
            self.animation_frame = 15
        elseif self.animation_frame == 157 then
            self.animation_frame = 16
        end
    end
end
local function devil_update(self)
    -- STATEMACHINE
    local d = self.user_data
    if d.state ==  DEVIL_STATE.VANILLA then
        state_vanilla(self)
    elseif d.state == DEVIL_STATE.JUMP then
        state_jump(self)
    elseif d.state == DEVIL_STATE.CHARGE then
        state_charge(self)
    end
    -- Custom animation
    animate_entity(self)
end

local function devil_set(self)
    -- Userdata stuff
    self.user_data = {
        ent_type = HD_ENT_TYPE.MONS_DEVIL;

        -- ANIMATION
        animation_timer = 1;
        animation_frame = 0;
        animation_info = ANIMATION_INFO.IDLE; -- Info about animation speed, start frame, stop frame
        custom_animation = true; -- When false we let the game handle animations

        -- AI 
        state = DEVIL_STATE.VANILLA;
        previous_state = DEVIL_STATE.VANILLA;

        jump_delay = 7; -- Frames before the devil does a jump
        jump_cooldown = 30;
    };
    -- Custom texture
    self:set_texture(devil_texture_id)

    -- Remove any held items
    local held_item = get_entity(self.holding_uid)
    if held_item ~= nil then
        drop(self.uid, held_item.uid)
        held_item:destroy()
    end

    -- Statemachine
    self:set_post_update_state_machine(devil_update)

    -- No Tiki SFX when dying
    self:set_pre_kill(function()
        local tikiman_db = get_type(ENT_TYPE.MONS_TIKIMAN)
        local sound_killed_by_player = tikiman_db.sound_killed_by_player
        local sound_killed_by_other = tikiman_db.sound_killed_by_other
        tikiman_db.sound_killed_by_player = -1
        tikiman_db.sound_killed_by_other = -1
        set_timeout(function()
            tikiman_db.sound_killed_by_player = sound_killed_by_player
            tikiman_db.sound_killed_by_other = sound_killed_by_other
        end, 1)
        --play a death sound, sounds weird otherwise
        local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.SHARED_DAMAGED, self.uid)
        audio:set_volume(1)
        audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, 1)   
        -- Play our own custom death noise (credits to greeni)
        local audio = devil_defeat:play()
        local x, y, _ = get_position(self.uid)
        local sx, sy = screen_position(x, y)
        local d = screen_distance(distance(self.uid, self.uid))
        if players[1] ~= nil then
            d = screen_distance(distance(self.uid, players[1].uid))
        end
        audio:set_parameter(VANILLA_SOUND_PARAM.POS_SCREEN_X, sx)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_X, math.abs(sx)*1.5)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_CENTER_Y, math.abs(sy)*1.5)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_Z, 0.0)
        audio:set_parameter(VANILLA_SOUND_PARAM.DIST_PLAYER, d)
        audio:set_parameter(VANILLA_SOUND_PARAM.VALUE, demon_sound_volume)
        audio:set_volume(demon_sound_volume)
        
        audio:set_pause(false) 
    end)
    -- Make the entity unstompable, if the player tries to stomp on the devil we will instead stun them
    self:set_pre_damage(function(self, other, damage_amount, stun_time, vx, vy, iframes)
        -- If the damage dealer is a player that is attacking us directly and is above us, damage them instead
        if other ~= nil then
            if other.type.search_flags == MASK.PLAYER then
                -- Let the player stomp the devil if they have spike shoes
                if not other:has_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES) then
                    local px, py, _ = get_position(other.uid)
                    local sx, sy, _ = get_position(self.uid)
                    if py > sy then
                        other:damage(self.uid, 1, 100, 0.08, 0, 30)
                        return true
                    end
                end
            end
        end
    end)
end

function module.create_devil(x, y, l)
    local devil = get_entity(spawn(ENT_TYPE.MONS_TIKIMAN, x, y, l, 0, 0))
    devil_set(devil)
end

optionslib.register_entity_spawner("Devil", module.create_devil, false)

return module