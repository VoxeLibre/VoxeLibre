
if minetest.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"mobs:meat_raw"}, 5},
		{"dro", {"mobs:meat"}, 5},
		{"dro", {"mobs:nametag"}, 1},
		{"dro", {"mobs:leather"}, 5},
		{"dro", {"mobs:net"}, 1},
		{"dro", {"mobs:magic_lasso"}, 1},
		{"dro", {"mobs:shears"}, 1},
		{"dro", {"mobs:protector"}, 1},
		{"lig"},
	})
end
