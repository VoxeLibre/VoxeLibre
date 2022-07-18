-- Dripping Water Mod
-- by kddekadenz
-- License of code, textures & sounds: CC0

local math = math

local function register_drop(liquid, glow, sound, nodes)

	local pdef = {
		velocity = vector.new(0,0,0),
		collision_removal = false,
	}

	minetest.register_abm({
		label = "Create drops",
		nodenames = nodes,
		neighbors = {"group:" .. liquid},
		interval = 2,
		chance = 22,
		action = function(pos)
			if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1, 0)).name, liquid) ~= 0
			and minetest.get_node(vector.offset(pos, 0, -1, 0)).name == "air" then
				minetest.after(math.random(0.1,1.5),function()
					local pt = table.copy(pdef)
					local x, z = math.random(-45, 45) / 100, math.random(-45, 45) / 100
					pt.pos = vector.offset(pos,x,-0.52,z)
					pt.acceleration = vector.new(0,0,0)
					pt.collisiondetection = false
					pt.expirationtime = math.random(9.5,28.5)

					pt.texture="[combine:2x2:" .. -math.random(1, 16) .. "," .. -math.random(1, 16) .. "=default_" .. liquid .. "_source_animated.png"
					minetest.add_particle(pt)
					minetest.after(pt.expirationtime,function()
						pt.acceleration = vector.new(0,-5,0)
						pt.collisiondetection = true
						pt.expirationtime = math.random(6.2,17.5)
						minetest.add_particle(pt)
						minetest.sound_play({name = "drippingwater_" .. sound .. "drip"}, {pos = ownpos, gain = 0.5, max_hear_distance = 8}, true)
					end)
				end)
			end
		end,
	})
end

register_drop("water", 1, "", {"group:opaque", "group:leaves"})
register_drop("lava", math.max(7, minetest.registered_nodes["mcl_core:lava_source"].light_source - 3), "lava", {"group:opaque"})
