vl_tools.pickaxe = vl_tools.pickaxe or {}

local S = core.get_translator("mcl_tools")
local wield_scale = mcl_vars.tool_wield_scale

local pickaxe_longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient.")

function vl_tools.pickaxe.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.pickaxe.register requires a tool name")
	assert(def, "vl_tools.pickaxe.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.pickaxe.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.pickaxe.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_doc_items_longdesc = pickaxe_longdesc,
		wield_scale = wield_scale,
		groups = {
			tool = 1,
			pickaxe = 1,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material, def.repair_material},
				{"", "mcl_core:stick", ""},
				{"", "mcl_core:stick", ""},
			}
		})
	end

	if def.fuel_burntime then
		core.register_craft({
			type = "fuel",
			recipe = name,
			burntime = def.fuel_burntime,
		})
	end

	if def.cook_result then
		core.register_craft({
			type = "cooking",
			output = def.cook_result,
			recipe = name,
			cooktime = def.cooktime or 10,
		})
	end
end
