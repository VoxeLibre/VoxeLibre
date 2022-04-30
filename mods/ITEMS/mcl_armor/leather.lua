local S = minetest.get_translator(minetest.get_current_modname())
local colorize_value = 125
local modifier = "[colorize:<color>:"..colorize_value

local str = string

local longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive.")
local usage = S("To equip it, put it on the corresponding armor slot in your inventory menu.")

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
	local function get_texture(obj, itemstack)
		minetest.chat_send_all("called")
		local color = itemstack:get_meta():get_string("color")
		minetest.chat_send_all("|"..color.."|")
		if color == "" or color == nil then
			minetest.chat_send_all("No color: "..texture)
			return texture
		else
			minetest.chat_send_all("Color: "..texture.."^[colorize:"..color..":"..colorize_value)
			return texture.."^[colorize:"..color..":"..colorize_value
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
		head = get_texture_function("mcl_armor_helmet_leather.png"),
		torso = get_texture_function("mcl_armor_chestplate_leather.png"),
		legs = get_texture_function("mcl_armor_leggings_leather.png"),
		feet = get_texture_function("mcl_armor_boots_leather.png"),
	},
	repair_material = "mcl_mobitems:leather",
})

minetest.register_chatcommand("colort", {
	params = "",  -- Short parameter description
	description = "",  -- Full description
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local item = player:get_wielded_item()
		item:get_meta():set_string("color", "#951d1d")
		player:set_wielded_item(item)
		return true, "Done."
	end,
})