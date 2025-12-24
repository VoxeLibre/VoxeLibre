-- See README.txt for licensing and other information.
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
local use_select_box = minetest.settings:get_bool("mcl_buckets_use_select_box", false)

-- Compatibility with old bucket mod
minetest.register_alias("bucket:bucket_empty", "mcl_buckets:bucket_empty")
minetest.register_alias("bucket:bucket_water", "mcl_buckets:bucket_water")
minetest.register_alias("bucket:bucket_lava", "mcl_buckets:bucket_lava")

local mod_doc = minetest.get_modpath("doc")
local mod_mcl_core = minetest.get_modpath("mcl_core")
--local mod_mclx_core = minetest.get_modpath("mclx_core")

-- Localize some functions for faster access
local vector = vector
local math = math
local string = string

local raycast = minetest.raycast
local get_node = minetest.get_node
local set_node = minetest.set_node
local add_node = minetest.add_node
local add_item = minetest.add_item

local registered_nodes = minetest.registered_nodes
local get_item_group = minetest.get_item_group
local is_creative_enabled = minetest.is_creative_enabled
local is_protected = minetest.is_protected
local record_protection_violation = minetest.record_protection_violation


minetest.register_craft({
	output = "mcl_buckets:bucket_empty 1",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"", "mcl_core:iron_ingot", ""},
	},
})


mcl_buckets = {
	liquids = {},
	buckets = {},
}

