local S = core.get_translator("vl_trees")

local core_get_node, core_get_meta = core.get_node, core.get_meta
local math_abs, math_floor, math_max, math_random = math.abs, math.floor, math.max, math.random
local vector_new, vector_add, vector_offset = vector.new, vector.add, vector.offset

-- TODO: should be put into mcl_util as `table.merge` and `mcl_util.queue`
local table_merge, queue = dofile(core.get_modpath("vl_trees") .. "/util.lua")

-- Global dictionary of all woods registered via this mod
local registered_woods = {}
vl_trees.registered_woods = registered_woods

-- Make leaves which do not have a log within 6 nodes orphan.
--
-- orig. <https://codeberg.org/mineclonia/mineclonia/src/commit/160515fa99/mods/ITEMS/mcl_trees/api.lua#L14>
--       by ryvnf
local function update_far_away_leaves(pos)
	local logs = core.find_nodes_in_area(vector_add(pos, -12), vector_add(pos, 12), "group:tree")

	local function distance(a, b) -- Manhattan distance
		return math_abs(a.x - b.x) + math_abs(a.y - b.y) + math_abs(a.z - b.z)
	end

	local function log_in_range(lpos)
		for _, tpos in pairs(logs) do
			if distance(lpos, tpos) <= 6 then
				return true
			end
		end
		return false
	end

	local leaves = core.find_nodes_in_area(vector_add(pos, -6), vector_add(pos, 6), "group:leaves")
	for _, lpos in pairs(leaves) do
		if not log_in_range(lpos) then
			local node = core_get_node(lpos)
			local ndef = core.registered_nodes[node.name]
			if math_floor(node.param2 / 32) ~= 1 and ndef._mcl_leaves then
				core.swap_node(lpos, {
					name = ndef._mcl_orphan_leaves,
					param2 = node.param2,
				})
			end
		end
	end
end

local tree_tab, leaves_tab, orphan_tab = {}, {}, {}

-- Update leaves distances (param2 data) via VoxelManip
--
-- orig. <https://codeberg.org/mineclonia/mineclonia/src/commit/160515fa99/mods/ITEMS/mcl_trees/api.lua#L73>
--       by ryvnf
local directions = {
	vector_new(1, 0, 0),
	vector_new(-1, 0, 0),
	vector_new(0, 1, 0),
	vector_new(0, -1, 0),
	vector_new(0, 0, 1),
	vector_new(0, 0, -1),
}
local function update_leaves(pos, old_distance)
	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(vector_add(pos, -8), vector_add(pos, 8))
	local a = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()

	local function get_distance(ind)
		local cid = data[ind]
		if tree_tab[cid] then
			return 0
		elseif orphan_tab[cid] then
			return 7
		elseif leaves_tab[cid] then
			return math_max(math_floor(param2_data[ind] / 32) - 1, 0)
		end
	end

	local function update_distance(ind, distance)
		data[ind] = distance < 7 and leaves_tab[data[ind]].c_leaves or
				leaves_tab[data[ind]].c_orphan_leaves
		param2_data[ind] = (distance + 1) * 32 + param2_data[ind] % 32
	end

	local clear_queue = queue()
	local fill_queue = queue()
	if old_distance then
		clear_queue:enqueue({pos = pos, distance = old_distance})
	end
	if get_distance(a:indexp(pos)) then
		fill_queue:enqueue({pos = pos, distance = get_distance(a:indexp(pos))})
	end

	while clear_queue:size() > 0 do
		local entry = clear_queue:dequeue()
		local pos = entry.pos ---@diagnostic disable-line: need-check-nil
		local distance = entry.distance ---@diagnostic disable-line: need-check-nil

		for _, dir in pairs(directions) do
			local pos2 = pos:add(dir)
			local ind2 = a:indexp(pos2)
			local distance2 = get_distance(ind2)
			if distance2 and distance2 < 7 then
				if distance2 > distance then
					if leaves_tab[data[ind2]] then
						update_distance(ind2, 7)
						clear_queue:enqueue({pos = pos2, distance = distance + 1})
					end
				else
					fill_queue:enqueue({pos = pos2, distance = distance2})
				end
			end
		end
	end

	while fill_queue:size() > 0 do
		local entry = fill_queue:dequeue()
		local pos = entry.pos ---@diagnostic disable-line: need-check-nil
		local distance2 = entry.distance + 1 ---@diagnostic disable-line: need-check-nil

		for _, dir in pairs(directions) do
			local pos2 = pos:add(dir)
			local ind2 = a:indexp(pos2)
			if leaves_tab[data[ind2]] and get_distance(ind2) > distance2 then
				update_distance(ind2, distance2)
				fill_queue:enqueue({pos = pos2, distance = distance2})
			end
		end
	end

	vm:set_data(data)
	vm:set_param2_data(param2_data)
	vm:write_to_map(false)
