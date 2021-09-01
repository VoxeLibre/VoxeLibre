function mcl_mobs.mob:update_collisionbox()
	local box = self.def.collisionbox

	if self.baby and self.def.baby_size then
		box = mcl_mobs.util.scale_size(box, self.def.baby_size)
	end

	if self.easteregg.upside_down then
		box[2], box[5] = -box[5], -box[2]
	end

	self.collisionbox = {
		min = vector.new(box[1], box[2], box[3]),
		max = vector.new(box[4], box[5], box[6]),
	}

	self:set_properties({collisionbox = box})

	self.collisionbox_cache = nil
	mcl_mount.update_children_visual_size(self.object)
end
