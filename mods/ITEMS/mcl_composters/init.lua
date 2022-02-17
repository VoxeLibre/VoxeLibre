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

local compostability = {
	["mcl_cake:cake"] = 100,
	["mcl_farming:pumpkin_pie"] = 100,

	["mcl_farming:potato_item_baked"] = 85,
	["mcl_farming:bread"] = 85,
	["mcl_farming:cookie"] = 85,
	["mcl_farming:hay_block"] = 85,
	-- mushroom cap block have 64 variants, wtf!?
	["mcl_mushrooms:brown_mushroom_block_cap_111111"] = 85,
	["mcl_mushrooms:red_mushroom_block_cap_111111"] = 85,
	["mcl_nether:nether_wart_block"] = 85,
	["mcl_mushroom:warped_wart_block"] = 85,

	["mcl_core:apple"] = 65,
	-- missing: azalea
	["mcl_farming:beetroot_item"] = 65,
	-- missing: big dripleaf
	["mcl_farming:carrot_item"] = 65,
	-- what's up with cocoa beans?
	["mcl_dye:brown"] = 65,
	["mcl_flowers:fern"] = 65,
	["mcl_flowers:double_fern"] = 65,
	["mcl_flowers:allium"] = 65,
	["mcl_flowers:azure_bluet"] = 65,
	["mcl_flowers:blue_orchid"] = 65,
	["mcl_flowers:dandelion"] = 65,
	["mcl_flowers:lilac"] = 65,
	["mcl_flowers:oxeye_daisy"] = 65,
	["mcl_flowers:poppy"] = 65,
	["mcl_flowers:tulip_orange"] = 65,
	["mcl_flowers:tulip_pink"] = 65,
	["mcl_flowers:tulip_red"] = 65,
	["mcl_flowers:tulip_white"] = 65,
	["mcl_flowers:peony"] = 65,
	["mcl_flowers:rose_bush"] = 65,
	["mcl_flowers:sunflower"] = 65,
	["mcl_flowers:waterlily"] = 65,
	["mcl_farming:melon"] = 65,
	-- missing: moss block?
	-- mushroom aliases below?
	["mcl_farming:mushroom_brown"] = 65,
	["mcl_mushrooms:mushroom_brown"] = 65,
	["mcl_farming:mushroom_red"] = 65,
	["mcl_mushrooms:mushroom_red"] = 65,
	["mcl_mushrooms:brown_mushroom_block_stem_full"] = 65,
	["mcl_mushrooms:red_mushroom_block_stem_full"] = 65,
	-- nether wart
	["mcl_farming:potato_item"] = 65,
	["mcl_farming:pumpkin"] = 65,
	["mcl_farming:pumpkin_face_light"] = 65,
	["mcl_ocean:sea_pickle_"] = 65,
	["mcl_mushroom:shroomlight"] = 65,
	-- missing: spore blossom
	["mcl_farming:wheat_item"] = 65,
	["mcl_mushroom:crimson_fungus"] = 65,
	["mcl_mushroom:warped_fungus"] = 65,
	["mcl_mushroom:crimson_roots"] = 65,
	["mcl_mushroom:warped_roots"] = 65,

	["mcl_core:cactus"] = 50,
	["mcl_ocean:dried_kelp_block"] = 50,
	-- missing: flowering azalea leaves
	-- missing: glow lichen
	["mcl_farming:melon_item"] = 50,
	["mcl_mushroom:nether_sprouts"] = 50,
	["mcl_core:reeds"] = 50,
	["mcl_flowers:double_grass"] = 50,
	["mcl_core:vine"] = 50,
	-- missing: weeping vines
	["mcl_mushroom:twisting_vines"] = 50,

	["mcl_flowers:tallgrass"] = 30,
	["mcl_farming:beetroot_seeds"] = 30,
	["mcl_core:dirt_with_grass"] = 30,
	["mcl_core:tallgrass"] = 30,
	["mcl_ocean:dried_kelp"] = 30,
	["mcl_ocean:kelp"] = 30,
	["mcl_core:leaves"] = 30,
	["mcl_core:acacialeaves"] = 30,
	["mcl_core:birchleaves"] = 30,
	["mcl_core:darkleaves"] = 30,
	["mcl_core:jungleleaves"] = 30,
	["mcl_core:spruceleaves"] = 30,
	--
	["mcl_farming:melon_seeds"] = 30,
	-- missing: moss carpet
	["mcl_farming:pumpkin_seeds"] = 30,
	["mcl_core:sapling"] = 30,
	["mcl_core:acaciasapling"] = 30,
	["mcl_core:birchsapling"] = 30,
	["mcl_core:darksapling"] = 30,
	["mcl_core:junglesapling"] = 30,
	["mcl_core:sprucesapling"] = 30,
	["mcl_ocean:seagrass"] = 30,
	-- missing: small dripleaf
	["mcl_sweet_berry:sweet_berry"] = 30,
	["mcl_farming:sweet_berry"] = 30,
	["mcl_farming:wheat_seeds"] = 30,

}

local function composter_add_item(pos, node, player, itemstack, pointed_thing)
	--
	-- handle filling the composter when rightclicked
	-- as an on_rightclick handles, it returns an itemstack
	--
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	if not itemstack and itemstack:is_empty() then
		return itemstack
	end
	local itemname = itemstack:get_name()
	local chance = compostability[itemname]
	if chance then
		if not minetest.is_creative_enabled(player:get_player_name()) then
			itemstack:take_item()
		end
		-- calculate leveling up chance
		local rand = math.random(0,100)
		if chance >= rand then
			-- get current compost level
			local node_defs = minetest.registered_nodes[node.name]
			local level = node_defs["_compost_level"]
			-- spawn green particles above new layer
			mcl_dye.add_bone_meal_particle(vector.add(pos, {x=0, y=level/8, z=0}))
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
	-- this function is a callback on_timer.
	-- the timer is set in function 'composter_fill' when composter level is 7
	-- returns false in order to cancel further activity of the timer
	--
	minetest.swap_node(pos, {name = "mcl_composters:composter_ready"})
	-- maybe spawn particles again?
	-- TODO: play some sounds
	return false
end

local function composter_harvest(pos, node, player, itemstack, pointed_thing)
	--
	-- handle harvesting bone meal from a ready composter when rightclicked
	--
	if not player or player:get_player_control().sneak then
		return
	end
	-- reset composter to empty
	minetest.swap_node(pos, {name="mcl_composters:composter"})
	-- spawn bone meal item (wtf dye?! is this how the make white cocoa)
	minetest.add_item(pos, "mcl_dye:white")
	-- TODO play some sounds

end

local function composter_get_nodeboxes(level)
	--
	-- Convenience function because the composter nodeboxes are very similar
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
-- Register empty composter
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
	_mcl_hardness = 2,
	_mcl_blast_resistance = 2,
	_compost_level = 0,
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
		_mcl_hardness = 2,
		_mcl_blast_resistance = 2,
		_compost_level = level,
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
	_mcl_hardness = 2,
	_mcl_blast_resistance = 2,
	_compost_level = 7,
	on_rightclick = composter_harvest
})
