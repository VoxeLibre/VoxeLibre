local S = minetest.get_translator("mcl_books")

local max_text_length = 4500 -- TODO: Increase to 12800 when scroll bar was added to written book
local max_title_length = 64

local header = ""
if minetest.get_modpath("mcl_init") then
	header = "no_prepend[]" .. mcl_vars.gui_nonbg .. mcl_vars.gui_bg_color ..
		"style_type[button;border=false;bgimg=mcl_books_button9.png;bgimg_pressed=mcl_books_button9_pressed.png;bgimg_middle=2,2]"
end

-- Book
minetest.register_craftitem("mcl_books:book", {
	description = S("Book"),
	_doc_items_longdesc = S("Books are used to make bookshelves and book and quills."),
	inventory_image = "default_book.png",
	stack_max = 64,
	groups = { book=1, craftitem = 1, enchantability = 1 },
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
})

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		type = 'shapeless',
		output = 'mcl_books:book',
		recipe = { 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:paper', 'mcl_mobitems:leather', }
	})
end

-- Get the included text out of the book item
-- itemstack: Book item
-- meta: Meta of book (optional)
local get_text = function(itemstack)
	-- Grab the text
	local meta = itemstack:get_meta()
	local text = meta:get_string("text")

	-- Backwards-compability with MCL2 0.21.0
	-- Remember that get_metadata is deprecated since MT 0.4.16!
	if text == nil or text == "" then
		local meta_legacy = itemstack:get_metadata()
		if itemstack:get_name() == "mcl_books:written_book" then
			local des = minetest.deserialize(meta_legacy)
			if des then
				text = des.text
			end
		else
			text = meta_legacy
		end
	end

	-- Security check
	if not text then
		text = ""
	end
	return text
end

local make_description = function(title, author, generation)
	local desc
	if generation == 0 then
		desc = S("“@1”", title)
	elseif generation == 1 then
		desc = S("Copy of “@1”", title)
	elseif generation == 2 then
		desc = S("Copy of Copy of “@1”", title)
	else
		desc = S("Tattered Book")
	end
	desc = desc .. "\n" .. minetest.colorize(mcl_colors.GRAY, S("by @1", author))
	return desc
end

local cap_text_length = function(text, max_length)
	return string.sub(text, 1, max_length)
end

local write = function(itemstack, user, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	local text = get_text(itemstack)
	local formspec = "size[8,9]"..
		header..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
		"textarea[0.75,0.1;7.25,9;text;;"..minetest.formspec_escape(text).."]"..
		"button[0.75,7.95;3,1;sign;"..minetest.formspec_escape(S("Sign")).."]"..
		"button_exit[4.25,7.95;3,1;ok;"..minetest.formspec_escape(S("Done")).."]"
	minetest.show_formspec(user:get_player_name(), "mcl_books:writable_book", formspec)
end

local read = function(itemstack, user, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	local text = get_text(itemstack)
	local formspec = "size[8,9]"..
		header..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
		"textarea[0.75,0.1;7.25,9;;"..minetest.formspec_escape(text)..";]"..
		"button_exit[2.25,7.95;3,1;ok;"..minetest.formspec_escape(S("Done")).."]"
	minetest.show_formspec(user:get_player_name(), "mcl_books:written_book", formspec)
end

-- Book and Quill
minetest.register_craftitem("mcl_books:writable_book", {
	description = S("Book and Quill"),
	_tt_help = S("Write down some notes"),
	_doc_items_longdesc = S("This item can be used to write down some notes."),
	_doc_items_usagehelp = S("Hold it in the hand, then rightclick to read the current notes and edit then. You can edit the text as often as you like. You can also sign the book which turns it into a written book which you can stack, but it can't be edited anymore.").."\n"..
	S("A book can hold up to 4500 characters. The title length is limited to 64 characters."),
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
			local meta = stack:get_meta()
			local text = cap_text_length(fields.text, max_text_length)
			if fields.ok then
				meta:set_string("text", text)
				player:set_wielded_item(stack)
			elseif fields.sign then
				meta:set_string("text", text)
				player:set_wielded_item(stack)

				local name = player:get_player_name()
				local formspec = "size[8,9]"..
					header..
					"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
					"field[0.75,1;7.25,1;title;"..minetest.formspec_escape(minetest.colorize(mcl_colors.BLACK, S("Enter book title:")))..";]"..
					"label[0.75,1.5;"..minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, S("by @1", name))).."]"..
					"button_exit[0.75,7.95;3,1;sign;"..minetest.formspec_escape(S("Sign and Close")).."]"..
					"tooltip[sign;"..minetest.formspec_escape(S("Note: The book will no longer be editable after signing")).."]"..
					"button[4.25,7.95;3,1;cancel;"..minetest.formspec_escape(S("Cancel")).."]"
				minetest.show_formspec(player:get_player_name(), "mcl_books:signing", formspec)
			end
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.sign and fields.title) then
		local newbook = ItemStack("mcl_books:written_book")
		local book = player:get_wielded_item()
		local name = player:get_player_name()
		if book:get_name() == "mcl_books:writable_book" then
			local title = fields.title
			if string.len(title) == 0 then
				title = S("Nameless Book")
			end
			title = cap_text_length(title, max_title_length)
			local meta = newbook:get_meta()
			local text = cap_text_length(get_text(book), max_text_length)
			meta:set_string("title", title)
			meta:set_string("author", name)
			meta:set_string("text", text)
			meta:set_string("description", make_description(title, name, 0))

			-- The book copy counter. 0 = original, 1 = copy of original, 2 = copy of copy of original, …
			meta:set_int("generation", 0)

			player:set_wielded_item(newbook)
		else
			minetest.log("error", "[mcl_books] "..name.." failed to sign a book!")
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.cancel) then
		local book = player:get_wielded_item()
		if book:get_name() == "mcl_books:writable_book" then
			write(book, player, { type = "nothing" })
		end
	end
