-- Temporary node aliases for some legacy schematics in mcl_core.
-- Because these legacy schematics still use Minetest Game node names.
-- TODO: Update the offending schematics and delete this mod.

minetest.register_alias("default:jungletree", "mcl_core:jungletree")
minetest.register_alias("default:aspen_tree", "mcl_core:birchtree")
minetest.register_alias("default:pine_tree", "mcl_core:sprucetree")

minetest.register_alias("default:jungleleaves", "mcl_core:jungleleaves")
minetest.register_alias("default:aspen_leaves", "mcl_core:birchleaves")
minetest.register_alias("default:pine_needles", "mcl_core:spruceleaves")
