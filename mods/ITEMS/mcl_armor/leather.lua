local S = minetest.get_translator(minetest.get_current_modname())
local colorize_value = 125

local str = string

local longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive.")
local usage = S("To equip it, put it on the corresponding armor slot in your inventory menu.")

local colors = {
	-- { ID, decription, wool, dye }
	{ "red", "Red", "mcl_dye:red", "#951d1d" },
	{ "blue", "Blue", "mcl_dye:blue", "#2a2c94" },
	{ "cyan", "Cyan", "mcl_dye:cyan", "#0d7d8e" },
	{ "grey", "Grey", "mcl_dye:dark_grey", "#363a3f" },
	{ "silver", "Light Grey", "mcl_dye:grey", "#818177" },
	{ "black", "Black", "mcl_dye:black", "#020307" },
	{ "yellow", "Yellow", "mcl_dye:yellow", "#f2b410" },
	{ "green", "Green", "mcl_dye:dark_green", "#495d20" },
	{ "magenta", "Magenta", "mcl_dye:magenta", "#ae2ea4" },
	{ "orange", "Orange", "mcl_dye:orange", "#e36501" },
	{ "purple", "Purple", "mcl_dye:violet", "#681ba1" },
	{ "brown", "Brown", "mcl_dye:brown", "#623b1a" },
	{ "pink", "Pink", "mcl_dye:pink", "#d66691" },
	{ "lime", "Lime", "mcl_dye:green", "#60ad13" },
	{ "light_blue", "Light Blue", "mcl_dye:lightblue", "#1f8eca" },
	{ "white", "White", "mcl_dye:white", "#d1d7d8" },
}

--local function get_color_rgb(color)
--    return tonumber(str.sub(first, 2, 3)), tonumber(str.sub(first, 4, 5)), tonumber(str.sub(first, 6, 7))
--end

local function calculate_color(first, last)
    --local first_r = tonumber(str.sub(first, 2, 3))
    --local first_g = tonumber(str.sub(first, 4, 5))
    return  tonumber(first)*tonumber(last)
end

local function get_on_armor_leather_use(itemname, raw)
    local function on_armor_leather_use(itemstack, user, pointed_thing)
        if not user or user:is_player() == false then
            return itemstack
        end
        -- Call on_rightclick if the pointed node defines it
        if pointed_thing.type == "node" then
            local node = minetest.get_node(pointed_thing.under)
            if minetest.get_item_group(node.name, "cauldron") ~= 0 then
                itemstack:set_name(raw)
                return itemstack
            end
            if user and not user:get_player_control().sneak then
                if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                    return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
                end
            end
        end

        local name, player_inv, armor_inv = armor:get_valid_player(user, "[on_armor_use]")
        if not name then
            return itemstack
        end

        local def = itemstack:get_definition()
        local slot
        if def.groups and def.groups.armor_head then
            slot = 2
        elseif def.groups and def.groups.armor_torso then
            slot = 3
        elseif def.groups and def.groups.armor_legs then
            slot = 4
        elseif def.groups and def.groups.armor_feet then
            slot = 5
        end

        if slot then
            local itemstack_single = ItemStack(itemstack)
            itemstack_single:set_count(1)
            local itemstack_slot = armor_inv:get_stack("armor", slot)
            if itemstack_slot:is_empty() then
                armor_inv:set_stack("armor", slot, itemstack_single)
                player_inv:set_stack("armor", slot, itemstack_single)
                armor:set_player_armor(user)
                armor:update_inventory(user)
                armor:play_equip_sound(itemstack_single, user)
                itemstack:take_item()
            elseif itemstack:get_count() <= 1 and not mcl_enchanting.has_enchantment(itemstack_slot, "curse_of_binding") then
                armor_inv:set_stack("armor", slot, itemstack_single)
                player_inv:set_stack("armor", slot, itemstack_single)
                armor:set_player_armor(user)
                armor:update_inventory(user)
                armor:play_equip_sound(itemstack_single, user)
                itemstack = ItemStack(itemstack_slot)
            end
        end

        return itemstack
    end
    return on_armor_leather_use
end

