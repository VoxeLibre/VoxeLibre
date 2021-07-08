local hud_totem = {}

minetest.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

-- Totem particle registration
function rgb_to_hex(rgb)
	local hexadecimal = "#"

	for key, value in pairs(rgb) do
		local hex = ""

		while value > 0 do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub("0123456789ABCDEF", index, index) .. hex
		end

		local len = string.len(hex)

		if len == 0 then
			hex = "00"
		elseif len == 1 then
			hex = "0" .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

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
	glow = 14,
	on_activate = function(self, staticdata)
		local color
		if math.random(0, 3) == 0 then
			color = rgb_to_hex({ (0.6 + math.random() * 0.2) * 255, (0.6 + math.random() * 0.3) * 255, (math.random() * 0.2) * 255 })
		else
			color = rgb_to_hex({ (0.1 + math.random() * 0.4) * 255, (0.6 + math.random() * 0.3) * 255, (math.random() * 0.2) * 255 })
		end
		self.object:set_properties({
			textures = { "mcl_particles_totem"..math.random(1, 4)..".png^[colorize:"..color }
		})
		local t = math.random(1, 2)*math.random()
		minetest.after(t, function()
			self.object:set_velocity({x = math.random(-4, 4)*math.random(), y = math.random(-1, 4)*math.random(), z = math.random(-4, 4)*math.random()})
		end)
		minetest.after(0.3 + t, function()
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
				
				minetest.after(0.1, function()
					local new_pos = obj:get_pos()
					if not new_pos then return end
					local particlepos = {x = new_pos.x, y = new_pos.y + 1, z = new_pos.z}
					for i = 1, 150 do
						minetest.add_entity(particlepos, "mcl_totems:totem_particle")
					end
				end)

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