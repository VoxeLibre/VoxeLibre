mcl_wieldview = {
	players = {}
}

function mcl_wieldview.get_item_texture(itemname)
	if itemname == "" then
		return
	end

	local def = minetest.registered_items[itemname]
	if not def then
		return
	end

	local inv_image = def.inventory_image
	if inv_image == "" then
		return
	end

	local texture = inv_image

	local transform = minetest.get_item_group(itemname, "wieldview_transform")
	if transform then
		-- This actually works with groups ratings because transform1, transform2, etc.
		-- have meaning and transform0 is used for identidy, so it can be ignored
		texture = texture .. "^[transform" .. transform
	end

	return texture
end

function mcl_wieldview.update_wielded_item(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local itemstack = player:get_wielded_item()
	local itemname = itemstack:get_name()

	local def = mcl_wieldview.players[name]

	if def.item == itemname then
		return
	end

	def.item = itemname
	def.texture = mcl_wieldview.get_item_texture(itemname) or "blank.png"

	mcl_player.player_set_wielditem(player, def.texture)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mcl_wieldview.players[name] = {item = "", texture = "blank.png"}

	minetest.after(0, function()
		if not player:is_player() then
			return
		end

		mcl_wieldview.update_wielded_item(player)

		local itementity = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldnode")
		itementity:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 0, 45))
		itementity:get_luaentity().wielder = name
	end)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcl_wieldview.players[name] = nil
end)

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		mcl_wieldview.update_wielded_item(player)
	end
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

	itemstring = "",

	on_step = function(self)
		local player = minetest.get_player_by_name(self.wielder)
		if player then
			local wielded = player:get_wielded_item()
			local itemstring = wielded:get_name()

			if self.itemstring ~= itemstring then
				local def = minetest.registered_items[itemstring]
				self.object:set_properties({glow = def and def.light_source or 0})

				-- wield item as cubic
				if mcl_wieldview.players[self.wielder].texture == "blank.png" then
					self.object:set_properties({textures = {itemstring}})
				-- wield item as flat
				else
					self.object:set_properties({textures = {""}})
				end

				self.itemstring = itemstring
			end
		else
			self.object:remove()
		end
	end,
})
