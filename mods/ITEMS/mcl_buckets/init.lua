local S = minetest.get_translator("mcl_buckets")
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.

minetest.register_alias("bucket:bucket_empty", "mcl_buckets:bucket_empty")
minetest.register_alias("bucket:bucket_water", "mcl_buckets:bucket_water")
minetest.register_alias("bucket:bucket_lava", "mcl_buckets:bucket_lava")

local mod_doc = minetest.get_modpath("doc")
local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_mclx_core = minetest.get_modpath("mclx_core")

if mod_mcl_core then
	minetest.register_craft({
		output = 'mcl_buckets:bucket_empty 1',
		recipe = {
			{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
			{'', 'mcl_core:iron_ingot', ''},
		}
	})
end

mcl_buckets = {}
mcl_buckets.liquids = {}

-- Sound helper functions for placing and taking liquids
local sound_place = function(itemname, pos)
	local def = minetest.registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		minetest.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local sound_take = function(itemname, pos)
	local def = minetest.registered_nodes[itemname]
	if def and def.sounds and def.sounds.dug then
		minetest.sound_play(def.sounds.dug, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local place_liquid = function(pos, itemstring)
	local fullness = minetest.registered_nodes[itemstring].liquid_range
	sound_place(itemstring, pos)
	minetest.add_node(pos, {name=itemstring, param2=fullness})
end

function mcl_buckets.register_liquid(def)
	for i=1, #def.source_take do
		mcl_buckets.liquids[def.source_take[i]] = {
			source_place = def.source_place,
			source_take = def.source_take[i],
			itemname = def.itemname,
		}
		if type(def.source_place) == "string" then
			mcl_buckets.liquids[def.source_place] = mcl_buckets.liquids[def.source_take[i]]
		end
	end

	if def.itemname ~= nil then
		minetest.register_craftitem(def.itemname, {
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

				local node = minetest.get_node(pointed_thing.under)
				local place_pos = pointed_thing.under
				local nn = node.name
				-- Call on_rightclick if the pointed node defines it
				if user and not user:get_player_control().sneak then
					if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
						return minetest.registered_nodes[nn].on_rightclick(place_pos, node, user, itemstack) or itemstack
					end
				end

				local node_place
				if type(def.source_place) == "function" then
					node_place = def.source_place(place_pos)
				else
					node_place = def.source_place
				end
				-- Check if pointing to a buildable node
				local item = itemstack:get_name()

				if extra_check and extra_check(place_pos, user) == false then
					-- Fail placement of liquid
				elseif minetest.registered_nodes[nn] and minetest.registered_nodes[nn].buildable_to then
					-- buildable; replace the node
					local pns = user:get_player_name()
					if minetest.is_protected(place_pos, pns) then
						minetest.record_protection_violation(place_pos, pns)
						return itemstack
					end
					place_liquid(place_pos, node_place)
					if mod_doc and doc.entry_exists("nodes", node_place) then
						doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
					end
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced
					local abovenode = minetest.get_node(pointed_thing.above)
					if minetest.registered_nodes[abovenode.name] and minetest.registered_nodes[abovenode.name].buildable_to then
						local pn = user:get_player_name()
						if minetest.is_protected(pointed_thing.above, pn) then
							minetest.record_protection_violation(pointed_thing.above, pn)
							return itemstack
						end
						place_liquid(pointed_thing.above, node_place)
						if mod_doc and doc.entry_exists("nodes", node_place) then
							doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
						end
					else
						-- do not remove the bucket with the liquid
						return
					end
				end

				-- Handle bucket item and inventory stuff
				if not minetest.is_creative_enabled(user:get_player_name()) then
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
							minetest.add_item(user:get_pos(), new_bucket)
						end
						itemstack:take_item()
						return itemstack
					end
				else
					return
				end
			end,
			_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
				local iname = stack:get_name()
				local buildable = minetest.registered_nodes[dropnode.name].buildable_to or dropnode.name == "mcl_portals:portal"

				if def.extra_check and def.extra_check(droppos, nil) == false then
					-- Fail placement of liquid
				elseif buildable then
					-- buildable; replace the node
					local node_place
					if type(def.source_place) == "function" then
						node_place = def.source_place(droppos)
					else
						node_place = def.source_place
					end
					place_liquid(droppos, node_place)
					stack:set_name("mcl_buckets:bucket_empty")
				end
				return stack
			end,
		})
	end
end

minetest.register_craftitem("mcl_buckets:bucket_empty", {
	description = S("Empty Bucket"),
	_doc_items_longdesc = S("A bucket can be used to collect and release liquids."),
	_doc_items_usagehelp = S("Punch a liquid source to collect it. You can then use the filled bucket to place the liquid somewhere else."),
	_tt_help = S("Collects liquids"),

	liquids_pointable = true,
	inventory_image = "bucket.png",
	stack_max = 16,
	on_place = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		local nn = node.name
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
				return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Can't steal liquids
		if minetest.is_protected(pointed_thing.above, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		-- Check if pointing to a liquid source
		local liquiddef = mcl_buckets.liquids[nn]
		local new_bucket
		if liquiddef ~= nil and liquiddef.itemname ~= nil and (nn == liquiddef.source_take) then

			-- Fill bucket, but not in Creative Mode
			if not minetest.is_creative_enabled(user:get_player_name()) then
				new_bucket = ItemStack({name = liquiddef.itemname})
			end

			minetest.add_node(pointed_thing.under, {name="air"})
			sound_take(nn, pointed_thing.under)

			if mod_doc and doc.entry_exists("nodes", nn) then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", nn)
			end

		elseif nn == "mcl_cauldrons:cauldron_3" then
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

		-- Add liquid bucket and put it into inventory, if possible.
		-- Drop new bucket otherwise.
		if new_bucket then
			if itemstack:get_count() == 1 then
				return new_bucket
			else
				local inv = user:get_inventory()
				if inv:room_for_item("main", new_bucket) then
					inv:add_item("main", new_bucket)
				else
					minetest.add_item(user:get_pos(), new_bucket)
				end
				if not minetest.is_creative_enabled(user:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Fill empty bucket with liquid or drop bucket if no liquid
		local collect_liquid = false

		local liquiddef = mcl_buckets.liquids[dropnode.name]
		local new_bucket
		if liquiddef ~= nil and liquiddef.itemname ~= nil and (dropnode.name  == liquiddef.source_take) then
			-- Fill bucket
			new_bucket = ItemStack({name = liquiddef.itemname})
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
