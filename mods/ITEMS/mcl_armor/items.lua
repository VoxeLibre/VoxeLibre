local S = minetest.get_translator("mcl_armor")

function mcl_armor.register_set(def)
	local modname = minetest.get_current_modname()
	local sounds = {
		_mcl_armor_equip = "mcl_armor_equip_" .. def.material,
		_mcl_armor_unequip = "mcl_armor_unequip_" .. def.material,
	}

	for _, elem in pairs(mcl_armor.elements) do
		local item_name = elem.name .. "_" .. def.name
		local full_name = modname .. ":" .. item_name

		minetest.register_tool(full_name, {
			description = def.custom_descriptions[elem.name] or def.description .. " " .. elem.description,
			_doc_items_longdesc = mcl_armor.longdesc,
			_doc_items_usagehelp = mcl_armor.usagehelp,
			inventory_image = modname .. "_inv_" .. item_name .. ".png",
			groups = {[elem.name] = 1, armor_points = 1, armor = 1, enchantability = def.enchantability},	-- ToDo: armor_points
			sounds = sounds,
			on_place = mcl_armor.rightclick_equip,
			on_secondary_use = mcl_armor.rightclick_equip,
			_durability = def.durability * elem.durability,
			_repair_material = def.craft_item,
		})

		if def.craft_material then
			minetest.register_craft({
				output = full_name,
				recipe = elem.recipe(def.craft_material),
			})
		end

		if def.cook_material then
			minetest.register_craft({
				type = "cooking",
				output = def.cook_material,
				recipe = full_name,
				cooktime = 10,
			})
		end
	end
end

mcl_armor.register_set {
	name = "iron",
	description = S("Iron"),
	durability = 240,
	enchantability =
	craft_material = "mcl_core:iron_ingot",
	cook_material = "mcl_core:iron_nugget",
}
