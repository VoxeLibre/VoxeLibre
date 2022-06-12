local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_tool("mcl_spyglass:spyglass",{
    description = S("Spyglass"),
    _doc_items_longdesc = S("A spyglass is an item that can be used for zooming in on specific locations."),
    inventory_image = "mcl_spyglass.png",
    stack_max = 1,
    _mcl_toollike_wield = true,
})

local function craft_spyglass(ingot)
    minetest.register_craft({
        output = "mcl_spyglass:spyglass",
        recipe = {
            {"xpanes:pane_natural_flat"},
            {ingot},
            {ingot},
        }
    })
end

if minetest.get_modpath("mcl_copper") then
    craft_spyglass("mcl_copper:copper_ingot")
else
    craft_spyglass("mcl_core:iron_ingot")
end

local spyglass_scope = {}

local function add_scope(player)
    local wielditem = player:get_wielded_item()
    if wielditem:get_name() == "mcl_spyglass:spyglass" then
        spyglass_scope[player] = player:hud_add({
            hud_elem_type = "image",
            position = {x = 0.5, y = 0.5},
            scale = {x = -100, y = -100},
            text = "mcl_spyglass_scope.png",
        })
        player:hud_set_flags({wielditem = false})
    end
end

local function remove_scope(player)
    if spyglass_scope[player] then
        player:hud_remove(spyglass_scope[player])
        spyglass_scope[player] = nil
        player:hud_set_flags({wielditem = true})
        player:set_fov(86.1)
    end
end

controls.register_on_press(function(player, key)
    if key ~= "RMB" then return end
    add_scope(player)
end)

controls.register_on_release(function(player, key, time)
    if key ~= "RMB" then return end
    remove_scope(player)
end)

controls.register_on_hold(function(player, key, time)
    if key ~= "RMB" then return end
    local wielditem = player:get_wielded_item()
    if wielditem:get_name() == "mcl_spyglass:spyglass" then
        player:set_fov(8, false, 0.1)
        if spyglass_scope[player] == nil then
            add_scope(player)
        end
    else 
        remove_scope(player)
    end
end)

minetest.register_on_dieplayer(function(player)
    remove_scope(player)
end)

minetest.register_on_leaveplayer(function(player)
    spyglass_scope[player] = nil
end)
