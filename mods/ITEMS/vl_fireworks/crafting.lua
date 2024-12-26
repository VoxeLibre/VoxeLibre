local function register_firework_crafts()
	local recipe = {"mcl_core:paper"}
	for i=1, 3 do
		table.insert(recipe, "mcl_mobitems:gunpowder")
		minetest.register_craft({
			type = "shapeless",
			output = "vl_fireworks:rocket 3",
			recipe = recipe,
		})
	end
end
register_firework_crafts()

local function craft_firework(itemstack, player, old_grid)
	if itemstack:get_name() ~= "vl_fireworks:rocket" then return end
	local gp = 0
	for _, item in pairs(old_grid) do
		if item:get_name() == "mcl_mobitems:gunpowder" then gp = gp + 1 end
	end
	local tbl = vl_fireworks.firework_def._vl_fireworks_std_durs_forces[gp]
	local meta = itemstack:get_meta()
	meta:set_float("vl_fireworks:duration", tbl[1])
	meta:set_int("vl_fireworks:force", tbl[2])
	tt.reload_itemstack_description(itemstack)
	return itemstack
end
core.register_craft_predict(craft_firework)
core.register_on_craft(craft_firework)
