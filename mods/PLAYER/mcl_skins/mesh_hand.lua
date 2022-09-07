local function make_texture(base, colorspec)
	local output = ""
	if mcl_skins.masks[base] then
		output = mcl_skins.masks[base] ..
			"^[colorize:" .. minetest.colorspec_to_colorstring(colorspec) .. ":alpha"
	end
	if #output > 0 then output = output .. "^" end
	output = output .. base
	return output
end

function mcl_skins.get_skin_list()
	local list = {}
	for _, base in pairs(mcl_skins.base) do
		for _, base_color in pairs(mcl_skins.base_color) do
			local id = base:gsub(".png$", "") .. minetest.colorspec_to_colorstring(base_color):gsub("#", "")
			local female = {
				texture = make_texture(base, base_color),
				slim_arms = true,
				id = id .. "_female"
			}
			table.insert(list, female)
			
			local male = {
				texture = make_texture(base, base_color),
				slim_arms = false,
				id = id .. "_male"
			}
			table.insert(list, male)
		end
	end
	for _, skin in pairs(mcl_skins.simple_skins) do
		table.insert(list, {
			texture = skin.texture,
			slim_arms = skin.slim_arms,
			id = skin.texture:gsub(".png$", "") .. "_" .. (skin.slim_arms and "female" or "male"),
		})
	end
	return list
end

function mcl_skins.get_node_id_by_player(player)
	local skin = mcl_skins.players[player]
	if skin.simple_skins_id then
		local skin = mcl_skins.simple_skins[skin.simple_skins_id]
		return skin.texture:gsub(".png$", "") ..
			"_" .. (skin.slim_arms and "female" or "male")
	else
		return skin.base:gsub(".png$", "") ..
			minetest.colorspec_to_colorstring(skin.base_color):gsub("#", "") ..
			"_" .. (skin.slim_arms and "female" or "male")
	end
end
