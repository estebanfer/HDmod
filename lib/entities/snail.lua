--replaces ENT_TYPE.MONS_HERMITCRAB
local module = {}
local hermitcrab_db = get_type(ENT_TYPE.MONS_HERMITCRAB)
hermitcrab_db.life = 1
hermitcrab_db.leaves_corpse_behind = false
set_post_entity_spawn(function(entity)
    entity.move_state = 9
    entity.animation_frame = 74
    entity.spawn_new_carried_item = true
    set_on_destroy(entity.uid, function(entity)
        local x, y, l = get_position(entity.uid)
        for i=1, 4, 1 do
            -- # TODO: polish this effect up a bit more, colors arent spot on
            local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE,
                x+prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, y+(prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100)+0.1, l,
                prng:random_int(-10, 10, PRNG_CLASS.PARTICLES)/100, prng:random_int(1, 6, PRNG_CLASS.PARTICLES)/30))
            rubble.animation_frame = 22
            rubble.color.r = 55
            rubble.color.g = 65
            rubble.color.b = 115
        end
    end)
    set_post_statemachine(entity.uid, function()
        entity.animation_frame = 74
        clear_callback()
    end)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HERMITCRAB)

function module.create_snail(x, y, l)
    spawn_on_floor(ENT_TYPE.MONS_HERMITCRAB, x, y, l)
end

optionslib.register_entity_spawner("Snail", module.create_snail, false)

return module