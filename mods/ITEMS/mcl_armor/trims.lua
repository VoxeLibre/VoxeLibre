local mod_registername      = minetest.get_current_modname() .. ":"
local S                     = minetest.get_translator(minetest.get_current_modname())

for _, template_name in pairs(mcl_armor.trims.overlays) do
	minetest.register_craftitem(mod_registername .. template_name, {
		description      = S("Smithing Template '@1'", mcl_armor.trims.translations[template_name]),
		inventory_image  = template_name .. "_armor_trim_smithing_template.png",
		groups           = { armor_trim_template = 1 },
		_mcl_armor_template = true,
		_mcl_armor_template_name = template_name,
	})

	minetest.register_craft({
		output = mod_registername .. template_name .. " 2",
		recipe = {
			{"mcl_core:diamond",mod_registername .. template_name,"mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:cobble","mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		}
	})
end

--temp craft recipies, missing structures
minetest.register_craft({
	output = mod_registername .. "eye",
	recipe = {
		{"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})

minetest.register_craft({
	output = mod_registername .. "ward",
	recipe = {
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:apple_gold_enchanted","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})

minetest.register_craft({
	output = mod_registername .. "snout",
	recipe = {
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:goldblock","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})

minetest.register_craft({
	output = mod_registername .. "silence",
	recipe = {
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		{"mcl_core:diamond", mod_registername.."ward","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})

minetest.register_craft({
	output = mod_registername .. "wayfinder",
	recipe = {
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		{"mcl_core:diamond", "mcl_maps:empty_map","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})
