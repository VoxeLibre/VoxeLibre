-- [bamboo] mod by Krock, modified by SmallJoker, Made for MineClone 2 by Michieal (as mcl_bamboo).
-- Parts of mcl_scaffolding were used. Mcl_scaffolding originally created by Cora; modified for mcl_bamboo by Michieal.
-- Creation date: 12-01-2022 (Dec 1st, 2022)
-- License for everything: GPL3
-- Bamboo max height: 12-16

-- LOCALS
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local bamboo = "mcl_bamboo:bamboo"
local adj_nodes = {
	vector.new(0, 0, 1),
	vector.new(0, 0, -1),
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
}
local node_sound = mcl_sounds.node_sound_wood_defaults()

-- CONSTS
local SIDE_SCAFFOLDING = false
local MAKE_STAIRS = true
local DEBUG = false
local USE_END_CAPS = false

-- Due to door fix #2736, doors are displayed backwards. When this is fixed, set this variable to false.
local BROKEN_DOORS = true

-- LOCAL FUNCTIONS
local function create_nodes()

	local bamboo_def = {
		description = "Bamboo",
		tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo.png"},
		drawtype = "nodebox",
		paramtype = "light",
		groups = {handy = 1, axey = 1, choppy = 1, flammable = 3},
		sounds = node_sound,
		drops = "mcl_bamboo:bamboo",
		inventory_image = "mcl_bamboo_bamboo_shoot.png",
		wield_image = "mcl_bamboo_bamboo_shoot.png",
		_mcl_blast_resistance = 1,
		_mcl_hardness = 2,
		node_box = {
			type = "fixed",
			fixed = {
				--				{0.1875, -0.5, -0.125, 0.4125, 0.5, 0.0625},
				--				{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
				--				{-0.25, -0.5, -0.3125, 0, 0.5, -0.125},
				{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
			}
		},

		--[[
		Node Box definitions for alternative styles.
		{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
		{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
		{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
		--]]

		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			local node = minetest.get_node(pointed_thing.under)
			local pos = pointed_thing.under
			if DEBUG then
				minetest.log("mcl_bamboo::Node placement data:")
				minetest.log(dump(pointed_thing))
				minetest.log(dump(node))
			end

			if DEBUG then
				minetest.log("mcl_bamboo::Checking for protected placement of bamboo.")
			end
			local pname = placer:get_player_name()
			if minetest.is_protected(pos, pname) then
				minetest.record_protection_violation(pos, pname)
				return
			end
			if DEBUG then
				minetest.log("mcl_bamboo::placement of bamboo is not protected.")
			end

			-- Use pointed node's on_rightclick function first, if present
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					if DEBUG then
						minetest.log("mcl_bamboo::attempting placement of bamboo via targeted node's on_rightclick.")
					end
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			if node.name ~= "mcl_bamboo:bamboo" then
				if node.name ~= "mcl_flowerpots:flower_pot" then
					if minetest.get_item_group(node.name, "dirt") == 0 then
						return itemstack
					end
				end
			end

			if DEBUG then
				minetest.log("mcl_bamboo::placing bamboo directly.")
			end
			return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))

		end,

		on_destruct = function(pos)
			-- Node destructor; called before removing node.
			local new_pos = vector.offset(pos, 0, 1, 0)
			local node_above = minetest.get_node(new_pos)
			if node_above and node_above.name == "mcl_bamboo:bamboo" then
				if node_above and node_above.name == "mcl_bamboo:bamboo" then
					local sound_params = {
						pos = new_pos,
						gain = 1.0, -- default
						max_hear_distance = 10, -- default, uses a Euclidean metric
					}

					minetest.remove_node(new_pos)
					minetest.sound_play(node_sound.dug, sound_params, true)
					local istack = ItemStack("mcl_bamboo:bamboo")
					minetest.add_item(new_pos, istack)
				end
			end
		end,
	}
	minetest.register_node("mcl_bamboo:bamboo", bamboo_def)
	local bamboo_top = table.copy(bamboo_def)
	bamboo_top.groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3}

	bamboo_top.on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local node = minetest.get_node(pointed_thing.under)
		local pos = pointed_thing.under
		if DEBUG then
			minetest.log("mcl_bamboo::Node placement data:")
			minetest.log(dump(pointed_thing))
			minetest.log(dump(node))
		end

		if DEBUG then
			minetest.log("mcl_bamboo::Checking for protected placement of bamboo.")
		end
		local pname = placer:get_player_name()
		if pname then
			if minetest.is_protected(pos, pname) then
				minetest.record_protection_violation(pos, pname)
				return
			end
			--not for player use.
			if minetest.is_creative_enabled(pname) == false then
				itemstack:set_count(0)
				return itemstack
			end
		end
		if DEBUG then
			minetest.log("mcl_bamboo::placement of bamboo is not protected.")
		end

		if node.name ~= "mcl_bamboo:bamboo" then
			return itemstack
		end

		if DEBUG then
			minetest.log("mcl_bamboo::placing bamboo directly.")
		end
		return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))
	end,

	minetest.register_node("mcl_bamboo:bamboo_top", bamboo_top)

	local bamboo_block_def = {
		description = "Bamboo Block",
		tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_block.png"},
		groups = {handy = 1, building_block = 1, axey = 1, flammable = 2, material_wood = 1, bamboo_block = 1, fire_encouragement = 5, fire_flammability = 5},
		sounds = node_sound,
		paramtype2 = "facedir",
		drops = "mcl_bamboo:bamboo_block",
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
		_mcl_stripped_variant = "mcl_bamboo:bamboo_block_stripped", -- this allows us to use the built in Axe's strip block.
		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.under

			local pname = placer:get_player_name()
			if minetest.is_protected(pos, pname) then
				minetest.record_protection_violation(pos, pname)
				return
			end

			-- Use pointed node's on_rightclick function first, if present
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))
		end,

	}

	-- basic bamboo nodes.
	minetest.register_node("mcl_bamboo:bamboo_block", bamboo_block_def)
	local bamboo_stripped_block = table.copy(bamboo_block_def)
	bamboo_stripped_block.on_rightclick = nil
	bamboo_stripped_block.description = S("Stripped Bamboo Block")
	bamboo_stripped_block.tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_block_stripped.png"}
	minetest.register_node("mcl_bamboo:bamboo_block_stripped", bamboo_stripped_block)
	minetest.register_node("mcl_bamboo:bamboo_plank", {
		description = S("Bamboo Plank"),
		_doc_items_longdesc = S("Bamboo Plank"),
		_doc_items_hidden = false,
		tiles = {"mcl_bamboo_bamboo_plank.png"},
		stack_max = 64,
		is_ground_content = false,
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})

	-- specific bamboo nodes...
	if minetest.get_modpath("mcl_flowerpots") then
		if DEBUG then
			minetest.log("mcl_bamboo::FlowerPot Section Entrance. Modpath exists.")
		end
		if mcl_flowerpots ~= nil then
			-- Flower-potted Bamboo...
			local flwr_name = "mcl_bamboo:bamboo"
			local flwr_def = {name = "bamboo_plant",
							  desc = S("Bamboo"),
							  image = "mcl_bamboo_bamboo_fpm.png", -- use with "register_potted_cube"
				-- "mcl_bamboo_flower_pot.png", -- use with "register_potted_flower"
			}

			mcl_flowerpots.register_potted_cube(flwr_name, flwr_def)
			--			mcl_flowerpots.register_potted_flower(flwr_name, flwr_def)
			minetest.register_alias("bamboo_flower_pot", "mcl_flowerpots:flower_pot_bamboo_plant")
		end
	end

	if minetest.get_modpath("mcl_doors") then
		if mcl_doors then
			local top_door_tiles = {}
			local bot_door_tiles = {}

			if BROKEN_DOORS then
				top_door_tiles = {"mcl_bamboo_door_top_alt.png", "mcl_bamboo_door_top.png"}
				bot_door_tiles = {"mcl_bamboo_door_bottom_alt.png", "mcl_bamboo_door_bottom.png"}
			else
				top_door_tiles = {"mcl_bamboo_door_top.png", "mcl_bamboo_door_top.png"}
				bot_door_tiles = {"mcl_bamboo_door_bottom.png", "mcl_bamboo_door_bottom.png"}
			end

			local name = "mcl_bamboo:bamboo_door"
			local def = {
				description = S("Bamboo Door."),
				inventory_image = "mcl_bamboo_door_wield.png",
				wield_image = "mcl_bamboo_door_wield.png",
				groups = {handy = 1, axey = 1, material_wood = 1, flammable = -1},
				_mcl_hardness = 3,
				_mcl_blast_resistance = 3,
				tiles_bottom = bot_door_tiles,
				tiles_top = top_door_tiles,
				sounds = mcl_sounds.node_sound_wood_defaults(),
			}

			--[[ Registers a door
			--  name: The name of the door
			--  def: a table with the folowing fields:
			--    description
			--    inventory_image
			--    groups
			--    tiles_bottom: the tiles of the bottom part of the door {front, side}
			--    tiles_top: the tiles of the bottom part of the door {front, side}
			--    If the following fields are not defined the default values are used
			--    node_box_bottom
			--    node_box_top
			--    selection_box_bottom
			--    selection_box_top
			--    only_placer_can_open: if true only the player who placed the door can
			--                          open it
			--    only_redstone_can_open: if true, the door can only be opened by redstone,
			--                            not by rightclicking it
			--]]

			mcl_doors:register_door(name, def)

			name = "mcl_bamboo:bamboo_trapdoor"
			local trap_def = {
				description = S("Bamboo Trapdoor."),
				inventory_image = "mcl_bamboo_door_complete.png",
				groups = {},
				tile_front = "mcl_bamboo_trapdoor_top.png",
				tile_side = "mcl_bamboo_trapdoor_side.png",
				_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
				_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
				wield_image = "mcl_bamboo_trapdoor_wield.png",
				inventory_image = "mcl_bamboo_trapdoor_wield.png",
				groups = {handy = 1, axey = 1, mesecon_effector_on = 1, material_wood = 1, flammable = -1},
				_mcl_hardness = 3,
				_mcl_blast_resistance = 3,
				sounds = mcl_sounds.node_sound_wood_defaults(),
			}

			mcl_doors:register_trapdoor(name, trap_def)

			minetest.register_alias("bamboo_door", "mcl_bamboo:bamboo_door")
			minetest.register_alias("bamboo_trapdoor", "mcl_bamboo:bamboo_trapdoor")
		end
	end

	if MAKE_STAIRS then
		if minetest.get_modpath("mcl_stairs") then
			if mcl_stairs ~= nil then
				mcl_stairs.register_stair_and_slab_simple(
						"bamboo_block",
						"mcl_bamboo:bamboo_block",
						S("Bamboo Stair"),
						S("Bamboo Slab"),
						S("Double Bamboo Slab")
				)
				mcl_stairs.register_stair_and_slab_simple(
						"bamboo_stripped",
						"mcl_bamboo:bamboo_block_stripped",
						S("Stripped Bamboo Stair"),
						S("Stripped Bamboo Slab"),
						S("Double Stripped Bamboo Slab")
				)
				mcl_stairs.register_stair_and_slab_simple(
						"bamboo_plank",
						"mcl_bamboo:bamboo_plank",
						S("Bamboo Plank Stair"),
						S("Bamboo Plank Slab"),
						S("Double Bamboo Plank Slab")
				)

				-- let's add plank slabs to the wood_slab group.
				local bamboo_plank_slab = "mcl_stairs:slab_bamboo_plank"
				local node_def_plank_slab_def = minetest.registered_nodes[bamboo_plank_slab]
				node_def_plank_slab_def.groups = {
					wood_slab = 1,
					building_block = 1,
					slab = 1,
					axey = 1,
					handy = 1,
					stair = 1
				}

				if DEBUG then
					minetest.log("Plank_Slab definition: \n" .. dump(node_def_plank_slab_def))
				end

				-- A necessary evil, to add a single group to an already registered node. (And yes, I did try override_item())
				minetest.unregister_item(node_def_plank_slab_def.name)
				minetest.register_node(":"..node_def_plank_slab_def.name, node_def_plank_slab_def)
			end
		end
	end

	if minetest.get_modpath("mesecons_pressureplates") then

		if mesecon ~= nil and mesecon.register_pressure_plate ~= nil then
			-- make sure that pressure plates are installed.

			-- Bamboo Pressure Plate...

			-- Register a Pressure Plate (api command doc.)
			-- basename:    base name of the pressure plate
			-- description:	description displayed in the player's inventory
			-- textures_off:textures of the pressure plate when inactive
			-- textures_on:	textures of the pressure plate when active
			-- image_w:	wield image of the pressure plate
			-- image_i:	inventory image of the pressure plate
			-- recipe:	crafting recipe of the pressure plate
			-- sounds:	sound table (like in minetest.register_node)
			-- plusgroups:	group memberships (attached_node=1 and not_in_creative_inventory=1 are already used)
			-- activated_by: optimal table with elements denoting by which entities this pressure plate is triggered
			--		Possible table fields:
			--		* player=true: Player
			--		* mob=true: Mob
			--		By default, is triggered by all entities
			-- longdesc:	Customized long description for the in-game help (if omitted, a dummy text is used)

			mesecon.register_pressure_plate(
					"mcl_bamboo:pressure_plate_bamboo_wood",
					S("Bamboo Pressure Plate"),
					{"mcl_bamboo_bamboo_plank.png"},
					{"mcl_bamboo_bamboo_plank.png"},
					"mcl_bamboo_bamboo_plank.png",
					nil,
					{{"mcl_bamboo:bamboo_plank", "mcl_bamboo:bamboo_plank"}},
					mcl_sounds.node_sound_wood_defaults(),
					{axey = 1, material_wood = 1},
					nil,
					S("A wooden pressure plate is a redstone component which supplies its surrounding blocks with redstone power while any movable object (including dropped items, players and mobs) rests on top of it."))

			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_bamboo:pressure_plate_bamboo_wood_off",
				burntime = 15
			})
			minetest.register_alias("bamboo_pressure_plate", "mcl_bamboo:pressure_plate_bamboo_wood")

		end
	end

	if minetest.get_modpath("mcl_signs") then
		if DEBUG then
			minetest.log("mcl_bamboo::Signs Section Entrance. Modpath exists.")
		end
		if mcl_signs ~= nil then
			-- Bamboo Signs...
			mcl_signs.register_sign_custom("mcl_bamboo", "_bamboo", "mcl_signs_sign_greyscale.png",
					"#f6dc91", "default_sign_greyscale.png", "default_sign_greyscale.png",
					"Bamboo Sign")
			mcl_signs.register_sign_craft("mcl_bamboo", "mcl_bamboo:bamboo_plank", "_bamboo")
			minetest.register_alias("bamboo_sign", "mcl_signs:wall_sign_bamboo")
		end
	end

	if minetest.get_modpath("mcl_fences") then
		if DEBUG then
			minetest.log("mcl_bamboo::Fences Section Entrance. Modpath exists.")
		end
		local id = "bamboo_fence"
		local id_gate = "bamboo_fence_gate"
		local wood_groups = {handy = 1, axey = 1, flammable = 2, fence_wood = 1, fire_encouragement = 5, fire_flammability = 20}
		local wood_connect = {"group:fence_wood"}

		local fence_id = mcl_fences.register_fence(id, S("Bamboo Fence"), "mcl_bamboo_fence_bamboo.png", wood_groups,
				2, 15, wood_connect, node_sound)
		local gate_id = mcl_fences.register_fence_gate(id, S("Bamboo Fence Gate"), "mcl_bamboo_fence_gate_bamboo.png",
				wood_groups, 2, 15, node_sound) -- note: about missing params.. will use defaults.

		if DEBUG then
			minetest.log(dump(fence_id))
			minetest.log(dump(gate_id))
		end

		local craft_wood = "mcl_bamboo:bamboo_plank"
		minetest.register_craft({
			output = "mcl_bamboo:" .. id .. " 3",
			recipe = {
				{craft_wood, "mcl_core:stick", craft_wood},
				{craft_wood, "mcl_core:stick", craft_wood},
			}
		})
		minetest.register_craft({
			output = "mcl_bamboo:" .. id_gate,
			recipe = {
				{"mcl_core:stick", craft_wood, "mcl_core:stick"},
				{"mcl_core:stick", craft_wood, "mcl_core:stick"},
			}
		})
		-- mcl_fences.register_fence("nether_brick_fence", S("Nether Brick Fence"), "mcl_fences_fence_nether_brick.png", {pickaxey=1, deco_block=1, fence_nether_brick=1}, 2, 30, {"group:fence_nether_brick"}, mcl_sounds.node_sound_stone_defaults())
		minetest.register_alias("bamboo_fence", "mcl_fences:" .. id)
		minetest.register_alias("bamboo_fence_gate", "mcl_fences:" .. id_gate)
	end

	if minetest.get_modpath("mesecons_button") then
		if mesecon ~= nil then
			mesecon.register_button(
					"bamboo",
					S("Bamboo Button"),
					"mcl_bamboo_bamboo_plank.png",
					"mcl_bamboo:bamboo_plank",
					node_sound,
					{material_wood = 1, handy = 1, pickaxey = 1},
					1,
					false,
					S("A bamboo button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
					"mesecons_button_push")
		end
	end

	minetest.register_node("mcl_bamboo:scaffolding", {
		description = S("Scaffolding"),
		doc_items_longdesc = S("Scaffolding block used to climb up or out across areas."),
		doc_items_hidden = false,
		tiles = {"mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_bottom.png"},
		drawtype = "nodebox",
		paramtype = "light",
		use_texture_alpha = "clip",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
				{0.375, -0.5, -0.5, 0.5, 0.5, -0.375},
				{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
		buildable_to = false,
		is_ground_content = false,
		walkable = false,
		climbable = true,
		physical = true,
		node_placement_prediction = "",
		groups = {handy = 1, axey = 1, flammable = 3, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20, falling_node = 1, stack_falling = 1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
		on_place = function(itemstack, placer, ptd)
			if SIDE_SCAFFOLDING then
				-- count param2 up when placing to the sides. Fall when > 6
				local ctrl = placer:get_player_control()
				if ctrl and ctrl.sneak then
					local pp2 = minetest.get_node(ptd.under).param2
					local np2 = pp2 + 1
					if minetest.get_node(vector.offset(ptd.above, 0, -1, 0)).name == "air" then
						minetest.set_node(ptd.above, {name = "mcl_bamboo:scaffolding_horizontal", param2 = np2})
						itemstack:take_item(1)
					end
					if np2 > 6 then
						minetest.check_single_for_falling(ptd.above)
					end
					return itemstack
				end
			end

			--place on solid nodes
			local node = minetest.get_node(ptd.under)
			if itemstack:get_name() ~= node.name then
				minetest.set_node(ptd.above, {name = "mcl_bamboo:scaffolding", param2 = 0})
				itemstack:take_item(1)
				return itemstack
			end

			--build up when placing on existing scaffold
			local h = 0
			local pos = ptd.under
			repeat
				pos.y = pos.y + 1
				h = h + 1
				local cn = minetest.get_node(pos)
				if cn.name == "air" then
					minetest.set_node(pos, node)
					itemstack:take_item(1)
					placer:set_wielded_item(itemstack)
					return itemstack
				end
			until cn.name ~= node.name or h >= 32
		end,
		on_destruct = function(pos)
			-- Node destructor; called before removing node.
			local new_pos = vector.offset(pos, 0, 1, 0)
			local node_above = minetest.get_node(new_pos)
			if node_above and node_above.name == "mcl_bamboo:scaffolding" then
				if node_above and node_above.name == "mcl_bamboo:scaffolding" then
					local sound_params = {
						pos = new_pos,
						gain = 1.0, -- default
						max_hear_distance = 10, -- default, uses a Euclidean metric
					}

					minetest.remove_node(new_pos)
					minetest.sound_play(node_sound.dug, sound_params, true)
					local istack = ItemStack("mcl_bamboo:scaffolding")
					minetest.add_item(new_pos, istack)
				end
			end
		end,

	})

	if SIDE_SCAFFOLDING then
		--currently, disabled.
		minetest.register_node("mcl_bamboo:scaffolding_horizontal", {
			description = S("Scaffolding (horizontal)"),
			doc_items_longdesc = S("Scaffolding block used to climb up or out across areas."),
			doc_items_hidden = false,
			tiles = {"mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_bottom.png"},
			drawtype = "nodebox",
			paramtype = "light",
			use_texture_alpha = "clip",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5},
					{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
					{0.375, -0.5, -0.5, 0.5, 0.5, -0.375},
					{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
					{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
					{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
				}
			},
			selection_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				},
			},
			groups = {handy = 1, axey = 1, flammable = 3, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20, not_in_creative_inventory = 1, falling_node = 1},
			_mcl_after_falling = function(pos)
				if minetest.get_node(pos).name == "mcl_bamboo:scaffolding_horizontal" then
					if minetest.get_node(vector.offset(pos, 0, 0, 0)).name ~= "mcl_bamboo:scaffolding" then
						minetest.remove_node(pos)
						minetest.add_item(pos, "mcl_bamboo:scaffolding")
					else
						minetest.set_node(vector.offset(pos, 0, 1, 0), {name = "mcl_bamboo:scaffolding"})
					end
				end
			end
		})
	end
end

local function register_craftings()
	-- Craftings

	minetest.register_craft({
		output = bamboo .. "_block",
		recipe = {
			{bamboo, bamboo, bamboo},
			{bamboo, bamboo, bamboo},
			{bamboo, bamboo, bamboo},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_plank 2",
		recipe = {
			{bamboo .. "_block"},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_plank 2",
		recipe = {
			{bamboo .. "_block_stripped"},
		}
	})

	minetest.register_craft({
		output = "mcl_core:stick",
		recipe = {
			{bamboo},
			{bamboo},
		}
	})

	-- Barrel and composter recipes
	if minetest.get_modpath("mcl_stairs") and 1 == 2 then
		-- currently disabled.
		if mcl_stairs ~= nil then
			minetest.register_craft({
				output = "mcl_barrels:barrel_closed",
				recipe = {
					{"group:wood", "group:wood_slab", "group:wood"},
					{"group:wood", "", "group:wood"},
					{"group:wood", "group:wood_slab", "group:wood"},
				}
			})

			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_barrels:barrel_closed",
				burntime = 15,
			})
		end
	end

	minetest.register_craft({
		output = "mcl_bamboo:scaffolding 6",
		recipe = {{bamboo, "mcl_mobitems:string", bamboo},
				  {bamboo, "", bamboo},
				  {bamboo, "", bamboo}}
	})

	minetest.register_craft({
		output = "mcl_bamboo:bamboo_door 3",
		recipe = {
			{bamboo .. "_plank", bamboo .. "_plank"},
			{bamboo .. "_plank", bamboo .. "_plank"},
			{bamboo .. "_plank", bamboo .. "_plank"}
		}
	})

	minetest.register_craft({
		output = "mcl_bamboo:bamboo_trapdoor 2",
		recipe = {
			{bamboo .. "_plank", bamboo .. "_plank", bamboo .. "_plank"},
			{bamboo .. "_plank", bamboo .. "_plank", bamboo .. "_plank"},
		}
	})

	-- Fuels
	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_bamboo:bamboo_door",
		burntime = 10,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_bamboo:bamboo_trapdoor",
		burntime = 15,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo,
		burntime = 2.5, -- supposed to be 1/2 that of a stick, per minecraft wiki as of JE 1.19.3
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_block",
		burntime = 15,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_block_stripped",
		burntime = 15,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_plank",
		burntime = 7.5,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_bamboo:scaffolding",
		burntime = 20
	})
