local S = minetest.get_translator("mcl_mushroom")

-- Warped fungus
-- Crimson fungus
--Functions and Biomes

-- WARNING: The most comments are in german. Please Translate with an translater if you don't speak good german

minetest.register_node("mcl_mushroom:warped_fungus", {
  description = S("Warped Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_warped_fungus.png" },
	inventory_image = "farming_warped_fungus.png",
	wield_image = "farming_warped_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1},

	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, player, itemstack)
    if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
      local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
      if nodepos.name == "mcl_mushroom:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
        local random = math.random(1, 5)
        if random == 1 then
          generate_warped_tree(pos)
        end
      end
    end
  end,
	_mcl_blast_resistance = 0,

  stack_max = 64,
})

minetest.register_node("mcl_mushroom:warped_wart_block", {
  description = S("Warped Wart Block"),
  tiles = {"warped_wart_block.png"},
  groups = {handy=1,hoe=7,swordy=1, deco_block=1, },
  stack_max = 64,
  _mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:shroomlight", {
  description = S("Shroomlight"),
  tiles = {"shroomlight.png"},
  groups = {handy=1,hoe=7,swordy=1, leafdecay=leafdecay_distance, leaves=1, deco_block=1, },
  stack_max = 64,
  _mcl_hardness = 2,
  light_source = 15
})

minetest.register_node("mcl_mushroom:warped_hyphae", {
  description = S("Warped Hyphae"),
  tiles = {"warped_hyphae.png",
           "warped_hyphae.png",
           "warped_hyphae_side.png",
           "warped_hyphae_side.png",
           "warped_hyphae_side.png",
           "warped_hyphae_side.png",
         },
  groups = {handy=5,axey=1, bark=1, building_block=1, material_wood=1,},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:warped_nylium", {
  description = S("Warped Nylium"),
  tiles = {"warped_wart_block.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png^warped_nylium_side.png",
           "mcl_nether_netherrack.png^warped_nylium_side.png",
           "mcl_nether_netherrack.png^warped_nylium_side.png",
           "mcl_nether_netherrack.png^warped_nylium_side.png",
         },
  groups = {pickaxey=1, building_block=1, material_stone=1},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 0.4,
  _mcl_blast_resistance = 0.4,
  is_ground_content = true,
  drop = "mcl_nether:netherrack",
  _mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mushroom:warped_checknode", {
  description = S("Warped Checknode - only to check!"),
  tiles = {"mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
         },
  groups = {pickaxey=1, building_block=1, material_stone=1, not_in_creative_inventory=1},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 0.4,
  _mcl_blast_resistance = 0.4,
  is_ground_content = true,
  drop = "mcl_nether:netherrack"
})

