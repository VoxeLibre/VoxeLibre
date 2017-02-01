-- Fishing Rod
minetest.register_tool("mcl_fishing:fishing_rod", {
	description = "Fishing Rod",
    groups = { tool=1 },
    inventory_image = "mcl_fishing_fishing_rod.png",
    stack_max = 1,
    liquids_pointable = true,
	on_use = function (itemstack, user, pointed_thing)
		if pointed_thing and pointed_thing.under then
			local node = minetest.get_node(pointed_thing.under)
			if string.find(node.name, "mcl_core:water") then
				local itemname
				local itemcount = 1
				local itemwear = 0
				local r = math.random(1, 100)
				if r <= 85 then
					-- Fish
					r = math.random(1, 100)
					if r <= 60 then
						itemname = "mcl_fishing:fish_raw"
					elseif r <= 85 then
						itemname = "mcl_fishing:salmon_raw"
					elseif r <= 87 then
						itemname = "mcl_fishing:clownfish_raw"
					else
						itemname = "mcl_fishing:pufferfish_raw"
					end
				elseif r <= 95 then
					-- Junk
					r = math.random(1, 83)
					if r <= 10 then
						itemname = "mcl_core:bowl"
					elseif r <= 12 then
						itemname = "mcl_fishing:fishing_rod"
						itemwear = math.random(6554, 65535)	-- 10%-100% damaged
					elseif r <= 22 then
						itemname = "mcl_mobitems:leather"
					elseif r <= 32 then
						itemname = "3d_armor:boots_leather"
						itemwear = math.random(6554, 65535)	-- 10%-100% damaged
					elseif r <= 42 then
						itemname = "mcl_mobitems:rotten_flesh"
					elseif r <= 47 then
						itemname = "mcl_core:stick"
					elseif r <= 52 then
						itemname = "mcl_mobitems:string"
					elseif r <= 62 then
						itemname = "mcl_potions:glass_bottle"
						--TODO itemname = "mcl_potions:bottle_water"
					elseif r <= 72 then
						itemname = "mcl_mobitems:bone"
					elseif r <= 73 then
						itemname = "mcl_dye:black"
						itemcount = 10
					else
						-- TODO: Tripwire hook
						itemname = "mcl_mobitems:string"
					end
				else
					-- Treasure
					r = math.random(1, 6)
					if r == 1 then
						-- TODO: Enchanted
						itemname = "mcl_throwing:bow"
						itemwear = math.random(49144, 65535)	-- 75%-100% damaged
					elseif r == 2 then
						-- TODO: Enchanted book
						itemname = "mcl_core:book"
					elseif r == 3 then
						-- TODO: Enchanted
						itemname = "mcl_fishing:fishing_rod"
						itemwear = math.random(49144, 65535)	-- 75%-100% damaged
					elseif r == 4 then
						itemname = "mobs:nametag"
					elseif r == 5 then
						itemname = "mcl_mobitems:saddle"
					elseif r == 6 then
						itemname = "mcl_flowers:waterlily"
					end
				end
				local inv = user:get_inventory()
				local item = {name=itemname, count=itemcount, wear=itemwear, metadata=""}
				if inv:room_for_item("main", item) then
					inv:add_item("main", item)
				end
				if not minetest.setting_get("creative_mode") then
					itemstack:add_wear(66000/65) -- 65 uses
				end
				return itemstack
			end
		end
		return nil
	end,
})

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_mobitems:string'},
		{'mcl_core:stick','','mcl_mobitems:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
		{'mcl_mobitems:string','','mcl_core:stick'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_fishing:fishing_rod",
	burntime = 15,
})


-- Fish
minetest.register_craftitem("mcl_fishing:fish_raw", {
	description = "Raw Fish",
	inventory_image = "mcl_fishing_fish_raw.png",
	on_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
})

minetest.register_craftitem("mcl_fishing:fish_cooked", {
	description = "Cooked Fish",
	inventory_image = "mcl_fishing_fish_cooked.png",
	on_use = minetest.item_eat(5),
	stack_max = 64,
	groups = { food=2, eatable=5 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:fish_cooked",
	recipe = "mcl_fishing:fish_raw",
	cooktime = 10,
})

-- Salmon
minetest.register_craftitem("mcl_fishing:salmon_raw", {
	description = "Raw Salmon",
	inventory_image = "mcl_fishing_salmon_raw.png",
	on_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
})

minetest.register_craftitem("mcl_fishing:salmon_cooked", {
	description = "Cooked Salmon",
	inventory_image = "mcl_fishing_salmon_cooked.png",
	on_use = minetest.item_eat(6),
	stack_max = 64,
	groups = { food=2, eatable=6 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:salmon_cooked",
	recipe = "mcl_fishing:salmon_raw",
	cooktime = 10,
})

-- Clownfish
minetest.register_craftitem("mcl_fishing:clownfish_raw", {
	description = "Clownfish",
	inventory_image = "mcl_fishing_clownfish_raw.png",
	on_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable = 1 },
})

-- Pufferfish
minetest.register_craftitem("mcl_fishing:pufferfish_raw", {
	description = "Pufferfish",
	inventory_image = "mcl_fishing_pufferfish_raw.png",
	on_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable=1 },
})

