function mcl_mobs.mob:get_special_textures()
	if self.baby then
		return self:evaluate("baby_textures")
	elseif self.gotten then
		return self:evaluate("gotten_textures")
	elseif self.easteregg.rainbow then
		return self:evaluate("rainbow_textures", mcl_mobs.util.color_from_hue(self.easteregg.hue))
	end
end

function mcl_mobs.mob:get_textures()
	return self:get_special_textures() or self:calculate_textures(self.def.textures)
end

function mcl_mobs.mob:update_textures()
	self:set_properties({textures = self:get_textures()})
end
