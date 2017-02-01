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
	recipe = { 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:paper', 'mcl_mobitems:leather',
	}
})

-- Book and Quill
minetest.register_craftitem("mcl_books:writable_book", {
	description = "Book and Quill",
	inventory_image = "mcl_books_book_writable.png",
	groups = { book=1 },
	stack_max = 1,
	on_use = function (itemstack, user, pointed_thing)
		local text = itemstack:get_metadata()
		local formspec = "size[8,9]"..
			"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"..
			"textarea[0.5,0.25;7.5,9.25;text;;"..minetest.formspec_escape(text).."]"..
        		"button_exit[3,8.25;2,1;ok;Exit]"
			minetest.show_formspec(user:get_player_name(), "mcl_core:book", formspec)
	end,
})

minetest.register_on_player_receive_fields(function ( player, formname, fields )
	if ((formname == "mcl_books:writable_book") and fields and fields.text) then
		local stack = player:get_wielded_item()
		if (stack:get_name() and (stack:get_name() == "mcl_books:writable_book")) then
			local t = stack:to_table()
			t.metadata = fields.text
			player:set_wielded_item(ItemStack(t))
		end
	end
end)

minetest.register_craft({
	type = "shapeless",
	output = "mcl_books:writable_book",
	recipe = { "mcl_books:books", "mcl_dyes:black", "mcl_mobitems:feather" },
})

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

