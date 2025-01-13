-- Aliases for backwards-compability

local materials = {
	"wood", "junglewood", "sprucewood", "acaciawood", "birchwood", "darkwood",
	"cobble", "brick_block", "sandstone", "redsandstone", "stonebrick",
	"quartzblock", "purpur_block", "nether_brick"
}

for m=1, #materials do
	local mat = materials[m]
	minetest.register_alias("stairs:slab_"..mat, "mcl_stairs:slab_"..mat)
	minetest.register_alias("stairs:stair_"..mat, "mcl_stairs:stair_"..mat)

	-- corner stairs
	minetest.register_alias("stairs:stair_"..mat.."_inner", "mcl_stairs:stair_"..mat.."_inner")
	minetest.register_alias("stairs:stair_"..mat.."_outer", "mcl_stairs:stair_"..mat.."_outer")
end

minetest.register_alias("stairs:slab_stone", "mcl_stairs:slab_stone")
minetest.register_alias("stairs:slab_stone_double", "mcl_stairs:slab_stone_double")

-- vl_trees transition
local woods = {
	["wood"] = "wood_oak",
	["junglewood"] = "wood_jungle",
	["sprucewood"] = "wood_spruce",
	["acaciawood"] = "wood_acacia",
	["birchwood"] = "wood_birch",
	["darkwood"] = "wood_dark_oak"
}

for old, new in pairs(woods) do
	minetest.register_alias("mcl_stairs:stair_"..old, "mcl_stairs:stair_"..new)
	minetest.register_alias("mcl_stairs:stair_"..old.."_inner", "mcl_stairs:stair_"..new.."_inner")
	minetest.register_alias("mcl_stairs:stair_"..old.."_outer", "mcl_stairs:stair_"..new.."_outer")
	minetest.register_alias("mcl_stairs:slab_"..old, "mcl_stairs:slab_"..new)
	minetest.register_alias("mcl_stairs:slab_"..old.."_top", "mcl_stairs:slab_"..new.."_top")
	minetest.register_alias("mcl_stairs:slab_"..old.."_double", "mcl_stairs:slab_"..new.."_double")
end
