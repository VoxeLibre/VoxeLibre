local enchanting_table_formspec = ""
	.. "size[9.07,8.6;]"
	.. "formspec_version[3]"
	.. "label[0,0;" .. minetest.formspec_escape(minetest.colorize("#313131", "Enchant")) .. "]"
	.. mcl_formspec.get_itemslot_bg(1.1, 2.4, 1, 1)
	.. "image[1.1,2.4;1,1;mcl_enchanting_lapis_background.png]"
	.. "list[context;lapis;1.1,2.4;1,1;]"
	.. mcl_formspec.get_itemslot_bg(0.2, 2.4, 1, 1)
	.. "list[context;tool;0.2,2.4;1,1;]"
	.. "label[0,4;" .. minetest.formspec_escape(minetest.colorize("#313131", "Inventory")) .. "]"
	.. mcl_formspec.get_itemslot_bg(0,4.5,9,3)
	.. mcl_formspec.get_itemslot_bg(0,7.74,9,1)
	.. "list[current_player;main;0,4.5;9,3;9]"
	.. "listring[]"
	.. "list[current_player;main;0,7.74;9,1;]"
	.. "real_coordinates[true]"
	.. "image[3.15,0.6;7.6,4.1;mcl_enchanting_button_background.png]" 

local bookshelf_positions = {{x = 1}, {x = -1}, {z = 1}, {z = -1}}

for _, p in pairs(bookshelf_positions) do
	for _, d in pairs({"x", "y", "z"}) do
		p[d] = p[d] or 0
	end
end

minetest.register_abm({
	name = "Enchanting table bookshelf particles",
	interval = 0.1,
	chance = 1,
	nodenames = "mcl_books:bookshelf",
	action = function(pos)
		for _, relative_pos in pairs(bookshelf_positions) do
			if minetest.get_node(vector.add(pos, vector.multiply(relative_pos, 2))).name == "mcl_enchanting:table" and minetest.get_node(vector.add(pos, relative_pos, 2)).name == "air" then
				minetest.add_particle({
					pos = pos,
					velocity = vector.subtract(relative_pos, vector.new(0, -2, 0)),
					acceleration = {x = 0, y = -2, z = 0},
					expirationtime = 2,
					size = 2,
					texture = "mcl_enchanting_glyph_" .. math.random(18) .. ".png"
				})
			end
		end
	end
}) 


