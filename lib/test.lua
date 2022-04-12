local module = {}

local function testroom_level_1()
	--[[
		Coordinates of each floor:
		Top:	x = 13..32,	y = 112
		Middle:	x = 13..32,	y = 109
		Bottom:	x = 5..40,	y = 101
	--]]
	
	--[[
		Thanks for offering to help with this.
		The door below the rope at the camp will take you to the testing area.
	--]]

	--[[
		Here's the behavior inheritance feature, as examplified by the scorpionfly.

			- ****Here I'm using an imp instead of the bat for the agro behavior because bats make noise. I adjusted the
				script that removes hermitcrab items to support removing the imp's lavapot but that's not working for
				some reason. For now, just pause and use MOUSE 3 to move the lavapot out of the way to see it in action.

			- There are some HD enemies that weren't recreated in the sequal but had some of their behaviors
				used for new ones. Take the scorpion fly: In HD, an idle and pre-agro scorpionfly behaves like
				a mosquito. When agrod, it targets the player, heading toward them like a bat/imp. When it takes
				a point of damage, health is taken from it, it looses its wings and behaves like a scorpion.
				We can create a scorpionfly by "duct-taping" these enemies together and toggling the physics, AI,
				and visibility of each one at the appropriate times.

				Since there are several HD enemies that could be recreated this way, we should make a system for it.
				Maybe we could provide fields like "agro" and "idle" to assign uids to, and the way they are handled
				is through methods you can assign to run on each frame. That way we can reduce duplicate code.

				Another thing I'll point out is that the imp is invisible and the scorpion is colored red. Ideally we
				should be toggling the visibility of these enemies and reskin them with their HD frames (or at least in
				situations where they are using the same animations). The mosquito's idle state animation uses the same
				frames that the scorpion fly did; So does the imp for agro and the scorpion for all of its animations.
				res/monsters01_scorpionfly.png
				res/monstersbasic01_scorpionfly.png

				There are more enemy textures I've prepared to get some ideas across. They'll probably see a lot of
				changes so feel free to change them. The .ase files are in src/.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.SCORPIONFLY, 24, 108, LAYER.FRONT, false, 0, 0)
	
	--[[
		- now that I look back on it a lot of stuff like these HD_ENT fields:
			
				dangertype = HD_DANGERTYPE.FLOORTRAP,
				collisiontype = hdtypelib.HD_COLLISIONTYPE.FLOORTRAP,
			
			are just overcomplicating things so it might be better to just remove and start over with some things.
			Dangertype isn't used for anything so that can be removed, but some things like the collisiontype
			field might be useful in `is_valid_*_spawn` methods.
			Both the tikitrap and hangspider need to use spawn_entity_over for their creation, so maybe make an
			HD_ENT field for a method interacting with a passed-in uid.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.HANGSPIDER, 26, 104, LAYER.FRONT, false, 0, 0)
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.TRAP_TIKI, 14, 110, LAYER.FRONT, false, 0, 0)


	--[[
		- These last two are examples of enemies that require common flags, fields, and methods.
			In HD, the snail has 1 hp and doesn't leave a corpse. So what was needed was to remove the hermetcrab's
			backitem, set its health, and disable its corpse. The eggsac is a similar story: we're replacing the
			S2 maggots with wormbabies, which also have one health and no corpse.
	--]]
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.SNAIL, 24, 110, LAYER.FRONT, false, 0, 0)
	hdtypelib.create_hd_type(hdtypelib.HD_ENT.EGGSAC, 28, 110, LAYER.FRONT, false, 0, 0)

	--[[
		- I've set up a bunch of procedural spawn methods to fill under the prefix `global_procedural_spawn_*`
	--]]

	-- thank you and good luck :derekapproves:
end

local function testroom_level_2()
	
end

local function test_bacterium()
	-- Bacterium Creation
		-- FLOOR_THORN_VINE:
			-- flags = clr_flag(flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR) -- indestructable (maybe need to clear this? Not sure yet)
			-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
			-- visible
			-- allow hurting player
			-- allow bombs to destroy them.
		-- ACTIVEFLOOR_BUSHBLOCK:
			-- invisible
			-- flags = clr_flag(flags, ENT_FLAG.SOLID) -- solid wall
			-- allow taking damage (unless it's already enabled by default)
		-- ITEM_ROCK:
			-- disable ai and physics
				-- re-enable once detached from surface
	-- Challenge: Let rock attatch to surface, move it on frame.

	-- Bacterium Behavior
		-- Bacterium Movement Script
		-- **Behavior is handled in onframe_manage_dangers()
		-- Class requirements:
		-- - Destination {float, float}
		-- - Angle int
		-- - Entity uid:
		-- - stun timeout (May be possible to track with the entity)
		-- # TODO: Bacterium Movement Script
		-- Detect whether it is owned by a wall and if the wall exists, and if not, attempt to adopt a wall within all
		-- 4 sides of it. If that fails, enable physics if not already.
		-- If it is owned by a wall, detect 
		-- PROTOTYPING:
		-- if {x, y} == destination, then:
		--   if "block to immediate right", then:
		--     if "block to immediate front", then:
		--       rotate -90d;
		--     end
		--     own block to immediate right;
		--   else:
		--     rotate 90d;
		--   end
		--   destination = {x, y} of immediate front
		-- go towards the destination;
		-- end
		-- **Get to the point where you can store a single bacterium in an array, get placed on a wall and toast the angle it's chosen to face.
end

set_callback(function()
	if worldlib.HD_WORLDSTATE_STATE == worldlib.HD_WORLDSTATE_STATUS.TESTING then
		if state.level == 1 then
			testroom_level_1()
		elseif state.level == 2 then
			testroom_level_2()
		end
	end
end, ON.LEVEL)

return module