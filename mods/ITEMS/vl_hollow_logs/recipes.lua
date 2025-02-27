function vl_hollow_logs.register_craft(material, result)
	core.register_craft({
		output = "vl_hollow_logs:"..result.."_hollow 4",
		recipe = {
			{"",  material, ""},
			{material, "", material},
			{"", material, ""}
		},
		type = "shaped"
	})

	core.register_craft({
		output = "vl_hollow_logs:"..result.."_hollow_ladder",
		recipe = {
			"vl_hollow_logs:"..result.."_hollow",
			"mcl_core:ladder"
		},
		type = "shapeless"
	})

	mcl_stonecutter.register_recipe(material, "vl_hollow_logs:"..result.."_hollow", 1)
end

for _, defs in pairs(vl_hollow_logs.logs) do
	local mod, material, stripped_material
	local name = defs[1]
	local stripped_name = defs[2]

	if name:find("cherry") then
		mod = "mcl_cherry_blossom:"
	elseif name:find("mangrove") then
		mod = "mcl_mangrove:"
	elseif name:find("hyphae") then
		mod = "mcl_crimson:"
	else
		mod = "mcl_core:"
	end

	material = mod..name
	stripped_material = mod..stripped_name

	vl_hollow_logs.register_craft(material, name)
	vl_hollow_logs.register_craft(stripped_material, stripped_name)
end

core.register_craft({
	burntime = 10,
	recipe = "group:hollow_log_burnable",
	type = "fuel",
})

core.register_craft({
	cooktime = 5,
	output = "mcl_core:charcoal_lump",
	recipe = "group:hollow_log_burnable",
	type = "cooking"
})
