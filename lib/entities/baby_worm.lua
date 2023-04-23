local celib = require "lib.entities.custom_entities"

local module = {}
local texture_id
do
    local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_MONSTERSBASIC01_0)
    texture_def.texture_path = 'res/worm_baby.png'
    texture_id = define_texture(texture_def)
end
local function worm_baby_set(uid)
    local ent = get_entity(uid)
    ent.price = 0 --exit_chase_timer
    ent:set_texture(texture_id)
    -- user_data
    ent.user_data = {
        ent_type = HD_ENT_TYPE.MONS_worm_baby;
    };
end
local function worm_baby_update(ent)
    --chase timer
    if ent.price > 0 then
        ent.price = ent.price - 1
    end
    --lock jump behavior
    ent.jump_timer = 180
    --statemachine
    if ent.move_state == 1 then
        --check for enter chase state
        for _, player in ipairs(players) do
            local x, y, _ = get_position(ent.uid)
            local px, py, _ = get_position(player.uid)
            if py-y-0.1 <= 0 then
                ent.price = 15
                ent.move_state = 20
                break
            end
        end
    elseif ent.move_state == 20 then
        --boost speed
        ent.x = ent.x+(0.02*ent.movex)
        if ent.price == 0 then
            ent.move_state = 1
        end
        --extend chase state
        for _, player in ipairs(players) do
            local x, y, _ = get_position(ent.uid)
            local px, py, _ = get_position(player.uid)
            if py-y-0.1 <= 0 then
                ent.price = 15
                ent.move_state = 20
                break
            end
        end
        --check for walls and flip if we touch one
        local incoming_wall = get_grid_entity_at(ent.x+ent.movex/4, ent.y, LAYER.FRONT)
        if incoming_wall ~= -1 then
            local wall = get_entity(incoming_wall)
            if not test_flag(wall.flags, ENT_FLAG.SOLID) then return end
            if test_flag(ent.flags, ENT_FLAG.FACING_LEFT) then
                ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
            else
                ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
            end
        end
    end
end
function module.create_worm_baby(x, y, l)
    local worm_baby = spawn(ENT_TYPE.MONS_ALIEN, x, y, l, 0, 0)
    worm_baby_set(worm_baby)
    set_post_statemachine(worm_baby, worm_baby_update)
end

set_pre_entity_spawn(function (e_type, x, y, l)
    module.create_worm_baby(x, y, l)
    return spawn_grid_entity(ENT_TYPE.FX_SHADOW, 0, 0, LAYER.FRONT)
end, SPAWN_TYPE.ANY, MASK.MONSTER, ENT_TYPE.MONS_GRUB)

optionslib.register_entity_spawner("Worm Baby", module.create_worm_baby)

return module