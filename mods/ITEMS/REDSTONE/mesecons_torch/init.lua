--MESECON TORCHES

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

local torch_action_on = function(pos, node)
	if node.name == "mesecons_torch:mesecon_torch_on" then
		minetest.set_node(pos, {name="mesecons_torch:mesecon_torch_off", param2=node.param2})
		mesecon.receptor_off(pos, torch_get_output_rules(node))
	elseif node.name == "mesecons_torch:mesecon_torch_on_wall" then
		minetest.set_node(pos, {name="mesecons_torch:mesecon_torch_off_wall", param2=node.param2})
		mesecon.receptor_off(pos, torch_get_output_rules(node))
	end
end

local torch_action_off = function(pos, node)
	if node.name == "mesecons_torch:mesecon_torch_off" then
		minetest.set_node(pos, {name="mesecons_torch:mesecon_torch_on", param2=node.param2})
		mesecon.receptor_on(pos, torch_get_output_rules(node))
	elseif node.name == "mesecons_torch:mesecon_torch_off_wall" then
		minetest.set_node(pos, {name="mesecons_torch:mesecon_torch_on_wall", param2=node.param2})
		mesecon.receptor_on(pos, torch_get_output_rules(node))
	end
end

minetest.register_craft({
	output = 'mesecons_torch:mesecon_torch_on',
	recipe = {
	{"mesecons:redstone"},
	{"mcl_core:stick"},}
})

mcl_torches.register_torch("mesecon_torch_off", "Redstone Torch (off)",
	nil,
	nil,
	"jeija_torches_off.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_off.png"},
	0,
	{dig_immediate=3, dig_by_water=1, redstone_torch=2, not_in_creative_inventory=1},
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

mcl_torches.register_torch("mesecon_torch_on", "Redstone Torch",
	"Redstone torches are redstone components which invert the signal of surrounding redstone components. An active component will become inactive, and an inactive component will become active. Redstone torches can be used as a quick and easy way to send a redstone to a redstone trail.",
	[[Redstone torches can generally be placed at the side and on the top of full solid opaque blocks. The following exceptions apply:
• Glass, fence, wall, hopper: Can only be placed on top
• Upside-down slab/stair: Can only be placed on top
• Soul sand, mob spawner: Placement possible
• Glowstone and pistons: No placement possible]],
	"jeija_torches_on.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_on.png"},
	7,
	{dig_immediate=3, dig_by_water=1, redstone_torch=1},
	mcl_sounds.node_sound_wood_defaults(),
	{
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
		}
	}
)

minetest.register_node("mesecons_torch:redstoneblock", {
	description = "Block of Redstone",
	_doc_items_longdesc = "A block of redstone permanently supplies redstone power to its surrounding blocks.",
	tiles = {"redstone_redstone_block.png"},
	stack_max = 64,
	groups = {pickaxey=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 30,
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
