local S = minetest.get_translator(minetest.get_current_modname())

function mcl_amethyst.grow_amethyst_bud(pos, ignore_budding_amethyst)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if not (def and def.groups and def.groups.amethyst_buds) then return end
	local next_gen = def._mcl_amethyst_next_grade
	if not next_gen then return end

	-- Check Budding Amethyst
	if not ignore_budding_amethyst then
		local dir = minetest.wallmounted_to_dir(node.param2)
		local ba_pos = vector.add(pos, dir)
		local ba_node = minetest.get_node(ba_pos)
		if ba_node.name ~= "mcl_amethyst:budding_amethyst_block" then return end
	end
	local swap_result = table.copy(node)
	swap_result.name = next_gen
	minetest.swap_node(pos, swap_result)
	return true
end

local function get_growing_tool_handle(ignore)
	return function(itemstack, user, pointed_thing)
		if not user:is_player() then return end
		local name = user:get_player_name()
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			minetest.chat_send_player(name, S("Not allowed to use Amethyst Growing Tool in a protected area!"))
			return
		end
		if not mcl_amethyst.grow_amethyst_bud(pos, ignore) then
			minetest.chat_send_player(name, S("Growing Failed"))
		end
	end
end

minetest.register_tool("mcl_amethyst:growing_tool",{
	description = S("Amethyst Growing Tool"),
	on_use = get_growing_tool_handle(true),
	on_place = get_growing_tool_handle(false),
	inventory_image = "amethyst_cluster.png^amethyst_shard.png",
	groups = {
		tool = 1,
	},
})

mcl_wip.register_experimental_item("mcl_amethyst:growing_tool")
