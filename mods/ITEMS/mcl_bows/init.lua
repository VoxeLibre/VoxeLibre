dofile(minetest.get_modpath("mcl_bows") .. "/arrow.lua")
dofile(minetest.get_modpath("mcl_bows") .. "/bow.lua")

minetest.register_alias("mcl_throwing:bow", "mcl_bows:bow")
minetest.register_alias("mcl_throwing:arrow", "mcl_bows:arrow")
