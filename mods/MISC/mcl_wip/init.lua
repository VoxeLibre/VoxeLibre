local wip_items = {
	"mcl_anvils:anvil",
	"mcl_anvils:anvil_damage_1",
	"mcl_anvils:anvil_damage_2",
	"mcl_core:darksapling",
	"mcl_core:apple_gold",
	"mcl_end:ender_eye",
	"mcl_end:chorus_fruit",
	"mcl_end:chorus_flower",
	"mcl_end:chorus_flower_dead",
	"mcl_fishing:fishing_rod",
	"mcl_maps:filled_map",
	"mcl_maps:empty_map",
	"mcl_minecarts:golden_rail",
	"gemalde:node_1",
	"mcl_observers:observer",
	"mcl_chests:trapped_chest",
	"mcl_core:cobweb",
	"mobs_mc:parrot",
	"mobs_mc:vindicator",
	"mobs_mc:evoker",
	"mobs_mc:vex",
	"mobs_mc:llama",
	"mobs_mc:illusioner",
	"mobs_mc:skeleton_horse",
	"mobs_mc:totem",
}

for i=1,#wip_items do
	local def = minetest.registered_items[wip_items[i]]
	if not def then
		minetest.log("error", "[mcl_wip] Unknown item: "..wip_items[i])
		break
	end
	local new_description = def.description
	new_description = new_description .. "\n"..core.colorize("#FF0000", "(WIP)")
	minetest.override_item(wip_items[i], { description = new_description })
end

local experimental_items = {
	"doc_identifier:identifier_solid",
	"doc_identifier:identifier_liquid",
}
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