end)

if minetest.get_modpath("mcl_dye") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_books:writable_book",
		recipe = { "mcl_books:book", "mcl_dye:black", "mcl_mobitems:feather" },
	})
end

-- Written Book
minetest.register_craftitem("mcl_books:written_book", {
	description = S("Written Book"),
	_doc_items_longdesc = S("Written books contain some text written by someone. They can be read and copied, but not edited."),
	_doc_items_usagehelp = S("Hold it in your hand, then rightclick to read the book.").."\n\n"..

S("To copy the text of the written book, place it into the crafting grid together with a book and quill (or multiple of those) and craft. The written book will not be consumed. Copies of copies can not be copied."),
	inventory_image = "mcl_books_book_written.png",
	groups = { not_in_creative_inventory=1, book=1, no_rename=1 },
	stack_max = 16,
	on_place = read,
	on_secondary_use = read
})

-- Copy books

-- This adds 8 recipes
local baq = "mcl_books:writable_book"
local wb = "mcl_books:written_book"
local recipes = {
	{wb, baq},
	{baq, baq, wb},
	{baq, baq, wb, baq},
	{baq, baq, baq, baq, wb},
	{baq, baq, baq, baq, wb, baq},
	{baq, baq, baq, baq, wb, baq, baq},
	{baq, baq, baq, baq, wb, baq, baq, baq},
	{baq, baq, baq, baq, wb, baq, baq, baq, baq},
}
for r=#recipes, 1, -1 do
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_books:written_book "..r,
		recipe = recipes[r],
	})
end

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
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

	local ometa = original:get_meta()
	local generation = ometa:get_int("generation")

	-- Check generation, don't allow crafting with copy of copy of book
	if generation >= 2 then
		return ItemStack("")
	else
		-- Valid copy. Let's update the description field of the result item
		-- so it is properly displayed in the crafting grid.
		local imeta = itemstack:get_meta()
		local title = cap_text_length(ometa:get_string("title"), max_title_length)
		local author = ometa:get_string("author")

		-- Increase book generation and update description
		generation = generation + 1
		if generation < 1 then
			generation = 1
		end

		local desc = make_description(title, author, generation)
		imeta:set_string("description", desc)
		return itemstack
	end
end)

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

	-- copy of the book
	local text = get_text(original)
	if not text or text == "" then
		local copymeta = original:get_metadata()
		itemstack:set_metadata(copymeta)
	else
		local ometa = original:get_meta()
		local generation = ometa:get_int("generation")

		-- No copy of copy of copy of book allowed
		if generation >= 2 then
			return ItemStack("")
		end

		-- Copy metadata
		local imeta = itemstack:get_meta()
		local title = cap_text_length(ometa:get_string("title"), max_title_length)
		local author = ometa:get_string("author")
		imeta:set_string("title", title)
		imeta:set_string("author", author)
		imeta:set_string("text", cap_text_length(text, max_text_length))

		-- Increase book generation and update description
		generation = generation + 1
		if generation < 1 then
			generation = 1
		end

		local desc = make_description(title, author, generation)

		imeta:set_string("description", desc)
		imeta:set_int("generation", generation)
	end
	-- put the book with metadata back in the craft grid
	craft_inv:set_stack("craft", index, original)
end)

local wood_sound
if minetest.get_modpath("mcl_sounds") then
	wood_sound = mcl_sounds.node_sound_wood_defaults()
end

-- Bookshelf
minetest.register_node("mcl_books:bookshelf", {
	description = S("Bookshelf"),
	_doc_items_longdesc = S("Bookshelves are used for decoration."),
	tiles = {"mcl_books_bookshelf_top.png", "mcl_books_bookshelf_top.png", "default_bookshelf.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy=1,axey=1, flammable=3,building_block=1, material_wood=1, fire_encouragement=30, fire_flammability=20},
	drop = "mcl_books:book 3",
	sounds = wood_sound,
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
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
	recipe = "mcl_books:bookshelf",
	burntime = 15,
})

