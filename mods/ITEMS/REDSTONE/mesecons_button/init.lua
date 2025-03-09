-- WALL BUTTON
-- A button that when pressed emits power for a short moment and then turns off again

local S = minetest.get_translator(minetest.get_current_modname())

local button_sounds = {} -- remember button push sounds

local button_get_output_rules = mesecon.rules.wallmounted_get

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

-- Push the button
function mesecon.push_button(pos, node)
	-- No-op if button is already pushed
	if mesecon.is_receptor_on(node) then
		return
	end
	local def = minetest.registered_nodes[node.name]
	minetest.set_node(pos, {name="mesecons_button:button_"..def._mcl_button_basename.."_on", param2=node.param2})
	mesecon.receptor_on(pos, button_get_output_rules(node))
	local sfx = button_sounds[node.name]
	if sfx then
		minetest.sound_play(sfx, {pos=pos}, true)
	end
	local timer = minetest.get_node_timer(pos)
	timer:start(def._mcl_button_timer)
end

vl_attach.set_default("button",function(node, def, wdir)
	-- No ceiling buttons
	if wdir == 0 then return false end

	-- Allow solid, opaque, full cube collision box nodes are allowed.
	if def.groups.solid and def.groups.opaque then return true end
end)
vl_attach.register_autogroup({
	skip_existing = {"button"},
	callback = function(allow_attach, _, def)
		local groups = def.groups
		if not groups then return end

		-- Only allow full-solid blocks to have buttons attached
		if groups.solid and groups.opaque and (def.node_box and def.node_box.type ~= "regular") then
			allow_attach.button = true
		end

		-- Exception: allow placing on top of top-slabs
		if groups.slab_top then
			allow_attach.button = true
		end
	end
})

local buttonuse = S("Use the button to push it.")

