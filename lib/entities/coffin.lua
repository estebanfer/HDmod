local unlockslib = require 'lib.unlocks'
local roomdeflib = require 'lib.gen.roomdef'
local roomgenlib = require 'lib.gen.roomgen'
local locatelib = require 'lib.locate'

local module = {}

local function create_coffin_coop(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	local the_coffin = get_entity(coffin_uid)
	the_coffin.player_respawn = true
	return coffin_uid
end

local function create_coffin_unlock(x, y, l)
	local coffin_uid = spawn_entity(ENT_TYPE.ITEM_COFFIN, x, y, l, 0, 0)
	if unlockslib.LEVEL_UNLOCK ~= nil then
		--[[ 193 + unlock_num = ENT_TYPE.CHAR_* ]]
		set_contents(coffin_uid, 193 + unlockslib.HD_UNLOCKS[unlockslib.LEVEL_UNLOCK].unlock_id)
	end

	set_post_statemachine(coffin_uid, function()
		local coffin = get_entity(coffin_uid)
		if (
			coffin.animation_frame == 1
			and (
				unlockslib.LEVEL_UNLOCK ~= nil
				and (
					unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND1
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND2
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND3
					or unlockslib.LEVEL_UNLOCK == unlockslib.HD_UNLOCK_ID.AREA_RAND4
				)
			)
		) then
			for i = 1, #unlockslib.RUN_UNLOCK_AREA, 1 do
				if unlockslib.RUN_UNLOCK_AREA[i].theme == state.theme then
					unlockslib.RUN_UNLOCK_AREA[i].unlocked = true 
					break
				end
			end
		end
	end)

	return coffin_uid
end

function module.create_coffin(x, y, l)
    local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
    local _subchunk_id
    if roomgenlib.global_levelassembly.modification.levelrooms[roomy] ~= nil then
        _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
    end
    
    local coffin_uid = (
        _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP
        or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP
        or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_NOTOP
        or _subchunk_id == roomdeflib.HD_SUBCHUNKID.COFFIN_COOP_DROP_NOTOP
    ) and create_coffin_coop(x+0.35, y, l) or create_coffin_unlock(x+0.35, y, l)

    if (
        state.theme == THEME.EGGPLANT_WORLD
        or state.theme == THEME.NEO_BABYLON
    ) then
        local coffin_e = get_entity(coffin_uid)
        local texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_COFFINS_0)
        if state.theme == THEME.EGGPLANT_WORLD then
            coffin_e.flags = set_flag(coffin_e.flags, ENT_FLAG.NO_GRAVITY)
            coffin_e.velocityx = 0
            coffin_e.velocityy = 0
            texture_def.texture_path = "res/coffin_worm.png"
        end
        if state.theme == THEME.NEO_BABYLON then
            texture_def = get_texture_definition(TEXTURE.DATA_TEXTURES_COFFINS_5)
        end
        coffin_e:set_texture(define_texture(texture_def))
    end
end

return module