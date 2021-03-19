local time = 0
local update_time = tonumber(minetest.settings:get("wieldview_update_time"))
if not update_time then
	update_time = 2
	minetest.settings:set("wieldview_update_time", tostring(update_time))
end
local node_tiles = minetest.settings:get_bool("wieldview_node_tiles")
if not node_tiles then
	node_tiles = false
	minetest.settings:set("wieldview_node_tiles", "false")
end

wieldview = {
	wielded_item = {},
	transform = {},
}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/transform.lua")

wieldview.get_item_texture = function(self, item)
	local texture = "blank.png"
	if item ~= "" then
		if minetest.registered_items[item] then
			if minetest.registered_items[item].inventory_image ~= "" then
				texture = minetest.registered_items[item].inventory_image
			elseif node_tiles == true and minetest.registered_items[item].tiles
					and type(minetest.registered_items[item].tiles[1]) == "string"
					and minetest.registered_items[item].tiles[1] ~= "" then
				texture = minetest.inventorycube(minetest.registered_items[item].tiles[1])
			end
		end
		-- Get item image transformation, first from group, then from transform.lua
		local transform = minetest.get_item_group(item, "wieldview_transform")
		if transform == 0 then
			transform = wieldview.transform[item]
		end
		if transform then
			-- This actually works with groups ratings because transform1, transform2, etc.
			-- have meaning and transform0 is used for identidy, so it can be ignored
			texture = texture.."^[transform"..tostring(transform)
		end
	end
	return texture
end

wieldview.update_wielded_item = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local stack = player:get_wielded_item()
	local item = stack:get_name()
	if not item then
		return
	end
	if self.wielded_item[name] then
		if self.wielded_item[name] == item then
			return
		end
		if not armor.textures[name] then
			return
		end
		armor.textures[name].wielditem = self:get_item_texture(item)
		armor:update_player_visuals(player)
	end
	self.wielded_item[name] = item
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	wieldview.wielded_item[name] = ""
	minetest.after(0, function(player)
		wieldview:update_wielded_item(player)
		local itementity = minetest.add_entity(player:get_pos(), "wieldview:wieldnode")
		itementity:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 0, 45))
		itementity:get_luaentity().wielder = name
	end, player)
end)

minetest.register_globalstep(function()
	for _,player in pairs(minetest.get_connected_players()) do
		wieldview:update_wielded_item(player)
	end
end)

minetest.register_entity("wieldview:wieldnode", {
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
        minetest.chat_send_all(dump2(itemstring, "itemstring"))
				local def = minetest.registered_items[itemstring]
				self.object:set_properties({glow = def and def.light_source or 0})

        -- wield item as cubic
				if armor.textures[self.wielder].wielditem == "blank.png" then
					self.object:set_properties({textures = {itemstring}})
				else -- displayed item as flat
					self.object:set_properties({textures = {""}})
				end

        if itemstring == "" then -- holding item
          player:set_bone_position("Arm_Right", vector.new(0, 0, 0), vector.new(0, 0, 0))
        else -- empty hands
          player:set_bone_position("Arm_Right", vector.new(0, 0, 0), vector.new(20, 0, 0))
        end

				self.itemstring = itemstring
			end
		else
			self.object:remove()
		end
	end,
})
