local S = minetest.get_translator(minetest.get_current_modname())

--
-- Composter mod, adds composters.
--
-- Copyleft 2022 by kabou
-- GNU General Public Licence 3.0
--

local composter_description = S(
	"Composter"
)
local composter_longdesc = S(
	"Composters can convert various organic items into bone meal."
)
local composter_usagehelp = S(
	"Use organic items on the composter to fill it with layers of compost. " ..
	"Every time an item is put in the composter, there is a chance that the " ..
	"composter adds another layer of compost.  Some items have a bigger chance " ..
	"of adding an extra layer than other items.  After filling up with 7 layers " ..
	"of compost, the composter is full.  After a delay of approximately one " ..
	"second the composter becomes ready and bone meal can be retrieved from it. " ..
	"Right-clicking the composter takes out the bone meal empties the composter."
)

minetest.register_craft({
	output = "mcl_composters:composter",
	recipe = {
		{"group:wood_slab", "", "group:wood_slab"},
		{"group:wood_slab", "", "group:wood_slab"},
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_composters:composter",
	burntime = 15,
})

local get_item_group = minetest.get_item_group
local is_creative_enabled = minetest.is_creative_enabled
local registered_nodes = minetest.registered_nodes
local set_node = core.set_node
local get_node_timer = minetest.get_node_timer
local add_item = minetest.add_item
local vector_offset = vector.offset
local is_protected = minetest.is_protected
local record_protection_violation = minetest.record_protection_violation

--- Math and node swap during compost progression
---@param pos Vector Position of the node
---@param node node
---@param chance integer Value of "compostability" group of inserted item
local function composter_progress_chance(pos, node, chance)
	-- calculate leveling up chance
	local rand = math.random(0,100)
	if chance >= rand then
		-- get current compost level
		local level = registered_nodes[node.name]["_mcl_compost_level"]
		-- spawn green particles above new layer
		mcl_bone_meal.add_bone_meal_particle(vector_offset(pos, 0, level/8, 0))
		-- update composter block
		if level < 7 then
			level = level + 1
		else
			level = "ready"
		end
		set_node(pos, {name = "mcl_composters:composter_" .. level})
		minetest.sound_play({name="default_grass_footstep", gain=0.4}, {
			pos = pos,
			gain= 0.4,
			max_hear_distance = 16,
		}, true)
		-- a full composter becomes ready for harvest after one second
		-- the block will get updated by the node timer callback set in node reg def
		if level == 7 then
			local timer = get_node_timer(pos)
			if not timer:is_started() then
				timer:start(1)
			end
		end
	end
end

--- Fill the composter when rightclicked.
--
-- `on_rightclick` handler for composter blocks of all fill levels except
-- for the "ready" composter (see: composter_harvest).
-- If the item used on the composter block is compostable, there is a chance
-- that the level of the composter may increase, depending on the value of
-- compostability of the item.
--
-- parameters are the standard parameters passed to `on_rightclick`.
-- returns the remaining itemstack.
--
local function composter_add_item(pos, node, player, itemstack, pointed_thing)
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	local name = player:get_player_name()
	if is_protected(pos, name) then
		record_protection_violation(pos, name)
		return itemstack
	end
	if not itemstack or itemstack:is_empty() then
		return itemstack
	end
	local itemname = itemstack:get_name()
	local chance = get_item_group(itemname, "compostability")
	if chance > 0 then
		if not is_creative_enabled(player:get_player_name()) then
			itemstack:take_item()
			minetest.sound_play({name="default_gravel_dug", gain=1}, {
				pos = pos,
				max_hear_distance = 16,
			}, true)
		end
		composter_progress_chance(pos, node, chance)
	end
	return itemstack
end

--- Update a full composter block to ready for harvesting.
--
-- `on_timer` handler. The timer is set in function 'composter_add_item'
-- when the composter level has reached 7.
--
-- pos: position of the composter block.
-- returns false, thereby cancelling further activity of the timer.
--
local function composter_ready(pos)
	set_node(pos, {name = "mcl_composters:composter_ready"})
	-- maybe spawn particles again?
	minetest.sound_play({name="default_dig_snappy", gain=1}, {
		pos = pos,
		max_hear_distance = 16,
	}, true)
	return false
end

--- Spawn bone meal item and reset composter block.
--
-- `on_rightclick` handler for the "ready" composter block.  Causes a
-- bone meal item to be spawned from the composter and resets the
-- composter block to an empty composter block.
--
-- parameterss are the standard parameters passed to `on_rightclick`.
-- returns itemstack (unchanged in this function).
--
local function composter_harvest(pos, node, player, itemstack, pointed_thing)
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	local name = player:get_player_name()
	if is_protected(pos, name) then
		record_protection_violation(pos, name)
		return itemstack
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	--remove bone meal from internal inventory
	inv:set_stack("dst", 1, ItemStack())
	-- reset ready type composter to empty type
	set_node(pos, {name="mcl_composters:composter"})
	-- spawn bone meal item
	add_item(pos, "mcl_bone_meal:bone_meal")
	-- TODO play some sounds
	return itemstack
end

--- Construct composter nodeboxes with varying levels of compost.
--
-- level: compost level in the composter
-- returns a nodebox definition table.
--
local function composter_get_nodeboxes(level)
	local top_y_tbl = {[0]=-7, -5, -3, -1, 1, 3, 5, 7}
	local top_y = top_y_tbl[level] / 16
	return {
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   top_y, 0.5},   -- Bottom level
		}
	}