function mesecon.register_button(basename, description, texture, recipeitem, sounds, plusgroups, button_timer, push_by_arrow, longdesc, button_sound)
	local groups_off = table.copy(plusgroups)
	groups_off.attached_node=1
	groups_off.dig_by_water=1
	groups_off.destroy_by_lava_flow=1
	groups_off.dig_by_piston=1
	groups_off.dig_immediate_piston=1
	groups_off.button=1 -- button (off)
	groups_off.vl_attach = 1

	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory=1
	groups_on.button=2 -- button (on)
	groups_on.vl_attach = 1

	if not button_sound then
		button_sound = "mesecons_button_push"
	end
	button_sounds["mesecons_button:button_"..basename.."_off"] = button_sound

	if not longdesc then
		if groups_off.material_wood ~= 0 then
			longdesc = S("A wooden button is a redstone component made out of wood which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1.5 seconds. Wooden buttons may also be pushed by arrows.")
		else
			longdesc = S("A button is a redstone component which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for @1 seconds.", button_timer)
		end
	end

	if push_by_arrow then
		groups_off.button_push_by_arrow = 1
		groups_on.button_push_by_arrow = 1
	end
	local tt = S("Provides redstone power when pushed")
	tt = tt .. "\n" .. S("Push duration: @1s", string.format("%.1f", button_timer))
	if push_by_arrow then
		tt = tt .. "\n" .. S("Pushable by arrow")
	end
	minetest.register_node(":mesecons_button:button_"..basename.."_off", {
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
		_tt_help = tt,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = buttonuse,
		_vl_attach_type = "button",
		on_place = vl_attach.place_attached,
		node_placement_prediction = "",
		on_rightclick = function(pos, node)
			mesecon.push_button(pos, node)
		end,
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.off,
			rules = button_get_output_rules,
		}},
		_mcl_button_basename = basename,
		_mcl_button_timer = button_timer,
		_vl_projectile = {
			on_collide = function(projectile, pos, node, node_def)
				pos = vector.round(pos)

				-- Push the button! Push, push, push the button!
				if node_def.groups.button_push_by_arrow == 1 then
					mesecon.push_button(pos, node)
				end
			end
		},

		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_node(":mesecons_button:button_"..basename.."_on", {
		drawtype = "nodebox",
		tiles = {texture},
		wield_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		wield_scale = { x=1, y=1, z=0.5},
		paramtype = "light",
		paramtype2 = "wallmounted",
		is_ground_content = false,
		walkable = false,
		sunlight_propagates = true,
		node_box = boxes_on,
		groups = groups_on,
		drop = "mesecons_button:button_"..basename.."_off",
		_doc_items_create_entry = false,
		node_placement_prediction = "",
		sounds = sounds,
		mesecons = {receptor = {
			state = mesecon.state.on,
			rules = button_get_output_rules
		}},
		_mcl_button_basename = basename,
		_mcl_button_timer = button_timer,
		on_timer = function(pos, elapsed)
			local node = minetest.get_node(pos)
			if node.name=="mesecons_button:button_"..basename.."_on" then --has not been dug
				-- Is button pushable by arrow?
				if push_by_arrow then
					-- If there's an arrow stuck in the button, keep it pressed and check
					-- it again later.
					local objs = minetest.get_objects_inside_radius(pos, 1)
					for o=1, #objs do
						local entity = objs[o]:get_luaentity()
						if entity and entity.name == "mcl_bows:arrow_entity" then
							local timer = minetest.get_node_timer(pos)
							timer:start(button_timer)
							return
						end
					end
				end

				-- Normal operation: Un-press the button
				minetest.set_node(pos, {name="mesecons_button:button_"..basename.."_off",param2=node.param2})
				minetest.sound_play(button_sound, {pos=pos, pitch=0.9}, true)
				mesecon.receptor_off(pos, button_get_output_rules(node))
			end
		end,

		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_craft({
		output = "mesecons_button:button_"..basename.."_off",
		recipe = {{ recipeitem }},
	})

	if minetest.get_modpath("mesecons_mvps") then
		mesecon.register_mvps_unsticky("mesecons_button:button_"..basename.."_off")
		mesecon.register_mvps_unsticky("mesecons_button:button_"..basename.."_on")
	end
end

mesecon.register_button(
	"stone",
	S("Stone Button"),
	"default_stone.png",
	"mcl_core:stone",
	mcl_sounds.node_sound_stone_defaults(),
	{material_stone=1,handy=1,pickaxey=1},
	1,
	false,
	S("A stone button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	"mesecons_button_push")

mesecon.register_button(
	"polished_blackstone",
	S("Polished Blackstone Button"),
	"mcl_blackstone_polished.png",
	"mcl_blackstone:blackstone_polished",
	mcl_sounds.node_sound_stone_defaults(),
	{material_stone=1,handy=1,pickaxey=1},
	1,
	false,
	S("A polished blackstone button is a redstone component made out of polished blackstone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	"mesecons_button_push")

local woods = {
	{ "wood", "mcl_core:wood", "default_wood.png", S("Oak Button") },
	{ "acaciawood", "mcl_core:acaciawood", "default_acacia_wood.png", S("Acacia Button") },
	{ "birchwood", "mcl_core:birchwood", "mcl_core_planks_birch.png", S("Birch Button") },
	{ "darkwood", "mcl_core:darkwood", "mcl_core_planks_big_oak.png", S("Dark Oak Button") },
	{ "sprucewood", "mcl_core:sprucewood", "mcl_core_planks_spruce.png", S("Spruce Button") },
	{ "junglewood", "mcl_core:junglewood", "default_junglewood.png", S("Jungle Button") },

	{ "mangrove_wood", "mcl_mangrove:mangrove_wood", "mcl_mangrove_planks.png", S("Mangrove Button") },
	{ "crimson_hyphae_wood", "mcl_crimson:crimson_hyphae_wood", "mcl_crimson_crimson_hyphae_wood.png", S("Crimson Button") },
	{ "warped_hyphae_wood", "mcl_crimson:warped_hyphae_wood", "mcl_crimson_warped_hyphae_wood.png", S("Warped Button") },
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
		true,
		nil,
		"mesecons_button_push_wood")

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
