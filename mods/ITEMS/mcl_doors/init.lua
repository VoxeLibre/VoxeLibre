local init = os.clock()
mcl_doors = {}

local this = minetest.get_current_modname()
local path = minetest.get_modpath(this)

dofile(path.."/api_doors.lua") -- Doors API
dofile(path.."/api_trapdoors.lua") -- Trapdoors API
dofile(path.."/register.lua") -- Register builtin doors and trapdoors
dofile(path.."/crafting.lua") -- Additional crafting recipes and fuel
dofile(path.."/alias.lua") -- Legacy aliases

-- Debug info
local time_to_load= os.clock() - init
minetest.log("action", (string.format("[MOD] "..this.." loaded in %.4f s", time_to_load)))
