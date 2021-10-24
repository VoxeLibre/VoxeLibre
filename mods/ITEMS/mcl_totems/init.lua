local hud_totem = {}

minetest.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

local particle_colors = {"98BF22", "C49E09", "337D0B", "B0B021", "1E9200"} -- TODO: real MC colors

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
				for n = 1, #mobs_mc.misc.totem_fail_nodes do
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
				minetest.sound_play({name = "mcl_totems_totem", gain = 1}, {pos=ppos, max_hear_distance = 16}, true)
				
				for i = 1, 100 do
					minetest.add_particle({
						pos = vector.offset(ppos, 0, math.random(-10, 10) / 10, 0),
        					velocity = vector.new(math.random(-15, 15) / 10, math.random(0, 15) / 10, math.random(-15, 15) / 10),
        					acceleration = vector.new(0, -math.random(1, 10) / 10, 0),
        					expirationtime = math.random(1, 3),
        					size = math.random(1, 2),
        					collisiondetection = true,
        					collision_removal = true,
        					object_collision = false,
        					texture = "mcl_particles_totem" .. math.random(1, 4) .. ".png^[colorize:#" .. particle_colors[math.random(#particle_colors)],
        					glow = 10,
					})
					
				end

				-- Big totem overlay
				if not hud_totem[obj] then
					hud_totem[obj] = obj:hud_add({
						hud_elem_type = "image",
						text = "mcl_totems_totem.png",
						position = {x = 0.5, y = 1},
						scale = {x = 17, y = 17},
						offset = {x = 0, y = -178},
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
