mcl_numbers.register_provider = mcl_util.registration_function(mcl_numbers.providers)

function mcl_numbers.get_number(provider, data)
	if type(provider) == "number" then
		return provider
	else
		mcl_numbers.providers[data.type](provider, data)
	end
end

function mcl_numbers.match_bounds(actual, expected, data)
	if type(expected) == "table" then
		expected = {
			min = mcl_numbers.get_number(expected.min, data),
			max = mcl_numbers.get_number(expected.max, data)
		}
	end
	return mcl_util.match_bounds(actual, expected)
end
