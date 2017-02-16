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

mcl_torches.register_torch("mesecon_torch_off", "Mesecon Torch (off)", "jeija_torches_off.png",
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
	}
)

mcl_torches.register_torch("mesecon_torch_on", "Mesecon Torch", "jeija_torches_on_inv.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{"jeija_torches_on.png"},
	7,
	{dig_immediate=3, dig_by_water=1},
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
	tiles = {"redstone_redstone_block.png"},
	stack_max = 64,
	groups = {cracky=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = torch_get_output_rules
	}},
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

-- Param2 Table (Block Attached To)
-- 5 = z-1
-- 3 = x-1
-- 4 = z+1
-- 2 = x+1
-- 0 = y+1
-- 1 = y-1
