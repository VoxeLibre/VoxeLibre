
-- Compatibility with deleted mobs

-- Magically turn horses into rabbits and cows. :D
mobs:alias_mob("mobs_mc:horse", "mobs_mc:rabbit")
mobs:alias_mob("mobs_mc:horse2", "mobs_mc:cow")
mobs:alias_mob("mobs_mc:horse3", "mobs_mc:cow")

minetest.register_alias("mobs_mc:horse", "mobs_mc:rabbit")
minetest.register_alias("mobs_mc:horse2", "mobs_mc:cow")
minetest.register_alias("mobs_mc:horse3", "mobs_mc:cow")
