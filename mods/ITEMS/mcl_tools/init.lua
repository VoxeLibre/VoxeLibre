local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- mods/default/tools.lua

--
-- Tool definition
--

--[[
dig_speed_class group:
- 1: Painfully slow
- 2: Very slow
- 3: Slow
- 4: Fast
- 5: Very fast
- 6: Extremely fast
- 7: Instantaneous
]]

-- Help texts
local sword_longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs.")
-- local sword_use = S("To slash multiple enemies, hold the sword in your hand, then use (rightclick) an enemy.")
-- TODO slash attack not implemented yet

local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

local wield_scale = mcl_vars.tool_wield_scale

local carve_pumpkin
if minetest.get_modpath("mcl_farming") then
	function carve_pumpkin(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		-- Only carve pumpkin if used on side
		if pointed_thing.above.y ~= pointed_thing.under.y then
			return
		end
		if node.name == "mcl_farming:pumpkin" then
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				-- Add wear (as if digging a shearsy node)
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shearsy")
				if wear then
					itemstack:add_wear(wear)
					tt.reload_itemstack_description(itemstack) -- update tooltip
				end

			end
			minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pointed_thing.above}, true)
			local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
			local param2 = minetest.dir_to_facedir(dir)
			minetest.set_node(pointed_thing.under, {name="mcl_farming:pumpkin_face", param2 = param2})
			minetest.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
		end
		return itemstack
	end
end

-- Swords
minetest.register_tool("mcl_tools:sword_wood", {
	description = S("Wooden Sword"),
	_doc_items_longdesc = sword_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:sword_stone", {
	description = S("Stone Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_stonesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 4, level = 3, uses = 132 },
		swordy_cobweb = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:sword_iron", {
	description = S("Iron Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_steelsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 6, level = 4, uses = 251 },
		swordy_cobweb = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:sword_gold", {
	description = S("Golden Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_goldsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		damage_groups = {fleshy=4},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 12, level = 2, uses = 33 },
		swordy_cobweb = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:sword_diamond", {
	description = S("Diamond Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_diamondsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 1562 },
		swordy_cobweb = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:sword_netherite"
})
minetest.register_tool("mcl_tools:sword_netherite", {
	description = S("Netherite Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_netheritesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 2031 },
		swordy_cobweb = { speed = 8, level = 5, uses = 2031 }
	},
})

--Shears
minetest.register_tool("mcl_tools:shears", {
	description = S("Shears"),
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1, shears=1, dig_speed_class=4, enchantability=-1, },
	tool_capabilities = {
	        full_punch_interval = 0.5,
	        max_drop_level=1,
	},
	on_place = carve_pumpkin,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 }
	},
})


dofile(modpath.."/crafting.lua")
dofile(modpath.."/aliases.lua")
