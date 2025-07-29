tt = {}
tt.COLOR_DEFAULT = mcl_colors.GREEN
tt.COLOR_DANGER = mcl_colors.YELLOW
tt.COLOR_GOOD = mcl_colors.GREEN
tt.NAME_COLOR = mcl_colors.YELLOW

-- API
tt.registered_snippets = {}

function tt.register_snippet(func)
	table.insert(tt.registered_snippets, func)
end

function tt.register_priority_snippet(func)
	table.insert(tt.registered_snippets, 1, func)
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/snippets.lua")

-- Apply item description updates

local function apply_snippets(desc, itemstring, toolcaps, itemstack)
	-- Apply snippets
	for s=1, #tt.registered_snippets do
		local str, snippet_color = tt.registered_snippets[s](itemstring, toolcaps, itemstack)
		if str then
			if snippet_color == nil then snippet_color = tt.COLOR_DEFAULT end
			desc = desc .. "\n" .. (snippet_color and minetest.colorize(snippet_color, str) or str)
		end
	end
	return desc
end

local function should_change(itemstring, def)
	return itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and def and def.description and def.description ~= "" and def._tt_ignore ~= true
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

function tt.reload_itemstack_description(itemstack)
	local itemstring = itemstack:get_name()
	local def = itemstack:get_definition()
	local meta = itemstack:get_meta()
	if def and def._mcl_generate_description then
		def._mcl_generate_description(itemstack)
	elseif should_change(itemstring, def) then
		local toolcaps = def.tool_capabilities and itemstack:get_tool_capabilities()
		local orig_desc = def._tt_original_description or def.description
		if meta:get_string("name") ~= "" then
			orig_desc = minetest.colorize(tt.NAME_COLOR, meta:get_string("name"))
		elseif def.groups._mcl_potion == 1 then
			local potency = meta:get_int("mcl_potions:potion_potent")
			local plus = meta:get_int("mcl_potions:potion_plus")
			if potency > 0 then
				orig_desc = orig_desc .. " " .. mcl_util.to_roman(potency+1)
			end
			if plus > 0 then
				orig_desc = orig_desc .. " "
				for i = 1, plus do
					orig_desc = orig_desc .. "+"
				end
			end
		end
		local desc = apply_snippets(orig_desc, itemstring, toolcaps or def.tool_capabilities, itemstack)
		if desc == def.description and meta:get_string("description") == "" then return end
		meta:set_string("description", desc)
	end
end

core.register_craft_predict(tt.reload_itemstack_description)
core.register_on_craft(tt.reload_itemstack_description)
