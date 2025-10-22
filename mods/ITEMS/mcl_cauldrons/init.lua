local S = minetest.get_translator(minetest.get_current_modname())

-- Cauldron mod, adds cauldrons.

-- TODO: Extinguish fire of burning entities

-- Convenience function because the cauldron nodeboxes are very similar
local function create_cauldron_nodebox(water_level)
	local floor_y
	if water_level == 0 then	-- empty
		floor_y = -0.1875
	elseif water_level == 1 then	-- 1/3 filled
		floor_y = 1/16
	elseif water_level == 2 then	-- 2/3 filled
		floor_y = 4/16
	elseif water_level == 3 then	-- full
		floor_y = 7/16
	end
	return {
		type = "fixed",
		fixed = {
			{-0.5, -0.1875, -0.5, -0.375, 0.5, 0.5}, -- Left wall
			{0.375, -0.1875, -0.5, 0.5, 0.5, 0.5}, -- Right wall
			{-0.375, -0.1875, 0.375, 0.375, 0.5, 0.5}, -- Back wall
			{-0.375, -0.1875, -0.5, 0.375, 0.5, -0.375}, -- Front wall
			{-0.5, -0.3125, -0.5, 0.5, floor_y, 0.5}, -- Floor
			{-0.5, -0.5, -0.5, -0.375, -0.3125, -0.25}, -- Left front foot, part 1
			{-0.375, -0.5, -0.5, -0.25, -0.3125, -0.375}, -- Left front foot, part 2
			{-0.5, -0.5, 0.25, -0.375, -0.3125, 0.5}, -- Left back foot, part 1
			{-0.375, -0.5, 0.375, -0.25, -0.3125, 0.5}, -- Left back foot, part 2
			{0.375, -0.5, 0.25, 0.5, -0.3125, 0.5}, -- Right back foot, part 1
			{0.25, -0.5, 0.375, 0.375, -0.3125, 0.5}, -- Right back foot, part 2
			{0.375, -0.5, -0.5, 0.5, -0.3125, -0.25}, -- Right front foot, part 1
			{0.25, -0.5, -0.5, 0.375, -0.3125, -0.375}, -- Right front foot, part 2
		}
	}
end

-- Empty cauldron
minetest.register_node("mcl_cauldrons:cauldron", {
	description = S("Cauldron"),
	_tt_help = S("Stores water"),
	_doc_items_longdesc = S("Cauldrons are used to store water and slowly fill up under rain. They can also be used to wash off banners."),
	_doc_items_usagehelp = S("Place a water bucket into the cauldron to fill it with water. Place an empty bucket on a full cauldron to retrieve the water. Place a water bottle into the cauldron to fill the cauldron to one third with water. Place a glass bottle in a cauldron with water to retrieve one third of the water. Use an emblazoned banner on a cauldron with water to wash off its top layer."),
	wield_image = "mcl_cauldrons_cauldron.png",
	inventory_image = "mcl_cauldrons_cauldron.png",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {pickaxey=1, deco_block=1, cauldron=1},
	node_box = create_cauldron_nodebox(0),
	use_texture_alpha = "clip",
	selection_box = { type = "regular" },
	tiles = {
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_top.png",
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
		"mcl_cauldrons_cauldron_side.png"
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 2,
	_mcl_blast_resistance = 2,
})

-- Template function for cauldrons with water
local function register_filled_cauldron(water_level, description, liquid)
	local id = "mcl_cauldrons:cauldron_"..water_level
	local water_tex
	if liquid == "river_water" then
		id = id .. "r"
		water_tex = "mcl_core_water_source_animation.png^[verticalframe:16:0^[multiply:#0084FF"
	elseif liquid == "lava" then
		id = id .. "_lava"
		water_tex = "mcl_core_lava_source_animation.png^[verticalframe:16:0"
	else
		water_tex = "mcl_core_water_source_animation.png^[verticalframe:16:0^[multiply:#3F76E4"
	end
	minetest.register_node(id, {
		description = description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		groups = {pickaxey=1, not_in_creative_inventory=1, cauldron=(1+water_level), cauldron_filled=water_level, comparator_signal=water_level},
		node_box = create_cauldron_nodebox(water_level),
		use_texture_alpha = "clip",
		collision_box = create_cauldron_nodebox(0),
		selection_box = { type = "regular" },
		tiles = {
			"("..water_tex..")^mcl_cauldrons_cauldron_top.png",
			"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
			"mcl_cauldrons_cauldron_side.png"
		},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		drop = "mcl_cauldrons:cauldron",
		_mcl_hardness = 2,
		_mcl_blast_resistance = 2,
		on_rightclick = function(pos, node, player, itemstack)
			local outcome = mcl_armor.wash_leather_armor(itemstack)
			if outcome then
				minetest.sound_play("mcl_potions_bottle_pour",
					{pos=pos, gain=0.5, max_hear_range=16},true)
			end
			return outcome
		end,
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "mcl_cauldrons:cauldron", "nodes", id)
	end
end

-- Filled cauldrons (3 levels)
for i=1,3 do
	register_filled_cauldron(i, S("Cauldron (@1/3 Water)", i))
	register_filled_cauldron(i, S("Cauldron (@1/3 Lava)", i), "lava")
	if minetest.get_modpath("mclx_core") then
		register_filled_cauldron(i, S("Cauldron (@1/3 River Water)", i), "river_water")
	end
end

minetest.register_craft({
	output = "mcl_cauldrons:cauldron",
	recipe = {
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})

local function cauldron_extinguish(obj,pos)
	local node = minetest.get_node(pos)
	if mcl_burning.is_burning(obj) then
		mcl_burning.extinguish(obj)
		local new_group = minetest.get_item_group(node.name, "cauldron_filled") - 1
		minetest.swap_node(pos, {name = "mcl_cauldrons:cauldron" .. (new_group == 0 and "" or "_" .. new_group)})
	end
end

local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		local n = minetest.find_node_near(pl:get_pos(),0.4,{"group:cauldron_filled"},true)
		if n and not minetest.get_node(n).name:find("lava") then
			cauldron_extinguish(pl,n)
		elseif n and minetest.get_node(n).name:find("lava") then
				mcl_burning.set_on_fire(pl, 5)
		end
	end
	for _,ent in pairs(minetest.luaentities) do
		if ent.object:get_pos() and ent.is_mob then
			local n = minetest.find_node_near(ent.object:get_pos(),0.4,{"group:cauldron_filled"},true)
			if n and not minetest.get_node(n).name:find("lava") then
				cauldron_extinguish(ent.object,n)
			elseif n and minetest.get_node(n).name:find("lava") then
				mcl_burning.set_on_fire(ent.object, 5)
			end
		end
	end
end)
