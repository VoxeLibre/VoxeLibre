local S = minetest.get_translator("mcl_ocean")
local mod_doc = minetest.get_modpath("doc") ~= nil
-- NOTE: whenever it becomes possible to fully implement kelp without the
-- plantlike_rooted limitation, please adapt the code accordingly.

-- List of supported surfaces for seagrass and kelp.
local surfaces = {
	{ "dirt", "mcl_core:dirt" },
	{ "sand", "mcl_core:sand", 1 },
	{ "redsand", "mcl_core:redsand", 1 },
	{ "gravel", "mcl_core:gravel", 1 },
}

-- Is this water?
local function is_submerged(node, nodedef)
	if minetest.get_item_group(node.name, "water") ~= 0 then
		return nodedef.liquidtype -- Expected only "source" and "flowing" from water liquids
	end
	return false
end

-- Is the water downward flowing?
-- (kelp can grow/be placed inside downward flowing water)
local function is_downward_flowing(pos, node, nodedef, is_above)

	result = (math.floor(node.param2 / 8) % 2) == 1
	if not (result or is_above) then
		-- If not, also check node above (this is needed due a weird quirk in the definition of
		-- "downwards flowing" liquids in Minetest)
		local node_above = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local nodedef_above = minetest.registered_nodes[node_above.name]
		result = is_submerged(node_above, nodedef_above) or is_downward_flowing(pos, node_above, nodedef_above, true)
	end
	return result
end

-- Converts param2 to kelp height.
local function get_kelp_height(param2)
	return math.floor(param2 / 16)
end

-- Obtain pos and node of the top of kelp.
local function get_kelp_top(pos, node)
	local size = math.ceil(node.param2 / 16)
	local pos_top = table.copy(pos)
	pos_top.y = pos_top.y + size
	return pos_top, minetest.get_node(pos_top)
end

-- Obtain position of the first kelp unsubmerged.
local function get_kelp_unsubmerged(pos, node)
	local x,y,z = pos.x, pos.y, pos.z
	local height = get_kelp_height(node.param2)
	for i=1,height do
		local walk_pos = {x=x, y=y + i, z=z}
		if minetest.get_item_group(minetest.get_node(walk_pos).name, "water") == 0 then
			return walk_pos
		end
	end
	return nil
end

-- Obtain next param2 if grown
local function grow_param2_step(param2)
	-- TODO: allow kelp to grow bypass this limit according to MC rules.
	-- https://minecraft.gamepedia.com/Kelp

	local old_param2 = param2
	param2 = param2+16 - param2 % 16
	if param2 > 240 then
		param2 = 240
	end
	return param2, param2 ~= old_param2
end

local function kelp_place(pos, node, pos_top, def_top, is_downward_flowing)
	-- Liquid source: Grow normally
	minetest.set_node(pos, node)

	-- Flowing liquid: Grow 1 step, but also turn the top node into a liquid source
	if is_downward_flowing then
		local alt_liq = def_top.liquid_alternative_source
		if alt_liq then
			minetest.set_node(pos_top, {name=alt_liq})
		end
	end
end

local function kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = minetest.get_node(pos_under)
	local nu_name = node_under.name
	local def_under = minetest.registered_nodes[nu_name]

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

	local new_kelp = false
	local is_downward_flowing = false
	local pos_top, node_top, def_top

	-- When placed on kelp.
	if minetest.get_item_group(nu_name, "kelp") == 1 then
		node_under.param2, new_kelp = grow_param2_step(node_under.param2)
		-- Kelp must not reach the height limit.
		-- Kelp must also be placed on top of kelp to add kelp.
		if not new_kelp or pos_under.y >= pos_above.y then
			return itemstack
		end
		pos_top, node_top = get_kelp_top(pos_under, node_under)
		def_top = minetest.registered_nodes[node_top.name]

	-- When placed on surface.
	else
		for _,surface in pairs(surfaces) do
			-- Surface must support kelp
			if nu_name == surface[2] then
				node_under.name = "mcl_ocean:kelp_" ..surface[1]
				node_under.param2 = minetest.registered_items[nu_name].place_param2 or 16
				new_kelp = true
			end
		end

		-- Kelp must also be placed on top of surface to add new kelp.
		if not new_kelp or pos_under.y >= pos_above.y then
			return itemstack
		end
		pos_top = pos_above
		node_top = minetest.get_node(pos_above)
		def_top = minetest.registered_nodes[node_above.name]
	end

	-- New kelp must also be submerged in water.
	is_downward_flowing = is_downward_flowing(pos_top, node_top, def_top)
	if not (is_submerged(node_top, def_top) and is_downward_flowing) then
		return itemstack
	end

	-- Play sound, place surface/kelp and take away an item
	local def_node = minetest.registered_items[nu_name]
	if def_node.sounds then
		minetest.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	kelp_place(pos_under, node_under, pos_top, def_top, is_downward_flowing)
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end

-- From kelp at pos, drop kelp until reaching its height.
local function kelp_drop(pos, height)
	local x,y,z = pos.x,pos.y,pos.z
	for i=1,height do
		minetest.add_item({x=x, y=y+i, z=z}, "mcl_ocean:kelp")
	end
end

-- Dig kelp:
--   Each kelp from broken stem until the top drop a single item
--   Kelp's height decreases to the height below dig_pos
local function kelp_dig(dig_pos, pos, node, is_drop)
	local param2 = node.param2
	local height = get_kelp_height(param2)
	-- pos.y points to the surface, offset needed to point to the first kelp
	local new_height = dig_pos.y - (pos.y+1)

	-- Digs the entire kelp: invoke after_dig_node to set_node
	if new_height == 0 then
		if is_drop then
			kelp_drop(dig_pos, height)
		end
		minetest.set_node(pos, {name=minetest.registered_nodes[node.name].node_dig_prediction})

	-- Digs the kelp beginning at a height
	else
		if is_drop then
			kelp_drop(dig_pos, height - new_height)
		end
		minetest.set_node(pos, {name=node.name, param=node.param, param2=16*new_height})
	end
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
			minetest.set_node(pos, {name=surface[s][2]})
		end,
		on_dig = function(pos, node, digger)
			local is_drop = true
			if digger and minetest.is_creative_enabled(digger:get_player_name()) then
				is_drop = false
			end
			kelp_dig(pos, pos, node, is_drop)
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
	-- interval = 45,
	-- chance = 12,
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local grow
		-- Grow kelp by 1 node length if it would grow inside water
		node.param2, grow = grow_param2_step(node.param2)
		local pos_top, node_top = get_kelp_top(pos, node)
		local def_top = minetest.registered_nodes[node_top.name]
		if grow and is_submerged(node_top, def_top) then
			kelp_place(pos, node, pos_top, def_top,
				is_downward_flowing(pos_top, node_top, def_top))
		end
	end,
})

-- Break kelp not underwater.
minetest.register_abm({
	label = "Kelp drops",
	nodenames = { "group:kelp" },
	interval = 0.25,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		local dig_pos = get_kelp_unsubmerged(pos, node)
		if dig_pos then
			kelp_dig(dig_pos, pos, node, true)
		end
	end
})
