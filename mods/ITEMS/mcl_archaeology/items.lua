local S = minetest.get_translator(minetest.get_current_modname())

for _, row in ipairs(mcl_archaeology.pottery_sherds) do
	-- assign variable = row[x]
	local name = row[1]
	local desc = row[2] -- short for "description"

	-- register
	minetest.register_craftitem("mcl_archaeology:"..name.."_pottery_sherd", {
		description = desc,
		_doc_items_longdesc = S("A pottery sherd is used to craft Decorated Pots."),
		inventory_image = "mcl_archaeology_pottery_sherd_"..name..".png",
		groups = { craftitem = 1, pottery_sherd = 1, pottery = 1 }
	})
end

minetest.register_craftitem("mcl_archaeology:brush", {
	description = S("Brush"),
	_doc_items_longdesc = S("A brush can be used to excavate suspicious blocks."),
	_tt_help = S("Excavates suspicious blocks"),
	inventory_image = "mcl_archaeology_brush.png",
	stack_max = 1,
	groups = {tool=1},
})

minetest.register_craft({
	output = "mcl_archaeology:brush",
	recipe = {
		{"mcl_mobitems:feather"},
		{"mcl_copper:copper_ingot"},
		{"mcl_core:stick"}
	}
})
