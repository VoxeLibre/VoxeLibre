local S = minetest.get_translator("mcl_lightning_rods")

---@type nodebox
local cbox = {
	type = "fixed",
	fixed = {
		{ -0.0625, -0.5, -0.0625, 0.0625, 0.25, 0.0625 },
		{ -0.125, 0.25, -0.125, 0.125, 0.5, 0.125 },
	},
}

local text_top = "[combine:16x16:6,6=mcl_lightning_rods_rod.png"
local text_side = "[combine:16x16:7,0=mcl_lightning_rods_rod.png:-6,0=mcl_lightning_rods_rod.png\\^[transformR270"

minetest.register_node("mcl_lightning_rods:rod", {
	description = S("Lightning Rod"),
	_doc_items_longdesc = S("A block that attracts lightning"),
	tiles = {
		text_top,
		text_top,
		text_side,
		text_side,
		text_side,
		text_side,
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "opaque",
	groups = { pickaxey = 2, attracts_lightning = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	node_box = cbox,
	selection_box = cbox,
	collision_box = cbox,
	node_placement_prediction = "",
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

	_mcl_blast_resistance = 0,
})

lightning.register_on_strike(function(pos, pos2, objects)
	local lr = minetest.find_node_near(pos, 128, { "group:attracts_lightning" }, true)
	return lr, nil
end)

minetest.register_craft({
	output = "mcl_lightning_rods:rod",
	recipe = {
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
	},
})
