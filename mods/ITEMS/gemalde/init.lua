-- Count the number of pictures.
local function get_picture(number)
	local filename	= minetest.get_modpath("gemalde").."/textures/gemalde_"..number..".png"
	local file		= io.open(filename, "r")
	if file ~= nil then io.close(file) return true else return false end
end

local N = 1

while get_picture(N) == true do
	N = N + 1
end

N = N - 1

-- register for each picture
for n=1, N do

local groups = {choppy=2, dig_immediate=3, picture=1, not_in_creative_inventory=1}
if n == 1 then
	groups = {choppy=2, dig_immediate=3, picture=1, deco_block=1}
end

local desc
if n == 1 then
	desc = "Painting"
else
	desc = "Painting ("..n..")"
end

-- inivisible node
minetest.register_node("gemalde:node_"..n.."", {
	description = desc,
	drawtype = "signlike",
	tiles = {"gemalde_"..n..".png","gemalde_bg.png"},
	visual_scale = 3.0,
	inventory_image = "gemalde_node.png",
	is_ground_content = false,
	wield_image = "gemalde_node.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -1.5, -1.5, -0.4, 1.5, 1.5 },
	},
	drop = "gemalde:node_1",
	groups = groups,

	on_rightclick = function(pos, node, clicker)
	
		local length = string.len (node.name)
		local number = string.sub (node.name, 14, length)
		
		-- TODO. Reducing currently not working, because sneaking prevents right click.
		local keys=clicker:get_player_control()
		if keys["sneak"]==false then
			if number == tostring(N) then
				number = 1
			else
				number = number + 1
			end
		else
			if number == 1 then
				number = N - 1
			else
				number = number - 1
			end
		end

		print("[gemalde] number is "..number.."")
		node.name = "gemalde:node_"..number..""
		minetest.set_node(pos, node)
	end,

--	TODO.
--	on_place = minetest.rotate_node
})

end

-- initial craft
minetest.register_craft({
	output = 'gemalde:node_1',
	recipe = {
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
		{'mcl_core:stick', 'group:wool', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
	}
})

