-- mods/default/tools.lua

--
-- Tool definition
--

-- The hand
local groupcaps
if minetest.setting_getbool("creative_mode") then
	groupcaps = {
		snappy = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=255},
		cracky = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=255},
		crumbly = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=255},
		choppy = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=255},
		oddly_breakable_by_hand = {times={[1]=0, [2]=0, [3]=0, [4]=0, [5]=0}, uses=0, maxlevel=255},
	}
else
	groupcaps = {
		crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
		snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
		oddly_breakable_by_hand = {times={[0]=90.00,[1]=7.00,[2]=4.00,[3]=1.40,[4]=480.70,}, uses=0, maxlevel=5}
	}
end
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
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
		max_drop_level=0,
		groupcaps={
			cracky = {times={[3]=1.60}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
})
minetest.register_tool("mcl_core:pick_stone", {
	description = "Stone Pickaxe",
	inventory_image = "default_tool_stonepick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.20}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
})
minetest.register_tool("mcl_core:pick_steel", {
	description = "Iron Pickaxe",
	inventory_image = "default_tool_steelpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
})
minetest.register_tool("mcl_core:pick_gold", {
	description = "Golden Pickaxe",
	inventory_image = "default_tool_goldpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.20}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
})
minetest.register_tool("mcl_core:pick_diamond", {
	description = "Diamond Pickaxe",
	inventory_image = "default_tool_diamondpick.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50,[4]=20.00 }, uses=30, maxlevel=4},
		},
		damage_groups = {fleshy=5},
	},
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
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=3.00, [2]=1.60, [3]=0.60}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
})
minetest.register_tool("mcl_core:shovel_stone", {
	description = "Stone Shovel",
	inventory_image = "default_tool_stoneshovel.png",
	wield_image = "default_tool_stoneshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	on_place = make_grass_path,
})
minetest.register_tool("mcl_core:shovel_steel", {
	description = "Iron Shovel",
	inventory_image = "default_tool_steelshovel.png",
	wield_image = "default_tool_steelshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	on_place = make_grass_path,
})
minetest.register_tool("mcl_core:shovel_gold", {
	description = "Golden Shovel",
	inventory_image = "default_tool_goldshovel.png",
	wield_image = "default_tool_goldshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
	on_place = make_grass_path,
})
minetest.register_tool("mcl_core:shovel_diamond", {
	description = "Diamond Shovel",
	inventory_image = "default_tool_diamondshovel.png",
	wield_image = "default_tool_diamondshovel.png^[transformR90",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	on_place = make_grass_path,
})

-- Axes
minetest.register_tool("mcl_core:axe_wood", {
	description = "Wooden Axe",
	inventory_image = "default_tool_woodaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=0,
		groupcaps={
			choppy = {times={[2]=3.00, [3]=2.00}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=7},
	},
})
minetest.register_tool("mcl_core:axe_stone", {
	description = "Stone Axe",
	inventory_image = "default_tool_stoneaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=0,
		groupcaps={
			choppy={times={[1]=3.00, [2]=2.00, [3]=1.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=9},
	},
})
minetest.register_tool("mcl_core:axe_steel", {
	description = "Iron Axe",
	inventory_image = "default_tool_steelaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=9},
	},
})
minetest.register_tool("mcl_core:axe_gold", {
	description = "Golden Axe",
	inventory_image = "default_tool_goldaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=0,
		groupcaps={
			choppy={times={[1]=3.00, [2]=2.00, [3]=1.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=7},
	},
})
minetest.register_tool("mcl_core:axe_diamond", {
	description = "Diamond Axe",
	inventory_image = "default_tool_diamondaxe.png",
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=9},
	},
})

-- Swords
minetest.register_tool("mcl_core:sword_wood", {
	description = "Wooden Sword",
	inventory_image = "default_tool_woodsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	}
})
minetest.register_tool("mcl_core:sword_stone", {
	description = "Stone Sword",
	inventory_image = "default_tool_stonesword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=5},
	}
})
minetest.register_tool("mcl_core:sword_steel", {
	description = "Iron Sword",
	inventory_image = "default_tool_steelsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	}
})
minetest.register_tool("mcl_core:sword_gold", {
	description = "Golden Sword",
	inventory_image = "default_tool_goldsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	}
})
minetest.register_tool("mcl_core:sword_diamond", {
	description = "Diamond Sword",
	inventory_image = "default_tool_diamondsword.png",
	groups = { weapon=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	}
})

--Shears
minetest.register_tool("mcl_core:shears", {
	description = "Shears",
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	max_drop_level=3,
	groups = { tool=1 },
	tool_capabilities = {
	        full_punch_interval = 0.5,
	        max_drop_level=1,
	        groupcaps={
				leaves={times={[1]=0,[2]=0,[3]=0}, uses=283, maxlevel=1},
				wool={times={[1]=0.2,[2]=0.2,[3]=0.2}, uses=283, maxlevel=1},
				snappy={times={[1]=0.2,[2]=0.2,[3]=0.2}, uses=283, maxlevel=1},
        	}
    }
})


