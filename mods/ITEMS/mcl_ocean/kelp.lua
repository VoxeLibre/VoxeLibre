local S = minetest.get_translator("mcl_ocean")
local mod_doc = minetest.get_modpath("doc") ~= nil

-- List of supported surfaces for seagrass and kelp
local surfaces = {
	{ "dirt", "mcl_core:dirt" },
	{ "sand", "mcl_core:sand", 1 },
	{ "redsand", "mcl_core:redsand", 1 },
	{ "gravel", "mcl_core:gravel", 1 },
}

local function get_kelp_top(pos, node)
	local size = math.ceil(node.param2 / 16)
	local pos_water = table.copy(pos)
	pos_water.y = pos_water.y + size
	return pos_water, minetest.get_node(pos_water)
end

local function get_submerged(node_water)
	local def_water = minetest.registered_nodes[node_water.name]
	-- Submerged in water?
	if minetest.get_item_group(node_water.name, "water") then
		if def_water.liquidtype == "source" then
			return "source"
		elseif def_water.liquidtype == "flowing" then
			return "flowing"
		end
	end
	return false
end

local function grow_param2_step(param2, snap_into_grid)
	local old_param2 = param2
	param2 = param2 + 16
	if param2 > 240 then
		param2 = 240
	end
	if snap_into_grid and (param2 % 16 ~= 0) then
		param2 = param2 - (param2 % 16)
	end
	return param2, param2 ~= old_param2
end

local function kelp_check_place(pos_above, node_above, def_above)
	if minetest.get_item_group(node_above.name, "water") == 0 then
		return false
	end
	local can_place = false
	if (def_above.liquidtype == "source") then
		can_place = true
	elseif (def_above.liquidtype == "flowing") then
		-- Check if bit 3 (downwards flowing) is set
		can_place = (math.floor(node_above.param2 / 8) % 2) == 1
		if not can_place then
			-- If not, also check node above (this is needed due a weird quirk in the definition of
			-- "downwards flowing" liquids in Minetest)
			local node_above_above = minetest.get_node({x=pos_above.x,y=pos_above.y+1,z=pos_above.z})
			local naa_def = minetest.registered_nodes[node_above_above.name]
			can_place = naa_def.liquidtype == "source"
			if not can_place then
				can_place = (naa_def.liquidtype == "flowing") and ((math.floor(node_above_above.param2 / 8) % 2) == 1)
			end
		end
	end
	return can_place
