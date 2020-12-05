-- Mod to mark WIP (Work In Progress) content

local S = minetest.get_translator("mcl_wip")

local wip_items = {
	"mcl_maps:empty_map",
	"mcl_comparators:comparator_off_comp",
	"mcl_minecarts:hopper_minecart",
	"mcl_minecarts:command_block_minecart",
	"mcl_minecarts:chest_minecart",
	"mcl_minecarts:furnace_minecart",
	"mobs_mc:enderdragon",
	"mobs_mc:wither",
	"mobs_mc:witch",
	"screwdriver:screwdriver",
	"mcl_paintings:painting",
	"mcl_potions:night_vision",
	"mcl_potions:night_vision_plus",
	-- "mcl_potions:weakness",
	-- "mcl_potions:weakness_plus",
	-- "mcl_potions:strength",
	-- "mcl_potions:strength_plus",
	-- "mcl_potions:strength_2",
	"mcl_potions:night_vision_splash",
	"mcl_potions:night_vision_plus_splash",
	-- "mcl_potions:weakness_splash",
	-- "mcl_potions:weakness_plus_splash",
	-- "mcl_potions:strength_splash",
	-- "mcl_potions:strength_plus_splash",
	-- "mcl_potions:strength_2_splash",
	"mcl_potions:night_vision_lingering",
	"mcl_potions:night_vision_plus_lingering",
	-- "mcl_potions:weakness_lingering",
	-- "mcl_potions:weakness_plus_lingering",
	-- "mcl_potions:strength_lingering",
	-- "mcl_potions:strength_plus_lingering",
	-- "mcl_potions:strength_2_lingering",
	"mcl_potions:night_vision_arrow",
	"mcl_potions:night_vision_plus_arrow",
}
local experimental_items = {
}

for i=1,#wip_items do
	local def = minetest.registered_items[wip_items[i]]
	if not def then
		minetest.log("error", "[mcl_wip] Unknown item: "..wip_items[i])
		break
	end
	local new_description = def.description
	local new_groups = table.copy(def.groups)
	if new_description == "" then
		new_description = wip_items[i]
	end
	new_description = new_description .. "\n"..core.colorize("#FF0000", S("(WIP)"))
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
	new_description = new_description .. "\n"..core.colorize("#FFFF00", S("(Temporary)"))
	minetest.override_item(experimental_items[i], { description = new_description })
end
