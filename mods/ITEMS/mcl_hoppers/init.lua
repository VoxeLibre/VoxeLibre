local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_hoppers", false)
local function mcl_log(message)
	if LOGGING_ON then
		mcl_util.mcl_log(message, "[Hoppers]", true)
	end
end

mcl_hoppers = {}

--[[ BEGIN OF NODE DEFINITIONS ]]

local mcl_hoppers_formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,8.175]",

	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Hopper"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.875, 0.75, 5, 1),
	"list[context;main;2.875,0.75;5,1;]",

	"label[0.375,2.45;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 2.85, 9, 3),
	"list[current_player;main;0.375,2.85;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 6.8, 9, 1),
	"list[current_player;main;0.375,6.8;9,1;]",

	"listring[context;main]",
	"listring[current_player;main]",
})

local function straight_hopper_act(pos, node, active_object_count, active_count_wider)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		--Pause if already recived item this tick
		return
	end
	timer:start(1.0)

	-- Move from internal inventory to dst first
	local dst_pos = vector.offset(pos, 0, -1, 0)
	local dst_node = minetest.get_node(dst_pos)
	local dst_name = dst_node.name
	local dst_def = minetest.registered_nodes[dst_name]

	if dst_def and dst_def._mcl_hopper_act then
		dst_def._mcl_hopper_act( dst_pos, dst_node, active_object_count, active_count_wider )
	end

	mcl_util.hopper_push(pos, dst_pos)
	local src_pos = vector.offset(pos, 0, 1, 0)
	mcl_util.hopper_pull_to_inventory(minetest.get_meta(pos):get_inventory(), "main", src_pos, pos)
end

local function bent_hopper_act(pos, node, active_object_count, active_object_count_wider)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		--Pause if already recived item this tick
		return
	end
	timer:start(1.0)

	-- Check if we are empty
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local empty = inv:is_empty("main")

	-- Determine to which side the hopper is facing, get nodes
	local face = minetest.get_node(pos).param2
	local dst_pos = {}
	if face == 0 then
		dst_pos = vector.offset(pos, -1, 0, 0)
	elseif face == 1 then
		dst_pos = vector.offset(pos, 0, 0, 1)
	elseif face == 2 then
		dst_pos = vector.offset(pos, 1, 0, 0)
	elseif face == 3 then
		dst_pos = vector.offset(pos, 0, 0, -1)
	end
	local dst_node = minetest.get_node(dst_pos)
	local dst_name = dst_node.name
	local dst_def = minetest.registered_nodes[dst_name]
	if dst_def and dst_def._mcl_hopper_act then
		dst_def._mcl_hopper_act( dst_pos, dst_node, active_object_count, active_object_count_wider )
	end
	if not empty then
		mcl_util.hopper_push(pos, dst_pos)
	end

	local src_pos = vector.offset(pos, 0, 1, 0)
	mcl_util.hopper_pull_to_inventory(inv, "main", src_pos, pos)
end

--[[
  Returns true if an item was pushed to the minecart
]]
local function hopper_push_to_mc(mc_ent, dest_pos)
	if not mcl_util.metadata_last_act(minetest.get_meta(dest_pos), "hopper_push_timer", 1) then return false end

	local dest_inv = mcl_entity_invs.load_inv(mc_ent, mc_ent._inv_size)
	if not dest_inv then
		mcl_log("No inv")
		return false
	end
	mc_ent._inv = dest_inv

	local meta = minetest.get_meta(dest_pos)
	local inv = meta:get_inventory()
	if not inv then
		mcl_log("No dest inv")
		return
	end

	mcl_log("inv. size: " .. mc_ent._inv_size)
	for i = 1, mc_ent._inv_size, 1 do
		local stack = inv:get_stack("main", i)

		mcl_log("i: " .. tostring(i))
		mcl_log("Name: [" .. tostring(stack:get_name()) .. "]")
		mcl_log("Count: " .. tostring(stack:get_count()))
		mcl_log("stack max: " .. tostring(stack:get_stack_max()))

		if not stack:get_name() or stack:get_name() ~= "" then
			if dest_inv:room_for_item("main", stack:peek_item()) then
				mcl_log("Room so unload")
				dest_inv:add_item("main", stack:take_item())
				inv:set_stack("main", i, stack)
				mcl_entity_invs.save_inv(mc_ent)

				-- Take one item and stop until next time
				return
			else
				mcl_log("no Room")
			end

		else
			mcl_log("nothing there")
		end
	end
