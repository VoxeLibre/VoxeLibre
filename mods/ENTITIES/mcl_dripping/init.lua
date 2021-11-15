-- Dripping Water Mod
-- by kddekadenz

local math = math

-- License of code, textures & sounds: CC0

local function register_drop(liquid, glow, sound, nodes)
	minetest.register_entity("mcl_dripping:drop_" .. liquid, {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.01, 0.01, -0.01, 0.01, 0.01, 0.01},
		glow = glow,
		pointable = false,
		visual = "sprite",
		visual_size = {x = 0.1, y = 0.1},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		static_save = false,
		_dropped = false,
		on_activate = function(self)
			self.object:set_properties({
				textures = {"[combine:2x2:" .. -math.random(1, 16) .. "," .. -math.random(1, 16) .. "=default_" .. liquid .. "_source_animated.png"}
			})
		end,
		on_step = function(self, dtime)
			local k = math.random(1, 222)
			local ownpos = self.object:get_pos()
			if k == 1 then
				self.object:set_acceleration(vector.new(0, -5, 0))
			end
			if minetest.get_node(vector.offset(ownpos, 0, 0.5, 0)).name == "air" then
				self.object:set_acceleration(vector.new(0, -5, 0))
			end
			if minetest.get_node(vector.offset(ownpos, 0, -0.1, 0)).name ~= "air" then
				local ent = self.object:get_luaentity()
				if not ent._dropped then
					ent._dropped = true
					minetest.sound_play({name = "drippingwater_" .. sound .. "drip"}, {pos = ownpos, gain = 0.5, max_hear_distance = 8}, true)
				end
				if k < 3 then
					self.object:remove()
				end
			end
		end,
	})
	minetest.register_abm({
		label = "Create drops",
		nodenames = nodes,
		neighbors = {"group:" .. liquid},
		interval = 2,
		chance = 22,
		action = function(pos)
			if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1, 0)).name, liquid) ~= 0
			and minetest.get_node(vector.offset(pos, 0, -1, 0)).name == "air" then
				local x, z = math.random(-45, 45) / 100, math.random(-45, 45) / 100
				minetest.add_entity(vector.offset(pos, x, -0.520, z), "mcl_dripping:drop_" .. liquid)
			end
		end,
	})
end

register_drop("water", 1, "", {"group:opaque", "group:leaves"})
register_drop("lava", math.max(7, minetest.registered_nodes["mcl_core:lava_source"].light_source - 3), "lava", {"group:opaque"})