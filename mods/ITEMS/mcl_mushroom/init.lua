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

	if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
	      itemstack:take_item()
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

minetest.register_node("mcl_mushroom:twisting_vines", {
  description = S("Twisting Vines"),
	drawtype = "plantlike",
	tiles = { "twisting_vines_plant.png" },
	inventory_image = "twisting_vines.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	climbable = true,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, itemstack)

	if pointed_thing:get_wielded_item():get_name() == "mcl_mushroom:twisting_vines" then
	      itemstack:take_item()
	      grow_twisting_vines(pos, 1)
	elseif pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
	      itemstack:take_item()
	      grow_twisting_vines(pos, math.random(1, 3))
	end
	end,
	drop = {
	max_items = 1,
	items = {
			{items = {"mcl_mushroom:twisting_vines"}, rarity = 3},
		}
	},
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { items = {{items = {"mcl_mushroom:twisting_vines"}, rarity = 3},},
	 											items = {{items = {"mcl_mushroom:twisting_vines"}, rarity = 1.8181818181818181},},
												"mcl_mushroom:twisting_vines",
												"mcl_mushroom:twisting_vines"},
  _mcl_blast_resistance = 0,
  stack_max = 64,
})

minetest.register_node("mcl_mushroom:nether_sprouts", {
  description = S("Nether Sprouts"),
	drawtype = "plantlike",
	tiles = { "nether_sprouts.png" },
	inventory_image = "nether_sprouts.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 0, 4/16 },
	},
	node_placement_prediction = "",
	drop = "",
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = false,
  _mcl_blast_resistance = 0,
  stack_max = 64,
})