minetest.register_node("mcl_mushroom:warped_hyphae_wood", {
  description = S("Warped Hyphae Wood"),
  tiles = {"warped_hyphae_wood.png"},
  groups = {handy=5,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 2,
})

mcl_stairs.register_stair_and_slab_simple("Warped Wood", "mcl_mushroom:warped_hyphae_wood", "Warped Wood Stairs", "Warped Wood Slab", "Double Warped Wood Slab")

minetest.register_craft({
  output = "mcl_mushroom:warped_hyphae_wood 4",
  recipe = {
    {"mcl_mushroom:warped_hyphae"},
  }
})

minetest.register_craft({
  output = "mcl_mushroom:warped_nyliumd 2",
  recipe = {
    {"mcl_mushroom:warped_wart_block"},
    {"mcl_nether:netherrack"},
  }
})

minetest.register_abm({
	label = "mcl_mushroom:warped_fungus",
	nodenames = {"mcl_mushroom:warped_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    if nodepos.name == "mcl_mushroom:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
      if pos.y < -28400 then
        generate_warped_tree(pos)
      end
    end
  end
})

minetest.register_abm({
	label = "mcl_mushroom:warped_checknode",
	nodenames = {"mcl_mushroom:warped_checknode"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
    if nodepos.name == "air" then
      minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_mushroom:warped_nylium" })
      local randomg = math.random(1, 40)
      if randomg == 2 then
        minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_fungus" })
      elseif randomg == 7 then
        local pos1 = { x = pos.x, y = pos.y + 1, z = pos.z }
        generate_warped_tree(pos1)
      end
    else
      minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_nether:netherrack" })
    end
  end
})

mobs:spawn({
  name = "mobs_mc:enderman",
  nodes = "mcl_mushroom:warped_nylium",
  max_light = 15,
  min_light = 0,
  chance = 300,
  active_object_count = 20,
  max_height = -28940,
})



minetest.register_node("mcl_mushroom:crimson_fungus", {
  description = S("Crimson Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_crimson_fungus.png" },
	inventory_image = "farming_crimson_fungus.png",
	wield_image = "farming_crimson_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1},

	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, player)
    if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
      local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
      if nodepos.name == "mcl_mushroom:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
        local random = math.random(1, 5)
        if random == 1 then
          generate_crimson_tree(pos)
        end
      end
    end
  end,
	_mcl_blast_resistance = 0,

  stack_max = 64,
})

minetest.register_node("mcl_mushroom:crimson_hyphae", {
  description = S("Crimson Hyphae"),
  tiles = {"crimson_hyphae.png",
           "crimson_hyphae.png",
           "crimson_hyphae_side.png",
           "crimson_hyphae_side.png",
           "crimson_hyphae_side.png",
           "crimson_hyphae_side.png",
         },
  groups = {handy=5,axey=1, bark=1, building_block=1, material_wood=1,},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:crimson_hyphae_wood", {
  description = S("Crimson Hyphae Wood"),
  tiles = {"crimson_hyphae_wood.png"},
  groups = {handy=5,axey=1, wood=1,building_block=1, material_wood=1,},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 2,
})

minetest.register_node("mcl_mushroom:crimson_nylium", {
  description = S("Crimson Nylium"),
  tiles = {"nether_wart_block.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png^crimson_nylium_side.png",
           "mcl_nether_netherrack.png^crimson_nylium_side.png",
           "mcl_nether_netherrack.png^crimson_nylium_side.png",
           "mcl_nether_netherrack.png^crimson_nylium_side.png",
         },
  groups = {pickaxey=1, building_block=1, material_stone=1},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 0.4,
  _mcl_blast_resistance = 0.4,
  is_ground_content = true,
  drop = "mcl_nether:netherrack",
  _mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mushroom:crimson_checknode", {
  description = S("Crimson Checknode - only to check!"),
  tiles = {"mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
           "mcl_nether_netherrack.png",
         },
  groups = {pickaxey=1, building_block=1, material_stone=1, not_in_creative_inventory=1},
  paramtype2 = "facedir",
  stack_max = 64,
  _mcl_hardness = 0.4,
  _mcl_blast_resistance = 0.4,
  is_ground_content = true,
  drop = "mcl_nether:netherrack"
})

minetest.register_craft({
  output = "mcl_mushroom:crimson_hyphae_wood 4",
  recipe = {
    {"mcl_mushroom:crimson_hyphae"},
  }
})

minetest.register_craft({
  output = "mcl_mushroom:crimson_nyliumd 2",
  recipe = {
    {"mcl_nether:nether_wart"},
    {"mcl_nether:netherrack"},
  }
})

mcl_stairs.register_stair_and_slab_simple("Crimson Wood", "mcl_mushroom:crimson_hyphae_wood", "Crimson Wood Stairs", "Crimson Wood Slab", "Double Crimson Wood Slab")

minetest.register_abm({
	label = "mcl_mushroom:crimson_fungus",
	nodenames = {"mcl_mushroom:crimson_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    if nodepos.name == "mcl_mushroom:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
      if pos.y < -28400 then
        generate_crimson_tree(pos)
      end
    end
  end
})

minetest.register_abm({
	label = "mcl_mushroom:crimson_checknode",
	nodenames = {"mcl_mushroom:crimson_checknode"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
    local nodepos = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
    if nodepos.name == "air" then
      minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_mushroom:crimson_nylium" })
      local randomg = math.random(1, 40)
      if randomg == 2 then
        minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_fungus" })
      elseif randomg == 7 then
        local pos1 = { x = pos.x, y = pos.y + 1, z = pos.z }
        generate_crimson_tree(pos1)
      end
    else
      minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_nether:netherrack" })
    end
  end
})

function generate_warped_tree(pos)
  -- Baumgenerator
  -- Warzen
  -- erste Etage
  -- 2+
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  --1+
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  --0
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  --2-
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })


  -- zweite etage
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z + 2}, { name = "mcl_mushroom:warped_wart_block" })
  --1+
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  --0
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  --2-
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z - 2}, { name = "mcl_mushroom:warped_wart_block" })


  -- dritte etage
  --1+
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  --0
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })

  -- vierte Etage
  --1+
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z + 1}, { name = "mcl_mushroom:warped_wart_block" })
  --0
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z - 1}, { name = "mcl_mushroom:warped_wart_block" })
  -- fünfte Etage
  minetest.set_node({x = pos.x, y = pos.y + 7, z = pos.z}, { name = "mcl_mushroom:warped_wart_block" })

  -- Pilzlich
  local randomgenerate = math.random(1, 2)
  if randomgenerate == 1 then
    local randomx = math.random(-2, 2)
    local randomz = math.random(-2, 2)
    minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
  end
  local randomgenerate = math.random(1, 8)
  if randomgenerate == 4 then
    local randomx = math.random(-2, 2)
    local randomz = math.random(-2, 2)
    minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
  end
  -- Holz
  minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 2, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
