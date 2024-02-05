minetest.register_craft({
	output = "mcl_copper:block_raw",
	recipe = {
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
	},
})

minetest.register_craft({
	output = "mcl_copper:cut 4",
	recipe = {
		{ "mcl_copper:block", "mcl_copper:block" },
		{ "mcl_copper:block", "mcl_copper:block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:waxed_cut 4",
	recipe = {
		{ "mcl_copper:waxed_block", "mcl_copper:waxed_block" },
		{ "mcl_copper:waxed_block", "mcl_copper:waxed_block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:cut_exposed 4",
	recipe = {
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
	},
})

minetest.register_craft({
	output = "mcl_copper:waxed_cut_exposed 4",
	recipe = {
		{ "mcl_copper:waxed_block_exposed", "mcl_copper:waxed_block_exposed" },
		{ "mcl_copper:waxed_block_exposed", "mcl_copper:waxed_block_exposed" },
	},
})

minetest.register_craft({
	output = "mcl_copper:cut_weathered 4",
	recipe = {
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
	},
})

minetest.register_craft({
	output = "mcl_copper:waxed_cut_weathered 4",
	recipe = {
		{ "mcl_copper:waxed_block_weathered", "mcl_copper:waxed_block_weathered" },
		{ "mcl_copper:waxed_block_weathered", "mcl_copper:waxed_block_weathered" },
	},
})

minetest.register_craft({
	output = "mcl_copper:cut_oxidized 4",
	recipe = {
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
	},
})

minetest.register_craft({
	output = "mcl_copper:waxed_cut_oxidized 4",
	recipe = {
		{ "mcl_copper:waxed_block_oxidized", "mcl_copper:waxed_block_oxidized" },
		{ "mcl_copper:waxed_block_oxidized", "mcl_copper:waxed_block_oxidized" },
	},
})

minetest.register_craft({
	output = "mcl_copper:grate 4",
	recipe = {
		{ "", "mcl_copper:block", "" },
		{ "mcl_copper:block", "", "mcl_copper:block" },
		{ "", "mcl_copper:block", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_grate 4",
	recipe = {
		{ "", "mcl_copper:waxed_block", "" },
		{ "mcl_copper:waxed_block", "", "mcl_copper:waxed_block" },
		{ "", "mcl_copper:waxed_block", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:grate_exposed 4",
	recipe = {
		{ "", "mcl_copper:block_exposed", "" },
		{ "mcl_copper:block_exposed", "", "mcl_copper:block_exposed" },
		{ "", "mcl_copper:block_exposed", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_grate_exposed 4",
	recipe = {
		{ "", "mcl_copper:waxed_block_exposed", "" },
		{ "mcl_copper:waxed_block_exposed", "", "mcl_copper:waxed_block_exposed" },
		{ "", "mcl_copper:waxed_block_exposed", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:grate_weathered 4",
	recipe = {
		{ "", "mcl_copper:block_weathered", "" },
		{ "mcl_copper:block_weathered", "", "mcl_copper:block_weathered" },
		{ "", "mcl_copper:block_weathered", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_grate_weathered 4",
	recipe = {
		{ "", "mcl_copper:waxed_block_weathered", "" },
		{ "mcl_copper:waxed_block_weathered", "", "mcl_copper:waxed_block_weathered" },
		{ "", "mcl_copper:waxed_block_weathered", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:grate_oxidized 4",
	recipe = {
		{ "", "mcl_copper:block_oxidized", "" },
		{ "mcl_copper:block_oxidized", "", "mcl_copper:block_oxidized" },
		{ "", "mcl_copper:block_oxidized", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_grate_oxidized 4",
	recipe = {
		{ "", "mcl_copper:waxed_block_oxidized", "" },
		{ "mcl_copper:waxed_block_oxidized", "", "mcl_copper:waxed_block_oxidized" },
		{ "", "mcl_copper:waxed_block_oxidized", "" }
	}
})

minetest.register_craft({
	output = "mcl_copper:chiseled 1",
	recipe = {
		{ "mcl_stairs:slab_copper_cut" },
		{ "mcl_stairs:slab_copper_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_chiseled 1",
	recipe = {
		{ "mcl_stairs:slab_waxed_copper_cut" },
		{ "mcl_stairs:slab_waxed_copper_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:chiseled_exposed 1",
	recipe = {
		{ "mcl_stairs:slab_copper_exposed_cut" },
		{ "mcl_stairs:slab_copper_exposed_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_chiseled_exposed 1",
	recipe = {
		{ "mcl_stairs:slab_waxed_copper_exposed_cut" },
		{ "mcl_stairs:slab_waxed_copper_exposed_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:chiseled_weathered 1",
	recipe = {
		{ "mcl_stairs:slab_copper_weathered_cut" },
		{ "mcl_stairs:slab_copper_weathered_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_chiseled_weathered 1",
	recipe = {
		{ "mcl_stairs:slab_waxed_copper_weathered_cut" },
		{ "mcl_stairs:slab_waxed_copper_weathered_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:chiseled_oxidized 1",
	recipe = {
		{ "mcl_stairs:slab_copper_oxidized_cut" },
		{ "mcl_stairs:slab_copper_oxidized_cut" }
	}
})

minetest.register_craft({
	output = "mcl_copper:waxed_chiseled_oxidized 1",
	recipe = {
		{ "mcl_stairs:slab_waxed_copper_oxidized_cut" },
		{ "mcl_stairs:slab_waxed_copper_oxidized_cut" }
	}
})

local waxable_blocks = {
	"block",
	"cut",
	"grate",
	"chiseled",
	"block_exposed",
	"cut_exposed",
	"grate_exposed",
	"chiseled_exposed",
	"block_weathered",
	"cut_weathered",
	"grate_weathered",
	"chiseled_weathered",
	"block_oxidized",
	"cut_oxidized",
	"grate_oxidized",
	"chiseled_oxidized"
}

for _, w in ipairs(waxable_blocks) do
	minetest.register_craft({
		output = "mcl_copper:waxed_"..w,
		recipe = {
			{ "mcl_copper:"..w, "mcl_honey:honeycomb" },
		},
	})
end

local cuttable_blocks = {
	"block",
	"waxed_block",
	"block_exposed",
	"waxed_block_exposed",
	"block_weathered",
	"waxed_block_weathered",
	"block_oxidized",
	"waxed_block_oxidized"
}

for _, c in ipairs(cuttable_blocks) do
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c:gsub("block", "cut"), 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c:gsub("block", "grate"), 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c, "mcl_copper:"..c:gsub("block", "chiseled"), 4)
	mcl_stonecutter.register_recipe("mcl_copper:"..c:gsub("block", "cut"), "mcl_copper:"..c:gsub("block", "chiseled"), 1)
end

minetest.register_craft({
	output = "mcl_copper:copper_ingot 9",
	recipe = {
		{ "mcl_copper:block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:raw_copper 9",
	recipe = {
		{ "mcl_copper:block_raw" },
	},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:raw_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:stone_with_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:block",
	recipe = "mcl_copper:block_raw",
	cooktime = 90,
})
