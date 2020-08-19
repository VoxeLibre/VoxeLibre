-- REDSTONE TORCH AND BLOCK OF REDSTONE

local S = minetest.get_translator("mesecons_torch")

local TORCH_COOLOFF = 120 -- Number of seconds it takes for a burned-out torch to reactivate

local rotate_torch_rules = function (rules, param2)
	if param2 == 1 then
		return rules
	elseif param2 == 5 then
		return mesecon.rotate_rules_right(rules)
	elseif param2 == 2 then
		return mesecon.rotate_rules_right(mesecon.rotate_rules_right(rules)) --180 degrees
	elseif param2 == 4 then
		return mesecon.rotate_rules_left(rules)
	elseif param2 == 0 then
		return rules
	else
		return rules
	end
end

local torch_get_output_rules = function(node)
	if node.param2 == 1 then
		return {
			{ x = -1, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0, spread = true },
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
		}
	else
		return rotate_torch_rules({
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x =  0, y =  1, z =  0, spread = true },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
		}, node.param2)
	end
end

local torch_get_input_rules = function(node)
	if node.param2 == 1 then
		return {{x = 0, y = -1, z = 0 }}
	else
		return rotate_torch_rules({{ x = -1, y = 0, z = 0 }}, node.param2)
	end
end

local torch_overheated = function(pos)
	minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.02, max_hear_distance = 6}, true)
	minetest.add_particle({
		pos = {x=pos.x, y=pos.y+0.2, z=pos.z},
		velocity = {x = 0, y = 0.6, z = 0},
		expirationtime = 1.2,
		size = 1.5,
		texture = "mcl_particles_smoke.png",
	})
	local timer = minetest.get_node_timer(pos)
	timer:start(TORCH_COOLOFF)
end

local torch_action_on = function(pos, node)
	local overheat
	if node.name == "mesecons_torch:mesecon_torch_on" then
		overheat = mesecon.do_overheat(pos)
		if overheat then
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_overheated", param2=node.param2})
		else
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_off", param2=node.param2})
		end
		mesecon.receptor_off(pos, torch_get_output_rules(node))
	elseif node.name == "mesecons_torch:mesecon_torch_on_wall" then
		overheat = mesecon.do_overheat(pos)
		if overheat then
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_overheated_wall", param2=node.param2})
		else
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_off_wall", param2=node.param2})
		end
		mesecon.receptor_off(pos, torch_get_output_rules(node))
	end
	if overheat then
		torch_overheated(pos)
	end
end

local torch_action_off = function(pos, node)
	local overheat
	if node.name == "mesecons_torch:mesecon_torch_off" or node.name == "mesecons_torch:mesecon_torch_overheated" then
		overheat = mesecon.do_overheat(pos)
		if overheat then
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_overheated", param2=node.param2})
		else
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_on", param2=node.param2})
			mesecon.receptor_on(pos, torch_get_output_rules(node))
		end
	elseif node.name == "mesecons_torch:mesecon_torch_off_wall" or node.name == "mesecons_torch:mesecon_torch_overheated_wall" then
		overheat = mesecon.do_overheat(pos)
		if overheat then
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_overheated_wall", param2=node.param2})
		else
			minetest.swap_node(pos, {name="mesecons_torch:mesecon_torch_on_wall", param2=node.param2})
			mesecon.receptor_on(pos, torch_get_output_rules(node))
		end
	end
	if overheat then
		torch_overheated(pos)
	end
end

minetest.register_craft({
	output = 'mesecons_torch:mesecon_torch_on',
	recipe = {
	{"mesecons:redstone"},
	{"mcl_core:stick"},}
})

mcl_torches.register_torch("mesecon_torch_off", S("Redstone Torch (off)"),
	nil,
	nil,
	"jeija_torches_off.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_off.png"},
	0,
	{dig_immediate=3, dig_by_water=1, redstone_torch=2, mesecon_ignore_opaque_dig=1, not_in_creative_inventory=1},
	mcl_sounds.node_sound_wood_defaults(),
	{
		mesecons = {
			receptor = {
				state = mesecon.state.off,
				rules = torch_get_output_rules,
			},
			effector = {
				state = mesecon.state.on,
				rules = torch_get_input_rules,
				action_off = torch_action_off,
			},
		},
		drop = "mesecons_torch:mesecon_torch_on",
		_doc_items_create_entry = false,
	}
)

mcl_torches.register_torch("mesecon_torch_overheated", S("Redstone Torch (overheated)"),
	nil,
	nil,
	"jeija_torches_off.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_off.png"},
	0,
	{dig_immediate=3, dig_by_water=1, redstone_torch=2, mesecon_ignore_opaque_dig=1, not_in_creative_inventory=1},
	mcl_sounds.node_sound_wood_defaults(),
	{
		drop = "mesecons_torch:mesecon_torch_on",
		_doc_items_create_entry = false,
		on_timer = function(pos, elapsed)
			if not mesecon.is_powered(pos) then
				local node = minetest.get_node(pos)
				torch_action_off(pos, node)
			end
		end,
	}
)



mcl_torches.register_torch("mesecon_torch_on", S("Redstone Torch"),
	S("A redstone torch is a redstone component which can be used to invert a redstone signal. It supplies its surrounding blocks with redstone power, except for the block it is attached to. A redstone torch is normally lit, but it can also be turned off by powering the block it is attached to. While unlit, a redstone torch does not power anything."),
	S("Redstone torches can be placed at the side and on the top of full solid opaque blocks."),
	"jeija_torches_on.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_on.png"},
	7,
	{dig_immediate=3, dig_by_water=1, redstone_torch=1, mesecon_ignore_opaque_dig=1},
	mcl_sounds.node_sound_wood_defaults(),
	{
		on_destruct = function(pos, oldnode)
			local node = minetest.get_node(pos)
			torch_action_on(pos, node)
		end,
		mesecons = {
			receptor = {
				state = mesecon.state.on,
				rules = torch_get_output_rules
			},
			effector = {
				state = mesecon.state.off,
				rules = torch_get_input_rules,
				action_on = torch_action_on,
			},
		},
		_tt_help = S("Provides redstone power when it's not powered itself"),
	}
)

minetest.register_node("mesecons_torch:redstoneblock", {
	description = S("Block of Redstone"),
	_tt_help = S("Provides redstone power"),
	_doc_items_longdesc = S("A block of redstone permanently supplies redstone power to its surrounding blocks."),
	tiles = {"redstone_redstone_block.png"},
	stack_max = 64,
	groups = {pickaxey=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_craft({
	output = "mesecons_torch:redstoneblock",
	recipe = {
		{'mesecons:wire_00000000_off','mesecons:wire_00000000_off','mesecons:wire_00000000_off'},
		{'mesecons:wire_00000000_off','mesecons:wire_00000000_off','mesecons:wire_00000000_off'},
		{'mesecons:wire_00000000_off','mesecons:wire_00000000_off','mesecons:wire_00000000_off'},
	}
})

minetest.register_craft({
	output = 'mesecons:wire_00000000_off 9',
	recipe = {
		{'mesecons_torch:redstoneblock'},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_torch:mesecon_torch_on", "nodes", "mesecons_torch:mesecon_torch_off")
	doc.add_entry_alias("nodes", "mesecons_torch:mesecon_torch_on", "nodes", "mesecons_torch:mesecon_torch_off_wall")
end