-- Sound helper functions for placing and taking liquids
local function sound_place(itemname, pos)
	local def = registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		minetest.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function sound_take(itemname, pos)
	local def = registered_nodes[itemname]
	if def and def.sounds and def.sounds.dug then
		minetest.sound_play(def.sounds.dug, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function place_liquid(pos, itemstring)
	sound_place(itemstring, pos)
	set_node(pos, {name=itemstring})
end

function mcl_buckets.give_bucket(new_bucket, itemstack, user)
	local inv = user:get_inventory()
	if is_creative_enabled(user:get_player_name()) then
		--TODO: is a full bucket added if inv doesn't contain one?
		return itemstack
	else
		if itemstack:get_count() == 1 then
			return new_bucket
		else
			if inv:room_for_item("main", new_bucket) then
				inv:add_item("main", new_bucket)
			else
				add_item(user:get_pos(), new_bucket)
			end
			itemstack:take_item()
			return itemstack
		end
	end
end
local give_bucket = mcl_buckets.give_bucket

local pointable_sources = {}

local function get_node_place(source_place, place_pos)
	local node_place
	if type(source_place) == "function" then
		node_place = source_place(place_pos)
	else
		node_place = source_place
	end
	return node_place
end

local function get_extra_check(check, pos, user)
	local result
	local take_bucket
	if check then
		result, take_bucket = check(pos, user)
		if result == nil then result = true end
		if take_bucket == nil then take_bucket = true end
	else
		result = true
		take_bucket = true
	end
	return result, take_bucket
end

function mcl_buckets.get_bucket_drop(itemstack, user, take_bucket)
	-- Handle bucket item and inventory stuff
	if take_bucket and not is_creative_enabled(user:get_player_name()) then
		-- Add empty bucket and put it into inventory, if possible.
		-- Drop empty bucket otherwise.
		local new_bucket = ItemStack("mcl_buckets:bucket_empty")
		if itemstack:get_count() == 1 then
			return new_bucket
		else
			local inv = user:get_inventory()
			if inv:room_for_item("main", new_bucket) then
				inv:add_item("main", new_bucket)
			else
				add_item(user:get_pos(), new_bucket)
			end
			itemstack:take_item()
			return itemstack
		end
	else
		return itemstack
	end
end
local get_bucket_drop = mcl_buckets.get_bucket_drop
---@param player core.Player
---@return any pointed_thing
function mcl_buckets.bucket_get_pointed_thing(player)
	local start = player:get_pos()
	start.y = start.y + player:get_properties().eye_height

	local look_dir = player:get_look_dir()
	local range, err = mcl_meshhand.get_player_hand_range(player)
	if err then
		core.log("error", string.format(
			"[mcl_buckets] Could not find range for player %q, "
			.. "using fallback: %q",
			player:get_player_name(), err))
		range = mcl_meshhand.get_default_hand_range(player)
	end
	assert(range)

	local _end = vector.add(start, vector.multiply(look_dir, range))

	local ray = raycast(start, _end, false, true)
	for pointed_thing in ray do
		local name = get_node(pointed_thing.under).name
		local def = registered_nodes[name]
		if not def or def.drawtype ~= "flowingliquid" then
			return pointed_thing
		end
	end
end
local bucket_get_pointed_thing = mcl_buckets.bucket_get_pointed_thing

local function on_place_bucket(itemstack, user, pointed_thing)
	if not use_select_box then
		pointed_thing = bucket_get_pointed_thing(user)
	end

	-- Must be pointing to node
	if not pointed_thing or pointed_thing.type ~= "node" then
		return
	end

	-- Call on_rightclick if the pointed node defines it
	local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if new_stack then
		return new_stack
	end

	local bucket_def = mcl_buckets.buckets[itemstack:get_name()]
	for _, pos in pairs({ pointed_thing.under, pointed_thing.above }) do
		local node = get_node(pos)
		local node_def = registered_nodes[node.name]

		if node_def and node_def.buildable_to or get_item_group(node.name, "cauldron") == 1 or minetest.get_node(pos).name == "mcl_mangrove:mangrove_roots" then
			local result, take_bucket = get_extra_check(bucket_def.extra_check, pos, user)
			if result then
				local node_place = get_node_place(bucket_def.source_place, pos)
				local player_name = user:get_player_name()

				-- Check protection
				if is_protected(pos, player_name) then
					record_protection_violation(pos, player_name)
					return itemstack
				end

				-- Place liquid
				place_liquid(pos, node_place)

				-- Update doc mod
				if mod_doc and doc.entry_exists("nodes", node_place) then
					doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
				end
			end
			return get_bucket_drop(itemstack, user, take_bucket)
		end
	end
	return itemstack
end

local function on_place_bucket_empty(itemstack, user, pointed_thing)
	if not use_select_box then
		pointed_thing = bucket_get_pointed_thing(user)
	end

	-- Must be pointing to node
	if not pointed_thing or pointed_thing.type ~= "node" then
		return itemstack
	end

	-- Call on_rightclick if the pointed node defines it
	local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if new_stack and new_stack ~= itemstack then
		return new_stack
	end

	local new_bucket
	local under = pointed_thing.under
	local node_name = get_node(under).name
	if pointable_sources[node_name] then
		if is_protected(under, user:get_player_name()) then
			record_protection_violation(under, user:get_player_name())
		end
		local liquid_def = mcl_buckets.liquids[node_name]
		if liquid_def then
			-- Fill bucket, but not in Creative Mode
			-- FIXME: remove this line
			--if not is_creative_enabled(user:get_player_name()) then
			if not false then
				new_bucket = ItemStack({name = liquid_def.bucketname})
				if liquid_def.on_take then
					liquid_def.on_take(user)
				end
			end
			add_node(under, {name="air"})
			sound_take(node_name, under)

			if mod_doc and doc.entry_exists("nodes", node_name) then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_name)
			end
			if new_bucket then
				return give_bucket(new_bucket, itemstack, user)
			end
		else
			minetest.log("error", string.format("[mcl_buckets] Node [%s] has invalid group [_mcl_bucket_pointable]!", node_name))
		end
		return itemstack
	else
		-- FIXME: replace this ugly code by cauldrons API
		if node_name == "mcl_cauldrons:cauldron_3" then
			-- Take water out of full cauldron
			set_node(under, {name="mcl_cauldrons:cauldron"})
			if not is_creative_enabled(user:get_player_name()) then
				new_bucket = ItemStack("mcl_buckets:bucket_water")
			end
			sound_take("mcl_core:water_source", under)
		elseif node_name == "mcl_cauldrons:cauldron_3r" then
			-- Take river water out of full cauldron
			set_node(under, {name="mcl_cauldrons:cauldron"})
			if not is_creative_enabled(user:get_player_name()) then
				new_bucket = ItemStack("mcl_buckets:bucket_river_water")
			end
			sound_take("mclx_core:river_water_source", under)
		elseif node_name == "mcl_cauldrons:cauldron_3_lava" then
			set_node(under, {name="mcl_cauldrons:cauldron"})
			if not is_creative_enabled(user:get_player_name()) then
				new_bucket = ItemStack("mcl_buckets:bucket_lava")
			end
			sound_take("mcl_core:lava_source", under)
		end
		if new_bucket then
			return give_bucket(new_bucket, itemstack, user)
		end
	end
	return itemstack
