minetest.register_craftitem("mcl_enchanting:book_enchanted", {
	description = "Enchanted Book",
	inventory_image = "mcl_enchanting_book_enchanted.png^[colorize:purple:50",
	groups = {enchanted = 1, not_in_creative_inventory = 1},
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
	stack_max = 1,
}) 

minetest.registered_items["mcl_books:book"]._mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted"
