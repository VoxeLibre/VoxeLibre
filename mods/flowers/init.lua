-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

flower_tmp={}


-- Map Generation
dofile(minetest.get_modpath("flowers").."/mapgen.lua")
dofile(minetest.get_modpath("flowers").."/func.lua")



-------------------------------
--- Fleur Simple (une case) ---
-------------------------------


local function add_simple_flower(name, desc, image, color)
	minetest.register_node("flowers:"..name.."", {
		description = desc,
		drawtype = "plantlike",
		tiles = { image..".png" },
		inventory_image = image..".png",
		wield_image = image..".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 64,
		groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,dig_by_water=1,color=1},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
		},
	})
end

add_simple_flower("rose", "Coqlicot", "flowers_coqlicot", "color_red")
--add_simple_flower("rose", "Rose", "flowers_rose", "color_red") -- Old skin :( you miss me
add_simple_flower("dandelion_yellow", "Yellow Dandelion", "flowers_dandelion_yellow", "color_yellow")
add_simple_flower("oxeye_daisy", "Oxeye Daisy", "flower_oxeye_daisy", "color_yellow")
add_simple_flower("tulip_orange", "Orange Tulip", "flower_tulip_orange", "color_orange")

minetest.register_node("flowers:tulip_pink", {
	description = "Pink Tulip",
	drawtype = "plantlike",
	tiles = { "flower_tulip_pink.png" },
	inventory_image = "flower_tulip_pink.png",
	wield_image = "flower_tulip_pink.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_pink=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

minetest.register_node("flowers:tulip_red", {
	description = "Red Tulip",
	drawtype = "plantlike",
	tiles = { "flower_tulip_red.png" },
	inventory_image = "flower_tulip_red.png",
	wield_image = "flower_tulip_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_red=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


minetest.register_node("flowers:tulip_white", {
	description = "White Tulip",
	drawtype = "plantlike",
	tiles = { "flower_tulip_white.png" },
	inventory_image = "flower_tulip_white.png",
	wield_image = "flower_tulip_white.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_white=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


--- allium ---

minetest.register_node("flowers:allium", {
	description = "Allium",
	drawtype = "plantlike",
	tiles = { "flower_allium.png" },
	inventory_image = "flower_allium.png",
	wield_image = "flower_allium.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_pink=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

--- paeonia ---

minetest.register_node("flowers:paeonia", {
	description = "Paeonia",
	drawtype = "plantlike",
	tiles = { "flower_paeonia.png" },
	inventory_image = "flower_paeonia.png",
	wield_image = "flower_paeonia.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_pink=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})


--- houstonia ---

minetest.register_node("flowers:houstonia", {
	description = "Houstonia",
	drawtype = "plantlike",
	tiles = { "flower_houstonia.png" },
	inventory_image = "flower_houstonia.png",
	wield_image = "flower_houstonia.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_white=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

---blue_orchid ---

minetest.register_node("flowers:blue_orchid", {
	description = "Blue Orchid",
	drawtype = "plantlike",
	tiles = { "flower_blue_orchid.png" },
	inventory_image = "flower_blue_orchid.png",
	wield_image = "flower_blue_orchid.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_blue=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

--- Fern ---

minetest.register_node("flowers:fern", {
	description = "Fern",
	drawtype = "plantlike",
	tiles = { "fern.png" },
	inventory_image = "fern.png",
	wield_image = "fern.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {snappy=3,flammable=2,flower=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

function register_large(name, desc, inv_img, bot_img, colr) --change in function
    minetest.register_node("flowers:"..name.."_bottom", {
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
                while minetest.get_node(pointed_thing.under).name == "flowers:"..name.."_bottom" and height < 2 do
                    height = height+1
                    pointed_thing.under = pointed_thing.under+1
                end
                if height <2 then
                    if minetest.get_node(pointed_thing.under).name == "air" then
                        minetest.set_node(pointed_thing.under, {name="flowers:"..name.."_top"})
                    end
                end
            end
        end,
        ]]
        drop = "flowers:"..name,
        groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,colr=1, dig_by_water=1, double_bottom =1},
        sounds = default.node_sound_leaves_defaults(),
        selection_box = {
            type = "fixed",
            fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
        },
    })

    -- Top
    minetest.register_node("flowers:"..name.."_top", {
        description = desc.." Top",
        drawtype = "plantlike",
        tiles = { "double_plant_"..name.."_top.png" },
        inventory_image = "double_plant_"..inv_img.."_top.png",
        wield_image = "double_plant_"..inv_img.."_top.png",
        sunlight_propagates = true,
        paramtype = "light",
        walkable = false,
        buildable_to = true,
        drop = "flowers:"..name,
        groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,colr=1, dig_by_water=1, not_in_creative_inventory = 1, double_top =1},
        sounds = default.node_sound_leaves_defaults(),
        selection_box = {
            type = "fixed",
            fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
        },
    })
end



-----------------------------
---   Generation terrin  ----
-----------------------------

minetest.register_abm({
	nodenames = {"group:flora"},
	neighbors = {"default:dirt_with_grass", "default:sand"},
	interval = 40,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y - 1
		local under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if under.name == "default:sand" then
			minetest.set_node(pos, {name="default:dry_shrub"})
		elseif under.name ~= "default:sand" then
			return
		end
		
		local light = minetest.get_node_light(pos)
		if not light or light < 10 then
			return
		end
		
		local pos0 = {x=pos.x-4,y=pos.y-4,z=pos.z-4}
		local pos1 = {x=pos.x+4,y=pos.y+4,z=pos.z+4}
		
		local flowers = minetest.find_nodes_in_area(pos0, pos1, "group:flora")
		if #flowers > 3 then
			return
		end
		
		local seedling = minetest.find_nodes_in_area(pos0, pos1, "default:dirt_with_grass")
		if #seedling > 0 then
			seedling = seedling[math.random(#seedling)]
			seedling.y = seedling.y + 1
			light = minetest.get_node_light(seedling)
			if not light or light < 13 then
				return
			end
			if minetest.get_node(seedling).name == "air" then
				minetest.set_node(seedling, {name=node.name})
			end
		end
	end,
})

--
-- Flower Pot
--

minetest.register_node("flowers:pot",{
	description = "Flower Pot",
	drawtype = "nodebox",
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
	groups = {snappy=3},
	stack_max = 16,
	sounds = default.node_sound_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.env:get_meta(pos)
		if clicker:get_player_name() == meta:get_string("owner") then
			flower_pot_drop_item(pos,node)
			local s = itemstack:take_item()
			meta:set_string("item",s:to_string())
			flower_pot_update_item(pos,node)
		end
		return itemstack
	end,
	on_punch = function(pos,node,puncher)
		local meta = minetest.env:get_meta(pos)
		if puncher:get_player_name() == meta:get_string("owner") then
			flower_pot_drop_item(pos,node)
		end
	end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos)
		return player:get_player_name() == meta:get_string("owner")
	end,
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		flower_pot_drop_item(pos,node)
		minetest.env:add_node(pos, {name="air"})
		minetest.env:add_item(pos, "flowers:pot")
	end,
})


