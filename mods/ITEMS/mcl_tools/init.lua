-- mods/default/tools.lua

--
-- Tool definition
--

--[[ Maximum drop level definitions:
- 0: Hand
- 1: Wood / Shears
- 2: Gold
- 3: Stone
- 4: Iron
- 5: Diamond
]]

-- TODO: Add legacy support for Minetest Game groups like crumbly, snappy, cracky, etc. for all tools

-- The hand
local groupcaps
if minetest.setting_getbool("creative_mode") then
	-- Instant breaking in creative mode
	groupcaps = {
		creative_breakable = {times={[1]=0}, uses=0},
	}
	-- mcl_autogroup provides the creative digging times for all digging groups
	for k,v in pairs(mcl_autogroup.creativetimes) do
		groupcaps[k] = { times = v, uses = 0 }
	end
else
	groupcaps = {
		handy_dig = {times=mcl_autogroup.digtimes.handy_dig, uses=0},
	}
end
minetest.register_item(":", {
	type = "none",
	_doc_items_longdesc = "You use your bare hand whenever you are not wielding any item. With your hand you can mine the weakest blocks and deal minor damage by punching. Using the hand is often a last resort, as proper mining tools and weapons are better than the hand. When you are wielding an item which is not a mining tool or a weapon, it will behave as if it were the hand when you start mining or punching. In Creative Mode, the hand is able to break all blocks instantly.",
	wield_image = "wieldhand.png",
	wield_scale = {x=1.0,y=1.0,z=2.0},
	-- According to Minecraft Wiki, the exact range is 3.975.
	-- Minetest seems to only support whole numbers, so we use 4.
	range = 4,
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level = 0,
		groupcaps = groupcaps,
		damage_groups = {fleshy=1},
	}
})

-- Help texts
local pickaxe_longdesc = "Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient."
local axe_longdesc = "An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow."
local sword_longdesc = "Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs."
local shovel_longdesc = "Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak."
local shovel_use = "To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block."
local shears_longdesc = "Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from a grass, leaves and similar blocks."
local shears_use = "To shear a sheep and obtain its wool, rightclick it while holding the shears. Mining works are usual, but the drops are different for a few blocks."

-- Picks
minetest.register_tool("mcl_tools:pick_wood", {
	description = "Wooden Pickaxe",
	_doc_items_longdesc = pickaxe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		groupcaps={
			pickaxey_dig_wood = {times=mcl_autogroup.digtimes.pickaxey_dig_wood, uses=60, maxlevel=0},
		},
		damage_groups = {fleshy=2},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:pick_stone", {
	description = "Stone Pickaxe",
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_stonepick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		groupcaps={
			pickaxey_dig_stone = {times=mcl_autogroup.digtimes.pickaxey_dig_stone, uses=132, maxlevel=0},
		},
		damage_groups = {fleshy=3},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:pick_iron", {
	description = "Iron Pickaxe",
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_steelpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=4,
		groupcaps={
			pickaxey_dig_iron = {times=mcl_autogroup.digtimes.pickaxey_dig_iron , uses=251, maxlevel=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:pick_gold", {
	description = "Golden Pickaxe",
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_goldpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=2,
		groupcaps={
			pickaxey_dig_gold = {times=mcl_autogroup.digtimes.pickaxey_dig_gold , uses=33, maxlevel=0},
		},
		damage_groups = {fleshy=2},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:pick_diamond", {
	description = "Diamond Pickaxe",
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_diamondpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		groupcaps={
			pickaxey_dig_diamond = {times=mcl_autogroup.digtimes.pickaxey_dig_diamond, uses=1562, maxlevel=0},
		},
		damage_groups = {fleshy=5},
	},
	sound = { breaks = "default_tool_breaks" },
})

local get_shovel_dig_group = function(itemstring)
	local def = minetest.registered_items[itemstring]
	if itemstring == "mcl_tools:shovel_wood" then
		return "shovely_dig_wood"
	elseif itemstring == "mcl_tools:shovel_stone" then
		return "shovely_dig_stone"
	elseif itemstring == "mcl_tools:shovel_iron" then
		return "shovely_dig_iron"
	elseif itemstring == "mcl_tools:shovel_gold" then
		return "shovely_dig_gold"
	elseif itemstring == "mcl_tools:shovel_diamond" then
		return "shovely_dig_diamond"
	else
		-- Fallback
		return "shovely_dig_wood"
	end
end

local make_grass_path = function(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	-- Only make grass path if tool used on side or top of target node
	if pointed_thing.above.y < pointed_thing.under.y then
		return
	end
	if (node.name == "mcl_core:dirt_with_grass" or node.name == "mcl_core:dirt_with_grass_snow") then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if minetest.get_node(above).name == "air" then
			if not minetest.setting_getbool("creative_mode") then
				-- Add wear, as if digging a level 0 shovely node
				local toolname = itemstack:get_name()
				local def = minetest.registered_items[toolname]
				local group = get_shovel_dig_group(toolname)
				local base_uses = def.tool_capabilities.groupcaps[group].uses
				local maxlevel = def.tool_capabilities.groupcaps[group].maxlevel
				local uses = base_uses * math.pow(3, maxlevel)
				local wear = math.ceil(65535 / uses)
				itemstack:add_wear(wear)
			end
			minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above})
			minetest.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
		end
	end
	return itemstack
end

