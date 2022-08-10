local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath.."/api.lua")

for _,w in pairs({"oak","dark_oak","jungle","spruce","acacia","birch"}) do
	mcl_wood.register_wood(w)
end

minetest.register_alias("default:acacia_tree", "mcl_core:acaciatree")
minetest.register_alias("default:acacia_leaves", "mcl_core:acacialeaves")

minetest.register_alias("mcl_core:birchtree","mcl_wood:tree_birch")
minetest.register_alias("mcl_core:darktree","mcl_wood:tree_dark_oak")
minetest.register_alias("mcl_core:acaciatree","mcl_wood:tree_acacia")
minetest.register_alias("mcl_core:jungletree","mcl_wood:tree_jungle")
minetest.register_alias("mcl_core:sprucetree","mcl_wood:tree_spruce")
minetest.register_alias("mcl_core:tree","mcl_wood:tree_oak")
minetest.register_alias("default:tree","mcl_wood:tree_oak")
minetest.register_alias("mcl_mangrove:mangrove_tree","mcl_wood:tree_mangrove")

minetest.register_alias("mcl_core:birchleaves","mcl_wood:leaves_birch")
minetest.register_alias("mcl_core:darkleaves","mcl_wood:leaves_dark_oak")
minetest.register_alias("mcl_core:acacialeaves","mcl_wood:leaves_acacia")
minetest.register_alias("mcl_core:jungleleaves","mcl_wood:leaves_jungle")
minetest.register_alias("mcl_core:spruceleaves","mcl_wood:leaves_spruce")
minetest.register_alias("mcl_core:leaves","mcl_wood:leaves_oak")
minetest.register_alias("default:leaves","mcl_wood:leaves_oak")
minetest.register_alias("mcl_mangrove:mangroveleaves","mcl_wood:leaves_mangrove")

minetest.register_alias("mcl_core:birchwood","mcl_wood:wood_birch")
minetest.register_alias("mcl_core:big_oakwood","mcl_wood:wood_dark_oak")
minetest.register_alias("mcl_core:acaciawood","mcl_wood:wood_acacia")
minetest.register_alias("mcl_core:junglewood","mcl_wood:wood_jungle")
minetest.register_alias("mcl_core:sprucewood","mcl_wood:wood_spruce")
minetest.register_alias("mcl_core:wood","mcl_wood:wood_oak")
minetest.register_alias("default:wood","mcl_wood:wood_oak")

minetest.register_alias("mcl_core:birchsapling","mcl_sapling:sapling_birch")
minetest.register_alias("mcl_core:big_oaksapling","mcl_sapling:sapling_dark_oak")
minetest.register_alias("mcl_core:acaciasapling","mcl_sapling:sapling_acacia")
minetest.register_alias("mcl_core:junglesapling","mcl_sapling:sapling_jungle")
minetest.register_alias("mcl_core:sprucesapling","mcl_sapling:sapling_spruce")
minetest.register_alias("mcl_core:sapling","mcl_sapling:sapling_oak")
minetest.register_alias("default:sapling","mcl_sapling:sapling_oak")
