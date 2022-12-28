-- [bamboo] mod by SmallJoker, Made for MineClone 2 by Michieal (as mcl_bamboo).
-- Parts of mcl_scaffolding were used. Mcl_scaffolding originally created by Cora; Fixed and heavily reworked
-- for mcl_bamboo by Michieal.
-- Creation date: 12-01-2022 (Dec 1st, 2022)
-- License for everything: CC-BY-SA 4.0
-- Bamboo max height: 12-16

-- LOCALS
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local bamboo = "mcl_bamboo:bamboo"

local node_sound = mcl_sounds.node_sound_wood_defaults()

-- CONSTS
local SIDE_SCAFFOLDING = false
local DEBUG = false
local DOUBLE_DROP_CHANCE = 8

mcl_bamboo ={}

--- pos: node position; placer: ObjectRef that is placing the item
--- returns: true if protected, otherwise false.
function mcl_bamboo.is_protected(pos, placer)
	local name = placer:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

--Bamboo can be planted on moss blocks, grass blocks, dirt, coarse dirt, rooted dirt, gravel, mycelium, podzol, sand, red sand, or mud
local bamboo_dirt_nodes = {
	"mcl_core:redsand",
	"mcl_core:sand",
	"mcl_core:dirt",
	"mcl_core:coarse_dirt",
	"mcl_core:dirt_with_grass",
	"mcl_core:podzol",
	"mcl_core:mycelium",
	"mcl_lush_caves:rooted_dirt",
	"mcl_lush_caves:moss",
	"mcl_mud:mud",
}

-- Due to door fix #2736, doors are displayed backwards. When this is fixed, set this variable to false.
local BROKEN_DOORS = true

-- LOCAL FUNCTIONS

-- Add Groups function, courtesy of Warr1024.
function mcl_bamboo.addgroups(name, ...)
	local def = minetest.registered_items[name] or error(name .. " not found")
	local groups = {}
	for k, v in pairs(def.groups) do
		groups[k] = v
	end
	local function addall(x, ...)
		if not x then
			return
		end
		groups[x] = 1
		return addall(...)
	end
	addall(...)
	return minetest.override_item(name, {groups = groups})
end

