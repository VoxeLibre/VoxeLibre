-- Copyright (c) 2021 Cato Yiu (GPLv3)
local S = minetest.get_translator(minetest.get_current_modname())

-- Amethyst block
minetest.register_node("mcl_amethyst:amethyst_block",{
  description = S("Block of Amethyst"),
  tiles = {"amethyst_block.png"},
  _mcl_hardness = 1.5,
  _mcl_blast_resistance = 1.5,
  groups = {
    pickaxey = 1,
    building_block = 1,
  },
  sounds = mcl_sounds.node_sound_glass_defaults(),
  is_ground_content = true,
  stack_max = 64,
  _doc_items_longdesc = S("The Block of Anethyst is a decoration block creft from amethyst shards."),
})

-- (WIP!) Budding Amethyst
minetest.register_node("mcl_amethyst:budding_amethyst_block",{
  description = S("Budding Amethyst"),
  tiles = {"budding_amethyst.png"},
  drop = "",
  _mcl_hardness = 1.5,
  _mcl_blast_resistance = 1.5,
  groups = {
    pickaxey = 1,
    building_block = 1,
    dig_by_piston = 1,
  },
  sounds = mcl_sounds.node_sound_glass_defaults(),
  is_ground_content = true,
  stack_max = 64,
  _doc_items_longdesc = S("The Budding Anethyst can grow amethyst"),
})
mcl_wip.register_wip_item("mcl_amethyst:budding_amethyst_block")

-- Amethyst Shard
minetest.register_craftitem("mcl_amethyst:amethyst_shard",{
  description = S("Amethyst Shard"),
  inventory_image = "amethyst_shard.png",
  stack_max = 64,
  groups = {
    craftitem = 1,
  },
  _doc_items_longdesc = S("An amethyst shard is a crystalline mineral."),
})

-- Calcite
minetest.register_node("mcl_amethyst:calcite",{
  description = S("Calcite"),
  tiles = {"calcite.png"},
  _mcl_hardness = 0.75,
  _mcl_blast_resistance = 0.75,
  groups = {
    pickaxey = 1,
    building_block = 1,
  },
  sounds = mcl_sounds.node_sound_stone_defaults(),
  is_ground_content = true,
  stack_max = 64,
  _doc_items_longdesc = S("Calcite can be found as part of amethyst geodes."),
})

-- Tinied Glass
minetest.register_node("mcl_amethyst:tinted_glass",{
  description = S("Tinted Glass"),
  tiles = {"tinted_glass.png"},
  _mcl_hardness = 0.3,
  _mcl_blast_resistance = 0.3,
  drawtype = "glasslike",
  use_texture_alpha = "clip",
  sunlight_propagates = false,
  groups = {
    handy = 1,
    building_block = 1,
    deco_block = 1,
  },
  sounds = mcl_sounds.node_sound_glass_defaults(),
  is_ground_content = false,
  stack_max = 64,
  _doc_items_longdesc = S("Tinted Glass is a type of glass which blocks lights while it is visually transparent."),
})

-- Amethyst Cluster
local bud_def = {
  {"small","Small","mcl_amethyst:medium_amethyst_bud"},
  {"medium","Medium","mcl_amethyst:large_amethyst_bud"},
  {"large","Large","mcl_amethyst:amethyst_cluster"},
}
for x,y in pairs(bud_def) do
  minetest.register_node("mcl_amethyst:" .. y[1] .. "_amethyst_bud",{
    description = y[2] .. "Amethyst Bud",
    _mcl_hardness = 1.5,
    _mcl_blast_resistance = 1.5,
    drop = "",
    tiles = {y[1] .. "_amethyst_bud.png",},
    paramtype2 = "wallmounted",
    drawtype = "plantlike",
    use_texture_alpha = "clip",
    sunlight_propagates = true,
    groups = {
      dig_by_water = 1,
      destroy_by_lava_flow = 1,
      dig_by_piston = 1,
      pickaxey = 1,
      deco_block = 1,
    },
    selection_box = {
      type = "fixed",
      -- fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
      fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
    },
    collision_box = {
      type = "fixed",
      -- fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
      fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
    },
    _mcl_silk_touch_drop = true,
    _mcl_amethyst_next_grade = y[3],
  })
end

-- Register Crafts
minetest.register_craft({
  output = "mcl_amethyst:amethyst_block",
  recipe = {
    {"mcl_amethyst:amethyst_shard","mcl_amethyst:amethyst_shard",},
    {"mcl_amethyst:amethyst_shard","mcl_amethyst:amethyst_shard",},
  },
})

minetest.register_craft({
  output = "mcl_amethyst:tinted_glass",
  recipe = {
    {"","mcl_amethyst:amethyst_shard",""},
    {"mcl_amethyst:amethyst_shard","mcl_core:glass","mcl_amethyst:amethyst_shard",},
    {"","mcl_amethyst:amethyst_shard",""},
  },
})

if minetest.get_modpath("mcl_spyglass") then
  minetest.clear_craft({output = "mcl_spyglass:spyglass",})
  local function craft_spyglass(ingot)
    minetest.register_craft({
      output = "mcl_spyglass:spyglass",
      recipe = {
        {"mcl_amethyst:amethyst_shard"},
        {ingot},
        {ingot},
      }
    })
  end
  if minetest.get_modpath("mcl_copper") then
    craft_spyglass("mcl_copper:copper_ingot")
  else
    craft_spyglass("mcl_core:iron_ingot")
  end
end
