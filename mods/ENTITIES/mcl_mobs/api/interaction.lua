function mcl_mobs.mob:on_rightclick(clicker)
	local itemstack = clicker:get_wielded_item()

	if self:on_rightclick_handler(clicker, itemstack) then
		clicker:set_wielded_item(itemstack)
	end
end

function mcl_mobs.mob:feed(clicker, itemname)
	if self.data.heal_with[itemname] and self.data.health < self.def.health_max then
		self:heal()
	elseif self.def.boost_with[itemname] and self.data.baby then
		self:boost()
	elseif self.def.breed_with[itemname] and not self.data.bred then
		self:init_breeding()
	elseif self.data.tame_with[itemname] and not self.def.tamed then
		self:tame(clicker)
	else
		return false
	end

	return true
end

function mcl_mobs.mob:on_rightclick_handler(clicker, itemstack)
	if self.dead then
		return false
	end

	if self.def.on_rightclick then
		if self.def.on_rightclick(clicker, itemstack) then
			return true
		end
	end

	local itemname = itemstack:get_name()

	if not self.def.ignores_nametag and itemname == "mcl_mobitems:nametag" then
		local tag = item:get_meta():get_string("name")
		if tag ~= "" then
			self.data.nametag = tag
			self:update_nametag()

			return mcl_mobs.util.take_item(clicker, itemstack)
		end
	end

	if self:feed(clicker, itemstack) then
		mcl_mobs.util.take_item(clicker, itemname)
		self:play_sound_specific("mobs_mc_animal_eat_generic")
		return true
	end

	if not self.data.gotten and self.def.get_with[itemname] and self.def.get(self, clicker, itemstack) then
		self.data.gotten = true
		self.data.gotten_timer = self:evaluate("gotten_cooldown")
		return true
	end
end
