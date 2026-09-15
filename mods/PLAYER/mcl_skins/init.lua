local mod_path=minetest.get_modpath(minetest.get_current_modname())
local path=minetest.get_modpath("mcl_skins").."/textures"
local files=minetest.get_dir_list(path,false)

local mcl_skins_enabled=minetest.settings:get_bool("mcl_enable_skin_customization",true)
if mcl_skins_enabled then
    dofile(mod_path.."/edit_skin.lua")
    dofile(mod_path.."/simple_skins.lua")
    dofile(mod_path.."/mesh_hand.lua")
end

for _,f in ipairs(files) do
    if f:match("%.png$") and not f:match("^mcl_skins_character_") and f~="character.png" then
        mcl_skins.register_simple_skin({texture=f,slim_arms=false})
    end
end
