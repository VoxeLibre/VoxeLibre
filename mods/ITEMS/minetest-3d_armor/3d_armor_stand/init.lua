local elements = {"head", "torso", "legs", "feet"}

local function get_stand_object(pos)
	local object = nil
	local objects = minetest.get_objects_inside_radius(pos, 0.5) or {}
	for _, obj in pairs(objects) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.name == "3d_armor_stand:armor_entity" then
				-- Remove duplicates
				if object then
					obj:remove()
				else
					object = obj
				end
			end
		end
	end
	return object
end

local function update_entity(pos)
	local node = minetest.get_node(pos)
	local object = get_stand_object(pos)
	if object then
		if not string.find(node.name, "3d_armor_stand:") then
			object:remove()
			return
		end
	else
		object = minetest.add_entity(pos, "3d_armor_stand:armor_entity")
	end
	if object then
		local texture = "3d_armor_trans.png"
		local textures = {}
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local yaw = 0
		if inv then
			for _, element in pairs(elements) do
				local stack = inv:get_stack("armor_"..element, 1)
				if stack:get_count() == 1 then
					local item = stack:get_name() or ""
					local def = stack:get_definition() or {}
					local groups = def.groups or {}
					if groups["armor_"..element] then
						local texture = def.texture or item:gsub("%:", "_")
						table.insert(textures, texture..".png")
					end
				end
			end
		end
		if #textures > 0 then
			texture = table.concat(textures, "^")
		end
		if node.param2 then
			local rot = node.param2 % 4
			if rot == 1 then
				yaw = 3 * math.pi / 2
			elseif rot == 2 then
				yaw = math.pi
			elseif rot == 3 then
				yaw = math.pi / 2
			end
		end
		object:setyaw(yaw)
		object:set_properties({textures={texture}})
	end
end

-- FIXME: The armor stand should be an entity
minetest.register_node("3d_armor_stand:armor_stand", {
	description = "Armor Stand",
	_doc_items_longdesc = "An armor stand is a decorative object which displays different pieces of armor.",
	_doc_items_usagehelp = "Hold an armor item in your hand and rightclick the armor stand to put it on the armor stand. To take a piece of armor from the armor stand, select your hand and rightclick the armor stand. You'll retrieve the first armor item from above.",
	drawtype = "mesh",
	mesh = "3d_armor_stand.obj",
	inventory_image = "3d_armor_stand_item.png",
	tiles = {"default_wood.png", "default_steel_block.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	is_ground_content = false,
	stack_max = 16,
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5, 0.5,1.4,0.5}
	},
	-- FIXME: This should be breakable by 2 quick punches
	groups = {handy=1, deco_block=1},
	_mcl_hardness = 2,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for _, element in pairs(elements) do
			inv:set_size("armor_"..element, 1)
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for _, element in pairs(elements) do
			if not inv:is_empty("armor_"..element) then
				return false
			end
		end
		return true
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- Check if player wields armor
		local name = itemstack:get_name()
		local list
		for e=1, #elements do
			local g = minetest.get_item_group(name, "armor_" .. elements[e])
			if g ~= nil and g ~= 0 then
				list = "armor_" .. elements[e]
				break
			end
		end

		-- If player wields armor, put it on armor stand
		local inv = minetest.get_inventory({type = "node", pos = pos})
		local wielditem = clicker:get_wielded_item()
		if not inv then return end
		if list then
			if inv:room_for_item(list, itemstack) then
				inv:add_item(list, itemstack)
				update_entity(pos)
				itemstack:take_item()
			end
			return itemstack
		elseif wielditem:get_name() == "" then
		-- If player does not wield anything, take the first available armor from the armor stand
		-- and give it to the player
			for e=1, #elements do
				local stand_armor = inv:get_stack("armor_" .. elements[e], 1)
				if not stand_armor:is_empty() then
					local pinv = clicker:get_inventory()
					pinv:set_stack("main", clicker:get_wield_index(), stand_armor)
					stand_armor:take_item()
					inv:set_stack("armor_" .. elements[e], 1, stand_armor)
					update_entity(pos)
					return clicker:get_wielded_item()
				end
			end
		end
		return itemstack
	end,
	after_place_node = function(pos)
		minetest.add_entity(pos, "3d_armor_stand:armor_entity")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		local def = stack:get_definition() or {}
		local groups = def.groups or {}
		if groups[listname] then
			return 1
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos)
		return 0
	end,
	on_metadata_inventory_put = function(pos)
		update_entity(pos)
	end,
	on_metadata_inventory_take = function(pos)
		update_entity(pos)
	end,
	after_destruct = function(pos)
		update_entity(pos)
	end,
	on_blast = function(pos)
		local object = get_stand_object(pos)
		if object then
			object:remove()
		end
		minetest.after(1, function(pos)
			update_entity(pos)
		end, pos)
	end,
})

minetest.register_entity("3d_armor_stand:armor_entity", {
	physical = true,
	visual = "mesh",
	mesh = "3d_armor_entity.obj",
	visual_size = {x=1, y=1},
	collisionbox = {-0.1,-0.4,-0.1, 0.1,1.3,0.1},
	textures = {"3d_armor_trans.png"},
	pos = nil,
	timer = 0,
	on_activate = function(self)
		local pos = self.object:getpos()
		self.object:set_armor_groups({immortal=1})
		if pos then
			self.pos = vector.round(pos)
			update_entity(pos)
		end
	end,
	on_step = function(self, dtime)
		if not self.pos then
			return
		end
		self.timer = self.timer + dtime
		if self.timer > 1 then
			self.timer = 0
			local pos = self.object:getpos()
			if pos then
				if vector.equals(vector.round(pos), self.pos) then
					return
				end
			end
			update_entity(self.pos)
			self.object:remove()
		end
	end,
})

if minetest.get_modpath("doc_identifier") ~= nil then
	doc.sub.identifier.register_object("3d_armor_stand:armor_entity", "nodes", "3d_armor_stand:armor_stand")
end

minetest.register_craft({
	output = "3d_armor_stand:armor_stand",
	recipe = {
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"", "mcl_core:stick", ""},
		{"mcl_core:stick", "stairs:slab_stone", "mcl_core:stick"},
	}
})

