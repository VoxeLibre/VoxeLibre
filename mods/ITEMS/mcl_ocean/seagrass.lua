local S = minetest.get_translator("mcl_ocean")

local function seagrass_on_place(itemstack, placer, pointed_thing)
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

	if node_under.name ~= "mcl_core:dirt" then
		return itemstack
	end
	node_under.name = "mcl_ocean:seagrass_dirt"
	node_under.param2 = minetest.registered_items[itemstack:get_name()].place_param2 or 3
	if node_under.param2 < 8 and math.random(1,2) == 1 then
		-- Random horizontal displacement
		node_under.param2 = node_under.param2 + 8
	end
	minetest.set_node(pos_under, node_under)
	if not (minetest.settings:get_bool("creative_mode")) then
		itemstack:take_item()
	end

	return itemstack
end

-- Seagrass on dirt

minetest.register_node("mcl_ocean:seagrass_dirt", {
	description = S("Seagrass"),
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	tiles = { "default_dirt.png" },
	special_tiles = {
		{ 
		image = "mcl_ocean_seagrass.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=1.0},
		}
	},
	inventory_image = "mcl_ocean_seagrass.png^[verticalframe:12:0",
	wield_image = "mcl_ocean_seagrass.png^[verticalframe:12:0",
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -6/16, -8/16, -6/16, 6/16, 4/16, 6/16 },
		},
	},
	groups = { dig_immediate = 3, deco_block = 1, plant = 1, seagrass = 1, },
	sounds = mcl_sounds.node_sound_leaves_defaults({footstep = mcl_sounds.node_sound_dirt_defaults().footstep}),
	node_placement_prediction = "",
	node_dig_prediction = "mcl_core:dirt",
	on_place = seagrass_on_place,
	after_destruct = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "seagrass") == 0 then
			minetest.set_node(pos, {name="mcl_core:dirt"})
		end
	end,
	drop = "",
	_mcl_shears_drop = true,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
})