end

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

	if minetest.is_protected(pos_under, player_name) or
			minetest.is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	local grow_kelp = false
	-- Select a kelp node when placed on surface node
	if node_under.name == "mcl_core:dirt" then
		node_under.name = "mcl_ocean:kelp_dirt"
	elseif node_under.name == "mcl_core:sand" then
		node_under.name = "mcl_ocean:kelp_sand"
	elseif node_under.name == "mcl_core:redsand" then
		node_under.name = "mcl_ocean:kelp_redsand"
	elseif node_under.name == "mcl_core:gravel" then
		node_under.name = "mcl_ocean:kelp_gravel"
	elseif minetest.get_item_group(node_under.name, "kelp") == 1 then
		-- Place kelp on kelp = grow kelp by 1 node length
		node_under.param2, grow_kelp = grow_param2_step(node_under.param2)
		if not grow_kelp then
			return itemstack
		end
	else
		return itemstack
	end
	local submerged = false
	if grow_kelp then
		-- Kelp placed on kelp ...
		-- Kelp can be placed on top of another kelp to make it grow
		if pos_under.y >= pos_above.y or pos_under.x ~= pos_above.x or pos_under.z ~= pos_above.z then
			-- Placed on side or below node, abort
			return itemstack
		end
		-- New kelp top must also be submerged in water
		local top_pos, top_node = get_kelp_top(pos_under, node_under)
		local top_def = minetest.registered_nodes[top_node.name]
		submerged = kelp_check_place(top_pos, top_node, top_def)
		if not submerged then
			-- Not submerged in water, abort
			return itemstack
		end
	else
		-- New kelp placed ...
		if pos_under.y >= pos_above.y then
			-- Placed on side or below node, abort
			return itemstack
		end
		-- Kelp can be placed inside a water source or water flowing downwards on top of a surface node
		local can_place = kelp_check_place(pos_above, node_above, def_above)
		if not can_place then
			return itemstack
		end
		node_under.param2 = minetest.registered_items[node_under.name].place_param2 or 16
	end
	-- Place or grow kelp
	local def_node = minetest.registered_items[node_under.name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	minetest.set_node(pos_under, node_under)
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end

local get_kelp_height = function(param2)
	return math.floor(param2 / 16)
end

minetest.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
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
	local tt_help, doc_longdesc, doc_img, desc
	if surfaces[s][1] == "dirt" then
		doc_longdesc = S("Kelp grows inside water on top of dirt, sand or gravel.")
		desc = S("Kelp")
		doc_create = true
		doc_img = "mcl_ocean_kelp_item.png"
	else
		doc_create = false
	end
	minetest.register_node("mcl_ocean:kelp_"..surfaces[s][1], {
		_doc_items_entry_name = desc,
		_doc_items_longdesc = doc_longdesc,
		_doc_items_create_entry = doc_create,
		_doc_items_image = doc_img,
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
		on_dig = function(pos, node, digger)
			-- Drop kelp as item; item count depends on height
			local dname = ""
			if digger then
				dname = digger:get_player_name()
			end
			local creative = minetest.is_creative_enabled(dname)
			if not creative then
				minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, "mcl_ocean:kelp "..get_kelp_height(node.param2))
			end
			minetest.node_dig(pos, node, digger)
		end,
		drop = "", -- drops are handled in on_dig
		_mcl_falling_node_alternative = alt,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
	})

	if mod_doc and surfaces[s][1] ~= "dirt" then
		doc.add_entry_alias("nodes", "mcl_ocean:kelp_dirt", "nodes", "mcl_ocean:kelp_"..surfaces[s][1])
	end
end

if mod_doc then
	doc.add_entry_alias("nodes", "mcl_ocean:kelp_dirt", "craftitems", "mcl_ocean:kelp")
end

-- Dried kelp stuff

-- TODO: This is supposed to be eaten very fast
minetest.register_craftitem("mcl_ocean:dried_kelp", {
	description = S("Dried Kelp"),
	_doc_items_longdesc = S("Dried kelp is a food item."),
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
	_doc_items_longdesc = S("A decorative block that serves as a great furnace fuel."),
	tiles = { "mcl_ocean_dried_kelp_top.png", "mcl_ocean_dried_kelp_bottom.png", "mcl_ocean_dried_kelp_side.png" },
	groups = { handy = 1, building_block = 1, flammable = 2, fire_encouragement = 30, fire_flammability = 60 },
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
	recipe = {
		{ "mcl_ocean:dried_kelp_block" },
	},
	output = "mcl_ocean:dried_kelp 9",
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_ocean:dried_kelp_block",
	burntime = 200,
})

-- Grow kelp
minetest.register_abm({
	label = "Kelp growth",
	nodenames = { "group:kelp" },
	interval = 45,
	chance = 12,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local grown
		-- Grow kelp by 1 node length if it would grow inside water
		node.param2, grown = grow_param2_step(node.param2, true)
		local top, top_node = get_kelp_top(pos, node)
		local submerged = get_submerged(top_node)
		if grown then
			if submerged == "source" then
				-- Liquid source: Grow normally
				minetest.set_node(pos, node)
			elseif submerged == "flowing" then
				-- Flowing liquid: Grow 1 step, but also turn the top node into a liquid source
				minetest.set_node(pos, node)
				local def_liq = minetest.registered_nodes[top_node.name]
				local alt_liq = def_liq and def_liq.liquid_alternative_source
				if alt_liq then
					minetest.set_node(top, {name=alt_liq})
				end
			end
		end
	end,
})
