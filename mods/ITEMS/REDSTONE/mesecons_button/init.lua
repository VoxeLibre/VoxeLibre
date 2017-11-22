-- WALL BUTTON
-- A button that when pressed emits power for 1 second
-- and then turns off again

-- FIXME: Power node behind as well
local button_get_output_rules = function(node)
	local rules = mesecon.rules.alldirs
	return rules
end

local boxes_off = {
	type = "wallmounted",
	wall_side = { -8/16, -2/16, -4/16, -6/16, 2/16, 4/16 },
	wall_bottom = { -4/16, -8/16, -2/16, 4/16, -6/16, 2/16 },
	wall_top = { -4/16, 6/16, -2/16, 4/16, 8/16, 2/16 },
}
local boxes_on = {
	type = "wallmounted",
	wall_side = { -8/16, -2/16, -4/16, -7/16, 2/16, 4/16 },
	wall_bottom = { -4/16, -8/16, -2/16, 4/16, -7/16, 2/16 },
	wall_top = { -4/16, 7/16, -2/16, 4/16, 8/16, 2/16 },
}

local on_button_place = function(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		-- no interaction possible with entities
		return itemstack
	end

	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local def = minetest.registered_nodes[node.name]
	if not def then return end
	local groups = def.groups

	-- Check special rightclick action of pointed node
	if def and def.on_rightclick then
		if not placer:get_player_control().sneak then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack, false
		end
	end

	-- If the pointed node is buildable, let's look at the node *behind* that node
	if def.buildable_to then
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		local actual = vector.subtract(under, dir)
		local actualnode = minetest.get_node(actual)
		def = minetest.registered_nodes[actualnode.name]
		groups = def.groups
	end

	-- Only allow placement on full-cube solid opaque nodes
	if (not groups) or (not groups.solid) or (not groups.opaque) or (def.node_box and def.node_box.type ~= "regular") then
		return itemstack
	end

	local above = pointed_thing.above

	local idef = itemstack:get_definition()
	local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

	if success then
		if idef.sounds and idef.sounds.place then
			minetest.sound_play(idef.sounds.place, {pos=above, gain=1})
		end
	end
	return itemstack
end

local buttonuse = "Rightclick the button to push it."

mesecon.register_button = function(basename, description, texture, recipeitem, sounds, plusgroups, button_timer, longdesc)
	local groups_off = table.copy(plusgroups)
	groups_off.attached_node=1
	groups_off.dig_by_water=1
	groups_off.destroy_by_lava_flow=1
	groups_off.dig_by_piston=1
	groups_off.button=1 -- button (off)

	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory=1
	groups_on.button=2 -- button (on)

	minetest.register_node("mesecons_button:button_"..basename.."_off", {
		drawtype = "nodebox",
		tiles = {texture},
		wield_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		-- FIXME: Use proper 3D inventory image
		inventory_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		wield_scale = { x=1, y=1, z=1},
		paramtype = "light",
		paramtype2 = "wallmounted",
		is_ground_content = false,
		walkable = false,
		sunlight_propagates = true,
		node_box = boxes_off,
		groups = groups_off,
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = buttonuse,
		on_place = on_button_place,
		node_placement_prediction = "",
		on_rightclick = function (pos, node)
			minetest.swap_node(pos, {name="mesecons_button:button_"..basename.."_on", param2=node.param2})
			mesecon.receptor_on(pos, button_get_output_rules(node))
			minetest.sound_play("mesecons_button_push", {pos=pos})
			local button_turnoff = function(a)
				local pos = a.pos
				local node = minetest.get_node(pos)
				local basename = a.basename
				if node.name=="mesecons_button:button_"..basename.."_on" then --has not been dug
					minetest.swap_node(pos, {name="mesecons_button:button_"..basename.."_off",param2=node.param2})
					minetest.sound_play("mesecons_button_pop", {pos=pos})
					mesecon.receptor_off(pos, button_get_output_rules(node))
				end
			end
			minetest.after(button_timer, button_turnoff, {pos=pos, basename=basename})
		end,
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.off,
			rules = button_get_output_rules,
		}},
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_node("mesecons_button:button_"..basename.."_on", {
		drawtype = "nodebox",
		tiles = {texture},
		wield_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		inventory_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		wield_scale = { x=1, y=1, z=0.5},
		paramtype = "light",
		paramtype2 = "wallmounted",
		is_ground_content = false,
		walkable = false,
		sunlight_propagates = true,
		node_box = boxes_on,
		groups = groups_on,
		drop = 'mesecons_button:button_'..basename..'_off',
		_doc_items_create_entry = false,
		node_placement_prediction = "",
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.on,
			rules = button_get_output_rules
		}},
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_craft({
		output = "mesecons_button:button_"..basename.."_off",
		recipe = {{ recipeitem }},
	})
end

mesecon.register_button(
	"stone",
	"Stone Button",
	"default_stone.png",
	"mcl_core:stone",
	mcl_sounds.node_sound_stone_defaults(),
	{material_stone=1,handy=1,pickaxey=1},
	1,
	"A stone button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second. It can only be placed on solid opaque full cubes (like cobblestone).")

local woods = {
	{ "wood", "mcl_core:wood", "default_wood.png", "Oak Button" },
	{ "acaciawood", "mcl_core:acaciawood", "default_acacia_wood.png", "Acacia Button" },
	{ "birchwood", "mcl_core:birchwood", "mcl_core_planks_birch.png", "Birch Button" },
	{ "darkwood", "mcl_core:darkwood", "mcl_core_planks_big_oak.png", "Dark Oak Button" },
	{ "sprucewood", "mcl_core:sprucewood", "mcl_core_planks_spruce.png", "Spruce Button" },
	{ "junglewood", "mcl_core:junglewood", "default_junglewood.png", "Jungle Button" },
}

for w=1, #woods do
	mesecon.register_button(
		woods[w][1],
		woods[w][4],
		woods[w][3],
		woods[w][2],
		mcl_sounds.node_sound_wood_defaults(),
		{material_wood=1,handy=1,axey=1},
		1.5,
		"A wooden button is a redstone component made out of wood which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1.5 seconds. It can only be placed on solid opaque full cubes (like cobblestone).")

	minetest.register_craft({
		type = "fuel",
		recipe = "mesecons_button:button_"..woods[w][1].."_off",
		burntime = 5,
	})
end

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_button:button_wood_off", "nodes", "mesecons_button:button_wood_on")
	doc.add_entry_alias("nodes", "mesecons_button:button_stone_off", "nodes", "mesecons_button:button_stone_on")
end
