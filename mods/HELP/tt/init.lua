tt = {}
tt.COLOR_DEFAULT = "#d0ffd0"
tt.COLOR_DANGER = "#ffff00"
tt.COLOR_GOOD = "#00ff00"

-- API
tt.registered_snippets = {}

tt.register_snippet = function(func)
	table.insert(tt.registered_snippets, func)
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/snippets.lua")

-- Apply item description updates

local function append_snippets()
	for itemstring, def in pairs(minetest.registered_items) do
		if itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and def ~= nil and def.description ~= nil and def.description ~= "" and def._tt_ignore ~= true then
			local desc = def.description
			local orig_desc = desc
			local first = true
			-- Apply snippets
			for s=1, #tt.registered_snippets do
				local str, snippet_color = tt.registered_snippets[s](itemstring)
				if snippet_color == nil then
					snippet_color = tt.COLOR_DEFAULT
				elseif snippet_color == false then
					snippet_color = false
				end
				if str then
					if first then
						first = false
					end
					desc = desc .. "\n"
					if snippet_color then
						desc = desc .. minetest.colorize(snippet_color, str)
					else
						desc = desc .. str
					end
				end
			end
			if desc ~= def.description then
				minetest.override_item(itemstring, { description = desc, _tt_original_description = orig_desc })
			end
		end
	end
end

minetest.register_on_mods_loaded(append_snippets)
