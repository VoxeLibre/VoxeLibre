mcl_types = {}

function mcl_types.match_bounds(actual, expected)
	if type(expected) == "table" then
		return actual <= expected.max and actual >= expected.min
	else
		return actual == expected
	end
end

function mcl_types.match_meta(actual, expected)
	for k, v in pairs(expected) do
		if actual:get_string(k) ~= v then
			return false
		end
	end
	return true
end

function mcl_types.match_vector(actual, expected)
	for k, v in pairs(expected) do
		if not mcl_types.match_bounds(actual[k], expected[k]) then
			return false
		end
	end
	return true
end

function mcl_types.match_enchantments(actual, expected)
	for _, v in ipairs(expected) do
		if not mcl_types.match_bounds(actual[v.enchantment] or 0, v.levels or {min = 1, max = math.huge}) then
			return false
		end
	end
	return true
end

function mcl_types.match_item(actual, expected)
	actual = actual or ItemStack()

	if expected.item and actual:get_name() ~= expected.item then
		return false
	elseif expected.group and minetest.get_item_group(actual:get_name(), expected.group) == 0 then
		return false
	elseif expected.count and not mcl_types.match_bounds(actual:get_count(), expected.count) then
		return false
	elseif expected.wear and not mcl_types.match_bounds(actual:get_wear(), expected.wear) then
		return false
	elseif expected.enchantments and not mcl_types.match_enchantments(mcl_enchanting.get_enchantments(actual), expected.enchantments) then
		return false
	elseif expected.meta and not mcl_types.match_meta(actual:get_meta(), expected.meta) then
		return false
	else
		return true
	end
end

function mcl_types.match_node(actual, expected, pos, meta)
	if expected.node and actual.name ~= expected.node then
		return false
	elseif expected.group and minetest.get_item_group(actual.name, expected.group) == 0 then
		return false
	elseif expected.param1 and actual.param1 ~= compare.param1 then
		return false
	elseif expected.param2 and actual.param2 ~= compare.param2 then
		return false
	elseif expected.meta and not mcl_types.match_meta(meta or minetest.get_meta(pos), expected.meta) then
		return false
	else
		return true
	end
end

function mcl_types.match_pos(actual, expected, meta)
	if expected.pos and not mcl_types.match_vector(actual, expected.pos) then
		return false
	elseif expected.dimension and mcl_worlds.pos_to_dimension(actual) ~= expected.dimension then
		return false
	elseif expected.biome and minetest.get_biome_name(minetest.get_biome_data(actual).biome) ~= expected.biome then
		return false
	elseif expected.node and not mcl_types.match_node(minetest.get_node(actual), expected.node, actual, meta) then
		return false
	elseif expected.light and not mcl_types.match_bounds(minetest.get_node_light(actual), expected.light) then
		return false
	else
		return true
	end
end
