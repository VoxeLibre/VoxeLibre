-- CUSTOM SNIPPETS --

-- Custom text (_tt_help)
tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	return def and def._tt_help or nil
end)


