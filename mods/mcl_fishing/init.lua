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
				local r = math.random(1, 100)
				if r <= 85 then
					-- Fish
					r = math.random(1, 100)
					if r <= 60 then
						itemname = "mcl_fishing:fish_raw"
					elseif r <= 85 then
						itemname = "mcl_fishing:fish_raw"
						--itemname = "mcl_core:salmon"
					elseif r <= 87 then
						itemname = "mcl_fishing:fish_raw"
						--itemname = "mcl_core:clownfish"
					else
						itemname = "mcl_fishing:fish_raw"
						--itemname = "mcl_core:pufferfish"
					end
				elseif r <= 95 then
					-- Junk
					r = math.random(1, 83)
					if r <= 10 then
						itemname = "mcl_fishing:bowl"
					elseif r <= 12 then
						-- TODO: Damaged
						itemname = "mcl_fishing:fishing_rod"
					elseif r <= 22 then
						itemname = "mcl_mobitems:leather"
					elseif r <= 32 then
						itemname = "3d_armor:boots_leather"
					elseif r <= 42 then
						itemname = "mcl_mobitems:rotten_flesh"
					elseif r <= 47 then
						itemname = "mcl_core:stick"
					elseif r <= 52 then
						itemname = "mcl_core:string"
					elseif r <= 62 then
						itemname = "mcl_potions:glass_bottle"
						--TODO itemname = "mcl_potions:bottle_water"
					elseif r <= 72 then
						itemname = "mcl_core:bone"
					elseif r <= 73 then
						itemname = "mcl_dye:black"
						itemcount = 10
					else
						-- TODO: Tripwire hook
						itemname = "mcl_core:string"
					end
				else
					-- Treasure
					r = math.random(1, 6)
					if r == 1 then
						-- TODO: Enchanted and damaged
						itemname = "throwing:bow"
					elseif r == 2 then
						-- TODO: Enchanted book
						itemname = "mcl_core:book"
					elseif r == 3 then
						-- TODO: Enchanted and damaged
						itemname = "mcl_fishing:fishing_rod"
					elseif r == 4 then
						itemname = "mobs:naming_tag"
					elseif r == 5 then
						itemname = "mcl_mobitems:saddle"
					elseif r == 6 then
						itemname = "mcl_flowers:waterlily"
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

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_core:string'},
		{'mcl_core:stick','','mcl_core:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_core:string', 'mcl_core:stick', ''},
		{'mcl_core:string','','mcl_core:stick'},
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

