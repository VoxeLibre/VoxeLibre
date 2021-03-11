mcl_predicates.register_predicate = mcl_util.registration_function(mcl_predicates.predicates)

function mcl_predicates.do_predicates(predicates, data, or_mode)
	or_mode = or_mode or false
	for _, func in ipairs(predicates) do
		if type(func) == "string" then
			func = mcl_predicates.predicates[func]
		end
		local failure = func and not func(def, data) or false
		if or_mode ~= failure then
			return or_mode
		end
	end
	return not or_mode or #predicates == 0
end