local itemcount = 0
for _,first_color in ipairs(colors) do
    local itemname = "mcl_armor:helmet_leather_"..first_color[1]
    minetest.register_tool(itemname, {
        description = S("Leather Cap "..first_color[2]),
        _doc_items_longdesc = longdesc,
        _doc_items_usagehelp = usage,
        inventory_image = "mcl_armor_inv_helmet_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        texture = "mcl_armor_helmet_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        groups = {armor_head=1, mcl_armor_points=1, mcl_armor_uses=56, enchantability=15}, --TODO: add not_in_creative_inventory=1
        _repair_material = "mcl_mobitems:leather",
        sounds = {
            _mcl_armor_equip = "mcl_armor_equip_leather",
            _mcl_armor_unequip = "mcl_armor_unequip_leather",
        },
        on_place = get_on_armor_leather_use(itemname, "mcl_armor:helmet_leather"),
        on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:helmet_leather"),
    })
    local itemname = "mcl_armor:chestplate_leather_"..first_color[1]
    minetest.register_tool(itemname, {
        description = S("Leather Tunic "..first_color[2]),
        _doc_items_longdesc = longdesc,
        _doc_items_usagehelp = usage,
        inventory_image = "mcl_armor_inv_chestplate_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        texture = "mcl_armor_chestplate_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        groups = {armor_torso=1, mcl_armor_points=3, mcl_armor_uses=81, enchantability=15 },
        _repair_material = "mcl_mobitems:leather",
        sounds = {
            _mcl_armor_equip = "mcl_armor_equip_leather",
            _mcl_armor_unequip = "mcl_armor_unequip_leather",
        },
        on_place = get_on_armor_leather_use(itemname, "mcl_armor:chestplate_leather"),
        on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:chestplate_leather"),
    })
    local itemname = "mcl_armor:leggings_leather_"..first_color[1]
    minetest.register_tool(itemname, {
        description = S("Leather Pants "..first_color[2]),
        _doc_items_longdesc = longdesc,
        _doc_items_usagehelp = usage,
        inventory_image = "mcl_armor_inv_leggings_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        texture = "mcl_armor_leggings_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        groups = {armor_legs=1, mcl_armor_points=2, mcl_armor_uses=76, enchantability=15 },
        _repair_material = "mcl_mobitems:leather",
        sounds = {
            _mcl_armor_equip = "mcl_armor_equip_leather",
            _mcl_armor_unequip = "mcl_armor_unequip_leather",
        },
        on_place = get_on_armor_leather_use(itemname, "mcl_armor:leggings_leather"),
        on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:leggings_leather"),
    })
    local itemname = "mcl_armor:boots_leather_"..first_color[1]
    minetest.register_tool(itemname, {
        description = S("Leather Boots "..first_color[2]),
        _doc_items_longdesc = longdesc,
        _doc_items_usagehelp = usage,
        inventory_image = "mcl_armor_inv_boots_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        texture = "mcl_armor_boots_leather.png^[colorize:"..first_color[4]..":"..colorize_value,
        groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=66, enchantability=15 },
        _repair_material = "mcl_mobitems:leather",
        sounds = {
            _mcl_armor_equip = "mcl_armor_equip_leather",
            _mcl_armor_unequip = "mcl_armor_unequip_leather",
        },
        on_place = get_on_armor_leather_use(itemname, "mcl_armor:boots_leather"),
        on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:boots_leather"),
    })
    minetest.register_craft({
        type = "shapeless",
        output = "mcl_armor:helmet_leather_"..first_color[1],
        recipe = {"mcl_armor:helmet_leather", first_color[1]},
    })
    minetest.register_craft({
        type = "shapeless",
        output = "mcl_armor:chestplate_leather_"..first_color[1],
        recipe = {"mcl_armor:chestplate_leather", first_color[3]},
    })
    minetest.register_craft({
        type = "shapeless",
        output = "mcl_armor:leggings_leather_"..first_color[1],
        recipe = {"mcl_armor:leggings_leather", first_color[3]},
    })
    minetest.register_craft({
        type = "shapeless",
        output = "mcl_armor:boots_leather_"..first_color[1],
        recipe = {"mcl_armor:boots_leather", first_color[3]},
    })
    itemcount = itemcount + 4
    for _,second_color in ipairs(colors) do
        minetest.register_tool("mcl_armor:helmet_leather_"..first_color[1].."_"..second_color[1], {
            description = S("Leather Cap "..first_color[2].." "..second_color[2]),
            _doc_items_longdesc = longdesc,
            _doc_items_usagehelp = usage,
            inventory_image = "mcl_armor_inv_helmet_leather.png",
            texture = "mcl_armor_helmet_leather.png",
            groups = {armor_head=1, mcl_armor_points=1, mcl_armor_uses=56, enchantability=15},
            _repair_material = "mcl_mobitems:leather",
            sounds = {
                _mcl_armor_equip = "mcl_armor_equip_leather",
                _mcl_armor_unequip = "mcl_armor_unequip_leather",
            },
            on_place = get_on_armor_leather_use(itemname, "mcl_armor:helmet_leather"),
            on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:helmet_leather"),
        })
        minetest.register_tool("mcl_armor:chestplate_leather_"..first_color[1].."_"..second_color[1], {
            description = S("Leather Tunic "..first_color[2].." "..second_color[2]),
            _doc_items_longdesc = longdesc,
            _doc_items_usagehelp = usage,
            inventory_image = "mcl_armor_inv_chestplate_leather.png",
            texture = "mcl_armor_chestplate_leather.png",
            groups = {armor_torso=1, mcl_armor_points=3, mcl_armor_uses=81, enchantability=15 },
            _repair_material = "mcl_mobitems:leather",
            sounds = {
                _mcl_armor_equip = "mcl_armor_equip_leather",
                _mcl_armor_unequip = "mcl_armor_unequip_leather",
            },
            on_place = get_on_armor_leather_use(itemname, "mcl_armor:chestplate_leather"),
            on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:chestplate_leather"),
        })
        minetest.register_tool("mcl_armor:leggings_leather_"..first_color[1].."_"..second_color[1], {
            description = S("Leather Pants "..first_color[2].." "..second_color[2]),
            _doc_items_longdesc = longdesc,
            _doc_items_usagehelp = usage,
            inventory_image = "mcl_armor_inv_leggings_leather.png",
            texture = "mcl_armor_leggings_leather.png",
            groups = {armor_legs=1, mcl_armor_points=2, mcl_armor_uses=76, enchantability=15 },
            _repair_material = "mcl_mobitems:leather",
            sounds = {
                _mcl_armor_equip = "mcl_armor_equip_leather",
                _mcl_armor_unequip = "mcl_armor_unequip_leather",
            },
            on_place = get_on_armor_leather_use(itemname, "mcl_armor:leggings_leather"),
            on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:leggings_leather"),
        })
        minetest.register_tool("mcl_armor:boots_leather_"..first_color[1].."_"..second_color[1], {
            description = S("Leather Boots "..first_color[2].." "..second_color[2]),
            _doc_items_longdesc = longdesc,
            _doc_items_usagehelp = usage,
            inventory_image = "mcl_armor_inv_boots_leather.png",
            texture = "mcl_armor_leggins_leather.png",
            groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=66, enchantability=15 },
            _repair_material = "mcl_mobitems:leather",
            sounds = {
                _mcl_armor_equip = "mcl_armor_equip_leather",
                _mcl_armor_unequip = "mcl_armor_unequip_leather",
            },
            on_place = get_on_armor_leather_use(itemname, "mcl_armor:boots_leather"),
            on_secondary_use = get_on_armor_leather_use(itemname, "mcl_armor:boots_leather"),
        })
        minetest.register_craft({
            type = "shapeless",
            output = "mcl_armor:helmet_leather_"..first_color[1].."_"..second_color[1],
            recipe = {"mcl_armor:helmet_leather_"..first_color[1], second_color[3]},
        })
        minetest.register_craft({
            type = "shapeless",
            output = "mcl_armor:chestplate_leather_"..first_color[1].."_"..second_color[1],
            recipe = {"mcl_armor:chestplate_leather_"..first_color[1], second_color[3]},
        })
        minetest.register_craft({
            type = "shapeless",
            output = "mcl_armor:leggings_leather_"..first_color[1].."_"..second_color[1],
            recipe = {"mcl_armor:leggings_leather_"..first_color[1], second_color[3]},
        })
        minetest.register_craft({
            type = "shapeless",
            output = "mcl_armor:boots_leather_"..first_color[1].."_"..second_color[1],
            recipe = {"mcl_armor:boots_leather_"..first_color[1], second_color[3]},
        })
        itemcount = itemcount + 4
    end
end

--minetest.register_on_joinplayer(function()
--    minetest.chat_send_all(itemcount)
--end)

minetest.log("info", "[mcl_armor] "..itemcount.." leather armor pieces have been registered")
