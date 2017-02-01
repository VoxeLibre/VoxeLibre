-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
local init = os.clock()
flower_tmp={}


-- Map Generation
dofile(minetest.get_modpath("mcl_flowers").."/mapgen.lua")
dofile(minetest.get_modpath("mcl_flowers").."/func.lua")



-------------------------------
--- Fleur Simple (une case) ---
-------------------------------


local function add_simple_flower(name, desc, image, color)
	minetest.register_node("mcl_flowers:"..name, {
		description = desc,
		drawtype = "plantlike",
		tiles = { image..".png" },
		inventory_image = image..".png",
		wield_image = image..".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 64,
		groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,dig_by_water=1,color=1,deco_block=1},
		sounds = mcl_core.node_sound_leaves_defaults(),
		buildable_to = true,
		selection_box = {
			type = "fixed",
			fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
		},
	})
end

add_simple_flower("poppy", "Poppy", "mcl_flowers_poppy", "color_red")
add_simple_flower("dandelion", "Dandelion", "flowers_dandelion_yellow", "color_yellow")
add_simple_flower("oxeye_daisy", "Oxeye Daisy", "mcl_flowers_oxeye_daisy", "color_yellow")
add_simple_flower("tulip_orange", "Orange Tulip", "flowers_tulip", "color_orange")

