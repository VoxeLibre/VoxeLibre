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
---@param core.ItemStack
---@return nil
function mod.convert_itemstack(itemstack)
	local conversion = itemstack and item_conversions[itemstack:get_name()]
	if conversion then
		local new_name,func = conversion[1],conversion[2]
		if func then
			func(itemstack)
		else
			itemstack:set_name(new_name)
		end
	end
end
function mod.convert_inventory_lists(lists)
	for _,list in pairs(lists) do
		for i = 1,#list do
			mod.convert_itemstack(list[i])
		end
	end
end
function mod.convert_inventory(inv)
	local lists = inv:get_lists()
	mod.convert_inventory_lists(lists)
	inv:set_lists(lists)
end
function mod.convert_node(pos, node)
	local node = node or minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	local convert = node_def._vl_legacy_convert_node
	if type(convert) == "function" then
		convert(pos, node)
	elseif type(convert) == "string" then
		node.name = convert
		minetest.swap_node(pos, node)
	end
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
minetest.register_lbm({
	name = "vl_legacy:convert_nodes",
	nodenames = "group:legacy",
	run_at_every_load = true,
	action = mod.convert_node,
})
minetest.register_abm({
	label = "Convert Legacy Nodes",
	nodenames = "group:legacy",
	interval = 5,
	chance = 1,
	action = mod.convert_node,
})
