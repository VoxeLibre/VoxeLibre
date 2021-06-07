local hud_totem = {}

minetest.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

-- Totem particle registration
-- TODO: real MC colors, these are randomly selected colors:
local colors = {"#7FFF00", "#698B22", "#BCEE68", "#EEEE00", "#C5F007"}
minetest.register_entity("mcl_totems:totem_particle", {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.02,-0.02,-0.02, 0.02,0.02,0.02},
	pointable = false,
	visual = "sprite",
	visual_size = {x=0.2, y=0.2},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	static_save = false,
	glow = 5,
	on_activate = function(self, staticdata)
		self.object:set_properties({
			textures = {"mcl_particles_totem"..math.random(1, 4)..".png^[colorize:"..colors[math.random(#colors)]}
		})
		self.object:set_velocity({x = math.random(-4, 4)*math.random(), y = math.random(-1, 4)*math.random(), z = math.random(-4, 4)*math.random()})
		minetest.after(0.3, function()
			self.object:set_acceleration({x=0, y=-4, z=0})
			self.object:set_velocity({x=0, y=0, z=0})
		end)
	end,
	on_step = function(self, dtime)
		local r = math.random(1,50)
		if r == 1 then
			self.object:remove()
		end
	end
})

-- Save the player from death when holding totem of undying in hand
mcl_damage.register_modifier(function(obj, damage, reason)
	if obj:is_player() then
		local hp = obj:get_hp()
		if hp - damage <= 0 then
			local wield = obj:get_wielded_item()
			if wield:get_name() == "mobs_mc:totem" then
				local ppos = obj:get_pos()
				local pnname = minetest.get_node(ppos).name
				-- Some exceptions when _not_ to save the player
				for n=1, #mobs_mc.misc.totem_fail_nodes do
					if pnname == mobs_mc.misc.totem_fail_nodes[n] then
						return
					end
				end
				-- Reset breath as well
				if obj:get_breath() < 11 then
					obj:set_breath(10)
				end

				if not minetest.is_creative_enabled(obj:get_player_name()) then
					wield:take_item()
					obj:set_wielded_item(wield)
				end

				-- Effects
				minetest.sound_play({name = "mcl_totems_totem", gain=1}, {pos=ppos, max_hear_distance=16}, true)

				--Particles
				for i = 1, 150 do
					minetest.after(math.random(1, 2)*math.random(), function()
						local new_pos = obj:get_pos()
						minetest.add_entity({x = new_pos.x, y = new_pos.y + 1, z = new_pos.z}, "mcl_totems:totem_particle")
					end)
				end

				-- Big totem overlay 
				if not hud_totem[obj] then
					hud_totem[obj] = obj:hud_add({
						hud_elem_type = "image",
						text = "mcl_totems_totem.png",
						position = { x=0.5, y=1 },
						scale = { x=17, y=17 },
						offset = { x=0, y=-178 },
						z_index = 100,
					})
					minetest.after(3, function()
						if obj:is_player() then
							obj:hud_remove(hud_totem[obj])
							hud_totem[obj] = nil
						end
					end)
				end

				-- Set HP to exactly 1
				return hp - 1
			end
		end
	end
end, 1000)