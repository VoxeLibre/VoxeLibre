vl_tools.hammer = vl_tools.hammer or {}

local S = core.get_translator("vl_weaponry")
local wield_scale = mcl_vars.tool_wield_scale

local hammer_tt = S("Can crush blocks") .. "\n" .. S("Increased knockback")
local hammer_longdesc = S("Hammers are great in melee combat, as they deal high damage with increased knockback and can endure countless battles. Hammers can also be used to crush things.")
local hammer_use = S("To crush a block, dig the block with the hammer. This only works with some blocks.")

function vl_tools.hammer.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.hammer.register requires a tool name")
	assert(def, "vl_tools.hammer.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.hammer.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.hammer.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_tt_help = hammer_tt,
		_doc_items_longdesc = hammer_longdesc,
		_doc_items_usagehelp = hammer_use,
		wield_scale = wield_scale,
		groups = {
			weapon = 1,
			hammer = 1,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, "", def.repair_material},
				{def.repair_material, "mcl_core:stick", def.repair_material},
				{"", "mcl_core:stick", ""},
			}
		})
	end
end
