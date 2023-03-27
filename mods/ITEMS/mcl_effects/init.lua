local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_effects = {}
effects = {}

mcl_effects.registered_effects = {}

function mcl_effects.register_effect(name, def)
	local EFFECT_TYPES = 0
	for _,_ in pairs(effects) do
		EFFECT_TYPES = EFFECT_TYPES + 1
	end

	local icon_ids = {}
	local function potions_init_icons(player)
		local name = player:get_player_name()
		icon_ids[name] = {}
		for e=1, EFFECT_TYPES do
			local x = -52 * e - 2
			local id = player:hud_add({
				hud_elem_type = "image",
				text = "blank.png",
				position = { x = 1, y = 0 },
				offset = { x = x, y = 3 },
				scale = { x = 0.375, y = 0.375 },
				alignment = { x = 1, y = 1 },
				z_index = 100,
			})
			table.insert(icon_ids[name], id)
		end
	end

	local function potions_set_icons(player)
		local name = player:get_player_name()
		if not icon_ids[name] then
			return
		end
		local active_effects = {}
		for effect_name, effect in pairs(effects) do
			if effect[player] then
			table.insert(active_effects, effect_name)
			end
		end

		for i=1, EFFECT_TYPES do
			local icon = icon_ids[name][i]
			local effect_name = active_effects[i]
			--[[if effect_name == "swift" and effects.swift[player].is_slow then
				effect_name = "slow"
			end]]
			if effect_name == nil then
				player:hud_change(icon, "text", "blank.png")
			else
				player:hud_change(icon, "text", def.icon.."^[resize:128x128")
			end
		end
	
	end

	local function potions_set_hud(player)
	
		potions_set_hudbar(player)
		potions_set_icons(player)
	
	end
end

effects.test_effect = {}

mcl_effects.register_effect("test_effect", {
	description = "Test Effect",
	icon = "default_stone.png",
	particle_color = "#000000",
})