end
--[[
  Returns true if an item was pulled from the minecart
]]
local function hopper_pull_from_mc(mc_ent, dest_pos)
	if not mcl_util.metadata_last_act(minetest.get_meta(dest_pos), "hopper_pull_timer", 1) then return false end

	local inv = mcl_entity_invs.load_inv(mc_ent, mc_ent._inv_size)
	if not inv then
		mcl_log("No inv")
		return false
	end
	mc_ent._inv = inv

	local dest_meta = minetest.get_meta(dest_pos)
	local dest_inv = dest_meta:get_inventory()
	if not dest_inv then
		mcl_log("No dest inv")
		return false
	end

	mcl_log("inv. size: " .. mc_ent._inv_size)
	for i = 1, mc_ent._inv_size, 1 do
		local stack = inv:get_stack("main", i)

		mcl_log("i: " .. tostring(i))
		mcl_log("Name: [" .. tostring(stack:get_name()) .. "]")
		mcl_log("Count: " .. tostring(stack:get_count()))
		mcl_log("stack max: " .. tostring(stack:get_stack_max()))

		if not stack:get_name() or stack:get_name() ~= "" then
			if dest_inv:room_for_item("main", stack:peek_item()) then
				mcl_log("Room so unload")
				dest_inv:add_item("main", stack:take_item())
				inv:set_stack("main", i, stack)
				mcl_entity_invs.save_inv(mc_ent)

				-- Take one item and stop until next time, report that we took something
				return true
			else
				mcl_log("no Room")
			end
		end
	end
end
mcl_hoppers.pull_from_minecart = hopper_pull_from_mc


-- Downwards hopper (base definition)

---@type node_definition
local def_hopper = {
	inventory_image = "mcl_hoppers_item.png",
	wield_image = "mcl_hoppers_item.png",
	groups = { pickaxey = 1, container = 2, deco_block = 1, hopper = 1 },
	drawtype = "nodebox",
	paramtype = "light",
	-- FIXME: mcl_hoppers_hopper_inside.png is unused by hoppers.
	tiles = {
		"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{ -0.5, 0.0, 0.4, 0.5, 0.5, 0.5 },
			{ 0.4, 0.0, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, -0.4, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, 0.5, 0.5, -0.4 },
			--funnel base
			{ -0.5, 0.0, -0.5, 0.5, 0.1, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.1, -0.3, -0.1, 0.1, -0.5, 0.1 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{ -0.5, 0.0, -0.5, 0.5, 0.5, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.1, -0.3, -0.1, 0.1, -0.5, 0.1 },
		},
	},
	is_ground_content = false,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = vector.offset(pos, math.random(0, 10) / 10 - 0.5, 0, math.random(0, 10) / 10 - 0.5)
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	_mcl_minecarts_on_enter_below = function(pos, cart, next_dir)
		-- Hopper is below minecart

		-- Only pull to containers
		if cart and cart.groups and (cart.groups.container or 0) ~= 0 then
			cart:add_node_watch(pos)
			hopper_pull_from_mc(cart, pos)
		end
	end,
	_mcl_minecarts_on_enter_above = function(pos, cart, next_dir)
		-- Hopper is above minecart

		-- Only push to containers
		if cart and cart.groups and (cart.groups.container or 0) ~= 0 then
			cart:add_node_watch(pos)
			hopper_push_to_mc(cart, pos)
		end
	end,
	_mcl_minecarts_on_leave_above = function(pos, cart, next_dir)
		if not cart then return end

		cart:remove_node_watch(pos)
	end,
	_mcl_minecarts_node_on_step = function(pos, cart, dtime, cartdata)
		if not cart then
			minetest.log("warning", "trying to process hopper-to-minecart movement without luaentity")
			return
		end

		local cart_pos = mcl_minecarts.get_cart_position(cartdata)
		if not cart_pos then return false end
		if vector.distance(cart_pos, pos) > 1.5 then
			cart:remove_node_watch(pos)
			return
		end
		if vector.direction(pos,cart_pos).y > 0 then
			-- The cart is above us, pull from minecart
			hopper_pull_from_mc(cart, pos)
		else
			hopper_push_to_mc(cart, pos)
		end

		return true
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_comparator_get_reading = function(pos)
		local inv = core.get_meta(pos):get_inventory()
		return mcl_comparators.read_inventory(inv, "main")
	end,

	_mcl_blast_resistance = 4.8,
	_mcl_hardness = 3,
}

