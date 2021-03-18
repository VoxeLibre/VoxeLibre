MCLPlayer = class(MCLObject)

MCLPlayer:__cache_getter("meta", function(self)
	return self.object:get_meta()
end)

MCLPlayer:__cache_getter("inventory", function(self)
	return self.object:get_inventory()
end)

MCLPlayer:__override_pipe("death_drop", function(self, inventory, listname, index, stack)
	if not mcl_gamerules.keepInventory then
		return self, inventory, listname, index, stack
	end
end)

function MCLPlayer:on_damage(damage, source, knockback)
	MCLObject.on_damage(self, damage, source, knockback)
end
