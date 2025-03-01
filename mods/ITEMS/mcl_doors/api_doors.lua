local S = minetest.get_translator(minetest.get_current_modname())
local minetest_get_meta = minetest.get_meta

-- This helper function calls on_place_node callbacks.
local function on_place_node(place_to, newnode,
	placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in pairs(minetest.registered_on_placenodes) do
		-- Deep-copy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy =
			{name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy =
			{name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer,
			oldnode_copy, itemstack, pointed_thing_copy)
	end
end

-- Registers a door
--  name: The name of the door
--  def: a table with the following fields:
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
	def.groups.door = 1
	def.groups.mesecon_ignore_opaque_dig = 1

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end
	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	if not def.node_box then
		def.node_box = {{-8/16, -8/16, -8/16, 8/16, 8/16, -5/16}}
	end
	if not def.selection_box then
		def.selection_box = {{-8/16, -8/16, -8/16, 8/16, 8/16, -5/16}}
	end

	local longdesc, usagehelp, tt_help
	tt_help = def._tt_help
	longdesc = def._doc_items_longdesc
	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = S("This door is a 2-block high barrier which can only be opened by redstone power, not by hand.")
		else
			longdesc = S("This door is a 2-block high barrier which can be opened or closed by hand or by redstone power.")
		end
	end
	usagehelp = def._doc_items_usagehelp
	if not usagehelp then
		if def.only_redstone_can_open then
			usagehelp = S("To open or close this door, send a redstone signal to its bottom half.")
		else
			usagehelp = S("To open or close this door, rightclick it or send a redstone signal to its bottom half.")
		end
	end
	if not tt_help then
		if def.only_redstone_can_open then
			tt_help = S("Openable by redstone power")
		else
			tt_help = S("Openable by players and redstone power")
		end
	end

	local craftitem_groups = { mesecon_conductor_craftable = 1, deco_block = 1 }
	if def.groups and def.groups.flammable then
		craftitem_groups.flammable = def.groups.flammable
	end

	minetest.register_craftitem(name, {
		description = def.description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		inventory_image = def.inventory_image,
		stack_max = 64,
		groups = craftitem_groups,
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" or not placer or not placer:is_player() then
				return itemstack
			end
			local pn = placer:get_player_name()
			if minetest.is_protected(pointed_thing.above, pn) and minetest.is_protected(pointed_thing.under, pn) then
				return itemstack
			end
			local ptu = pointed_thing.under
			local nu = minetest.get_node(ptu)
			-- Pointed thing's rightclick action takes precedence, unless player holds down the sneak key
			if minetest.registered_nodes[nu.name] and minetest.registered_nodes[nu.name].on_rightclick and not placer:get_player_control().sneak then
				return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
			end

			local pt
			if minetest.registered_nodes[nu.name] and minetest.registered_nodes[nu.name].buildable_to then
				pt = pointed_thing.under
			else
				pt = pointed_thing.above
			end
			local pt2 = {x=pt.x, y=pt.y, z=pt.z}
			pt2.y = pt2.y+1
			local ptname = minetest.get_node(pt).name
			local pt2name = minetest.get_node(pt2).name
			if
				(minetest.registered_nodes[ptname] and not minetest.registered_nodes[ptname].buildable_to) or
				(minetest.registered_nodes[pt2name] and not minetest.registered_nodes[pt2name].buildable_to)
			then
				return itemstack
			end

			-- get left coordinate for checking if another door is there
			local pt_left = {x=pt.x, y=pt.y, z=pt.z}
			local p2 = minetest.dir_to_facedir(placer:get_look_dir())

			if p2 == 0 then
				pt_left.x = pt_left.x-1
			elseif p2 == 1 then
				pt_left.z = pt_left.z+1
			elseif p2 == 2 then
				pt_left.x = pt_left.x+1
			elseif p2 == 3 then
				pt_left.z = pt_left.z-1
			end

			local left_node = minetest.get_node(pt_left)
			local mirrored = false
			local door_dir = 1
			if left_node.name:sub(1, #name) == name then
				mirrored = true
				door_dir = 3
				p2 = left_node.param2
			end

			-- Set door nodes
			minetest.set_node(pt, {name=name.."_b_"..door_dir, param2=p2})
			minetest.set_node(pt2, {name=name.."_t_"..door_dir, param2=p2})

			if def.sounds and def.sounds.place then
				minetest.sound_play(def.sounds.place, {pos=pt}, true)
			end

			if def.only_placer_can_open then
				local meta = minetest_get_meta(pt)
				meta:set_string("doors_owner", "")
				meta = minetest_get_meta(pt2)
				meta:set_string("doors_owner", "")
			end

			local meta1 = minetest_get_meta(pt)
			local meta2 = minetest_get_meta(pt2)
			-- save mirror state for the correct door
			if mirrored then
				meta1:set_int("is_mirrored", 1)
				meta2:set_int("is_mirrored", 1)
			end

			-- Save open state. 1 = open. 0 = closed
			meta1:set_int("is_open", 0)
			meta2:set_int("is_open", 0)


			if not minetest.is_creative_enabled(pn) then
				itemstack:take_item()
			end

			on_place_node(pt, minetest.get_node(pt), placer, nu, itemstack, pointed_thing)
			on_place_node(pt2, minetest.get_node(pt2), placer, minetest.get_node({x=ptu.x,y=ptu.y+1,z=ptu.z}), itemstack, pointed_thing)

			return itemstack
		end,
	})

	local top_door_texture = def.tiles_top:match("(.+)%..+$") -- This removes the filename extension from the images.
	local bottom_door_texture = def.tiles_bottom:match("(.+)%..+$") -- This removes the filename extension from the images.

	local texture_top = top_door_texture .. ".png"
	local texture_bottom = bottom_door_texture .. ".png"
	local texture_top_toppart = top_door_texture .. "_toppart.png" -- Special texture to make the top of opened doors not look weird.
	local texture_bottom_bottompart = bottom_door_texture .. "_bottompart.png" -- Special texture to make the bottom of opened doors not look weird.
	local texture_top_side = top_door_texture .. "_side.png" -- Special texture to make the side of opened doors not look weird.
	local texture_bottom_side = bottom_door_texture .. "_side.png" -- Special texture to make the side of opened doors not look weird.

	local texture_top_mirrored = texture_top .. "^[transformFX"
	local texture_bottom_mirrored = texture_bottom .. "^[transformFX"
	local texture_top_toppart_mirrored = texture_top_toppart .. "^[transformFX"
	local texture_bottom_bottompart_mirrored = texture_bottom_bottompart .. "^[transformFX"
	local texture_top_side_mirrored = texture_top_side .. "^[transformFX"
	local texture_bottom_side_mirrored = texture_bottom_side .. "^[transformFX"

	local function on_open_close(pos, dir, check_name, replace, replace_dir)
		local meta1 = minetest_get_meta(pos)
		pos.y = pos.y+dir
		local meta2 = minetest_get_meta(pos)

		-- if name of other door is not the same as check_name -> return
		if not minetest.get_node(pos).name == check_name  then
			return
		end

		-- swap directions if mirrored
		local params = {3,0,1,2}
		if meta1:get_int("is_open") == 0 and meta2:get_int("is_mirrored") == 0 or meta1:get_int("is_open") == 1 and meta2:get_int("is_mirrored") == 1 then
			params = {1,2,3,0}
		end

		local p2 = minetest.get_node(pos).param2
		local np2 = params[p2+1]

		minetest.swap_node(pos, {name=replace_dir, param2=np2})
		pos.y = pos.y-dir
		minetest.swap_node(pos, {name=replace, param2=np2})

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
		minetest.sound_play(door_switching_sound, {pos = pos, gain = 0.5, max_hear_distance = 16}, true)
	end

	local function on_mesecons_signal_open(pos, node)
		local meta2 = minetest_get_meta(pos)
		if meta2:get_int("is_mirrored") ~= 1 then
			on_open_close(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2")
		else
			on_open_close(pos, 1, name.."_t_3", name.."_b_4", name.."_t_4")
		end
	end

	local function on_mesecons_signal_close(pos, node)
		if not mesecon.is_powered({x=pos.x,y=pos.y+1,z=pos.z}) then
			local meta2 = minetest_get_meta(pos)
			if meta2:get_int("is_mirrored") ~= 1 then
				on_open_close(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1")
			else
				on_open_close(pos, 1, name.."_t_4", name.."_b_3", name.."_t_3")
			end
		end
	end

	local function on_mesecons_signal_open_top(pos, node)
		on_mesecons_signal_open({x=pos.x, y=pos.y-1, z=pos.z}, node)
	end

	local function on_mesecons_signal_close_top(pos, node)
		if not mesecon.is_powered({x=pos.x,y=pos.y-1,z=pos.z}) then
			on_mesecons_signal_close({x=pos.x, y=pos.y-1, z=pos.z}, node)
		end
	end

	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then
			return true
		end
		local meta = minetest_get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end

	local on_rightclick
	-- Disable on_rightclick if this is a redstone-only door
	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2")
			end
		end
	end

	local template_def = {
		tiles = nil,
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box
		},
		groups = def.groups,
		_mcl_hardness = def._mcl_hardness,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		sounds = def.sounds,

		after_destruct = nil,

		on_rightclick = nil,

		mesecons = nil,

		on_rotate = nil,

		can_dig = check_player_priv,
	}

	local _b_1_def = table.copy(template_def)
	_b_1_def.tiles = {"blank.png", texture_bottom_bottompart .. "^[transformFY", texture_bottom_side, texture_bottom_side_mirrored, texture_bottom_mirrored, texture_bottom}
	_b_1_def.after_destruct = function(bottom, oldnode)
		local meta_bottom = minetest_get_meta(bottom)
		if meta_bottom:get_int("rotation") == 1 then
			meta_bottom:set_int("rotation", 0)
		else
			minetest.add_item(bottom, name)
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			if minetest.get_node(bottom).name ~= name.."_b_2" and minetest.get_node(top).name == name.."_t_1" then
				minetest.remove_node(top)
			end
		end
	end
	_b_1_def.on_rightclick = on_rightclick
	_b_1_def.mesecons = { effector = {
		action_on = on_mesecons_signal_open,
	}}
	_b_1_def.on_rotate = function(bottom, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(bottom, node, mode)
			minetest.swap_node(bottom, node)

			local top = {x=bottom.x,y=bottom.y+1,z=bottom.z}
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.name = name .."_t_1"
			minetest.swap_node(top, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_b_1", _b_1_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2")
			end
		end
	end

	local _t_1_def = table.copy(template_def)
	_t_1_def.tiles = {texture_top_toppart .. "^[transformFY", "blank.png", texture_top_side, texture_top_side_mirrored, texture_top_mirrored, texture_top}
	_t_1_def.after_destruct = function(top, oldnode)
		local meta_top = minetest_get_meta(top)
		if meta_top:get_int("rotation") == 1 then
			meta_top:set_int("rotation", 0)
		else
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if minetest.get_node(top).name ~= name.."_t_2" and minetest.get_node(bottom).name == name.."_b_1" and oldnode.name == name.."_t_1" then
				minetest.dig_node(bottom)
			end
		end
	end
	_t_1_def.on_rightclick = on_rightclick
	_t_1_def.mesecons = { effector = {
		action_on = on_mesecons_signal_open_top,
		rules = mesecon.rules.flat,
	}}
	_t_1_def.on_rotate = function(top, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(top, node, mode)
			minetest.swap_node(top, node)

			local bottom = {x=top.x,y=top.y-1,z=top.z}
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.name = name .."_b_1"
			minetest.swap_node(bottom, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_t_1", _t_1_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1")
			end
		end
	end

	local _b_2_def = table.copy(template_def)
	_b_2_def.tiles = {"blank.png", texture_bottom_bottompart_mirrored, texture_bottom_side, texture_bottom_side, texture_bottom, texture_bottom_mirrored}
	_b_2_def.after_destruct = function(bottom, oldnode)
		local meta_bottom = minetest_get_meta(bottom)
		if meta_bottom:get_int("rotation") == 1 then
			meta_bottom:set_int("rotation", 0)
		else
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			minetest.add_item(bottom, name)
			if minetest.get_node(bottom).name ~= name.."_b_1" and minetest.get_node(top).name == name.."_t_2" then
				minetest.remove_node(top)
			end
		end
	end
	_b_2_def.on_rightclick = on_rightclick
	_b_2_def.mesecons = { effector = {
		action_off = on_mesecons_signal_close,
	}}
	_b_2_def.on_rotate = function(bottom, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(bottom, node, mode)
			minetest.swap_node(bottom, node)

			local top = {x=bottom.x,y=bottom.y+1,z=bottom.z}
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.name = name .."_t_2"
			minetest.swap_node(top, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_b_2", _b_2_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1")
			end
		end
	end

	local _t_2_def = table.copy(template_def)
	_t_2_def.tiles = {texture_top_toppart_mirrored, "blank.png", texture_top_side, texture_top_side, texture_top, texture_top_mirrored}
	_t_2_def.after_destruct = function(top, oldnode)
		local meta_top = minetest_get_meta(top)
		if meta_top:get_int("rotation") == 1 then
			meta_top:set_int("rotation", 0)
		else
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if minetest.get_node(top).name ~= name.."_t_1" and minetest.get_node(bottom).name == name.."_b_2" and oldnode.name == name.."_t_2" then
				minetest.dig_node(bottom)
			end
		end
	end
	_t_2_def.on_rightclick = on_rightclick
	_t_2_def.mesecons = { effector = {
		action_off = on_mesecons_signal_close_top,
		rules = mesecon.rules.flat,
	}}
	_t_2_def.on_rotate = function(top, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(top, node, mode)
			minetest.swap_node(top, node)

			local bottom = {x=top.x,y=top.y-1,z=top.z}
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.name = name .."_b_2"
			minetest.swap_node(bottom, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_t_2", _t_2_def)

	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_3", name.."_b_4", name.."_t_4")
			end
		end
	end

	local _b_3_def = table.copy(template_def)
	_b_3_def.tiles = {"blank.png", texture_bottom_mirrored .. "^[transformFY", texture_bottom_side, texture_bottom_side_mirrored, texture_bottom, texture_bottom_mirrored}
	_b_3_def.after_destruct = function(bottom, oldnode)
		local meta_bottom = minetest_get_meta(bottom)
		if meta_bottom:get_int("rotation") == 1 then
			meta_bottom:set_int("rotation", 0)
		else
			minetest.add_item(bottom, name)
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			if minetest.get_node(bottom).name ~= name.."_b_4" and minetest.get_node(top).name == name.."_t_3" then
				minetest.remove_node(top)
			end
		end
	end
	_b_3_def.on_rightclick = on_rightclick
	_b_3_def.mesecons = { effector = {
		action_on = on_mesecons_signal_open,
	}}
	_b_3_def.on_rotate = function(bottom, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(bottom, node, mode)
			minetest.swap_node(bottom, node)

			local top = {x=bottom.x,y=bottom.y+1,z=bottom.z}
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.name = name .."_t_3"
			minetest.swap_node(top, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_b_3", _b_3_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_3", name.."_t_4", name.."_b_4")
			end
		end
	end

	local _t_3_def = table.copy(template_def)
	_t_3_def.tiles = {texture_top_toppart_mirrored .. "^[transformFY", "blank.png", texture_top_side, texture_top_side_mirrored, texture_top, texture_top_mirrored}
	_t_3_def.after_destruct = function(top, oldnode)
		local meta_top = minetest_get_meta(top)
		if meta_top:get_int("rotation") == 1 then
			meta_top:set_int("rotation", 0)
		else
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if minetest.get_node(top).name ~= name.."_t_4" and minetest.get_node(bottom).name == name.."_b_3" and oldnode.name == name.."_t_3" then
				minetest.dig_node(bottom)
			end
		end
	end
	_t_3_def.on_rightclick = on_rightclick
	_t_3_def.mesecons = { effector = {
		action_on = on_mesecons_signal_open_top,
		rules = mesecon.rules.flat,
	}}
	_t_3_def.on_rotate = function(top, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(top, node, mode)
			minetest.swap_node(top, node)

			local bottom = {x=top.x,y=top.y-1,z=top.z}
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.name = name .."_b_3"
			minetest.swap_node(bottom, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_t_3", _t_3_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, 1, name.."_t_4", name.."_b_3", name.."_t_3")
			end
		end
	end

	local _b_4_def = table.copy(template_def)
	_b_4_def.tiles = {"blank.png", texture_bottom_bottompart, texture_bottom_side_mirrored, texture_bottom_side_mirrored, texture_bottom_mirrored, texture_bottom}
	_b_4_def.after_destruct = function(bottom, oldnode)
		local meta_bottom = minetest_get_meta(bottom)
		if meta_bottom:get_int("rotation") == 1 then
			meta_bottom:set_int("rotation", 0)
		else
			local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
			minetest.add_item(bottom, name)
			if minetest.get_node(bottom).name ~= name.."_b_3" and minetest.get_node(top).name == name.."_t_4" then
				minetest.remove_node(top)
			end
		end
	end
	_b_4_def.on_rightclick = on_rightclick
	_b_4_def.mesecons = { effector = {
		action_off = on_mesecons_signal_close,
	}}
	_b_4_def.on_rotate = function(bottom, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(bottom, node, mode)
			minetest.swap_node(bottom, node)

			local top = {x=bottom.x,y=bottom.y+1,z=bottom.z}
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.name = name .."_t_4"
			minetest.swap_node(top, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_b_4", _b_4_def)

	if def.only_redstone_can_open then
		on_rightclick = nil
	else
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_open_close(pos, -1, name.."_b_4", name.."_t_3", name.."_b_3")
			end
		end
	end

	local _t_4_def = table.copy(template_def)
	_t_4_def.tiles = {texture_top_toppart, "blank.png", texture_top_side_mirrored, texture_top_side_mirrored, texture_top_mirrored, texture_top}
	_t_4_def.after_destruct = function(top, oldnode)
		local meta_top = minetest_get_meta(top)
		if meta_top:get_int("rotation") == 1 then
			meta_top:set_int("rotation", 0)
		else
			local bottom = { x = top.x, y = top.y - 1, z = top.z }
			if minetest.get_node(top).name ~= name.."_t_3" and minetest.get_node(bottom).name == name.."_b_4" and oldnode.name == name.."_t_4" then
				minetest.dig_node(bottom)
			end
		end
	end
	_t_4_def.on_rightclick = on_rightclick
	_t_4_def.mesecons = { effector = {
		action_off = on_mesecons_signal_close_top,
		rules = mesecon.rules.flat,
	}}
	_t_4_def.on_rotate = function(top, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta_top = minetest_get_meta(top)
			meta_top:set_int("rotation", 1)
			node.param2 = screwdriver.rotate.facedir(top, node, mode)
			minetest.swap_node(top, node)

			local bottom = {x=top.x,y=top.y-1,z=top.z}
			local meta_bottom = minetest_get_meta(bottom)
			meta_bottom:set_int("rotation", 1)
			node.name = name .."_b_4"
			minetest.swap_node(bottom, node)

			return true
		end
		return false
	end

	minetest.register_node(name.."_t_4", _t_4_def)


	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_1")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_2")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_3")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_b_4")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_1")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_2")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_3")
		doc.add_entry_alias("craftitems", name, "nodes", name.."_t_4")
	end
end
