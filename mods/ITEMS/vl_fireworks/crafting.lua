-- Firework Star
core.register_craft({ -- temporary
	type = "shapeless",
	output = "vl_fireworks:firework_star",
	recipe = {"mcl_mobitems:gunpowder", "mcl_core:clay_lump"}
})
core.register_craft({ -- temporary
	type = "shapeless",
	output = "vl_fireworks:firework_star",
	recipe = {"mcl_mobitems:gunpowder", "mcl_core:clay_lump", "mcl_fire:fire_charge"}
})
core.register_craft({ -- temporary
	type = "shapeless",
	output = "vl_fireworks:firework_star",
	recipe = {"mcl_mobitems:gunpowder", "mcl_core:clay_lump", "mcl_end:crystal"}
})

local function craft_star(itemstack, player, old_grid)
	if itemstack:get_name() ~= "vl_fireworks:firework_star" then return end
	local size = 1

	-- analyze the recipe used
	for _, item in pairs(old_grid) do
		if item:get_name() == "mcl_fire:fire_charge" then
			size = 2
			break
		end
		if item:get_name() == "mcl_end:crystal" then
			size = 3
			break
		end
	end

	local effect = {
		fn = "generic",
		size = size
	}
	itemstack:get_meta():set_string("vl_fireworks:star_effect", core.serialize(effect))
	tt.reload_itemstack_description(itemstack)
	return itemstack
end
core.register_craft_predict(craft_star)
core.register_on_craft(craft_star)

-- Firework Rocket
local function register_firework_crafts()
	local r1 = {"mcl_core:paper"}
	local r2 = table.copy(r1)
	table.insert(r2, "vl_fireworks:firework_star") -- TODO replace with a loop or such to allow more stars
	for i=1, 3 do
		table.insert(r1, "mcl_mobitems:gunpowder")
		table.insert(r2, "mcl_mobitems:gunpowder")
		core.register_craft({
			type = "shapeless",
			output = "vl_fireworks:rocket 3",
			recipe = r1,
		})
		core.register_craft({
			type = "shapeless",
			output = "vl_fireworks:rocket 3",
			recipe = r2,
		})
	end
end
register_firework_crafts()

local function craft_firework(itemstack, player, old_grid)
	if itemstack:get_name() ~= "vl_fireworks:rocket" then return end
	local gp = 0 -- gunpowder
	local stars = {}

	-- analyze the recipe used
	for _, item in pairs(old_grid) do
		if item:get_name() == "mcl_mobitems:gunpowder" then gp = gp + 1 end
		if item:get_name() == "vl_fireworks:firework_star" then
			local effect = item:get_meta():get("vl_fireworks:star_effect")
				or core.serialize({fn="generic"})
			table.insert(stars, effect)
		end
	end

	-- determine duration and force from the amount of gunpowder used
	local tbl = vl_fireworks.firework_def._vl_fireworks_std_durs_forces[gp]
	local meta = itemstack:get_meta()
	meta:set_float("vl_fireworks:duration", tbl[1])
	meta:set_int("vl_fireworks:force", tbl[2])

	-- write star effects into metadata
	meta:set_string("vl_fireworks:stars", core.serialize(stars))

	tt.reload_itemstack_description(itemstack)
	return itemstack
end
core.register_craft_predict(craft_firework)
core.register_on_craft(craft_firework)
