minetest.register_entity("mcl_itemframes:item",{
	hp_max = 1,
	visual = "wielditem",
	visual_size = {x=0.3,y=0.3},
	collisionbox = {0,0,0,0,0,0},
	physical = false,
	textures = { "empty.png" },
	on_activate = function(self, staticdata)
		if staticdata ~= nil and staticdata ~= "" then
			local data = staticdata:split(';')
			if data and data[1] and data[2] then
				self._nodename = data[1]
				self._texture = data[2]
			end
		end
		if self._texture ~= nil then
			self.object:set_properties({textures={self._texture}})
		end
	end,
	get_staticdata = function(self)
		if self._nodename ~= nil and self._texture ~= nil then
			return self._nodename .. ';' .. self._texture
		end
		return ""
	end,

	_update_texture = function(self)
		if self._texture ~= nil then
			self.object:set_properties({textures={self._texture}})
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

local update_item_entity = function(pos, node)
	remove_item_entity(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "mcl_itemframes:item_frame" then
			local posad = facedir[node.param2]
			pos.x = pos.x + posad.x*6.5/16
			pos.y = pos.y + posad.y*6.5/16
			pos.z = pos.z + posad.z*6.5/16
		end
		local e = minetest.add_entity(pos,"mcl_itemframes:item")
		local lua = e:get_luaentity()
		lua._nodename = node.name
		lua._texture = ItemStack(meta:get_string("item")):get_name()
		lua:_update_texture()
		if node.name == "mcl_itemframes:item_frame" then
			local yaw = math.pi*2 - node.param2 * math.pi/2
			e:setyaw(yaw)
		end
	end
end

local drop_item = function(pos, node, meta)
	if meta:get_string("item") ~= "" then
		if node.name == "mcl_itemframes:item_frame" and not minetest.settings:get_bool("creative_mode") then
			local item = ItemStack(minetest.deserialize(meta:get_string("itemdata")))
			minetest.add_item(pos, item)
		end
		meta:set_string("item", "")
		meta:set_string("itemdata", "")
		meta:set_string("infotext", "")
	end
	remove_item_entity(pos, node)
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

minetest.register_node("mcl_itemframes:item_frame",{
	description = "Item Frame",
	_doc_items_longdesc = "Item frames are decorative blocks in which items can be placed.",
	_doc_items_usagehelp = "Hold any item in your hand and right-click the item frame to place the item into the frame. Rightclick the item frame again to retrieve the item.",
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
	groups = { dig_immediate=3,deco_block=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.get_meta(pos)
		drop_item(pos, node, meta)
		-- item holds the itemstring
		meta:set_string("item", itemstack:get_name())
		local put_itemstack = ItemStack(itemstack)
		put_itemstack:set_count(1)
		local itemdata = minetest.serialize(put_itemstack:to_table())
		-- itemdata holds the serialized itemstack in table form
		update_item_entity(pos,node)
		-- Add node infotext when item has been named
		meta:set_string("itemdata", itemdata)
		local imeta = itemstack:get_meta()
		local iname = imeta:get_string("name")
		if iname then
			meta:set_string("infotext", iname)
		end

		if not minetest.settings:get_bool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		drop_item(pos, node, meta)
	end,
	on_rotate = on_rotate,
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
		minetest.swap_node(pos, node)
		update_item_entity(pos, node)
	end,
})
