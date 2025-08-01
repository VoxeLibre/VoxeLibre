local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
--- Item and armor management

local function player_near(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos,2)) do
		if o:is_player() then return true end
	end
end

local function get_armor_texture(stack)
	local def = stack:get_definition()
	if not def or type(def._mcl_armor_texture) ~= "function" then return "" end
	return def._mcl_armor_texture(nil, stack)
end

function mob_class:set_armor_texture()
	if self.armor_list then
		local chestplate = ItemStack(self.armor_list.chestplate)
		local boots = ItemStack(self.armor_list.boots)
		local leggings = ItemStack(self.armor_list.leggings)
		local helmet = ItemStack(self.armor_list.helmet)

		local textures = {
			get_armor_texture(chestplate),
			get_armor_texture(helmet),
			get_armor_texture(boots),
			get_armor_texture(leggings)
		}
		local textures_fixed = {}
		for _, el in ipairs(textures) do
			if el ~= "" then
				table.insert(textures_fixed, el)
			end
		end
		local texture = table.concat(textures_fixed, "^")
		if texture == "" then texture = "blank.png" end
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
			if item then
				local def = ItemStack(item):get_definition()
				if def and def.groups and (def.groups.mcl_armor_points or 0) > 0 then
					armor_.fleshy = armor_.fleshy - (def.groups.mcl_armor_points * 3.5)
				end
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
				local stack = ItemStack(l.itemstring)
				local def = stack:get_definition()
				if not player_near(p) and def and def.groups and (def.groups.armor or 0) > 0 and self.wears_armor then
					local armor_type
					if (def.groups.armor_torso or 0) > 0 then
						armor_type = "chestplate"
					elseif (def.groups.armor_feet or 0) > 0 then
						armor_type = "boots"
					elseif (def.groups.armor_legs or 0) > 0 then
						armor_type = "leggings"
					elseif (def.groups.armor_head or 0) > 0 then
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
					self.armor_list[armor_type]=l.itemstring
					o:remove()
				end
				if self.pick_up then -- FIXME this section is bad
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
