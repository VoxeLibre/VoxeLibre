local modname    = minetest.get_current_modname()
local S          = minetest.get_translator(modname)

for _, template_name in pairs(mcl_armor_trims.overlays) do
    minetest.register_craftitem(modname .. ":" .. template_name, {
        description      = S("Smithing Template '@1'", template_name),
        inventory_image  = template_name .. "_armor_trim_smithing_template.png",
    })
    
    minetest.register_craft({
        output = modname .. ":" .. template_name .. " 2",
        recipe = {
            {"mcl_core:diamond",modname .. ":" .. template_name,"mcl_core:diamond"},
            {"mcl_core:diamond","mcl_core:cobble","mcl_core:diamond"},
            {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
        }
    })
end

--temp craft recipies
minetest.register_craft({
    output = modname .. ":eye",
    recipe = {
        {"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})

minetest.register_craft({
    output = modname .. ":ward",
    recipe = {
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:apple_gold_enchanted","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})

minetest.register_craft({
    output = modname .. ":snout",
    recipe = {
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:goldblock","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})