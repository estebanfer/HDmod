snowlib = require 'lib.entities.snow'
treelib = require 'lib.entities.tree'
gargoylelib = require 'lib.entities.gargoyle'
touchupslib = require 'lib.gen.touchups'
shopslib = require 'lib.entities.shops'

module = {}

local function add_decorations()
    snowlib.add_snow_to_floor()
    treelib.onlevel_decorate_haunted()
    gargoylelib.add_gargoyles_to_hc()
    shopslib.add_shop_decorations()
end

local function remove_decorations()
	touchupslib.remove_boulderstatue()
	touchupslib.remove_neobab_decorations()
end

function module.change_decorations()
    add_decorations()
    remove_decorations()
end


return module