end

create_nodes()
register_craftings()

-- MAPGEN
dofile(minetest.get_modpath(modname) .. "/mapgen.lua")

--ABMs
minetest.register_abm({
	nodenames = {"mcl_bamboo:bamboo"},
	interval = 40,
	chance = 40,
	action = function(pos, node)
		local soil_pos = nil
		if minetest.get_node_light(pos) < 8 then
			return
		end
		local found_soil = false
		for py = -1, -16, -1 do
			local chk_pos = vector.offset(pos, 0, py, 0)
			local name = minetest.get_node(chk_pos).name
			if minetest.get_item_group(name, "soil") ~= 0 then
				found_soil = true
				soil_pos = chk_pos
				break
			elseif name ~= "mcl_bamboo:bamboo" then
				break
			end
		end
		if not found_soil then
			return
		end
		for py = 1, 14 do
			local npos = vector.offset(pos, 0, py, 0)
			local name = minetest.get_node(npos).name
			if vector.distance(soil_pos, npos) >= 15 then
				-- stop growing check.
				if USE_END_CAPS then
					if name == "air" then
						minetest.set_node(npos, {name = "mcl_bamboo:bamboo_top"})
					end
				end
				break
			end
			if name == "air" then
				minetest.set_node(npos, {name = "mcl_bamboo:bamboo"})
				break
			elseif name ~= "mcl_bamboo:bamboo" then
				break
			end
		end
	end,
})

