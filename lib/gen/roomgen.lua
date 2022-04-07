local module = {}

module.global_levelassembly = nil

-- # TODO: For development of the new scripted level gen system, move tables/variables into here from init_onlevel() as needed.
function module.init_posttile_door()
	module.global_levelassembly = {}
end

set_callback(function()
	-- roomgenlib.global_levelassembly = nil
end, ON.TRANSITION)

return module