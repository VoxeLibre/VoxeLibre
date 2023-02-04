--local deepslate_mod = minetest.get_modpath("mcl_deepslate")

local function register_oxidation_abm(abm_name, node_name, oxidized_variant)
	minetest.register_abm({
		label = abm_name,
		nodenames = { node_name },
		interval = 500,
		chance = 3,
		action = function(pos, node)
			minetest.swap_node(pos, { name = oxidized_variant, param2 = node.param2 })
		end,
	})
end

--[[
local stairs = {
	{"stair", "exposed", "_inner", "cut_inner"},
	{"stair", "weathered", "_inner", "exposed_cut_inner"},
	{"stair", "exposed", "_outer", "cut_outer"},
	{"stair", "weathered", "_outer", "exposed_cut_outer"},
	{"stair", "oxidized", "_outer", "weathered_cut_outer"},
	{"stair", "oxidized", "_inner", "weathered_cut_inner"},
	{"slab", "exposed", "","cut"},
	{"slab", "oxidized", "","weathered_cut"},
	{"slab", "weathered", "","exposed_cut"},
	{"slab", "exposed", "_top","cut_top"},
	{"slab", "oxidized", "_top", "weathered_cut_top"},
	{"slab", "weathered", "_top","exposed_cut_top"},
	{"slab", "exposed", "_double","cut_double"},
	{"slab", "oxidized", "_double","weathered_cut_double"},
	{"slab", "weathered", "_double","exposed_cut_double"},
	{"stair", "exposed", "","cut"},
	{"stair", "oxidized", "", "weathered_cut"},
	{"stair", "weathered", "", "exposed_cut"},
}]]

local block_oxidation = {
	{ "", "_exposed" },
	{ "_cut", "_exposed_cut" },
	{ "_exposed", "_weathered" },
	{ "_exposed_cut", "_weathered_cut" },
	{ "_weathered", "_oxidized" },
	{ "_weathered_cut", "_oxidized_cut" }
}

local stair_oxidation = {
	{ "slab", "cut", "exposed_cut" },
	{ "slab", "exposed_cut", "weathered_cut" },
	{ "slab", "weathered_cut", "oxidized_cut" },
	{ "slab", "cut_top", "exposed_cut_top" },
	{ "slab", "exposed_cut_top", "weathered_cut_top" },
	{ "slab", "weathered_cut_top", "oxidized_cut_double" },
	{ "slab", "cut_double", "exposed_cut_double" },
	{ "slab", "exposed_cut_double", "weathered_cut_double" },
	{ "slab", "weathered_cut_double", "oxidized_cut_double" },
	{ "stair", "cut", "exposed_cut" },
	{ "stair", "exposed_cut", "weathered_cut" },
	{ "stair", "weathered_cut", "oxidized_cut" },
	{ "stair", "cut_inner", "exposed_cut_inner" },
	{ "stair", "exposed_cut_inner", "weathered_cut_inner" },
	{ "stair", "weathered_cut_inner", "oxidized_cut_inner" },
	{ "stair", "cut_outer", "exposed_cut_outer" },
	{ "stair", "exposed_cut_outer", "weathered_cut_outer" },
	{ "stair", "weathered_cut_outer", "oxidized_cut_outer" }
}

for _, b in pairs(block_oxidation) do
	register_oxidation_abm("Copper oxidation", "mcl_copper:block" .. b[1], "mcl_copper:block" .. b[2])
end

for _, s in pairs(stair_oxidation) do
	register_oxidation_abm("Copper oxidation", "mcl_stairs:" .. s[1] .. "_copper_" .. s[2], "mcl_stairs:" .. s[1] .. "_copper_" .. s[3])
	-- TODO: Make stairs and slabs be waxable / scrapable. Place the Node overrides here, just like they are on the copper nodes, and it will work properly. May need to update mcl_honey to call the waxing function for stairs and slabs.
end

