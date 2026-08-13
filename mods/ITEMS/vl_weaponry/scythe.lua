local S = core.get_translator(core.get_current_modname())

local scythe_tt = S("Cuts plants in range")
local scythe_longdesc = S("Scythes are great in melee combat.")
local scythe_use = S("When you cut down a plant with a scythe, it cuts down other plants in a 3x3 area.")
local SCYTHE_RANGE = 4.0
local locked_digger = false

vl_weaponry.scythe_tt = scythe_tt

---Cut plantlike nodes in a 3x3 area around a dug plant.
---@return boolean cut Whether the area effect was applied.
function vl_weaponry.scythe_cut_plants(pos, oldnode, digger)
	if locked_digger or not digger then return false end

	local tool = digger:get_wielded_item()
	if not tool or core.get_item_group(tool:get_name(), "scythe") <= 0 then
		return false
	end

	local definition = core.registered_nodes[oldnode.name]
	if not definition or definition.drawtype ~= "plantlike"
			or core.get_item_group(oldnode.name, "plant") <= 0 then
		return false
	end

	locked_digger = true
	for x = -1, 1 do
		for z = -1, 1 do
			local plant_pos = vector.offset(pos, x, 0, z)
			local node = core.get_node(plant_pos)
			local node_definition = core.registered_nodes[node.name]
			if node_definition and node_definition.drawtype == "plantlike"
					and core.get_item_group(node.name, "plant") > 0 then
				core.dig_node(plant_pos, digger)
			end
		end
	end
	locked_digger = false
	return true
end

core.register_on_dignode(vl_weaponry.scythe_cut_plants)

local function build_definition(_, material, stats)
	return {
		_tt_help = scythe_tt,
		_doc_items_longdesc = scythe_longdesc,
		_doc_items_usagehelp = scythe_use,
		_doc_items_hidden = false,
		wield_scale = mcl_vars.tool_wield_scale,
		groups = {
			weapon = 1,
			tool = 1,
			scythe = 1,
			dig_speed_class = material.dig_speed_class,
		},
		range = SCYTHE_RANGE,
		tool_capabilities = {
			full_punch_interval = stats.attack_interval,
			max_drop_level = stats.harvest_level,
			damage_groups = { fleshy = stats.damage },
			punch_attack_uses = stats.durability,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			swordy = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			},
			swordy_cobweb = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			},
			hoey = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			},
		},
	}
end

local function register_crafts(item_name, craft_material)
	local stick = "mcl_core:stick"
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material, craft_material, stick },
			{ "", stick, "" },
			{ stick, "", "" },
		},
	})
	core.register_craft({
		output = item_name,
		recipe = {
			{ stick, craft_material, craft_material },
			{ "", stick, "" },
			{ "", "", stick },
		},
	})
end

vl_weaponry.register_tool_type("vl_weaponry:scythe", {
	smelting_yield = 18,
	base_stats = {
		durability = 0,
		dig_speed = 1,
		harvest_level = 0,
		damage = 5,
		attack_interval = 1.1,
		enchantability = 0,
	},
	build_definition = build_definition,
	register_crafts = register_crafts,
})
