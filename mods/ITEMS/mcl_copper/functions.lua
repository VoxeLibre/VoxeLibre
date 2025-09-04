local stair_oxidization = {
	{ "cut", "exposed_cut" },
	{ "cut_inner", "exposed_cut_inner" },
	{ "cut_outer", "exposed_cut_outer" },
	{ "exposed_cut", "weathered_cut" },
	{ "exposed_cut_inner", "weathered_cut_inner" },
	{ "exposed_cut_outer", "weathered_cut_outer" },
	{ "weathered_cut", "oxidized_cut" },
	{ "weathered_cut_inner", "oxidized_cut_inner" },
	{ "weathered_cut_outer", "oxidized_cut_outer" }
}

local slab_oxidization = {
	{ "cut", "exposed_cut" },
	{ "cut_top", "exposed_cut_top" },
	{ "cut_double", "exposed_cut_double" },
	{ "exposed_cut", "weathered_cut" },
	{ "exposed_cut_top", "weathered_cut_top" },
	{ "exposed_cut_double", "weathered_cut_double" },
	{ "weathered_cut", "oxidized_cut" },
	{ "weathered_cut_top", "oxidized_cut_top" },
	{ "weathered_cut_double", "oxidized_cut_double" },
}

local def
local def_variant_oxidized
local def_variant_waxed
local def_variant_scraped

-- set up oxidized and waxed variants.
for i = 1, #stair_oxidization do
	-- stairs
	def = "mcl_stairs:stair_copper_" .. stair_oxidization[i][1]
	def_variant_oxidized = "mcl_stairs:stair_copper_" .. stair_oxidization[i][2]
	core.override_item(def, { _mcl_oxidized_variant = def_variant_oxidized })

	def_variant_waxed = "mcl_stairs:stair_waxed_copper_" .. stair_oxidization[i][1]
	core.override_item(def, { _mcl_waxed_variant = def_variant_waxed })

	-- slabs
	def = "mcl_stairs:slab_copper_" .. slab_oxidization[i][1]
	def_variant_oxidized = "mcl_stairs:slab_copper_" .. slab_oxidization[i][2]
	core.override_item(def, { _mcl_oxidized_variant = def_variant_oxidized })

	def_variant_waxed = "mcl_stairs:slab_waxed_copper_" .. slab_oxidization[i][1]
	core.override_item(def, { _mcl_waxed_variant = def_variant_waxed })
end

-- Set up scraped variants.
for i = 1, #stair_oxidization do
	-- does both stairs and slabs.
	if i > 3 then
		def = "mcl_stairs:stair_copper_" .. stair_oxidization[i][1]
		def_variant_scraped = "mcl_stairs:stair_copper_" .. stair_oxidization[i - 3][1]
		core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

		def = "mcl_stairs:slab_copper_" .. slab_oxidization[i][1]
		def_variant_scraped = "mcl_stairs:slab_copper_" .. slab_oxidization[i - 3][1]
		core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })
	end
	if i > 6 then
		def = "mcl_stairs:stair_copper_" .. stair_oxidization[i][2]
		def_variant_scraped = "mcl_stairs:stair_copper_" .. stair_oxidization[i][1]
		core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

		def = "mcl_stairs:slab_copper_" .. slab_oxidization[i][2]
		def_variant_scraped = "mcl_stairs:slab_copper_" .. slab_oxidization[i][1]
		core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })
	end
end

-- Set up scraped variants for waxed stairs.
local waxed_variants = {
	{ "waxed_copper_cut", "copper_cut" },
	{ "waxed_copper_exposed_cut", "copper_exposed_cut" },
	{ "waxed_copper_weathered_cut", "copper_weathered_cut" },
	{ "waxed_copper_oxidized_cut", "copper_oxidized_cut" },
}

for i = 1, #waxed_variants do
	-- stairs
	def = "mcl_stairs:stair_" .. waxed_variants[i][1]
	def_variant_scraped = "mcl_stairs:stair_" .. waxed_variants[i][2]
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

	def = "mcl_stairs:stair_" .. waxed_variants[i][1] .. "_inner"
	def_variant_scraped = "mcl_stairs:stair_" .. waxed_variants[i][2] .. "_inner"
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

	def = "mcl_stairs:stair_" .. waxed_variants[i][1] .. "_outer"
	def_variant_scraped = "mcl_stairs:stair_" .. waxed_variants[i][2] .. "_outer"
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

	-- slab
	def = "mcl_stairs:slab_" .. waxed_variants[i][1]
	def_variant_scraped = "mcl_stairs:slab_" .. waxed_variants[i][2]
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

	def = "mcl_stairs:slab_" .. waxed_variants[i][1] .. "_top"
	def_variant_scraped = "mcl_stairs:slab_" .. waxed_variants[i][2] .. "_top"
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

	def = "mcl_stairs:slab_" .. waxed_variants[i][1] .. "_double"
	def_variant_scraped = "mcl_stairs:slab_" .. waxed_variants[i][2] .. "_double"
	core.override_item(def, { _mcl_stripped_variant = def_variant_scraped })

end

-- Waxed Oxidized Slabs and Stairs
local oxidized_slabs = {
	"oxidized_cut",
	"oxidized_cut_double",
	"oxidized_cut_top"
}

for i = 1, #oxidized_slabs do
	def = "mcl_stairs:slab_copper_" .. oxidized_slabs[i]
	def_variant_waxed = "mcl_stairs:slab_waxed_copper_" .. oxidized_slabs[i]
	core.override_item(def, { _mcl_waxed_variant = def_variant_waxed })
end

local oxidized_stairs = {
	"oxidized_cut",
	"oxidized_cut_inner",
	"oxidized_cut_outer"
}

for i = 1, #oxidized_stairs do
	def = "mcl_stairs:stair_copper_" .. oxidized_stairs[i]
	def_variant_waxed = "mcl_stairs:stair_waxed_copper_" .. oxidized_stairs[i]
	core.override_item(def, { _mcl_waxed_variant = def_variant_waxed })
end