end

local function hopper_push_condition(stack)
	local chance = get_item_group(stack:get_name(), "compostability")
	if chance > 0 then
		return true
	end
	return false
end

--- Register empty composter node.
--
-- This is the craftable base model that can be placed in an inventory.
--
minetest.register_node("mcl_composters:composter", {
	description = composter_description,
	_tt_help = S("Converts organic items into bone meal"),
	_doc_items_longdesc = composter_longdesc,
	_doc_items_usagehelp = composter_usagehelp,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = composter_get_nodeboxes(0),
	selection_box = {type = "regular"},
	tiles = {
		"mcl_composter_bottom.png^mcl_composter_top.png",
		"mcl_composter_bottom.png",
		"mcl_composter_side.png"
	},
	is_ground_content = false,
	groups = {
		handy=1, material_wood=1, deco_block=1, dirtifier=1,
		flammable=2, fire_encouragement=3, fire_flammability=4,
		container = 2
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.6,
	_mcl_blast_resistance = 0.6,
	_mcl_compost_level = 0,
	on_rightclick = composter_add_item,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("src", 1)
		inv:set_size("dst", 1)
	end,
	_mcl_hoppers_on_try_pull = function(pos, hop_pos, hop_inv, hop_list)
		return nil, nil, nil
	end,
	_mcl_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv, "src", mcl_util.select_stack(hop_inv, hop_list, inv, "src", hopper_push_condition, 1)
	end,
	_mcl_hoppers_on_after_push = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("src", 1)
		if not stack:is_empty() then
			local chance = get_item_group(stack:get_name(), "compostability")
			if chance > 0 then
				local node = minetest.get_node(pos)
				composter_progress_chance(pos, node, chance)
			end
		end
		inv:remove_item("src", stack)
	end,
})

--- Template function for composters with compost.
--
-- For each fill level a custom node is registered.
--
local function register_filled_composter(level)
	local id = "mcl_composters:composter_"..level
	minetest.register_node(id, {
		description = S("Composter") .. " (" .. level .. "/7 " .. S("filled") .. ")",
		_doc_items_create_entry = false,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = composter_get_nodeboxes(level),
		selection_box = {type = "regular"},
		tiles = {
			"mcl_composter_compost.png^mcl_composter_top.png",
			"mcl_composter_bottom.png",
			"mcl_composter_side.png"
		},
		is_ground_content = false,
		groups = {
			handy=1, material_wood=1, deco_block=1, dirtifier=1,
			not_in_creative_inventory=1, not_in_craft_guide=1,
			flammable=2, fire_encouragement=3, fire_flammability=4,
			comparator_signal=level, container = 2
		},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		drop = "mcl_composters:composter",
		_mcl_hardness = 0.6,
		_mcl_blast_resistance = 0.6,
		_mcl_compost_level = level,
		on_rightclick = composter_add_item,
		on_timer = composter_ready,
		_mcl_hoppers_on_try_pull = function(pos, hop_pos, hop_inv, hop_list)
			return nil, nil, nil
		end,
		_mcl_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv, "src", mcl_util.select_stack(hop_inv, hop_list, inv, "src", hopper_push_condition, 1)
		end,
		_mcl_hoppers_on_after_push = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack("src", 1)
			if not stack:is_empty() then
				local chance = get_item_group(stack:get_name(), "compostability")
				if chance > 0 then
					local node = minetest.get_node(pos)
					composter_progress_chance(pos, node, chance)
				end
			end
			inv:remove_item("src", stack)
		end,
		_mcl_comparator_get_reading = level
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "mcl_composters:composter", "nodes", id)
	end
end

--- Register filled composters (7 levels).
--
for level = 1, 7 do
	register_filled_composter(level)
end

--- Register composter that is ready to be harvested.
--
minetest.register_node("mcl_composters:composter_ready", {
	description = S("Composter") .. "(" .. S("ready for harvest") .. ")",
	_doc_items_create_entry = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = composter_get_nodeboxes(7),
	selection_box = {type = "regular"},
	tiles = {
		"mcl_composter_ready.png^mcl_composter_top.png",
		"mcl_composter_bottom.png",
		"mcl_composter_side.png"
	},
	is_ground_content = false,
	groups = {
		handy=1, material_wood=1, deco_block=1, dirtifier=1,
		not_in_creative_inventory=1, not_in_craft_guide=1,
		flammable=2, fire_encouragement=3, fire_flammability=4,
		comparator_signal=8, container = 2
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_composters:composter",
	_mcl_hardness = 0.6,
	_mcl_blast_resistance = 0.6,
	_mcl_compost_level = 7,
	on_rightclick = composter_harvest,
	_mcl_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
		return nil, nil, nil
	end,
	_mcl_hoppers_on_try_pull = function(pos, hop_pos, hop_inv, hop_list)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		--remove bone meal from internal inventory
		inv:set_stack("dst", 1, ItemStack())
		inv:add_item("dst", "mcl_bone_meal:bone_meal")
		local stack = inv:get_stack("dst", 1)
		if not stack:is_empty() and hop_inv:room_for_item(hop_list, stack) then
			return inv, "dst", 1
		end
		return nil, nil, nil
	end,
	_mcl_hoppers_on_after_pull = function(pos)
		set_node(pos, {name = "mcl_composters:composter"})
	end,
	_mcl_comparator_get_reading = 8,
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_composters:composter",
		"nodes", "mcl_composters:composter_ready" )
end
