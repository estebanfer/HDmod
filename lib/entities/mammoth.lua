local celib = require "lib.entities.custom_entities"

local module = {}

local mammoth_texture_id
do
    local mammoth_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERSBIG03_0)
    mammoth_texture_def.texture_path = 'res/mammoth.png'
    mammoth_texture_id = define_texture(mammoth_texture_def)
end

--modify ITEM_FREEZERAYSHOT to ignore lamassu with mammoth texture
local function ignore_mammoth(ent, collision_ent)
    if collision_ent:get_texture() == mammoth_texture_id then
        return true
    end
end
set_post_entity_spawn(function(ent)
    ent:set_pre_on_collision2(ignore_mammoth)
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.ITEM_FREEZERAYSHOT)

local function mammoth_set(uid)
    local ent = get_entity(uid)
    local x, y, l = get_position(uid)
    ent:set_texture(mammoth_texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_MAMMOTH;
    };

    --we are using price as a variable to keep track of when mammoth will shoot a freezray blast
    ent.price = 90
end
local function mammoth_update(ent)
    --remove the lamassu attack FX
    if get_entity(ent.attack_effect_entity.uid) ~= nil then
        ent.attack_effect_entity:remove()
    end
    ent.emitted_light.enabled = false
    ent.particle.x = -900
    --clear targetting logic so the mammoth doesnt try to turn around and face the player
    ent.chased_target_uid = -1
    ent.target_selection_timer = 60
    --determine state
    if ent.price > 20 then
        ent.move_state = 1
    else
        ent.move_state = 30
    end

    --do animations manually
    if ent.price <= 20 and ent.price > 16 then
        ent.animation_frame = 1
    elseif ent.price <= 16 and ent.price > 12 then
        ent.animation_frame = 2
    elseif ent.price <= 12 and ent.price > 8 then
        ent.animation_frame = 3
    elseif ent.price <= 8 and ent.price > 4 then
        ent.animation_frame = 4
    elseif ent.price <= 4 then
        ent.animation_frame = 5
    end

    --only decrease timer if the ent isnt stopped by anything
    if ent.lock_input_timer == 0 and ent.frozen_timer == 0 and ent.stun_timer == 0 then
        ent.price = ent.price - 1
    end
    if ent.price == 0  then
      ent.price = 90
    end
    if ent.price == 4 then --create attack hitbox
        local x, y, l = get_position(ent.uid)
        commonlib.play_sound_at_entity(VANILLA_SOUND.ITEMS_FREEZE_RAY, ent.uid)
        if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
            local freezeray = get_entity(spawn(ENT_TYPE.ITEM_FREEZERAYSHOT, x-1, y-0.65, l, -0.25, 0))
            freezeray.owner_uid = ent.uid
            freezeray.last_owner_uid = ent.uid
            freezeray.angle = math.pi
        else
            local freezeray = get_entity(spawn(ENT_TYPE.ITEM_FREEZERAYSHOT, x+1, y-0.65, l, 0.25, 0))
            freezeray.owner_uid = ent.uid
            freezeray.last_owner_uid = ent.uid
        end
    end
end

function module.create_mammoth(x, y, l)
    local mammoth = spawn(ENT_TYPE.MONS_LAMASSU, x, y, l, 0, 0)
    mammoth_set(mammoth)
    set_post_statemachine(mammoth, mammoth_update)
    set_on_kill(mammoth, function()
        local ent = get_entity(mammoth)
        local x, y, l = get_position(mammoth)
        kill_entity(spawn(ENT_TYPE.MONS_AMMIT, x+0.2, y-0.6, l, 0, 0))
        ent.x = -900 --destroy() and remove() both crash the game ????
    end)
end

--to stop UFOs from targetting the mammoth, we are going to add some pre and post statemachine code to the UFO that temporarily turns the mammoths ENT_TYPE to 0 so they wont target them
--since the switch should only last the extent of the UFOs statemachine code, it shouldn't effect anything else about the mammoth
--thanks to JayTheBusinessGoose and Dregu for helping me figure out this technique
local lamassu_db = get_type(ENT_TYPE.MONS_LAMASSU)
set_post_entity_spawn(function(ufo)
    ufo:set_pre_update_state_machine(function()
        lamassu_db.id = 0
        return false
    end)
    ufo:set_post_update_state_machine(function()
        lamassu_db.id = ENT_TYPE.MONS_LAMASSU
        return false
    end)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

-- register_option_button("spawn_mammoth", "spawn_mammoth", 'spawn_mammoth', function ()
--     local x, y, l = get_position(players[1].uid)
--     module.create_mammoth(x-3, y, l)
-- end)

return module