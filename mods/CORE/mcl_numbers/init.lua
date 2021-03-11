mcl_numbers = {
	providers = {},
}

mcl_numbers.register_provider("mcl_numbers:constant", function(provider)
	return provider.value
end)

mcl_numbers.register_provider("mcl_numbers:uniform", function(provider, data)
	return mcl_util.rand(data.pr, mcl_numbers.get_number(provider.min, data), mcl_numbers.get_number(provider.max, data))
end)

mcl_numbers.register_provider("mcl_numbers:binomial", function(provider, data)
	local n = mcl_numbers.get_number(provider.n, data)
	local num = 0
	for i = 1, n do
		if mcl_util.rand_bool(mcl_numbers.get_number(provider.p, data), data.pr) then
			num = num + 1
		end
	end
	return num
end)
 
