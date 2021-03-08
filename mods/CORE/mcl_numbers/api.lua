mcl_numbers.register_provider = mcl_util.registration_function(mcl_numbers.providers)

function mcl_numbers.get_number(provider, data)
	local t = type(provider)
	if t == "nil" then
		return 0
	elseif t == "number" then
		return provider
	elseif t == "table" then
		local func = assert(mcl_numbers.providers[data.type])
		return assert(tonumber(func(provider, data)))
	else
		error("invalid number type: " .. t)
	end
end
