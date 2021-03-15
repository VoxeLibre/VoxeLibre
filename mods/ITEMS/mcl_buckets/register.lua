local S = minetest.get_translator(minetest.get_current_modname())
local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_mclx_core = minetest.get_modpath("mclx_core")

if mod_mcl_core then
	-- Lava bucket
	mcl_buckets.register_liquid({
		source_place = function(pos)
			local dim = mcl_worlds.pos_to_dimension(pos)
			if dim == "nether" then
				return "mcl_nether:nether_lava_source"
			else
				return "mcl_core:lava_source"
			end
		end,
		source_take = {"mcl_core:lava_source", "mcl_nether:nether_lava_source"},
		itemname = "mcl_buckets:bucket_lava",
		inventory_image = "bucket_lava.png",
		name = S("Lava Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with hot lava, safely contained inside. Use with caution."),
		usagehelp = S("Get in a safe distance and place the bucket to empty it and create a lava source at this spot. Don't burn yourself!"),
		tt_help = S("Places a lava source")
	})

	-- Water bucket
	mcl_buckets.register_liquid({
		source_place = "mcl_core:water_source",
		source_take = {"mcl_core:water_source"},
		itemname = "mcl_buckets:bucket_water",
		inventory_image = "bucket_water.png",
		name = S("Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with water."),
		usagehelp = S("Place it to empty the bucket and create a water source."),
		tt_help = S("Places a water source"),
		extra_check = function(pos, placer)
			-- Check protection
			local placer_name = ""
			if placer ~= nil then
				placer_name = placer:get_player_name()
			end
			if placer and minetest.is_protected(pos, placer_name) then
				minetest.record_protection_violation(pos, placer_name)
				return false
			end
			local nn = minetest.get_node(pos).name
			-- Pour water into cauldron
			if minetest.get_item_group(nn, "cauldron") ~= 0 then
				-- Put water into cauldron
				if nn ~= "mcl_cauldrons:cauldron_3" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3"})
				end
				sound_place("mcl_core:water_source", pos)
				return false
			-- Evaporate water if used in Nether (except on cauldron)
			else
				local dim = mcl_worlds.pos_to_dimension(pos)
				if dim == "nether" then
					minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
					return false
				end
			end
		end,
		groups = { water_bucket = 1 },
	})
end

if mod_mclx_core then
	-- River water bucket
	mcl_buckets.register_liquid({
		source_place = "mclx_core:river_water_source",
		source_take = {"mclx_core:river_water_source"},
		itemname = "mcl_buckets:bucket_river_water",
		inventory_image = "bucket_river_water.png",
		name = S("River Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with river water."),
		usagehelp = S("Place it to empty the bucket and create a river water source."),
		tt_help = S("Places a river water source"),
		extra_check = function(pos, placer)
			-- Check protection
			local placer_name = ""
			if placer ~= nil then
				placer_name = placer:get_player_name()
			end
			if placer and minetest.is_protected(pos, placer_name) then
				minetest.record_protection_violation(pos, placer_name)
				return false
			end
			local nn = minetest.get_node(pos).name
			-- Pour into cauldron
			if minetest.get_item_group(nn, "cauldron") ~= 0 then
				-- Put water into cauldron
				if nn ~= "mcl_cauldrons:cauldron_3r" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3r"})
				end
				sound_place("mcl_core:water_source", pos)
				return false
			else
				-- Evaporate water if used in Nether (except on cauldron)
				local dim = mcl_worlds.pos_to_dimension(pos)
				if dim == "nether" then
					minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
					return false
				end
			end
		end,
		groups = { water_bucket = 1 },
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_buckets:bucket_lava",
	burntime = 1000,
	replacements = {{"mcl_buckets:bucket_lava", "mcl_buckets:bucket_empty"}},
})
