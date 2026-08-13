local S = core.get_translator(core.get_current_modname())

local hammer_tt = S("Can crush blocks") .. "\n" .. S("Increased knockback")
local hammer_longdesc = S("Hammers are great in melee combat, as they deal high damage with increased knockback and can endure countless battles. Hammers can also be used to crush things.")
local hammer_use = S("To crush a block, dig the block with the hammer. This only works with some blocks.")

vl_weaponry.hammer_tt = hammer_tt

local function build_definition(_, material, stats)
	return {
		_tt_help = hammer_tt,
		_doc_items_longdesc = hammer_longdesc,
		_doc_items_usagehelp = hammer_use,
		_doc_items_hidden = false,
		wield_scale = mcl_vars.tool_wield_scale,
		groups = { weapon = 1, hammer = 1, dig_speed_class = 2 },
		tool_capabilities = {
			full_punch_interval = stats.attack_interval,
			max_drop_level = stats.harvest_level,
			damage_groups = { fleshy = stats.damage },
			punch_attack_uses = stats.durability,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			pickaxey = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			},
			shovely = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			},
		},
	}
end

local function register_crafts(item_name, craft_material)
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material, "", craft_material },
			{ craft_material, "mcl_core:stick", craft_material },
			{ "", "mcl_core:stick", "" },
		},
	})
end

vl_weaponry.register_tool_type("vl_weaponry:hammer", {
	smelting_yield = 36,
	base_stats = {
		durability = 0,
		dig_speed = 0.5,
		harvest_level = 0,
		damage = 4,
		attack_interval = 1.2,
		enchantability = 0,
	},
	build_definition = build_definition,
	register_crafts = register_crafts,
})
