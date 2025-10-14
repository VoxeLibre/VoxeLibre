local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator("mcl_lightning_rods")

mcl_lightning_rods = {}
local mod = mcl_lightning_rods

---@class (partial) core.NodeDef
---@field _on_lightning_strike? fun(pos : vector.Vector, node : core.Node)

dofile(modpath.."/api.lua")

---@type core.NodeBox
local cbox = {
	type = "fixed",
	fixed = {
		{ -0.0625, -0.5, -0.0625, 0.0625, 0.25, 0.0625 },
		{ -0.125, 0.25, -0.125, 0.125, 0.5, 0.125 },
	},
}

---@type core.NodeDef
local rod_def = {
	description = S("Lightning Rod"),
	_doc_items_longdesc = S("A block that attracts lightning"),
	tiles = { "mcl_lightning_rods_rod.png" },
	drawtype = "mesh",
	mesh = "mcl_lightning_rods_rod.obj",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "opaque",
	groups = { pickaxey = 2, attracts_lightning = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	selection_box = cbox,
	collision_box = cbox,
	node_placement_prediction = "",
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.alldirs,
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
	after_place_node = function(pos)
		mod.register_lightning_attractor(pos)
	end,
	after_destruct = function(pos)
		mod.unregister_lightning_attractor(pos)
	end,
	_on_lightning_strike = function(pos, node)
		minetest.set_node(pos, { name = "mcl_lightning_rods:rod_powered", param2 = node.param2 })
		mesecon.receptor_on(pos, mesecon.rules.alldirs)
		minetest.get_node_timer(pos):start(0.4)
	end,

	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
}

minetest.register_node("mcl_lightning_rods:rod", rod_def)

local rod_def_a = table.copy(rod_def)

rod_def_a.tiles = { "mcl_lightning_rods_rod.png^[brighten" }

rod_def_a.groups.not_in_creative_inventory = 1

rod_def_a.mesecons = {
	receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
	},
}

rod_def_a.on_timer = function(pos)
	local node = minetest.get_node(pos)

	if node.name == "mcl_lightning_rods:rod_powered" then --has not been dug
		minetest.set_node(pos, { name = "mcl_lightning_rods:rod", param2 = node.param2 })
		mesecon.receptor_off(pos, mesecon.rules.alldirs)
	end

	return false
end

minetest.register_node("mcl_lightning_rods:rod_powered", rod_def_a)

lightning.register_on_strike(function(pos)
	local lr = mod.find_closest_attractor(pos, 64)
	if not lr then return end

	-- Make sure this possition attracts lightning
	local node = minetest.get_node(lr)
	if minetest.get_item_group(node.name, "attracts_lightning") == 0 then return end

	-- Allow the node to process a lightning strike
	local nodedef = minetest.registered_nodes[node.name]
	if nodedef and nodedef._on_lightning_strike then
		nodedef._on_lightning_strike(lr, node)
	end

	return lr
end)

minetest.register_craft({
	output = "mcl_lightning_rods:rod",
	recipe = {
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
	},
})
minetest.register_lbm({
	name = "mcl_lightning_rods:index_rods",
	nodenames = {"mcl_lightning_rods:rod","mcl_lightning_rods:rod_powered"},
	action = function(pos)
		mod.register_lightning_attractor(pos)
	end
})
