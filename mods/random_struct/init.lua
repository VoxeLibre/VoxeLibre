local init = os.clock()
random_struct ={}

random_struct.get_struct = function(file)
	local localfile = minetest.get_modpath("random_struct").."/build/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload ~= nil then
	    minetest.log("action", '[Random_Struct] error: could not open this struct "' .. localfile .. '"')
	    return nil
	end

   local allnode = file:read("*a")
   file:close()

    return allnode
end

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
