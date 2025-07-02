local S = core.get_translator(core.get_current_modname())
local get_double_container_neighbor_pos = mcl_util.get_double_container_neighbor_pos

local chestusage = S("To access its inventory, rightclick it. When broken, the items will drop out.")

mcl_chests.register_chest("chest", {
	desc = S("Chest"),
	longdesc = S(
		"Chests are containers which provide 27 inventory slots. Chests can be turned into large chests with " ..
		"double the capacity by placing two chests next to each other."
	),
	usagehelp = chestusage,
	tt_help = S("27 inventory slots") .. "\n" .. S("Can be combined to a large chest"),
	tiles = {
		small = mcl_chests.tiles.chest_normal_small,
		double = mcl_chests.tiles.chest_normal_double,
		inv = {
			"default_chest_top.png", "mcl_chests_chest_bottom.png",
			"mcl_chests_chest_right.png", "mcl_chests_chest_left.png",
			"mcl_chests_chest_back.png", "default_chest_front.png"
		},
	},
	groups = {
		handy = 1,
		axey = 1,
		material_wood = 1,
		flammable = -1,
	},
	sounds = {mcl_sounds.node_sound_wood_defaults()},
	hardness = 2.5,
	hidden = false,
})

local traptiles = {
	small = mcl_chests.tiles.chest_trapped_small,
	double = mcl_chests.tiles.chest_trapped_double,
}

