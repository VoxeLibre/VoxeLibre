local random = math.random

local ipairs = ipairs

mcl_death_drop = {}

mcl_death_drop.registered_dropped_lists = {}
mcl_death_drop.on_death_drop_per_stack = {}
mcl_death_drop.ORDER = {
	VOID = -1000,
	SELECTIVE = 0,
	CATCH_ALL = 1000,
}

local callback_sequence = 0
local callbacks_dirty = false

local keep_inventory = vl_tuning.setting("gamerule:keepInventory")

function mcl_death_drop.register_dropped_list(inv, listname, drop)
	table.insert(mcl_death_drop.registered_dropped_lists, {inv = inv, listname = listname, drop = drop})
end

function mcl_death_drop.register_on_death_drop_per_stack(func, priority)
	callback_sequence = callback_sequence + 1
	table.insert(mcl_death_drop.on_death_drop_per_stack, {
		func = func,
		priority = priority or mcl_death_drop.ORDER.SELECTIVE,
		sequence = callback_sequence,
	})
	callbacks_dirty = true
end

local function sort_callbacks()
	if not callbacks_dirty then
		return
	end

	table.sort(mcl_death_drop.on_death_drop_per_stack, function(a, b)
		if a.priority == b.priority then
			return a.sequence < b.sequence
		end
		return a.priority < b.priority
	end)
	callbacks_dirty = false
end

mcl_death_drop.register_dropped_list("PLAYER", "main", true)
mcl_death_drop.register_dropped_list("PLAYER", "craft", true)
mcl_death_drop.register_dropped_list("PLAYER", "craftresult", true)
mcl_death_drop.register_dropped_list("PLAYER", "armor", true)
mcl_death_drop.register_dropped_list("PLAYER", "offhand", true)
mcl_death_drop.register_dropped_list("PLAYER", "distr", true)

minetest.register_on_dieplayer(function(player)
	if not keep_inventory.getter() then
		sort_callbacks()
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
						if on_death_drop.func ~= nil and on_death_drop.func(player, inv, listname, i, stack) then
							was_handled = true
							break
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
