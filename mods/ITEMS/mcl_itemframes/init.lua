local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local S = minetest.get_translator(minetest.get_current_modname())

if 1 == 1 then
    minetest.log("action", "[mcl_itemframes] initialized.")
end

-- mcl_itemframes API
dofile(modpath .. "/item_frames_API.lua")

mcl_itemframes.create_base_frames()

-- Register the base item_frame's recipes.
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

-- for compatibility:
minetest.register_lbm({
    label = "Update legacy item frames",
    name = "mcl_itemframes:update_legacy_item_frames",
    nodenames = { "itemframes:frame" },
    action = function(pos, node)
        -- Swap legacy node, then respawn entity
        node.name = "mcl_itemframes:item_frame"
        local meta = minetest.get_meta(pos)
        local item = meta:get_string("item")
        minetest.swap_node(pos, node)
        if item ~= "" then
            local itemstack = ItemStack(minetest.deserialize(meta:get_string("itemdata")))
            local inv = meta:get_inventory()
            inv:set_size("main", 1)
            if not itemstack:is_empty() then
                inv:set_stack("main", 1, itemstack)
            end
        end
        mcl_itemframes.update_item_entity(pos, node)
    end,
})
minetest.register_alias("itemframes:frame", "mcl_itemframes:item_frame")
