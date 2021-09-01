function mcl_mobs.mob:update_nametag()
	self:update_easteregg()

	self:set_properties({
		nametag = self.data.nametag,
	})
end
