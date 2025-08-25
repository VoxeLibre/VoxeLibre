local S = minetest.get_translator("mcl_target")

local mod_farming = minetest.get_modpath("mcl_farming")

local receptor_on  = vl_circuitry.mesecon.receptor_on
local receptor_off = vl_circuitry.mesecon.receptor_off
local all_dirs = vl_circuitry.mesecon.rules.alldirs

mcl_target = {}

function mcl_target.hit(pos, time)
	minetest.set_node(pos, {name="mcl_target:target_on"})
	receptor_on(pos, all_dirs)

	local timer = minetest.get_node_timer(pos)
	timer:start(time)
end

minetest.register_node("mcl_target:target_off", {
	description = S("Target"),
	_doc_items_longdesc = S("A target is a block that provides a temporary redstone charge when hit by a projectile."),
	_doc_items_usagehelp = S("Throw a projectile on the target to activate it."),
	tiles = {"mcl_target_target_top.png", "mcl_target_target_top.png", "mcl_target_target_side.png"},
	groups = {hoey = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	mesecons = {
		receptor = {
			state = vl_circuitry.mesecon.off_state,
			rules = vl_circuitry.mesecon.rules.alldirs,
		},
	},
	_vl_projectile = {
		on_collide = function(projectile, pos, node, node_def)
			mcl_target.hit(pos, 1) --10 redstone ticks
		end
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_target:target_on", {
	description = S("Target"),
	_doc_items_create_entry = false,
	tiles = {"mcl_target_target_top.png", "mcl_target_target_top.png", "mcl_target_target_side.png"},
	groups = {hoey = 1, not_in_creative_inventory = 1},
	drop = "mcl_target:target_off",
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "mcl_target:target_on" then --has not been dug
			minetest.set_node(pos, {name="mcl_target:target_off"})
			receptor_off(pos, all_dirs)
		end
	end,
	mesecons = {
		receptor = {
			state = vl_circuitry.mesecon.on_state,
			rules = vl_circuitry.mesecon.rules.alldirs,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})


if mod_farming then
	local rs = "mesecons:redstone"
	local hb = "mcl_farming:hay_block"
	minetest.register_craft({
		output = "mcl_target:target_off",
		recipe = {
			{"", rs, ""},
			{rs, hb, rs},
			{"", rs, ""},
		},
	})
end