local function create_nodes()

	local bamboo_def = {
		description = "Bamboo",
		tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo.png"},
		drawtype = "nodebox",
		paramtype = "light",
		groups = {handy = 1, axey = 1, choppy = 1, flammable = 3},
		sounds = node_sound,

		drop = {
			max_items = 1,
			-- Maximum number of item lists to drop.
			-- The entries in 'items' are processed in order. For each:
			-- Item filtering is applied, chance of drop is applied, if both are
			-- successful the entire item list is dropped.
			-- Entry processing continues until the number of dropped item lists
			-- equals 'max_items'.
			-- Therefore, entries should progress from low to high drop chance.
			items = {
				-- Examples:
				{
					-- 1 in 100 chance of dropping.
					-- Default rarity is '1'.
					rarity = DOUBLE_DROP_CHANCE,
					items = {bamboo .. " 2"},
				},
				{
					-- 1 in 2 chance of dropping.
					-- Default rarity is '1'.
					rarity = 1,
					items = {bamboo},
				},
			},
		},

		inventory_image = "mcl_bamboo_bamboo_shoot.png",
		wield_image = "mcl_bamboo_bamboo_shoot.png",
		_mcl_blast_resistance = 1,
		_mcl_hardness = 1.5,
		node_box = {
			type = "fixed",
			fixed = {
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
			if mcl_bamboo.is_protected(pos, placer) then
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
					local found = false
					for i = 1, #bamboo_dirt_nodes do
						if node.name == bamboo_dirt_nodes[i] then
							found = true
							break
						end
					end
					if not found then
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
			if node_above and node_above.name == bamboo then
				local sound_params = {
					pos = new_pos,
					gain = 1.0, -- default
					max_hear_distance = 10, -- default, uses a Euclidean metric
				}
				minetest.remove_node(new_pos)
				minetest.sound_play(node_sound.dug, sound_params, true)
				local istack = ItemStack(bamboo)
				if math.random(1, DOUBLE_DROP_CHANCE) == 1 then
					minetest.add_item(new_pos, istack)
				end
				minetest.add_item(new_pos, istack)
			elseif node_above and node_above.name == "mcl_bamboo:bamboo_endcap" then
				minetest.remove_node(new_pos)
				minetest.sound_play(node_sound.dug, sound_params, true)
				local istack = ItemStack(bamboo)
				minetest.add_item(new_pos, istack)
				if math.random(1, DOUBLE_DROP_CHANCE) == 1 then
					minetest.add_item(new_pos, istack)
				end
			end
		end,
	}
	minetest.register_node(bamboo, bamboo_def)
	local bamboo_top = table.copy(bamboo_def)
	bamboo_top.groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3}
	bamboo_top.tiles = {"mcl_bamboo_endcap.png"}
	bamboo_top.drawtype = "plantlike"
	bamboo_top.paramtype2 = "meshoptions"
	bamboo_top.param2 = 34
	bamboo_top.nodebox = nil

	bamboo_top.on_place = function(itemstack, _, _)
		-- Should never occur... but, if it does, then nix it.
		itemstack:set_name(bamboo)
		return itemstack
	end

	minetest.register_node("mcl_bamboo:bamboo_endcap", bamboo_top)

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

			if mcl_bamboo.is_protected(pos, placer) then
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
			local node_groups = {
				wood_slab = 1,
				building_block = 1,
				slab = 1,
				axey = 1,
				handy = 1,
				stair = 1,
				flammable = 1,
				fire_encouragement = 5,
				fire_flammability = 20
			}

			minetest.override_item(bamboo_plank_slab, {groups = node_groups})
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
					{material_wood = 1, handy = 1, pickaxey = 1, flammable = 3, fire_flammability = 20, fire_encouragement = 5, },
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
		paramtype2 = "4dir",
		param2 = 0,
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
			local scaff_node_name = "mcl_bamboo:scaffolding"
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
			if DEBUG then
				minetest.log("mcl_bamboo::Checking for protected placement of scaffolding.")
			end
			local node = minetest.get_node(ptd.under)
			local pos = ptd.under
			if mcl_bamboo.is_protected(pos, placer) then
				return
			end
			if DEBUG then
				minetest.log("mcl_bamboo::placement of scaffolding is not protected.")
			end

			--place on solid nodes
			if itemstack:get_name() ~= node.name then
				minetest.set_node(ptd.above, {name = scaff_node_name, param2 = 0})
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item(1)
				end
				return itemstack
			end

			--build up when placing on existing scaffold
			local h = 0
			repeat
				pos.y = pos.y + 1
				local cn = minetest.get_node(pos)
				local cnb = minetest.get_node(ptd.under)
				local bn = minetest.get_node(vector.offset(ptd.under, 0, -1, 0))
				if cn.name == "air" then
					-- first step to making scaffolding work like Minecraft scaffolding.
					if cnb.name == scaff_node_name and bn == scaff_node_name and SIDE_SCAFFOLDING == false then
						return itemstack
					end

					minetest.set_node(pos, node)
					if not minetest.is_creative_enabled(placer:get_player_name()) then
						itemstack:take_item(1)
					end
					placer:set_wielded_item(itemstack)
					return itemstack
				end
				h = h + 1
			until cn.name ~= node.name or itemstack:get_count() == 0 or h >= 128
		end,
		on_destruct = function(pos)
			-- Node destructor; called before removing node.
			local new_pos = vector.offset(pos, 0, 1, 0)
			local node_above = minetest.get_node(new_pos)
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
		end,
	})

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

	if minetest.get_modpath("mcl_stairs") then
		if mcl_stairs ~= nil then
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_plank",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_block",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_stripped",
				burntime = 7.5,
			})

			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_plank",
				burntime = 15,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_block",
				burntime = 15,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_stripped",
				burntime = 15,
			})
		end
	end

	minetest.register_craft({
		type = "fuel",
		recipe = "mesecons_button:button_bamboo_off",
		burntime = 5,
	})

