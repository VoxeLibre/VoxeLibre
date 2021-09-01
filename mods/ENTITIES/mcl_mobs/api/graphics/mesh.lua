function mcl_mobs.mob:update_mesh()
	self:set_properties({
		visual = "mesh",
		mesh = self.def.model,
	})
end
