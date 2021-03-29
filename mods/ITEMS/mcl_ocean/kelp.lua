-- TODO: whenever it becomes possible to fully implement kelp without the
-- plantlike_rooted limitation, please adapt the code accordingly.
--
-- TODO: In MC, you can't actually destroy kelp by bucket'ing water in the middle.
-- However, because of the plantlike_rooted hack, we'll just allow it for now.

local S = minetest.get_translator("mcl_ocean")
local mod_doc = minetest.get_modpath("doc") ~= nil

--------------------------------------------------------------------------------
-- local-ify runtime functions
--------------------------------------------------------------------------------
-- objects
local mt_registered_items = minetest.registered_items
local mt_registered_nodes = minetest.registered_nodes

-- functions
local mt_add_item = minetest.add_item
local mt_get_item_group = minetest.get_item_group
local mt_get_node = minetest.get_node
local mt_get_node_level = minetest.get_node_level
local mt_get_node_max_level = minetest.get_node_max_level
local mt_get_node_or_nil = minetest.get_node_or_nil
local mt_get_node_timer = minetest.get_node_timer
local mt_hash_node_position = minetest.hash_node_position
local mt_is_protected = minetest.is_protected
local mt_set_node = minetest.set_node
local mt_get_meta = minetest.get_meta

local mt_is_creative_enabled = minetest.is_creative_enabled
local mt_sound_play = minetest.sound_play

local math_floor = math.floor
local math_random = math.random
local string_format = string.format

-- DEBUG: functions
local log = minetest.log
local chatlog = minetest.chat_send_all

--------------------------------------------------------------------------------
-- Kelp API
--------------------------------------------------------------------------------

local kelp = {}
mcl_ocean.kelp = kelp

kelp.MAX_AGE = 25
kelp.TIMER_INTERVAL = 0.2

