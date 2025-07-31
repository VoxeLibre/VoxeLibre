-- Building blocks and decorative nodes
local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

minetest.register_node("mcl_end:end_stone", {
	description = S("End Stone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_stone.png"},
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = mcl_end.check_detach_chorus_plant,
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_end:end_bricks", {
	description = S("End Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_bricks.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_end:purpur_block", {
	description = S("Purpur Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1, purpur_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_end:purpur_pillar", {
	description = S("Purpur Pillar"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, purpur_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

local end_rod_name = "mcl_end:end_rod"
local end_rod_def = {
	description = S("End Rod"),
	_doc_items_longdesc = S("End rods are decorative light sources."),
	tiles = {
		"mcl_end_end_rod.png",
	},
	drawtype = "mesh",
	mesh = "mcl_end_rod.obj",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = minetest.LIGHT_MAX,
	sunlight_propagates = true,
	groups = { dig_immediate=3, deco_block=1, destroy_by_lava_flow=1, end_rod=1 },
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,

	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 0,
}
minetest.register_node(end_rod_name, end_rod_def)

-- register colored end_rods
local colored_end_rods = {
	{"white",      S("White End Rod"),      	"white"},
	{"grey",       S("Grey End Rod"),       	"dark_grey"},
	{"silver",     S("Light Grey End Rod"),		"grey"},
	{"black",      S("Black End Rod"),      	"black"},
	{"red",        S("Red End Rod"),        	"red"},
	{"yellow",     S("Yellow End Rod"),     	"yellow"},
	{"green",      S("Green End Rod"),      	"dark_green"},
	{"cyan",       S("Cyan End Rod"),       	"cyan"},
	{"blue",       S("Blue End Rod"),       	"blue"},
	{"magenta",    S("Magenta End Rod"),    	"magenta"},
	{"orange",     S("Orange End Rod"),     	"orange"},
	{"purple",     S("Purple End Rod"),     	"violet"},
	{"brown",      S("Brown End Rod"),      	"brown"},
	{"pink",       S("Pink End Rod"),       	"pink"},
	{"lime",       S("Lime End Rod"),       	"green"},
	{"lightblue",  S("Light Blue End Rod"), 	"lightblue"},
}
local end_rod_mask = "^[mask:mcl_end_end_rod_mask.png"
for num, row in ipairs(colored_end_rods) do
	local name = row[1]
	local desc = row[2]
	local dye = row[3]
	local def = table.copy(end_rod_def)
	def.description = desc
	def._doc_items_longdesc = nil
	def._doc_items_create_entry = false
	def.use_texture_alpha = "clip"
	local side_tex
	if name == "pink" then
		def.tiles[1] = def.tiles[1] .. "^(" .. def.tiles[1] .. end_rod_mask .. "^[multiply:" .. name .. "^[hsl:0:300)"
	elseif num > 4 then
		def.tiles[1] = def.tiles[1] .. "^(" .. def.tiles[1] .. end_rod_mask .. "^[multiply:" .. name .. "^[hsl:0:300^[opacity:120)"
	else
		def.tiles[1] = def.tiles[1] .. "^(" .. def.tiles[1] .. end_rod_mask .. "^[multiply:" .. name .. "^[hsl:0:-100^[opacity:170)"
	end
	minetest.register_node(end_rod_name.."_"..name, def)
	minetest.register_craft({
		type = "shapeless",
		output = end_rod_name.."_"..name,
		recipe = {"group:end_rod", "mcl_dye:"..dye}
	})
end


minetest.register_node("mcl_end:dragon_egg", {
	description = S("Dragon Egg"),
	_doc_items_longdesc = S("A dragon egg is a decorative item which can be placed."),
	tiles = {
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.5, -0.4375, -0.5, 0.5, -0.1875, 0.5},
			{-0.4375, -0.1875, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, 0, -0.375, 0.375, 0.125, 0.375},
			{-0.3125, 0.125, -0.3125, 0.3125, 0.25, 0.3125},
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25},
			{-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},
			{-0.0625, 0.4375, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "regular",
	},
	groups = {handy = 1, falling_node = 1, deco_block = 1, not_in_creative_inventory = 1, dig_by_piston = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
	on_punch = function(pos, node, puncher)
		if not minetest.is_protected(pos, puncher:get_player_name()) then
			local max_dist = vector.new(15, 7, 15)
			local positions = minetest.find_nodes_in_area(vector.subtract(pos, max_dist), vector.add(pos, max_dist), "air", false)
			if #positions > 0 then
				local tpos = positions[math.random(#positions)]
				minetest.remove_node(pos)
				minetest.set_node(tpos, node)
				minetest.check_for_falling(tpos)
			end
		end
	end,
})



-- Crafting recipes
minetest.register_craft({
	output = "mcl_end:end_bricks 4",
	recipe = {
		{"mcl_end:end_stone", "mcl_end:end_stone"},
		{"mcl_end:end_stone", "mcl_end:end_stone"},
	}
})

minetest.register_craft({
	output = "mcl_end:purpur_block 4",
	recipe = {
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
	}
})

minetest.register_craft({
	output = "mcl_end:end_rod 4",
	recipe = {
		{"mcl_mobitems:flaming_rod"},
		{"mcl_end:chorus_fruit_popped"},
	},
})

mcl_stonecutter.register_recipe("mcl_end:end_stone", "mcl_end:end_bricks")
mcl_stonecutter.register_recipe("mcl_end:purpur_block", "mcl_end:purpur_pillar")
