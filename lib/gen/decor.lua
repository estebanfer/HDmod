snowlib = require 'lib.entities.snow'
treelib = require 'lib.entities.tree'
gargoylelib = require 'lib.entities.gargoyle'

module = {}

function module.add_decorations()
    snowlib.add_snow_to_floor()
    treelib.onlevel_decorate_haunted()
    gargoylelib.add_gargoyles_to_hc()
end

return module