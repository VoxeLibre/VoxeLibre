-- TODO: whenever it becomes possible to fully implement kelp without the
-- plantlike_rooted limitation, please adapt the code accordingly.
--
-- TODO: In MC, you can't actually destroy kelp by bucket'ing water in the middle.
-- However, because of the plantlike_rooted hack, we'll just allow it for now.
--
-- TODO: Currently, you lose kelp if the kelp is placed on a block and then falls.
-- This is most relevant for (red)sand and gravel.

local S = minetest.get_translator("mcl_ocean")
local mod_doc = minetest.get_modpath("doc") ~= nil

--------------------------------------------------------------------------------
-- local-ify runtime functions
--------------------------------------------------------------------------------
-- objects
local registered_items = minetest.registered_items
local registered_nodes = minetest.registered_nodes

-- functions
local mt_get_item_group = minetest.get_item_group
local mt_get_node = minetest.get_node
local mt_set_node = minetest.set_node
local mt_add_item = minetest.add_item
local mt_sound_play = minetest.sound_play
local mt_is_creative_enabled = minetest.is_creative_enabled
local mt_is_protected = minetest.is_protected
local mt_hash_node_position = minetest.hash_node_position
local mt_get_node_timer = minetest.get_node_timer

-- DEBUG: functions
local log = minetest.log
local chatlog = minetest.chat_send_all

--------------------------------------------------------------------------------
-- Kelp API
--------------------------------------------------------------------------------

kelp = {}

-- Is this water?
-- Returns the liquidtype, if indeed water.
local function is_submerged(node, nodedef)
	if mt_get_item_group(node.name, "water") ~= 0 then
		return nodedef.liquidtype -- Expected only "source" and "flowing" from water liquids
	end
	return false
end
kelp.is_submerged = is_submerged


-- Is the water downward flowing?
-- (kelp can grow/be placed inside downward flowing water)
local function is_downward_flowing(pos, node, nodedef, is_above)
	local result = (math.floor(node.param2 / 8) % 2) == 1
	if not (result or is_above) then
		-- If not, also check node above.
		-- (this is needed due a weird quirk in the definition of "downwards flowing"
		-- liquids in Minetest)
		local node_above = mt_get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local nodedef_above = registered_nodes[node_above.name]
		result = is_submerged(node_above, nodedef_above)
			or is_downward_flowing(pos, node_above, nodedef_above, true)
	end
	return result
end
kelp.is_downward_flowing = is_downward_flowing


-- Converts param2 to kelp height.
local function get_height(param2)
	return math.floor(param2 / 16)
end
kelp.get_height = get_height


-- Obtain pos and node of the top of kelp.
local function get_tip(pos, node)
	local size = math.ceil(node.param2 / 16)
	local pos_top = table.copy(pos)
	pos_top.y = pos_top.y + size
	return pos_top, mt_get_node(pos_top)
end
kelp.get_tip = get_tip


-- Obtain position of the first kelp unsubmerged.
local function find_unsubmerged(pos, node)
	local x,y,z = pos.x, pos.y, pos.z
	local height = get_height(node.param2)
	for i=1,height do
		local walk_pos = {x=x, y=y + i, z=z}
		if mt_get_item_group(mt_get_node(walk_pos).name, "water") == 0 then
			return walk_pos
		end
	end
	return nil
end
kelp.find_unsubmerged = find_unsubmerged


-- Obtain next param2.
local function next_param2(param2)
	local old_param2 = param2
	param2 = param2+16 - param2 % 16
	return param2, param2 ~= old_param2
end
kelp.next_param2 = next_param2


-- Grow next kelp.
local function next_grow(pos, node, pos_top, def_top, is_downward_flowing)
	-- Liquid source: Grow normally.
	mt_set_node(pos, node)

	-- Flowing liquid: Grow 1 step, but also turn the top node into a liquid source.
	if is_downward_flowing then
		local alt_liq = def_top.liquid_alternative_source
		if alt_liq then
			mt_set_node(pos_top, {name=alt_liq})
		end
	end
