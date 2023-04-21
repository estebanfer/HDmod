local celib = require "lib.entities.custom_entities"

local module = {}
--movable.price is used as a cooldown to stop the whip from damaging the entity multiple times
local green_knight_texture_id
do
    local green_knight_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERS01_0)
    green_knight_texture_def.texture_path = 'res/green_knight.png'
    green_knight_texture_id = define_texture(green_knight_texture_def)
end
local function green_knight_set(uid)
    local ent = get_entity(uid)
    local x, y, l = get_position(uid)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
    --set the caveman to be awake
    ent.move_state = 0
    ent.state = 1
    ent:set_texture(green_knight_texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_GREEN_KNIGHT;
        hit_ground = true;
        jingle_timer = 40; -- Makes the knights armor jingle when 0
        armored = true;
    };
end
set_callback(function()
    module.create_greenknight(players[1].x+3, players[1].y, players[1].layer)
end, ON.START)
local function green_knight_update(ent)
    --manage price timer
    if ent.price > 0 then
        ent.price = ent.price - 1
    end
    -- Clang sound when landing
    if ent.user_data.armored then
        if not ent.user_data.hit_ground and ent:can_jump() then
            if not test_flag(ent.flags, ENT_FLAG.DEAD) then
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
                audio:set_volume(0.5)
                audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, math.random(2, 3))
                audio:set_pitch(math.random(70, 90)/100)
            end
            ent.user_data.hit_ground = true
        end
        if ent.standing_on_uid == -1 then ent.user_data.hit_ground = false end
        -- Jingle jangle jingle
        if ent:can_jump() and ent.movex ~= 0 then
            ent.user_data.jingle_timer = ent.user_data.jingle_timer - 1
            if ent.move_state == 6 then ent.user_data.jingle_timer = ent.user_data.jingle_timer - 1 end
            if ent.user_data.jingle_timer <= 0 then
                ent.user_data.jingle_timer = math.random(28, 40)
                local audio = commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid, 1)
                audio:set_volume(0.3)
                audio:set_parameter(VANILLA_SOUND_PARAM.COLLISION_MATERIAL, math.random(2, 3))
                audio:set_pitch(math.random(90, 120)/100)
            end
        end
    end
end
local function ignore_whip_damage(ent, damage_dealer, damage_amount, velocityx, velocityy, stun_amount, iframes)
    if damage_dealer.type.id == ENT_TYPE.ITEM_WHIP and ent.price == 0 and ent.health > 2 then
        generate_world_particles(PARTICLEEMITTER.NOHITEFFECT_STARS, ent.uid)
        ent.price = 10 --cooldown
        commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_ENEMY_HIT_INVINCIBLE, damage_dealer.uid)
        return true
    end
end
local function become_caveman(ent)
    ent.user_data.armored = false
    if ent:get_texture() ~= ent.type.texture then
        ent:set_texture(ent.type.texture)
        --sfx and green rubble here
        ent.flags = set_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
        commonlib.play_sound_at_entity(VANILLA_SOUND.ENEMIES_OLMITE_ARMOR_BREAK, ent.uid)
        for i=1, 4, 1 do
            -- # TODO: polish this effect up a bit more, colors arent spot on and the sfx could be a bit more metalic
            local x, y, l = get_position(ent.uid)
            local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, math.random(-10, 10)/100, math.random(1, 6)/30))
            rubble.animation_frame = 41
            rubble.color.r = 155
            rubble.color.g = 35
            rubble.color.b = 200
        end
    end
end
local function check_for_damage(ent, damage_dealer, damage_amount, velocityx, velocityy, stun_amount, iframes)
    if damage_dealer ~= nil then
        if (damage_dealer.type.id ~= ENT_TYPE.ITEM_WHIP and ent.health > 2) or ent.health == 0 then
            become_caveman(ent)
        end
    else
        if (ent.health > 2) or ent.health == 0 then
            become_caveman(ent)
        end 
    end
end
function module.create_greenknight(x, y, l)
    local green_knight = spawn(ENT_TYPE.MONS_CAVEMAN, x, y, l, 0, 0)
    green_knight_set(green_knight)
    set_post_statemachine(green_knight, green_knight_update)
    set_on_damage(green_knight, ignore_whip_damage)
    set_on_damage(green_knight, check_for_damage)
    set_on_destroy(green_knight, become_caveman)
end

optionslib.register_entity_spawner("Green knight", module.create_greenknight)

return module