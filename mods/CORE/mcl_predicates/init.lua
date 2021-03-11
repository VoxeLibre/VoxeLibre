mcl_predicates = {
	predicates = {},
}

local modpath = minetest.get_modpath("mcl_predicates")

dofile(modpath .. "/api.lua")

mcl_predicates.register_predicate("alternative", function(predicate, data)
	return mcl_predicates.do_predicates(predicate.terms, data, true)
end)

mcl_predicates.register_predicate("block_state_property", function(predicate, data)
	return mcl_predicates.match_block(predicate.block, predicate.properties, data.location)
end)

mcl_predicates.register_predicate("damage_source_properties", function(predicate, data)
	-- ToDo: damage source abstraction
	return nil
end)

mcl_predicates.register_predicate("entity_properties", function(predicate, data)
	local entity = predicate.entity
	if not entity or (entity ~= "this" and entity ~= "killer" and entity ~= "killer_player") then
		return false
	end
	
	local ref = data[entity]
	if not ref then
		return false
	end

	-- ToDo: entity / player abstraction
	return nil
end)

mcl_predicates.register_predicate("entity_scores", function(predicate, data)
	-- ToDo: scoreboards
	return nil
end)

mcl_predicates.register_predicate("inverted", function(predicate, data)
	return not mcl_predicates.do_predicates({predicate.term}, data)
end)

mcl_predicates.register_predicate("killed_by_player", function(predicate, data)
	return not predicate.inverse ~= not data.killer_player
end)

mcl_predicates.register_predicate("location_check", function(predicate, data)
	local location = vector.new(data.location)

	location.x = location.x + (data.offsetX or 0)
	location.y = location.y + (data.offsetY or 0)
	location.z = location.z + (data.offsetZ or 0)

	-- ToDo, needs abstraction?
	return nil
end)

mcl_predicates.register_predicate("match_tool", function(predicate, data)
	return mcl_predicates.match_tool(data.tool, predicate.predicate)
end)

mcl_predicates.register_predicate("random_chance", function(predicate, data)
	return mcl_util.rand_bool(predicate.chance, data.pr)
end)

mcl_predicates.register_predicate("random_chance_with_looting", function(predicate, data)
	local chance = predicate.chance -- + (looting_level * looting_multiplier)

	-- ToDo: entity / player abstraction
	return mcl_util.rand_bool(chance, data.pr)
end)

mcl_predicates.register_predicate("reference", function(predicate, data)
	-- ToDo: needs research
	return nil
end)

mcl_predicates.register_predicate("survives_explosion", function(predicate, data)
	return mcl_util.rand_bool(data.drop_chance or 1, data.pr)
end)

mcl_predicates.register_predicate("table_bonus", function(predicate, data)
	-- ToDo: entity / player abstraction
	return nil
end)

mcl_predicates.register_predicate("time_check", function(predicate, data)
	-- ToDo: needs research
	return nil
end)

mcl_predicates.register_predicate("weather_check", function(predicate, data)
	local weather = mcl_weather.get_weather()
	
	if predicate.thundering then
		return weather == "thunder"
	elseif predicate.raining then
		return weather == "rain"
	else
		return true
	end
end)

mcl_predicates.register_predicate("value_check", function(predicate, data)
	local value = mcl_numbers.get_number(predicate.value, data)
	return mcl_numbers.check_in_bounds(value, predicate.range, data)
end)