minetest.register_node("mcl_flowers:tulip_pink", {
	description = "Pink Tulip",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_tulip_pink.png" },
	inventory_image = "mcl_flowers_tulip_pink.png",
	wield_image = "mcl_flowers_tulip_pink.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_pink=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

minetest.register_node("mcl_flowers:tulip_red", {
	description = "Red Tulip",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_tulip_red.png" },
	inventory_image = "mcl_flowers_tulip_red.png",
	wield_image = "mcl_flowers_tulip_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_red=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


minetest.register_node("mcl_flowers:tulip_white", {
	description = "White Tulip",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_tulip_white.png" },
	inventory_image = "mcl_flowers_tulip_white.png",
	wield_image = "mcl_flowers_tulip_white.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_white=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


--- allium ---

minetest.register_node("mcl_flowers:allium", {
	description = "Allium",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_allium.png" },
	inventory_image = "mcl_flowers_allium.png",
	wield_image = "mcl_flowers_allium.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_pink=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

--- peony ---

minetest.register_node("mcl_flowers:peony", {
	description = "Peony",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_peony.png" },
	inventory_image = "mcl_flowers_peony.png",
	wield_image = "mcl_flowers_peony.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_pink=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


--- azure bluet ---

minetest.register_node("mcl_flowers:azure_bluet", {
	description = "Azure Bluet",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_azure_bluet.png" },
	inventory_image = "mcl_flowers_azure_bluet.png",
	wield_image = "mcl_flowers_azure_bluet.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_white=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

---blue_orchid ---

minetest.register_node("mcl_flowers:blue_orchid", {
	description = "Blue Orchid",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_blue_orchid.png" },
	inventory_image = "mcl_flowers_blue_orchid.png",
	wield_image = "mcl_flowers_blue_orchid.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,color_blue=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

--- Fern ---

minetest.register_node("mcl_flowers:fern", {
	description = "Fern",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_fern.png" },
	inventory_image = "mcl_flowers_fern.png",
	wield_image = "mcl_flowers_fern.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_farming:wheat_seed'},
				rarity = 8,
			},
		}
	},
})

function register_large(name, desc, inv_img, bot_img, colr) --change in function
    minetest.register_node("mcl_flowers:"..name.."_bottom", {
        description = desc.." Bottom",
        drawtype = "plantlike",
        tiles = { "double_plant_"..name.."_bottom.png" },
        inventory_image = "flowers_"..inv_img..".png",
        wield_image = "flowers_"..inv_img..".png",
        sunlight_propagates = true,
        paramtype = "light",
        walkable = false,
        buildable_to = true,
        --[[
        on_place = function(itemstack, placer, pointed_thing)
            pointed_thing.under = pointed_thing.under-1
            local name = minetest.get_node({x=pointed_thing.under, y=pointed_thing.under-1, z=pointed_thing.under}).name
            if minetest.get_item_group(name, "soil") ~= 0 then
                pointed_thing.under = pointed_thing.under+1
                local height = 0
                while minetest.get_node(pointed_thing.under).name == "mcl_flowers:"..name.."_bottom" and height < 2 do
                    height = height+1
                    pointed_thing.under = pointed_thing.under+1
                end
                if height <2 then
                    if minetest.get_node(pointed_thing.under).name == "air" then
                        minetest.set_node(pointed_thing.under, {name="mcl_flowers:"..name.."_top"})
                    end
                end
            end
        end,
        ]]
        drop = "mcl_flowers:"..name,
        groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,colr=1, dig_by_water=1, double_bottom =1,deco_block=1,deco_block=1},
        sounds = mcl_core.node_sound_leaves_defaults(),
        selection_box = {
            type = "fixed",
            fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
        },
    })

    -- Top
    minetest.register_node("mcl_flowers:"..name.."_top", {
        description = desc.." Top",
        drawtype = "plantlike",
        tiles = { "double_plant_"..name.."_top.png" },
        inventory_image = "double_plant_"..inv_img.."_top.png",
        wield_image = "double_plant_"..inv_img.."_top.png",
        sunlight_propagates = true,
        paramtype = "light",
        walkable = false,
        buildable_to = true,
        drop = "mcl_flowers:"..name,
        groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,colr=1, dig_by_water=1, not_in_creative_inventory = 1, double_top =1},
        sounds = mcl_core.node_sound_leaves_defaults(),
        selection_box = {
            type = "fixed",
            fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
        },
    })
end


--
-- Flower Pot
--

minetest.register_node("mcl_flowers:pot",{
	description = "Flower Pot",
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = { type = "fixed", fixed = {
		{-0.125,-0.125,-0.187500,-0.187500,-0.500,0.1875}, --Wall 1
		{0.1875,-0.125,-0.125,0.125,-0.500,0.1875}, --Wall 2
		{-0.1875,-0.125,-0.125,0.1875,-0.500,-0.1875}, --Wall 3
		{0.1875,-0.125,0.125,-0.1875,-0.500,0.1875}, --Wall 4
		{-0.125,-0.500,-0.125,0.125,-0.250,0.125}, --Dirt 5
	}},
	selection_box = { type = "fixed", fixed = {-0.125,-0.5,-0.125,0.125,-0.25,0.125 }},
	tiles = {"flowers_pot_top.png", "flowers_pot_bottom.png", "flowers_pot_top.png"},
	inventory_image="flowers_pot_inventory.png",
	paramtype = "light",
	groups = {dig_immediate=3,deco_block=1},
	stack_max = 64,
	sounds = mcl_core.node_sound_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.get_meta(pos)
		if clicker:get_player_name() == meta:get_string("owner") then
			flower_pot_drop_item(pos,node)
			local s = itemstack:take_item()
			meta:set_string("item",s:to_string())
			flower_pot_update_item(pos,node)
		end
		return itemstack
	end,
	on_punch = function(pos,node,puncher)
		local meta = minetest.get_meta(pos)
		if puncher:get_player_name() == meta:get_string("owner") then
			flower_pot_drop_item(pos,node)
		end
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		return player:get_player_name() == meta:get_string("owner")
	end,
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		flower_pot_drop_item(pos,node)
		minetest.add_node(pos, {name="air"})
		minetest.add_item(pos, "mcl_flowers:pot")
	end,
})

minetest.register_craft({
	output = "mcl_flowers:pot",
	recipe = {
		{ "mcl_core:brick", "", "mcl_core:brick", },
		{ "", "mcl_core:brick", "" },
	},
})

-- Lily Pad
minetest.register_node("mcl_flowers:waterlily", {
	description = "Lily Pad",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png", "flowers_waterlily.png^[transformFY"},
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	liquids_pointable = true,
	walkable = true,
	sunlight_propagates = true,
	groups = {dig_immediate = 3, dig_by_water = 1, deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -15 / 32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under).name
		local def = minetest.registered_nodes[node]
		local node_above = minetest.get_node(pointed_thing.above).name
		local def_above = minetest.registered_nodes[node_above]
		local player_name = placer:get_player_name()

		if def and
				pointed_thing.under.x == pointed_thing.above.x and
				pointed_thing.under.z == pointed_thing.above.z then
			if ((def.liquidtype == "source" and minetest.get_item_group(node, "water") > 0) or
					(node == "mcl_core:ice") or
					(minetest.get_item_group(node, "frosted_ice") > 0)) and
					(def_above.buildable_to and minetest.get_item_group(node_above, "liquid") == 0) then
				if not minetest.is_protected(pos, player_name) then
					minetest.set_node(pos, {name = "mcl_flowers:waterlily",
						param2 = math.random(0, 3)})
					if not minetest.setting_getbool("creative_mode") then
						itemstack:take_item()
					end
				else
					minetest.chat_send_player(player_name, "Node is protected")
					minetest.record_protection_violation(pos, player_name)
				end
			end
		end

		return itemstack
	end
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