end




function generate_crimson_tree(pos)
  -- Baumgenerator
  -- Warzen
  -- erste Etage
  -- 2+
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  --1+
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  --0
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  --2-
  minetest.set_node({x = pos.x + 2, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 3, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 3, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })


  -- zweite etage
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z + 2}, { name = "mcl_nether:nether_wart_block" })
  --1+
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  --0
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  --2-
  minetest.set_node({x = pos.x + 2, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x + 1, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 4, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 2 , y = pos.y + 4, z = pos.z - 2}, { name = "mcl_nether:nether_wart_block" })


  -- dritte etage
  --1+
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  --0
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 1, y = pos.y + 5, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 5, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 5, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })

  -- vierte Etage
  --1+
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z + 1}, { name = "mcl_nether:nether_wart_block" })
  --0
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z}, { name = "mcl_nether:nether_wart_block" })
  --1-
  minetest.set_node({x = pos.x + 1, y = pos.y + 6, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x, y = pos.y + 6, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  minetest.set_node({x = pos.x - 1 , y = pos.y + 6, z = pos.z - 1}, { name = "mcl_nether:nether_wart_block" })
  -- fünfte Etage
  minetest.set_node({x = pos.x, y = pos.y + 7, z = pos.z}, { name = "mcl_nether:nether_wart_block" })

  -- Pilzlich


  local randomx = math.random(-2, 2)
  local randomz = math.random(-2, 2)
  minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })

  local randomgenerate = math.random(1, 2)
  if randomgenerate == 2 then
    local randomx = math.random(-2, 2)
    local randomz = math.random(-2, 2)
    minetest.set_node({x = pos.x + randomx, y = pos.y + 3, z = pos.z + randomz}, { name = "mcl_mushroom:shroomlight" })
  end
  -- Holz
  minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 2, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 3, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
  minetest.set_node({x = pos.x, y = pos.y + 4, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
end


--[[
FIXME: Biomes are to rare
FIXME: Decoration don't do generate
-- biomes in test!
minetest.register_biome({
  name = "WarpedForest",
  node_filler = "mcl_nether:netherrack",
  node_stone = "mcl_nether:netherrack",
  node_top = "mcl_mushroom:warped_nylium",
  node_water = "air",
  node_river_water = "air",
  y_min = -29065,
  y_max = -28940,
  heat_point = 100,
  humidity_point = 0,
  _mcl_biome_type = "hot",
  _mcl_palette_index = 19,
})
minetest.register_decoration({
  deco_type = "simple",
  place_on = {"mcl_mushroom:warped_nylium"},
  sidelen = 16,
  noise_params = {
    offset = 0.01,
    scale = 0.0022,
    spread = {x = 250, y = 250, z = 250},
    seed = 2,
    octaves = 3,
    persist = 0.66
  },
  biomes = {"WarpedForest"},
  y_min = -29065,
  y_max = -28940 + 80,
  decoration = "mcl_mushroom:warped_fungus",
})
]]
minetest.register_ore({
  ore_type        = "sheet",
  ore             = "mcl_mushroom:warped_checknode",
  -- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
  -- in v6, but instead set with the on_generated function in mcl_mapgen_core.
  wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
  clust_scarcity  = 14 * 14 * 14,
  clust_size      = 10,
  y_min           = -29065,
  y_max           = -28940,
  noise_threshold = 0.0,
  noise_params    = {
    offset = 0.5,
    scale = 0.1,
    spread = {x = 8, y = 8, z = 8},
    seed = 4996,
    octaves = 1,
    persist = 0.0
  },
})

minetest.register_ore({
  ore_type        = "sheet",
  ore             = "mcl_mushroom:crimson_checknode",
  -- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
  -- in v6, but instead set with the on_generated function in mcl_mapgen_core.
  wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
  clust_scarcity  = 10 * 10 * 10,
  clust_size      = 10,
  y_min           = -29065,
  y_max           = -28940,
  noise_threshold = 0.0,
  noise_params    = {
    offset = 1,
    scale = 0.5,
    spread = {x = 12, y = 12, z = 12},
    seed = 12948,
    octaves = 1,
    persist = 0.0
  },
})


minetest.register_decoration({
    deco_type = "simple",
    place_on = {"mcl_mushroom:warped_nylium"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"Nether"},
    y_max = -28940,
    y_min = -29065,
    decoration = "mcl_mushroom:warped_fungus",
})


minetest.register_decoration({
    deco_type = "simple",
    place_on = {"mcl_mushroom:crimson_nylium"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"Nether"},
    y_max = -28940,
    y_min = -29065,
    decoration = "mcl_mushroom:crimson_fungus",
})
