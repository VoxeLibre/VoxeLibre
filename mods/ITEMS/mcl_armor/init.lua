local S = minetest.get_translator("mcl_armor")

mcl_armor = {
	longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive."),
	usage = S("To equip it, put it on the corresponding armor slot in your inventory menu."),
	elements = {
		head = {
			name = "helmet",
			description = "Helmet",
			durability = 0.6857,
			index = 2,
			craft = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{"", "", ""},
				}
			end,
		},
		torso = {
			name = "chestplate",
			description = "Chestplate",
			durability = 1.0,
			index = 3,
			craft = function(m)
				return {
					{ m, "",  m},
					{ m,  m,  m},
					{ m,  m,  m},
				}
			end,
		},
		legs = {
			name = "leggings",
			description = "Leggings",
			durability = 0.9375,
			index = 4,
			craft = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		},
		feet = {
			name = "boots",
			description = "Boots",
			durability = 0.8125,
			index = 5,
			craft = function(m)
				return {
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		}
	},
	player_view_range_factors = {},
}

local modpath = minetest.get_modpath("mcl_armor")

dofile(modpath .. "/api.lua")
dofile(modpath .. "/player.lua")
dofile(modpath .. "/damage.lua")
dofile(modpath .. "/register.lua")
dofile(modpath .. "/alias.lua")
