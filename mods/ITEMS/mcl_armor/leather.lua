local C = minetest.colorize

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

-- #608b03 from #495d20

local function color_string_to_table(colorstring)
	return {
		r = tonumber(colorstring:sub(2,3), 16), -- 16 as second parameter allows hexadecimal
		g = tonumber(colorstring:sub(4,5), 16),
		b = tonumber(colorstring:sub(6,7), 16),
	}
end

local function av(a, b)
	return (a + b)/2
end

local function calculate_color(first, last)
    return {
		r = av(first.r, last.r),
		g = av(first.g, last.g),
		b = av(first.b, last.b),
    }
end

local function get_texture_function(texture)
	local function get_texture(_, itemstack)
		local out
		local color = itemstack:get_meta():get_string("mcl_armor:color")
		if color == "" or color == nil then
			out = texture
		else
			out = texture.."^[hsl:0:100:50^[multiply:"..color
		end

		if mcl_enchanting.is_enchanted(itemstack:get_name()) then
			minetest.chat_send_all(out..mcl_enchanting.overlay)
			return out..mcl_enchanting.overlay
		else
			minetest.chat_send_all(out)
			return out
		end
	end
	return get_texture
end

function mcl_armor.colorize_leather_armor(itemstack, colorstring)
	local color = color_string_to_table(colorstring)
	local meta = itemstack:get_meta()
	local old_color = meta:get_string("mcl_armor:color")
	if old_color ~= "" then
		color = calculate_color(
			color_string_to_table(minetest.colorspec_to_colorstring(old_color)),
			color
		)
		colorstring = minetest.colorspec_to_colorstring(color)
	end
	meta:set_string("mcl_armor:color", colorstring)
	meta:set_string("inventory_image",
		itemstack:get_definition().inventory_image .. "^[hsl:0:100:50^[multiply:" .. colorstring
	)
	tt.reload_itemstack_description(itemstack)
	return itemstack
end

function mcl_armor.wash_leather_armor(itemstack)
	if not itemstack or not itemstack:get_definition().groups.armor_leather == 1 then
		return
	end
	local meta = itemstack:get_meta()
	meta:set_string("mcl_armor:color", "")
	meta:set_string("inventory_image", "")
	tt.reload_itemstack_description(itemstack)
	return itemstack
end

mcl_armor.register_set({
	name = "leather",
	description = "Leather",
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
		head = get_texture_function("mcl_armor_helmet_leather.png"),
		torso = get_texture_function("mcl_armor_chestplate_leather.png"),
		legs = get_texture_function("mcl_armor_leggings_leather.png"),
		feet = get_texture_function("mcl_armor_boots_leather.png"),
	},
	craft_material = "mcl_mobitems:leather",
})

tt.register_priority_snippet(function(_, _, itemstack)
	if not itemstack or not itemstack:get_definition().groups.armor_leather == 1 then
		return
	end
	local color = itemstack:get_meta():get_string("mcl_armor:color")
	if color and color ~= "" then
		local text = C(mcl_colors.GRAY, "Dyed: "..color)
		return text, false
	end
end)


minetest.register_chatcommand("color_leather", {
	params = "<color>",
	description = "Colorize a piece of leather armor, or wash it",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local item = player:get_wielded_item()
			if not item or not item:get_definition().groups.armor_leather == 1 then
				return false, "Not leather armor."
			end
			if param == "wash" then
				player:set_wielded_item(mcl_armor.wash_leather_armor(item))
				return true, "Washed."
			end
			local colorstring = minetest.colorspec_to_colorstring(param)
			if not colorstring then return false, "Invalid color" end
			player:set_wielded_item(mcl_armor.colorize_leather_armor(item, colorstring))
			return true, "Done: " .. colorstring
		else
			return false, "Player isn't online"
		end
	end,
})