-- The average amount of growth for kelp in a day is 2.16 (https://youtu.be/5Bp4lAjAk3I)
-- Normally, a day lasts 20 minutes, meaning this nodetimer is executed 24000 times.
-- Calculate probability via 2.16/24000 and we get the probability 9/100'000 or 9.0e-5
-- NOTE: currently, we can't exactly use the same type of randomness MC does,
-- because it has multiple complicated sets of PRNGs.
-- kelp.RANDOM_NUMERATOR = 9
kelp.RANDOM_NUMERATOR = 100
kelp.RANDOM_DENOMINATOR = 100000

kelp.leaf_sounds = mcl_sounds.node_sound_leaves_defaults()

-- TODO: is this really necessary
-- Lock drops to avoid duplicate drops, set after dropping detached kelp.
kelp.lock_drop = 0

-- Registrar of nodetimers, indexed by pos_hash.
kelp.registered_nodetimers = {}

-- Pool storing age, indexed by pos_hash.
kelp.age_pool = {}


-- is age in the growable range?
function kelp.is_age_growable(age)
	return age >= 0 and age < kelp.MAX_AGE
end


-- Is this water?
-- Returns the liquidtype, if indeed water.
function kelp.is_submerged(node, def)
	if mt_get_item_group(node.name, "water") ~= 0 then
		return def.liquidtype -- Expected only "source" and "flowing" from water liquids
	end
	return false
end


-- Is the water downward flowing?
-- (kelp can grow/be placed inside downward flowing water)
function kelp.is_downward_flowing(pos, node, def, is_above)
	local result = (math_floor(node.param2 / 8) % 2) == 1
	if not (result or is_above) then
		-- If not, also check node above.
		-- (this is needed due a weird quirk in the definition of "downwards flowing"
		-- liquids in Minetest)
		local node_above = mt_get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local def_above = mt_registered_nodes[node_above.name]
		result = kelp.is_submerged(node_above, def_above)
			or kelp.is_downward_flowing(pos, node_above, def_above, true)
	end
	return result
end


-- Will node fall at that position?
-- This only checks if a node would fall, meaning that node need not be at pos.
function kelp.is_falling(pos, node)
	-- NOTE: Modified from check_single_for_falling in builtin.
	-- Please update as necessary.
	local nodename = node.name

	if mt_get_item_group(nodename, "falling_node") == 0 then
		return false
	end

	local pos_bottom = {x = pos.x, y = pos.y - 1, z = pos.z}
	-- get_node_or_nil: Only fall if node below is loaded
	local node_bottom = mt_get_node_or_nil(pos_bottom)
	local nodename_bottom = node_bottom.name
	local def_bottom = node_bottom and mt_registered_nodes[nodename_bottom]
	if not def_bottom then
		return false
	end

	local same = nodename == nodename_bottom
	-- Let leveled nodes fall if it can merge with the bottom node
	if same and def_bottom.paramtype2 == "leveled" and
			mt_get_node_level(pos_bottom) <
			mt_get_node_max_level(pos_bottom) then
		return true
	end

	-- Otherwise only if the bottom node is considered "fall through"
	if not same and
			(not def_bottom.walkable or def_bottom.buildable_to) and
			(mt_get_item_group(nodename, "float") == 0 or
			def_bottom.liquidtype == "none") then
		return true
	end

	return false
end


-- Converts param2 to kelp height.
function kelp.get_height(param2)
	return math_floor(param2 / 16)
end


-- Obtain pos and node of the tip of kelp.
function kelp.get_tip(pos, node)
	local size = math.ceil(node.param2 / 16)
	local pos_tip = table.copy(pos)
	pos_tip.y = pos_tip.y + size
	return pos_tip, mt_get_node(pos_tip)
end


-- Obtain position of the first kelp unsubmerged.
function kelp.find_unsubmerged(pos, node)

	local x,y,z = pos.x, pos.y, pos.z
	local height = kelp.get_height(node.param2)
	local walk_pos = {x=x, z=z}
	for i=1,height do
		walk_pos.y = y + i
		local walk_node = mt_get_node(walk_pos)
		if mt_get_item_group(walk_node.name, "water") == 0 then
			return walk_pos, walk_node
		end
	end
	return nil
end


-- Obtain next param2.
function kelp.next_param2(param2)
	return param2+16 - param2 % 16
end


-- Grow next kelp.
function kelp.next_grow(pos, node, pos_tip, def_tip, downward_flowing)
	-- Optional parameters
	local pos_tip, def_tip = pos_tip, def_tip
	local downward_flowing = downward_flowing
	if pos_tip == nil and def_tip == nil then
		local node_tip
		pos_tip, node_tip = kelp.get_tip(pos, node)
		def_tip = mt_registered_nodes[node_tip.name]
		downward_flowing = kelp.is_submerged(pos_tip, node_tip)
			and kelp.is_downward_flowing(pos_tip, node_tip, def_tip)
	end

	-- Liquid source: Grow normally.
	local node = table.copy(node)
	node.param2 = kelp.next_param2(node.param2)
	mt_set_node(pos, node)

	-- Flowing liquid: Grow 1 step, but also turn the tip node into a liquid source.
	if downward_flowing then
		local alt_liq = def_tip.liquid_alternative_source
		if alt_liq then
			mt_set_node(pos_tip, {name=alt_liq})
		end
	end
end


-- Naturally grow next kelp.
function kelp.natural_grow(pos, node, age, pos_hash, meta)
	-- Must grow first, then get the new meta
	kelp.next_grow(pos, node)

	-- Optional params
	local meta = meta or mt_get_meta(pos)
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	local age = age + 1
	kelp.age_pool[pos_hash] = age
	meta:set_int("mcl_ocean:kelp_age", age)

end


-- Drops the items for detached kelps.
function kelp.detach_drop(pos, height, pos_hash)
	local pos_hash = pos_hash or mt_hash_node_position(pos) -- Optional params

	if kelp.lock_drop > 0 then
		minetest.log("error",
			string_format("Duplicate drop prevented at (%d, %d, %d) with lock level %d! Please report this.",
				pos.x, pos.y, pos.z, kelp.lock_drop))
		return
	end

	local x,y,z = pos.x,pos.y,pos.z
	for i=1,height do
		mt_add_item({x=x, y=y+i, z=z}, "mcl_ocean:kelp")
	end

	-- Locks drop.
	kelp.lock_drop = kelp.lock_drop + 1
	return true
end


-- Detach the kelp at dig_pos, and drop their items.
-- Synonymous to digging the kelp.
-- NOTE: this is intended for whenever kelp truly becomes segmented plants
-- instead of rooted to the floor. Don't try to remove dig_pos.
function kelp.detach_dig(dig_pos, pos, node, is_drop, pos_hash)
	local pos_hash = pos_hash or mt_hash_node_position(pos)

	local param2 = node.param2
	-- pos.y points to the surface, offset needed to point to the first kelp.
	local new_height = dig_pos.y - (pos.y+1)

	-- Digs the entire kelp: invoke after_dig_node to mt_set_node.
	if new_height <= 0 then
		if is_drop then
			kelp.detach_drop(dig_pos, kelp.get_height(param2), pos_hash)
		end
		mt_set_node(pos, {
			name=mt_registered_nodes[node.name].node_dig_prediction,
			param=node.param, param2=0 })

	-- Digs the kelp beginning at a height
	else
		if is_drop then
			kelp.detach_drop(dig_pos, kelp.get_height(param2) - new_height, pos_hash)
		end
		mt_set_node(pos, {name=node.name, param=node.param, param2=16*new_height})
	end
end


--------------------------------------------------------------------------------
-- Kelp callback functions
--------------------------------------------------------------------------------

-- Set this to drop kelps when
function kelp.surface_on_dig(pos, node, digger)
	kelp.detach_dig(pos, pos, node, true)
end


function kelp.surface_after_dig_node(pos, node)
	return mt_set_node(pos, {name=registred_nodes[node.name].node_dig_prediction})
end


function kelp.surface_on_timer(pos, elapsed)
	local node = mt_get_node(pos)
	local dig_pos = kelp.find_unsubmerged(pos, node)
	local pos_hash = mt_hash_node_position(pos)
	if dig_pos then
		kelp.detach_dig(dig_pos, pos, node, true, pos_hash)
	end

	-- Grow kelp on chance
	if math_random(kelp.RANDOM_DENOMINATOR) - kelp.RANDOM_NUMERATOR < 0 then
		local age = kelp.age_pool[pos_hash]
		if kelp.is_age_growable(age) then
			kelp.natural_grow(pos, node, age, pos_hash)
		end
	end

	return true
end

function kelp.surface_on_destruct(pos)
	local node = mt_get_node(pos)
	local pos_hash = mt_hash_node_position(pos)

	-- on_falling callback. Activated by pistons for falling nodes too.
	if kelp.is_falling(pos, node) then
		kelp.detach_drop(pos, kelp.get_height(node.param2), pos_hash)
	end

	-- Unlocks drops.
	if kelp.lock_drop > 0 then
		kelp.lock_drop = kelp.lock_drop - 1
	end
end


function kelp.surface_on_mvps_move(pos, node, oldpos, nodemeta)
	-- Pistons moving falling nodes will have already activated on_falling callback.
	kelp.detach_dig(pos, pos, node, mt_get_item_group(node.name, "falling_node") ~= 1)
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
function kelp.surface_register_nodetimer(pos, node, pos_hash, meta, age)
	-- Optional params
	local pos_hash,meta,age = pos_hash,meta,age
	local timer = kelp.registered_nodetimers[pos_hash]

	if not timer then
		pos_hash = pos_hash or mt_hash_node_position(pos)

		timer = mt_get_node_timer(pos)
		kelp.registered_nodetimers[pos_hash] = timer

		-- Pool age to avoid meta:get* operations
		meta = meta or mt_get_meta(pos)
		if not age then
			if not meta:contains("mcl_ocean:kelp_age") then
				age = math_random(0, kelp.MAX_AGE-1)
			else
				age = meta:get_int("mcl_ocean:kelp_age")
			end
		end
		kelp.age_pool[pos_hash] = age
		meta:set_int("mcl_ocean:kelp_age", age)
	end

	if not timer:is_started() then
		timer:start(kelp.TIMER_INTERVAL)
	end

	return pos_hash, meta, age
end


-- NOTE: Uncomment this to use ABMs
-- function kelp.grow_abm(pos, node)
-- 	-- Grow kelp by 1 node length if it would grow inside water
-- 	node.param2 = next_param2(node.param2)
-- 	local pos_tip, node_tip = get_tip(pos, node)
-- 	local def_tip = mt_registered_nodes[node_tip.name]
-- 	if is_submerged(node_tip, def_tip) then
-- 		kelp.next_grow(pos, node, pos_tip, def_tip,
-- 			is_downward_flowing(pos_tip, node_tip, def_tip))
-- 	end
-- end


function kelp.kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = mt_get_node(pos_under)
	local nu_name = node_under.name
	local def_under = mt_registered_nodes[nu_name]

	-- Allow rightclick to override place.
	if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
		return def_under.on_rightclick(pos_under, node_under,
				placer, itemstack, pointed_thing) or itemstack
	end

	-- Protection
	if mt_is_protected(pos_under, player_name) or
			mt_is_protected(pos_above, player_name) then
		minetest.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. minetest.pos_to_string(pos_under))
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end


	local pos_tip, node_tip, def_tip
	local pos_hash, meta


	-- Kelp must also be placed on the top/tip side of the surface/kelp
	if pos_under.y >= pos_above.y then
		return itemstack
	end

	-- When placed on kelp.
	if mt_get_item_group(nu_name, "kelp") == 1 then
		pos_tip, node_tip = kelp.get_tip(pos_under, node_under)
		def_tip = mt_registered_nodes[node_tip.name]

		pos_hash = mt_hash_node_position(pos_under)
		meta = mt_get_meta(pos_under)

	-- When placed on surface.
	else
		local new_kelp = false
		for _,surface in pairs(kelp.surfaces) do
			if nu_name == surface.nodename then
				node_under.name = "mcl_ocean:kelp_" ..surface.name
				node_under.param2 = 0
				new_kelp = true
				break
			end
		end
		-- Surface must support kelp
		if not new_kelp then
			return itemstack
		end

		-- NOTE: Uncomment this to use nodetimers
		-- Register nodetimer
		pos_hash, meta = kelp.surface_register_nodetimer(pos_under)

		pos_tip = pos_above
		node_tip = mt_get_node(pos_above)
		def_tip = mt_registered_nodes[node_tip.name]
	end

	-- New kelp must also be submerged in water.
	local downward_flowing = kelp.is_downward_flowing(pos_tip, node_tip, def_tip)
	if not (kelp.is_submerged(node_tip, def_tip) or downward_flowing) then
		return itemstack
	end

	-- Play sound, place surface/kelp and take away an item
	local def_node = mt_registered_items[nu_name]
	if def_node.sounds then
		mt_sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	kelp.next_grow(pos_under, node_under, pos_tip, def_tip, downward_flowing)
	if not mt_is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	-- Reroll age
	local age = math_random(0, kelp.MAX_AGE-1)
	meta:set_int("mcl_ocean:kelp_age", age)
	kelp.age_pool[pos_hash] = age

	return itemstack