-- Redstone variants (on/off) of downwards hopper.
-- Note a hopper is enabled when it is *not* supplied with redstone power and disabled when it is supplied with redstone power.

-- Enabled downwards hopper
local def_hopper_enabled = table.copy(def_hopper)
def_hopper_enabled.description = S("Hopper")
def_hopper_enabled._tt_help = S("5 inventory slots") ..
	"\n" .. S("Collects items from above, moves items to container below") .. "\n" ..
	S("Can be disabled with redstone power")
def_hopper_enabled._doc_items_longdesc = S("Hoppers are containers with 5 inventory slots. They collect dropped items from above, take items from a container above and attempt to put its items it into an adjacent container. Hoppers can go either downwards or sideways. Hoppers interact with chests, droppers, dispensers, shulker boxes, furnaces and hoppers.")
	.. "\n\n" ..

	S("Hoppers interact with containers the following way:") .. "\n" ..
	S("• Furnaces: Hoppers from above will put items into the source slot. Hoppers from below take items from the output slot. They also take items from the fuel slot when they can't be used as a fuel. Sideway hoppers that point to the furnace put items into the fuel slot")
	.. "\n" ..
	S("• Ender chests: No interaction.") .. "\n" ..
	S("• Other containers: Normal interaction.") .. "\n\n" ..

	S("Hoppers can be disabled when supplied with redstone power. Disabled hoppers don't move items.")
def_hopper_enabled._doc_items_usagehelp = S("To place a hopper vertically, place it on the floor or a ceiling. To place it sideways, place it at the side of a block. Use the hopper to access its inventory.")
def_hopper_enabled.on_place = function(itemstack, placer, pointed_thing)
	local upos = pointed_thing.under
	local apos = pointed_thing.above

	local uposnode = minetest.get_node(upos)
	local uposnodedef = minetest.registered_nodes[uposnode.name]
	if not uposnodedef then return itemstack end
	-- Use pointed node's on_rightclick function first, if present
	if placer and not placer:get_player_control().sneak then
		if uposnodedef and uposnodedef.on_rightclick then
			return uposnodedef.on_rightclick(pointed_thing.under, uposnode, placer, itemstack) or itemstack
		end
	end

	local x = upos.x - apos.x
	local z = upos.z - apos.z

	local fake_itemstack = ItemStack(itemstack)
	local param2
	if x == -1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 0
	elseif x == 1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 2
	elseif z == -1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 3
	elseif z == 1 then
		fake_itemstack:set_name("mcl_hoppers:hopper_side")
		param2 = 1
	end
	local itemstack, _ = minetest.item_place_node(fake_itemstack, placer, pointed_thing, param2)
	itemstack:set_name("mcl_hoppers:hopper")
	return itemstack
end
def_hopper_enabled.mesecons = {
	effector = {
		action_on = function(pos, node)
			minetest.swap_node(pos, {name = "mcl_hoppers:hopper_disabled", param2 = node.param2})
		end,
	},
}
def_hopper_enabled._mcl_hopper_act = straight_hopper_act

minetest.register_node("mcl_hoppers:hopper", def_hopper_enabled)

---Disabled downwards hopper
---@type node_definition
local def_hopper_disabled = table.copy(def_hopper)
def_hopper_disabled.description = S("Disabled Hopper")
def_hopper_disabled.inventory_image = nil
def_hopper_disabled._doc_items_create_entry = false
def_hopper_disabled.groups.not_in_creative_inventory = 1
def_hopper_disabled.drop = "mcl_hoppers:hopper"
def_hopper_disabled.mesecons = {
	effector = {
		action_off = function(pos, node)
			minetest.swap_node(pos, {name = "mcl_hoppers:hopper", param2 = node.param2})
		end,
	},
}

minetest.register_node("mcl_hoppers:hopper_disabled", def_hopper_disabled)



local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