minetest.register_node("mcl_mushroom:warped_roots", {
  description = S("Warped Roots"),
	drawtype = "plantlike",
	tiles = { "warped_roots.png" },
	inventory_image = "warped_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
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
  groups = {handy=1,hoe=7,swordy=1, leafdecay=1, leafdecay_distance=1, leaves=1, deco_block=1, },
  stack_max = 64,
  _mcl_hardness = 2,
  -- this is 15 in Minecraft
  light_source = 14,
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
  tiles = {"warped_nylium.png",
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

mcl_stairs.register_stair_and_slab_simple("warped_hyphae_wood", "mcl_mushroom:warped_hyphae_wood", "Warped Wood Stairs", "Warped Wood Slab", "Double Warped Wood Slab")

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
<<<<<<< HEAD
=======
			elseif randomg > 15 and randomg <= 45 then
				grow_twisting_vines({ x = pos.x, y = pos.y, z = pos.z } ,math.random(1, 4))
			elseif randomg > 45 and randomg <= 50 then
				minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_fungus" })
			elseif randomg > 50 and randomg <= 150 then
				minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:nether_sprouts" })
			elseif randomg > 150 and randomg <= 250 then
				minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_roots" })
>>>>>>> da0cb4853 (Add more decoration blocks.)
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

minetest.register_node("mcl_mushroom:crimson_roots", {
  description = S("Crimson Roots"),
	drawtype = "plantlike",
	tiles = { "crimson_roots.png" },
	inventory_image = "crimson_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
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
  tiles = {"crimson_nylium.png",
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

mcl_stairs.register_stair_and_slab_simple("crimson_hyphae_wood", "mcl_mushroom:crimson_hyphae_wood", "Crimson Wood Stairs", "Crimson Wood Slab", "Double Crimson Wood Slab")

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
			local randomg = math.random(1, 400)
      if randomg <= 10 then
        minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_fungus" })
      elseif randomg > 10 and randomg <= 25 then
        local pos1 = { x = pos.x, y = pos.y + 1, z = pos.z }
        generate_crimson_tree(pos1)
			elseif randomg > 25 and randomg <= 30 then
	      minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:warped_fungus" })
			elseif randomg > 30 and randomg <= 130 then
	      minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "mcl_mushroom:crimson_roots" })
      end
    else
      minetest.swap_node({ x = pos.x, y = pos.y, z = pos.z }, { name = "mcl_nether:netherrack" })
    end
  end
})

function generate_warped_tree(pos)
  breakgrow = false
  breakgrow2 = false
  -- Baumgenerator
  -- erste und zweite Etage
  	for x = pos.x - 2,pos.x + 2 do
        	for y = pos.y + 3, pos.y + 4 do
        	    for z = pos.z - 2, pos.z + 2 do
        	        if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then breakgrow = true end	
        	    end
        	end
    	end
  
  	-- dritte und vierte Etage
  	for x = pos.x - 1,pos.x + 1 do
  	      for y = pos.y + 5, pos.y + 6 do
  	          for z = pos.z - 1, pos.z + 1 do
  	              if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then breakgrow = true end
  	          end
  	      end
  	  end
 
 	 -- fünfte Etage
	if not (minetest.get_node({x = pos.x, y = pos.y + 7, z = pos.z}).name == "air") then breakgrow = true end

 	 -- Holz
	 if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:warped_fungus") then breakgrow = true end
 	 for y = pos.y + 1, pos.y + 4 do
 	   if not (minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air") then breakgrow = true end
	   print(minetest.get_node({x = pos.x, y = y, z = pos.z}).name)
 	 end
	 if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:warped_fungus") then breakgrow2 = true end
  print(tostring(breakgrow))
  if breakgrow == false then
	-- Warzen
	-- erste und zweite Etage
  	for x = pos.x - 2,pos.x + 2 do
        	for y = pos.y + 3, pos.y + 4 do
        	    for z = pos.z - 2, pos.z + 2 do
        	        minetest.set_node({x = x, y = y, z = z}, { name = "mcl_mushroom:warped_wart_block" })
        	    end
        	end
    	end
  
  	-- dritte und vierte Etage
  	for x = pos.x - 1,pos.x + 1 do
  	      for y = pos.y + 5, pos.y + 6 do
  	          for z = pos.z - 1, pos.z + 1 do
  	              minetest.set_node({x = x, y = y, z = z}, { name = "mcl_mushroom:warped_wart_block" })
  	          end
  	      end
  	  end
 
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
 	 for y = pos.y, pos.y + 4 do
 	   minetest.set_node({x = pos.x, y = y, z = pos.z}, { name = "mcl_mushroom:warped_hyphae" })
 	   --print("Placed at " .. x .. " " .. y .. " " .. z)
 	 end
  else
  	if breakgrow2 == false then minetest.set_node(pos,{ name = "mcl_mushroom:warped_fungus" }) end
  end
end

function generate_crimson_tree(pos)
  breakgrow = false
  breakgrow2 = false
  -- Baumgenerator
  -- erste und zweite Etage
  	for x = pos.x - 2,pos.x + 2 do
        	for y = pos.y + 3, pos.y + 4 do
        	    for z = pos.z - 2, pos.z + 2 do
        	        if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then breakgrow = true end	
        	    end
        	end
    	end
  
  	-- dritte und vierte Etage
  	for x = pos.x - 1,pos.x + 1 do
  	      for y = pos.y + 5, pos.y + 6 do
  	          for z = pos.z - 1, pos.z + 1 do
  	              if not (minetest.get_node({x = x, y = y, z = z}).name == "air") then breakgrow = true end
  	          end
  	      end
  	  end
 
 	 -- fünfte Etage
	if not (minetest.get_node({x = pos.x, y = pos.y + 7, z = pos.z}).name == "air") then breakgrow = true end

 	 -- Holz
	 if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:crimson_fungus") then breakgrow = true end
 	 for y = pos.y + 1, pos.y + 4 do
 	   if not (minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air") then breakgrow = true end
	   print(minetest.get_node({x = pos.x, y = y, z = pos.z}).name)
 	 end
	 if not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "air") and not (minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "mcl_mushroom:crimson_fungus") then breakgrow2 = true end
  print(tostring(breakgrow))
  if breakgrow == false then
	-- Warzen
	-- erste und zweite Etage
  	for x = pos.x - 2,pos.x + 2 do
        	for y = pos.y + 3, pos.y + 4 do
        	    for z = pos.z - 2, pos.z + 2 do
        	        minetest.set_node({x = x, y = y, z = z}, { name = "mcl_nether:nether_wart_block" })
        	    end
        	end
    	end
  
  	-- dritte und vierte Etage
  	for x = pos.x - 1,pos.x + 1 do
  	      for y = pos.y + 5, pos.y + 6 do
  	          for z = pos.z - 1, pos.z + 1 do
  	              minetest.set_node({x = x, y = y, z = z}, { name = "mcl_nether:nether_wart_block" })
  	          end
  	      end
  	  end
 
 	 -- fünfte Etage
 	 minetest.set_node({x = pos.x, y = pos.y + 7, z = pos.z}, { name = "mcl_nether:nether_wart_block" })

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
 	 for y = pos.y, pos.y + 4 do
 	   minetest.set_node({x = pos.x, y = y, z = pos.z}, { name = "mcl_mushroom:crimson_hyphae" })
 	   --print("Placed at " .. x .. " " .. y .. " " .. z)
 	 end
  else
  	if breakgrow2 == false then minetest.set_node(pos,{ name = "mcl_mushroom:crimson_fungus" }) end
  end
end


--[[
FIXME: Biomes are to rare
FIXME: Decoration don't do generate
WARNING: Outdatet, the biomes gernerate now different, with Ores 
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
--[[ No Ore gen for now
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
--]]

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