mcl_chests.register_chest("trapped_chest", {
	desc = S("Trapped Chest"),
	title = {
		small = S("Chest"),
		double = S("Large Chest")
	},
	longdesc = S(
		"A trapped chest is a container which provides 27 inventory slots. When it is opened, it sends a redstone " ..
		"signal to its adjacent blocks as long it stays open. Trapped chests can be turned into large trapped " ..
		"chests with double the capacity by placing two trapped chests next to each other."
	),
	usagehelp = chestusage,
	tt_help = S("27 inventory slots") .. "\n" ..
		S("Can be combined to a large chest") .. "\n" .. S("Emits a redstone signal when opened"),
	tiles = traptiles,
	groups = {
		handy = 1,
		axey = 1,
		material_wood = 1,
		flammable = -1,
		mesecon = 2,
	},
	sounds = {mcl_sounds.node_sound_wood_defaults()},
	hardness = 2.5,
	hidden = false,
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.pplate,
		},
	},
	on_rightclick = function(pos, node, clicker)
		core.swap_node(pos, {name = "mcl_chests:trapped_chest_on_small", param2 = node.param2})
		mcl_chests.find_or_create_entity(
			pos, "mcl_chests:trapped_chest_on_small", mcl_chests.tiles.chest_trapped_small,
			node.param2, false, "default_chest", "mcl_chests_chest", "chest"
		):reinitialize("mcl_chests:trapped_chest_on_small")
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
	on_rightclick_left = function(pos, node, clicker)
		local meta = core.get_meta(pos)
		meta:set_int("players", 1)

		core.swap_node(pos, {name = "mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mcl_chests.find_or_create_entity(
			pos, "mcl_chests:trapped_chest_on_left", mcl_chests.tiles.chest_trapped_double,
			node.param2, true, "default_chest", "mcl_chests_chest", "chest"
		):reinitialize("mcl_chests:trapped_chest_on_left")
		mesecon.receptor_on(pos, mesecon.rules.pplate)

		local pos_other = get_double_container_neighbor_pos(pos, node.param2, "left")
		core.swap_node(pos_other, {name = "mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon.receptor_on(pos_other, mesecon.rules.pplate)
	end,
	on_rightclick_right = function(pos, node, clicker)
		local pos_other = get_double_container_neighbor_pos(pos, node.param2, "right")

		core.swap_node(pos, {name = "mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon.receptor_on(pos, mesecon.rules.pplate)

		core.swap_node(pos_other, {name = "mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mcl_chests.find_or_create_entity(
			pos_other, "mcl_chests:trapped_chest_on_left", mcl_chests.tiles.chest_trapped_double,
			node.param2, true, "default_chest", "mcl_chests_chest", "chest"
		):reinitialize("mcl_chests:trapped_chest_on_left")
		mesecon.receptor_on(pos_other, mesecon.rules.pplate)
	end
})

mcl_chests.register_chest("trapped_chest_on", {
	title = {
		small = S("Chest"),
		double = S("Large Chest")
	},
	tiles = traptiles,
	groups = {
		handy = 1,
		axey = 1,
		material_wood = 1,
		flammable = -1,
		mesecon = 2,
	},
	sounds = {mcl_sounds.node_sound_wood_defaults()},
	hardness = 2.5,
	hidden = true,
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = mesecon.rules.pplate,
		},
	},
	drop = "trapped_chest",
	canonical_basename = "trapped_chest"
})

core.register_craft({
	output = "mcl_chests:chest",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "",           "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	},
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_chests:chest",
	burntime = 15,
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_chests:trapped_chest",
	burntime = 15,
})

-- Disable active/open trapped chests when loaded because nobody could have them open at loading time.
-- Fixes redstone weirdness.
core.register_lbm({
	label = "Disable active trapped chests",
	name = "mcl_chests:reset_trapped_chests",
	nodenames = {
		"mcl_chests:trapped_chest_on_small",
		"mcl_chests:trapped_chest_on_left",
		"mcl_chests:trapped_chest_on_right"
	},
	run_at_every_load = true,
	action = function(pos, node)
		core.log("action", "[mcl_chests] Disabled active trapped chest on load: " .. core.pos_to_string(pos))
		mcl_chests.chest_update_after_close(pos)
	end,
})

--Additional storage by Thomas Conway (c. 2025)
-- Iron Chest (36 slots - 4 rows)
mcl_chests.register_chest("iron_chest", {
    desc = S("Iron Chest"),
    longdesc = S(
        "Iron Chests are sturdy containers which provide 36 inventory slots. "..
        "They can be turned into large iron chests with double the capacity by "..
        "placing two iron chests next to each other."
    ),
    usagehelp = chestusage,
    tt_help = S("36 inventory slots") .. "\n" .. S("Can be combined to a large chest"),
    rows = 4, -- This gives us 9x4 = 36 slots
    tiles = {
        small = {
            "mcl_chests_iron_chest_top.png", "mcl_chests_iron_chest_bottom.png",
            "mcl_chests_iron_chest_right.png", "mcl_chests_iron_chest_left.png",
            "mcl_chests_iron_chest_back.png", "mcl_chests_iron_chest_front.png"
        },
        double = {
            "mcl_chests_iron_top_double.png", "mcl_chests_iron_bottom.png",
            "mcl_chests_iron_right_double.png", "mcl_chests_iron_left_double.png",
            "mcl_chests_iron_back_double.png", "mcl_chests_iron_front_double.png"
        },
        inv = {
            "mcl_chests_iron_top.png", "mcl_chests_iron_bottom.png",
            "mcl_chests_iron_right.png", "mcl_chests_iron_left.png",
            "mcl_chests_iron_back.png", "mcl_chests_iron_front.png"
        },
    },
    groups = {
        handy = 1,
        pickaxey = 1,
        material_metal = 1,
        deco_block = 1,
    },
    sounds = mcl_sounds.node_sound_metal_defaults(),
    hardness = 5.0,
    hidden = false,
})

-- Crafting recipe for iron chest
core.register_craft({
    output = "mcl_chests:iron_chest",
    recipe = {
        {"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
        {"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
        {"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
    },
})

-- Backpack item (portable chest) with unique inventory per item and texture swapping

local S = core.get_translator("mcl_chests")

-- Helper function to update backpack texture
local function update_backpack_texture(itemstack, is_open)
    local meta = itemstack:get_meta()
    local current_texture = is_open and "mcl_chests_backpack_open.png" or "mcl_chests_backpack_closed.png"

    -- Store the open state in metadata
    meta:set_string("is_open", is_open and "true" or "false")

    -- Update the item definition with new texture
    local item_def = core.registered_items[itemstack:get_name()]
    if item_def then
        -- We'll use a different approach - register separate items for open/closed states
        local new_name = is_open and "mcl_chests:backpack_open" or "mcl_chests:backpack"
        if itemstack:get_name() ~= new_name then
            -- Transfer all metadata to the new item
            local new_stack = ItemStack(new_name)
            new_stack:get_meta():from_table(meta:to_table())
            return new_stack
        end
    end

    return itemstack
end

-- Closed backpack (default state)
core.register_craftitem("mcl_chests:backpack", {
    description = S("Backpack"),
    _doc_items_longdesc = S("A portable storage item with 27 inventory slots. Right-click to open."),
    inventory_image = "mcl_chests_backpack_closed.png",
    stack_max = 1,  -- Important: prevent stacking to preserve inventory
    groups = {backpack = 1, not_in_creative_inventory = 0},

    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local meta = itemstack:get_meta()

        -- Generate unique ID for this backpack if it doesn't have one
        local backpack_id = meta:get_string("backpack_id")
        if backpack_id == "" then
            backpack_id = tostring(math.random(1000000, 9999999)) .. "_" .. tostring(core.get_us_time())
            meta:set_string("backpack_id", backpack_id)
        end

        -- Create/load detached inventory using unique ID
        local inv_name = "backpack_" .. backpack_id
        local inv = core.get_inventory({type = "detached", name = inv_name})

        if not inv then
            inv = core.create_detached_inventory(inv_name, {
                allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                    return count
                end,
                allow_put = function(inv, listname, index, stack, player)
                    if stack:get_name() == "mcl_chests:ender_backpack" or
                       stack:get_name() == "mcl_chests:ender_backpack_open" or
                       stack:get_name() == "mcl_chests:backpack" or
                       stack:get_name() == "mcl_chests:backpack_open" then
                        return 0  -- Prevent placing backpacks inside backpacks
                    end
                    return stack:get_count()
                end,
                allow_take = function(inv, listname, index, stack, player)
                    return stack:get_count()
                end,
            })
            inv:set_size("main", 9 * 3)  -- Same size as a chest

            -- Load saved inventory if exists
            local contents_str = meta:get_string("inventory")
            local contents = {}
            if contents_str ~= "" then
                contents = core.deserialize(contents_str) or {}
            end

            for i, stack in ipairs(contents) do
                inv:set_stack("main", i, ItemStack(stack))
            end
        end

        -- Remember which backpack is open using player meta
        local player_meta = user:get_meta()
        player_meta:set_string("mcl_chests:open_backpack_id", backpack_id)

        -- Show the formspec
        core.show_formspec(player_name, "mcl_chests:backpack", table.concat({
            "formspec_version[4]",
            "size[11.75,10.425]",
            "label[0.375,0.375;", core.formspec_escape(S("Backpack")), "]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
            "list[detached:" .. inv_name .. ";main;0.375,0.75;9,3;]",
            "label[0.375,4.7;", core.formspec_escape(S("Inventory")), "]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
            "list[current_player;main;0.375,5.1;9,3;9]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
            "list[current_player;main;0.375,9.05;9,1;]",
            "listring[detached:" .. inv_name .. ";main]",
            "listring[current_player;main]"
        }))

        -- Convert to open backpack texture
        local new_stack = update_backpack_texture(itemstack, true)
        return new_stack
    end,
})

-- Open backpack (visual state when inventory is open)
core.register_craftitem("mcl_chests:backpack_open", {
    description = S("Backpack (Open)"),
    _doc_items_longdesc = S("A portable storage item with 27 inventory slots. Currently open."),
    inventory_image = "mcl_chests_backpack_open.png",
    stack_max = 1,
    groups = {backpack = 1, not_in_creative_inventory = 1}, -- Hide from creative inventory

    -- Same functionality as closed backpack
    on_use = function(itemstack, user, pointed_thing)
        -- Redirect to closed backpack functionality
        local closed_stack = ItemStack("mcl_chests:backpack")
        closed_stack:get_meta():from_table(itemstack:get_meta():to_table())
        return core.registered_items["mcl_chests:backpack"].on_use(closed_stack, user, pointed_thing)
    end,
})

-- Save backpack inventory when formspec closes
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mcl_chests:backpack" then return end

    local player_name = player:get_player_name()
    local player_meta = player:get_meta()
    local backpack_id = player_meta:get_string("mcl_chests:open_backpack_id")
    if backpack_id == "" then return end

    -- Clear the open backpack reference
    player_meta:set_string("mcl_chests:open_backpack_id", "")

    -- Get the detached inventory
    local inv = core.get_inventory({type = "detached", name = "backpack_" .. backpack_id})
    if not inv then return end

    -- Save inventory contents
    local contents = {}
    for i = 1, inv:get_size("main") do
        table.insert(contents, inv:get_stack("main", i):to_string())
    end

    -- Find the backpack in player's inventory and update it
    local player_inv = player:get_inventory()
    local found = false

    -- Helper function to close backpack and save contents
    local function close_backpack(stack, slot_func)
        if (stack:get_name() == "mcl_chests:backpack" or stack:get_name() == "mcl_chests:backpack_open") and
           stack:get_meta():get_string("backpack_id") == backpack_id then

            local meta = stack:get_meta()
            meta:set_string("inventory", core.serialize(contents))

            -- Convert back to closed backpack
            local closed_stack = update_backpack_texture(stack, false)
            slot_func(closed_stack)
            return true
        end
        return false
    end

    -- Check wielded item
    local wielded = player:get_wielded_item()
    if close_backpack(wielded, function(new_stack) player:set_wielded_item(new_stack) end) then
        found = true
    end

    -- Check inventory slots
    if not found then
        for i = 1, player_inv:get_size("main") do
            local stack = player_inv:get_stack("main", i)
            if close_backpack(stack, function(new_stack) player_inv:set_stack("main", i, new_stack) end) then
                found = true
                break
            end
        end
    end

    -- Clean up detached inventory
    core.remove_detached_inventory("backpack_" .. backpack_id)
end)

-- Enhanced Ender Backpack with texture swapping
core.register_craftitem("mcl_chests:ender_backpack", {
    description = S("Ender Backpack"),
    _doc_items_longdesc = S("A mystical portable storage item with 27 inventory slots that connects to the void. Right-click to open."),
    inventory_image = "mcl_chests_backpack_closed.png^[colorize:#220055:120",
    stack_max = 1,
    groups = {ender_backpack = 1, not_in_creative_inventory = 0},

    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local meta = itemstack:get_meta()

        -- Create/get detached inventory
        local inv_name = "ender_backpack_" .. player_name
        local inv = core.get_inventory({type = "detached", name = inv_name})

        if not inv then
            inv = core.create_detached_inventory(inv_name, {
                allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                    return count
                end,
                allow_put = function(inv, listname, index, stack, player)
                    if stack:get_name() == "mcl_chests:ender_backpack" or
                       stack:get_name() == "mcl_chests:ender_backpack_open" or
                       stack:get_name() == "mcl_chests:backpack" or
                       stack:get_name() == "mcl_chests:backpack_open" then
                        return 0  -- Prevent placing backpacks inside backpacks
                    end
                    return stack:get_count()
                end,
                allow_take = function(inv, listname, index, stack, player)
                    return stack:get_count()
                end,
            })
            inv:set_size("main", 9 * 3)
        end

        -- Load saved inventory
        local contents_str = meta:get_string("inventory")
        if contents_str ~= "" then
            local contents = core.deserialize(contents_str) or {}
            for i, stack in ipairs(contents) do
                inv:set_stack("main", i, ItemStack(stack))
            end
        end

        -- Remember which ender backpack is open
        local player_meta = user:get_meta()
        player_meta:set_string("mcl_chests:open_ender_backpack", "true")

        -- Show formspec
        core.show_formspec(player_name, "mcl_chests:ender_backpack", table.concat({
            "formspec_version[4]",
            "size[11.75,10.425]",
            "label[0.375,0.375;", core.formspec_escape(S("Ender Backpack")), "]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
            "list[detached:" .. inv_name .. ";main;0.375,0.75;9,3;]",
            "label[0.375,4.7;", core.formspec_escape(S("Inventory")), "]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
            "list[current_player;main;0.375,5.1;9,3;9]",
            mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
            "list[current_player;main;0.375,9.05;9,1;]",
            "listring[detached:" .. inv_name .. ";main]",
            "listring[current_player;main]"
        }))

        -- Convert to open ender backpack
        local new_stack = ItemStack("mcl_chests:ender_backpack_open")
        new_stack:get_meta():from_table(meta:to_table())
        return new_stack
    end,
})

-- Open ender backpack
core.register_craftitem("mcl_chests:ender_backpack_open", {
    description = S("Ender Backpack (Open)"),
    _doc_items_longdesc = S("A mystical portable storage item currently open to the void."),
    inventory_image = "mcl_chests_backpack_open.png^[colorize:#220055:120",
    stack_max = 1,
    groups = {ender_backpack = 1, not_in_creative_inventory = 1}, -- Hide from creative inventory

    on_use = function(itemstack, user, pointed_thing)
        -- Redirect to closed ender backpack functionality
        local closed_stack = ItemStack("mcl_chests:ender_backpack")
        closed_stack:get_meta():from_table(itemstack:get_meta():to_table())
        return core.registered_items["mcl_chests:ender_backpack"].on_use(closed_stack, user, pointed_thing)
    end,
})

-- Save ender backpack inventory when formspec closes
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mcl_chests:ender_backpack" then return end

    local player_name = player:get_player_name()
    local player_meta = player:get_meta()

    -- Clear the open ender backpack reference
    player_meta:set_string("mcl_chests:open_ender_backpack", "")

    local inv = core.get_inventory({type = "detached", name = "ender_backpack_" .. player_name})

    if inv then
        local contents = {}
        for i = 1, inv:get_size("main") do
            table.insert(contents, inv:get_stack("main", i):to_string())
        end

        -- Helper function to close ender backpack
        local function close_ender_backpack(stack, slot_func)
            if stack:get_name() == "mcl_chests:ender_backpack" or stack:get_name() == "mcl_chests:ender_backpack_open" then
                local meta = stack:get_meta()
                meta:set_string("inventory", core.serialize(contents))

                -- Convert back to closed state
                local closed_stack = ItemStack("mcl_chests:ender_backpack")
                closed_stack:get_meta():from_table(meta:to_table())
                slot_func(closed_stack)
                return true
            end
            return false
        end

        -- Check wielded item
        local wielded = player:get_wielded_item()
        if close_ender_backpack(wielded, function(new_stack) player:set_wielded_item(new_stack) end) then
            -- Found and updated
        else
            -- Check inventory slots
            local player_inv = player:get_inventory()
            for i = 1, player_inv:get_size("main") do
                local stack = player_inv:get_stack("main", i)
                if close_ender_backpack(stack, function(new_stack) player_inv:set_stack("main", i, new_stack) end) then
                    break
                end
            end
        end
    end
end)

-- Crafting recipes
core.register_craft({
    output = "mcl_chests:backpack",
    recipe = {
        {"mcl_mobitems:leather", "mcl_mobitems:leather", "mcl_mobitems:leather"},
        {"mcl_mobitems:leather", "", "mcl_mobitems:leather"},
        {"mcl_mobitems:leather", "mcl_mobitems:leather", "mcl_mobitems:leather"},
    }
})

core.register_craft({
    output = "mcl_chests:ender_backpack",
    recipe = {
        {"mcl_mobitems:ender_pearl", "mcl_mobitems:ender_pearl", "mcl_mobitems:ender_pearl"},
        {"mcl_mobitems:ender_pearl", "mcl_mobitems:leather", "mcl_mobitems:ender_pearl"},
        {"mcl_mobitems:ender_pearl", "mcl_mobitems:ender_pearl", "mcl_mobitems:ender_pearl"},
    }
})

-- Fuel recipes
core.register_craft({
    type = "fuel",
    recipe = "mcl_chests:backpack",
    burntime = 15,
})

core.register_craft({
    type = "fuel",
    recipe = "mcl_chests:ender_backpack",
    burntime = 15,
})