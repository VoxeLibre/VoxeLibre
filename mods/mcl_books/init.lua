-- Book
minetest.register_craftitem("mcl_books:book", {
	description = "Book",
	inventory_image = "default_book.png",
	stack_max = 64,
	groups = { book=1 },
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_books:book',
	recipe = { 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:paper', 'mcl_mobitems:leather', }
})

local write = function(itemstack, user, pointed_thing)
	local text = itemstack:get_metadata()
	local formspec = "size[8,9]"..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
		"textarea[0.5,0.25;7.5,9.25;text;;"..minetest.formspec_escape(text).."]"..
		"button[0.5,8.15;3,1;sign;Sign]"..
		"button_exit[4,8.15;3,1;ok;Done]"
	minetest.show_formspec(user:get_player_name(), "mcl_books:writable_book", formspec)
end

local read = function(itemstack, user, pointed_thing)
	local meta = minetest.deserialize(itemstack:get_metadata())
	local text
	if meta ~= nil then
		text = meta.text
	end
	if text == nil then
		text = ""
	end
	local formspec = "size[8,9]"..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
		"textarea[0.5,0.25;7.5,9.25;;"..core.colorize("#000000", minetest.formspec_escape(text))..";]"..
		"button_exit[2.5,8.15;3,1;ok;Done]"
	minetest.show_formspec(user:get_player_name(), "mcl_books:written_book", formspec)
end

-- Book and Quill
minetest.register_craftitem("mcl_books:writable_book", {
	description = "Book and Quill",
	inventory_image = "mcl_books_book_writable.png",
	groups = { book=1 },
	stack_max = 1,
	on_place = write,
	on_secondary_use = write,
})

minetest.register_on_player_receive_fields(function ( player, formname, fields )
	if ((formname == "mcl_books:writable_book") and fields and fields.text) then
		local stack = player:get_wielded_item()
		if (stack:get_name() and (stack:get_name() == "mcl_books:writable_book")) then
			if fields.ok then
				local t = stack:to_table()
				t.metadata = fields.text
				player:set_wielded_item(ItemStack(t))
			elseif fields.sign then
				local t = stack:to_table()
				t.metadata = fields.text
				player:set_wielded_item(ItemStack(t))

				local text = stack:get_metadata()
				local name = player:get_player_name()
				local formspec = "size[8,9]"..
					"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
					"field[0.5,1;7.5,1;title;"..core.colorize("#000000", "Enter book title:")..";]"..
					"label[0.5,1.5;"..core.colorize("#404040", minetest.formspec_escape("by " .. name)).."]"..
					"label[0.5,7.15;"..core.colorize("#000000", "Note: The book will no longer") .. "\n" .. core.colorize("#000000", "be editable after signing.").."]"..
					"button_exit[0.5,8.15;3,1;sign;Sign and Close]"..
					"button[4,8.15;3,1;cancel;Cancel]"
				minetest.show_formspec(player:get_player_name(), "mcl_books:signing", formspec)
			end
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.sign and fields.title) then
		local newbook = ItemStack("mcl_books:written_book")
		local book = player:get_wielded_item()
		local name = player:get_player_name()
		if book:get_name() == "mcl_books:writable_book" then
			if fields.title == "" then
				fields.title = "Nameless Book"
			end
			local meta = {
				title = fields.title,
				author = name,
				text = book:get_metadata()
			}
			newbook:set_metadata(minetest.serialize(meta))
			player:set_wielded_item(newbook)
		else
			minetest.log("error", "[mcl_books] "..name.." failed to sign a book!")
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.cancel) then
		local book = player:get_wielded_item()
		local name = player:get_player_name()
		if book:get_name() == "mcl_books:writable_book" then
			write(book, player)
		end
	end
end)

minetest.register_craft({
	type = "shapeless",
	output = "mcl_books:writable_book",
	recipe = { "mcl_books:book", "mcl_dye:black", "mcl_mobitems:feather" },
})

-- Written Book
minetest.register_craftitem("mcl_books:written_book", {
	description = "Written Book",
	inventory_image = "mcl_books_book_written.png",
	groups = { not_in_creative_inventory=1, book=1 },
	-- TODO: Increase to 16 when this mod is ready
	stack_max = 1,
	on_place = read,
	on_secondary_use = read
})

-- Copy books
minetest.register_craft({
	type = "shapeless",
	output = "mcl_books:written_book",
	recipe = {"mcl_books:writable_book", "mcl_books:written_book"}
})
-- TODO: Add copy recipes to copy 2-8 books at once

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "mcl_books:written_book" then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if old_craft_grid[i]:get_name() == "mcl_books:written_book" then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end
	local copymeta = original:get_metadata()
	-- copy of the book held by player's mouse cursor
	itemstack:set_metadata(copymeta)
	-- put the book with metadata back in the craft grid
	craft_inv:set_stack("craft", index, original)
end)

-- Bookshelf
minetest.register_node("mcl_books:bookshelf", {
	description = "Bookshelf",
	tiles = {"default_wood.png", "default_wood.png", "default_bookshelf.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=3,oddly_breakable_by_hand=2,flammable=3,building_block=1},
	drop = "mcl_books:book 3",
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'mcl_books:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'mcl_books:book', 'mcl_books:book', 'mcl_books:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:bookshelf",
	burntime = 15,
})

