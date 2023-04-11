local module = {}
local snow = get_particle_type(PARTICLEEMITTER.ICECAVES_DIAMONDDUST)
local snow_hsp = 0.000075
local snow_vsp = -0.00035
local orig_scale_x = snow.scale_x
local orig_scale_y = snow.scale_y
local orig_scale_x_min = snow.scale_x_min
local orig_scale_y_min = snow.scale_y_min
local orig_hor_scattering = snow.hor_scattering
local orig_ver_scattering = snow.ver_scattering
local orig_hor_velocity = snow.hor_velocity
local orig_ver_velocity = snow.ver_velocity
do
    local special_snowman_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
    special_snowman_texture_def.texture_path = 'res/special_snowman.png'
    special_snowman_texture_id = define_texture(special_snowman_texture_def)
end
function module.set_icecaves_diamonddust_particles(custom)
    if custom then
        snow.scale_x = orig_scale_x*1.1
        snow.scale_y = orig_scale_x*1.1
        snow.scale_x_min = orig_scale_x_min*1.5
        snow.scale_y_min = orig_scale_y_min*1.5
        snow.ver_scattering = 24
        snow.hor_scattering = 20
        snow.ver_velocity = snow_vsp        
    else
        snow.scale_x = orig_scale_x
        snow.scale_y = orig_scale_y
        snow.scale_x_min = orig_scale_x_min
        snow.scale_y_min = orig_scale_y_min
        snow.hor_scattering = orig_hor_scattering
        snow.ver_scattering = orig_ver_scattering
        snow.hor_scattering = orig_hor_scattering
        snow.ver_scattering = orig_ver_scattering
        snow.hor_velocity = orig_hor_velocity
        snow.ver_velocity = orig_ver_velocity
    end
end
function module.add_snow_to_floor()
    if (feelingslib.feeling_check(feelingslib.FEELING_ID.SNOW)) then
        local floors = get_entities_by_type(ENT_TYPE.FLOOR_GENERIC)
        for _, floor_uid in pairs(floors) do
            local floor = get_entity(floor_uid)
            if floor.deco_top ~= -1 then
                local deco_top = get_entity(floor.deco_top)
                if (
                    deco_top.animation_frame ~= 101
                    and deco_top.animation_frame ~= 102
                    and deco_top.animation_frame ~= 103
                ) then
                    deco_top.animation_frame = deco_top.animation_frame - 24
                    if get_grid_entity_at(floor.x, floor.y + 1, floor.layer) == -1 and prng:random_chance(60, PRNG_CLASS.LEVEL_DECO) then
                        -- Add a snowman decoration to the floor.
                        local scale = 0.6 + (0.2 * prng:random_float(PRNG_CLASS.LEVEL_DECO))
                        local offset_x = -0.15 + (0.3 * prng:random_float(PRNG_CLASS.LEVEL_DECO))
                        local offset_y = 0.5 + (0.4 * scale)
                        local snowman = get_entity(spawn_entity_over(ENT_TYPE.DECORATION_GENERIC, floor_uid, offset_x, offset_y))
                        snowman:set_texture(TEXTURE.DATA_TEXTURES_ITEMS_0)
                        -- Rare chance for the Guy Spelunky snowman instead of the regular one
                        if prng:random_chance(5, PRNG_CLASS.LEVEL_DECO) then
                            snowman:set_texture(special_snowman_texture_id)
                        end
                        snowman.animation_frame = 221
                        snowman:set_draw_depth(12)
                        snowman.width = prng:random_chance(2, PRNG_CLASS.LEVEL_DECO) and scale or -scale
                        snowman.height = scale
                    end
                end
            end
        end
        -- Heavy snow effect
        module.set_icecaves_diamonddust_particles(true)
        local snow_generator = get_entity(spawn(ENT_TYPE.ITEM_POTOFGOLD, players[1].x, players[1].y, LAYER.FRONT, 0, 0))
        snow_generator.flags = set_flag(snow_generator.flags, ENT_FLAG.NO_GRAVITY)
        snow_generator.flags = set_flag(snow_generator.flags, ENT_FLAG.PASSES_THROUGH_EVERYTHING)
        snow_generator.flags = set_flag(snow_generator.flags, ENT_FLAG.INVISIBLE)
        snow_generator.flags = clr_flag(snow_generator.flags, ENT_FLAG.COLLIDES_WALLS)
        snow_generator.flags = clr_flag(snow_generator.flags, ENT_FLAG.PICKUPABLE)
        -- Anchor this entity at the camera's focus
        snow_generator:set_post_update_state_machine(function(self)
            move_entity(self.uid, state.camera.calculated_focus_x, state.camera.calculated_focus_y, 0, 0)
        end)
        -- Do the snow effect
        for _=1, 1000 do
            generate_world_particles(PARTICLEEMITTER.ICECAVES_DIAMONDDUST, snow_generator.uid)
        end
    end
end
-- Reset the particle effect after clearing a level
set_callback(function()
    module.set_icecaves_diamonddust_particles(false)
end, ON.TRANSITION)
-- This is done for the effect of custom snow used in snow levels
set_callback(function()
    snow.hor_velocity = snow_hsp*math.random(-125, 125)/100
end, ON.GAMEFRAME)

return module