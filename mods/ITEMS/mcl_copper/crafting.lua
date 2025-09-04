core.register_craft({
	output = "mcl_copper:block_raw",
	recipe = {
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
	},
})

core.register_craft({
	output = "mcl_copper:block",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
	},
})

core.register_craft({
	output = "mcl_copper:block_cut 4",
	recipe = {
		{ "mcl_copper:block", "mcl_copper:block" },
		{ "mcl_copper:block", "mcl_copper:block" },
	},
})

core.register_craft({
	output = "mcl_copper:block_exposed_cut 4",
	recipe = {
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
	},
})

core.register_craft({
	output = "mcl_copper:block_oxidized_cut 4",
	recipe = {
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
	},
})

core.register_craft({
	output = "mcl_copper:block_weathered_cut 4",
	recipe = {
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
	},
})

local waxable_blocks = { "block", "block_cut", "block_exposed", "block_exposed_cut", "block_weathered", "block_weathered_cut", "block_oxidized", "block_oxidized_cut" }

for _, w in ipairs(waxable_blocks) do
	core.register_craft({
		output = "mcl_copper:waxed_"..w,
		recipe = {
			{ "mcl_copper:"..w, "mcl_honey:honeycomb" },
		},
	})
end

local cuttable_blocks = { "block", "waxed_block", "block_exposed", "waxed_block_exposed", "block_weathered", "waxed_block_weathered", "block_oxidized", "waxed_block_oxidized" }

for _, c in ipairs(cuttable_blocks) do
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c.."_cut", 4)
end

core.register_craft({
	output = "mcl_copper:copper_ingot 9",
	recipe = {
		{ "mcl_copper:block" },
	},
})

core.register_craft({
	output = "mcl_copper:raw_copper 9",
	recipe = {
		{ "mcl_copper:block_raw" },
	},
})

core.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:raw_copper",
	cooktime = 10,
})

core.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:stone_with_copper",
	cooktime = 10,
})

core.register_craft({
	type = "cooking",
	output = "mcl_copper:block",
	recipe = "mcl_copper:block_raw",
	cooktime = 90,
})
