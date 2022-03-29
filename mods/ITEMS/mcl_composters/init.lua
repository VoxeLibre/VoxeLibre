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
	"Composters can convert various organic items into bonemeal."
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

local function composter_add_item(pos, node, player, itemstack, pointed_thing)
	--
	-- handler for filling the composter when rightclicked
	--
	-- as an on_rightclick handler, it returns an itemstack
	--
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	if not itemstack and itemstack:is_empty() then
		return itemstack
	end
	local itemname = itemstack:get_name()
	local chance = get_item_group(itemname, "compostability")
	if chance > 0 then
		if not minetest.is_creative_enabled(player:get_player_name()) then
			itemstack:take_item()
		end
		-- calculate leveling up chance
		local rand = math.random(0,100)
		if chance >= rand then
			-- get current compost level
			local node_defs = minetest.registered_nodes[node.name]
			local level = node_defs["_mcl_compost_level"]
			-- spawn green particles above new layer
			mcl_dye.add_bone_meal_particle(vector.add(pos, vector.new(0, level/8, 0)))
			-- TODO: play some sounds
			-- update composter block
			if level < 7 then
				level = level + 1
			else
				level = "ready"
			end
			minetest.swap_node(pos, {name = "mcl_composters:composter_" .. level})
			-- a full composter becomes ready for harvest after one second
			-- the block will get updated by the node timer callback set in node reg def
			if level == 7 then
				local timer = minetest.get_node_timer(pos)
				timer:start(1)
			end
		end
	end
	return itemstack
end

local function composter_ready(pos)
	--
	-- update the composter block to ready for harvesting
	-- this function is a node callback on_timer.
	-- the timer is set in function 'composter_fill' when composter level is 7
	--
	-- returns false in order to cancel further activity of the timer
	--
	minetest.swap_node(pos, {name = "mcl_composters:composter_ready"})
	-- maybe spawn particles again?
	-- TODO: play some sounds
	return false
end

local function composter_harvest(pos, node, player, itemstack, pointed_thing)
	--
	-- handler for harvesting bone meal from a ready composter when rightclicked
	--
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return
	end
	-- reset ready type composter to empty type
	minetest.swap_node(pos, {name="mcl_composters:composter"})
	-- spawn bone meal item (wtf dye?! is this how they make white cocoa)
	minetest.add_item(pos, "mcl_dye:white")
	-- TODO play some sounds

end

local function composter_get_nodeboxes(level)
	--
	-- Convenience function to construct the nodeboxes for varying levels of compost
	--
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

--
-- Register empty composter node
-- This is the base model that is craftable and can be placed in an inventory
--
minetest.register_node("mcl_composters:composter", {
	description = composter_description,
	_tt_help = S("Converts organic items into bonemeal"),
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
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	is_ground_content = false,
	groups = {
		handy=1, material_wood=1, deco_block=1, dirtifier=1,
		flammable=2, fire_encouragement=3, fire_flammability=4,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.6,
	_mcl_blast_resistance = 0.6,
	_mcl_compost_level = 0,
	on_rightclick = composter_add_item
})

--
-- Template function for composters with compost
-- For each fill level a custom node is registered
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
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		is_ground_content = false,
		groups = {
			handy=1, material_wood=1, deco_block=1, dirtifier=1,
			not_in_creative_inventory=1, not_in_craft_guide=1,
			flammable=2, fire_encouragement=3, fire_flammability=4,
			comparator_signal=level
		},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		drop = "mcl_composters:composter",
		_mcl_hardness = 0.6,
		_mcl_blast_resistance = 0.6,
		_mcl_compost_level = level,
		on_rightclick = composter_add_item,
		on_timer = composter_ready
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "mcl_composters:composter", "nodes", id)
	end
end

--
-- Register filled composters (7 levels)
--
for level = 1, 7 do
	register_filled_composter(level)
end

--
-- Register composter ready to be harvested
--
minetest.register_node("mcl_composters:composter_ready", {
	description = S("Composter") .. "(" .. S("ready for harvest") .. ")",
	_doc_items_create_entry = false,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
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
		comparator_signal=8
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_composters:composter",
	_mcl_hardness = 0.6,
	_mcl_blast_resistance = 0.6,
	_mcl_compost_level = 7,
	on_rightclick = composter_harvest
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_composters:composter", 
		"nodes", "mcl_composters:composter_ready" )
end