end
kelp.next_grow = next_grow


-- Drops the items for detached kelps.
local function detach_drop(pos, height)
	local x,y,z = pos.x,pos.y,pos.z
	for i=1,height do
		mt_add_item({x=x, y=y+i, z=z}, "mcl_ocean:kelp")
	end
end
kelp.detach_drop = detach_drop


-- Detach the kelp at dig_pos, and drop their items.
-- Synonymous to digging the kelp.
-- NOTE: this is intended for whenever kelp truly becomes segmented plants
-- instead of rooted to the floor. Don't try to remove dig_pos.
local function detach_dig(dig_pos, pos, node, is_drop)
	local param2 = node.param2
	-- pos.y points to the surface, offset needed to point to the first kelp.
	local new_height = dig_pos.y - (pos.y+1)

	-- Digs the entire kelp: invoke after_dig_node to mt_set_node.
	if new_height <= 0 then
		if is_drop then
			detach_drop(dig_pos, get_height(param2))
		end
		mt_set_node(pos, {
			name=registered_nodes[node.name].node_dig_prediction,
			param=node.param, param2=0 })

	-- Digs the kelp beginning at a height
	else
		if is_drop then
			detach_drop(dig_pos, get_height(param2) - new_height)
		end
		mt_set_node(pos, {name=node.name, param=node.param, param2=16*new_height})
	end
end
kelp.detach_dig = detach_dig

--------------------------------------------------------------------------------
-- Kelp callback functions
--------------------------------------------------------------------------------

local function surface_on_dig(pos, node, digger)
	-- NOTE: if instead, kelp shouldn't drop in creative: use this instead
	-- detach_dig(pos, pos, node,
	-- 	not (digger and mt_is_creative_enabled(digger:get_player_name())))
	detach_dig(pos, pos, node, true)
end
kelp.surface_on_dig = surface_on_dig


local function surface_after_dig_node(pos, node)
	return mt_set_node(pos, {name=registred_nodes[node.name].node_dig_prediction})
end
kelp.surface_after_dig_node = surface_after_dig_node


local kelp_timers = {}
local kelp_timers_counter = 0
local function surface_on_timer(pos, elapsed)
	local node = mt_get_node(pos)
	local dig_pos = find_unsubmerged(pos, node)
	if dig_pos then
		detach_dig(dig_pos, pos, node, true)
	end
	return true
end


-- NOTE: Uncomment this to use ABMs
-- local function surface_unsubmerged_abm(pos, node)
-- 	local dig_pos = find_unsubmerged(pos, node)
-- 	if dig_pos then
-- 		detach_dig(dig_pos, pos, node, true)
-- 	end
-- 	return true
-- end


-- NOTE: Uncomment this to use nodetimers
local function surface_register_nodetimer(pos, node)
	local pos_hash = mt_hash_node_position(pos)
	if kelp_timers[pos_hash] then
		return
	end
	local timer = mt_get_node_timer(pos)
	kelp_timers[pos_hash] = timer
	timer:start(0.5)
	kelp_timers_counter = kelp_timers_counter + 1
	chatlog("added a timer. Currently " ..tostring(kelp_timers_counter) .." timers")
end
kelp.surface_register_nodetiemr = surface_register_nodetimer


local function grow_kelp(pos, node)
	local grow
	-- Grow kelp by 1 node length if it would grow inside water
	node.param2, grow = next_param2(node.param2)
	local pos_top, node_top = get_tip(pos, node)
	local def_top = registered_nodes[node_top.name]
	if grow and is_submerged(node_top, def_top) then
		next_grow(pos, node, pos_top, def_top,
			is_downward_flowing(pos_top, node_top, def_top))
	end
end
kelp.grow_kelp = grow_kelp