---Sideways hopper (base definition)
---@type node_definition
local def_hopper_side = {
	_doc_items_create_entry = false,
	drop = "mcl_hoppers:hopper",
	groups = {pickaxey = 1, container = 2, not_in_creative_inventory = 1, hopper = 2},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {
		"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
		"mcl_hoppers_hopper_outside.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{ -0.5, 0.0, 0.4, 0.5, 0.5, 0.5 },
			{ 0.4, 0.0, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, -0.4, 0.5, 0.5 },
			{ -0.5, 0.0, -0.5, 0.5, 0.5, -0.4 },
			--funnel base
			{ -0.5, 0.0, -0.5, 0.5, 0.1, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.5, -0.3, -0.1, 0.1, -0.1, 0.1 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{ -0.5, 0.0, -0.5, 0.5, 0.5, 0.5 },
			--spout
			{ -0.3, -0.3, -0.3, 0.3, 0.0, 0.3 },
			{ -0.5, -0.3, -0.1, 0.1, -0.1, 0.1 },
		},
	},
	is_ground_content = false,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = vector.offset(pos, math.random(0, 10) / 10 - 0.5, 0, math.random(0, 10) / 10 - 0.5)
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from mcl_hoppers at " .. minetest.pos_to_string(pos))
	end,
	on_rotate = on_rotate,
	sounds = mcl_sounds.node_sound_metal_defaults(),

	_mcl_minecarts_on_enter_below = function(pos, cart, next_dir)
		-- Hopper is below minecart

		-- Only push to containers
		if cart and cart.groups and (cart.groups.container or 0) ~= 0 then
			cart:add_node_watch(pos)
			hopper_pull_from_mc(cart, pos)
		end
	end,
	_mcl_minecarts_on_leave_below = function(pos, cart, next_dir)
		if not cart then return end

		cart:remove_node_watch(pos)
	end,
	_mcl_minecarts_on_enter_side = function(pos, cart, next_dir, rail_pos)
		-- Hopper is to the side of the minecart

		if not cart then return end

		-- Only try to push to minecarts when the spout position is pointed at the rail
		local face = minetest.get_node(pos).param2
		local dst_pos = {}
		if face == 0 then
			dst_pos = vector.offset(pos, -1, 0, 0)
		elseif face == 1 then
			dst_pos = vector.offset(pos, 0, 0, 1)
		elseif face == 2 then
			dst_pos = vector.offset(pos, 1, 0, 0)
		elseif face == 3 then
			dst_pos = vector.offset(pos, 0, 0, -1)
		end
		if dst_pos ~= rail_pos then return end

		-- Only push to containers
		if cart.groups and (cart.groups.container or 0) ~= 0 then
			cart:add_node_watch(pos)
		end

		hopper_push_to_mc(cart, pos)
	end,
	_mcl_minecarts_on_leave_side = function(pos, cart, next_dir)
		if not cart then return end

		cart:remove_node_watch(pos)
	end,
	_mcl_minecarts_node_on_step = function(pos, cart, dtime, cartdata)
		if not cart then return end

		local cart_pos = mcl_minecarts.get_cart_position(cartdata)
		if not cart_pos then return false end
		if vector.distance(cart_pos, pos) > 1.5 then
			cart:remove_node_watch(pos)
			return false
		end

		if cart_pos.y == pos.y then
			hopper_push_to_mc(cart, pos)
		elseif cart_pos.y > pos.y then
			hopper_pull_from_mc(cart, pos)
		end

		return true
	end,

	_mcl_blast_resistance = 4.8,
	_mcl_hardness = 3,
}

---@type node_definition
local def_hopper_side_enabled = table.copy(def_hopper_side)
def_hopper_side_enabled.description = S("Side Hopper")
def_hopper_side_enabled.mesecons = {
	effector = {
		action_on = function(pos, node)
			minetest.swap_node(pos, {name = "mcl_hoppers:hopper_side_disabled", param2 = node.param2})
		end,
	},
}
def_hopper_side_enabled._mcl_hopper_act = bent_hopper_act
minetest.register_node("mcl_hoppers:hopper_side", def_hopper_side_enabled)

---@type node_definition
local def_hopper_side_disabled = table.copy(def_hopper_side)
def_hopper_side_disabled.description = S("Disabled Side Hopper")
def_hopper_side_disabled.mesecons = {
	effector = {
		action_off = function(pos, node)
			minetest.swap_node(pos, {name = "mcl_hoppers:hopper_side", param2 = node.param2})
		end,
	},
}
minetest.register_node("mcl_hoppers:hopper_side_disabled", def_hopper_side_disabled)

--[[ END OF NODE DEFINITIONS ]]


--[[ BEGIN OF ABM DEFINITONS ]]