end

--------------------------------------------------------------------------------
-- Kelp registration API
--------------------------------------------------------------------------------

-- List of supported surfaces for seagrass and kelp.
kelp.surfaces = {
	{ name="dirt",    nodename="mcl_core:dirt",    },
	{ name="sand",    nodename="mcl_core:sand",    },
	{ name="redsand", nodename="mcl_core:redsand", },
	{ name="gravel",  nodename="mcl_core:gravel",  },
}
kelp.registered_surfaces = {}

-- Commented properties are the ones obtained using register_kelp_surface.
-- If you define your own properties, it overrides the default ones.
kelp.surface_deftemplate = {
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
	after_dig_node = kelp.surface_after_dig_node,
	on_destruct = kelp.surface_on_destruct,
	on_dig = kelp.surface_on_dig,
	on_timer = kelp.surface_on_timer,
	mesecon = { on_mvps_move = kelp.surface_on_mvps_move, },
	drop = "", -- drops are handled in on_dig
	--_mcl_falling_node_alternative = is_falling and nodename or nil,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
}

-- Commented properties are the ones obtained using register_kelp_surface.
kelp.surface_docs = {
	-- entry_id_orig = nodename,
	_doc_items_entry_name = S("Kelp"),
	_doc_items_longdesc = S("Kelp grows inside water on top of dirt, sand or gravel."),
	--_doc_items_create_entry = doc_create,
	_doc_items_image = "mcl_ocean_kelp_item.png",
}

