local tmp = {}

minetest.register_entity("itemframes:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=0.3,y=0.3},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	on_activate = function(self, staticdata)
		if tmp.nodename ~= nil and tmp.texture ~= nil then
			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.nodename = data[1]
					self.texture = data[2]
				end
			end
		end
		if self.texture ~= nil then
			self.object:set_properties({textures={self.texture}})
		end
	end,
	get_staticdata = function(self)
		if self.nodename ~= nil and self.texture ~= nil then
			return self.nodename .. ';' .. self.texture
		end
		return ""
	end,
})


local facedir = {}
facedir[0] = {x=0,y=0,z=1}
facedir[1] = {x=1,y=0,z=0}
facedir[2] = {x=0,y=0,z=-1}
facedir[3] = {x=-1,y=0,z=0}

local remove_item = function(pos, node)
	local objs = nil
	if node.name == "itemframes:frame" then
		objs = minetest.get_objects_inside_radius(pos, .5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "itemframes:item" then
				obj:remove()
			end
		end
	end
end

local update_item = function(pos, node)
	remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "itemframes:frame" then
			local posad = facedir[node.param2]
			pos.x = pos.x + posad.x*6.5/16
			pos.y = pos.y + posad.y*6.5/16
			pos.z = pos.z + posad.z*6.5/16
		end
		tmp.nodename = node.name
		tmp.texture = ItemStack(meta:get_string("item")):get_name()
		local e = minetest.add_entity(pos,"itemframes:item")
		if node.name == "itemframes:frame" then
			local yaw = math.pi*2 - node.param2 * math.pi/2
			e:setyaw(yaw)
		end
	end
end

local drop_item = function(pos, node, meta)
	if meta:get_string("item") ~= "" then
		if node.name == "itemframes:frame" and not minetest.settings:get_bool("creative_mode") then
			local item = ItemStack(minetest.deserialize(meta:get_string("itemdata")))
			minetest.add_item(pos, item)
		end
		meta:set_string("item","")
		meta:set_string("itemdata","")
	end
	remove_item(pos, node)
end

minetest.register_node("itemframes:frame",{
	description = "Item Frame",
	_doc_items_longdesc = "Item frames are decorative blocks in which items can be placed.",
	_doc_items_usagehelp = "Hold any item in your hand and right-click the item frame to place the item into the frame. Rightclick the item frame again to retrieve the item.",
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "itemframes_itemframe1facedir.obj",
	selection_box = { type = "fixed", fixed = {-6/16, -6/16, 7/16, 6/16, 6/16, 0.5} },
	collision_box = { type = "fixed", fixed = {-6/16, -6/16, 7/16, 6/16, 6/16, 0.5} },
	tiles = {"itemframe_background.png", "itemframe_background.png", "itemframe_background.png", "itemframe_background.png", "default_wood.png", "itemframe_background.png"},
	inventory_image = "itemframes_frame.png",
	wield_image = "itemframes_frame.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = { dig_immediate=3,deco_block=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
		meta:set_string("infotext","Item frame (owned by "..placer:get_player_name()..")")
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.get_meta(pos)
		if clicker:get_player_name() == meta:get_string("owner") then
			drop_item(pos, node, meta)
			-- item holds the itemstring
			meta:set_string("item", itemstack:get_name())
			local put_itemstack = ItemStack(itemstack)
			put_itemstack:set_count(1)
			local itemdata = minetest.serialize(put_itemstack:to_table())
			-- itemdata holds the serialized itemstack in table form
			meta:set_string("itemdata", itemdata)
			update_item(pos,node)
			if not minetest.settings:get_bool("creative_mode") then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		drop_item(pos, node, meta)
	end,
	can_dig = function(pos,player)
		
		local meta = minetest.get_meta(pos)
		return player:get_player_name() == meta:get_string("owner")
	end,
})

minetest.register_craft({
	output = 'itemframes:frame',
	recipe = {
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_mobitems:leather', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
	}
})
