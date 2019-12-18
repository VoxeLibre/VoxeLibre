local S = minetest.get_translator("mcl_ocean")

-- List of supported surfaces for seagrass and kelp
local surfaces = {
	{ "dirt", "mcl_core:dirt" },
	{ "sand", "mcl_core:sand", 1 },
	{ "redsand", "mcl_core:redsand", 1 },
	{ "gravel", "mcl_core:gravel", 1 },
}

local function kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = minetest.get_node(pos_under)
	local node_above = minetest.get_node(pos_above)
	local def_under = minetest.registered_nodes[node_under.name]
	local def_above = minetest.registered_nodes[node_above.name]

	if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
		return def_under.on_rightclick(pos_under, node_under,
				placer, itemstack, pointed_thing) or itemstack
	end

	if pos_under.y >= pos_above.y then
		return itemstack
	end

	-- Placement rules:
	-- Seagrass can only be placed on top of dirt inside water
	local g_above_water = minetest.get_item_group(node_above.name, "water")
	if not (g_above_water ~= 0 and def_above.liquidtype == "source") then
		return itemstack
	end

	if minetest.is_protected(pos_under, player_name) or
			minetest.is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	-- Select a kelp node
	if node_under.name == "mcl_core:dirt" then
		node_under.name = "mcl_ocean:kelp_dirt"
	elseif node_under.name == "mcl_core:sand" then
		node_under.name = "mcl_ocean:kelp_sand"
	elseif node_under.name == "mcl_core:redsand" then
		node_under.name = "mcl_ocean:kelp_redsand"
	elseif node_under.name == "mcl_core:gravel" then
		node_under.name = "mcl_ocean:kelp_gravel"
	else
		return itemstack
	end
	local def_node = minetest.registered_items[node_under.name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under })
	end
	node_under.param2 = minetest.registered_items[node_under.name].place_param2 or 16
	minetest.set_node(pos_under, node_under)
	if not (minetest.settings:get_bool("creative_mode")) then
		itemstack:take_item()
	end

	return itemstack
end

minetest.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	inventory_image = "mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	on_place = kelp_on_place,
	groups = { deco_block = 1 },
})

-- Kelp nodes: kelp on a surface node

for s=1, #surfaces do
	local def = minetest.registered_nodes[surfaces[s][2]]
	local alt
	if surfaces[s][3] == 1 then
		alt = surfaces[s][2]
	end
	local sounds = table.copy(def.sounds)
	local leaf_sounds = mcl_sounds.node_sound_leaves_defaults()
	sounds.dig = leaf_sounds.dig
	sounds.dug = leaf_sounds.dug
	sounds.place = leaf_sounds.place
	minetest.register_node("mcl_ocean:kelp_"..surfaces[s][1], {
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "leveled",
		place_param2 = 16,
		tiles = def.tiles,
		special_tiles = {
			{
			image = "mcl_ocean_kelp_plant.png",
			animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
			tileable_vertical = true,
			}
		},
		inventory_image = "("..def.tiles[1]..")^mcl_ocean_kelp_item.png",
		wield_image = "mcl_ocean_kelp_item.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.5, 0.5 },
			},
		},
		groups = { dig_immediate = 3, deco_block = 1, plant = 1, kelp = 1, falling_node = surfaces[s][3] },
		sounds = sounds,
		node_dig_prediction = surfaces[s][2],
		after_dig_node = function(pos)
			minetest.set_node(pos, {name=surfaces[s][2]})
		end,
		drop = "mcl_ocean:kelp",
		_mcl_falling_node_alternative = alt,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
	})
end


-- Dried kelp stuff

-- TODO: This is supposed to be eaten very fast
minetest.register_craftitem("mcl_ocean:dried_kelp", {
	description = S("Dried Kelp"),
	inventory_image = "mcl_ocean_dried_kelp.png",
	wield_image = "mcl_ocean_dried_kelp.png",
	groups = { food = 2, eatable = 1 },
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = { food = 2, eatable = 1 },
	_mcl_saturation = 0.6,
})

local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end


minetest.register_node("mcl_ocean:dried_kelp_block", {
	description = S("Dried Kelp Block"),
	tiles = { "mcl_ocean_dried_kelp_top.png", "mcl_ocean_dried_kelp_bottom.png", "mcl_ocean_dried_kelp_side.png" },
	groups = { handy = 1, building_block = 1, flammable = 2 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	_mcl_hardness = 0.5,
	_mcl_blast_resistance = 12.5,
})

minetest.register_craft({
	type = "cooking",
	recipe = "mcl_ocean:kelp",
	output = "mcl_ocean:dried_kelp",
	cooktime = 10,
})
minetest.register_craft({
	recipe = {
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
		{ "mcl_ocean:dried_kelp","mcl_ocean:dried_kelp","mcl_ocean:dried_kelp" },
	},
	output = "mcl_ocean:dried_kelp_block",
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_ocean:dried_kelp_block",
	burntime = 200,
})
