player_running_physics = {}
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		--local pos = player:getpos()
		--print(dump(player:get_player_control().up))
		if player:get_player_control().up == true and player_running_physics[player:get_player_name()] == nil then
			minetest.after(0.05, function()
				if player:get_player_control().up == false then
					minetest.after(0.05, function()
						if player:get_player_control().up == true then
							player:set_physics_override(1.5, 1, 1)
							player_running_physics[player:get_player_name()] = true
							--print("test1")
						end
					end)
				end
			end)
		elseif player:get_player_control().up == false and player_running_physics[player:get_player_name()] == true then
			--minetest.after(0.2, function()
				if player:get_player_control().up == false then
					player_running_physics[player:get_player_name()] = nil
					player:set_physics_override(1, 1, 1)
					--print("test2")
				end
			--end)
		end
		
	end
end)