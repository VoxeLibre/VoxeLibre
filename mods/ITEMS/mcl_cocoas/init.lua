local S = minetest.get_translator(minetest.get_current_modname())

mcl_cocoas = {}

--- Place a cocoa pod.
-- Attempt to place a cocoa pod on a jungle tree.  Checks if attachment
-- point is a jungle tree and sets the correct orientation of the stem.
--
function mcl_cocoas.place(itemstack, placer, pt, plantname)
	-- check if pointing at a node
	if not pt or pt.type ~= "node" then
		return
	end

	-- Handle node right-clicking
	local called
	itemstack, called = mcl_util.handle_node_rightclick(itemstack, placer, pt)
	if called then return itemstack end

	local node = minetest.get_node(pt.under)

	-- return if any of the nodes are not registered
	local def = minetest.registered_nodes[node.name]
	if not def then
		return
	end

	-- Check if pointing at jungle tree
	if node.name ~= "mcl_core:jungletree"
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

--- Grows cocoa pod one size larger.
-- Attempts to grow a cocoa at pos, returns true when grown, returns false
-- if there's no cocoa or it is already at full size.
--
function mcl_cocoas.grow(pos)
	local node = minetest.get_node(pos)
	if node.name == "mcl_cocoas:cocoa_1" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_2", param2 = node.param2})
	elseif node.name == "mcl_cocoas:cocoa_2" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_3", param2 = node.param2})
	else
		return false
	end
	return true
end

-- only caller was mcl_dye, consider converting these into local functions.
local cocoa_place = mcl_cocoas.place
local cocoa_grow = mcl_cocoas.grow

-- Cocoa pod variant definitions.
local podinfo = {
	{
		desc = S("Premature Cocoa Pod"),
		longdesc = S("Cocoa pods grow on the side of jungle trees in 3 stages."),
		n_box = {-0.125, -0.0625, 0.1875, 0.125, 0.25, 0.4375},
		s_box = {-0.125, -0.0625, 0.1875, 0.125, 0.5,  0.5   },
	},
	{
		desc = S("Medium Cocoa Pod"),
		n_box = {-0.1875, -0.1875, 0.0625, 0.1875, 0.25, 0.4375},
		s_box = {-0.1875, -0.1875, 0.0625, 0.1875, 0.5,  0.5   },
	},
	{
		desc = S("Mature Cocoa Pod"),
		longdesc = S("A mature cocoa pod grew on a jungle tree to its full size and it is ready to be harvested for cocoa beans. It won't grow any further."),
		n_box = {-0.25, -0.3125, -0.0625, 0.25, 0.25, 0.4375},
		s_box = {-0.25, -0.3125, -0.0625, 0.25, 0.5,  0.5   },
	},
}

for i = 1, 3 do
	local def = {
		description = podinfo[i].desc,
		_doc_items_create_entry = true,
		_doc_items_longdesc = podinfo[i].longdesc,
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "mesh",
		mesh = "mcl_cocoas_cocoa_stage_"..(i-1)..".obj",
		tiles = {"mcl_cocoas_cocoa_stage_"..(i-1)..".png"},
		use_texture_alpha = "clip",
		collision_box = {
			type = "fixed",
			fixed = podinfo[i].n_box
		},
		selection_box = {
			type = "fixed",
			fixed = podinfo[i].s_box
		},
		groups = {
			handy = 1, axey = 1, attached_node_facedir = 1,
			dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1,
			cocoa = i, not_in_creative_inventory = 1,
		},
		sunlight_propagates = true,
		walkable = true,
		drop = "mcl_cocoas:cocoa_beans",
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = false,
		_mcl_blast_resistance = 3,
		_mcl_hardness = 0.2,
		_on_bone_meal = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.under
			return cocoa_grow(pos)
		end,
	}

	if i == 2 then
		def._doc_items_longdesc = nil
		def._doc_items_create_entry = false
	elseif i == 3 then
		def.drop = "mcl_cocoas:cocoa_beans 3"
		def._on_bone_mealing = nil
	end

	minetest.register_node("mcl_cocoas:cocoa_" .. i, table.copy(def))
end

minetest.register_craftitem("mcl_cocoas:cocoa_beans", {
	inventory_image = "mcl_cocoa_beans.png",
	_tt_help = S("Grows at the side of jungle trees"),
	_doc_items_longdesc = S("Cocoa beans can be used to plant cocoa, bake cookies or craft brown dye."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool brown. Rightclick on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa."),
	description = S("Cocoa Beans"),
	stack_max = 64,
	groups = {
		craftitem = 1, compostability = 65,
	},
	on_place = function(itemstack, placer, pointed_thing)
		return cocoa_place(itemstack, placer, pointed_thing, "mcl_cocoas:cocoa_1")
	end,
})

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
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_cocoas:cocoa_1", "nodes", "mcl_cocoas:cocoa_2")
end