local function kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = mt_get_node(pos_under)
	local nu_name = node_under.name
	local def_under = registered_nodes[nu_name]

	-- Allow rightclick override.
	if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
		return def_under.on_rightclick(pos_under, node_under,
				placer, itemstack, pointed_thing) or itemstack
	end

	if mt_is_protected(pos_under, player_name) or
			mt_is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	local new_kelp = false
	local downward_flowing = false
	local pos_top, node_top, def_top

	-- When placed on kelp.
	if mt_get_item_group(nu_name, "kelp") == 1 then
		node_under.param2, new_kelp = next_param2(node_under.param2)
		-- Kelp must not reach the height limit.
		-- Kelp must also be placed on top of kelp to add kelp.
		if not new_kelp or pos_under.y >= pos_above.y then
			return itemstack
		end
		pos_top, node_top = get_tip(pos_under, node_under)
		def_top = registered_nodes[node_top.name]

	-- When placed on surface.
	else
		local surfaces = kelp.surfaces or surfaces
		for _,surface in pairs(surfaces) do
			-- Surface must support kelp
			if nu_name == surface.nodename then
				node_under.name = "mcl_ocean:kelp_" ..surface.name
				node_under.param2 = registered_items[nu_name].place_param2 or 16
				new_kelp = true
				break
			end
		end

		-- Kelp must also be placed on top of surface to add new kelp.
		if not new_kelp or pos_under.y >= pos_above.y then
			return itemstack
		end

		pos_top = pos_above
		node_top = mt_get_node(pos_above)
		def_top = registered_nodes[node_top.name]

		-- NOTE: Uncomment this to use nodetimers
		-- Register nodetimer
		surface_register_nodetimer(pos_under, node_under)
	end

	-- New kelp must also be submerged in water.
	downward_flowing = is_downward_flowing(pos_top, node_top, def_top)
	if not (is_submerged(node_top, def_top) or downward_flowing) then
		return itemstack
	end

	-- Play sound, place surface/kelp and take away an item
	local def_node = registered_items[nu_name]
	if def_node.sounds then
		mt_sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	next_grow(pos_under, node_under, pos_top, def_top, downward_flowing)
	if not mt_is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end
kelp.kelp_on_place = kelp_on_place

--------------------------------------------------------------------------------
-- Kelp registration API
--------------------------------------------------------------------------------

-- List of supported surfaces for seagrass and kelp.
local surfaces = {
	{ name="dirt",    nodename="mcl_core:dirt",    },
	{ name="sand",    nodename="mcl_core:sand",    },
	{ name="redsand", nodename="mcl_core:redsand", },
	{ name="gravel",  nodename="mcl_core:gravel",  },
}
kelp.surfaces = surfaces
local registered_surfaces = {}
kelp.registered_surfaces = registered_surfaces

-- Commented properties are the ones obtained using register_kelp_surface.
-- If you define your own properties, it overrides the default ones.
local surface_deftemplate = {
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "leveled",
	place_param2 = 16,
	--tiles = def.tiles,
	special_tiles = {
		{
		image = "mcl_ocean_kelp_plant.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
		tileable_vertical = true,
		}
	},
	--inventory_image = "("..def.tiles[1]..")^mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.5, 0.5 },
		},
	},
	-- groups.falling_node = is_falling,
	groups = { dig_immediate = 3, deco_block = 1, plant = 1, kelp = 1, },
	--sounds = sounds,
	--node_dig_prediction = nodename,
	after_dig_node = surface_after_dig_node,
	on_dig = surface_on_dig,
	on_timer = surface_on_timer,
	drop = "", -- drops are handled in on_dig
	--_mcl_falling_node_alternative = is_falling and nodename or nil,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
}
kelp.surface_deftemplate = surface_deftemplate

-- Commented properties are the ones obtained using register_kelp_surface.
local surface_docs = {
	-- entry_id_orig = nodename,
	_doc_items_entry_name = S("Kelp"),
	_doc_items_longdesc = S("Kelp grows inside water on top of dirt, sand or gravel."),
	--_doc_items_create_entry = doc_create,
	_doc_items_image = "mcl_ocean_kelp_item.png",
}
kelp.surface_docs = surface_docs

