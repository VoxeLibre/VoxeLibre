local mcl_skins_enabled = minetest.global_exists("mcl_skins")

-- This is a fake node that should never be placed in the world
local node_def = {
	description = "",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	visual_scale = 1,
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	node_placement_prediction = "",
	on_construct = function(pos)
		local name = get_node(pos).name
		local message = "[mcl_meshhand] Trying to construct " .. name .. " at " .. minetest.pos_to_string(pos)
		minetest.log("error", message)
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function() return "" end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = minetest.registered_items[""].range
}

local function player_base_to_node_id(base, colorspec, sex)
	return base:gsub("%.", "") .. minetest.colorspec_to_colorstring(colorspec):gsub("#", "") .. sex
end

if mcl_skins_enabled then
	local bases = mcl_skins.base
	local base_colors = mcl_skins.base_color
	
	-- Generate a node for every skin
	for _, base in pairs(bases) do
		for _, base_color in pairs(base_colors) do
			local node_id = player_base_to_node_id(base, base_color, "male")
			local texture = mcl_skins.make_hand_texture(base, base_color)
			local male = table.copy(node_def)
			male._mcl_hand_id = node_id
			male.mesh = "mcl_meshhand.b3d"
			male.tiles = {texture}
			minetest.register_node("mcl_meshhand:" .. node_id, male)
			
			node_id = player_base_to_node_id(base, base_color, "female")
			local female = table.copy(node_def)
			female._mcl_hand_id = node_id
			female.mesh = "mcl_meshhand_female.b3d"
			female.tiles = {texture}
			minetest.register_node("mcl_meshhand:" .. node_id, female)
		end
	end
else
	node_def._mcl_hand_id = "hand"
	node_def.mesh = "mcl_meshhand.b3d"
	node_def.tiles = {"character.png"}
	minetest.register_node("mcl_meshhand:hand", node_def)
end

if mcl_skins_enabled then
	-- Change the player's hand to their skin
	mcl_skins.register_on_set_skin(function(player)
		local data = mcl_skins.players[player:get_player_name()]
		local node_id = player_base_to_node_id(data.base, data.base_color, data.slim_arms and "female" or "male")
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:" .. node_id)
	end)
else
	minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:hand")
	end)
end
