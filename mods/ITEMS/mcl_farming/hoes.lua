local S = core.get_translator(core.get_current_modname())

function mcl_farming.create_soil(pos)
	if not pos then return false end
	local node = core.get_node(pos)
	local above = core.get_node(vector.offset(pos, 0, 1, 0))
	local cultivatable = core.get_item_group(node.name, "cultivatable")
	if above.name ~= "air" or cultivatable == 0 then return false end

	if cultivatable == 2 then
		node.name = "mcl_farming:soil"
		core.set_node(pos, node)
		core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
		return true
	elseif cultivatable == 1 then
		node.name = "mcl_core:dirt"
		core.set_node(pos, node)
		core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
		return true
	end
	return false
end

function mcl_farming.hoe_on_place(itemstack, user, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	if user and not user:get_player_control().sneak then
		local node_def = core.registered_nodes[node.name]
		if node_def and node_def.on_rightclick then
			return node_def.on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
		end
	end
	if core.is_protected(pointed_thing.under, user:get_player_name()) then
		core.record_protection_violation(pointed_thing.under, user:get_player_name())
		return itemstack
	end
	if mcl_farming.create_soil(pointed_thing.under) then
		if not core.is_creative_enabled(user:get_player_name()) then
			local wear = mcl_autogroup.get_wear(itemstack:get_name(), "hoey")
			if wear then
				itemstack:add_wear(wear)
				tt.reload_itemstack_description(itemstack)
			end
		end
		return itemstack
	end
end

local hoe_tt = S("Turns block into farmland")
local hoe_longdesc = S(
	"Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch.")
local hoe_usagehelp = S(
	"Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt.")

local function pair(item_name, description, inventory_image, upgrade_item)
	return {
		item_name = item_name,
		description = description,
		inventory_image = inventory_image,
		upgrade_item = upgrade_item,
	}
end

local materials = {
	wood = pair("mcl_farming:hoe_wood", S("Wood Hoe"), "farming_tool_woodhoe.png"),
	stone = pair("mcl_farming:hoe_stone", S("Stone Hoe"), "farming_tool_stonehoe.png"),
	iron = pair("mcl_farming:hoe_iron", S("Iron Hoe"), "farming_tool_steelhoe.png"),
	gold = pair("mcl_farming:hoe_gold", S("Gold Hoe"), "farming_tool_goldhoe.png"),
	diamond = pair("mcl_farming:hoe_diamond", S("Diamond Hoe"), "farming_tool_diamondhoe.png",
		"mcl_farming:hoe_netherite"),
	netherite = pair("mcl_farming:hoe_netherite", S("Netherite Hoe"), "farming_tool_netheritehoe.png"),
}

local function register_crafts(item_name, craft_material)
	local stick = "mcl_core:stick"
	for _, recipe in ipairs({
		{
			{ craft_material, craft_material },
			{ "", stick },
			{ "", stick },
		},
		{
			{ craft_material, craft_material },
			{ stick, "" },
			{ stick, "" },
		},
	}) do
		core.register_craft({ output = item_name, recipe = recipe })
	end
end

vl_weaponry.register_tool_type("mcl_farming:hoe", {
	materials = materials,
	smelting_yield = 18,
	base_stats = {
		durability = 0,
		dig_speed = 1,
		harvest_level = 0,
		damage = 1,
		enchantability = 0,
	},
	build_definition = function(_, material, stats)
		return {
			_tt_help = hoe_tt,
			_doc_items_longdesc = hoe_longdesc,
			_doc_items_usagehelp = hoe_usagehelp,
			_doc_items_hidden = false,
			wield_scale = mcl_vars.tool_wield_scale,
			on_place = mcl_farming.hoe_on_place,
			groups = { tool = 1, hoe = 1, dig_speed_class = material.dig_speed_class },
			tool_capabilities = {
				full_punch_interval = math.max(2 / stats.dig_speed, 0.25),
				damage_groups = { fleshy = math.max(1, stats.damage) },
				punch_attack_uses = stats.durability,
			},
			sound = { breaks = "default_tool_breaks" },
			_mcl_toollike_wield = true,
			_mcl_diggroups = { hoey = {
				speed = stats.dig_speed,
				level = stats.harvest_level,
				uses = stats.durability,
			} },
		}
	end,
	register_crafts = register_crafts,
})