-- Creates new surfaces.
-- NOTE: surface_deftemplate will be modified in-place.
function kelp.register_kelp_surface(surface, surface_deftemplate, surface_docs)
	local name = surface.name
	local nodename = surface.nodename
	local def = mt_registered_nodes[nodename]
	local def_tiles = def.tiles

	local surfacename = "mcl_ocean:kelp_"..name
	local surface_deftemplate = surface_deftemplate or kelp.surface_deftemplate -- Optional param

	local doc_create = surface.doc_create or false
	local surface_docs = surface_docs or kelp.surface_docs -- Optional param

	if doc_create then
		surface_deftemplate._doc_items_entry_name = surface_docs._doc_items_entry_name
		surface_deftemplate._doc_items_longdesc = surface_docs._doc_items_longdesc
		surface_deftemplate._doc_items_create_entry = true
		surface_deftemplate._doc_items_image = surface_docs._doc_items_image
		-- Sets the first surface as the docs' entry ID
		if not surface_docs.entry_id_orig then
			surface_docs.entry_id_orig = nodename
		end
	elseif mod_doc then
		doc.add_entry_alias("nodes", surface_docs.entry_id_orig, "nodes", surfacename)
	end

	local sounds = table.copy(def.sounds)
	sounds.dig = kelp.leaf_sounds.dig
	sounds.dug = kelp.leaf_sounds.dug
	sounds.place = kelp.leaf_sounds.place

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
kelp.register_kelp_surface(kelp.surfaces[1], table.copy(kelp.surface_deftemplate), kelp.surface_docs)
for i=2, #kelp.surfaces do
	kelp.register_kelp_surface(kelp.surfaces[i], table.copy(kelp.surface_deftemplate), kelp.surface_docs)
end

-- Kelp item -------------------------------------------------------------------

minetest.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
	inventory_image = "mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	on_place = kelp.kelp_on_place,
	groups = { deco_block = 1 },
})

if mod_doc then
	doc.add_entry_alias("nodes", kelp.surface_docs.entry_id_orig, "craftitems", "mcl_ocean:kelp")
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

-- NOTE: Uncomment this to use nodetimers
minetest.register_lbm({
	label = "Kelp timer registration",
	name = "mcl_ocean:kelp_timer_registration",
	nodenames = { "group:kelp" },
	run_at_every_load = true, -- so old kelps are also registered
	action = kelp.surface_register_nodetimer,
})

-- NOTE: Uncomment this to use ABMs
-- minetest.register_abm({
-- 	label = "Kelp drops",
-- 	nodenames = { "group:kelp" },
-- 	interval = 1.0,
-- 	chance = 1,
-- 	catch_up = false,
-- 	action = surface_unsubmerged_abm,
-- })
--
-- minetest.register_abm({
-- 	label = "Kelp growth",
-- 	nodenames = { "group:kelp" },
-- 	interval = 45,
-- 	chance = 12,
-- 	catch_up = false,
-- 	action = grow_abm,
-- })
