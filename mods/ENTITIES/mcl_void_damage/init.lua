local voidtimer = 0

minetest.register_globalstep(function(dtime)
	voidtimer = voidtimer + dtime
	if voidtimer > 0.5 then
		voidtimer = 0
		local objs = minetest.object_refs
		local enable_damage = minetest.settings:get_bool("enable_damage")
		for id, obj in pairs(objs) do
			local pos = obj:get_pos()
			local void, void_deadly = mcl_worlds.is_in_void(pos)
			if void_deadly then
				local is_player = obj:is_player()
				local ent = obj:get_luaentity()
				local immortal_val = obj:get_armor_groups().immortal
				local is_immortal = false
				if immortal_val and immortal_val > 0 then
					is_immortal = true
				end
				if is_immortal or not enable_damage then
					if is_player then
						-- If damage is disabled, we can't kill players.
						-- So we just teleport the player back to spawn.
						local spawn = mcl_spawn.get_spawn_pos(obj)
						obj:set_pos(spawn)
						mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(spawn))
						minetest.chat_send_player(obj:get_player_name(), "The void is off-limits to you!")
					else
						obj:remove()
					end
				elseif enable_damage and not is_immortal then
					-- Damage enabled, not immortal: Deal void damage (4 HP / 0.5 seconds)
					if obj:get_hp() > 0 then
						if is_player then
							mcl_death_messages.player_damage(obj, string.format("%s fell into the endless void.", obj:get_player_name()))
						end
						obj:set_hp(obj:get_hp() - 4)
					end
				end
			end
		end
	end
end)
