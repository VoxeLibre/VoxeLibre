-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.

local LIQUID_MAX = 8  --The number of water levels when liquid_finite is enabled

minetest.register_alias("bucket", "bucket:bucket_empty")
minetest.register_alias("bucket_water", "bucket:bucket_water")
minetest.register_alias("bucket_lava", "bucket:bucket_lava")

minetest.register_craft({
	output = 'bucket:bucket_empty 1',
	recipe = {
		{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
		{'', 'mcl_core:iron_ingot', ''},
	}
})

bucket = {}
bucket.liquids = {}

-- Register a new liquid
--   source = name of the source node
--   flowing = name of the flowing node
--   itemname = name of the new bucket item (or nil if liquid is not takeable)
--   inventory_image = texture of the new bucket item (ignored if itemname == nil)
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name)
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

	if itemname ~= nil then
		minetest.register_craftitem(itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 16,
			liquids_pointable = true,
			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local node = minetest.get_node(pointed_thing.under)
				local nn = node.name
				-- Call on_rightclick if the pointed node defines it
				if user and not user:get_player_control().sneak then
					if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
						return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
					end
				end

				local place_liquid = function(pos, node, source, flowing, fullness)
					if math.floor(fullness/128) == 1 or (not minetest.setting_getbool("liquid_finite")) then
						minetest.add_node(pos, {name=source, param2=fullness})
						return
					elseif node.name == flowing then
						fullness = fullness + node.param2
					elseif node.name == source then
						fullness = LIQUID_MAX
					end

					if fullness >= LIQUID_MAX then
						minetest.add_node(pos, {name=source, param2=LIQUID_MAX})
					else
						minetest.add_node(pos, {name=flowing, param2=fullness})
					end
				end

				-- Check if pointing to a buildable node
				local fullness = tonumber(itemstack:get_metadata())
				if not fullness then fullness = LIQUID_MAX end
				local item = itemstack:get_name()

				if item == "bucket:bucket_water" and
						(nn == "mcl_cauldrons:cauldron" or
						nn == "mcl_cauldrons:cauldron_1" or
						nn == "mcl_cauldrons:cauldron_2") then
					-- Put water into cauldron
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_3"})
				elseif item == "bucket:bucket_water" and nn == "mcl_cauldrons:cauldron_3" then
					-- No-op (just empty the bucket)
				elseif minetest.registered_nodes[nn].buildable_to then
					-- buildable; replace the node
					local pns = user:get_player_name()
					if minetest.is_protected(pointed_thing.under, pns) then
						return itemstack
					end
					place_liquid(pointed_thing.under, node, source, flowing, fullness)
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced
					local abovenode = minetest.get_node(pointed_thing.above)
					if minetest.registered_nodes[abovenode.name].buildable_to then
						local pn = user:get_player_name()
						if minetest.is_protected(pointed_thing.above, pn) then
							return itemstack
						end
						place_liquid(pointed_thing.above, node, source, flowing, fullness)
					else
						-- do not remove the bucket with the liquid
						return
					end
				end

				-- Handle bucket item and inventory stuff
				if not minetest.setting_getbool("creative_mode") then
					-- Add empty bucket and put it into invntory, if possible.
					-- Drop empty bucket otherwise.
					local new_bucket = ItemStack("bucket:bucket_empty")
					if itemstack:get_count() == 1 then
						return new_bucket
					else
						local inv = user:get_inventory()
						if inv:room_for_item("main", new_bucket) then
							inv:add_item("main", new_bucket)
						else
							minetest.add_item(user:getpos(), new_bucket)
						end
						itemstack:take_item()
						return itemstack
					end
				else
					return
				end
			end
		})
	end
end

minetest.register_craftitem("bucket:bucket_empty", {
	description = "Empty Bucket",
	inventory_image = "bucket.png",
	stack_max = 16,
	liquids_pointable = true,
	on_place = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return
		end

		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		local nn = node.name
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
				return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Check if pointing to a liquid source
		liquiddef = bucket.liquids[nn]
		local new_bucket
		if liquiddef ~= nil and liquiddef.itemname ~= nil and (nn == liquiddef.source or
			(nn == liquiddef.flowing and minetest.setting_getbool("liquid_finite"))) then

			new_bucket = ItemStack({name = liquiddef.itemname, metadata = tostring(node.param2)})

			minetest.add_node(pointed_thing.under, {name="air"})

		elseif nn == "mcl_cauldrons:cauldron_3" then
			-- Take water out of full cauldron
			minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
			new_bucket = ItemStack("bucket:bucket_water")
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
					minetest.add_item(user:getpos(), new_bucket)
				end
				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
				return itemstack
			end
		end
	end,
})

bucket.register_liquid(
	"mcl_core:water_source",
	"mcl_core:water_flowing",
	"bucket:bucket_water",
	"bucket_water.png",
	"Water Bucket"
)

bucket.register_liquid(
	"mcl_core:lava_source",
	"mcl_core:lava_flowing",
	"bucket:bucket_lava",
	"bucket_lava.png",
	"Lava Bucket"
)

minetest.register_craft({
	type = "fuel",
	recipe = "bucket:bucket_lava",
	burntime = 1000,
	replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
})
