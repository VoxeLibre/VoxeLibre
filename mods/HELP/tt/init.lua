tt = {}
tt.COLOR_DEFAULT = "#d0ffd0"
tt.COLOR_DANGER = "#ffff00"
tt.COLOR_GOOD = "#00ff00"
tt.NAME_COLOR = "#FFFF4C"

-- API
tt.registered_snippets = {}

tt.register_snippet = function(func)
	table.insert(tt.registered_snippets, func)
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/snippets.lua")

-- Apply item description updates

local function apply_snippets(desc, itemstring, toolcaps, itemstack)
	local first = true
	-- Apply snippets
	for s=1, #tt.registered_snippets do
		local str, snippet_color = tt.registered_snippets[s](itemstring, toolcaps, itemstack)
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
	return desc
end

local function should_change(itemstring, def)
	return itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and def ~= nil and def.description ~= nil and def.description ~= "" and def._tt_ignore ~= true
end

local function append_snippets()
	for itemstring, def in pairs(minetest.registered_items) do
		if should_change(itemstring, def) then
			local orig_desc = def.description
			local desc = apply_snippets(orig_desc, itemstring, def.tool_capabilities, nil)
			if desc ~= orig_desc then
				minetest.override_item(itemstring, { description = desc, _tt_original_description = orig_desc })
			end
		end
	end
end

minetest.register_on_mods_loaded(append_snippets)

tt.reload_itemstack_description = function(itemstack)
	local itemstring = itemstack:get_name()
	local def = itemstack:get_definition()
	local meta = itemstack:get_meta()
	if def and def._mcl_generate_description then
		def._mcl_generate_description(itemstack)
	elseif should_change(itemstring, def) then
		local toolcaps
		if def.tool_capabilities then
			toolcaps = itemstack:get_tool_capabilities()
		end
		local orig_desc = def._tt_original_description or def.description
		if meta:get_string("name") ~= "" then
			orig_desc = minetest.colorize(tt.NAME_COLOR, meta:get_string("name"))
		end
		local desc = apply_snippets(orig_desc, itemstring, toolcaps or def.tool_capabilities, itemstack)
		if desc ~= orig_desc then
			meta:set_string("description", desc)
		end
	end
end