function mcl_enchanting.update_formspec(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory() 
	local full_tool_name = inv:get_stack("tool", 1):get_name()
	local shortened_tool_name = mcl_enchanting.all_tools[full_tool_name]
	local supported_enchantments = (shortened_tool_name and mcl_enchanting.tools[shortened_tool_name].enchantments or {})
	local sup_ench = false
	local formspec = enchanting_table_formspec
	local e_list = minetest.deserialize(meta:get_string("enchantments"))
	local y = 0.65
	for i, e in pairs(e_list) do
		local enchantment_supported = table.indexof(supported_enchantments, e.enchantment) ~= -1
		sup_ench = sup_ench or enchantment_supported
		local enough_lapis = inv:contains_item("lapis", ItemStack(mcl_enchanting.lapis_itemstring .. " " .. e.cost))
		local ending = (enough_lapis and enchantment_supported and "" or "_off")
		local hover_ending = (enough_lapis and enchantment_supported and "_hovered" or "_off")
		formspec = formspec
			.. "container[3.2," .. y .. "]"
			.. (enchantment_supported and "tooltip[button_" .. i .. ";" .. C("#818181") .. mcl_enchanting.get_enchantment_description(e.enchantment, e.level) .. " " .. C("#FFFFFF") .. " . . . ?\n\n" .. C(enough_lapis and "#818181" or "#FC5454") .. e.cost .. " Lapis Lazuli" .. "]" or "")
			.. "style[button_" .. i .. ";bgimg=mcl_enchanting_button" .. ending .. ".png;bgimg_hovered=mcl_enchanting_button" .. hover_ending .. ".png;bgimg_pressed=mcl_enchanting_button" .. hover_ending .. ".png]"
			.. "button[0,0;7.5,1.3;button_" .. i .. ";]"
			.. (enchantment_supported and "image[0,0;1.3,1.3;mcl_enchanting_number_" .. i .. ending .. ".png]" or "")
			.. (enchantment_supported and e.glyphs or "")
			.. "container_end[]"
		y = y + 1.35
	end
	formspec = formspec
		.. "image[" .. (sup_ench and 0.58 or 1.15) .. ",1.2;" .. (sup_ench and 2 or 0.87) .. ",1.43;mcl_enchanting_book_" .. (sup_ench and "open" or "closed") .. ".png]"
	meta:set_string("formspec", formspec)
end

function mcl_enchanting.progress_formspec_input(pos, _, fields, player)
	if fields.quit then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local e_list = minetest.deserialize(meta:get_string("enchantments"))
	local button_pressed
	for i = 1, 3 do
		if fields["button_" .. i] then
			button_pressed = i
		end
	end
	if not button_pressed then return end
	local e = e_list[button_pressed]
	local lapis_cost = ItemStack(mcl_enchanting.lapis_itemstring .. " " .. e.cost)
	if not inv:contains_item("lapis", lapis_cost) then return end
	local tool_stack = inv:get_stack("tool", 1)
	local full_tool_name = tool_stack:get_name()
	local shortened_tool_name = mcl_enchanting.all_tools[full_tool_name]
	if not shortened_tool_name then return end
	if table.indexof(mcl_enchanting.tools[shortened_tool_name].enchantments, e.enchantment) == -1 then return end		
	local wear = tool_stack:get_wear()
	inv:remove_item("lapis", lapis_cost)
	local enchanted_tool_stack = ItemStack(full_tool_name .. "_enchanted_" .. e.enchantment .. "_" .. e.level)
	enchanted_tool_stack:add_wear(tool_stack:get_wear())
	inv:set_stack("tool", 1, enchanted_tool_stack)
	minetest.sound_play("mcl_enchanting_enchant", {to_player = player:get_player_name(), gain = 5.0})
	mcl_enchanting.add_enchantments(pos)
end


function mcl_enchanting.drop_inventory(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	for _, listname in ipairs({"tool", "lapis"}) do
		local stack = inv:get_stack(listname, 1)
		if not stack:is_empty() then
			minetest.add_item(vector.add(pos, {x = math.random(0, 10) / 10 - 0.5, y = 0, z = math.random(0, 10) / 10 - 0.5}), stack)
		end
	end
end

function mcl_enchanting.init_table(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("lapis", 1)
	mcl_enchanting.add_enchantments(pos)
	minetest.add_entity(vector.add(pos, mcl_enchanting.book_offset), "mcl_enchanting:book")
end

function mcl_enchanting.add_enchantments_to_table(pos)
	local meta = minetest.get_meta(pos)
	local e_list = {}
	for i = 1, 3 do
		local e = {}
		e.cost = math.random(mcl_enchanting.max_cost)
		e.enchantment = mcl_enchanting.enchantment_name_list[math.random(#mcl_enchanting.enchantment_name_list)]
		local max_level = mcl_enchanting.enchantments[e.enchantment].max_level
		e.level = max_level + 1 - math.ceil(math.pow(math.random(math.pow(max_level, mcl_enchanting.level_rarity_grade)), 1 / mcl_enchanting.level_rarity_grade))
		e.glyphs = ""
		local x = 1.3
		for i = 1, 9 do			
			e.glyphs = e.glyphs .. "image[".. x .. ",0.1;0.5,0.5;mcl_enchanting_glyph_" .. math.random(18) .. ".png^[colorize:#675D49:255]"
			x = x + 0.6
		end
		e_list[i] = e
	end
	meta:set_string("enchantments", minetest.serialize(e_list))
	mcl_enchanting.update_formspec(pos)
end

minetest.register_node("mcl_enchanting:table", {
	description = "Enchanting Table",
	drawtype = "nodebox",
	tiles = {"mcl_enchanting_table_top.png",  "mcl_enchanting_table_bottom.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png"},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey = 2},
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,
	on_rotate = (screwdriver or {}).rotate_simple,
	on_construct = mcl_enchanting.init_table,
	on_destruct = mcl_enchanting.drop_inventory,
	after_destruct = mcl_enchanting.check_book,
	on_receive_fields = mcl_enchanting.progress_formspec_input,
	on_metadata_inventory_put = mcl_enchanting.update_formspec,
	on_metadata_inventory_take = mcl_enchanting.update_formspec,
	allow_metadata_inventory_put = function(_, listname, _, stack)
		if listname == "lapis" then
			return (stack:get_name() == mcl_enchanting.lapis_itemstring) and stack:get_count() or 0
		end
		return 1
	end,
	allow_metadata_inventory_move = function()
		return 0
	end,
}) 

minetest.register_craft({
	output = "mcl_enchanting:table",
	recipe = {
		{"", "mcl_books:book", ""},
		{"mcl_core:diamond", "mcl_core:obsidian", "mcl_core:diamond"},
		{"mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian"}
	}
})