--[==[--
register_kelp_surface(surface[, surface_deftemplate[, surface_docs]])

surface: table with its specific properties. See also kelp.surface.

surface_deftemplate: modifiable nodedef template. See also kelp.surface_deftempate.
DO NOT RE-USE THE SAME DEFTEMPLATE. create copies.

surface_docs: table with properties related to docs. See also kelp.surface_docs.
--]==]--
local leaf_sounds = mcl_sounds.node_sound_leaves_defaults()
local function register_kelp_surface(surface, surface_deftemplate, surface_docs)
	local name = surface.name
	local nodename = surface.nodename
	local def = registered_nodes[nodename]
	local def_tiles = def.tiles

	local surfacename = "mcl_ocean:kelp_"..name
	local surface_deftemplate = surface_deftemplate or kelp.surface_deftemplate -- optional param

	local doc_create = surface.doc_create or false
	local surface_docs = surface_docs or kelp.surface_docs

	if doc_create then
		surface_deftemplate._doc_items_entry_name = surface_docs._doc_items_entry_name
		surface_deftemplate._doc_items_longdesc = surface_docs._doc_items_longdesc
		surface_deftemplate._doc_items_create_entry = true
		surface_deftemplate._doc_items_image = surface_docs._doc_items_image
		-- Takes the first surface with docs
		if not surface_docs.entry_id_orig then
			surface_docs.entry_id_orig = nodename
		end
	elseif mod_doc then
		doc.add_entry_alias("nodes", surface_docs.entry_id_orig, "nodes", surfacename)
	end

	local sounds = table.copy(def.sounds)
	sounds.dig = leaf_sounds.dig
	sounds.dug = leaf_sounds.dug
	sounds.place = leaf_sounds.place

	surface_deftemplate.tiles = surface_deftemplate.tiles or def_tiles
	surface_deftemplate.inventory_image = surface_deftemplate.inventory_image or "("..def_tiles[1]..")^mcl_ocean_kelp_item.png"
	surface_deftemplate.sounds = surface_deftemplate.sound or sounds
	local falling_node = mt_get_item_group(nodename, "falling_node")
	surface_deftemplate.node_dig_prediction = surface_deftemplate.node_dig_prediction or nodename
	surface_deftemplate.groups.falling_node = surface_deftemplate.groups.falling_node or falling_node
	surface_deftemplate._mcl_falling_node_alternative = surface_deftemplate._mcl_falling_node_alternative or (falling_node and nodename or nil)

	minetest.register_node(surfacename, surface_deftemplate)
end

-- Kelp surfaces nodes ---------------------------------------------------------

-- Dirt must be registered first, for the docs
register_kelp_surface(surfaces[1], table.copy(surface_deftemplate), surface_docs)
for i=2, #surfaces do
	register_kelp_surface(surfaces[i], table.copy(surface_deftemplate), surface_docs)
end

-- Kelp item -------------------------------------------------------------------

minetest.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
	inventory_image = "mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	on_place = kelp_on_place,
	groups = { deco_block = 1 },
})

if mod_doc then
	doc.add_entry_alias("nodes", surface_docs.entry_id_orig, "craftitems", "mcl_ocean:kelp")
end

-- Dried kelp ------------------------------------------------------------------

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

-- ABMs ------------------------------------------------------------------------
minetest.register_abm({
	label = "Kelp growth",
	nodenames = { "group:kelp" },
	interval = 45,
	chance = 12,
	catch_up = false,
	action = grow_kelp,
})

-- NOTE: Uncomment this to use nodetimers
minetest.register_lbm({
	label = "Kelp timer registration",
	name = "mcl_ocean:kelp_timer_registration",
	nodenames = { "group:kelp" },
	run_at_every_load = false,
	action = surface_register_nodetimer,
})

-- NOTE: Uncomment this to use ABMs
-- Break kelp not underwater.
-- minetest.register_abm({
-- 	label = "Kelp drops",
-- 	nodenames = { "group:kelp" },
-- 	interval = 1.0,
-- 	chance = 1,
-- 	catch_up = false,
-- 	action = surface_unsubmerged_abm,
-- })
