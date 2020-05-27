local S = minetest.get_translator("mcl_brewing_stand")
local NAME_COLOR = "#FFFF4C"

local function active_brewing_formspec(fuel_percent, item_percent)

	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.5,9.5;mcl_brewing_inventory.png]"..
	-- "background[-0.19,-0.25;9.5,9.5;mcl_brewing_inventory_active.png]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.75;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.75,9,1)..
	"list[current_name;fuel;0.5,1.75;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.75,1,1).."image[0.5,1.75;1,1;mcl_brewing_fuel_bg.png]"..
	"list[current_name;input;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[context;stand;4.5,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(4.5,2.5,1,1).."image[4.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;6,2.8;1,1;1]"..
	mcl_formspec.get_itemslot_bg(6,2.8,1,1).."image[6,2.8;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;7.5,2.5;1,1;2]"..
	mcl_formspec.get_itemslot_bg(7.5,2.5,1,1).."image[7.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..

	"image[2.7,3.33;1.28,0.41;mcl_brewing_burner.png^[lowpart:"..
	(100-fuel_percent)..":mcl_brewing_burner_active.png^[transformR270]"..

	"image[2.76,1.4;1,2.15;mcl_brewing_bubbles.png^[lowpart:"..
	(item_percent)..":mcl_brewing_bubbles_active.png]"..

	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_name;input]"..
	"listring[context;stand]"
end

local brewing_formspec = "size[9,8.75]"..
	"background[-0.19,-0.25;9.5,9.5;mcl_brewing_inventory.png]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.75;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.75,9,1)..
	"list[current_name;fuel;0.5,1.75;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.75,1,1).."image[0.5,1.75;1,1;mcl_brewing_fuel_bg.png]"..
	"list[current_name;input;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[context;stand;4.5,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(4.5,2.5,1,1).."image[4.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;6,2.8;1,1;1]"..
	mcl_formspec.get_itemslot_bg(6,2.8,1,1).."image[6,2.8;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;7.5,2.5;1,1;2]"..
	mcl_formspec.get_itemslot_bg(7.5,2.5,1,1).."image[7.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..

	"image[2.7,3.33;1.28,0.41;mcl_brewing_burner.png^[transformR270]"..
	"image[2.76,1.4;1,2.15;mcl_brewing_bubbles.png]"..

	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_name;input]"..
	"listring[context;stand]"


local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end


local function brewable(inv)

	local ingredient = inv:get_stack("input",1):get_name()
	local stands = {"","",""}
	local stand_size = inv:get_size("stand")

	for i=1,stand_size do

		local bottle = inv:get_stack("stand", i):get_name()
		stands[i] = bottle -- initialize the stand

		if bottle == "mcl_potions:potion_river_water" or bottle == "mcl_potions:potion_water" then
			if ingredient == "mcl_nether:nether_wart_item" then
				stands[i] = "mcl_potions:potion_awkward"
			elseif ingredient == "mcl_potions:fermented_spider_eye" then
				stands[i] = "mcl_potions:weakness"
			end

		elseif bottle == "mcl_potions:potion_awkward" then
			if ingredient == "mcl_potions:speckled_melon" then
				stands[i] = "mcl_potions:healing"
			end
		end

	end
	-- if any stand holds a new potion, return the list of new potions
	for i=1,stand_size do
		if stands[i] ~= inv:get_stack("stand", i):get_name() then
			return stands
		end
	end

	return false
end


