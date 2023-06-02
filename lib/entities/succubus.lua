local module = {}
local MONS_SUCC = EntityDB:new(ENT_TYPE.MONS_LEPRECHAUN)
MONS_SUCC.properties_flags = clr_flag(MONS_SUCC.properties_flags, 5)
-- Setup texture sheet
local succ_texture_id
do
    local succ_texture_def = TextureDefinition.new()
    succ_texture_def.width = 1152
    succ_texture_def.height = 256
    succ_texture_def.tile_width = 128
    succ_texture_def.tile_height = 128
    succ_texture_def.texture_path = 'res/succubus.png'
    succ_texture_id = define_texture(succ_texture_def)
end
-- Sound effect path
local succlaugh = create_sound('res/sounds/succlaugh.wav')
local succdead = create_sound('res/sounds/succdead.wav')

-- Animations
local ANIMATION_INFO = {
    IDLE = {
        start = 9;
        finish = 9;
        speed = 1;
    };
    RUN = {
        start = 10;
        finish = 17;
        speed = 5;
    };
    JUMP = {
        start = 13;
        finish = 13;
        speed = 1;
    };
    CLING = {
        start = 5;
        finish = 8;
        speed = 6;
    };
}

-- State enum
local SUCC_STATE = {
    BAIT = 1; -- We display the fake pet entity and make the actual succubus invisible
    VANILLA = 2;  -- We should probably use a monkey for the base entity and disable the sounds
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
local function state_bait(self)
    local sx, sy, sl = get_position(self.uid)
    self.user_data.animation_info = ANIMATION_INFO.IDLE
    -- Stop leprechaun from moving + invisible
    self.move_state = 15
    self.state = 15
    self.flags = set_flag(self.flags, ENT_FLAG.INVISIBLE)
    -- Make the pet yell twice as fast
    if self.user_data.pet.yell_counter < 250 then
        self.user_data.pet.yell_counter = 250
    end
    -- Enter the chase state once the player is in range
    for _, v in ipairs(get_entities_at({}, MASK.PLAYER, sx, sy, sl, 4)) do
        local ent = get_entity(v)
        if not test_flag(ent.flags, ENT_FLAG.DEAD) then
            -- Update state and make leprechaun visible
            self.state = 1
            self.move_state = 0
            self.flags = clr_flag(self.flags, ENT_FLAG.INVISIBLE)
            self.user_data.state = SUCC_STATE.VANILLA
            -- Get rid of da pet
            if self.user_data.pet ~= nil then
                self.user_data.pet:destroy()
            end
            -- Sound effect
            commonlib.play_custom_sound(succlaugh, self.uid, 0.1, false)
        end
    end
end
local function state_vanilla(self)
    -- Update animations
    if self.stun_timer > 0 or test_flag(self.flags, ENT_FLAG.DEAD) then -- stun / corpse
        self.user_data.custom_animation = false
        if self.animation_frame == 60 then
            self.animation_frame = 0
        end
        if self.animation_frame == 61 then
            self.animation_frame = 1
        end
        if self.animation_frame == 62 then
            self.animation_frame = 2
        end
        if self.animation_frame == 63 then
            self.animation_frame = 3
        end
        if self.animation_frame == 47 then
            self.animation_frame = 4
        end
    elseif self.hump_timer == 0 then
        if self:can_jump() and self.velocityx ~= 0 then
            self.user_data.animation_info = ANIMATION_INFO.RUN
            self.user_data.custom_animation = true
        elseif self:can_jump() and self.velocityx == 0 then
            self.user_data.animation_info = ANIMATION_INFO.IDLE   
            self.user_data.custom_animation = true     
        end
        if not self:can_jump() then
            self.user_data.animation_info = ANIMATION_INFO.JUMP   
            self.user_data.custom_animation = true          
        end
    else
        if self.user_data.animation_info ~= ANIMATION_INFO.CLING then
            self.user_data.animation_info = ANIMATION_INFO.CLING
            self.user_data.custom_animation = true
            self.user_data.animation_frame = 9
        end
    end

    -- Deal damage
    if self.hump_timer == 1 then
        if get_entity(self.chased_target_uid) ~= nil then
            local target = get_entity(self.chased_target_uid)
            target:damage(self.uid, 1, 100, 0, 0.1, 0)
            local dir = -1
            self.flags = set_flag(self.flags, ENT_FLAG.FACING_LEFT)
            if test_flag(self.overlay.flags, ENT_FLAG.FACING_LEFT) then
                dir = 1
                self.flags = clr_flag(self.flags, ENT_FLAG.FACING_LEFT)
            end
            -- Stop the vanilla stun prematurely 
            self.state = 12
            self.last_state = 1
            self.move_state = 5
            self:set_behavior(12)
            self.timer_after_humping = 120
            self.hump_timer = 0
            if self.overlay ~= nil then
                entity_remove_item(self.overlay.uid, self.uid)
            end
            set_timeout(function()
                if self ~= nil then
                    self.velocityy = 0.21
                    self.velocityx = 0.09*dir
                end
            end, 1)
            -- Lifesteal
            self.health = self.health + 1
        end
    end
end
local function succ_update(self)
    self.gold = 0
    -- STATEMACHINE
    local d = self.user_data
    if d.state == SUCC_STATE.BAIT then
        state_bait(self)
    elseif d.state == SUCC_STATE.VANILLA then
        state_vanilla(self)
    end
    -- Stop the leprechaun sounds
    if self.sound ~= nil then
        self.sound.playing = false
    end
    -- Custom animation
    animate_entity(self)
end
-- Stop the succubus from picking up gold
set_post_entity_spawn(function(ent)
    set_pre_collision2(ent.uid, function(col, col2)
        if type(col2.user_data) == "table" then
            if col2.user_data.ent_type == HD_ENT_TYPE.MONS_SUCCUBUS then
                return true
            end
        end
    end)
end, SPAWN_TYPE.ANY, 0, {ENT_TYPE.ITEM_DIAMOND, ENT_TYPE.ITEM_GOLDBAR, ENT_TYPE.ITEM_GOLDBARS, ENT_TYPE.ITEM_GOLDCOIN, ENT_TYPE.ITEM_NUGGET, ENT_TYPE.ITEM_NUGGET_SMALL, ENT_TYPE.ITEM_EMERALD, ENT_TYPE.ITEM_EMERALD_SMALL, ENT_TYPE.ITEM_RUBY, ENT_TYPE.ITEM_RUBY_SMALL, ENT_TYPE.ITEM_SAPPHIRE, ENT_TYPE.ITEM_SAPPHIRE_SMALL, ENT_TYPE.MONS_SCARAB})
local function succ_set(self)
    self.type = MONS_SUCC
    -- Userdata
    self.user_data = {
        ent_type = HD_ENT_TYPE.MONS_SUCCUBUS;

        -- ANIMATION
        animation_timer = 1;
        animation_frame = 0;
        animation_info = ANIMATION_INFO.IDLE; -- Info about animation speed, start frame, stop frame
        custom_animation = true; -- When false we let the game handle animations

        -- AI 
        state = SUCC_STATE.BAIT;
        previous_state = SUCC_STATE.BAIT;

        -- This entity will be destroyed once the succubus is "activated", also disabling picking it up as a safeguard
        pet = get_entity(spawn(ENT_TYPE.MONS_PET_DOG, self.x, self.y, self.layer, 0, 0));
        -- We use a Jiangshi as a "detector" for trying to kill this entity with a camera
        jiangshi = get_entity(spawn(ENT_TYPE.MONS_JIANGSHI, self.x, self.y, self.layer, 0, 0));
    };
    -- Set health
    self.health = 1
    -- Make detector jiangshi invisible and inactive and stay on the succubus
    self.user_data.jiangshi:set_post_update_state_machine(function(j)
        if self == nil then return end
        local x, y, _ = get_position(self.uid)
        -- Disable jiangshi mechanically
        j.flags = set_flag(j.flags, ENT_FLAG.NO_GRAVITY)
        j.flags = set_flag(j.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        j.state = 30
        j.move_state = 30
        j.lock_input_timer = 5
        j.flags = set_flag(j.flags, ENT_FLAG.INVISIBLE)
        -- Glue it to the succ
        move_entity(j.uid, x, y, 0, 0)
    end)
    -- Glue pet to the succ
    self.user_data.pet:set_post_update_state_machine(function(p)
        if self == nil then return end
        local x, y, _ = get_position(self.uid)
        move_entity(p.uid, x, y-0.1, 0, 0)        
    end)
    -- If the pet gets damaged update the succ state
    self.user_data.pet:set_pre_damage(function()
        -- Update state and make leprechaun visible
        self.state = 1
        self.move_state = 0
        self.flags = clr_flag(self.flags, ENT_FLAG.INVISIBLE)
        self.user_data.state = SUCC_STATE.VANILLA
        -- Get rid of da pet
        if self.user_data.pet ~= nil then
            if self.user_data.pet.type.id == ENT_TYPE.MONS_PET_DOG or self.user_data.pet.type.id == ENT_TYPE.MONS_PET_CAT or  self.user_data.pet.type.id == ENT_TYPE.MONS_PET_HAMSTER then
                self.user_data.pet:destroy()
            end
        end     
    end)
    -- Fix for the succubus' animations breaking after getting roped off a player
    self:set_pre_damage(function(self)
        if self.hump_timer > 0 then
            self.hump_timer = 0
            self.user_data.animation_info = ANIMATION_INFO.JUMP
        end
    end)
    -- Remove the succ and kill the jiangshi if the succ dies
    self:set_pre_kill(function(self, other)
        -- Get rid of da pet
        if self.user_data.pet ~= nil then
            if self.user_data.pet.type.id == ENT_TYPE.MONS_PET_DOG or self.user_data.pet.type.id == ENT_TYPE.MONS_PET_CAT or  self.user_data.pet.type.id == ENT_TYPE.MONS_PET_HAMSTER then
                self.user_data.pet:destroy()
            end
        end  
        -- Kill the jiangshi
        if self.user_data.jiangshi ~= nil then
            if self.user_data.jiangshi.type.id == ENT_TYPE.MONS_JIANGSHI then
                self.user_data.jiangshi:kill(false, nil)
            end
        end  
        -- Death sfx
        commonlib.play_custom_sound(succdead, self.uid, 0.1, false)   
        -- Move the base entity out of bounds
        self.x = -100
    end)
    -- Make detector jiangshi only take damage from the camera
    self.user_data.jiangshi:set_pre_damage(function(self, other)
        return true
    end)
    -- Because this jiangshi is effectively invincible, the only thing that can kill it is a camera. so if that happens, kill the other entities
    self.user_data.jiangshi:set_pre_kill(function()
        -- Kill the pet we used as well if its still alive
        if self.user_data.pet ~= nil then
            if self.user_data.pet.type.id == ENT_TYPE.MONS_PET_DOG or self.user_data.pet.type.id == ENT_TYPE.MONS_PET_CAT or self.user_data.pet.type.id == ENT_TYPE.MONS_PET_HAMSTER then
                self.user_data.pet:destroy()
            end
        end 
        -- Kill the base entity
        self:destroy()
    end)
    -- Stop the leprechaun from picking up gold (WIP)
    -- Custom texture
    self:set_texture(succ_texture_id)
    -- Statemachine
    self:set_post_update_state_machine(succ_update)
end

function module.create_succubus(x, y, l)
    local succ = get_entity(spawn(ENT_TYPE.MONS_LEPRECHAUN, x, y, l, 0, 0))
    succ_set(succ)
end
optionslib.register_entity_spawner("Succubus", module.create_devil, false)

return module