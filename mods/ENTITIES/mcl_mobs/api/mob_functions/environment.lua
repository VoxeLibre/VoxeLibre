local minetest_line_of_sight = minetest.line_of_sight
local minetest_dir_to_yaw    = minetest.dir_to_yaw
local minetest_yaw_to_dir    = minetest.yaw_to_dir
local minetest_get_node      = minetest.get_node
local minetest_get_item_group = minetest.get_item_group

local vector_new = vector.new
local vector_multiply = vector.multiply

-- default function when mobs are blown up with TNT
local do_tnt = function(obj, damage)

	obj.object:punch(obj.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = damage},
	}, nil)

	return false, true, {}
end

--a fast function to be able to detect only players without using objects_in_radius
mobs.detect_closest_player_within_radius = function(self, line_of_sight, radius, object_height_adder)
	
	line_of_sight = line_of_sight or true --fallback line_of_sight
	radius = radius or 10 -- fallback radius
	object_height_adder = object_height_adder or 0 --fallback entity (y height) addition for line of sight

	local pos1 = self.object:get_pos()
	local players_in_area = {}
	local winner_player = nil
	local players_detected = 0

	--get players in radius
	for _,player in pairs(minetest.get_connected_players()) do
		if player and player:get_hp() > 0 then

			local pos2 = player:get_pos()

			local distance = vector.distance(pos1,pos2)

			if distance <= radius then
				if line_of_sight then
					--must add eye height or stuff breaks randomly because of
					--seethrough nodes being a blocker (like grass)
					if minetest_line_of_sight(
							vector_new(pos1.x, pos1.y + object_height_adder, pos1.z), 
							vector_new(pos2.x, pos2.y + player:get_properties().eye_height, pos2.z)
						) then
						players_detected = players_detected + 1
						players_in_area[player] = distance
					end
				else
					players_detected = players_detected + 1
					players_in_area[player] = distance
				end
			end
		end
	end


	--return if there's no one near by
	if players_detected <= 0 then --handle negative numbers for some crazy error that could possibly happen
		return nil
	end

	--do a default radius max
	local shortest_disance = radius + 1

	--sort through players and find the closest player
	for player,distance in pairs(players_in_area) do
		if distance < shortest_disance then
			shortest_disance = distance
			winner_player = player
		end
	end

	return(winner_player)
end


--check if a mob needs to jump
mobs.jump_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector_multiply(dir, radius)

	--only jump if there's a node and a non-solid node above it
    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0

	test_dir.y = test_dir.y + 1

	local green_flag_2 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") == 0

    if green_flag_1 and green_flag_2 then
		--can jump over node
        return(1)
	elseif green_flag_1 and not green_flag_2 then 
		--wall in front of mob
		return(2)
    end

	--nothing to jump over
	return(0)
end