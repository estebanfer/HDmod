-- Code adapted from Gugubo's crystal monkey mod

local celib = require "lib.entities.custom_entities"
local optionslib = require "lib.options"

local module = {}

local texture_id
do
	local texture_def = TextureDefinition.new()
    texture_def.width = 768
    texture_def.height = 256
    texture_def.tile_width = 128
    texture_def.tile_height = 128
	texture_def.texture_path = "res/crystal_monkey.png"
	texture_id = define_texture(texture_def)
end

local tusk_idol_sacced = false
--See if a tusk idol has been sacced
set_post_entity_spawn(function(altar, spawn_flags)
	set_pre_collision2(altar.uid, function(self, collision_ent)
		if collision_ent.type.id == ENT_TYPE.ITEM_MADAMETUSK_IDOL and collision_ent.standing_on_uid == altar.uid and altar.timer == 20 then
			tusk_idol_sacced = true
	  	end
	end)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_ALTAR)

---@param entity GoldMonkey
local function monkey_set(entity)
	entity:set_texture(texture_id)
end

---@param self GoldMonkey
local function monkey_update(self)
    if self.animation_frame == 158 then
        self.animation_frame = 0
    elseif self.animation_frame == 159 then
        self.animation_frame = 1
    elseif self.animation_frame == 166 then
        self.animation_frame = 2
    elseif self.animation_frame == 167 then
        self.animation_frame = 3
    elseif self.animation_frame == 168 then
        self.animation_frame = 4
    elseif self.animation_frame == 169 then
        self.animation_frame = 5
    elseif self.animation_frame == 170 then
        self.animation_frame = 6
    elseif self.animation_frame == 171 then
        self.animation_frame = 7
    elseif self.animation_frame == 172 then
        self.animation_frame = 8
    elseif self.animation_frame == 173 then
        self.animation_frame = 9
    elseif self.animation_frame == 174 then
        self.animation_frame = 10
    elseif self.animation_frame == 175 then
        self.animation_frame = 11
    end
end

local crystal_monkey_id = celib.new_custom_entity(monkey_set, monkey_update, celib.CARRY_TYPE.HELD, ENT_TYPE.MONS_GOLDMONKEY)


--Turns gold monkey (entity) to crystal monkey
---@param entity GoldMonkey
local function gold_to_crystal_monkey(entity)
    celib.set_custom_entity(entity.uid, crystal_monkey_id)
end

--If a monkey spawns and a tusk idol has been sacced, turn the monkey into a crystal monkey
set_post_entity_spawn(function(entity, spawn_flags)
	if not tusk_idol_sacced then return end
	tusk_idol_sacced = false
	gold_to_crystal_monkey(entity)
end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_GOLDMONKEY)


function module.create_crystalmonkey(x, y, l)
    gold_to_crystal_monkey(get_entity(spawn_entity_snapped_to_floor(ENT_TYPE.MONS_GOLDMONKEY, x, y, l)))
end

optionslib.register_entity_spawner("Crystal Monkey", module.create_crystalmonkey, false)

return module