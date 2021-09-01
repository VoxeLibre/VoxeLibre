function mcl_mobs.mob:set_properties(props)
	self.object:set_properties(props)
	self:reload_properties()
end

function mcl_mobs.mob:reload_properties()
	self.properties = self.object:get_properties()
end
