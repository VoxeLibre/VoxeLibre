local S = minetest.get_translator("extra_mobs")

local pr = PseudoRandom(os.time()*(-334))

minetest.register_entity("extra_mobs:hb_eye", {
	visual = "mesh",
	mesh = "mcl_armor_character.b3d",
	textures = {"extra_mobs_herobrine_eyes.png", "extra_mobs_trans.png", "extra_mobs_trans.png" },
	visual_size = {x=1, y=1},
	on_activate = function(self)
		for _,hb in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 1)) do
			if not hb:is_player() and hb:get_luaentity().name == "extra_mobs:herobrine" then
				self.object:set_attach(hb, "Head", {x=0,y=-13.5,z=0}, {x=0,y=0,z=0})
			end
		end
	end,
	do_custom = function(self)
		if self.object:get_attach() == nil then
			self.object:remove()
		end
	end,
	glow = 10
})

mobs:register_mob("extra_mobs:herobrine", {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 1000,
	xp_max = 1000,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 2, 0.3},
	visual = "mesh",
	mesh = "mcl_armor_character.b3d",
	textures = {"character.png", "extra_mobs_trans.png", "extra_mobs_trans.png" },
	visual_size = {x=1, y=1},
	makes_footstep_sound = false,
	walk_velocity = 0,
	run_velocity = 0,
	damage = 10,
	reach = 1,
	armor = {fleshy = 0},
	view_range = 1000,
	attack_type = "dogfight",
	can_despawn = false,
	on_spawn = function(self)
		--if self.object:get_children() == nil then
		minetest.add_entity(self.object:get_pos(), "extra_mobs:hb_eye")
		--end
	end,
	do_custom = function(self)
		for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 30)) do
			if object:is_player() then
				pos = self.object:get_pos()
				local randomCube = vector.new( pos.x + 8*(pr:next(0,16)-8), pos.y + 8*(pr:next(0,16)-8), pos.z + 8*(pr:next(0,16)-8) )
				local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(randomCube, 4), vector.add(randomCube, 4), {"group:solid", "group:cracky", "group:crumbly"})
				local telepos
				if nodes ~= nil then
					if #nodes > 0 then
						-- Up to 64 attempts to teleport
						for n=1, math.min(64, #nodes) do
							local r = pr:next(1, #nodes)
							local nodepos = nodes[r]
							local node_ok = true
							-- Selected node needs to have 3 nodes of free space above
							for u=1, 3 do
								local node = minetest.get_node({x=nodepos.x, y=nodepos.y+u, z=nodepos.z})
								if minetest.registered_nodes[node.name].walkable then
									node_ok = false
									break
								end
							end
							if node_ok then
								telepos = {x=nodepos.x, y=nodepos.y+1, z=nodepos.z}
							end
						end
						if telepos then
							self.object:set_pos(telepos)
						end
					end
				end
			end
		end
	end,
})
