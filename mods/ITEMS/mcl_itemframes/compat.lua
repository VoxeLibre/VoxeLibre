
local entity_stub = {
	on_activate = function(self)
		local pos = self.object:get_pos()
		self.object:remove()
		mcl_itemframes.update_entity(pos)
	end
}

minetest.register_entity("mcl_itemframes:map", entity_stub)
minetest.register_entity("mcl_itemframes:glow_item", entity_stub)
minetest.register_entity("mcl_itemframes:glow_map", entity_stub)
