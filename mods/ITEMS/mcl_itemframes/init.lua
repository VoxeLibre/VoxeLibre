local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local S = minetest.get_translator(minetest.get_current_modname())

-- mcl_itemframes API
dofile(modpath .. "/item_frames_API.lua")

-- actual api initialization.
mcl_itemframes.create_base_definitions()

-- necessary to maintain compatibility amongst older versions.
mcl_itemframes.backwards_compatibility ()

-- test for the create custom frame
mcl_itemframes.create_custom_frame("false", "item_frame", false,
        "mcl_itemframes_item_frame.png", mcl_colors.WHITE, "Item Frame",
        "Can hold an item.")
mcl_itemframes.create_custom_frame("false", "glow_item_frame", true,
        "mcl_itemframes_glow_item_frame.png", mcl_colors.WHITE, "Glowing Item Frame",
        "Can hold an item and glows.")

-- Register the base frame's recipes.
-- was going to make it a specialized function, but minetest refuses to play nice.
minetest.register_craft({
    output = "mcl_itemframes:item_frame",
    recipe = {
        { "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
        { "mcl_core:stick", "mcl_mobitems:leather", "mcl_core:stick" },
        { "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
    }
})

minetest.register_craft({
    type = "shapeless",
    output = 'mcl_itemframes:glow_item_frame',
    recipe = { 'mcl_mobitems:glow_ink_sac', 'mcl_itemframes:item_frame' },
})

--[[ green frames just for testing
mcl_itemframes.create_custom_frame("false", "my_regular_frame", false,
        "mcl_itemframes_item_frame.png", mcl_colors.DARK_GREEN, "A Green frame",
        "My Green Frame")
mcl_itemframes.create_custom_frame("false", "my_glowing_frame", true,
        "mcl_itemframes_glow_item_frame.png", mcl_colors.DARK_GREEN, "A Green glowing frame",
        "My Green glowing Frame")

minetest.register_craft({
    output = "mcl_itemframes:my_regular_frame",
    recipe = {
        { "", "mcl_core:stick", "" },
        { "mcl_core:stick", "", "mcl_core:stick" },
        { "", "mcl_core:stick", "" },
    }
})

minetest.register_craft({
    type = "shapeless",
    output = "mcl_itemframes:my_glowing_frame",
    recipe = { "mcl_mobitems:glow_ink_sac", "mcl_itemframes:my_regular_frame" },
})
--]]
