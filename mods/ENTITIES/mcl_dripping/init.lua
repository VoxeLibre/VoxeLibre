-- Dripping Water Mod
-- by kddekadenz
-- License of code, textures & sounds: CC0

local math = math
local function make_drop(pos,liquid,sound,interval)
	local pt = {
		velocity = vector.new(0,0,0),
		collision_removal = false,
	}
	local t = math.random() + math.random(1, interval)
	minetest.after(t,function()
		local x, z = math.random(-45, 45) / 100, math.random(-45, 45) / 100
		pt.pos = vector.offset(pos,x,-0.52,z)
		pt.acceleration = vector.new(0,0,0)
		pt.collisiondetection = false
		pt.expirationtime = t

		pt.texture="[combine:2x2:" .. -math.random(1, 16) .. "," .. -math.random(1, 16) .. "=default_" .. liquid .. "_source_animated.png"
		minetest.add_particle(pt)
		minetest.after(t,function()
			pt.acceleration = vector.new(0,-5,0)
			pt.collisiondetection = true
			pt.expirationtime = math.random() + math.random(1, interval/2)
			minetest.add_particle(pt)
			minetest.sound_play({name = "drippingwater_" .. sound .. "drip"}, {pos = pos, gain = 0.5, max_hear_distance = 8}, true)
		end)
	end)
end

local function register_drop(liquid, glow, sound, nodes, interval, chance)
	minetest.register_abm({
		label = "Create drops",
		nodenames = nodes,
		neighbors = {"group:" .. liquid},
		interval = interval,
		chance = chance,
		action = function(pos)
			local r = math.ceil(interval / 20)
			local nn=minetest.find_nodes_in_area(vector.offset(pos,-r,0,-r),vector.offset(pos,r,0,r),nodes)
			--start a bunch of particle cycles to be able to get away
			--with longer abm cycles
			table.shuffle(nn)
			for i=1,math.random(#nn) do
				if nn[i] and minetest.get_item_group(minetest.get_node(vector.offset(nn[i], 0, 1, 0)).name, liquid) ~= 0
				and minetest.get_node(vector.offset(nn[i], 0, -1, 0)).name == "air" then
					make_drop(nn[i],liquid,sound,interval)
				end
			end
		end,
	})
end

register_drop("water", 1, "", {"group:opaque", "group:leaves"},60,10)
register_drop("lava", math.max(7, minetest.registered_nodes["mcl_core:lava_source"].light_source - 3), "lava", {"group:opaque"},60,10)
