local module = {}

function module.create_crushtrap(x, y, l)
    local crushtrap = get_entity(spawn_grid_entity(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, x, y, l))
    -- if options.hd_og_floorstyle_temple then
    --     -- crushtrap:set_texture(texture_id)
    --     crushtrap.animation_frame = 0
    -- end
end

return module