local module = {}

module.DEMO_MAX_WORLD = 2
optionslib.register_option_bool("hd_debug_demo_enable_all_worlds", "Demo - Enable unfinished worlds", nil, false, true)
optionslib.register_option_bool("hd_debug_demo_enable_tutorial", "Demo - Enable unfinished tutorial", nil, false, true)

return module