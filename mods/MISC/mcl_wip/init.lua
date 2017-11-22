local wip_items = {
	"mcl_anvils:anvil",
	"mcl_anvils:anvil_damage_1",
	"mcl_anvils:anvil_damage_2",
	"mcl_end:chorus_fruit",
	"mcl_end:chorus_flower",
	"mcl_end:chorus_flower_dead",
	"mcl_fishing:fishing_rod",
	"mcl_maps:empty_map",
	"gemalde:node_1",
	"mcl_observers:observer",
	"mcl_chests:trapped_chest",
	"mobs_mc:totem",
	"mcl_paintings:painting",
	"mcl_comparators:comparator_off_comp",
	"mcl_minecarts:hopper_minecart",
	"mcl_minecarts:command_block_minecart",
	"mcl_minecarts:chest_minecart",
	"mcl_minecarts:furnace_minecart",
	"mcl_minecarts:tnt_minecart",
	"mcl_minecarts:activator_rail",
}
local experimental_items = {}

for i=1,#wip_items do
	local def = minetest.registered_items[wip_items[i]]
	if not def then
		minetest.log("error", "[mcl_wip] Unknown item: "..wip_items[i])
		break
	end
	local new_description = def.description
	local new_groups = table.copy(def.groups)
	new_description = new_description .. "\n"..core.colorize("#FF0000", "(WIP)")
	new_groups.not_in_craft_guide = 1
	minetest.override_item(wip_items[i], { description = new_description, groups = new_groups })
end

for i=1,#experimental_items do
	local def = minetest.registered_items[experimental_items[i]]
	if not def then
		minetest.log("error", "[mcl_wip] Unknown item: "..experimental_items[i])
		break
	end
	local new_description = def.description
	new_description = new_description .. "\n"..core.colorize("#FFFF00", "(Experimental)")
	minetest.override_item(experimental_items[i], { description = new_description })
end


