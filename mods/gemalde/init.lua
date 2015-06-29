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
	groups = {choppy=2, dig_immediate=3, picture=1}
end

-- inivisible node
minetest.register_node("gemalde:node_"..n.."", {
	description = "Picture #"..n.."",
	drawtype = "signlike",
	tiles = {"gemalde_"..n..".png"},
	visual_scale = 3.0,
	inventory_image = "gemalde_node.png",
	wield_image = "gemalde_node.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
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
		minetest.env:set_node(pos, node)
	end,

--	TODO.
--	on_place = minetest.rotate_node
})

-- crafts
if n < N then
minetest.register_craft({
	output = 'gemalde:node_'..n..'',
	recipe = {
		{'gemalde:node_'..(n+1)..''},
	}
})
end

n = n + 1

end

-- close the craft loop
minetest.register_craft({
	output = 'gemalde:node_'..N..'',
	recipe = {
		{'gemalde:node_1'},
	}
})

-- initial craft
minetest.register_craft({
	output = 'gemalde:node_1',
	recipe = {
		{'default:paper', 'default:paper'},
		{'default:paper', 'default:paper'},
		{'default:paper', 'default:paper'},
	}
})

-- reset several pictures to #1
minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 2',
	recipe = {'group:picture', 'group:picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 3',
	recipe = {'group:picture', 'group:picture', 'group:picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 4',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 5',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 6',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 7',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 8',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 9',
	recipe = {
			'group:picture', 'group:picture', 'group:picture', 
			'group:picture', 'group:picture', 'group:picture', 
			'group:picture', 'group:picture', 'group:picture'
		}
})
