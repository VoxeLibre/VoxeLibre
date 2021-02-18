local has_mcl_skins = minetest.get_modpath("mcl_skins") ~= nil

local def = minetest.registered_items[""]

local list
-- mcl_skins is enabled
if has_mcl_skins == true then
	list = mcl_skins.list
else
	list = { "hand" }
end

--generate a node for every skin
for _,texture in pairs(list) do
	-- This is a fake node that should never be placed in the world
	minetest.register_node("mcl_meshhand:"..texture, {
		description = "",
		tiles = {texture..".png"},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		visual_scale = 1,
		wield_scale = {x=1,y=1,z=1},
		paramtype = "light",
		drawtype = "mesh",
		mesh = "mcl_meshhand.b3d",
		-- Prevent construction
		node_placement_prediction = "",
		on_construct = function(pos)
			minetest.log("error", "[mcl_meshhand] Trying to construct mcl_meshhand:"..texture.." at "..minetest.pos_to_string(pos))
			minetest.remove_node(pos)
		end,
		drop = "",
		on_drop = function()
			return ""
		end,
		groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
		range = def.range,
		})
end

if has_mcl_skins == true then
	--change the player's hand to their skin
	mcl_skins.register_on_set_skin(function(player, skin)
		local name = player:get_player_name()
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:"..skin)
	end)
else
	minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:hand")
	end)
end
