unused_args = false
allow_defined_top = true

globals = {
	"mcl_player"
}

read_globals = {
    "core",
    "mcl_tmp_message",

    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},
    -- My mod
    "mcl_cozy",

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",

    -- Mineclone
    "mcl_loot", "tga_encoder", "mcl_util", "flowlib", "mcl_sounds", "mcl_autogroup",
     "mcl_events", "biomeinfo", "mcl_damage", "mcl_particles", "mcl_worlds", "mcl_colors",
      "mcl_explosions", "mcl_vars", "controls", "walkover", "mcl_meshhand", "mcl_fovapi",
       "playerphysics", "mcl_hunger", "mcl_death_drop", "mcl_playerplus",
        "mcl_gamemode", "mcl_spawn", "mcl_skins", "mcl_sprint", "mcl_playerinfo",
         "mcl_item_id", "tt", "mcl_craftguide", "doc", "mcl_dripping",
         "mcl_entity_invs", "mcl_item_entity", "mcl_burning",
         "mcl_minecarts", "pillager", "mobs_mc", "sounds",
         "textures", "mcl_mobs", "mcl_paintings",
         "mcl_grindstone", "mcl_walls", "mcl_bamboo",
         "mcl_maps", "mcl_clock", "mcl_end", "mcl_starting_inventory",
         "mcl_bows", "mcl_bows_s", "mcl_dye", "mcl_copper",
          "mcl_flowerpots", "mcl_furnaces", "mcl_farming",
          "mcl_campfires", "mcl_crafting_table", "mcl_doors",
          "mcl_jukebox", "screwdriver", "mcl_itemframes",
          "mcl_heads", "mcl_beacons", "xpanes", "mcl_enchanting",
          "mcl_beds", "mcl_throwing", "mcl_banners", "mcl_mobspawners",
          "mcl_cocoas", "mcl_smithing_table", "mcl_flowers",
         "mcl_core", "mcl_torches", "mcl_target", "mesecon", "mcl_observers",
         "mcl_sculk", "mcl_armor", "mcl_lanterns", "mcl_stairs", "mcl_bells",
         "mcl_hamburger", "mcl_signs", "mcl_honey", "mcl_stonecutter", "mcl_fire",
          "mcl_compass", "mcl_ocean", "mcl_fences", "mcl_buckets", "mcl_potions",
          "tnt", "mcl_cherry_blossom", "mcl_portals", "mcl_chests", "mcl_shields",
          "mcl_wip", "mcl_raids", "mcl_moon", "lightning", "mcl_weather",
          "mcl_formspec", "mcl_death_messages", "mcl_bossbars", "awards",
          "mcl_inventory", "mcl_title", "mcl_offhand", "hb", "mcl_experience",
          "mcl_info", "mcl_credits", "tsm_railcorridors", "mcl_mapgen_core",
          "mcl_structures", "settlements", "mcl_dungeons", "mcl_colors_official"
}
