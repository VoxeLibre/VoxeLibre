function mcl_mobs.mob:start_breed_giveup_timer()
	self.breed_giveup_timer = mcl_mobs.const.breed_giveup_timer
end

function mcl_mobs.mob:breeding_on_activate()
	if self.data.breeding then
		self:start_breed_giveup_timer()
	end
end

function mcl_mobs.mob:init_breeding()
	self:debug("initializing breeding")
	self.data.bred = true
	self.data.breeding = true
	self:start_breed_giveup_timer()
end

-- looking for hot singles in the area
function mcl_mobs.mob:find_mate()
	return self:get_near_object(self.def.view_range, function(self, obj)
		local luaentity = obj:get_luaentity()
		return luaentity -- dont fook with hoomans
			and luaentity.name == self.name -- this is MineClone, not Animal Crossing
			and not luaentity.data.bred -- no polygamy pls
			and not luaentity.data.baby -- no pedophila pls
	end)
end
