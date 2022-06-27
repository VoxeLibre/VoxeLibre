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
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = false,
		textures         = {""},
		automatic_rotate = 1.5,
		is_visible       = true,
		pointable        = false,
		collide_with_objects = false,
		static_save = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.21, y = 0.21},
	},
	
	on_step = function(self)
		local player = self._wielder
		
		if not player or not player:is_player() then
			self.object:remove()
			return
		end
		
		local item = player:get_wielded_item():get_name()

		if item == self._item then return end
		
		self._item = item
		
		local def = player:get_wielded_item():get_definition()
		if def and def._mcl_wieldview_item then
			item = def._mcl_wieldview_item
		end
		
		local item_def = minetest.registered_items[item]
		self.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	end,
})
