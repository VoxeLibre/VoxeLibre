local S = core.get_translator(core.get_current_modname())

--Copied from mcl_flowers

local mod_screwdriver = minetest.get_modpath("screwdriver")
local has_mcl_flowerpots = minetest.get_modpath("mcl_flowerpots")


seasons.registered_simple_flowers = {}
-- Simple flower template
local smallflowerlongdesc = S("This is a small flower. Small flowers are mainly used for dye production and can also be potted.")
local plant_usage_help = S("It can only be placed on a block on which it would also survive.")

-- on_place function for flowers
local on_place_flower = mcl_util.generate_on_place_plant_function(function(pos, node, itemstack)
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local soil_node = minetest.get_node_or_nil(below)
	if not soil_node then return false end

	local has_palette = minetest.registered_nodes[itemstack:get_name()].palette ~= nil
	local colorize = has_palette and mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index or 0

--[[	Placement requirements:
	* Dirt or grass block
	* If not flower, also allowed on podzol and coarse dirt
	* Light level >= 8 at any time or exposed to sunlight at day
]]
	local light_night = minetest.get_node_light(pos, 0.0)
	local light_day = minetest.get_node_light(pos, 0.5)
	local light_ok = (light_night and light_night >= 8) or (light_day and light_day >= minetest.LIGHT_MAX)
	if itemstack:get_name() == "mcl_flowers:wither_rose" and (  minetest.get_item_group(soil_node.name, "grass_block") > 0 or soil_node.name == "mcl_core:dirt" or soil_node.name == "mcl_core:coarse_dirt" or soil_node.name == "mcl_mud:mud" or soil_node.name == "mcl_moss:moss" or soil_node.name == "mcl_nether:netherrack" or minetest.get_item_group(soil_node.name, "soul_block") > 0  ) then
		return true,colorize
	end
	local is_flower = minetest.get_item_group(itemstack:get_name(), "flower") == 1
	local ok = (soil_node.name == "mcl_core:dirt" or minetest.get_item_group(soil_node.name, "grass_block") == 1 or (not is_flower and (soil_node.name == "mcl_core:coarse_dirt" or soil_node.name == "mcl_core:podzol" or soil_node.name == "mcl_core:podzol_snow"))) and light_ok
	return ok, colorize
end)

function seasons.register_simple_flower(name, def)
	local newname = "vl_seasons:"..name
	if not def._mcl_silk_touch_drop then def._mcl_silk_touch_drop = nil end
	if not def.drop then def.drop = newname end
	seasons.registered_simple_flowers[newname] = {
		name=name,
		desc=def.desc,
		image=def.image,
		simple_selection_box=def.simple_selection_box,
	}
	minetest.register_node(newname, {
		description = def.desc,
		_doc_items_longdesc = smallflowerlongdesc,
		_doc_items_usagehelp = plant_usage_help,
		drawtype = "plantlike",
		waving = 1,
		tiles = { def.image },
		inventory_image = def.image,
		wield_image = def.image,
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		stack_max = 64,
		drop = def.drop,
		groups = {
			attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
			dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
			plant = 1, flower = 1, place_flowerlike = 1, non_mycelium_plant = 1,
			flammable = 2, fire_encouragement = 60, fire_flammability = 100,
			compostability = 65, oxidizable = 1,
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = on_place_flower,
		selection_box = {
			type = "fixed",
			fixed = def.selection_box,
		},
		_mcl_silk_touch_drop = def._mcl_silk_touch_drop,
	})
	if def.potted and has_mcl_flowerpots then
		mcl_flowerpots.register_potted_flower(newname, {
			name = name,
			desc = def.desc,
			image = def.image,
		})
	end
end

-- Unbloomed Flower Registry
seasons.register_simple_flower("unbloomed_poppy", {
	desc = S("Unbloomed Poppy"),
	image = "vl_seasons_unbloomed_poppy_stage_0.png",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	potted = true,
})
seasons.register_simple_flower("unbloomed_dandelion", {
    desc = S("Unbloomed Dandelion"),
    image = "vl_seasons_unbloomed_dandelion_yellow_stage_0.png",
    selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_oxeye_daisy", {
    desc = S("Unbloomed Oxeye Daisy"),
    image = "vl_seasons_unbloomed_oxeye_daisy_stage_0.png",
    selection_box = { -4/16, -0.5, -4/16, 4/16, 4/16, 4/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_tulip_orange", {
    desc = S("Unbloomed Orange Tulip"),
    image = "vl_seasons_unbloomed_tulip_orange_stage_0.png",
    selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_tulip_pink", {
    desc = S("Unbloomed Pink Tulip"),
    image = "vl_seasons_unbloomed_tulip_pink_stage_0.png",
    selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_tulip_red", {
    desc = S("Unbloomed Red Tulip"),
    image = "vl_seasons_unbloomed_tulip_red_stage_0.png",
    selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_tulip_white", {
    desc = S("Unbloomed White Tulip"),
    image = "vl_seasons_unbloomed_tulip_white_stage_0.png",
    selection_box = { -3/16, -0.5, -3/16, 3/16, 4/16, 3/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_allium", {
    desc = S("Unbloomed Allium"),
    image = "vl_seasons_unbloomed_allium_stage_0.png",
    selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_azure_bluet", {
    desc = S("Unbloomed Azure Bluet"),
    image = "vl_seasons_unbloomed_azure_bluet_stage_0.png",
    selection_box = { -5/16, -0.5, -5/16, 5/16, 3/16, 5/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_blue_orchid", {
    desc = S("Unbloomed Blue Orchid"),
    image = "vl_seasons_unbloomed_blue_orchid_stage_0.png",
    selection_box = { -5/16, -0.5, -5/16, 5/16, 7/16, 5/16 },
    potted = true,
})

seasons.register_simple_flower("unbloomed_lily_of_the_valley", {
    desc = S("Unbloomed Lily of the Valley"),
    image = "vl_seasons_unbloomed_lily_of_the_valley_stage_0.png",
    selection_box = { -5/16, -0.5, -5/16, 4/16, 5/16, 5/16 },
    potted = true,
})
seasons.register_simple_flower("unbloomed_cornflower", {
    desc = S("Unbloomed Cornflower"),
    image = "vl_seasons_unbloomed_cornflower_stage_0.png",
    selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
    potted = true,
})
