local celib = require "lib.entities.custom_entities"
local babyspiderlib = require "lib.entities.critterbabyspider"

local module = {}
local web_ball_texture_id
do
    local web_ball_texture_def
    web_ball_texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_ITEMS_0)
    web_ball_texture_def.texture_path = 'res/items_spiderlair_spidernest.png'
    web_ball_texture_id = define_texture(web_ball_texture_def)
end
local function spawn_web_ball_contents(x, y, l)
    local contents = {}
    if math.random(32) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.MONS_CAVEMAN, x, y, l, 0, 0)
        local caveman = get_entity(contents[#contents])
        caveman.health = 0
        caveman.last_state = caveman.state
        caveman.state = 22
        caveman.stand_counter = 0
        caveman.flags = set_flag(caveman.flags, ENT_FLAG.DEAD)
    elseif math.random(24) == 1 then
        for i = 1, 3, 1 do
            contents[#contents+1] = babyspiderlib.create_critterbabyspider(x, y, l)
        end
    elseif math.random(15) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_SKULL, x, y, l, 0, 0)
    elseif math.random(6) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.MONS_SPIDER, x, y, l, 0, 0)
    elseif math.random(15) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_RUBY, x, y, l, 0, 0)
    elseif math.random(12) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_SAPPHIRE, x, y, l, 0, 0)
    elseif math.random(7) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_EMERALD, x, y, l, 0, 0)
    elseif math.random(7) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_NUGGET, x, y, l, 0, 0)
    elseif math.random(4) == 1 then
        contents[#contents+1] = spawn(ENT_TYPE.ITEM_NUGGET_SMALL, x, y, l, 0, 0)
    end
    return contents
end
local function web_ball_destroy(_uid)
    local x, y, l = get_position(_uid)
    for _, contents_uid in ipairs(spawn_web_ball_contents(x, y, l)) do
        local contents = get_entity(contents_uid)
        contents.flags = set_flag(contents.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        set_timeout(function()
            --if a spider spawns stop it from hanging to the wall
            if contents.type.id == ENT_TYPE.MONS_SPIDER then
                contents.y = contents.y-0.5
            end
        end, 1)
        set_timeout(function()
            contents.flags = clr_flag(contents.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        end, 10)
    end
    generate_world_particles(PARTICLEEMITTER.HITEFFECT_STARS_BIG, _uid)
    for i=1, 6, 1 do
        commonlib.play_sound_at_entity(VANILLA_SOUND.SHARED_LANTERN_BREAK, _uid, 0.25)
        local leaf = get_entity(spawn(ENT_TYPE.ITEM_LEAF, x+(i-1)/6, y+math.random(-10, 10)/25, l, 0, 0))
        leaf.width = 0.75
        leaf.height = 0.75
        leaf.animation_frame = 47
        leaf.fade_away_trigger = true
    end
    for i=1, 4, 1 do
        -- # TODO: polish this effect up a bit more, colors arent spot on and the sfx could be a bit more metalic
        local x, y, l = get_position(_uid)
        local rubble = get_entity(spawn(ENT_TYPE.ITEM_RUBBLE, x, y, l, math.random(-10, 10)/80, math.random(1, 6)/25))
        rubble.animation_frame = 29
        rubble.width = 0.75
    end
end
local function web_ball_set(ent)
    ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    ent:set_texture(web_ball_texture_id)
    ent.inside = ENT_TYPE.FX_SHADOW --having this entity get crushed requires that it opens as well..
    --we can stop the player from seeing this by moving it out of bounds right before the crushing triggers opening..
    --if a bomb bag or box falls out,, once it falls into the abyss it will explode and make SFX..
    --so set the contents of this crate to nothing
end
local function web_ball_update(ent)
    local x, y, l = get_position(ent.uid)
    local ceiling_tile = get_grid_entity_at(x, y+0.75, l)
    if get_entity(ceiling_tile) == nil then
        web_ball_destroy(ent.uid)
        ent:destroy()
    end
end
local function check_for_destroy(ent, damage_dealer, damage_amount, velocityx, velocityy, stun_amount, iframes)
    if damage_amount > 0 then
        web_ball_destroy(ent.uid)
        ent:destroy()
        return true
    end
end
function module.create_webball(x, y, l)
    local web_ball = get_entity(spawn(ENT_TYPE.ITEM_CRATE, x, y, l, 0, 0))
    web_ball_set(web_ball)
    set_post_statemachine(web_ball.uid, web_ball_update)
    set_on_damage(web_ball.uid, check_for_destroy)
    set_on_kill(web_ball.uid, function()   
        web_ball_destroy(web_ball.uid)
        web_ball.x = -900
        --remove() or destroy() either dont work or crash
    end)
end

optionslib.register_entity_spawner("Web ball", module.create_webball, true)

return module