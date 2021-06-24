local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/register/kill.lua")
dofile(modpath.."/register/setblock.lua")
dofile(modpath.."/register/seed.lua")
dofile(modpath.."/register/summon.lua")
dofile(modpath.."/register/say.lua")
dofile(modpath.."/register/list.lua")
dofile(modpath.."/register/sound.lua")

dofile(modpath.."/alias.lua")