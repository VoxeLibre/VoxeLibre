local init = os.clock()
mcl_doors = {}

-- Registers a door
--  name: The name of the door
--  def: a table with the folowing fields:
--    description
--    inventory_image
--    groups
--    tiles_bottom: the tiles of the bottom part of the door {front, side}
--    tiles_top: the tiles of the bottom part of the door {front, side}
--    If the following fields are not defined the default values are used
--    node_box_bottom
--    node_box_top
--    selection_box_bottom
--    selection_box_top
--    only_placer_can_open: if true only the player who placed the door can
--                          open it
--    only_redstone_can_open: if true, the door can only be opened by redstone,
--                            not by rightclicking it

function mcl_doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	def.groups.dig_by_piston = 1

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end
	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	local box = {{-8/16, -8/16, -8/16, 8/16, 8/16, -5/16}}

	if not def.node_box_bottom then
		def.node_box_bottom = box
	end
	if not def.node_box_top then
		def.node_box_top = box
	end
	if not def.selection_box_bottom then
		def.selection_box_bottom= box
	end
	if not def.selection_box_top then
		def.selection_box_top = box
	end

	local longdesc, usagehelp
	longdesc = def._doc_items_longdesc
	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = "This door is a 2-block high barrier which can be opened or closed by hand or by redstone power."
		else
			longdesc = "This door is a 2-block high barrier which can only be opened by redstone power, not by hand."
		end
	end
	usagehelp = def._doc_items_usagehelp
	if not usagehelp then
		if def.only_redstone_can_open then
			usagehelp = "To open or close this door, send a redstone signal to its bottom half."
		else
			usagehelp = "To open or close this door, rightclick it or send a redstone signal to its bottom half."
		end
	end

	minetest.register_craftitem(name, {
		description = def.description,
		_doc_items_longdesc = def._doc_items_longdesc,
		_doc_items_usagehelp = def._doc_items_usagehelp,
		inventory_image = def.inventory_image,
		stack_max = 64,
		groups = { mesecon_conductor_craftable = 1 },
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end
			local pn = placer:get_player_name()
				if minetest.is_protected(pointed_thing.above, pn) and minetest.is_protected(pointed_thing.under, pn) then
					return itemstack
				end
					local ptu = pointed_thing.under
					local nu = minetest.get_node(ptu)
					if minetest.registered_nodes[nu.name].on_rightclick then
						return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
					end

					local pt = pointed_thing.above
					local pt2 = {x=pt.x, y=pt.y, z=pt.z}
					pt2.y = pt2.y+1
					if
						not minetest.registered_nodes[minetest.get_node(pt).name].buildable_to or
						not minetest.registered_nodes[minetest.get_node(pt2).name].buildable_to or
						not placer or
						not placer:is_player()
					then
						return itemstack
					end

					local p2 = minetest.dir_to_facedir(placer:get_look_dir())
					local pt3 = {x=pt.x, y=pt.y, z=pt.z}
					if p2 == 0 then
						pt3.x = pt3.x-1
					elseif p2 == 1 then
						pt3.z = pt3.z+1
					elseif p2 == 2 then
						pt3.x = pt3.x+1
					elseif p2 == 3 then
						pt3.z = pt3.z-1
					end
					if not string.find(minetest.get_node(pt3).name, name.."_b_") then
						minetest.set_node(pt, {name=name.."_b_1", param2=p2})
						minetest.set_node(pt2, {name=name.."_t_1", param2=p2})
					else
						minetest.set_node(pt, {name=name.."_b_2", param2=p2})
						minetest.set_node(pt2, {name=name.."_t_2", param2=p2})
					end
					if def.sounds and def.sounds.place then
						minetest.sound_play(def.sounds.place, {pos=pt})
					end

					if def.only_placer_can_open then
						local meta = minetest.get_meta(pt)
						meta:set_string("doors_owner", "")
						meta = minetest.get_meta(pt2)
						meta:set_string("doors_owner", "")
					end

					-- Save open state. 1 = open. 0 = closed
					local meta = minetest.get_meta(pt)
					meta:set_int("is_open", 0)
					meta = minetest.get_meta(pt2)
					meta:set_int("is_open", 0)

					if not minetest.setting_getbool("creative_mode") then
						itemstack:take_item()
					end
				return itemstack
		end,
	})

	local tt = def.tiles_top
	local tb = def.tiles_bottom

	local function after_dig_node(pos, name, digger)
		local node = minetest.get_node(pos)
		if node.name == name then
			minetest.node_dig(pos, node, digger)
		end
	end

	local function on_open_close(pos, dir, check_name, replace, replace_dir, params)
		local meta1 = minetest.get_meta(pos)
		pos.y = pos.y+dir
		local meta2 = minetest.get_meta(pos)
		if not minetest.get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.get_node(pos).param2
		local np2 = params[p2+1]

		local metatable = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace_dir, param2=np2})
		minetest.get_meta(pos):from_table(metatable)

		pos.y = pos.y-dir
		metatable = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace, param2=np2})
		minetest.get_meta(pos):from_table(metatable)

		local door_switching_sound
		if meta1:get_int("is_open") == 1 then
			door_switching_sound = def.sound_close
			meta1:set_int("is_open", 0)
			meta2:set_int("is_open", 0)
		else
			door_switching_sound = def.sound_open
			meta1:set_int("is_open", 1)
			meta2:set_int("is_open", 1)
		end
		minetest.sound_play(door_switching_sound, {pos = pos, gain = 0.5, max_hear_distance = 16})
	end

	local function on_mesecons_signal_open (pos, node)
		on_open_close(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
	end

	local function on_mesecons_signal_close (pos, node)
		on_open_close(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
	end

	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then
			return true
		end
		local meta = minetest.get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end

	local on_rightclick
	-- Disable on_rightclick if this is a redstone-only door
	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node_clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
			end
		end
	end

	minetest.register_node(name.."_b_1", {
		tiles = {tt[2].."^[transformFY", tt[2], tb[2].."^[transformFX", tb[2], tb[1], tb[1].."^[transformFX"},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_1", digger)
		end,

		on_rightclick = on_rightclick,

		mesecons = { effector = {
			action_on = on_mesecons_signal_open
		}},

		can_dig = check_player_priv,
	})

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node_clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
			end
		end
	end

	minetest.register_node(name.."_t_1", {
		tiles = {tt[2].."^[transformFY", tt[2], tt[2].."^[transformFX", tt[2], tt[1], tt[1].."^[transformFX"},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_1", digger)
		end,

		on_rightclick = on_rightclick,

		can_dig = check_player_priv,
	})

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node_clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
			end
		end
	end

	minetest.register_node(name.."_b_2", {
		tiles = {tt[2].."^[transformFY", tt[2], tb[2].."^[transformFX", tb[2], tb[1].."^[transformFX", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_2", digger)
		end,

		on_rightclick = on_rightclick,

		mesecons = { effector = {
			action_on = on_mesecons_signal_close
		}},

		can_dig = check_player_priv,
	})

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node_clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
			end
		end
	end

	minetest.register_node(name.."_t_2", {
		tiles = {tt[2].."^[transformFY", tt[2], tt[2].."^[transformFX", tt[2], tt[1].."^[transformFX", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_2", digger)
		end,

		on_rightclick = on_rightclick,

		can_dig = check_player_priv,
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_1")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_2")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_1")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_2")
	end

end

local wood_longdesc = "Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."
local wood_usagehelp = "To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."

--- Normal Door ---
mcl_doors:register_door("mcl_doors:wooden_door", {
	description = "Oak Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_wood.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_wood_b.png", "door_wood_b.png"},
	tiles_top = {"door_wood_a.png", "door_wood_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:wooden_door 3",
	recipe = {
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"}
	}
})

--- Accacia Door --
mcl_doors:register_door("mcl_doors:acacia_door", {
	description = "Acacia Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_acacia.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_acacia_b.png", "door_acacia_b.png"},
	tiles_top = {"door_acacia_a.png", "door_acacia_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:acacia_door 3",
	recipe = {
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"}
	}
})

--- birch Door --
mcl_doors:register_door("mcl_doors:birch_door", {
	description = "Birch Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_birch.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_birch_b.png", "door_birch_b.png"},
	tiles_top = {"door_birch_a.png", "door_birch_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:birch_door 3",
	recipe = {
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
	}
})

--- dark oak Door --
mcl_doors:register_door("mcl_doors:dark_oak_door", {
	description = "Dark Oak Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_dark_oak.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_dark_oak_b.png", "door_dark_oak_b.png"},
	tiles_top = {"door_dark_oak_a.png", "door_dark_oak_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:dark_oak_door 3",
	recipe = {
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
	}
})

--- jungle Door --
mcl_doors:register_door("mcl_doors:jungle_door", {
	description = "Jungle Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_jungle.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_jungle_b.png", "door_jungle_b.png"},
	tiles_top = {"door_jungle_a.png", "door_jungle_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:jungle_door 3",
	recipe = {
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"}
	}
})

--- spruce Door --
mcl_doors:register_door("mcl_doors:spruce_door", {
	description = "Spruce Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_spruce.png",
	groups = {handy=1,axey=1, door=1, material_wood=1},
	_mcl_hardness = 3,
	tiles_bottom = {"door_spruce_b.png", "door_spruce_b.png"},
	tiles_top = {"door_spruce_a.png", "door_spruce_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:spruce_door 3",
	recipe = {
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:wooden_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:jungle_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:dark_oak_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:birch_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:acacia_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:spruce_door",
	burntime = 10,
})

--- Door in Iron ---
mcl_doors:register_door("mcl_doors:iron_door", {
	description = "Iron Door",
	_doc_items_longdesc = "Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand.",
	_doc_items_usagehelp = "To open or close an iron door, supply its lower half with a redstone signal.",
	inventory_image = "door_steel.png",
	groups = {pickaxey=1, door=1,mesecon_effector_on=1},
	_mcl_hardness = 5,
	tiles_bottom = {"door_steel_b.png^[transformFX", "door_steel_b.png^[transformFX"},
	tiles_top = {"door_steel_a.png^[transformFX", "door_steel_a.png^[transformFX"},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_door 3",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"}
	}
})

---- Trapdoor ----

function mcl_doors:register_trapdoor(name, def)
	local function update_door(pos, node) 
		minetest.set_node(pos, node)
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end
	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	local function punch(pos)
		local meta = minetest.get_meta(pos)
		local state = meta:get_int("state")
		local me = minetest.get_node(pos)
		local tmp_node
		local tmp_node2
		local oben = {x=pos.x, y=pos.y+1, z=pos.z}
		if state == 1 then
			state = 0
			minetest.sound_play(def.sound_close, {pos = pos, gain = 0.3, max_hear_distance = 16})
			tmp_node = {name=name, param1=me.param1, param2=me.param2}
		else
			state = 1
			minetest.sound_play(def.sound_open, {pos = pos, gain = 0.3, max_hear_distance = 16})
			tmp_node = {name=name.."_open", param1=me.param1, param2=me.param2}
		end
		update_door(pos, tmp_node)
		meta:set_int("state", state)
	end

	local on_rightclick
	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node, clicker)
			punch(pos)
		end
	end

	-- Default help texts
	local longdesc, usagehelp
	longdesc = def._doc_items_longdesc
	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = "Trapdoors are floor covers which can be opened or closed. This trapdoor can only be opened or closed by redstone power."
		else
			longdesc = "Trapdoors are floor covers which can be opened or closed. This trapdoor can only be opened by hand and by redstone power."
		end
	end
	usagehelp = def._doc_items_usagehelp
	if not usagehelp and not def.only_redstone_can_open then
		usagehelp = "To open or close this door, rightclick it or send a redstone signal to it."
	end

	minetest.register_node(name, {
		description = def.description,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		tiles = def.tiles,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -8/16, 8/16, -5/16, 8/16},},
		},
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("state", 0)
		end,
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch(pos)
			end),
		}},
		on_rightclick = on_rightclick,
	})

	minetest.register_node(name.."_open", {
		drawtype = "nodebox",
		tiles = def.tiles,
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		pointable = true,
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		sounds = def.sounds,
		drop = name,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, 5/16, 0.5, 0.5, 0.5}
		},
		on_rightclick = on_rightclick,
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch(pos)
			end),
		}},
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", name, "nodes", name.."_open")
	end

