function mcl_mobs.mob:update_visual_size()
	local size = self.def.visual_size

	if self.data.size then
		mcl_mobs.util.scale_size(size, self.data.size)
	end

	if self.data.baby and self.def.baby_size then
		mcl_mobs.util.scale_size(size, self.def.baby_size)
	end

	local parent = self.object:get_attach()

	if parent then
		size = vector.divide(size, parent:get_properties().visual_size)
	end

	self:set_properties({visual_size = size})

	mcl_mount.update_children_visual_size(self.object)
end
