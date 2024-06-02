local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
--- Item and armor management

local function player_near(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos,2)) do
		if o:is_player() then return true end
	end
end

local function get_armor_texture(armor_name)
	if armor_name == "" then
		return ""
	end
	if armor_name=="blank.png" then
		return "blank.png"
	end
	local seperator = string.find(armor_name, ":")
	return "mcl_armor_"..string.sub(armor_name, seperator+1, -1)..".png"
end

--[[
-- Old texture function
function mob_class:set_armor_texture()
	if self.armor_list then
		local chestplate=minetest.registered_items[self.armor_list.chestplate] or {name=""}
		local boots=minetest.registered_items[self.armor_list.boots] or {name=""}
		local leggings=minetest.registered_items[self.armor_list.leggings] or {name=""}
		local helmet=minetest.registered_items[self.armor_list.helmet] or {name=""}

		if helmet.name=="" and chestplate.name=="" and leggings.name=="" and boots.name=="" then
			helmet={name="blank.png"}
		end
		local texture = get_armor_texture(chestplate.name)..get_armor_texture(helmet.name)..get_armor_texture(boots.name)..get_armor_texture(leggings.name)
		if string.sub(texture, -1,-1) == "^" then
			texture=string.sub(texture,1,-2)
		end
		if self.textures[self.wears_armor] then
			self.textures[self.wears_armor]=texture
		end
		self.object:set_properties({textures=self.textures})

		local armor_
		if type(self.armor) == "table" then
			armor_ = table.copy(self.armor)
			armor_.immortal = 1
		else
			armor_ = {immortal=1, fleshy = self.armor}
		end

		for _,item in pairs(self.armor_list) do
			if not item then return end
			if type(minetest.get_item_group(item, "mcl_armor_points")) == "number" then
				armor_.fleshy=armor_.fleshy-(minetest.get_item_group(item, "mcl_armor_points")*3.5)
			end
		end
		self.object:set_armor_groups(armor_)
	end
end
]]

minetest.register_entity("mcl_mobs:armor_piece", {
	visual = "mesh",
	mesh = "mcl_mobs_armor_head.obj",
	textures = {get_armor_texture("mcl_armor:helmet_diamond")},
	_kill_on_detach = true,
	_armor = true,
	pointable = false,
	physical = false,
	collide_with_objects = false,
	collisionbox = {0,0,0,0,0,0},
	on_detach = function(self)
		if self.object:get_pos() and not self.object:get_attach() and self._kill_on_detach then self.object:remove() return end
	end,
	on_activate = function(self)
		minetest.after(0.2, function() -- if we are disconnected from anything unless made to, self destruct
			if self and self.object and self.object:get_pos() then
				if self.object:get_pos() and not self.object:get_attach() and self._kill_on_detach then self.object:remove() return end
			end
		end)
	end,
}) -- specific piece selected at spawn

-- Adds a piece of armor (entity) into the worl based on it's name
function mcl_mobs.add_armor_piece(itemname, r_l, pos)
	local obj = minetest.add_entity(pos or vector.zero(), "mcl_mobs:armor_piece") -- armor piece
	tex = get_armor_texture(itemname) -- texture
	local mesh = ""

	-- choose correct model based on name
	if string.find(itemname, "chestplate") then
		if r_l then
			if r_l == "r" then
				mesh = "mcl_mobs_armor_arm_right.obj"
			else
				mesh = "mcl_mobs_armor_arm_left.obj"
			end
		else
			mesh = "mcl_mobs_armor_chest.obj"
		end
	elseif string.find(itemname, "boots") or string.find(itemname, "leggings") then
		if r_l then
			if r_l == "r" then
				mesh = "mcl_mobs_armor_leg_right.obj"
			else
				mesh = "mcl_mobs_armor_leg_left.obj"
			end
		end
	elseif string.find(itemname, "helmet") then
		mesh = "mcl_mobs_armor_head.obj"
	end


	obj:set_properties({textures = {tex}, mesh = mesh, visual_size = size or vector.new(1,1,1)})

	return obj
end

--[[
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		mcl_mobs.add_armor_piece("mcl_armor:helmet_diamond", nil, player:get_pos())
	end
end)]]

