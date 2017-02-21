--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights 
to this software to the public domain worldwide. This software is
distributed without any warranty. 
]]

--Configuration variables, these are all explained in README.md
mcl_sprint = {}

mcl_sprint.METHOD = 1
mcl_sprint.SPEED = 1.3
mcl_sprint.TIMEOUT = 0.5 --Only used if mcl_sprint.METHOD = 0

if mcl_sprint.METHOD == 0 then
	dofile(minetest.get_modpath("mcl_sprint") .. "/wsprint.lua")
elseif mcl_sprint.METHOD == 1 then
	dofile(minetest.get_modpath("mcl_sprint") .. "/esprint.lua")
else
	minetest.log("error", "[mcl_sprint] mcl_sprint.METHOD is not set properly, using [E] to sprint.")
	dofile(minetest.get_modpath("mcl_sprint") .. "/esprint.lua")
end
