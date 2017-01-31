minetest.register_entity("mcl_flowers:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.25,y=.25},
	collisionbox = {0,0,0,0,0,0},
	groups = {snappy=3,attached_node=1},
	stack_max = 1,
	physical=false,
	textures={"air"},
	on_activate = function(self, staticdata)
		if flower_tmp.nodename ~= nil and flower_tmp.texture ~= nil then
			self.nodename = flower_tmp.nodename
			flower_tmp.nodename = nil
			self.texture = flower_tmp.texture
			flower_tmp.texture = nil
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

local flower_pot_remove_item = function(pos, node)
	local objs = nil
	if node and node.name == "mcl_flowers:pot" then
		objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, .5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "mcl_flowers:item" then
				obj:remove()
			end
		end
	end
end

flower_pot_update_item = function(pos, node)
	flower_pot_remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	if meta and meta:get_string("item") ~= "" then
		if node.name == "mcl_flowers:pot" then
			pos.y = pos.y
		end
		flower_tmp.nodename = node.name
		flower_tmp.texture = ItemStack(meta:get_string("item")):get_name()
		local e = minetest.add_entity(pos,"mcl_flowers:item")
	end
end

flower_pot_drop_item = function(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "mcl_flowers:pot" then
			minetest.add_item({x=pos.x,y=pos.y+1,z=pos.z}, meta:get_string("item"))
		end
		meta:set_string("item","")
	end
	flower_pot_remove_item(pos, node)
end