-- Base Aliases.
minetest.register_alias("bamboo_block", "mcl_bamboo:bamboo_block")
minetest.register_alias("bamboo_strippedblock", "mcl_bamboo:bamboo_block_stripped")
minetest.register_alias("bamboo", "mcl_bamboo:bamboo")
minetest.register_alias("bamboo_plank", "mcl_bamboo:bamboo_plank")

minetest.register_alias("mcl_stairs:stair_bamboo", "mcl_stairs:stair_bamboo_block")
minetest.register_alias("bamboo:bamboo", "mcl_bamboo:bamboo")

--[[
todo -- make scaffolds do side scaffold blocks, so that they jut out.
todo -- Also, make those blocks collapse (break) when a nearby connected scaffold breaks.
todo -- add in alternative bamboo styles to simulate random placement. (see commented out nde box definitions.
todo -- make endcap node for bamboo, so that they can be 12-16 nodes high and stop growing.
todo -- mash all of that together so that it drops as one item, and chooses what version to be, in on_place.
todo -- Raft
todo -- Raft with Chest.
todo -- Add in Extras.
todo: Added a new "Mosaic" plank variant that is unique to Bamboo called Bamboo Mosaic
    It can be crafted with 1x2 Bamboo Slabs in a vertical strip
    You can craft Stair and Slab variants of Bamboo Mosaic
    Bamboo Mosaic blocks cannot be used as a crafting ingredient where other wooden blocks are used, but they can be
    used as fuel.
--]]