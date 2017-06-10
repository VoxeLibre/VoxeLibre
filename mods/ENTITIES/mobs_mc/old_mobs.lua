
-- Compatibility with deleted mobs

-- Magically turn horses into rabbits and cows. :D
mobs:alias_mob("mobs_mc:horse", "mobs_mc:rabbit")
mobs:alias_mob("mobs_mc:horse2", "mobs_mc:cow")
mobs:alias_mob("mobs_mc:horse3", "mobs_mc:cow")

minetest.register_alias("mobs_mc:horse", "mobs_mc:rabbit")
minetest.register_alias("mobs_mc:horse2", "mobs_mc:cow")
minetest.register_alias("mobs_mc:horse3", "mobs_mc:cow")

-- Magically turn wolves into sheep. (How ironic!)
mobs:alias_mob("mobs_mc:wolf", "mobs_mc:sheep")
mobs:alias_mob("mobs_mc:dog", "mobs_mc:sheep")

minetest.register_alias("mobs_mc:wolf", "mobs_mc:sheep")

