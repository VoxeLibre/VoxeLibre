local get_item_group = minetest.get_item_group

minetest.register_on_joinplayer(function(player)
	if not player or not player:is_player() then
		return
	end
	local itementity = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldnode")
	if not itementity then return end
	itementity:set_attach(player, "Wield_Item", vector.new(0, 0, 0), vector.new(0, 0, 0))
	--itementity:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 45, 90))
	itementity:get_luaentity()._wielder = player
end)

minetest.register_entity("mcl_wieldview:wieldnode", {
	visual = "wielditem",
	physical = false,
	pointable = false,
	collide_with_objects = false,
	static_save = false,
	visual_size  = {x = 0.21, y = 0.21},
	on_step = function(self)
		if not self._wielder or not self._wielder:is_player() then
			self.object:remove()
		end
		local player = self._wielder
		
		local item = player:get_wielded_item():get_name()

		if item == self._item then return end
		
		self._item = item
		
		if get_item_group(item, "no_wieldview") ~= 0 then
			local def = player:get_wielded_item():get_definition()
			if def and def._wieldview_item then
				item = def._wieldview_item
			else
				item = ""
			end
		end
		
		local item_def = minetest.registered_items[item]
		self.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	end,
})
