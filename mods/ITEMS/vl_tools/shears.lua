vl_tools.shears = vl_tools.shears or {}

local S = core.get_translator("mcl_tools")

local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

function vl_tools.shears.carve_pumpkin(itemstack, placer, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
			return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	if pointed_thing.above.y ~= pointed_thing.under.y then
		return
	end
	if node.name == "mcl_farming:pumpkin" then
		if not core.is_creative_enabled(placer:get_player_name()) then
			local toolname = itemstack:get_name()
			local wear = mcl_autogroup.get_wear(toolname, "shearsy")
			if wear then
				itemstack:add_wear(wear)
				tt.reload_itemstack_description(itemstack)
			end

		end
		core.sound_play({name = "default_grass_footstep", gain = 1}, {pos = pointed_thing.above}, true)
		local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
		local param2 = core.dir_to_facedir(dir)
		core.set_node(pointed_thing.under, {name = "mcl_farming:pumpkin_face", param2 = param2})
		core.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
	end
	return itemstack
end

function vl_tools.shears.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.shears.register requires a tool name")
	assert(def, "vl_tools.shears.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.shears.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.shears.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_doc_items_longdesc = shears_longdesc,
		_doc_items_usagehelp = shears_use,
		wield_image = def.wield_image or def.icon,
		stack_max = def.stack_max or 1,
		groups = {
			tool = 1,
			shears = 1,
		},
		on_place = vl_tools.shears.carve_pumpkin,
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, ""},
				{"", def.repair_material},
			}
		})
		core.register_craft({
			output = name,
			recipe = {
				{"", def.repair_material},
				{def.repair_material, ""},
			}
		})
	end
end
