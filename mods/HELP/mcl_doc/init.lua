-- Disable built-in factoids; it is planned to add custom ones as replacements
doc.sub.items.disable_core_factoid("node_mining")
doc.sub.items.disable_core_factoid("tool_capabilities")

-- Help button callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_doc then
		doc.show_doc(player:get_player_name())
	end
end)

-- doc_items factoids

-- dig_by_water
doc.sub.items.register_factoid("nodes", "drop_destroy", function(itemstring, def)
	if def.groups.dig_by_water then
		return "Water can flow into this block and cause it to drop as an item."
	end
	return ""
end)

-- usable by hoes
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.cultivatable == 2 then
		return "This block can be turned into dirt with a hoe."
	elseif def.groups.cultivatable == 2 then
		return "This block can be turned into farmland with a hoe."
	end
	return ""
end)

-- soil
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	local datastring = ""
	if def.groups.soil_sapling == 2 then
		datastring = datastring .. "This block acts as a soil for all saplings." .. "\n"
	elseif def.groups.soil_sapling == 1 then
		datastring = datastring .. "This block acts as a soil for some saplings." .. "\n"
	end
	if def.groups.soil_sugarcane then
		datastring = datastring .. "Sugar canes will grow on this block." .. "\n"
	end
	if def.groups.soil_nether_wart then
		datastring = datastring .. "Nether wart will grow on this block." .. "\n"
	end
	return datastring
end)

-- nodes which have flower placement rules
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	local datastring = ""
	if def.groups.place_flowerlike == 1 then
		return "This plant can only grow on dirt, grass blocks and podzol. To survive, it needs to have an unobstructed view to the sky above or be exposed to a light level of 8 or higher."
	end
	return ""
end)

-- flammable
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.flammable then
		return "This block is flammable."
	end
	return ""
end)

-- destroys_items
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.destroys_items then
		return "This block destroys any item it touches."
	end
	return ""
end)


-- Comestibles
doc.sub.items.register_factoid(nil, "use", function(itemstring, def)
	local s = ""
	if def.groups.eatable and not def._doc_items_usagehelp then
		if def.groups.food == 2 then
			s = s .. "To eat it, wield it, then rightclick."
			if def.groups.can_eat_when_full == 1 then
				s = s .. "\n" .. "You can eat this even when your hunger bar is full."
			else
				s = s .. "\n" .. "You cannot eat this when your hunger bar is full."
			end
		elseif def.groups.food == 3 then
			s = s .. "To drink it, wield it, then rightclick."
			if def.groups.can_eat_when_full ~= 1 then
				s = s .. "\n" .. "You cannot drink this when your hunger bar is full."
			end
		else
			s = s .. "To consume it, wield it, then rightclick."
			if def.groups.can_eat_when_full ~= 1 then
				s = s .. "\n" .. "You cannot consume this when your hunger bar is full."
			end
		end
		if def.groups.no_eat_delay ~= 1 then
			s = s .. "\n" .. "You have to wait for about 2 seconds before you can eat or drink again."
		end
	end
	return s
end)

doc.sub.items.register_factoid(nil, "groups", function(itemstring, def)
	local s = ""
	if def.groups.eatable and def.groups.eatable > 0 then
		s = s .. string.format("Hunger points restored: %d", def.groups.eatable)
	end
	if def._mcl_saturation and def._mcl_saturation > 0 then
		s = s .. "\n" .. string.format("Saturation points restored: %.1f", def._mcl_saturation)
	end
	return s
end)

-- Mining, hardness and all that
doc.sub.items.register_factoid("nodes", "mining", function(itemstring, def)
	local pickaxey = { "Diamond Pickaxe", "Iron Pickaxe", "Stone Pickaxe", "Golden Pickaxe", "Wooden Pickaxe" }
	local axey = { "Diamond Axe", "Iron Axe", "Stone Axe", "Golden Axe", "Wooden Axe" }
	local shovely = { "Diamond Shovel", "Iron Shovel", "Stone Shovel", "Golden Shovel", "Wooden Shovel" }

	local datastring = ""
	local groups = def.groups
	if groups then
		if groups.dig_immediate == 3 then
			datastring = datastring .. "This block can be mined by any tool instantly." .. "\n"
		else
			local tool_minable = false

			if groups.pickaxey then
				for g=1, 6-groups.pickaxey do
					datastring = datastring .. "• " .. pickaxey[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.axey then
				for g=1, 6-groups.axey do
					datastring = datastring .. "• " .. axey[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.shovely then
				for g=1, 6-groups.shovely do
					datastring = datastring .. "• " .. shovely[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.shearsy then
				datastring = datastring .. "• Shears" .. "\n"
				tool_minable = true
			end
			if groups.swordy then
				datastring = datastring .. "• Sword" .. "\n"
				tool_minable = true
			end
			if groups.handy then
				datastring = datastring .. "• Hand" .. "\n"
				tool_minable = true
			end

			if tool_minable then
				datastring = "This block can be mined by:\n" .. datastring .. "\n"
			end
		end
	end
	local hardness = def._mcl_hardness
	if not hardness then
		hardness = 0
	end
	if hardness == -1 then
		datastring = datastring .. "Hardness: ∞"
	else
		datastring = datastring .. string.format("Hardness: %.2f", hardness)
	end
	local blast = def._mcl_blast_resistance
	if not blast then
		blast = 0
	end
	if blast >= 1000 then
		datastring = datastring .. "\n" .. "This block will not be destroyed by TNT explosions."
	end
	return datastring
end)

-- Special drops when mined by shears
doc.sub.items.register_factoid("nodes", "drops", function(itemstring, def)
	if def._mcl_shears_drop == true then
		return "This block drops itself when mined by shears."
	elseif type(def._mcl_shears_drop) == "table" then
		local drops = {}
		for i=1, #def._mcl_shears_drop do
			local desc = minetest.registered_items[def._mcl_shears_drop[i]].description
			if desc then
				table.insert(drops)
			else
				table.insert(def._mcl_shears_drop[i])
			end
		end
		local ret = string.format("This blocks drops the following when mined by shears: %s", table.concat(drops, ", "))
		return ret
	end
	return ""
end)



-- TODO: Blast resistance (omitted for now because explosions ignore hardness)
