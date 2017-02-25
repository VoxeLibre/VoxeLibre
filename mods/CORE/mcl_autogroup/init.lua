local overwrite = function()
	local materials = { "wood", "gold", "stone", "iron", "diamond" }
	local material_divisors = { 2, 12, 4, 6, 8 }
	local basegroups = { "pickaxey", "axey", "shovely" }
	local minigroups = { "handy", "shearsy", "swordy" }

	for nname, ndef in pairs(minetest.registered_nodes) do
		local groups_changed = false
		local newgroups = table.copy(ndef.groups)
		if (nname ~= "ignore") then
			-- Automatically assign the “solid” group for solid nodes
			if (ndef.walkable == nil or ndef.walkable == true)
					and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
					and (ndef.node_box == nil or ndef.node_box.type == "regular")
					and (ndef.groups.falling_node == 0 or ndef.groups.falling_node == nil)
					and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
				newgroups.solid = 1
				groups_changed = true
			end

			-- Hack in digging times
			local hardness = ndef._mcl_hardness
			if not hardness then
				hardness = 0
			end
			-- Handle pickaxey, axey and shovely, and also handy indirectly
			for _, basegroup in pairs(basegroups) do
				if (hardness ~= -1 and ndef.groups[basegroup]) then
					for g=1,#materials do
						local diggroup = basegroup.."_dig_"..materials[g]
						local time, validity_factor
						if g >= ndef.groups[basegroup] then
							-- Valid tool
							validity_factor = 1.5
						else
							-- Wrong tool (higher digging time)
							validity_factor = 5
						end
						time = (hardness * validity_factor) / material_divisors[g]
						if time <= 0.05 then
							time = 1
						else
							time = math.ceil(time * 20)
						end
						newgroups[diggroup] = time
						groups_changed = true
					end
					if not ndef.groups.handy then
						local time = hardness * 5
						if time <= 0.05 then
							time = 1
						else
							time = math.ceil(time * 20)
						end
						newgroups.handy_dig = time
					end
				end
			end

			if groups_changed then
				minetest.override_item(nname, {
					groups = newgroups
				})
			end
		end
	end
end

overwrite()