minetest.register_abm({
	label = "Hoppers pull from minecart hoppers",
	nodenames = {"mcl_hoppers:hopper", "mcl_hoppers:hopper_side"},
	interval = 0.5,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		mcl_log("ABM for: " .. minetest.pos_to_string(pos))
		local objs = minetest.get_objects_inside_radius(pos, 3)

		if objs and #objs > 0 then
			for k, v in pairs(objs) do
				local entity = v:get_luaentity()
				if entity and entity.name then
					--mcl_log("Name of object near: " .. tostring(entity.name))

					if entity.name == "mcl_minecarts:hopper_minecart" or entity.name == "mcl_minecarts:chest_minecart" or entity.name == "mcl_boats:chest_boat" then
						local hm_pos = entity.object:get_pos()
						mcl_log("We have a minecart with inventory close: " .. minetest.pos_to_string(hm_pos))

						local ent_pos_y
						if entity.name == "mcl_minecarts:hopper_minecart" or entity.name == "mcl_minecarts:chest_minecart" then
							ent_pos_y = hm_pos.y
						elseif entity.name == "mcl_boats:chest_boat" then
							ent_pos_y = math.floor(hm_pos.y + 0.8)
						end

						local DIST_FROM_MC = 1.5
						--if ent_pos_y == pos.y - 1 then mcl_log("y is correct") end
						--if (hm_pos.x >= pos.x - DIST_FROM_MC and hm_pos.x <= pos.x + DIST_FROM_MC) then mcl_log("x is within range") end
						--if (hm_pos.z >= pos.z - DIST_FROM_MC and hm_pos.z <= pos.z + DIST_FROM_MC) then mcl_log("z is within range") end

						if (ent_pos_y == pos.y + 1)
							and (hm_pos.x >= pos.x - DIST_FROM_MC and hm_pos.x <= pos.x + DIST_FROM_MC)
							and (hm_pos.z >= pos.z - DIST_FROM_MC and hm_pos.z <= pos.z + DIST_FROM_MC) then
							mcl_log("Minecart close enough")
							hopper_pull_from_mc(entity, pos)
						elseif (ent_pos_y == pos.y - 1)
							and (hm_pos.x >= pos.x - DIST_FROM_MC and hm_pos.x <= pos.x + DIST_FROM_MC)
							and (hm_pos.z >= pos.z - DIST_FROM_MC and hm_pos.z <= pos.z + DIST_FROM_MC) then
							mcl_log("Minecart close enough")
							hopper_push_to_mc(entity, pos)
						end
					end
				else
					mcl_log("no entity")
				end
			end
		else
			mcl_log("objs missing")
		end
	end,
})

-- Make hoppers suck in dropped items
minetest.register_abm({
	label = "Hoppers suck in dropped items",
	nodenames = {"mcl_hoppers:hopper", "mcl_hoppers:hopper_side"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local abovenode = minetest.get_node(vector.offset(pos, 0, 1, 0))
		if not minetest.registered_items[abovenode.name] then return end
		-- Don't bother checking item enties if node above is a container (should save some CPU)
		if minetest.get_item_group(abovenode.name, "container") ~= 0 then
			return
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		for _, object in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" and
				not object:get_luaentity()._removed then
				if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
					-- Item must get sucked in when the item just TOUCHES the block above the hopper
					-- This is the reason for the Y calculation.
					-- Test: Items on farmland and slabs get sucked, but items on full blocks don't
					local posob = object:get_pos()
					local posob_miny = posob.y + object:get_properties().collisionbox[2]
					if math.abs(posob.x - pos.x) <= 0.5 and (posob_miny - pos.y < 1.5 and posob.y - pos.y >= 0.3) then
						inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
						object:get_luaentity().itemstring = ""
						object:remove()
					end
				end
			end
		end
	end,
})

-- Register push/pull for "straight" hopper
minetest.register_abm({
	label = "Hopper/container item exchange",
	nodenames = { "mcl_hoppers:hopper" },
	neighbors = { "group:container" },
	interval = 1.0,
	chance = 1,
	action = straight_hopper_act,
})

-- Register push/pull for "bent" hopper
minetest.register_abm({
	label = "Side-hopper/container item exchange",
	nodenames = { "mcl_hoppers:hopper_side" },
	neighbors = { "group:container" },
	interval = 1.0,
	chance = 1,
	action = bent_hopper_act,
})

minetest.register_craft({
	output = "mcl_hoppers:hopper",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_chests:chest", "mcl_core:iron_ingot"},
		{"", "mcl_core:iron_ingot", ""},
	},
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_hoppers:hopper", "nodes", "mcl_hoppers:hopper_side")
end

-- Legacy
minetest.register_alias("mcl_hoppers:hopper_item", "mcl_hoppers:hopper")

minetest.register_lbm({
	label = "Update hopper formspecs (0.60.0)",
	name = "mcl_hoppers:update_formspec_0_60_0",
	nodenames = {"group:hopper"},
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
	end,
})