-- Shovels
minetest.register_tool("mcl_tools:shovel_wood", {
	description = "Wooden Shovel",
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodshovel.png",
	wield_image = "default_tool_woodshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		groupcaps={
			shovely_dig_wood = {times=mcl_autogroup.digtimes.shovely_dig_wood, uses=60, maxlevel=0},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:shovel_stone", {
	description = "Stone Shovel",
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_stoneshovel.png",
	wield_image = "default_tool_stoneshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		groupcaps={
			shovely_dig_stone = {times=mcl_autogroup.digtimes.shovely_dig_stone, uses=132, maxlevel=0},
		},
		damage_groups = {fleshy=3},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:shovel_iron", {
	description = "Iron Shovel",
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_steelshovel.png",
	wield_image = "default_tool_steelshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=4,
		groupcaps={
			shovely_dig_iron = {times=mcl_autogroup.digtimes.shovely_dig_iron, uses=251, maxlevel=0},
		},
		damage_groups = {fleshy=4},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:shovel_gold", {
	description = "Golden Shovel",
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_goldshovel.png",
	wield_image = "default_tool_goldshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=2,
		groupcaps={
			shovely_dig_gold = {times=mcl_autogroup.digtimes.shovely_dig_gold, uses=33, maxlevel=0},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:shovel_diamond", {
	description = "Diamond Shovel",
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_diamondshovel.png",
	wield_image = "default_tool_diamondshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		groupcaps={
			shovely_dig_diamond = {times=mcl_autogroup.digtimes.shovely_dig_diamond, uses=1562, maxlevel=0},
		},
		damage_groups = {fleshy=5},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})

-- Axes
minetest.register_tool("mcl_tools:axe_wood", {
	description = "Wooden Axe",
	_doc_items_longdesc = axe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=1,
		groupcaps={
			axey_dig_wood = {times=mcl_autogroup.digtimes.axey_dig_wood, uses=60, maxlevel=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:axe_stone", {
	description = "Stone Axe",
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_stoneaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=3,
		groupcaps={
			axey_dig_stone = {times=mcl_autogroup.digtimes.axey_dig_stone, uses=132, maxlevel=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:axe_iron", {
	description = "Iron Axe",
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_steelaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=4,
		groupcaps={
			axey_dig_iron = {times=mcl_autogroup.digtimes.axey_dig_iron, uses=251, maxlevel=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:axe_gold", {
	description = "Golden Axe",
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_goldaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		groupcaps={
			axey_dig_gold= {times=mcl_autogroup.digtimes.axey_dig_gold, uses=33, maxlevel=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:axe_diamond", {
	description = "Diamond Axe",
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_diamondaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		groupcaps={
			axey_dig_diamond = {times=mcl_autogroup.digtimes.axey_dig_diamond, uses=1562, maxlevel=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})

-- Swords
minetest.register_tool("mcl_tools:sword_wood", {
	description = "Wooden Sword",
	_doc_items_longdesc = sword_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		groupcaps={
			swordy_dig = {times=mcl_autogroup.digtimes.swordy_dig , uses=60, maxlevel=0},
			swordy_cobweb_dig = {times=mcl_autogroup.digtimes.swordy_cobweb_dig , uses=60, maxlevel=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:sword_stone", {
	description = "Stone Sword",
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_stonesword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		groupcaps={
			swordy_dig = {times=mcl_autogroup.digtimes.swordy_dig , uses=132, maxlevel=0},
			swordy_cobweb_dig = {times=mcl_autogroup.digtimes.swordy_cobweb_dig , uses=132, maxlevel=0},
		},
		damage_groups = {fleshy=5},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:sword_iron", {
	description = "Iron Sword",
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_steelsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		groupcaps={
			swordy_dig = {times=mcl_autogroup.digtimes.swordy_dig, uses=251, maxlevel=0},
			swordy_cobweb_dig = {times=mcl_autogroup.digtimes.swordy_cobweb_dig , uses=251, maxlevel=0},
		},
		damage_groups = {fleshy=6},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:sword_gold", {
	description = "Golden Sword",
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_goldsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		groupcaps={
			swordy_dig = {times=mcl_autogroup.digtimes.swordy_dig, uses=33, maxlevel=0},
			swordy_cobweb_dig = {times=mcl_autogroup.digtimes.swordy_cobweb_dig, uses=33, maxlevel=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_tools:sword_diamond", {
	description = "Diamond Sword",
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_diamondsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		groupcaps={
			swordy_dig = {times=mcl_autogroup.digtimes.swordy_dig, uses=1562, maxlevel=0},
			swordy_cobweb_dig = {times=mcl_autogroup.digtimes.swordy_cobweb_dig, uses=1562, maxlevel=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})

--Shears
minetest.register_tool("mcl_tools:shears", {
	description = "Shears",
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1 },
	tool_capabilities = {
	        full_punch_interval = 0.5,
	        max_drop_level=1,
	        groupcaps={
			shearsy_dig = {times=mcl_autogroup.digtimes.shearsy_dig, uses=238, maxlevel=0},
			shearsy_wool_dig = {times=mcl_autogroup.digtimes.shearsy_wool_dig, uses=238, maxlevel=0},
		}
	},
	sound = { breaks = "default_tool_breaks" },
})


dofile(minetest.get_modpath("mcl_tools").."/crafting.lua")
dofile(minetest.get_modpath("mcl_tools").."/aliases.lua")
