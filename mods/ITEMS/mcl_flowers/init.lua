-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
local init = os.clock()
flower_tmp={}

-- Simple flower template
local smallflowerlongdesc = "This is a small flower. Small flowers are mainly used for dye production and can also be potted."

local function add_simple_flower(name, desc, image, simple_selection_box)
	minetest.register_node("mcl_flowers:"..name, {
		description = desc,
		_doc_items_longdesc = smallflowerlongdesc,
		drawtype = "plantlike",
		tiles = { image..".png" },
		inventory_image = image..".png",
		wield_image = image..".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 64,
		groups = {dig_immediate=3,flammable=2,flower=1,attached_node=1,dig_by_water=1,deco_block=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		buildable_to = true,
		selection_box = {
			type = "fixed",
			fixed = simple_selection_box,
		},
	})
end

local box_tulip = { -0.15, -0.5, -0.15, 0.15, 5/16, 0.15 }

add_simple_flower("poppy", "Poppy", "mcl_flowers_poppy", { -0.15, -0.5, -0.15, 0.15, 3/16, 0.15 })
add_simple_flower("dandelion", "Dandelion", "flowers_dandelion_yellow", { -0.15, -0.5, -0.15, 0.15, 0, 0.15 })
add_simple_flower("oxeye_daisy", "Oxeye Daisy", "mcl_flowers_oxeye_daisy", { -0.15, -0.5, -0.15, 0.15, 5/16, 0.15 })
add_simple_flower("tulip_orange", "Orange Tulip", "flowers_tulip", box_tulip)
add_simple_flower("tulip_pink", "Pink Tulip", "mcl_flowers_tulip_pink", box_tulip)
add_simple_flower("tulip_red", "Red Tulip", "mcl_flowers_tulip_red", box_tulip)
add_simple_flower("tulip_white", "White Tulip", "mcl_flowers_tulip_white", box_tulip)
add_simple_flower("allium", "Allium", "mcl_flowers_allium", { -0.2, -0.5, -0.2, 0.2, 6/16, 0.2 })
add_simple_flower("peony", "Peony", "mcl_flowers_peony", { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 })
add_simple_flower("azure_bluet", "Azure Bluet", "mcl_flowers_azure_bluet", { -3/16, -0.5, -3/16, 3/16, 2/16, 3/16 })
add_simple_flower("blue_orchid", "Blue Orchid", "mcl_flowers_blue_orchid", { -5/16, -0.5, -5/16, 5/16, 6/16, 5/16 })

--- Fern ---
minetest.register_node("mcl_flowers:fern", {
	description = "Fern",
	_doc_items_longdesc = "Ferns are small plants which occour naturally in grasslands. They can be harvested for wheat seeds.",
	drawtype = "plantlike",
	tiles = { "mcl_flowers_fern.png" },
	inventory_image = "mcl_flowers_fern.png",
	wield_image = "mcl_flowers_fern.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,attached_node=1,dig_by_water=1,deco_block=1},
	buildable_to = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 7/16, 4/16 },
	},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_farming:wheat_seeds'},
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
        sounds = mcl_sounds.node_sound_leaves_defaults(),
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
        sounds = mcl_sounds.node_sound_leaves_defaults(),
        selection_box = {
            type = "fixed",
            fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
        },
    })
end


-- Lily Pad
minetest.register_node("mcl_flowers:waterlily", {
	description = "Lily Pad",
	_doc_items_longdesc = "A lily pad is a flat plant block which can be walked on. They can be placed on water sources, ice and frosted ice.",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31/64, -0.5, 0.5, -15/32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local nodename = node.name
		local def = minetest.registered_nodes[nodename]
		local node_above = minetest.get_node(pointed_thing.above).name
		local def_above = minetest.registered_nodes[node_above]
		local player_name = placer:get_player_name()

		if def then
			-- Use pointed node's on_rightclick function first, if present
			if placer and not placer:get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			if (pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z) and
					((def.liquidtype == "source" and minetest.get_item_group(nodename, "water") > 0) or
					(nodename == "mcl_core:ice") or
					(minetest.get_item_group(nodename, "frosted_ice") > 0)) and
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
