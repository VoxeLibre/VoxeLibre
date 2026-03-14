local random = math.random

local ipairs = ipairs

mcl_death_drop = {}

mcl_death_drop.registered_dropped_lists = {}
mcl_death_drop.on_death_drop_per_stack = {}

local keep_inventory = vl_tuning.setting("gamerule:keepInventory")

function mcl_death_drop.register_dropped_list(inv, listname, drop)
	table.insert(mcl_death_drop.registered_dropped_lists, {inv = inv, listname = listname, drop = drop})
end

function mcl_death_drop.register_on_death_drop_per_stack(func)
	table.insert(mcl_death_drop.on_death_drop_per_stack, func)
end

mcl_death_drop.register_dropped_list("PLAYER", "main", true)
mcl_death_drop.register_dropped_list("PLAYER", "craft", true)
mcl_death_drop.register_dropped_list("PLAYER", "craftresult", true)
mcl_death_drop.register_dropped_list("PLAYER", "armor", true)
mcl_death_drop.register_dropped_list("PLAYER", "offhand", true)
mcl_death_drop.register_dropped_list("PLAYER", "distr", true)

minetest.register_on_dieplayer(function(player)
	if not keep_inventory.getter() then
		-- Drop inventory, crafting grid and armor
		local playerinv = player:get_inventory()
		local pos = player:get_pos()
		-- No item drop if in deep void
		local _, void_deadly = mcl_worlds.is_in_void(pos)

		for l=1,#mcl_death_drop.registered_dropped_lists do
			local inv = mcl_death_drop.registered_dropped_lists[l].inv
			if inv == "PLAYER" then
				inv = playerinv
			elseif type(inv) == "function" then
				inv = inv(player)
			end
			local listname = mcl_death_drop.registered_dropped_lists[l].listname
			local drop = mcl_death_drop.registered_dropped_lists[l].drop
			local dropspots = minetest.find_nodes_in_area(vector.offset(pos,-3,0,-3),vector.offset(pos,3,0,3),{"air"})
			if #dropspots == 0 then
				table.insert(dropspots,pos)
			end
			if inv then
				for i, stack in ipairs(inv:get_list(listname)) do
					local was_handled = false
					for _, on_death_drop in ipairs(mcl_death_drop.on_death_drop_per_stack) do
						if on_death_drop ~= nil and on_death_drop(player, inv, listname, i, stack) then
							was_handled = true
						end
					end
					if not was_handled then
						local p = vector.offset(dropspots[math.random(#dropspots)],math.random()-0.5,math.random()-0.5,math.random()-0.5)
						if not void_deadly and drop then
							local def = minetest.registered_items[stack:get_name()]
							if def and def.on_drop then
								stack = def.on_drop(stack, player, p)
							end
							core.add_item(p, stack)
						end
						inv:set_stack(listname, i, nil)
					end
				end
			end
		end
	end
end)
