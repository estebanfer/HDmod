local module = {}

local texture_id
do
    local texture_def = TextureDefinition.new()
    texture_def.width = 128
    texture_def.height = 512
    texture_def.tile_width = 128
    texture_def.tile_height = 128
    texture_def.texture_path = "res/ladder_gold.png"
    texture_id = define_texture(texture_def)
end

function module.create_ladder(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l) end

function module.create_ladder_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER, x, y, l))
    ent:set_texture(texture_id)
    if ent.animation_frame == 4 then
        ent.animation_frame = 0
    elseif ent.animation_frame == 16 then
        ent.animation_frame = 1
    elseif ent.animation_frame == 40 then
        ent.animation_frame = 3
    end
end

function module.create_ladder_platform(x, y, l) spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l) end

function module.create_ladder_platform_gold(x, y, l)
    local ent = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_LADDER_PLATFORM, x, y, l))
    ent:set_texture(texture_id)
    ent.animation_frame = 2
end

function module.create_ceiling_chain(x, y, l)
	local ent_to_spawn_over = nil
	local floors_at_offset = get_entities_at(0, MASK.FLOOR | MASK.ROPE, x, y+1, l, 0.5)
	if #floors_at_offset > 0 then ent_to_spawn_over = floors_at_offset[1] end

	if (
		ent_to_spawn_over ~= nil
	) then
		local ent = get_entity(ent_to_spawn_over)

		ent_to_spawn_over = spawn_entity_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ent_to_spawn_over, 0, -1)
		if (
			ent.type.id == ENT_TYPE.FLOOR_GENERIC
			or ent.type.id == ENT_TYPE.FLOORSTYLED_VLAD
			or ent.type.id == ENT_TYPE.FLOOR_BORDERTILE
		) then
			get_entity(ent_to_spawn_over).animation_frame = 4
		end
	end
end

function module.create_growable_ceiling_chain(x, y, l)
	local ent_to_spawn_over = nil
	local floors_at_offset = get_entities_at(0, MASK.FLOOR, x, y+1, LAYER.FRONT, 0.5)
	if #floors_at_offset > 0 then ent_to_spawn_over = floors_at_offset[1] end

	local yi = y
	while true do
		if (
			ent_to_spawn_over ~= nil
		) then
			local ent = get_entity(ent_to_spawn_over)

			ent_to_spawn_over = spawn_entity_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ent_to_spawn_over, 0, -1)
			if (
				ent.type.id == ENT_TYPE.FLOOR_GENERIC
				or ent.type.id == ENT_TYPE.FLOORSTYLED_VLAD
				or ent.type.id == ENT_TYPE.FLOOR_BORDERTILE
			) then
				get_entity(ent_to_spawn_over).animation_frame = 4
			end
			yi = yi - 1
			floors_at_offset = get_entities_at(0, MASK.FLOOR, x, yi-1, LAYER.FRONT, 0.5)[1] ~= nil
			floors_at_offset = floors_at_offset or get_entities_at(ENT_TYPE.LOGICAL_DOOR, 0, x, yi-2, LAYER.FRONT, 0.5)[1] ~= nil
			if floors_at_offset then break end
		else break end
	end
end

function module.create_vine(x, y, l)
    local vine = get_entity(spawn_grid_entity(ENT_TYPE.FLOOR_VINE, x, y, l))

    local chance_id = spawndeflib.global_spawn_procedural_monkey
    if state.theme == THEME.EGGPLANT_WORLD then
        chance_id = spawndeflib.global_spawn_procedural_worm_jungle_monkey
    end
    local monkey_chance = get_procedural_spawn_chance(chance_id)
    if (
        (
            (state.theme == THEME.JUNGLE and feelingslib.feeling_check(feelingslib.FEELING_ID.RESTLESS) == false)
            or (state.theme == THEME.EGGPLANT_WORLD and state.world == 2)
        )
        and monkey_chance ~= 0
        and math.random(monkey_chance) == 1
    ) then
        spawn_entity_over(ENT_TYPE.MONS_MONKEY, vine.uid, 0, 0)
    end
end

function module.create_growable_vine(x, y, l)
    spawn_grid_entity(ENT_TYPE.FLOOR_GROWABLE_VINE, x, y, l)
end

return module