local function brewing_stand_timer(pos, elapsed)
	-- Inizialize metadata
	local meta = minetest.get_meta(pos)

	local fuel_time = meta:get_float("fuel_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0
	local BREW_TIME = 30 -- all brews take max of 10

	local input_item = meta:get_string("input_item") or ""

	local stand_timer = meta:get_float("stand_timer") or 0
	-- local stand_items = meta:get_list("stand_items") or {"","",""}

	local inv = meta:get_inventory()

	local input_list, stand_list, fuel_list

	local fuel

	local update = true

	while update do

		update = false

		input_list = inv:get_list("input")
		stand_list = inv:get_list("stand")
		fuel_list = inv:get_list("fuel")

		-- TODO ... fix this.  Goal is to reset the process if the stand changes
		-- for i=1, inv:get_size("stand", i) do -- reset the process due to change
		-- 	local _name = inv:get_stack("stand", i):get_name()
		-- 	if  _name ~= stand_items[i] then
		-- 		stand_timer = 0
		-- 		stand_items[i] = _name
		-- 		update = true -- need to update the stand with new data
		--    return 1
		-- 	end
		-- end

		local brew_output = brewable(inv)

		if fuel_time < fuel_totaltime then

			fuel_time = fuel_time + elapsed

			if brew_output then

				stand_timer = stand_timer + elapsed
				-- Replace the stand item with the brew result
				if stand_timer >= BREW_TIME then

					local input_count = inv:get_stack("input",1):get_count()
					if (input_count-1) ~= 0 then
						inv:set_stack("input",1,inv:get_stack("input",1):get_name().." "..(input_count-1))
					else
						inv:set_stack("input",1,"")
					end

					for i=1, inv:get_size("stand") do
						if brew_output[i] then
							minetest.sound_play("mcl_potions_bottle_fill", {pos=pos, gain=0.4, max_hear_range=16}, true)
							inv:set_stack("stand", i, brew_output[i])
							minetest.sound_play("mcl_potions_bottle_pour", {pos=pos, gain=0.6, max_hear_range=16}, true)
						end
					end
					stand_timer = 0
					update = false -- stop the update if brew is complete
				end

			end


		else --get more fuel from fuel_list

			local after_fuel
			fuel, after_fuel = minetest.get_craft_result({method="fuel", width=1, items=fuel_list})

			if brew_output then

				if fuel.time == 0 then --no valid fuel, reset timers

					fuel_totaltime = 0
					stand_timer = 0

				-- only allow blaze powder fuel
				elseif inv:get_stack("fuel",1):get_name() == "mcl_mobitems:blaze_powder" then   -- Grab another fuel
					inv:set_stack("fuel", 1, after_fuel.items[1])

					update = true
					fuel_totaltime = fuel.time + (fuel_time - fuel_totaltime)
					stand_timer = stand_timer + elapsed

				end

			else --if no output potion, stop the process
				fuel_total_time = 0
				stand_timer = 0
			end
			fuel_time = 0
		end
		elapsed = 0
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end

	-- for i=1, inv:get_size("stand") do
	-- 	if stand_list[i]:is_empty() then
	-- 		stand_timer = 0
	-- 	end
	-- end

	--update formspec
	local formspec = brewing_formspec

	local result = false

	if fuel_totaltime ~= 0 then
		local fuel_percent = math.floor(fuel_time/fuel_totaltime*100)
		local brew_percent = math.floor(stand_timer/BREW_TIME*100)
		formspec = active_brewing_formspec(fuel_percent, brew_percent*4 % 100)
		-- swap_node(pos, "mcl_brewing:stand_active")
		result = true
	else
		-- swap_node(pos, "mcl_brewing:stand")
		minetest.get_node_timer(pos):stop()
	end


	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("stand_timer", stand_timer)
	-- meta:set_list("stand_items", stand_list)
	meta:set_string("formspec", formspec)

	return result
end


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then

		-- Test stack with size 1 because we burn one fuel at a time
		local teststack = ItemStack(stack)
		teststack:set_count(1)
		local output, decremented_input = minetest.get_craft_result({method="fuel", width=1, items={teststack}})
		if output.time ~= 0 then
			-- Only allow to place 1 item if fuel get replaced by recipe.
			-- This is the case for lava buckets.
			local replace_item = decremented_input.items[1]
			if replace_item:is_empty() then
				-- For most fuels, just allow to place everything
				return stack:get_count()
			else
				if inv:get_stack(listname, index):get_count() == 0 then
					return 1
				else
					return 0
				end
			end
		else
			return 0
		end
	elseif listname == "input" then
		return stack:get_count()
	elseif listname == "stand" then
		return 0
	end
end


-- Drop input items of brewing_stand at pos with metadata meta
local function drop_brewing_stand_items(pos, meta)

	local inv = meta:get_inventory()

	local stack = inv:get_stack("fuel", 1)
	if not stack:is_empty() then
		local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
		minetest.add_item(p, stack)
	end

	local stack = inv:get_stack("input", 1)
	if not stack:is_empty() then
		local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
		minetest.add_item(p, stack)
	end

	for i=1, inv:get_size("stand") do
		local stack = inv:get_stack("stand", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end


local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

local brewing_stand_def = {
	groups = {pickaxey=1, falling_node=1, crush_after_fall=1, deco_block=1, brewing_stand=1},
	tiles = {"mcl_brewing_top.png", 	--top
					 "mcl_brewing_base.png", 	--bottom
					 "mcl_brewing_side.png", 	--right
				 	 "mcl_brewing_side.png", 	--left
					 "mcl_brewing_side.png", 	--back
				 	 "mcl_brewing_side.png^[transformFX"}, --front
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {

			{-1/16, -5/16, -1/16, 1/16, 8/16, 1/16}, -- heat plume
			{ 2/16, -8/16, -8/16, 8/16, -6/16, -2/16}, -- base
			{-8/16, -8/16, -8/16, -2/16, -6/16, -2/16}, -- base
			{-3/16, -8/16, 2/16, 3/16, -6/16, 8/16}, -- base

			{-7/16, -6/16 ,-7/16 , -6/16,  1/16, -6/16 }, -- bottle 1
			{-6/16, -6/16 ,-6/16 , -5/16,  3/16, -5/16 }, -- bottle 1
			{-5/16, -6/16 ,-5/16 , -4/16,  3/16, -4/16 }, -- bottle 1
			{-4/16, -6/16 ,-4/16 , -3/16,  3/16, -3/16 }, -- bottle 1
			{-3/16, -6/16 ,-3/16 , -2/16,  1/16, -2/16 }, -- bottle 1

			{-5/16, 3/16 ,-5/16 , -4/16,  7/16, -4/16 }, -- line 1
			{-4/16, 6/16 ,-4/16 , -3/16,  8/16, -3/16 }, -- line 1
			{-3/16, 7/16 ,-3/16 , -2/16,  8/16, -2/16 }, -- line 1
			{-2/16, 7/16 ,-2/16 , -1/16,  8/16, -1/16 }, -- line 1


			{7/16, -6/16 ,-7/16 , 6/16,  1/16, -6/16 }, -- bottle 2
			{6/16, -6/16 ,-6/16 , 5/16,  3/16, -5/16 }, -- bottle 2
			{5/16, -6/16 ,-5/16 , 4/16,  3/16, -4/16 }, -- bottle 2
			{4/16, -6/16 ,-4/16 , 3/16,  3/16, -3/16 }, -- bottle 2
			{3/16, -6/16 ,-3/16 , 2/16,  1/16, -2/16 }, -- bottle 2

			{5/16, 3/16 ,-5/16 ,4/16,  7/16, -4/16 }, -- line 2
			{4/16, 6/16 ,-4/16 ,3/16,  8/16, -3/16 }, -- line 2
			{3/16, 7/16 ,-3/16 ,2/16,  8/16, -2/16 }, -- line 2
			{2/16, 7/16 ,-2/16 ,1/16,  8/16, -1/16 }, -- line 2

			{0/16, -6/16 , 2/16 , 1/16, 1/16, 7/16 }, -- bottle 3
			{0/16, 1/16 , 3/16 , 1/16,  3/16, 6/16 }, -- bottle 3

			{0/16, 7/16 , 1/16 , 1/16, 8/16, 3/16 }, -- line 3
			{0/16, 6/16 , 3/16 , 1/16, 7/16, 5/16 }, -- line 3
			{0/16, 3/16 , 4/16 , 1/16, 6/16, 5/16 }, -- line 3
		}
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		drop_brewing_stand_items(pos, meta)
		meta:from_table(meta2:to_table())
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,

	-- allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	-- 	local name = player:get_player_name()
	-- 	if minetest.is_protected(pos, name) then
	-- 		minetest.record_protection_violation(pos, name)
	-- 		return 0
	-- 	end
	-- end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1.0)
		--some code here to enforce only potions getting placed on stands
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("fuel", 1)
		inv:set_size("stand", 3)
		-- inv:set_size("stand2", 1)
		-- inv:set_size("stand3", 1)
		local form = brewing_formspec
		meta:set_string("formspec", form)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
	end,

	on_timer = brewing_stand_timer,
	on_rotate = on_rotate,
}


if minetest.get_modpath("screwdriver") then
	brewing_stand_def.on_rotate = screwdriver.rotate_simple
end

brewing_stand_def.description = S("Brewing Stand")
brewing_stand_def._doc_items_longdesc = S("The stand allows you to brew potions!")
brewing_stand_def._doc_items_usagehelp =
S("To use an brewing_stand, rightclick it. An brewing_stand has 2 input slots (on the left) and one output slot.").."\n"..
S("To rename items, put an item stack in one of the item slots while keeping the other input slot empty. Type in a name, hit enter or “Set Name”, then take the renamed item from the output slot.").."\n"..
S("There are two possibilities to repair tools (and armor):").."\n"..
S("• Tool + Tool: Place two tools of the same type in the input slots. The “health” of the repaired tool is the sum of the “health” of both input tools, plus a 12% bonus.").."\n"..
S("• Tool + Material: Some tools can also be repaired by combining them with an item that it's made of. For example, iron pickaxes can be repaired with iron ingots. This repairs the tool by 25%.").."\n"..
S("Armor counts as a tool. It is possible to repair and rename a tool in a single step.").."\n\n"..
S("The brewing_stand has limited durability and 3 damage levels: undamaged, slightly damaged and very damaged. Each time you repair or rename something, there is a 12% chance the brewing_stand gets damaged. brewing_stand also have a chance of being damaged when they fall by more than 1 block. If a very damaged brewing_stand is damaged again, it is destroyed.")
brewing_stand_def._tt_help = S("Repair and rename items")

minetest.register_node("mcl_brewing:stand", brewing_stand_def)

-- local brewing_stand_active_def = brewing_stand_def
-- brewing_stand_active_def.light_source = 8
-- brewing_stand_active_def.drop = "mcl_brewing:stand"
-- brewing_stand_active_def.groups = {not_in_creative_inventory=1, pickaxey=1, falling_node=1, falling_node_damage=1, crush_after_fall=1, deco_block=1, brewing_stand=1}
-- minetest.register_node("mcl_brewing:stand_active", brewing_stand_active_def)

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "mcl_brewing:stand",
		recipe = {
			{ "", "mcl_mobitems:blaze_rod", "" },
			{ "mcl_core:stone_smooth", "mcl_core:stone_smooth", "mcl_core:stone_smooth" },
		}
	})
end


-- Legacy
minetest.register_lbm({
	label = "Update brewing_stand formspecs (0.60.0",
	name = "mcl_brewing:update_formspec_0_60_0",
	--nodenames = { "group:brewing_stand" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", brewing_formspec)
	end,
})
