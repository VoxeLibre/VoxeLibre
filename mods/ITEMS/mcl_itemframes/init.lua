local S = minetest.get_translator("mcl_itemframes")

local VISUAL_SIZE = 0.3

minetest.register_entity("mcl_itemframes:item",{
	hp_max = 1,
	visual = "item",
	visual_size = {x=VISUAL_SIZE, y=VISUAL_SIZE},
	physical = false,
	pointable = false,
	textures = { "blank.png" },
	_texture = "blank.png",
	_scale = 1,

	on_activate = function(self, staticdata)
		if staticdata ~= nil and staticdata ~= "" then
			local data = staticdata:split(';')
			if data and data[1] and data[2] then
				self._nodename = data[1]
				self._texture = data[2]
				if data[3] then
					self._scale = data[3]
				else
					self._scale = 1
				end
			end
		end
		if self._texture ~= nil then
			self.object:set_properties({
				textures={self._texture},
				visual_size={x=VISUAL_SIZE/self._scale, y=VISUAL_SIZE/self._scale},
			})
		end
	end,
	get_staticdata = function(self)
		if self._nodename ~= nil and self._texture ~= nil then
			local ret = self._nodename .. ';' .. self._texture
			if self._scale ~= nil then
				ret = ret .. ';' .. self._scale
			end
			return ret
		end
		return ""
	end,

	_update_texture = function(self)
		if self._texture ~= nil then
			self.object:set_properties({
				textures={self._texture},
				visual_size={x=VISUAL_SIZE/self._scale, y=VISUAL_SIZE/self._scale},
			})
		end
	end,
})


local facedir = {}
facedir[0] = {x=0,y=0,z=1}
facedir[1] = {x=1,y=0,z=0}
facedir[2] = {x=0,y=0,z=-1}
facedir[3] = {x=-1,y=0,z=0}

local remove_item_entity = function(pos, node)
	local objs = nil
	if node.name == "mcl_itemframes:item_frame" then
		objs = minetest.get_objects_inside_radius(pos, .5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "mcl_itemframes:item" then
				obj:remove()
			end
		end
	end
end

local update_item_entity = function(pos, node, param2)
	remove_item_entity(pos, node)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local item = inv:get_stack("main", 1)
	if not item:is_empty() then
		if not param2 then
			param2 = node.param2
		end
		if node.name == "mcl_itemframes:item_frame" then
			local posad = facedir[param2]
			pos.x = pos.x + posad.x*6.5/16
			pos.y = pos.y + posad.y*6.5/16
			pos.z = pos.z + posad.z*6.5/16
		end
		local e = minetest.add_entity(pos, "mcl_itemframes:item")
		local lua = e:get_luaentity()
		lua._nodename = node.name
		local itemname = item:get_name()
		if itemname == "" or itemname == nil then
			lua._texture = "blank.png"
			lua._scale = 1
		else
			lua._texture = itemname
			local def = minetest.registered_items[itemname]
			if def and def.wield_scale then
				lua._scale = def.wield_scale.x
			else
				lua._scale = 1
			end
		end
		lua:_update_texture()
		if node.name == "mcl_itemframes:item_frame" then
			local yaw = math.pi*2 - param2 * math.pi/2
			e:set_yaw(yaw)
		end
	end
end

local drop_item = function(pos, node, meta, clicker)
	local cname = ""
	if clicker and clicker:is_player() then
		cname = clicker:get_player_name()
	end
	if node.name == "mcl_itemframes:item_frame" and not minetest.is_creative_enabled(cname) then
		local inv = meta:get_inventory()
		local item = inv:get_stack("main", 1)
		if not item:is_empty() then
			minetest.add_item(pos, item)
		end
	end
	meta:set_string("infotext", "")
	remove_item_entity(pos, node)
end

minetest.register_node("mcl_itemframes:item_frame",{
	description = S("Item Frame"),
	_tt_help = S("Can hold an item"),
	_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
	_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "mcl_itemframes_itemframe1facedir.obj",
	selection_box = { type = "fixed", fixed = {-6/16, -6/16, 7/16, 6/16, 6/16, 0.5} },
	collision_box = { type = "fixed", fixed = {-6/16, -6/16, 7/16, 6/16, 6/16, 0.5} },
	tiles = {"mcl_itemframes_itemframe_background.png", "mcl_itemframes_itemframe_background.png", "mcl_itemframes_itemframe_background.png", "mcl_itemframes_itemframe_background.png", "default_wood.png", "mcl_itemframes_itemframe_background.png"},
	inventory_image = "mcl_itemframes_item_frame.png",
	wield_image = "mcl_itemframes_item_frame.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = { dig_immediate=3,deco_block=1,dig_by_piston=1,container=7,attached_node_facedir=1 },
	sounds = mcl_sounds.node_sound_defaults(),
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then
			return
		end
		local pname = clicker:get_player_name()
		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end
		local meta = minetest.get_meta(pos)
		drop_item(pos, node, meta, clicker)
		local inv = meta:get_inventory()
		if itemstack:is_empty() then
			remove_item_entity(pos, node)
			meta:set_string("infotext", "")
			inv:set_stack("main", 1, "")
			return itemstack
		end
		local put_itemstack = ItemStack(itemstack)
		put_itemstack:set_count(1)
		inv:set_stack("main", 1, put_itemstack)
		update_item_entity(pos, node)
		-- Add node infotext when item has been named
		local imeta = itemstack:get_meta()
		local iname = imeta:get_string("name")
		if iname then
			meta:set_string("infotext", iname)
		end

		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		drop_item(pos, node, meta)
	end,
	on_rotate = function(pos, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			-- Rotate face
			local meta = minetest.get_meta(pos)
			local node = minetest.get_node(pos)

			local objs = nil
			if node.name == "mcl_itemframes:item_frame" then
				objs = minetest.get_objects_inside_radius(pos, .5)
			end
			if objs then
				for _, obj in ipairs(objs) do
					if obj and obj:get_luaentity() and obj:get_luaentity().name == "mcl_itemframes:item" then
						update_item_entity(pos, node, (node.param2+1) % 4)
						break
					end
				end
			end
			return
		elseif mode == screwdriver.ROTATE_AXIS then
			return false
		end
	end,
})

minetest.register_craft({
	output = 'mcl_itemframes:item_frame',
	recipe = {
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_mobitems:leather', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
	}
})

minetest.register_lbm({
	label = "Update legacy item frames",
	name = "mcl_itemframes:update_legacy_item_frames",
	nodenames = {"itemframes:frame"},
	action = function(pos, node)
		-- Swap legacy node, then respawn entity
		node.name = "mcl_itemframes:item_frame"
		local meta = minetest.get_meta(pos)
		local item = meta:get_string("item")
		minetest.swap_node(pos, node)
		if item ~= "" then
			local itemstack = ItemStack(minetest.deserialize(meta:get_string("itemdata")))
			local inv = meta:get_inventory()
			inv:set_size("main", 1)
			if not itemstack:is_empty() then
				inv:set_stack("main", 1, itemstack)
			end
		end
		update_item_entity(pos, node)
	end,
})

-- FIXME: Item entities can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn item frame item entities",
	name = "mcl_itemframes:respawn_entities",
	nodenames = {"mcl_itemframes:item_frame"},
	run_at_every_load = true,
	action = function(pos, node)
		update_item_entity(pos, node)
	end,
})

minetest.register_alias("itemframes:frame", "mcl_itemframes:item_frame")
