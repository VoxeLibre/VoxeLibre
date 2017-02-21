
--
-- Formspecs
--

local function active_formspec(fuel_percent, item_percent)
	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_inventory_furnace.png]"..
	mcl_vars.inventory_header..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[current_name;src;2.75,0.5;1,1;]"..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"list[current_name;dst;5.75,1.5;1,1;]"..
	"image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
	(100-fuel_percent)..":default_furnace_fire_fg.png]"..
	"image[4.1,1.5;1.5,1;gui_furnace_arrow_bg.png^[lowpart:"..
	(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
	"image_button[8,0;1,1;craftguide_book.png;__mcl_craftguide;]"..
	"tooltip[__mcl_craftguide;Show crafting recipes]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"
end

local inactive_formspec = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_inventory_furnace.png]"..
	mcl_vars.inventory_header..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[current_name;src;2.75,0.5;1,1;]"..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"list[current_name;dst;5.75,1.5;1,1;]"..
	"image[2.75,1.5;1,1;default_furnace_fire_bg.png]"..
	"image[4.1,1.5;1.5,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"image_button[8,0;1,1;craftguide_book.png;__mcl_craftguide;]"..
	"tooltip[__mcl_craftguide;Show crafting recipes]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"

local craftguide = function(pos, formname, fields, sender)
	if fields.__mcl_craftguide then
		mcl_craftguide.show_craftguide(sender)
	end
end

--
-- Node callback functions that are the same for active and inactive furnace
--

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			return stack:get_count()
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Inizialize metadata
	--
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local src_time = meta:get_float("src_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local srclist, fuellist

	local cookable, cooked
	local fuel

	local update = true
	while update do
		update = false

		srclist = inv:get_list("src")
		fuellist = inv:get_list("fuel")

		--
		-- Cooking
		--

		-- Check if we have cookable content
		local aftercooked
		cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		cookable = cooked.time ~= 0

		-- Check if we have enough fuel to burn
		if fuel_time < fuel_totaltime then
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + elapsed
			-- If there is a cookable item then check if it is ready yet
			if cookable then
				src_time = src_time + elapsed
				if src_time >= cooked.time then
					-- Place result in dst list if possible
					if inv:room_for_item("dst", cooked.item) then
						inv:add_item("dst", cooked.item)
						inv:set_stack("src", 1, aftercooked.items[1])
						src_time = src_time - cooked.time
						update = true
					end
				end
			end
		else
			-- Furnace ran out of fuel
			if cookable then
				-- We need to get new fuel
				local afterfuel
				fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

				if fuel.time == 0 then
					-- No valid fuel in fuel list
					fuel_totaltime = 0
					src_time = 0
				else
					-- Take fuel from fuel list
					inv:set_stack("fuel", 1, afterfuel.items[1])
					update = true
					fuel_totaltime = fuel.time + (fuel_time - fuel_totaltime)
					src_time = src_time + elapsed
				end
			else
				-- We don't need to get new fuel since there is no cookable item
				fuel_totaltime = 0
				src_time = 0
			end
			fuel_time = 0
		end

		elapsed = 0
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end
	if srclist[1]:is_empty() then
		src_time = 0
	end

	--
	-- Update formspec and node
	--
	local formspec = inactive_formspec
	local item_state
	local item_percent = 0
	if cookable then
		item_percent = math.floor(src_time / cooked.time * 100)
	end

	local result = false

	if fuel_totaltime ~= 0 then
		local fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
		formspec = active_formspec(fuel_percent, item_percent)
		swap_node(pos, "mcl_furnaces:furnace_active")
		-- make sure timer restarts automatically
		result = true
	else
		swap_node(pos, "mcl_furnaces:furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
	end

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("src_time", src_time)
	meta:set_string("formspec", formspec)

	return result
end

minetest.register_node("mcl_furnaces:furnace", {
	description = "Furnace",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_furnace_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2, container=4, deco_block=1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),

	on_timer = furnace_node_timer,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			local stack = inv:get_stack(listname, 1)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('fuel', 1)
		inv:set_size('dst', 1)
	end,

	on_metadata_inventory_move = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(1.0)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_receive_fields = craftguide,
})

minetest.register_node("mcl_furnaces:furnace_active", {
	description = "Burning Furnace",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_furnace_front_active.png",
	},
	paramtype2 = "facedir",
	light_source = 13,
	drop = "mcl_furnaces:furnace",
	groups = {cracky=2, container=4, deco_block=1, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_timer = furnace_node_timer,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			local stack = inv:get_stack(listname, 1)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,


	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_receive_fields = craftguide,
})

minetest.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_core:cobble", "", "mcl_core:cobble" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	}
})
