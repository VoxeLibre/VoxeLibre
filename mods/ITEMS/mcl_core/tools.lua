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

-- Table for tool digging times, everything from 0 to 250
-- Minecraft digging times are always multiples of 0.05
local tooltimes = {}
for i=1,5000 do
	local time
	if i == 1 then
		time = 0
	else
		time = i*0.05
	end
	table.insert(tooltimes, time)
end

-- TODO: Add legacy support for Minetest Game groups like crumbly, snappy, cracky, etc. for all tools

-- The hand
local groupcaps
if minetest.setting_getbool("creative_mode") then
	groupcaps = {
		creative_breakable = {times={[1]=0}, uses=0},

	}
else
	groupcaps = {
		handy_dig = {times=tooltimes, uses=0},
	}
end
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	range = 3.975,
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level = 0,
		groupcaps = groupcaps,
		damage_groups = {fleshy=1},
	}
})

-- Picks
minetest.register_tool("mcl_core:pick_wood", {
	description = "Wooden Pickaxe",
	inventory_image = "default_tool_woodpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		groupcaps={
			pickaxey_dig_wood = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=2},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:pick_stone", {
	description = "Stone Pickaxe",
	inventory_image = "default_tool_stonepick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		groupcaps={
			pickaxey_dig_stone = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=3},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:pick_iron", {
	description = "Iron Pickaxe",
	inventory_image = "default_tool_steelpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=4,
		groupcaps={
			pickaxey_dig_iron = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:pick_gold", {
	description = "Golden Pickaxe",
	inventory_image = "default_tool_goldpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=2,
		groupcaps={
			pickaxey_dig_gold = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=2},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:pick_diamond", {
	description = "Diamond Pickaxe",
	inventory_image = "default_tool_diamondpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		groupcaps={
			pickaxey_dig_diamond = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=5},
	},
	sound = { breaks = "default_tool_breaks" },
})

local make_grass_path = function(itemstack, placer, pointed_thing)
	if minetest.get_node(pointed_thing.under).name == "mcl_core:dirt_with_grass" and pointed_thing.above.y == pointed_thing.under.y then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if minetest.get_node(above).name == "air" then
			if not minetest.setting_getbool("creative_mode") then
				-- Add wear, as if digging a level 0 crumbly node
				local def = minetest.registered_items[itemstack:get_name()]
				local base_uses = def.tool_capabilities.groupcaps.crumbly.uses
				local maxlevel = def.tool_capabilities.groupcaps.crumbly.maxlevel
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
minetest.register_tool("mcl_core:shovel_wood", {
	description = "Wooden Shovel",
	inventory_image = "default_tool_woodshovel.png",
	wield_image = "default_tool_woodshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		groupcaps={
			shovely_dig_wood = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:shovel_stone", {
	description = "Stone Shovel",
	inventory_image = "default_tool_stoneshovel.png",
	wield_image = "default_tool_stoneshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		groupcaps={
			shovely_dig_stone = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=3},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:shovel_iron", {
	description = "Iron Shovel",
	inventory_image = "default_tool_steelshovel.png",
	wield_image = "default_tool_steelshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=4,
		groupcaps={
			shovely_dig_iron= {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:shovel_gold", {
	description = "Golden Shovel",
	inventory_image = "default_tool_goldshovel.png",
	wield_image = "default_tool_goldshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=2,
		groupcaps={
			shovely_dig_gold = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:shovel_diamond", {
	description = "Diamond Shovel",
	inventory_image = "default_tool_diamondshovel.png",
	wield_image = "default_tool_diamondshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		groupcaps={
			shovely_dig_diamond = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=5},
	},
	on_place = make_grass_path,
	sound = { breaks = "default_tool_breaks" },
})

-- Axes
minetest.register_tool("mcl_core:axe_wood", {
	description = "Wooden Axe",
	inventory_image = "default_tool_woodaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=1,
		groupcaps={
			axey_dig_wood = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:axe_stone", {
	description = "Stone Axe",
	inventory_image = "default_tool_stoneaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=3,
		groupcaps={
			axey_dig_stone = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:axe_iron", {
	description = "Iron Axe",
	inventory_image = "default_tool_steelaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=4,
		groupcaps={
			axey_dig_iron = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:axe_gold", {
	description = "Golden Axe",
	inventory_image = "default_tool_goldaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		groupcaps={
			axey_dig_gold = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:axe_diamond", {
	description = "Diamond Axe",
	inventory_image = "default_tool_diamondaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		groupcaps={
			axey_dig_diamond = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=9},
	},
	sound = { breaks = "default_tool_breaks" },
})

-- Swords
minetest.register_tool("mcl_core:sword_wood", {
	description = "Wooden Sword",
	inventory_image = "default_tool_woodsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		groupcaps={
			swordy_dig = {times=tooltimes, uses=0},
			swordy_cobweb_dig = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:sword_stone", {
	description = "Stone Sword",
	inventory_image = "default_tool_stonesword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		groupcaps={
			swordy_dig = {times=tooltimes, uses=0},
			swordy_cobweb_dig = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=5},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:sword_iron", {
	description = "Iron Sword",
	inventory_image = "default_tool_steelsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		groupcaps={
			swordy_dig = {times=tooltimes, uses=0},
			swordy_cobweb_dig = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=6},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:sword_gold", {
	description = "Golden Sword",
	inventory_image = "default_tool_goldsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		groupcaps={
			swordy_dig = {times=tooltimes, uses=0},
			swordy_cobweb_dig = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = { breaks = "default_tool_breaks" },
})
minetest.register_tool("mcl_core:sword_diamond", {
	description = "Diamond Sword",
	inventory_image = "default_tool_diamondsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		groupcaps={
			swordy_dig = {times=tooltimes, uses=0},
			swordy_cobweb_dig = {times=tooltimes, uses=0},
		},
		damage_groups = {fleshy=7},
	},
	sound = { breaks = "default_tool_breaks" },
})

--Shears
minetest.register_tool("mcl_core:shears", {
	description = "Shears",
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1 },
	tool_capabilities = {
	        full_punch_interval = 0.5,
	        max_drop_level=1,
	        groupcaps={
			shearsy_dig = {times=tooltimes, uses=0},
			shearsy_wool_dig = {times=tooltimes, uses=0},
		}
	},
	sound = { breaks = "default_tool_breaks" },
})


