local get_connected_players = minetest.get_connected_players
local get_item_group = minetest.get_item_group

mcl_wieldview = {
	players = {}
}

function mcl_wieldview.get_item_texture(itemname)
	if itemname == "" or minetest.get_item_group(itemname, "no_wieldview") ~= 0 then
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

	local transform = get_item_group(itemname, "wieldview_transform")
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
	local itemstack = player:get_wielded_item()
	local itemname = itemstack:get_name()

	local def = mcl_wieldview.players[player]

	if def.item == itemname then
		return
	end

	def.item = itemname
	def.texture = mcl_wieldview.get_item_texture(itemname) or "blank.png"

	mcl_player.player_set_wielditem(player, def.texture)
end

minetest.register_on_joinplayer(function(player)
	mcl_wieldview.players[player] = {item = "", texture = "blank.png"}

	minetest.after(0, function()
		if not player:is_player() then
			return
		end

		mcl_wieldview.update_wielded_item(player)

		local itementity = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldnode")
		itementity:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 0, 45))
		itementity:get_luaentity().wielder = player
	end)
end)

minetest.register_on_leaveplayer(function(player)
	mcl_wieldview.players[player] = nil
end)

minetest.register_globalstep(function()
    local players = get_connected_players()
	for i = 1, #players do
		mcl_wieldview.update_wielded_item(players[i])
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
		if self.wielder:is_player() then
			local def = mcl_wieldview.players[self.wielder]
			local itemstring = def.item

			if self.itemstring ~= itemstring then
				local itemdef = minetest.registered_items[itemstring]
				self.object:set_properties({glow = itemdef and itemdef.light_source or 0})

				-- wield item as cubic
				if def.texture == "blank.png" then
					self.object:set_properties({textures = {itemstring}})
				-- wield item as flat
				else
					self.object:set_properties({textures = {""}})
				end

				if minetest.get_item_group(itemstring, "no_wieldview") ~= 0 then
					self.object:set_properties({textures = {""}})
				end

				self.itemstring = itemstring
			end
		else
			self.object:remove()
		end
	end,
})