end

mcl_doors:register_trapdoor("mcl_doors:trapdoor", {
	description = "Wooden Trapdoor",
	_doc_items_longdesc = "Wooden trapdoors are floor covers which can be opened and closed by hand or a redstone signal.",
	_doc_items_usagehelp = "To open or close the trapdoor, rightclick it or send a redstone signal to it.",
	tiles = {"door_trapdoor.png"},
	wield_image = "door_trapdoor.png",
	groups = {handy=1,axey=1, mesecon_effector_on=1,door=2, material_wood=1},
	_mcl_hardness = 3,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'mcl_doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:trapdoor",
	burntime = 15,
})

mcl_doors:register_trapdoor("mcl_doors:iron_trapdoor", {
	description = "Iron Trapdoor",
	_doc_items_longdesc = "Iron trapdoors are floor covers which can only be opened and closed by redstone signals, but not by hand.",
	tiles = {"iron_trapdoor.png"},
	wield_image = "iron_trapdoor.png",
	groups = {pickaxey=1, mesecon_effector_on=1,door=2},
	_mcl_hardness = 5,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = 'mcl_doors:iron_trapdoor',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
	}
})

-- Register aliases
local doornames = {
	["door"] = "wooden_door",
	["door_jungle"] = "jungle_door",
	["door_spruce"] = "spruce_door",
	["door_dark_oak"] = "dark_oak_door",
	["door_birch"] = "birch_door",
	["door_acacia"] = "acacia_door",
	["door_iron"] = "iron_door",
}

for oldname, newname in pairs(doornames) do
	minetest.register_alias("doors:"..oldname, "mcl_doors:"..newname)
	minetest.register_alias("doors:"..oldname.."_t_1", "mcl_doors:"..newname.."_t_1")
	minetest.register_alias("doors:"..oldname.."_b_1", "mcl_doors:"..newname.."_b_1")
	minetest.register_alias("doors:"..oldname.."_t_2", "mcl_doors:"..newname.."_t_2")
	minetest.register_alias("doors:"..oldname.."_b_2", "mcl_doors:"..newname.."_b_2")
end

minetest.register_alias("doors:trapdoor", "mcl_doors:trapdoor")
minetest.register_alias("doors:trapdoor_open", "mcl_doors:trapdoor_open")
minetest.register_alias("doors:iron_trapdoor", "mcl_doors:iron_trapdoor")
minetest.register_alias("doors:iron_trapdoor_open", "mcl_doors:iron_trapdoor_open")

-- Debug info
local time_to_load= os.clock() - init
minetest.log("action", (string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load)))