end

-- Function called in leaves' `after_place_node`.
-- Sets their param2 to have a log distance of 0, turning decay off.
--
-- orig. <https://codeberg.org/mineclonia/mineclonia/src/commit/160515fa99/mods/ITEMS/mcl_trees/api.lua#L149>
--       by cora and ryvnf
local function after_place_leaves(pos)
	local node = core_get_node(pos)
	local palette_index = 0
	if core.get_item_group(node.name, "biomecolor") ~= 0 then
		palette_index = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
	end

	node.param2 = 32 + palette_index
	core.swap_node(pos, node)
end
vl_trees.after_place_leaves = after_place_leaves

local function update_leaves_biomecolor(pos)
	local node = core.get_node(pos)
	local palette_index = 0
	if core.get_item_group(node.name, "biomecolor") ~= 0 then
		palette_index = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
	end

	node.param2 = math.floor(node.param2 / 32) * 32 + palette_index
	core.swap_node(pos, node)
end
vl_trees.update_leaves_biomecolor = update_leaves_biomecolor

-- Templates
local tpl_planks = {
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	is_ground_content = false,
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1,
		material_wood = 1, fire_encouragement = 5, fire_flammability = 20
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
}

local tpl_trunk = {
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	after_destruct = update_leaves,
	groups = {
		handy = 1, axey = 1, tree = 1, flammable = 2, building_block = 1,
		material_wood = 1, fire_encouragement = 5, fire_flammability = 5
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	--_mcl_stripped_variant = stripped_variant,
}

local tpl_bark = {
	_doc_items_longdesc = S("This is a decorative block surrounded by the bark of a tree trunk."),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	groups = {
		handy = 1, axey = 1, bark = 1, flammable = 2, building_block = 1,
		material_wood = 1, fire_encouragement = 5, fire_flammability = 5
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	--_mcl_stripped_variant = stripped_variant.."_bark",
}

local tpl_leaves = {
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	paramtype = "light",
	paramtype2 = "color",
	palette = "mcl_core_palette_leaves.png",
	is_ground_content = false,
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		leaves = 1, biomecolor = 1, deco_block = 1, compostability = 30,
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_shears_drop = true,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
	after_place_node = after_place_leaves,
}

local tpl_sapling = {
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = core_get_meta(pos)
		meta:set_int("stage", 0)
	end,
	_on_bone_meal = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local node = core_get_node(pos)
		-- Saplings: 45% chance to advance growth stage
		if math_random(1, 100) <= 45 then
			return vl_trees.grow_sapling(pos, node)
		end
	end,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
}

local tpl_fruit = {
	on_place = core.item_eat(4),
	on_secondary_use = core.item_eat(4),
	groups = {
		food = 2, eatable = 4, compostability = 65
	},
	_mcl_saturation = 2.4,
}

local tpl_drop_chances = {
	sapling = {20, 16, 12, 10, 10},
	fruit = {200, 180, 160, 120, 40},
	stick = {50, 45, 30, 35, 10},
}

-- Subfunctions registering specific nodes and their crafting recipes
local function register_trunk_and_bark(stub, name, trunk_def, bark_def, is_stripped)
	local tname = stub .. "tree_" .. name
	local bname = stub .. "bark_" .. name
	local stname = stub .. "tree_stripped_" .. name
	local sbname = stub .. "bark_stripped_" .. name

	local tdef = table_merge(tpl_trunk, trunk_def, {_vl_wood = name, groups = {[name] = 1}})
	local bdef = table_merge(tpl_bark, bark_def, {_vl_wood = name, groups = {[name] = 1}})

	if is_stripped then
		tname = stname
		bname = sbname
	else
		tdef._mcl_stripped_variant = stname
		bdef._mcl_stripped_variant = sbname
	end

	core.register_node(tname, tdef)
	core.register_node(bname, bdef)

	core.register_craft({
		output = bname .. " 3",
		recipe = {
			{tname, tname},
			{tname, tname},
		},
	})

	return tname, bname
end

local function register_planks(stub, name, def)
	local pname = stub .. "wood_" .. name

	local pdef = table_merge(tpl_planks, def, {_vl_wood = name, groups = {[name] = 1}})
	core.register_node(pname, pdef)

	core.register_craft({
		output = pname .. " 4",
		recipe = {
			{"group:tree,"..name},
		},
	})
	core.register_craft({
		output = pname .. " 4",
		recipe = {
			{"group:bark,"..name},
		},
	})

	return pname
end

local function register_leaves(stub, name, def, chances, sname, fname)
	local function get_drop(lvl)
		local drop = {
			max_items = 1,
			items = {
				{
					items = {"mcl_core:stick 1"},
					rarity = chances.stick[lvl+1]
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = chances.stick[lvl+1]
				},
			}
		}
		if sname then
			drop.items[#drop.items+1] = {
				items = {sname},
				rarity = chances.sapling[lvl+1]
			}
		end
		if fname then
			drop.items[#drop.items+1] = {
				items = {fname},
				rarity = chances.fruit[lvl+1]
			}
		end
		return drop
	end

	local lname = stub .. "leaves_" .. name
	local oname = lname .. "_orphan"

	local basedef = table_merge(tpl_leaves, {
		drop = get_drop(0),
		_mcl_fortune_drop = {get_drop(1), get_drop(2), get_drop(3), get_drop(4)},
		_mcl_leaves = lname,
		_mcl_orphan_leaves = oname,
	}, def, {_vl_wood = name, groups = {[name] = 1}})

	-- Avoid "Node modname:subname has a palette, but not a suitable paramtype2" warnings
	if def.paramtype2 == "none" then
		basedef.palette = nil
	end

	local ldef = table_merge(basedef, {
		on_construct = function(pos)
			update_leaves(pos)
		end,
		after_destruct = function(pos, oldnode)
			update_leaves(pos, math_max(math_floor(oldnode.param2 / 32) - 1, 0))
		end,
	})
	core.register_node(lname, ldef)

	local odef = table_merge(basedef, {
		_doc_items_create_entry = false,
		groups = {not_in_creative_inventory = 1, orphan_leaves = 1},
		_mcl_shears_drop = {lname},
		_mcl_silk_touch_drop = {lname},
	})
	core.register_node(oname, odef)

	return lname
end

local TT_HELP_2X2 = {S("2×2 saplings = large tree"), S("2×2 saplings required")}
local function register_sapling(stub, name, def, min_soil_type, tbt_mode)
	local sname = stub .. "sapling_" .. name

	local sdef = table_merge(tpl_sapling, {
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_below = core_get_node(vector_offset(pos, 0, -1, 0))
			local nn = node_below.name
			return core.get_item_group(nn, "soil_sapling") >= min_soil_type
		end)
	}, def, {_vl_wood = name, groups = {[name] = 1}})

	if tbt_mode then
		sdef._tt_help = sdef._tt_help .. "\n" .. TT_HELP_2X2[tbt_mode]
	end

	core.register_node(sname, sdef)
	return sname
end

local function register_fruit(stub, name, def)
	local fname = def.name and stub .. def.name or stub .. "fruit_" .. name
	def.name = nil

	local fdef = table_merge(tpl_fruit, def, {_vl_wood = name, groups = {[name] = 1}})
	core.register_craftitem(fname, fdef)
	return fname
end

-- Main function to register a new wood variety.
-- See `API.md` for proper documentation on usage and the definition table.
function vl_trees.register_wood(name, def)
	assert(name and type(name) == "string", "Invalid name string for wood type")
	assert(def and type(def) == "table", "Invalid definition table for wood type")

	local modname = core.get_current_modname()
	def.__modname = modname
	local stub = modname .. ":"
	-- stub = "vl_larch:"
	-- name = "larch"
	-- => lname = "vl_larch:" .. "leaves_" .. "larch" -- ... etc

	if def.trunk and def.bark and type(def.trunk) == "table" and type(def.bark) == "table" then
		def.trunk, def.bark = register_trunk_and_bark(stub, name, def.trunk, def.bark)
	end

	if def.stripped_trunk and def.stripped_bark and type(def.stripped_trunk) == "table" and type(def.stripped_bark) == "table" then
		def.stripped_trunk, def.stripped_bark = register_trunk_and_bark(stub, name, def.stripped_trunk, def.stripped_bark, true)
	end

	def.planks = type(def.planks) == "table" and register_planks(stub, name, def.planks) or def.planks

	def.fruit = type(def.fruit) == "table" and register_fruit(stub, name, def.fruit) or def.fruit

	def.params = def.params or {}
	def.params.min_light = def.params.min_light or 9
	def.params.min_soil_type = def.params.min_soil_type or 1

	local tbt_mode
	if def.schematic_2x2 then
		tbt_mode = def.schematic and 1 or 2
	end

	def.sapling = type(def.sapling) == "table" and register_sapling(stub, name, def.sapling, def.params.min_soil_type, tbt_mode) or def.sapling

	def.drop_chances = table_merge(tpl_drop_chances, def.drop_chances)
	def.leaves = type(def.leaves) == "table" and register_leaves(stub, name, def.leaves, def.drop_chances, def.sapling, def.fruit) or def.leaves

	registered_woods[name] = def
end

-- Main function to register a callback for the woods to use them.
-- * `global_override` is an optional override table for the global woods table
-- * `callback` is called in a loop with name and definition table of a wood
--
-- See `API.md` for proper documentation on usage.
local overrides, callbacks = {}, {}
function vl_trees.register_on_woods_added(callback, global_override)
	assert(callback and type(callback) == "function", "Invalid callback function")

	if global_override then
		overrides[#overrides+1] = global_override
	end
	callbacks[#callbacks+1] = callback
end

core.register_on_mods_loaded(function()
	for name, ndef in pairs(core.registered_nodes) do
		-- populate the leafdecay tabs
		local cid = core.get_content_id(name)
		tree_tab[cid] = core.get_item_group(name, "tree") ~= 0 and true or nil
		if core.get_item_group(name, "leaves") ~= 0 and ndef._mcl_leaves then
			local def = {
				c_leaves = core.get_content_id(ndef._mcl_leaves),
				c_orphan_leaves = core.get_content_id(ndef._mcl_orphan_leaves),
			}
			leaves_tab[cid] = def
			orphan_tab[cid] = core.get_item_group(name, "orphan_leaves") ~= 0 and def or nil
		end

		-- set log on_construct/after_destruct in global loop for compatibility with mods
		if core.get_item_group(name, "tree") ~= 0 then
			local old_on_cons = ndef.on_construct
			local old_after_dest = ndef.after_destruct
			core.override_item(name, {
				on_construct = function(pos)
					if old_on_cons then
						old_on_cons(pos)
					end
					update_leaves(pos)
				end,
				after_destruct = function(pos)
					if old_after_dest then
						old_after_dest(pos)
					end
					update_far_away_leaves(pos)
					update_leaves(pos, 0)
				end,
			})
		end
	end

	-- NOTE: using `unpack` might not be reliable beyond ~8k overrides
	registered_woods = table_merge(registered_woods, unpack(overrides))

	for name, def in pairs(registered_woods) do
		for _, callback in ipairs(callbacks) do
			callback(name, def)
		end
	end
end)
