local deepslate_mod = minetest.get_modpath("mcl_deepslate")
local function register_oxidation_abm(abm_name, node_name, oxidized_variant)
	minetest.register_abm({
		label = abm_name,
		nodenames = {node_name},
		interval = 500,
		chance = 3,
		action = function(pos, node)
			minetest.swap_node(pos, {name=oxidized_variant, param2=node.param2})
		end
	})
end

local stairs = {
	{"stair", "exposed", "_inner", "cut_inner"},
	{"stair", "weathered", "_inner", "exposed_cut_inner"},
	{"stair", "exposed", "_outer", "cut_outer"},
	{"stair", "weathered", "_outer", "exposed_cut_outer"},
	{"stair", "oxidized", "_outer", "weathered_cut_outer"},
	{"stair", "oxidized", "_inner", "weathered_cut_inner"},
	{"slab", "exposed", "","cut"},
	{"slab", "oxidized", "","weathered_cut"},
	{"slab", "weathered", "","exposed_cut"},
	{"slab", "exposed", "_top","cut_top"},
	{"slab", "oxidized", "_top", "weathered_cut_top"},
	{"slab", "weathered", "_top","exposed_cut_top"},
	{"slab", "exposed", "_double","cut_double"},
	{"slab", "oxidized", "_double","weathered_cut_double"},
	{"slab", "weathered", "_double","exposed_cut_double"},
	{"stair", "exposed", "","cut"},
	{"stair", "oxidized", "", "weathered_cut"},
	{"stair", "weathered", "", "exposed_cut"}
}

local function anti_oxidation_particles(pointed_thing)
	local pos = pointed_thing.under
	minetest.add_particlespawner({
		amount = 8,
		time = 1,
		minpos = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
		maxpos = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
		minvel = {x = 0, y = 0, z = 0},
		maxvel = {x = 0, y = 0, z = 0},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 1,
		maxsize = 2.5,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_copper_anti_oxidation_particle.png",
		glow = 5,
	})
end

local function add_wear(placer, itemstack)
	if not minetest.is_creative_enabled(placer:get_player_name()) then
		local tool = itemstack:get_name()
		local wear = mcl_autogroup.get_wear(tool, "axey")
		itemstack:add_wear(wear)
	end
end

local function anti_oxidation(itemstack, placer, pointed_thing)
    if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
    local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

    if not placer:get_player_control().sneak and noddef.on_rightclick then
        return minetest.item_place(itemstack, placer, pointed_thing)
    end

    if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
        minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
        return itemstack
    end

    if noddef._mcl_stripped_variant == nil then
		for _, c in pairs(stairs) do
			if noddef.name == "mcl_stairs:"..c[1].."_copper_"..c[2].."_cut"..c[3] then
				minetest.swap_node(pointed_thing.under, {name="mcl_stairs:"..c[1].."_copper_"..c[4], param2=node.param2})
				anti_oxidation_particles(pointed_thing)
				add_wear(placer, itemstack)
			end
		end
		if noddef._mcl_anti_oxidation_variant ~= nil then
			minetest.swap_node(pointed_thing.under, {name=noddef._mcl_anti_oxidation_variant, param2=node.param2})
			anti_oxidation_particles(pointed_thing)
			add_wear(placer, itemstack)
		end
	elseif noddef._mcl_stripped_variant ~= nil then
		minetest.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
		add_wear(placer, itemstack)
	else
		return itemstack
	end
    return itemstack
end

local function register_axe_override(axe_name)
	minetest.override_item("mcl_tools:axe_"..axe_name, {
		on_place = anti_oxidation,
	})
end

local stonelike = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite"}
if not deepslate_mod then
	if minetest.settings:get_bool("mcl_generate_ores", true) then
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 830,
			clust_num_ores = 5,
			clust_size     = 3,
			y_min          = mcl_vars.mg_overworld_min,
			y_max          = mcl_worlds.layer_to_y(39),
		})
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 1660,
			clust_num_ores = 4,
			clust_size     = 2,
			y_min          = mcl_worlds.layer_to_y(40),
			y_max          = mcl_worlds.layer_to_y(63),
		})
	end
end

local block_oxidation = {
	{"", "_exposed"},
	{"_cut", "_exposed_cut"},
	{"_exposed", "_weathered"},
	{"_exposed_cut", "_weathered_cut"},
	{"_weathered", "_oxidized"},
	{"_weathered_cut", "_oxidized_cut"}
}

local stair_oxidation = {
	{"slab", "cut", "exposed_cut"},
	{"slab", "exposed_cut", "weathered_cut"},
	{"slab", "weathered_cut", "oxidized_cut"},
	{"slab", "cut_top", "exposed_cut_top"},
	{"slab", "exposed_cut_top", "weathered_cut_top"},
	{"slab", "weathered_cut_top", "oxidized_cut_double"},
	{"slab", "cut_double", "exposed_cut_double"},
	{"slab", "exposed_cut_double", "weathered_cut_double"},
	{"slab", "weathered_cut_double", "oxidized_cut_double"},
	{"stair", "cut", "exposed_cut"},
	{"stair", "exposed_cut", "weathered_cut"},
	{"stair", "weathered_cut", "oxidized_cut"},
	{"stair", "cut_inner", "exposed_cut_inner"},
	{"stair", "exposed_cut_inner", "weathered_cut_inner"},
	{"stair", "weathered_cut_inner", "oxidized_cut_inner"},
	{"stair", "cut_outer", "exposed_cut_outer"},
	{"stair", "exposed_cut_outer", "weathered_cut_outer"},
	{"stair", "weathered_cut_outer", "oxidized_cut_outer"}
}

for _, b in pairs(block_oxidation) do
	register_oxidation_abm("Copper oxidation", "mcl_copper:block"..b[1], "mcl_copper:block"..b[2])
end

for _, s in pairs(stair_oxidation) do
	register_oxidation_abm("Copper oxidation", "mcl_stairs:"..s[1].."_copper_"..s[2], "mcl_stairs:"..s[1].."_copper_"..s[3])
end
local axes = {"wood", "stone", "iron", "gold", "diamond"}
--[[
for _, axe in pairs(axes) do
	register_axe_override(axe)
end
]]
