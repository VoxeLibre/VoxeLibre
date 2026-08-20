--[[ This mod registers 3 nodes:
- One node for the horizontal-facing dispensers (mcl_dispensers:dispenser)
- One node for the upwards-facing dispensers (mcl_dispenser:dispenser_up)
- One node for the downwards-facing dispensers (mcl_dispenser:dispenser_down)

3 node definitions are needed because of the way the textures are defined.
All node definitions share a lot of code, so this is the reason why there
are so many weird tables below.
]]
local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

---@class core.LuaEntity
---@field _shot_from_dispenser? boolean

-- TODO: actually should have a slight lag as in MC?
local COOLDOWN = 0.19

local dispenser_formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[4.125,0.375;" .. F(C(mcl_formspec.label_color, S("Dispenser"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(4.125, 0.75, 3, 3),
	"list[context;main;4.125,0.75;3,3;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[context;main]",
	"listring[current_player;main]",
})

---For after_place_node
---@param pos Vector
local function setup_dispenser(pos)
	-- Set formspec and inventory
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", dispenser_formspec)
	local inv = meta:get_inventory()
	inv:set_size("main", 9)
end

local function orientate_dispenser(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	local node = minetest.get_node(pos)
	if pitch > 55 then
		minetest.swap_node(pos, { name = "mcl_dispensers:dispenser_up", param2 = node.param2 })
	elseif pitch < -55 then
		minetest.swap_node(pos, { name = "mcl_dispensers:dispenser_down", param2 = node.param2 })
	end
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

-- Shared core definition table
local dispenserdef = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				minetest.add_item(vector.offset(pos, math.random(0, 10) / 10 - 0.5, 0, math.random(0, 10) / 10 - 0.5), stack)
			end
		end
		meta:from_table(meta2)
	end,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	mesecons = {
		effector = {
			-- Dispense random item when triggered
			action_on = function(pos, node)
				local meta = minetest.get_meta(pos)
				local gametime = core.get_gametime()
				if gametime < meta:get_float("cooldown") then return end
				meta:set_float("cooldown", gametime + COOLDOWN)
				local inv = meta:get_inventory()
				local droppos, dropdir
				if node.name == "mcl_dispensers:dispenser" then
					dropdir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
					droppos = vector.add(pos, dropdir)
				elseif node.name == "mcl_dispensers:dispenser_up" then
					dropdir = vector.new(0, 1, 0)
					droppos = vector.offset(pos, 0, 1, 0)
				elseif node.name == "mcl_dispensers:dispenser_down" then
					dropdir = vector.new(0, -1, 0)
					droppos = vector.offset(pos, 0, -1, 0)
				end
				local dropnode = minetest.get_node(droppos)
				local dropnodedef = minetest.registered_nodes[dropnode.name]
				if not dropnodedef then
					dropnodedef = minetest.registered_nodes["mapgen_stone"]
				end
				local stacks = {}
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if not stack:is_empty() then
						table.insert(stacks, { stack = stack, stackpos = i })
					end
				end
				if #stacks >= 1 then
					local r = math.random(1, #stacks)
					local stack = stacks[r].stack
					local dropitem = ItemStack(stack)
					dropitem:set_count(1)
					local stack_id = stacks[r].stackpos
					local stackdef = core.registered_items[stack:get_name()]

					if not stackdef then
						return
					end

					local iname = stack:get_name()
					local igroups = stackdef.groups

					--[===[ Dispense item ]===]

					-- Hardcoded dispensions --

					-- Armor, mob heads and pumpkins
					if igroups.armor then
						local droppos_below = vector.offset(droppos, 0, -1, 0)

						for _, objs in ipairs({ minetest.get_objects_inside_radius(droppos, 1),
							minetest.get_objects_inside_radius(droppos_below, 1) }) do
							for _, obj in ipairs(objs) do
								stack = mcl_armor.equip(stack, obj)
								if stack:is_empty() then
									break
								end
							end
							if stack:is_empty() then
								break
							end
						end

						-- Place head or pumpkin as node, if equipping it as armor has failed
						if not stack:is_empty() then
							if igroups.head or iname == "mcl_farming:pumpkin_face" then
								if dropnodedef.buildable_to then
									minetest.set_node(droppos, { name = iname, param2 = node.param2 })
									stack:take_item()
								end
							end
						end

						inv:set_stack("main", stack_id, stack)

						-- Use shears on sheeps
					elseif igroups.shears then
						for _, obj in pairs(minetest.get_objects_inside_radius(droppos, 1)) do
							local entity = obj:get_luaentity()
							if entity and not entity.child and not entity.gotten then
								local entname = entity.name
								local pos = obj:get_pos()
								local used, texture = false
								if entname == "mobs_mc:sheep" then
									if entity.drops[2] then
										minetest.add_item(pos, entity.drops[2].name .. " " .. math.random(1, 3))
									end
									if not entity.color then
										entity.color = "unicolor_white"
									end
									entity.base_texture = { "blank.png", "mobs_mc_sheep.png" }
									texture = entity.base_texture
									entity.drops = {
										{ name = "mcl_mobitems:mutton", chance = 1, min = 1, max = 2 },
									}
									used = true
								elseif entname == "mobs_mc:snowman" then
									texture = {
										"mobs_mc_snowman.png",
										"blank.png", "blank.png",
										"blank.png", "blank.png",
										"blank.png", "blank.png",
									}
									used = true
								elseif entname == "mobs_mc:mooshroom" then
									local droppos = vector.offset(pos, 0, 1.4, 0)
									if entity.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
										minetest.add_item(droppos, "mcl_mushrooms:mushroom_brown 5")
									else
										minetest.add_item(droppos, "mcl_mushrooms:mushroom_red 5")
									end
									obj = mcl_util.replace_mob(obj, "mobs_mc:cow")
									entity = obj:get_luaentity()
									used = true
								end
								if used then
									obj:set_properties({ textures = texture })
									entity.gotten = true
									minetest.sound_play("mcl_tools_shears_cut", { pos = pos }, true)
									stack:add_wear(65535 / stackdef._mcl_diggroups.shearsy.uses)
									tt.reload_itemstack_description(stack) -- update tooltip
									inv:set_stack("main", stack_id, stack)
									break
								end
							end
						end

						-- Spawn Egg
					elseif igroups.spawn_egg then
						-- Spawn mob
						if not dropnodedef.walkable then
							--pointed_thing = { above = droppos, under = { x=droppos.x, y=droppos.y-1, z=droppos.z } }
							minetest.add_entity(droppos, stack:get_name())

							stack:take_item()
							inv:set_stack("main", stack_id, stack)
						end

						-- Generalized dispension
					elseif (not dropnodedef.walkable or stackdef._dispense_into_walkable) then
						--[[ _on_dispense(stack, pos, droppos, dropnode, dropdir)
							* stack: Itemstack which is dispense
							* pos: Position of dispenser
							* droppos: Position to which to dispense item
							* dropnode: Node of droppos
							* dropdir: Drop direction

						_dispense_into_walkable: If true, can dispense into walkable nodes
						]]
						if stackdef._on_dispense then
							-- Item-specific dispension (if defined)
							local od_ret = stackdef._on_dispense(dropitem, pos, droppos, dropnode, dropdir)
							if od_ret then
								local newcount = stack:get_count() - 1
								stack:set_count(newcount)
								inv:set_stack("main", stack_id, stack)
								if newcount == 0 then
									inv:set_stack("main", stack_id, od_ret)
								elseif inv:room_for_item("main", od_ret) then
									inv:add_item("main", od_ret)
								else
									local pos_variation = 100
									local speed = 3
									local droppos = vector.add(pos, {x = 0.5, y = 0.5, z = 0.5})
									droppos = vector.add(droppos, vector.multiply(dropdir, 0.49))
									droppos = {
										x = droppos.x + math.random(-pos_variation, pos_variation) / 1000,
										y = droppos.y + math.random(-pos_variation, pos_variation) / 1000,
										z = droppos.z + math.random(-pos_variation, pos_variation) / 1000,
									}
									local item_entity = core.add_item(droppos, od_ret)
									if item_entity then
										item_entity:set_velocity(vector.multiply(dropdir, speed))
									end
								end
							else
								stack:take_item()
								inv:set_stack("main", stack_id, stack)
							end
						else
							-- Drop item otherwise
							local pos_variation = 100
							droppos = {
								x = droppos.x + math.random(-pos_variation, pos_variation) / 1000,
								y = droppos.y + math.random(-pos_variation, pos_variation) / 1000,
								z = droppos.z + math.random(-pos_variation, pos_variation) / 1000,
							}
							local item_entity = minetest.add_item(droppos, dropitem)
							local drop_vel = vector.subtract(droppos, pos)
							local speed = 3
							item_entity:set_velocity(vector.multiply(drop_vel, speed))
							stack:take_item()
							inv:set_stack("main", stack_id, stack)
						end
					end


				end
			end,
			rules = mesecon.rules.alldirs,
		},
	},
	on_rotate = on_rotate,
}

-- Horizontal dispenser

local horizontal_def = table.copy(dispenserdef)
horizontal_def.description = S("Dispenser")
horizontal_def._tt_help = S("9 inventory slots") .. "\n" .. S("Launches item when powered by redstone power")
horizontal_def._doc_items_longdesc = S("A dispenser is a block which acts as a redstone component which, when powered with redstone power, dispenses an item. It has a container with 9 inventory slots.")
horizontal_def._doc_items_usagehelp = S("Place the dispenser in one of 6 possible directions. The “hole” is where items will fly out of the dispenser. Use the dispenser to access its inventory. Insert the items you wish to dispense. Supply the dispenser with redstone energy once to dispense a random item.")
	.. "\n\n" ..

	S("The dispenser will do different things, depending on the dispensed item:") .. "\n\n" ..

	S("• Arrows: Are launched") .. "\n" ..
	S("• Eggs and snowballs: Are thrown") .. "\n" ..
	S("• Fire charges: Are fired in a straight line") .. "\n" ..
	S("• Armor: Will be equipped to players and armor stands") .. "\n" ..
	S("• Boats: Are placed on water or are dropped") .. "\n" ..
	S("• Minecart: Are placed on rails or are dropped") .. "\n" ..
	S("• Bone meal: Is applied on the block it is facing") .. "\n" ..
	S("• Empty buckets: Are used to collect a liquid source") .. "\n" ..
	S("• Filled buckets: Are used to place a liquid source") .. "\n" ..
	S("• Heads, pumpkins: Equipped to players and armor stands, or placed as a block") .. "\n" ..
	S("• Shulker boxes: Are placed as a block") .. "\n" ..
	S("• TNT: Is placed and ignited") .. "\n" ..
	S("• Flint and steel: Is used to ignite a fire in air and to ignite TNT") .. "\n" ..
	S("• Spawn eggs: Will summon the mob they contain") .. "\n" ..
	S("• Other items: Are simply dropped")

function horizontal_def.after_place_node(pos, placer, itemstack, pointed_thing)
	setup_dispenser(pos)
	orientate_dispenser(pos, placer)
end

horizontal_def.tiles = {
	"default_furnace_top.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "mcl_dispensers_dispenser_front_horizontal.png"
}
horizontal_def.paramtype2 = "facedir"
horizontal_def.groups = { pickaxey = 1, container = 2, material_stone = 1 }

minetest.register_node("mcl_dispensers:dispenser", horizontal_def)

-- Down dispenser
local down_def = table.copy(dispenserdef)
down_def.description = S("Downwards-Facing Dispenser")
down_def.after_place_node = setup_dispenser
down_def.tiles = {
	"default_furnace_top.png", "mcl_dispensers_dispenser_front_vertical.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
down_def.groups = { pickaxey = 1, container = 2, not_in_creative_inventory = 1, material_stone = 1 }
down_def._doc_items_create_entry = false
down_def.drop = "mcl_dispensers:dispenser"
minetest.register_node("mcl_dispensers:dispenser_down", down_def)

-- Up dispenser
-- The up dispenser is almost identical to the down dispenser , it only differs in textures
local up_def = table.copy(down_def)
up_def.description = S("Upwards-Facing Dispenser")
up_def.tiles = {
	"mcl_dispensers_dispenser_front_vertical.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
minetest.register_node("mcl_dispensers:dispenser_up", up_def)


minetest.register_craft({
	output = "mcl_dispensers:dispenser",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble", },
		{ "mcl_core:cobble", "mcl_bows:bow", "mcl_core:cobble", },
		{ "mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble", },
	}
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_dispensers:dispenser", "nodes", "mcl_dispensers:dispenser_down")
	doc.add_entry_alias("nodes", "mcl_dispensers:dispenser", "nodes", "mcl_dispensers:dispenser_up")
end

-- Legacy
minetest.register_lbm({
	label = "Update dispenser formspecs (0.60.0)",
	name = "mcl_dispensers:update_formspecs_0_60_0",
	nodenames = { "mcl_dispensers:dispenser", "mcl_dispensers:dispenser_down", "mcl_dispensers:dispenser_up" },
	action = function(pos, node)
		setup_dispenser(pos)
		minetest.log("action", "[mcl_dispenser] Node formspec updated at " .. minetest.pos_to_string(pos))
	end,
})
