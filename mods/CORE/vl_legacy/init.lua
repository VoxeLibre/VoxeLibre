local mod = {}
vl_legacy = mod

function mod.deprecated(description, func)
	return function(...)
		minetest.log("warning",description .. debug.traceback())
		return func(...)
	end
end

local item_conversions = {}
mod.registered_item_conversions = item_conversions

function mod.register_item_conversion(old, new, func)
	item_conversions[old] = {new, func}
end
function mod.convert_inventory_lists(lists)
	for _,list in pairs(lists) do
		for i = 1,#list do
			local itemstack = list[i]
			local conversion = item_conversions[itemstack:get_name()]
			if conversion then
				local new_name,func = conversion[1],conversion[2]
				if func then
					func(itemstack)
				else
					itemstack:set_name(new_name)
				end
			end
		end
	end
end
function mod.convert_inventory(inv)
	local lists = inv:get_lists()
	mod.convert_inventory_lists(lists)
	inv:set_lists(lists)
end

minetest.register_on_joinplayer(function(player)
	mod.convert_inventory(player:get_inventory())
end)

minetest.register_lbm({
	name = "vl_legacy:convert_container_inventories",
	nodenames = "group:container",
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		mod.convert_inventory(meta:get_inventory())
	end
})

