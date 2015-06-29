
armor_api = {
	player_hp = {},
}

armor_api.get_armor_textures = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local textures = {}
	local player_inv = player:get_inventory()
	for _,v in ipairs({"head", "torso", "legs", "feet"}) do
		local stack = player_inv:get_stack("armor_"..v, 1)
		if stack:get_definition().groups["armor_"..v] then
			local item = stack:get_name()
			textures[v] = item:gsub("%:", "_")..".png"
		end
	end
	return textures
end

armor_api.set_player_armor = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	local armor_level = 0
	for _,v in ipairs({"head", "torso", "legs", "feet"}) do
		local stack = player_inv:get_stack("armor_"..v, 1)
		local armor = stack:get_definition().groups["armor_"..v] or 0
		armor_level = armor_level + armor
	end
	local armor_groups = {fleshy=100}
	if armor_level > 0 then
		armor_groups.level = math.floor(armor_level / 20)
		armor_groups.fleshy = 100 - armor_level
	end
	player:set_armor_groups(armor_groups)
	uniskins:update_player_visuals(player)
end

armor_api.update_armor = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local hp = player:get_hp()
	if hp == nil or hp == 0 or hp == self.player_hp[name] then
		return
	end
	if self.player_hp[name] > hp then
		local player_inv = player:get_inventory()
		local armor_inv = minetest.get_inventory({type="detached", name=name.."_outfit"})
		if armor_inv == nil then
			return
		end
		local heal_max = 0
		for _,v in ipairs({"head", "torso", "legs", "feet"}) do
			local stack = armor_inv:get_stack("armor_"..v, 1)
			if stack:get_count() > 0 then
				local use = stack:get_definition().groups["armor_use"] or 0
				local heal = stack:get_definition().groups["armor_heal"] or 0
				local item = stack:get_name()
				stack:add_wear(use)
				armor_inv:set_stack("armor_"..v, 1, stack)
				player_inv:set_stack("armor_"..v, 1, stack)
				if stack:get_count() == 0 then
					local desc = minetest.registered_items[item].description
					if desc then
						minetest.chat_send_player(name, "Your "..desc.." got destroyed!")
					end				
					self:set_player_armor(player)
				end
				heal_max = heal_max + heal
			end
		end
		if heal_max > math.random(100) then
			player:set_hp(self.player_hp[name])
			return
		end		
	end
	self.player_hp[name] = hp
end

