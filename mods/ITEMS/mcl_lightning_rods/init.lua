local S = minetest.get_translator("mobs_mc")

local cbox = {
	type = "fixed",
	fixed = {
		{ 0/16, -8/16, 0/16,  2/16, 4/16,  2/16 },
		{ 0/16, 4/16, 0/16,  3/16,  8/16,  3/16 },
	}
}

minetest.register_node("mcl_lightning_rods:rod", {
	description = S("Lightning Rod"),
	_doc_items_longdesc = S("A block that attracts lightning"),
	--inventory_image = "mcl_lightning_rods_rod_inv.png",
	tiles = {
		"mcl_lightning_rods_rod.png",
		"mcl_lightning_rods_rod.png",
		"mcl_lightning_rods_rod.png",
		"mcl_lightning_rods_rod.png",
		"mcl_lightning_rods_rod.png",
		"mcl_lightning_rods_rod.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {pickaxey=2,attracts_lightning=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	node_box = cbox,
	selection_box = cbox,
	collision_box = cbox,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
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

	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 0,
})

lightning.register_on_strike(function(pos,pos2,objects)
	local lr = minetest.find_node_near(pos,128,{"group:attracts_lightning"},true)
	return lr,nil
end)
