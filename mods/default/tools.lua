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
minetest.register_tool("default:pick_wood", {
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
minetest.register_tool("default:pick_stone", {
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
minetest.register_tool("default:pick_steel", {
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
minetest.register_tool("default:pick_gold", {
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
minetest.register_tool("default:pick_diamond", {
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

-- Shovels
minetest.register_tool("default:shovel_wood", {
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
})
minetest.register_tool("default:shovel_stone", {
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
})
minetest.register_tool("default:shovel_steel", {
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
})
minetest.register_tool("default:shovel_gold", {
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
})
minetest.register_tool("default:shovel_diamond", {
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
})

-- Axes
minetest.register_tool("default:axe_wood", {
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
minetest.register_tool("default:axe_stone", {
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
minetest.register_tool("default:axe_steel", {
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
minetest.register_tool("default:axe_gold", {
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
minetest.register_tool("default:axe_diamond", {
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
minetest.register_tool("default:sword_wood", {
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
minetest.register_tool("default:sword_stone", {
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
minetest.register_tool("default:sword_steel", {
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
minetest.register_tool("default:sword_gold", {
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
minetest.register_tool("default:sword_diamond", {
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

-- Flint and Steel
minetest.register_tool("default:flint_and_steel", {
	description = "Flint and Steel",
	inventory_image = "default_tool_flint_and_steel.png",
	liquids_pointable = false,
	stack_max = 1,
	groups = { tool = 1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=0,
		groupcaps={
			flamable = {uses=65, maxlevel=1},
		}
	},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			if minetest.get_node(pointed_thing.under).name == "tnt:tnt" then
				tnt.ignite(pointed_thing.under)
			else
				set_fire(pointed_thing)
				itemstack:add_wear(66000/65) -- 65 uses
				return itemstack
			end
		end
	end,
})

-- Fishing Pole
minetest.register_tool("default:pole", {
	description = "Fishing Rod",
    groups = { tool=1 },
    inventory_image = "default_tool_fishing_pole.png",
    stack_max = 1,
    liquids_pointable = true,
	on_use = function (itemstack, user, pointed_thing)
		if pointed_thing and pointed_thing.under then
			local node = minetest.get_node(pointed_thing.under)
			if string.find(node.name, "default:water") then
				local itemname
				local itemcount = 1
				local r = math.random(1, 100)
				if r <= 85 then
					-- Fish
					r = math.random(1, 100)
					if r <= 60 then
						itemname = "default:fish"
					elseif r <= 85 then
						itemname = "default:fish"
						--itemname = "default:salmon"
					elseif r <= 87 then
						itemname = "default:fish"
						--itemname = "default:clownfish"
					else
						itemname = "default:fish"
						--itemname = "default:pufferfish"
					end
				elseif r <= 95 then
					-- Junk
					r = math.random(1, 83)
					if r <= 10 then
						itemname = "default:bowl"
					elseif r <= 12 then
						-- TODO: Damaged
						itemname = "default:pole"
					elseif r <= 22 then
						itemname = "mcl_mobitems:leather"
					elseif r <= 32 then
						itemname = "3d_armor:boots_leather"
					elseif r <= 42 then
						itemname = "mcl_mobitems:rotten_flesh"
					elseif r <= 47 then
						itemname = "default:stick"
					elseif r <= 52 then
						itemname = "default:string"
					elseif r <= 62 then
						itemname = "vessels:glass_bottle"
						--TODO itemname = "mcl_potions:bottle_water"
					elseif r <= 72 then
						itemname = "default:bone"
					elseif r <= 73 then
						itemname = "dye:black"
						itemcount = 10
					else
						-- TODO: Tripwire hook
						itemname = "default:stick"
					end
				else
					-- Treasure
					r = math.random(1, 6)
					if r == 1 then
						-- TODO: Enchanted and damaged
						itemname = "throwing:bow"
					elseif r == 2 then
						-- TODO: Enchanted book
						itemname = "default:book"
					elseif r == 3 then
						-- TODO: Enchanted and damaged
						itemname = "default:pole"
					elseif r == 4 then
						itemname = "mcl_mobitems:spider_eye"
						-- TODO itemname = "mobs:naming_tag"
					elseif r == 5 then
						itemname = "flowers:dandelion"
						-- TODO itemname = "mobs:saddle"
					elseif r == 6 then
						itemname = "flowers:tulip_orange"
						-- TODO itemname = "flowers:waterlily"
					end
				end
				local inv = user:get_inventory()
				if inv:room_for_item("main", {name=itemname, count=1, wear=0, metadata=""}) then
					inv:add_item("main", {name=itemname, count=1, wear=0, metadata=""})
				end
				itemstack:add_wear(66000/65) -- 65 uses
				return itemstack
			end
		end
		return nil
	end,
})

--Shears
minetest.register_tool("default:shears", {
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


