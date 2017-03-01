--if minetest.setting_get("keepInventory") == false then
	minetest.register_on_dieplayer(function(player)
		local inv = player:get_inventory()
		local pos = player:getpos()
		local lists = { "main", "craft", "armor" }
		for l=1,#lists do
			for i,stack in ipairs(inv:get_list(lists[l])) do
				local x = math.random(0, 9)/3
				local z = math.random(0, 9)/3
				pos.x = pos.x + x
				pos.z = pos.z + z
				minetest.add_item(pos, stack)
				stack:clear()
				inv:set_stack(lists[l], i, stack)
				pos.x = pos.x - x
				pos.z = pos.z - z
			end
		end
	end)
--end
