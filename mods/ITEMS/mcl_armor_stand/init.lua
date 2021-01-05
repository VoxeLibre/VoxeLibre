local S = minetest.get_translator("mcl_armor_stand")

local elements = {"head", "torso", "legs", "feet"}

local function get_stand_object(pos)
	local object = nil
	local objects = minetest.get_objects_inside_radius(pos, 0.5) or {}
	for _, obj in pairs(objects) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.name == "mcl_armor_stand:armor_entity" then
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
		if not string.find(node.name, "mcl_armor_stand:") then
			object:remove()
			return
		end
	else
		object = minetest.add_entity(pos, "mcl_armor_stand:armor_entity")
	end
	if object then
		local texture = "blank.png"
		local textures = {}
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local yaw = 0
		if inv then
			for _, element in pairs(elements) do
				local stack = inv:get_stack("armor_"..element, 1)
				if stack:get_count() == 1 then
					local item = stack:get_name() or ""
					if minetest.registered_aliases[item] then
						item = minetest.registered_aliases[item]
					end
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
		object:set_yaw(yaw)
		object:set_properties({textures={texture}})
	end
end

-- Drop all armor of the armor stand on the ground
local drop_armor = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	for _, element in pairs(elements) do
		local stack = inv:get_stack("armor_"..element, 1)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end

-- TODO: The armor stand should be an entity
minetest.register_node("mcl_armor_stand:armor_stand", {
	description = S("Armor Stand"),
	_tt_help = S("Displays pieces of armor"),
	_doc_items_longdesc = S("An armor stand is a decorative object which can display different pieces of armor. Anything which players can wear as armor can also be put on an armor stand."),
	_doc_items_usagehelp = S("Just place an armor item on the armor stand. To take the top piece of armor from the armor stand, select your hand and use the place key on the armor stand."),
	drawtype = "mesh",
	mesh = "3d_armor_stand.obj",
	inventory_image = "3d_armor_stand_item.png",
	wield_image = "3d_armor_stand_item.png",
	tiles = {"default_wood.png", "mcl_stairs_stone_slab_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	is_ground_content = false,
	stack_max = 16,
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5, 0.5,1.4,0.5}
	},
	-- TODO: This should be breakable by 2 quick punches
	groups = {handy=1, deco_block=1, dig_by_piston=1, attached_node=1},
	_mcl_hardness = 2,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for _, element in pairs(elements) do
			inv:set_size("armor_"..element, 1)
		end
	end,
	-- Drop all armor on the ground when it got destroyed
	on_destruct = drop_armor,
	-- Put piece of armor on armor stand, or take one away
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return itemstack
		end

		local inv = minetest.get_inventory({type = "node", pos = pos})
		if not inv then
			return itemstack
		end

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
		local wielditem = clicker:get_wielded_item()
		if list then
			-- ... but only if the slot is free
			local single_item = ItemStack(itemstack)
			single_item:set_count(1)
			if inv:is_empty(list) then
				inv:add_item(list, single_item)
				armor:play_equip_sound(single_item, nil, pos)
				update_entity(pos)
				itemstack:take_item()
				return itemstack
			end
		end

		-- Take armor from stand if player has a free hand or wields the same armor type (if stackable)
		for e=1, #elements do
			local stand_armor = inv:get_stack("armor_" .. elements[e], 1)
			if not stand_armor:is_empty() then
				local pinv = clicker:get_inventory()
				local taken = false
				-- Empty hand
				if wielditem:get_name() == "" then
					pinv:set_stack("main", clicker:get_wield_index(), stand_armor)
					taken = true
				-- Stackable armor type (if not already full). This is the case for e.g. mob heads.
				-- This is done purely for convenience.
				elseif (wielditem:get_name() == stand_armor:get_name() and wielditem:get_count() < wielditem:get_stack_max()) then
					wielditem:set_count(wielditem:get_count()+1)
					pinv:set_stack("main", clicker:get_wield_index(), wielditem)
					taken = true
				end
				if taken then
					armor:play_equip_sound(stand_armor, nil, pos, true)
					stand_armor:take_item()
					inv:set_stack("armor_" .. elements[e], 1, stand_armor)
				end
				update_entity(pos)
				return clicker:get_wielded_item()
			end
		end
		update_entity(pos)
		return itemstack
	end,
	after_place_node = function(pos)
		minetest.add_entity(pos, "mcl_armor_stand:armor_entity")
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
		end
		local def = stack:get_definition() or {}
		local groups = def.groups or {}
		if groups[listname] then
			return 1
		end
		return 0
	end,
	allow_metadata_inventory_move = function()
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
		minetest.set_node(pos, {name = "air"})
	end,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_FACE then
			node.param2 = (node.param2 + 1) % 4
			minetest.swap_node(pos, node)
			update_entity(pos)
			return true
		end
		return false
	end,
})

minetest.register_entity("mcl_armor_stand:armor_entity", {
	physical = true,
	visual = "mesh",
	mesh = "3d_armor_entity.obj",
	visual_size = {x=1, y=1},
	collisionbox = {-0.1,-0.4,-0.1, 0.1,1.3,0.1},
	pointable = false,
	textures = {"blank.png"},
	pos = nil,
	timer = 0,
	on_activate = function(self)
		local pos = self.object:get_pos()
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
			local pos = self.object:get_pos()
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

-- FIXME: Armor helper entity can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn armor stand entities",
	name = "mcl_armor_stand:respawn_entities",
	nodenames = {"mcl_armor_stand:armor_stand"},
	run_at_every_load = true,
	action = function(pos, node)
		update_entity(pos, node)
	end,
})

minetest.register_craft({
	output = "mcl_armor_stand:armor_stand",
	recipe = {
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"", "mcl_core:stick", ""},
		{"mcl_core:stick", "mcl_stairs:slab_stone", "mcl_core:stick"},
	}
})


-- Legacy handling
minetest.register_alias("3d_armor_stand:armor_stand", "mcl_armor_stand:armor_stand")
minetest.register_entity(":3d_armor_stand:armor_entity", {
	on_activate = function(self)
		minetest.log("action", "[mcl_armor_stand] Removing legacy entity: 3d_armor_stand:armor_entity")
		self.object:remove()
	end,
	static_save = false,
})
