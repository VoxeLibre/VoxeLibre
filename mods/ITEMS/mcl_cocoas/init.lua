mcl_cocoas = {}

-- Place cocoa
function mcl_cocoas.place(itemstack, placer, pointed_thing, plantname)

	local pt = pointed_thing

	-- check if pointing at a node
	if not pt or pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)

	-- return if any of the nodes are not registered
	if not minetest.registered_nodes[under.name] then
		return
	end

	-- am I right-clicking on something that has a custom on_place set?
	-- thanks to Krock for helping with this issue :)
	local def = minetest.registered_nodes[under.name]
	if def and def.on_rightclick then
		return def.on_rightclick(pt.under, under, placer, itemstack)
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

	minetest.sound_play("default_place_node", {pos = pt.above, gain = 1.0})

	if not minetest.setting_getbool("creative_mode") then
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
local crop_def = {
	description = "Young Cocoa",
	drawtype = "nodebox",
	tiles = {
		"[combine:32x32:12,2=mcl_cocoas_cocoa_stage_0.png", "[combine:32x32:12,22=mcl_cocoas_cocoa_stage_0.png",
		"mcl_cocoas_cocoa_stage_0.png", "mcl_cocoas_cocoa_stage_0.png^[transformFX",
		"[combine:32x32:-10,0=mcl_cocoas_cocoa_stage_0.png", "[combine:32x32:-10,0=mcl_cocoas_cocoa_stage_0.png",
	},
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
		choppy=3, not_in_creative_inventory=1, dig_by_water = 1,
	},
	sounds = mcl_sounds.node_sound_wood_defaults()
}

-- 2nd stage
minetest.register_node("mcl_cocoas:cocoa_1", table.copy(crop_def))

crop_def.description = "Medium Cocoa"
crop_def.tiles = {
	"[combine:32x32:10,2=mcl_cocoas_cocoa_stage_1.png", "[combine:32x32:10,18=mcl_cocoas_cocoa_stage_1.png",
	"mcl_cocoas_cocoa_stage_1.png", "mcl_cocoas_cocoa_stage_1.png^[transformFX",
	"[combine:32x32:-8,0=mcl_cocoas_cocoa_stage_1.png", "[combine:32x32:-8,0=mcl_cocoas_cocoa_stage_1.png",
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
crop_def.description = "Mature Cocoa"
crop_def.tiles = {
	-- The following 2 textures were derived from the original because the size of the top/bottom is slightly different :-(
	-- TODO: Find a way to *only* use the base texture
	"mcl_cocoas_cocoa_top_stage_2.png", "mcl_cocoas_cocoa_top_stage_2.png^[transformFY",
	"mcl_cocoas_cocoa_stage_2.png", "mcl_cocoas_cocoa_stage_2.png^[transformFX",
	"[combine:32x32:-6,0=mcl_cocoas_cocoa_stage_2.png", "[combine:32x32:-6,0=mcl_cocoas_cocoa_stage_2.png",
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
crop_def.drop = "mcl_dye:brown 3",
minetest.register_node("mcl_cocoas:cocoa_3", table.copy(crop_def))

-- Add random cocoa pods to jungle trees

-- TODO: Do this more efficiently, with LuaVoxelManip
minetest.register_on_generated(function(minp, maxp)

	if maxp.y < 0 then
		return
	end

	local pos, treepos, dir
	local cocoa = minetest.find_nodes_in_area(minp, maxp, "mcl_core:jungletree")

	for n = 1, #cocoa do

		pos = cocoa[n]
		treepos = table.copy(pos)

		if minetest.find_node_near(pos, 1, {"mcl_core:jungleleaves"}) then

			dir = math.random(1, 40)

			if dir == 1 then
				pos.z = pos.z + 1
			elseif dir == 2 then
				pos.z = pos.z - 1
			elseif dir == 3 then
				pos.x = pos.x + 1
			elseif dir == 4 then
				pos.x = pos.x -1
			end

			local nn = minetest.get_node(pos).name

			if dir < 5
			and nn == "air"
			and minetest.get_node_light(pos) > 12 then
				minetest.swap_node(pos, {
					name = "mcl_cocoas:cocoa_" .. tostring(math.random(1, 3)),
					param2 = minetest.dir_to_facedir(vector.subtract(treepos, pos))
				})
			end

		end
	end
end)

minetest.register_abm({
		nodenames = {"mcl_cocoas:cocoa_1", "mcl_cocoas:cocoa_2"},
		-- Same as potatoes
		-- TODO: Tweak/balance the growth speed
		interval = 50,
		chance = 20,
		action = function(pos, node)
			mcl_cocoas.grow(pos)
		end
}	)

