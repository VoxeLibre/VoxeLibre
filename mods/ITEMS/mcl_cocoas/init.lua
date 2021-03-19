local S = minetest.get_translator("mcl_cocoas")

mcl_cocoas = {}

-- Place cocoa
function mcl_cocoas.place(itemstack, placer, pt, plantname)
	-- check if pointing at a node
	if not pt or pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)

	-- return if any of the nodes are not registered
	if not minetest.registered_nodes[under.name] then
		return
	end

	-- Am I right-clicking on something that has a custom on_rightclick set?
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[under.name] and minetest.registered_nodes[under.name].on_rightclick then
			return minetest.registered_nodes[under.name].on_rightclick(pt.under, under, placer, itemstack) or itemstack
		end
	end

	-- Check if pointing at jungle tree
	if under.name ~= "mcl_core:jungletree"
	or minetest.get_node(pt.above).name ~= "air" then
		return
	end

	-- Determine cocoa direction
	local clickdir = vector.subtract(pt.under, pt.above)

	-- Did user click on the SIDE of a jungle tree?
	if clickdir.y ~= 0 then
		return
	end

	-- Add the node, set facedir and remove 1 item from the itemstack
	minetest.set_node(pt.above, {name = plantname, param2 = minetest.dir_to_facedir(clickdir)})

	minetest.sound_play("default_place_node", {pos = pt.above, gain = 1.0}, true)

	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end

	return itemstack
end

-- Attempts to grow a cocoa at pos, returns true when grown, returns false if there's no cocoa
-- or it is already at full size
function mcl_cocoas.grow(pos)
	local node = minetest.get_node(pos)
	if node.name == "mcl_cocoas:cocoa_1" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_2", param2 = node.param2})
	elseif node.name == "mcl_cocoas:cocoa_2" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_3", param2 = node.param2})
		return true
	end
	return false
end

-- Note: cocoa beans are implemented as mcl_dye:brown

-- Cocoa definition
-- 1st stage

--[[ TODO: Use a mesh for cocoas for perfect texture compability. ]]
local crop_def = {
	description = S("Premature Cocoa Pod"),
	_doc_items_create_entry = true,
	_doc_items_longdesc = S("Cocoa pods grow on the side of jungle trees in 3 stages."),
	drawtype = "nodebox",
	tiles = {
		"[combine:16x16:6,1=mcl_cocoas_cocoa_stage_0.png", "[combine:16x16:6,11=mcl_cocoas_cocoa_stage_0.png",
		"mcl_cocoas_cocoa_stage_0.png", "mcl_cocoas_cocoa_stage_0.png^[transformFX",
		"[combine:16x16:-5,0=mcl_cocoas_cocoa_stage_0.png", "[combine:16x16:-5,0=mcl_cocoas_cocoa_stage_0.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	walkable = true,
	drop = "mcl_dye:brown",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.0625, 0.1875, 0.125, 0.25, 0.4375},  -- Pod
			-- FIXME: This has a thickness of 0. Is this OK in Minetest?
			{0, 0.25, 0.25, 0, 0.5, 0.5},	-- Stem
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.0625, 0.1875, 0.125, 0.25, 0.4375},  -- Pod
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.0625, 0.1875, 0.125, 0.5, 0.5},  -- Pod
		},
	},
	groups = {
		handy=1,axey=1, cocoa=1, not_in_creative_inventory=1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, attached_node_facedir=1,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.2,
}

-- 2nd stage
minetest.register_node("mcl_cocoas:cocoa_1", table.copy(crop_def))

crop_def.description = S("Medium Cocoa Pod")
crop_def._doc_items_create_entry = false
crop_def.groups.cocoa = 2
crop_def.tiles = {
	"[combine:16x16:5,1=mcl_cocoas_cocoa_stage_1.png", "[combine:16x16:5,9=mcl_cocoas_cocoa_stage_1.png",
	"mcl_cocoas_cocoa_stage_1.png", "mcl_cocoas_cocoa_stage_1.png^[transformFX",
	"[combine:16x16:-4,0=mcl_cocoas_cocoa_stage_1.png", "[combine:16x16:-4,0=mcl_cocoas_cocoa_stage_1.png",
}
crop_def.node_box = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.1875, 0.0625, 0.1875, 0.25, 0.4375},  -- Pod
		{0, 0.25, 0.25, 0, 0.5, 0.5},	-- Stem
	},
}
crop_def.collision_box = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.1875, 0.0625, 0.1875, 0.25, 0.4375},  -- Pod
	},
}
crop_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.1875, 0.0625, 0.1875, 0.5, 0.5},
	},
}

minetest.register_node("mcl_cocoas:cocoa_2", table.copy(crop_def))

-- Final stage
crop_def.description = S("Mature Cocoa Pod")
crop_def._doc_items_longdesc = S("A mature cocoa pod grew on a jungle tree to its full size and it is ready to be harvested for cocoa beans. It won't grow any further.")
crop_def._doc_items_create_entry = true
crop_def.groups.cocoa = 3
crop_def.tiles = {
	-- The following 2 textures were derived from the original because the size of the top/bottom is slightly different :-(
	-- TODO: Find a way to *only* use the base texture
	"mcl_cocoas_cocoa_top_stage_2.png", "mcl_cocoas_cocoa_top_stage_2.png^[transformFY",
	"mcl_cocoas_cocoa_stage_2.png", "mcl_cocoas_cocoa_stage_2.png^[transformFX",
	"[combine:16x16:-3,0=mcl_cocoas_cocoa_stage_2.png", "[combine:16x16:-3,0=mcl_cocoas_cocoa_stage_2.png",
}
crop_def.node_box = {
	type = "fixed",
	fixed = {
		{-0.25, -0.3125, -0.0625, 0.25, 0.25, 0.4375},  -- Pod
		{0, 0.25, 0.25, 0, 0.5, 0.5},	-- Stem
	},
}
crop_def.collision_box = {
	type = "fixed",
	fixed = {
		{-0.25, -0.3125, -0.0625, 0.25, 0.25, 0.4375},  -- Pod
	},
}
crop_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.25, -0.3125, -0.0625, 0.25, 0.5, 0.5},
	},
}
crop_def.drop = "mcl_dye:brown 3"
minetest.register_node("mcl_cocoas:cocoa_3", table.copy(crop_def))


minetest.register_abm({
		label = "Cocoa pod growth",
		nodenames = {"mcl_cocoas:cocoa_1", "mcl_cocoas:cocoa_2"},
		-- Same as potatoes
		-- TODO: Tweak/balance the growth speed
		interval = 50,
		chance = 20,
		action = function(pos, node)
			mcl_cocoas.grow(pos)
		end
}	)

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_cocoas:cocoa_1", "nodes", "mcl_cocoas:cocoa_2")
end

