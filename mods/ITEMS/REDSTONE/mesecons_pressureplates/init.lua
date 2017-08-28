local PRESSURE_PLATE_INTERVAL = 0.04

local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}

local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

local function pp_on_timer(pos, elapsed)
	local node = minetest.get_node(pos)
	local basename = minetest.registered_nodes[node.name].pressureplate_basename

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not basename then return end

	local objs   = minetest.get_objects_inside_radius(pos, 1)
	local two_below = vector.add(pos, vector.new(0, -2, 0))

	if objs[1] == nil and node.name == basename .. "_on" then
		minetest.set_node(pos, {name = basename .. "_off"})
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	elseif node.name == basename .. "_off" then
		for k, obj in pairs(objs) do
			local objpos = obj:getpos()
			if objpos.y > pos.y-1 and objpos.y < pos.y then
				minetest.set_node(pos, {name = basename .. "_on"})
				mesecon.receptor_on(pos, mesecon.rules.pplate )
			end
		end
	end
	return true
end

-- Register a Pressure Plate
-- basename:    base name of the pressure plate
-- description:	description displayed in the player's inventory
-- textures_off:textures of the pressure plate when inactive
-- textures_on:	textures of the pressure plate when active
-- image_w:	wield image of the pressure plate
-- image_i:	inventory image of the pressure plate
-- recipe:	crafting recipe of the pressure plate
-- sounds:	sound table (like in minetest.register_node)
-- plusgroups:	group memberships (attached_node=1 and not_in_creative_inventory=1 are already used)

function mesecon.register_pressure_plate(basename, description, textures_off, textures_on, image_w, image_i, recipe, sounds, plusgroups)
	local groups_off = table.copy(plusgroups)
	groups_off.attached_node = 1
	groups_off.dig_by_piston = 1
	groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory = 1

	mesecon.register_node(basename, {
		drawtype = "nodebox",
		inventory_image = image_i,
		wield_image = image_w,
		paramtype = "light",
	    	description = description,
		on_timer = pp_on_timer,
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		sounds = sounds,

		pressureplate_basename = basename,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	},{
		node_box = pp_box_off,
		selection_box = pp_box_off,
		groups = groups_off,
		tiles = textures_off,

		mesecons = {receptor = { state = mesecon.state.off, rules = mesecon.rules.pplate }},
		_doc_items_longdesc = "A pressure plate is a redstone component which supplies its surrounding blocks with redstone power while someone or something rests on top of it.",
	},{
		node_box = pp_box_on,
		selection_box = pp_box_on,
		groups = groups_on,
		tiles = textures_on,

		mesecons = {receptor = { state = mesecon.state.on, rules = mesecon.rules.pplate }},
	})

	minetest.register_craft({
		output = basename .. "_off",
		recipe = recipe,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", basename .. "_off", "nodes", basename .. "_on")
	end
end

mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_wood",
	"Wooden Pressure Plate",
	{"default_wood.png"},
	{"default_wood.png"},
	"default_wood.png",
	nil,
	{{"group:wood", "group:wood"}},
	mcl_sounds.node_sound_wood_defaults(),
	{axey=1, material_wood=1})

mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_stone",
	"Stone Pressure Plate",
	{"default_stone.png"},
	{"default_stone.png"},
	"default_stone.png",
	nil,
	{{"mcl_core:stone", "mcl_core:stone"}},
	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_pressureplates:pressure_plate_wood_off",
	burntime = 15
})