end

create_nodes()
register_craftings()

-- BAMBOO_TOO (Bamboo two)
dofile(minetest.get_modpath(modname) .. "/bambootoo.lua")

local BAMBOO_SOIL_DIST = -16
local BAM_MAX_HEIGHT_STPCHK = 11
local BAM_MAX_HEIGHT_TOP = 15

--ABMs
minetest.register_abm({
	nodenames = {bamboo},
	interval = 40,
	chance = 40,
	action = mcl_bamboo.grow_bamboo(pos,_),
})

function mcl_bamboo.grow_bamboo(pos, _, force)
	local soil_pos
	if minetest.get_node_light(pos) < 8 then
		return
	end
	local found_soil = false
	for py = -1, BAMBOO_SOIL_DIST, -1 do
		local chk_pos = vector.offset(pos, 0, py, 0)
		local name = minetest.get_node(chk_pos).name
		if minetest.get_item_group(name, "soil") ~= 0 then
			found_soil = true
			soil_pos = chk_pos
			break
		elseif name ~= bamboo then
			break
		end
	end
	if not found_soil then
		return
	end
	for py = 1, 15 do
		local npos = vector.offset(pos, 0, py, 0)
		local name = minetest.get_node(npos).name
		local dist = vector.distance(soil_pos, npos)
		if dist >= BAM_MAX_HEIGHT_STPCHK then
			-- stop growing check.
			if name == "air" then
				local height = math.random(BAM_MAX_HEIGHT_STPCHK, BAM_MAX_HEIGHT_TOP)
				if height == dist then
					minetest.set_node(npos, {name = "mcl_bamboo:bamboo_endcap"})
				end
			end
			break
		end
		if name == "air" then
			minetest.set_node(npos, {name = bamboo})
			break
		elseif name ~= bamboo then
			break
		end
	end

end

-- Base Aliases.
minetest.register_alias("bamboo_block", "mcl_bamboo:bamboo_block")
minetest.register_alias("bamboo_strippedblock", "mcl_bamboo:bamboo_block_stripped")
minetest.register_alias("bamboo", "mcl_bamboo:bamboo")
minetest.register_alias("bamboo_plank", "mcl_bamboo:bamboo_plank")
minetest.register_alias("bamboo_mosaic", "mcl_bamboo:bamboo_mosaic")

minetest.register_alias("mcl_stairs:stair_bamboo", "mcl_stairs:stair_bamboo_block")
minetest.register_alias("bamboo:bamboo", "mcl_bamboo:bamboo")
minetest.register_alias("mcl_scaffolding:scaffolding", "mcl_bamboo:scaffolding")
minetest.register_alias("mcl_scaffolding:scaffolding_horizontal", "mcl_bamboo:scaffolding")

--[[
todo -- make scaffolds do side scaffold blocks, so that they jut out.
todo -- Also, make those blocks collapse (break) when a nearby connected scaffold breaks.
todo -- add in alternative bamboo styles to simulate random placement. (see commented out node box definitions.
todo -- Add Flourish to the endcap node for bamboo.
todo -- mash all of that together so that it drops as one item, and chooses what version to be, in on_place.
todo -- Add in Extras.
todo -- fix scaffolding placing, instead of using on_rightclick first.

todo -- make graphic for top node of bamboo.

waiting on specific things:
todo -- Raft -- need model
todo -- Raft with Chest. same.
todo -- handle bonemeal...

Notes:
When bone meal is used on it, it grows by 1–2 blocks. Bamboo can grow up to 12–16 blocks tall.
The top of a bamboo plant requires a light level of 9 or above to grow.

Design Decision - to not make bamboo saplings, and not make them go through a ton of transformations.

--]]
