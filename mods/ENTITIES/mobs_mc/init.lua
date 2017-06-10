--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local path = minetest.get_modpath("mobs_mc")

-- Animals
dofile(path .. "/rabbit.lua") -- ExeterDad
dofile(path .. "/chicken.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/cow.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/sheep.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/pig.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/squid.lua") -- Animation, sound and egg texture by daufinsyd

-- NPC
dofile(path .. "/villager.lua") -- KrupnoPavel

--Monsters
dofile(path .. "/creeper.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/skeleton.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/zombie.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/zombiepig.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/slimes.lua") -- Tomas J. Luis
dofile(path .. "/spider.lua") -- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
dofile(path .. "/enderman.lua") -- maikerumine
dofile(path .. "/ghast.lua") -- maikerumine

dofile(path .. "/blaze.lua")  -- Animation by daufinsyd

dofile(path .. "/old_mobs.lua")  -- Compability with old removed mobs. To be removed later

print ("[MOD] Mobs Redo 'MC' loaded")