end

function mcl_buckets.register_liquid(def)
	for _,source in ipairs(def.source_take) do
		mcl_buckets.liquids[source] = {
			source_place = def.source_place,
			source_take = source,
			on_take = def.on_take,
			bucketname = def.bucketname,
		}
		pointable_sources[source] = true
		if type(def.source_place) == "string" then
			mcl_buckets.liquids[def.source_place] = mcl_buckets.liquids[source]
		end
	end

	mcl_buckets.buckets[def.bucketname] = def

	if def.bucketname == nil or def.bucketname == "" then
		error(string.format("[mcl_bucket] Invalid itemname then registering [%s]!", def.name))
	end

	minetest.register_craftitem(def.bucketname, {
		description = def.name,
		_doc_items_longdesc = def.longdesc,
		_doc_items_usagehelp = def.usagehelp,
		_tt_help = def.tt_help,
		inventory_image = def.inventory_image,
		stack_max = 1,
		groups = def.groups,
		liquids_pointable = use_select_box,
		on_place = on_place_bucket,
		on_secondary_use = on_place_bucket,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			local buildable = registered_nodes[dropnode.name].buildable_to or dropnode.name == "mcl_portals:portal"
			if not buildable then return stack end
			local result, take_bucket = get_extra_check(def.extra_check, droppos, nil)
			if result then -- Fail placement of liquid if result is false
				place_liquid(droppos, get_node_place(def.source_place, droppos))
			end
			if take_bucket then
				stack:set_name("mcl_buckets:bucket_empty")
			end
			return stack
		end,
	})
end

minetest.register_craftitem("mcl_buckets:bucket_empty", {
	description = S("Empty Bucket"),
	_doc_items_longdesc = S("A bucket can be used to collect and release liquids."),
	_doc_items_usagehelp = S("Punch a liquid source to collect it. You can then use the filled bucket to place the liquid somewhere else."),
	_tt_help = S("Collects liquids"),
	inventory_image = "mcl_buckets_bucket.png",
	stack_max = 16,
	liquids_pointable = use_select_box,
	on_place = on_place_bucket_empty,
	on_secondary_use = on_place_bucket_empty,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Fill empty bucket with liquid or drop bucket if no liquid
		local collect_liquid = false

		local liquiddef = mcl_buckets.liquids[dropnode.name]
		local new_bucket
		if liquiddef and liquiddef.bucketname and (dropnode.name  == liquiddef.source_take) then
			-- Fill bucket
			new_bucket = ItemStack({name = liquiddef.bucketname})
			sound_take(dropnode.name, droppos)
			collect_liquid = true
		end
		if collect_liquid then
			set_node(droppos, {name="air"})

			-- Fill bucket with liquid
			stack = new_bucket
		else
			-- No liquid found: Drop empty bucket
			add_item(droppos, stack)
			stack:take_item()
		end
		return stack
	end,
})

dofile(modpath.."/register.lua")
dofile(modpath.."/fishbuckets.lua")
