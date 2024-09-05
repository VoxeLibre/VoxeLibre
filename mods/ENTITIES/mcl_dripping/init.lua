-- Dripping Water Mod
-- by kddekadenz
-- License of code, textures & sounds: CC0

local math = math

mcl_dripping = {}


---@param pos Vector
---@param liquid string
---@param sound SimpleSoundSpec
---@param interval integer
---@param texture string
local function make_drop(pos, liquid, sound, interval, texture)
	local pt = {
		velocity = vector.zero(),
		collision_removal = false,
	}

	local t = math.random() + math.random(1, interval)

	minetest.after(t, function()
		local x, z = math.random(-45, 45) / 100, math.random(-45, 45) / 100

		pt.pos = vector.offset(pos, x, -0.52, z)
		pt.acceleration = vector.zero()
		pt.collisiondetection = false
		pt.expirationtime = t

		pt.texture = "[combine:2x2:" ..
			math.random(-14, 0) .. "," .. math.random(-14, 0) .. "=" .. texture

		minetest.add_particle(pt)

		minetest.after(t, function()
			pt.acceleration = vector.new(0, -5, 0)
			pt.collisiondetection = true
			pt.expirationtime = math.random() + math.random(1, interval / 2)

			minetest.add_particle(pt)

			minetest.sound_play(sound, { pos = pos, gain = 0.5, max_hear_distance = 8 },
				true)
		end)
	end)
end

---@class mcl_dripping_drop_definition
---@field liquid string The group the liquid's nodes belong to
---@field texture string The texture used (particles will take a random 2x2 area of it)
---@field light integer Define particle glow, ranges from `0` to `minetest.LIGHT_MAX`
---@field nodes string[] The nodes (or node group) the particles will spawn under
---@field interval integer The interval for the ABM to run
---@field chance integer The chance of the ABM
---@field sound SimpleSoundSpec The sound that will be played then the particle detaches from the roof

---@param def mcl_dripping_drop_definition
function mcl_dripping.register_drop(def)
	minetest.register_abm({
		label = "Create drops",
		nodenames = def.nodes,
		neighbors = { "group:" .. def.liquid },
		interval = def.interval,
		chance = def.chance,
		action = function(pos)
			local below = minetest.get_node(vector.offset(pos,0,-1,0)).name
			if below ~= "air" then return end
			local r = math.ceil(def.interval / 20)
			local nn = minetest.find_nodes_in_area(vector.offset(pos, -r, 0, -r), vector.offset(pos, r, 0, r), def.nodes)
			--start a bunch of particle cycles to be able to get away
			--with longer abm cycles
			table.shuffle(nn)
			for i = 1, math.random(#nn) do
				if minetest.get_item_group(minetest.get_node(vector.offset(nn[i], 0, 1, 0)).name, def.liquid) ~= 0 then
					make_drop(nn[i], def.liquid, def.sound, def.interval, def.texture)
				end
			end
		end,
	})
end

mcl_dripping.register_drop({
	liquid   = "water",
	texture  = "mcl_core_water_source_animation.png",
	light    = 1,
	nodes    = { "group:opaque", "group:leaves" },
	sound    = "drippingwater_drip",
	interval = 60.3,
	chance   = 10,
})

mcl_dripping.register_drop({
	liquid   = "lava",
	texture  = "mcl_core_lava_source_animation.png",
	light    = math.max(7, minetest.registered_nodes["mcl_core:lava_source"].light_source - 3),
	nodes    = { "group:opaque" },
	sound    = "drippingwater_lavadrip",
	interval = 110.1,
	chance   = 10,
})
