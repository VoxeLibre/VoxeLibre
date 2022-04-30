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
			local in_offhand = false
			if not (wield:get_name() == "mobs_mc:totem") then
				local inv = obj:get_inventory()
				if inv then
					wield = obj:get_inventory():get_stack("offhand", 1)
					in_offhand = true
				end
			end
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
					if in_offhand then
						obj:get_inventory():set_stack("offhand", 1, wield)
						mcl_inventory.update_inventory_formspec(obj)
					else
						obj:set_wielded_item(wield)
					end
				end

				-- Effects
				minetest.sound_play({name = "mcl_totems_totem", gain = 1}, {pos=ppos, max_hear_distance = 16}, true)
				
				for i = 1, 4 do
					for c = 1, #particle_colors do
						minetest.add_particlespawner({
    							amount = math.floor(100 / (4 * #particle_colors)),
    							time = 1,
    							minpos = vector.offset(ppos, 0, -1, 0),
    							maxpos = vector.offset(ppos, 0, 1, 0),
    							minvel = vector.new(-1.5, 0, -1.5),
    							maxvel = vector.new(1.5, 1.5, 1.5),
    							minacc = vector.new(0, -0.1, 0),
    							maxacc = vector.new(0, -1, 0),
    							minexptime = 1,
    							maxexptime = 3,
    							minsize = 1,
    							maxsize = 2,
    							collisiondetection = true,
    							collision_removal = true,
    							object_collision = false,
    							vertical = false,
    							texture = "mcl_particles_totem" .. i .. ".png^[colorize:#" .. particle_colors[c],
    							glow = 10,
    						})
					end
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
