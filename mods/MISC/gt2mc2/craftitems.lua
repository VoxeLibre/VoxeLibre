-- mods/gt2mc/craftitems.lua

--======================
--default to mcl_core
--======================
--tools
minetest.register_alias("default:stick", "mcl_core:stick")
minetest.register_alias("default:pick_wood", "mcl_tools:pick_wood")
minetest.register_alias("default:pick_stone", "mcl_tools:pick_stone")
minetest.register_alias("default:pick_steel", "mcl_tools:pick_iron")
minetest.register_alias("default:pick_gold", "mcl_tools:pick_gold")
minetest.register_alias("default:pick_mese", "mcl_tools:pick_gold")
minetest.register_alias("default:pick_diamond", "mcl_tools:pick_diamond")
minetest.register_alias("default:shovel_wood", "mcl_tools:shovel_wood")
minetest.register_alias("default:shovel_stone", "mcl_tools:shovel_stone")
minetest.register_alias("default:shovel_steel", "mcl_tools:shovel_iron")
minetest.register_alias("default:shovel_gold", "mcl_tools:shovel_gold")
minetest.register_alias("default:shovel_mese", "mcl_tools:shovel_gold")
minetest.register_alias("default:shovel_diamond", "mcl_tools:shovel_diamond")
minetest.register_alias("default:axe_wood", "mcl_tools:axe_wood")
minetest.register_alias("default:axe_stone", "mcl_tools:axe_stone")
minetest.register_alias("default:axe_steel", "mcl_tools:axe_iron")
minetest.register_alias("default:axe_gold", "mcl_tools:axe_gold")
minetest.register_alias("default:axe_diamond", "mcl_tools:axe_diamond")
minetest.register_alias("default:sword_wood", "mcl_tools:sword_wood")
minetest.register_alias("default:sword_stone", "mcl_tools:sword_stone")
minetest.register_alias("default:sword_steel", "mcl_tools:sword_iron")
minetest.register_alias("default:sword_gold", "mcl_tools:sword_gold")
minetest.register_alias("default:sword_mese", "mcl_tools:sword_gold")
minetest.register_alias("default:sword_diamond", "mcl_tools:sword_diamond")
minetest.register_alias("default:shears", "mcl_tools:shears")
minetest.register_alias("mobs:shears", "mcl_tools:shears")
--farming tools
minetest.register_alias("farming:hoe_stone", "mcl_farming:hoe_stone")
minetest.register_alias("farming:hoe_iron", "mcl_farming:hoe_iron")
minetest.register_alias("farming:hoe_steel", "mcl_farming:hoe_iron")
minetest.register_alias("farming:hoe_diamond", "mcl_farming:hoe_diamond")
minetest.register_alias("farming:hoe_gold", "mcl_farming:hoe_gold")
minetest.register_alias("farming:hoe_mese", "mcl_farming:hoe_gold")
--moredefault misc
minetest.register_alias("default:paper", "mcl_core:paper")
minetest.register_alias("mcl_books:paper", "mcl_core:paper")
minetest.register_alias("default:book", "mcl_books:book")
minetest.register_alias("default:book_written", "mcl_books:written_book")
minetest.register_alias("mcl_books:book_written", "mcl_books:written_book")
minetest.register_alias("default:bowl", "mcl_core:bowl")
minetest.register_alias("mobs:bowl", "mcl_core:bowl")
--default ores, ingots
minetest.register_alias("default:coal_lump", "mcl_core:coal_lump")
minetest.register_alias("default:charcoal", "mcl_core:charcoal")
minetest.register_alias("default:iron_lump", "mcl_core:stone_with_iron")
minetest.register_alias("default:steel_lump", "mcl_core:stone_with_iron")
minetest.register_alias("default:gold_lump", "mcl_core:stone_with_gold")
minetest.register_alias("default:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("default:gold_ingot", "mcl_core:gold_ingot")
minetest.register_alias("mcl_core:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("default:clay_lump", "mcl_core:clay_lump")
minetest.register_alias("default:mese_crystal_fragment", "mcl_core:iron_ingot")
minetest.register_alias("default:obsidian_shard", "mcl_core:iron_ingot")
minetest.register_alias("default:stone_with_coal", "mcl_core:stone_with_coal")
minetest.register_alias("default:iron_nugget", "mcl_core:ironnugget")
minetest.register_alias("default:gold_nugget", "mcl_core:goldnugget")
minetest.register_alias("default:mese_crystal", "mcl_core:redstone")
minetest.register_alias("mcl_core:redstone", "mesecons:redstone")
minetest.register_alias("default:emerald_crystal", "mcl_core:emerald")
minetest.register_alias("mcl_nether:quartz_crystal", "mcl_nether:quartz")
minetest.register_alias("default:quartz_crystal_piece", "mcl_nether:quartz")
minetest.register_alias("default:diamond", "mcl_core:diamond")
minetest.register_alias("default:clay_brick", "mcl_core:brick")

--======================
--bonemeal
--======================
minetest.register_alias("bonemeal:bonemeal", "mcl_dye:white")
minetest.register_alias("bonemeal:bone", "mcl_mobitems:bone")

--======================
--armor
--======================
minetest.register_alias("3d_armor:helmet_wood", "3d_armor:helmet_leather")
minetest.register_alias("3d_armor:chestplate_wood", "3d_armor:chestplate_leather")
minetest.register_alias("3d_armor:leggings_wood", "3d_armor:leggings_leather")
minetest.register_alias("3d_armor:boots_wood", "3d_armor:boots_leather")

minetest.register_alias("3d_armor:helmet_bronze", "3d_armor:helmet_gold")
minetest.register_alias("3d_armor:chestplate_bronze", "3d_armor:chestplate_gold")
minetest.register_alias("3d_armor:leggings_bronze", "3d_armor:leggings_gold")
minetest.register_alias("3d_armor:boots_bronze", "3d_armor:boots_gold")

--======================
--Cake
--======================
minetest.register_alias("cake:cake", "mcl_cake:cake")

--======================
--carts
--======================
minetest.register_alias("carts:cart", "mcl_minecarts:minecart")

--======================
--clock and compass
--======================
minetest.register_alias("clock:clock", "mcl_clock:clock")
minetest.register_alias("compass:compass", "mcl_compass:compass")

--clocks compass
minetest.register_alias("clock:1", "mcl_clock:clock_1")
minetest.register_alias("clock:2", "mcl_clock:clock_2")
minetest.register_alias("clock:3", "mcl_clock:clock_3")
minetest.register_alias("clock:4", "mcl_clock:clock_4")
minetest.register_alias("clock:5", "mcl_clock:clock_5")
minetest.register_alias("clock:6", "mcl_clock:clock_6")
minetest.register_alias("clock:7", "mcl_clock:clock_7")
minetest.register_alias("clock:8", "mcl_clock:clock_8")
minetest.register_alias("clock:9", "mcl_clock:clock_9")
minetest.register_alias("clock:10", "mcl_clock:clock_10")
minetest.register_alias("clock:11", "mcl_clock:clock_11")
minetest.register_alias("clock:12", "mcl_clock:clock_12")
minetest.register_alias("clock:13", "mcl_clock:clock_13")
minetest.register_alias("clock:14", "mcl_clock:clock_14")
minetest.register_alias("clock:15", "mcl_clock:clock_15")
minetest.register_alias("clock:16", "mcl_clock:clock_16")
minetest.register_alias("clock:17", "mcl_clock:clock_17")
minetest.register_alias("clock:18", "mcl_clock:clock_18")
minetest.register_alias("clock:19", "mcl_clock:clock_19")
minetest.register_alias("clock:20", "mcl_clock:clock_20")
minetest.register_alias("clock:21", "mcl_clock:clock_21")
minetest.register_alias("clock:22", "mcl_clock:clock_22")
minetest.register_alias("clock:23", "mcl_clock:clock_23")
minetest.register_alias("clock:24", "mcl_clock:clock_24")
minetest.register_alias("clock:25", "mcl_clock:clock_25")
minetest.register_alias("clock:26", "mcl_clock:clock_26")
minetest.register_alias("clock:27", "mcl_clock:clock_27")
minetest.register_alias("clock:28", "mcl_clock:clock_28")
minetest.register_alias("clock:29", "mcl_clock:clock_29")
minetest.register_alias("clock:30", "mcl_clock:clock_30")
minetest.register_alias("clock:31", "mcl_clock:clock_31")
minetest.register_alias("clock:32", "mcl_clock:clock_32")
minetest.register_alias("clock:33", "mcl_clock:clock_33")
minetest.register_alias("mcl_clock:33", "mcl_clock:clock_33")
minetest.register_alias("clock:34", "mcl_clock:clock_34")
minetest.register_alias("clock:35", "mcl_clock:clock_35")
minetest.register_alias("clock:36", "mcl_clock:clock_36")
minetest.register_alias("clock:37", "mcl_clock:clock_37")
minetest.register_alias("clock:38", "mcl_clock:clock_38")
minetest.register_alias("clock:39", "mcl_clock:clock_39")
minetest.register_alias("clock:40", "mcl_clock:clock_40")

--this is template
--minetest.register_alias("clock:57", "mcl_clock:clock_57")
--
--minetest.register_alias("compass:0", "mcl_compass:0")
--


minetest.register_alias("compass:compass", "mcl_compass:compass")
minetest.register_alias("compass:0", "mcl_compass:0")
minetest.register_alias("compass:1", "mcl_compass:1")
minetest.register_alias("compass:2", "mcl_compass:2")
minetest.register_alias("compass:3", "mcl_compass:3")
minetest.register_alias("compass:4", "mcl_compass:4")
minetest.register_alias("compass:5", "mcl_compass:5")
minetest.register_alias("compass:6", "mcl_compass:6")
minetest.register_alias("compass:7", "mcl_compass:7")
minetest.register_alias("compass:8", "mcl_compass:8")
minetest.register_alias("compass:9", "mcl_compass:9")
minetest.register_alias("compass:10", "mcl_compass:10")
minetest.register_alias("compass:11", "mcl_compass:11")
minetest.register_alias("compass:12", "mcl_compass:12")
minetest.register_alias("compass:13", "mcl_compass:13")
minetest.register_alias("compass:14", "mcl_compass:14")
minetest.register_alias("compass:15", "mcl_compass:15")
minetest.register_alias("compass:16", "mcl_compass:16")
minetest.register_alias("compass:17", "mcl_compass:17")
minetest.register_alias("compass:18", "mcl_compass:18")
minetest.register_alias("compass:19", "mcl_compass:19")
minetest.register_alias("compass:20", "mcl_compass:20")
minetest.register_alias("compass:21", "mcl_compass:17")
minetest.register_alias("compass:22", "mcl_compass:17")
minetest.register_alias("compass:23", "mcl_compass:17")
minetest.register_alias("compass:24", "mcl_compass:17")
minetest.register_alias("compass:25", "mcl_compass:17")
minetest.register_alias("compass:26", "mcl_compass:17")
minetest.register_alias("compass:27", "mcl_compass:17")
minetest.register_alias("compass:28", "mcl_compass:17")
minetest.register_alias("compass:29", "mcl_compass:29")
minetest.register_alias("compass:30", "mcl_compass:30")
minetest.register_alias("compass:31", "mcl_compass:31")
minetest.register_alias("compass:32", "mcl_compass:32")
minetest.register_alias("compass:33", "mcl_compass:33")


--======================
--dye
--======================
minetest.register_alias("dye:white", "mcl_dye:white")
minetest.register_alias("dye:brown", "mcl_dye:brown")
minetest.register_alias("dye:dark_grey", "mcl_dye:dark_grey")
minetest.register_alias("dye:lightblue", "mcl_dye:lightblue")
minetest.register_alias("dye:grey", "mcl_dye:grey")
minetest.register_alias("dye:green", "mcl_dye:green")
minetest.register_alias("dye:magenta", "mcl_dye:magenta")
minetest.register_alias("dye:pink", "mcl_dye:pink")
minetest.register_alias("dye:cyan", "mcl_dye:cyan")
minetest.register_alias("dye:violet", "mcl_dye:violet")
minetest.register_alias("dye:orange", "mcl_dye:orange")
minetest.register_alias("dye:yellow", "mcl_dye:yellow")
minetest.register_alias("dye:red", "mcl_dye:red")
minetest.register_alias("dye:black", "mcl_dye:black")
minetest.register_alias("dye:blue", "mcl_dye:blue")
minetest.register_alias("dye:dark_green", "mcl_dye:dark_green")

--======================
--farorb
--======================
minetest.register_alias("farorb:farorb", "mcl_end:ender_eye")

--======================
--flintsteel
--======================
minetest.register_alias("default:flint_and_steel", "mcl_fire:flint_and_steel")
minetest.register_alias("default:flint", "mcl_fire:flint")
minetest.register_alias("mcl_fire:flint", "mcl_core:flint")

--======================
--fishing
--======================
minetest.register_alias("fishing:fish_raw", "mcl_fishing:fish_raw")
minetest.register_alias("fishing:fish_cooked", "mcl_fishing:fish_raw")
minetest.register_alias("fishing:sushi", "mcl_fishing:fish_raw")
minetest.register_alias("fishing:salmon_raw", "mcl_fishing:salmon_raw")
minetest.register_alias("fishing:salmon_cooked", "mcl_fishing:salmon_cooked")
minetest.register_alias("fishing:clownfish_raw", "mcl_fishing:clownfish_raw")
minetest.register_alias("fishing:bluewhite_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:exoticfish_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:carp_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:perch_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:carp_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:catfish_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:shark_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:pike_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:pike_cooked", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:shark_cooked", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:shark_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:shark_raw", "mcl_fishing:pufferfish_raw")
minetest.register_alias("fishing:pole_wood", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:pole_perfect", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:bait_worm", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:bait_corn", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:bait_bread", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:baitball", "mcl_fishing:fishing_rod")
minetest.register_alias("fishing:baitball_shark", "mcl_fishing:fishing_rod")

--======================
--GoldenApple
--======================
minetest.register_alias("golden_apple:golden_apple", "mcl_core:apple_gold")
minetest.register_alias("default:golden_apple", "mcl_core:apple_gold")

--======================
--MC2 jukebox
--======================
minetest.register_alias("jdukebox:box", "mcl_jukebox:jukebox")
minetest.register_alias("jdukebox:disc_1", "mcl_jukebox:record_1")
minetest.register_alias("jdukebox:disc_2", "mcl_jukebox:record_2")
minetest.register_alias("jdukebox:disc_3", "mcl_jukebox:record_3")
minetest.register_alias("jdukebox:disc_4", "mcl_jukebox:record_4")
minetest.register_alias("jdukebox:disc_5", "mcl_jukebox:record_5")
minetest.register_alias("jdukebox:disc_6", "mcl_jukebox:record_6")
minetest.register_alias("jdukebox:disc_7", "mcl_jukebox:record_7")
minetest.register_alias("jdukebox:disc_8", "mcl_jukebox:record_8")



--======================
--hoppers
--======================
minetest.register_alias("hoppers:hopper", "mcl_hoppers:hopper")
minetest.register_alias("hoppers:hopper_side", "mcl_hoppers:hopper_side")

--======================
--MC2 boats
--======================
minetest.register_alias("boats:boat", "mcl_boats:boat_spruce")
minetest.register_alias("boats:boat_oak", "mcl_boats:boat_oak")
minetest.register_alias("boats:boat_spruce", "mcl_boats:boat_spruce")
minetest.register_alias("boats:boat_birch", "mcl_boats:boat_birch")
minetest.register_alias("boats:boat_jungle", "mcl_boats:boat_jungle")
minetest.register_alias("boats:boat_acacia", "mcl_boats:boat_acacia")
minetest.register_alias("boats:boat_dark_oak", "mcl_boats:boat_dark_oak")

--======================
--screwdriver
--======================
minetest.register_alias("screwdriver:screwdriver", "mcl_core:bowl")


--======================
--tnt
--======================
minetest.register_alias("tnt:tnt", "mcl_tnt:tnt")
minetest.register_alias("tnt:gunpowder", "mcl_tnt:tnt")

--======================
--vessels
--======================
minetest.register_alias("vessels:shelf", "mcl_core:bowl")
minetest.register_alias("vessels:glass_bottle", "bucket:bucket_empty")
minetest.register_alias("vessels:drinking_glass", "bucket:bucket_empty")
minetest.register_alias("vessels:steel_bottle", "bucket:bucket_empty")
minetest.register_alias("vessels:glass_fragments", "bucket:bucket_empty")

--======================
--xdecor
--======================
minetest.register_alias("xdecor:hammer", "bucket:bucket_empty")

