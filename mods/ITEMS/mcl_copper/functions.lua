function mcl_copper.register_oxidation_and_scraping(mod_name, subname, decay_chain)
	local item, oxidized_item

	for i = 1, #decay_chain - 1 do
		item = mod_name..":"..subname..decay_chain[i]
		oxidized_item = mod_name..":"..subname..decay_chain[i + 1]

		minetest.override_item(item, {_mcl_oxidized_variant = oxidized_item})
		minetest.override_item(oxidized_item, {_mcl_stripped_variant = item})

		if subname:find("stair") then
			minetest.override_item(item.."_inner", {_mcl_oxidized_variant = oxidized_item.."_inner"})
			minetest.override_item(item.."_outer", {_mcl_oxidized_variant = oxidized_item.."_outer"})
			minetest.override_item(oxidized_item.."_inner", {_mcl_stripped_variant = item.."_inner"})
			minetest.override_item(oxidized_item.."_outer", {_mcl_stripped_variant = item.."_outer"})
		elseif subname:find("slab") then
			minetest.override_item(item.."_double", {_mcl_oxidized_variant = oxidized_item.."_double"})
			minetest.override_item(item.."_top", {_mcl_oxidized_variant = oxidized_item.."_top"})
			minetest.override_item(oxidized_item.."_double", {_mcl_stripped_variant = item.."_double"})
			minetest.override_item(oxidized_item.."_top", {_mcl_stripped_variant = item.."_top"})
		end
	end
end

function mcl_copper.register_waxing_and_scraping(mod_name, subname, decay_chain)
	local waxed_item, unwaxed_item

	for i = 1, #decay_chain do
		waxed_item = mod_name..":"..subname..decay_chain[i]
		unwaxed_item = mod_name..":"..subname:gsub("waxed_", "")..decay_chain[i]

		minetest.override_item(waxed_item, {_mcl_stripped_variant = unwaxed_item})
		minetest.override_item(unwaxed_item, {_mcl_waxed_variant = waxed_item})

		if subname:find("stair") then
			minetest.override_item(waxed_item.."_inner", {_mcl_stripped_variant = unwaxed_item.."_inner"})
			minetest.override_item(waxed_item.."_outer", {_mcl_stripped_variant = unwaxed_item.."_outer"})
			minetest.override_item(unwaxed_item.."_inner", {_mcl_waxed_variant = waxed_item.."_inner"})
			minetest.override_item(unwaxed_item.."_outer", {_mcl_waxed_variant = waxed_item.."_outer"})
		elseif subname:find("slab") then
			minetest.override_item(waxed_item.."_double", {_mcl_stripped_variant = unwaxed_item.."_double"})
			minetest.override_item(waxed_item.."_top", {_mcl_stripped_variant = unwaxed_item.."_top"})
			minetest.override_item(unwaxed_item.."_double", {_mcl_waxed_variant = waxed_item.."_double"})
			minetest.override_item(unwaxed_item.."_top", {_mcl_waxed_variant = waxed_item.."_top"})
		end
	end
end

local cut_decay_chain = {
	"_cut",
	"_exposed_cut",
	"_weathered_cut",
	"_oxidized_cut"
}
local trapdoor_decay_chain = {
	"",
	"_exposed",
	"_weathered",
	"_oxidized"
}
local waxed_trapdoor_decay_chain = {
	"",
	"_exposed",
	"_weathered",
	"_oxidized"
}

mcl_copper.register_oxidation_and_scraping("mcl_stairs", "stair_copper", cut_decay_chain)
mcl_copper.register_oxidation_and_scraping("mcl_stairs", "slab_copper", cut_decay_chain)
mcl_copper.register_oxidation_and_scraping("mcl_copper", "trapdoor", trapdoor_decay_chain)
mcl_copper.register_waxing_and_scraping("mcl_stairs", "stair_waxed_copper", cut_decay_chain)
mcl_copper.register_waxing_and_scraping("mcl_stairs", "slab_waxed_copper", cut_decay_chain)
mcl_copper.register_waxing_and_scraping("mcl_copper", "waxed_trapdoor", waxed_trapdoor_decay_chain)
