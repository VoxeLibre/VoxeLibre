--MESECON TORCHES

local rotate_torch_rules = function (rules, param2)
	if param2 == 5 then
		return mesecon:rotate_rules_right(rules)
	elseif param2 == 2 then
		return mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules)) --180 degrees
	elseif param2 == 4 then
		return mesecon:rotate_rules_left(rules)
	elseif param2 == 1 then
		return mesecon:rotate_rules_down(rules)
	elseif param2 == 0 then
		return mesecon:rotate_rules_up(rules)
	else
		return rules
	end
end

local torch_get_output_rules = function(node)
	local rules = {
		{x = 1,  y = 0, z = 0},
		{x = 0,  y = 0, z = 1},
		{x = 0,  y = 0, z =-1},
		{x = 0,  y = 1, z = 0},
		{x = 0,  y =-1, z = 0}}

	return rotate_torch_rules(rules, node.param2)
end

local torch_get_input_rules = function(node)
	local rules = 	{{x = -2, y = 0, z = 0},
				 {x = -1, y = 1, z = 0}}

	return rotate_torch_rules(rules, node.param2)
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
	{dig_immediate=3, dig_by_water=1, not_in_creative_inventory=1},
	mcl_sounds.node_sound_wood_defaults(),
	{
		mesecons = {receptor = {
			state = mesecon.state.off,
			rules = torch_get_output_rules
		}},
		drop = "mesecons_torch:mesecon_torch_on",
		_doc_items_create_entry = false,
	}
)

mcl_torches.register_torch("mesecon_torch_on", "Redstone Torch",
	"Redstone torches are redstone components which invert the signal of surrounding redstone components. An active component will become inactive, and an inactive component will become active. Redstone torches can be used as a quick and easy way to send a redstone to a redstone trail.",
	[[Redstone torches can generally be placed at the side and on the top of full solid opaque blocks. The following exceptions apply:
• Glass, fence, wall, hopper: Can only be placed on top
• Upside-down slab/stair: Can only be placed on top
• Soul sand, monster spawner: Placement possible
• Glowstone and pistons: No placement possible]],
	"jeija_torches_on.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_on.png"},
	7,
	{dig_immediate=3, dig_by_water=1,},
	mcl_sounds.node_sound_wood_defaults(),
	{
		mesecons = {receptor = {
			state = mesecon.state.on,
			rules = torch_get_output_rules
		}}
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
		rules = {
			{x = 1,  y = 0, z = 0},
			{x = -1,  y = 0, z = 0},
			{x = 0,  y = 0, z = 1},
			{x = 0,  y = 0, z =-1},
			{x = 0,  y = 1, z = 0},
			{x = 0,  y =-1, z = 0}
		}
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

minetest.register_abm({
	label = "Redstone torch inversion",
	nodenames = {"mesecons_torch:mesecon_torch_off","mesecons_torch:mesecon_torch_off_wall","mesecons_torch:mesecon_torch_on","mesecons_torch:mesecon_torch_on_wall"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local is_powered = false
		for _, rule in ipairs(torch_get_input_rules(node)) do
			local src = mesecon:addPosRule(pos, rule)
			if mesecon:is_power_on(src) then
				is_powered = true
			end
		end

		if is_powered then
			if node.name == "mesecons_torch:mesecon_torch_on" then
				mesecon:swap_node(pos, "mesecons_torch:mesecon_torch_off")
				mesecon:receptor_off(pos, torch_get_output_rules(node))
			elseif node.name == "mesecons_torch:mesecon_torch_on_wall" then
				mesecon:swap_node(pos, "mesecons_torch:mesecon_torch_off_wall")
				mesecon:receptor_off(pos, torch_get_output_rules(node))
			end
		elseif node.name == "mesecons_torch:mesecon_torch_off" then
			mesecon:swap_node(pos, "mesecons_torch:mesecon_torch_on")
			mesecon:receptor_on(pos, torch_get_output_rules(node))
		elseif node.name == "mesecons_torch:mesecon_torch_off_wall" then
			mesecon:swap_node(pos, "mesecons_torch:mesecon_torch_on_wall")
			mesecon:receptor_on(pos, torch_get_output_rules(node))
		end
	end
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_torch:mesecon_torch_on", "nodes", "mesecons_torch:mesecon_torch_off")
	doc.add_entry_alias("nodes", "mesecons_torch:mesecon_torch_on", "nodes", "mesecons_torch:mesecon_torch_off_wall")
end
