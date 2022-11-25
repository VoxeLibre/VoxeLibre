local S = minetest.get_translator(minetest.get_current_modname())
local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_mclx_core = minetest.get_modpath("mclx_core")
local has_awards = minetest.get_modpath("awards")

local function sound_place(itemname, pos)
	local def = minetest.registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		minetest.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

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
		on_take = function(user)
			if has_awards and user and user:is_player() then
				awards.unlock(user:get_player_name(), "mcl:hotStuff")
			end
		end,
		extra_check = function(pos, placer)
			local nn = minetest.get_node(pos).name
			if minetest.get_item_group(nn, "cauldron") ~= 0 then
				if nn ~= "mcl_cauldrons:cauldron_3_lava" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3_lava"})
				end
				sound_place("mcl_core:lava_source", pos)
				return false, true
			end
		end,
		bucketname = "mcl_buckets:bucket_lava",
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
		bucketname = "mcl_buckets:bucket_water",
		inventory_image = "bucket_water.png",
		name = S("Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with water."),
		usagehelp = S("Place it to empty the bucket and create a water source."),
		tt_help = S("Places a water source"),
		extra_check = function(pos, placer)
			local nn = minetest.get_node(pos).name
			-- Pour water into cauldron
			if minetest.get_item_group(nn, "cauldron") ~= 0 then
				-- Put water into cauldron
				if nn ~= "mcl_cauldrons:cauldron_3" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3"})
				end
				sound_place("mcl_core:water_source", pos)
				return false, true
			-- Evaporate water if used in Nether (except on cauldron)
			else
				local dim = mcl_worlds.pos_to_dimension(pos)
				if dim == "nether" then
					minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
					return false, true
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
		bucketname = "mcl_buckets:bucket_river_water",
		inventory_image = "bucket_river_water.png",
		name = S("River Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with river water."),
		usagehelp = S("Place it to empty the bucket and create a river water source."),
		tt_help = S("Places a river water source"),
		extra_check = function(pos, placer)
			local nn = minetest.get_node(pos).name
			-- Pour into cauldron
			if minetest.get_item_group(nn, "cauldron") ~= 0 then
				-- Put water into cauldron
				if nn ~= "mcl_cauldrons:cauldron_3r" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3r"})
				end
				sound_place("mcl_core:water_source", pos)
				return false, true
			else
				-- Evaporate water if used in Nether (except on cauldron)
				local dim = mcl_worlds.pos_to_dimension(pos)
				if dim == "nether" then
					minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
					return false, true
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

-- Fish Buckets
local fish_names = {
	["cod"] = "Cod",
	["salmon"] = "Salmon",
	["tropical_fish"] = "Tropical Fish",
	["axolotl"] = "Axolotl",
	--["pufferfish"] = "Pufferfish", --FIXME add pufferfish
}

local fishbucket_prefix = "mcl_buckets:bucket_"

local function on_place_fish(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above
	local n = minetest.get_node_or_nil(pos)
	if n and minetest.registered_nodes[n.name].buildable_to or n.name == "mcl_portals:portal" then
		local fish = itemstack:get_name():gsub(fishbucket_prefix,"")
		if fish_names[fish] then
			local o = minetest.add_entity(pos, "mobs_mc:" .. fish)
			minetest.set_node(pos,{name = "mcl_core:water_source"})
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:set_name("mcl_buckets:bucket_empty")
			end
		end
	end
	return itemstack
end

for techname, fishname in pairs(fish_names) do
	minetest.register_craftitem(fishbucket_prefix .. techname, {
		description = S("Bucket of @1", S(fishname)),
		_doc_items_longdesc = S("This bucket is filled with water and @1.", S(fishname)),
		_doc_items_usagehelp = S("Place it to empty the bucket and place a @1. Obtain by right clicking on a @2 with a bucket of water.", S(fishname), S(fishname)),
		_tt_help = S("Places a water source and a @1.", S(fishname)),
		inventory_image = techname .. "_bucket.png",
		stack_max = 1,
		groups = {bucket = 1, fish_bucket = 1},
		liquids_pointable = false,
		on_place = on_place_fish,
		on_secondary_use = on_place_fish,
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

	minetest.register_alias("mcl_fishing:bucket_" .. techname, "mcl_buckets:bucket_" .. techname)
end
