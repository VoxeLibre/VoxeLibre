--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights 
to this software to the public domain worldwide. This software is
distributed without any warranty. 
]]

--Configuration variables, these are all explained in README.md
SPRINT_METHOD = 1
SPRINT_SPEED = 1.8
SPRINT_JUMP = 1.1
SPRINT_STAMINA = 20
SPRINT_TIMEOUT = 0.5 --Only used if SPRINT_METHOD = 0
SPRINT_HUDBARS_USED = false

if SPRINT_METHOD == 0 then
	dofile(minetest.get_modpath("mcl_sprint") .. "/wsprint.lua")
elseif SPRINT_METHOD == 1 then
	dofile(minetest.get_modpath("mcl_sprint") .. "/esprint.lua")
else
	minetest.log("error", "[mcl_sprint] SPRINT_METHOD is not set properly, using [E] to sprint.")
	dofile(minetest.get_modpath("mcl_sprint") .. "/esprint.lua")
end
