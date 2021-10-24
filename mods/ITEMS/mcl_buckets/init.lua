-- See README.txt for licensing and other information.
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

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
local add_node = minetest.add_node
local add_item = minetest.add_item


if mod_mcl_core then
	minetest.register_craft({
		output = "mcl_buckets:bucket_empty 1",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"", "mcl_core:iron_ingot", ""},
		},
	})
end

mcl_buckets = {}
mcl_buckets.liquids = {}

-- Sound helper functions for placing and taking liquids
local function sound_place(itemname, pos)
	local def = minetest.registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		minetest.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function sound_take(itemname, pos)
	local def = minetest.registered_nodes[itemname]
	if def and def.sounds and def.sounds.dug then
		minetest.sound_play(def.sounds.dug, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function place_liquid(pos, itemstring)
	local fullness = minetest.registered_nodes[itemstring].liquid_range
	sound_place(itemstring, pos)
	minetest.add_node(pos, {name=itemstring, param2=fullness})
end

local function give_bucket(new_bucket, itemstack, user)
	local inv = user:get_inventory()
	if minetest.is_creative_enabled(user:get_player_name()) then
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

local pointable_sources = {}

local function bucket_raycast(user)
	--local pos = user:get_pos()
	local pos = user:get_pos()
	--local pos = vector.add(user:get_pos(), user:get_bone_position("Head_Control"))
	pos.y = pos.y + user:get_properties().eye_height
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir, 5)
	local pos2 = vector.add(pos, look_dir)

	local ray = raycast(pos, pos2, false, true)
	if ray then
		for pointed_thing in ray do
			if pointed_thing and pointable_sources[get_node(pointed_thing.above).name] then
				--minetest.chat_send_all("found!")
				return {under=pointed_thing.under,above=pointed_thing.above}
			end
		end
	end
	return nil
end

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

local function get_bucket_drop(itemstack, user, take_bucket)
	-- Handle bucket item and inventory stuff
	if take_bucket and not minetest.is_creative_enabled(user:get_player_name()) then
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
		on_place = function(itemstack, user, pointed_thing)
			-- Must be pointing to node
			if pointed_thing.type ~= "node" then
				return
			end
			-- Call on_rightclick if the pointed node defines it
			local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
			if new_stack then
				return new_stack
			end

			local undernode = get_node(pointed_thing.under)
			local abovenode = get_node(pointed_thing.above)
			local buildable1 = minetest.registered_nodes[undernode.name] and minetest.registered_nodes[undernode.name].buildable_to
			local buildable2 = minetest.registered_nodes[abovenode.name] and minetest.registered_nodes[abovenode.name].buildable_to
			if not buildable1 and not buildable2 then return itemstack end --if both nodes aren't buildable_to, skip

			if buildable1 then
				local result, take_bucket = get_extra_check(def.extra_check, pointed_thing.under, user)
				if result then
					local node_place = get_node_place(def.source_place, pointed_thing.under)
					local pns = user:get_player_name()

					-- Check protection
					if minetest.is_protected(pointed_thing.under, pns) then
						minetest.record_protection_violation(pointed_thing.under, pns)
						return itemstack
					end

					-- Place liquid
					place_liquid(pointed_thing.under, node_place)

					-- Update doc mod
					if mod_doc and doc.entry_exists("nodes", node_place) then
						doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
					end
				end
				return get_bucket_drop(itemstack, user, take_bucket)
			elseif buildable2 then
				local result, take_bucket = get_extra_check(def.extra_check, pointed_thing.above, user)
				if result then
					local node_place = get_node_place(def.source_place, pointed_thing.above)
					local pns = user:get_player_name()

					-- Check protection
					if minetest.is_protected(pointed_thing.above, pns) then
						minetest.record_protection_violation(pointed_thing.above, pns)
						return itemstack
					end

					-- Place liquid
					place_liquid(pointed_thing.above, node_place)

					-- Update doc mod
					if mod_doc and doc.entry_exists("nodes", node_place) then
						doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
					end
				end
				return get_bucket_drop(itemstack, user, take_bucket)
			else
				return itemstack
			end
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			local buildable = minetest.registered_nodes[dropnode.name].buildable_to or dropnode.name == "mcl_portals:portal"
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
	--liquids_pointable = true,
	inventory_image = "bucket.png",
	stack_max = 16,
	on_place = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if new_stack then
			return new_stack
		end

		local node = minetest.get_node(pointed_thing.under)
		local nn = node.name

		local new_bucket
		local liquid_node = bucket_raycast(user)
		if liquid_node then
			if minetest.is_protected(liquid_node.above, user:get_player_name()) then
				minetest.record_protection_violation(liquid_node.above, user:get_player_name())
			end
			local liquid_name = get_node(liquid_node.above).name
			if liquid_name then
				local liquid_def = mcl_buckets.liquids[liquid_name]
				if liquid_def then
					--minetest.chat_send_all("test")
					-- Fill bucket, but not in Creative Mode
					-- FIXME: remove this line
					--if not minetest.is_creative_enabled(user:get_player_name()) then
					if not false then
						new_bucket = ItemStack({name = liquid_def.bucketname})
						if liquid_def.on_take then
							liquid_def.on_take(user)
						end
					end
					add_node(liquid_node.above, {name="air"})
					sound_take(nn, liquid_node.above)

					if mod_doc and doc.entry_exists("nodes", liquid_name) then
						doc.mark_entry_as_revealed(user:get_player_name(), "nodes", liquid_name)
					end
					if new_bucket then
						return give_bucket(new_bucket, itemstack, user)
					end
				else
					minetest.log("error", string.format("[mcl_buckets] Node [%s] has invalid group [_mcl_bucket_pointable]!", liquid_name))
				end
			end
			return itemstack
		else
			-- FIXME: replace this ugly code by cauldrons API
			if nn == "mcl_cauldrons:cauldron_3" then
				-- Take water out of full cauldron
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
				if not minetest.is_creative_enabled(user:get_player_name()) then
					new_bucket = ItemStack("mcl_buckets:bucket_water")
				end
				sound_take("mcl_core:water_source", pointed_thing.under)
			elseif nn == "mcl_cauldrons:cauldron_3r" then
				-- Take river water out of full cauldron
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
				if not minetest.is_creative_enabled(user:get_player_name()) then
					new_bucket = ItemStack("mcl_buckets:bucket_river_water")
				end
				sound_take("mclx_core:river_water_source", pointed_thing.under)
			end
			if new_bucket then
				return give_bucket(new_bucket, itemstack, user)
			end
        end
        return itemstack
	end,
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
			minetest.set_node(droppos, {name="air"})

			-- Fill bucket with liquid
			stack = new_bucket
		else
			-- No liquid found: Drop empty bucket
			minetest.add_item(droppos, stack)
			stack:take_item()
		end
		return stack
	end,
})

dofile(modpath.."/register.lua")