--new armor texture function
function mob_class:set_armor_texture()
	if self.armor_list then
		local chestplate=minetest.registered_items[self.armor_list.chestplate] or {name=""}
		local boots=minetest.registered_items[self.armor_list.boots] or {name=""}
		local leggings=minetest.registered_items[self.armor_list.leggings] or {name=""}
		local helmet=minetest.registered_items[self.armor_list.helmet] or {name=""}

		local no_armor

		if helmet.name=="" and chestplate.name=="" and leggings.name=="" and boots.name=="" then
			no_armor = true
		end

		for _,obj in ipairs(self.object:get_children()) do --destroy old armor entities
			if not obj:is_player() and obj:get_luaentity()._armor then
				obj:set_detach()
			end
		end

		local tforms = self.armor_transforms

		if chestplate.name ~= "" then
			local armor_chest = mcl_mobs.add_armor_piece(chestplate.name, false)
			local armor_right = mcl_mobs.add_armor_piece(chestplate.name, "r")
			local armor_left = mcl_mobs.add_armor_piece(chestplate.name, "l")

			armor_chest:set_properties({visual_size = self.armor_transforms.chest[4] or vector.new(1,1,1)})
			armor_right:set_properties({visual_size = self.armor_transforms.arm_right[4] or vector.new(1,1,1)})
			armor_left:set_properties({visual_size = self.armor_transforms.arm_left[4] or vector.new(1,1,1)})

			armor_chest:set_attach(self.object, self.armor_transforms.chest[1], self.armor_transforms.chest[2], self.armor_transforms.chest[3] or vector.zero())
			armor_right:set_attach(self.object, self.armor_transforms.arm_right[1], self.armor_transforms.arm_right[2], self.armor_transforms.arm_right[3] or vector.zero())
			armor_left:set_attach(self.object, self.armor_transforms.arm_left[1], self.armor_transforms.arm_left[2], self.armor_transforms.arm_left[3] or vector.zero())
		end
		if leggings.name ~= "" then
			local armor_right = mcl_mobs.add_armor_piece(leggings.name, "r")
			local armor_left = mcl_mobs.add_armor_piece(leggings.name, "l")

			armor_right:set_properties({visual_size = self.armor_transforms.leg_right[4] or vector.new(1,1,1)})
			armor_left:set_properties({visual_size = self.armor_transforms.leg_left[4] or vector.new(1,1,1)})

			armor_right:set_attach(self.object, self.armor_transforms.leg_right[1], self.armor_transforms.leg_right[2], self.armor_transforms.leg_right[3] or vector.zero())
			armor_left:set_attach(self.object, self.armor_transforms.leg_left[1], self.armor_transforms.leg_left[2], self.armor_transforms.leg_left[3] or vector.zero())
		end
		if boots.name ~= "" then
			local armor_right = mcl_mobs.add_armor_piece(boots.name, "r")
			local armor_left = mcl_mobs.add_armor_piece(boots.name, "l")

			armor_right:set_properties({visual_size = self.armor_transforms.leg_right[4] or vector.new(1,1,1)})
			armor_left:set_properties({visual_size = self.armor_transforms.leg_left[4] or vector.new(1,1,1)})

			armor_right:set_attach(self.object, self.armor_transforms.leg_right[1], self.armor_transforms.leg_right[2], self.armor_transforms.leg_right[3] or vector.zero())
			armor_left:set_attach(self.object, self.armor_transforms.leg_left[1], self.armor_transforms.leg_left[2], self.armor_transforms.leg_left[3] or vector.zero())
		end
		if helmet.name ~= "" then
			local armor_right = mcl_mobs.add_armor_piece(helmet.name, "r")

			armor_right:set_properties({visual_size = self.armor_transforms.head[4] or vector.new(1,1,1)})

			armor_right:set_attach(self.object, self.armor_transforms.head[1], self.armor_transforms.head[2], self.armor_transforms.head[3] or vector.zero())
		end

		local armor_
		if type(self.armor) == "table" then
			armor_ = table.copy(self.armor)
			armor_.immortal = 1
		else
			armor_ = {immortal=1, fleshy = self.armor}
		end

		for _,item in pairs(self.armor_list) do
			if not item then return end
			if type(minetest.get_item_group(item, "mcl_armor_points")) == "number" then
				armor_.fleshy=armor_.fleshy-(minetest.get_item_group(item, "mcl_armor_points")*3.5)
			end
		end
		self.object:set_armor_groups(armor_)
	end
end

function mob_class:check_item_pickup()
	if self.pick_up and #self.pick_up > 0 or self.wears_armor then
		local p = self.object:get_pos()
		if not p then return end
		for _,o in pairs(minetest.get_objects_inside_radius(p,2)) do
			local l=o:get_luaentity()
			if l and l.name == "__builtin:item" then
				if not player_near(p) and l.itemstring:find("mcl_armor") and self.wears_armor then
					local armor_type
					if l.itemstring:find("chestplate") then
						armor_type = "chestplate"
					elseif l.itemstring:find("boots") then
						armor_type = "boots"
					elseif l.itemstring:find("leggings") then
						armor_type = "leggings"
					elseif l.itemstring:find("helmet") then
						armor_type = "helmet"
					end
					if not armor_type then
						return
					end
					if not self.armor_list then
						self.armor_list={helmet="",chestplate="",boots="",leggings=""}
					elseif self.armor_list[armor_type] and self.armor_list[armor_type] ~= "" then
						return
					end
					self.armor_list[armor_type]=ItemStack(l.itemstring):get_name()
					o:remove()
				end
				if self.pick_up then
					for k,v in pairs(self.pick_up) do
						local itemstack = ItemStack(l.itemstring)
						if not player_near(p) and self.on_pick_up and itemstack:get_name():find(v) then
							local r =  self.on_pick_up(self,l)
							if  r and r.is_empty and not r:is_empty() then
								l.itemstring = r:to_string()
							elseif r and r.is_empty and r:is_empty() then
								o:remove()
							end
						end
					end
				end
			end
		end
	end
end
