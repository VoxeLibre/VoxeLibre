local S = minetest.get_translator(minetest.get_current_modname())

local colors = {
	-- { ID, decription, wool, dye }
	{ "red", "Red", "mcl_dye:red", "#951d1d" },
	{ "blue", "Blue", "mcl_dye:blue", "#2a2c94" },
	{ "cyan", "Cyan", "mcl_dye:cyan", "#0d7d8e" },
	{ "grey", "Grey", "mcl_dye:dark_grey", "#363a3f" },
	{ "silver", "Light Grey", "mcl_dye:grey", "#818177" },
	{ "black", "Black", "mcl_dye:black", "#020307" },
	{ "yellow", "Yellow", "mcl_dye:yellow", "#f2b410" },
	{ "green", "Green", "mcl_dye:dark_green", "#495d20" },
	{ "magenta", "Magenta", "mcl_dye:magenta", "#ae2ea4" },
	{ "orange", "Orange", "mcl_dye:orange", "#e36501" },
	{ "purple", "Purple", "mcl_dye:violet", "#681ba1" },
	{ "brown", "Brown", "mcl_dye:brown", "#623b1a" },
	{ "pink", "Pink", "mcl_dye:pink", "#d66691" },
	{ "lime", "Lime", "mcl_dye:green", "#60ad13" },
	{ "light_blue", "Light Blue", "mcl_dye:lightblue", "#1f8eca" },
	{ "white", "White", "mcl_dye:white", "#d1d7d8" },
}

--local function get_color_rgb(color)
--    return tonumber(str.sub(first, 2, 3)), tonumber(str.sub(first, 4, 5)), tonumber(str.sub(first, 6, 7))
--end

local function calculate_color(first, last)
    --local first_r = tonumber(str.sub(first, 2, 3))
    --local first_g = tonumber(str.sub(first, 4, 5))
    return  tonumber(first)*tonumber(last)
end

local function get_texture_function(texture)
	local function get_texture(_, itemstack)
		local out
		local color = itemstack:get_meta():get_string("color")
		if color == "" or color == nil then
			out = texture
		else
			out = texture.."^[multiply:"..color
		end

		if mcl_enchanting.is_enchanted(itemstack) then
			return out.."^"..mcl_enchanting.overlay
		else
			return out
		end
	end
	return get_texture
end

mcl_armor.register_set({
	name = "leather_colored",
	description = "Colored Leather",
	descriptions = {
		head = "Cap",
		torso = "Tunic",
		legs = "Pants",
	},
	durability = 80,
	enchantability = 15,
	points = {
		head = 1,
		torso = 3,
		legs = 2,
		feet = 1,
	},
	textures = {
		head = get_texture_function("mcl_armor_helmet_colored_leather.png"),
		torso = get_texture_function("mcl_armor_chestplate_colored_leather.png"),
		legs = get_texture_function("mcl_armor_leggings_colored_leather.png"),
		feet = get_texture_function("mcl_armor_boots_colored_leather.png"),
	},
	inventory = {
		head = "mcl_armor_inv_helmet_colored_leather.png",
		torso = "mcl_armor_inv_chestplate_colored_leather.png",
		legs = "mcl_armor_inv_leggings_colored_leather.png",
		feet = "mcl_armor_inv_boots_colored_leather.png",
	},
	repair_material = "mcl_mobitems:leather",
	groups = {armor_leather_colored = 1},
})

tt.register_priority_snippet(function(_, _, itemstack)
	if not itemstack or not itemstack:get_definition().groups.armor_leather_colored == 1 then
		return
	end
	local color = itemstack:get_meta():get_string("color")
	if color and color ~= "" then
		local text = "Color: "..color
		return text, false
	end
end)


-- This command is only temporary

minetest.register_chatcommand("color_leather", {
	params = "<color>",
	description = "Colorize a leather armor",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local item = player:get_wielded_item()
			item:get_meta():set_string("color", param)
			tt.reload_itemstack_description(item)
			player:set_wielded_item(item)
			return true, "Done."
		else
			return false, "Player isn't online"
		end
	end,
})