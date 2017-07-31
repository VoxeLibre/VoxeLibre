local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}

local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

pp_on_timer = function (pos, elapsed)
	local node   = minetest.get_node(pos)
	local ppspec = minetest.registered_nodes[node.name].pressureplate

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not ppspec then return end

	local objs   = minetest.get_objects_inside_radius(pos, 1)
	local two_below = mesecon:addPosRule(pos, {x = 0, y = -2, z = 0})

	if objs[1] == nil and node.name == ppspec.onstate then
		minetest.add_node(pos, {name = ppspec.offstate})
		mesecon:receptor_off(pos)
		-- force deactivation of mesecon two blocks below (hacky)
		if not mesecon:connected_to_receptor(two_below) then
			mesecon:turnoff(two_below)
		end
	elseif node.name == ppspec.offstate then
		for k, obj in pairs(objs) do
			local objpos = obj:getpos()
			if objpos.y > pos.y-1 and objpos.y < pos.y then
				minetest.add_node(pos, {name=ppspec.onstate})
				mesecon:receptor_on(pos)
				-- force activation of mesecon two blocks below (hacky)
				mesecon:turnon(two_below)
			end
		end
	end
	return true
end

-- Register a Pressure Plate
-- offstate:	name of the pressure plate when inactive
-- onstate:	name of the pressure plate when active
-- description:	description displayed in the player's inventory
-- tiles_off:	textures of the pressure plate when inactive
-- tiles_on:	textures of the pressure plate when active
-- image:	inventory and wield image of the pressure plate
-- recipe:	crafting recipe of the pressure plate
-- sounds:	sound table (like in minetest.register_node)
-- plusgroups:	group memberships (attached_node=1 and not_in_creative_inventory=1 are already used)

function mesecon:register_pressure_plate(offstate, onstate, description, texture_off, texture_on, recipe, sounds, plusgroups)
	local ppspec = {
		offstate = offstate,
		onstate  = onstate
	}

	local groups_off = table.copy(plusgroups)
	groups_off.attached_node = 1
	groups_off.dig_by_piston = 1

	minetest.register_node(offstate, {
		drawtype = "nodebox",
		tiles = {texture_off},
		wield_image = texture_off,
		wield_scale = { x=1, y=1, z=0.5 },
		paramtype = "light",
		sunlight_propagates = true,
		selection_box = pp_box_off,
		node_box = pp_box_off,
		groups = groups_off,
		is_ground_content = false,
	    	description = description,
		_doc_items_longdesc = "A pressure plate is a redstone component which supplies its surrounding blocks with redstone power while someone or something rests on top of it.",
		pressureplate = ppspec,
		on_timer = pp_on_timer,
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.off
		}},
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory = 1

	minetest.register_node(onstate, {
		drawtype = "nodebox",
		tiles = {texture_on},
		wield_image = texture_on,
		wield_scale = { x=1, y=1, z=0.25 },
		paramtype = "light",
		sunlight_propagates = true,
		selection_box = pp_box_on,
		node_box = pp_box_on,
		groups = groups_on,
		is_ground_content = false,
		drop = offstate,
		pressureplate = ppspec,
		on_timer = pp_on_timer,
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.on
		}},
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		after_dig_node = function(pos)
			local two_below = mesecon:addPosRule(pos, {x = 0, y = -2, z = 0})
			if not mesecon:connected_to_receptor(two_below) then
				mesecon:turnoff(two_below)
			end
		end,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_craft({
		output = offstate,
		recipe = recipe,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", offstate, "nodes", onstate)
	end
end

mesecon:register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_wood_off",
	"mesecons_pressureplates:pressure_plate_wood_on",
	"Wooden Pressure Plate",
	"default_wood.png",
	"default_wood.png",
	{{"group:wood", "group:wood"}},
	mcl_sounds.node_sound_wood_defaults(),
	{axey=1, material_wood=1})

mesecon:register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_stone_off",
	"mesecons_pressureplates:pressure_plate_stone_on",
	"Stone Pressure Plate",
	"default_stone.png",
	"default_stone.png",
	{{"mcl_core:stone", "mcl_core:stone"}},
	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_pressureplates:pressure_plate_wood_off",
	burntime = 15
})

