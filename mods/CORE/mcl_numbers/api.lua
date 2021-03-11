mcl_numbers.register_provider = mcl_util.registration_function(mcl_numbers.providers)

function mcl_numbers.get_number(provider, data)
	return mcl_util.switch_type(provider, {
		["number"] = function()
			return provider
		end,
		["table"] = function()
			local func = mcl_numbers.providers[data.type]
			return func(provider, data)
		end,
	}, "number provider")
end

function mcl_numbers.check_bounds(actual, expected, data)
	return mcl_util.switch_type(actual, {
		["nil"] = function()
			return true
		end,
		["number"] = function()
			return actual == expected
		end,
		["table"] = function()
			return actual <= mcl_numbers.get_number(expected.max, data) and actual >= mcl_numbers.get_number(expected.min, data)
		end,
	}, "range")
end
