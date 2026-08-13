local modpath = core.get_modpath(core.get_current_modname())
local S = core.get_translator(core.get_current_modname())

-- Keep the unrelated recipes which allow cobbled deepslate to substitute for
-- cobblestone after it was removed from the cobble group.
dofile(modpath .. "/crafting.lua")

vl_weaponry.register_tool_material("deepslate", {
	tool_types = {
		["mcl_tools:pickaxe"] = {
			item_name = "vl_deepslate_tools:pick_deepslate",
			description = S("Deepslate Pickaxe"),
			inventory_image = "vl_deepslate_tools_deepslatepick.png",
		},
		["mcl_tools:shovel"] = {
			item_name = "vl_deepslate_tools:shovel_deepslate",
			description = S("Deepslate Shovel"),
			inventory_image = "vl_deepslate_tools_deepslateshovel.png",
		},
		["mcl_tools:axe"] = {
			item_name = "vl_deepslate_tools:axe_deepslate",
			description = S("Deepslate Axe"),
			inventory_image = "vl_deepslate_tools_deepslateaxe.png",
		},
		["mcl_tools:sword"] = {
			item_name = "vl_deepslate_tools:sword_deepslate",
			description = S("Deepslate Sword"),
			inventory_image = "vl_deepslate_tools_deepslatesword.png",
		},
		["mcl_farming:hoe"] = {
			item_name = "vl_deepslate_tools:hoe_deepslate",
			description = S("Deepslate Hoe"),
			inventory_image = "vl_deepslate_tools_deepslatehoe.png",
		},
		["vl_weaponry:hammer"] = {
			item_name = "vl_deepslate_tools:hammer_deepslate",
			description = S("Deepslate Hammer"),
			inventory_image = "vl_deepslate_tools_deepslatehammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_deepslate_tools:spear_deepslate",
			description = S("Deepslate Spear"),
			inventory_image = "vl_deepslate_tools_deepslatespear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_deepslate_tools:scythe_deepslate",
			description = S("Deepslate Scythe"),
			inventory_image = "vl_tool_deepslatescythe.png",
		},
	},
	craft_material = "mcl_deepslate:deepslate_cobbled",
	repair_material = "mcl_deepslate:deepslate_cobbled",
	dig_speed_class = 3,
	max_enchant_level = 2,
	stat_modifiers = {
		durability = { add = 150 },
		dig_speed = { multiply = 4.25 },
		harvest_level = { add = 3 },
		damage = { add = 1.25 },
		attack_interval = { add = 0.1 },
		thrown_damage = { add = 1 },
		enchantability = { add = 5 },
	},
})

local pr = PcgRandom(1234)
core.register_on_craft(function(itemstack)
	if itemstack:get_name():sub(1, 18) ~= "vl_deepslate_tools"
			or mcl_enchanting.is_enchanted(itemstack:get_name())
			or math.random(1, 2) == 1 then
		return
	end
	local enchantment = mcl_enchanting.get_random_enchantment(itemstack, false, true, {}, pr)
	mcl_enchanting.enchant(itemstack, enchantment, 1)
	tt.reload_itemstack_description(itemstack)
end)
