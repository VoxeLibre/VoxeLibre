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
	if def.groups.eatable and not def._doc_items_usagehelp then
		if def.groups.food == 2 then
			return "To eat it, wield it, then rightclick."
		elseif def.groups.food == 3 then
			return "To drink it, wield it, then rightclick."
		else
			return "To consume it, wield it, then rightclick."
		end
	end
	return ""
end)
