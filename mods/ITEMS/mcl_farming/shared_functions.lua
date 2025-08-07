-- Possible future improvements:
-- * rewrite to use node timers instead of ABMs, but needs benchmarking
-- * redesign the catch-up logic
-- * switch to exponentially-weighted moving average for light instead using a single variable to conserve IO
--
local math = math

local vector = vector
local random = math.random
local floor = math.floor

local plant_lists = {}
mcl_farming.plant_lists = plant_lists -- export
local plant_nodename_to_id = {} -- map nodes to plants
local plant_step_from_name = {} -- map nodes to growth steps

local growth_factor = tonumber(core.settings:get("vl_plant_growth")) or 1.0

-- wetness of the surroundings
-- dry farmland = 1 point
-- wet farmland = 3 points
-- center point gives + 1 point, so 2 resp. 4
-- neighbors only 25%
local function get_moisture_level(pos)
	local n = vector.offset(pos, 0, -1, 0)
	local totalm = 1
	for z = -1,1 do
		n.z = pos.z + z
		for x = -1,1 do
			n.x = pos.x + x
			local ndef = core.registered_nodes[core.get_node(n).name]
			local soil = ndef and ndef.groups.soil
			if soil and soil >= 2 then
				local m = soil > 2 and 3 or 1
				-- corners have less weight
				if x ~= 0 or z ~= 0 then m = m * 0.25 end
				totalm = totalm + m
			end
		end
	end
	return totalm
end

-- moisture penalty function:
-- 0.5 if both on the x axis and the z axis at least one of the same plants grows
-- 0.5 if at least one diagonal neighbor is the same
-- 1.0 otherwise
-- we cannot use the names directly, because growth is encoded in the names
local function get_same_crop_penalty(pos)
	local name = core.get_node(pos).name
	local plant = plant_nodename_to_id[name]
	if not plant then return 1 end
	local n = vector.copy(pos)
	-- check adjacent positions, avoid vector allocations and reduce node accesses
	n.x = pos.x - 1
	local dx = plant_nodename_to_id[core.get_node(n).name] == plant
	n.x = pos.x + 1
	dx = dx or plant_nodename_to_id[core.get_node(n).name] == plant
	if dx then -- no need to check z otherwise
		n.x = pos.x
		n.z = pos.z - 1
		local dz = plant_nodename_to_id[core.get_node(n).name] == plant
		n.z = pos.z + 1
		dz = dz or plant_nodename_to_id[core.get_node(n).name] == plant
		if dz then return 0.5 end
	end
	-- check diagonals, clockwise
	n.x, n.z = pos.x - 1, pos.z - 1
	if plant_nodename_to_id[core.get_node(n).name] == plant then return 0.5 end
	n.x = pos.x + 1
	if plant_nodename_to_id[core.get_node(n).name] == plant then return 0.5 end
	n.z = pos.z + 1
	if plant_nodename_to_id[core.get_node(n).name] == plant then return 0.5 end
	n.x = pos.x - 1
	if plant_nodename_to_id[core.get_node(n).name] == plant then return 0.5 end
	return 1
end

function mcl_farming:add_plant(identifier, full_grown, names, interval, chance)
	interval = growth_factor > 0 and (interval / growth_factor) or 0
	local plant_info = {}
	plant_info.full_grown = full_grown
	plant_info.names = names
	plant_info.interval = interval
	plant_info.chance = chance
	plant_nodename_to_id[full_grown] = identifier
	for _, nodename in pairs(names) do
		plant_nodename_to_id[nodename] = identifier
	end
	for i, name in ipairs(names) do
		plant_step_from_name[name] = i
	end
	plant_lists[identifier] = plant_info
	if interval == 0 then return end -- growth disabled
	core.register_abm({
		label = string.format("Farming plant growth (%s)", identifier),
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			mcl_farming:grow_plant(identifier, pos, node, 1, false)
		end,
	})
end

-- Attempts to advance a plant at pos by one or more growth stages (if possible)
-- identifier: Identifier of plant as defined by mcl_farming:add_plant
-- pos: Position
-- node: Node table
-- stages: Number of stages to advance (optional, defaults to 1)
-- ignore_light_water: if true, ignore light and water requirements for growing
-- Returns true if plant has been grown by 1 or more stages.
-- Returns false if nothing changed.
function mcl_farming:grow_plant(identifier, pos, node, stages, ignore_light_water)
	-- number of missed interval ticks, for catch-up in block loading
	local plant_info = plant_lists[identifier]
	if not plant_info then return end
	if not ignore_light_water then
		if (core.get_node_light(pos, 0.5) or 0) < 0 then return false end -- day light
		local odds = floor(25 / (get_moisture_level(pos) * get_same_crop_penalty(pos))) + 1
		for i = 1,stages do
			-- compared to info from the MC wiki, our ABM runs a third as often, hence we use triple the chance
			if random() * odds >= 3 then stages = stages - 1 end
		end
	end

	if stages == 0 then return false end
	local step = plant_step_from_name[node.name]
	if step == nil then return false end
	core.set_node(pos, {
		name = plant_info.names[step + stages] or plant_info.full_grown,
		param = node.param,
		param2 = node.param2,
	})
	return true
end

function mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	if not pt or pt.type ~= "node" then return end

	-- Use pointed node's on_rightclick function first, if present
	local node = core.get_node(pt.under)
	if placer and not placer:get_player_control().sneak then
		if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
			return core.registered_nodes[node.name].on_rightclick(pt.under, node, placer, itemstack) or itemstack
		end
	end

	if core.get_node(pt.above).name ~= "air" then return end
	local farmland = core.registered_nodes[core.get_node(vector.offset(pt.above, 0, -1, 0)).name]
	if not farmland or (farmland.groups.soil or 0) < 2 then return end
	core.sound_play(core.registered_nodes[plantname].sounds.place, { pos = pt.above }, true)
	core.add_node(pt.above, { name = plantname, param2 = core.registered_nodes[plantname].place_param2 })

	if not core.is_creative_enabled(placer:get_player_name()) then itemstack:take_item() end
	return itemstack
end


--[[ Helper function to create a gourd (e.g. melon, pumpkin), the connected stem nodes as

- full_unconnected_stem: itemstring of the full-grown but unconnected stem node. This node must already be done
- connected_stem_basename: prefix of the itemstrings used for the 4 connected stem nodes to create
- stem_itemstring: Desired itemstring of the fully-grown unconnected stem node
- stem_def: Partial node definition of the fully-grown unconnected stem node. Many fields are already defined. You need to add `tiles` and `description` at minimum. Don't define on_construct without good reason
- stem_drop: Drop probability table for all stem
- gourd_itemstring: Desired itemstring of the full gourd node
- gourd_def: (almost) full definition of the gourd node. This function will add on_construct and after_destruct to the definition for unconnecting any connected stems
- grow_interval: Will attempt to grow a gourd periodically at this interval in seconds
- grow_chance: Chance of 1/grow_chance to grow a gourd next to the full unconnected stem after grow_interval has passed. Must be a natural number
- connected_stem_texture: Texture of the connected stem
]]


function mcl_farming:add_gourd(full_unconnected_stem, connected_stem_basename, stem_itemstring, stem_def, stem_drop, gourd_itemstring, gourd_def, grow_interval, grow_chance, connected_stem_texture)
	grow_interval = growth_factor > 0 and (grow_interval / growth_factor) or 0
	local connected_stem_names = {
		connected_stem_basename .. "_r",
		connected_stem_basename .. "_l",
		connected_stem_basename .. "_t",
		connected_stem_basename .. "_b" }

	-- Register gourd
	if not gourd_def.after_destruct then
		gourd_def.after_destruct = function(blockpos, oldnode)
			-- Disconnect any connected stems, turning them back to normal stems
			-- four directions, but avoid using a table
			-- opposite directions to above, as we go from groud to stem now!
			local stempos = vector.offset(blockpos, -1, 0, 0)
			if core.get_node(stempos).name == connected_stem_names[1] then
				core.swap_node(stempos, { name = full_unconnected_stem })
			end
			local stempos = vector.offset(blockpos, 1, 0, 0)
			if core.get_node(stempos).name == connected_stem_names[2] then
				core.swap_node(stempos, { name = full_unconnected_stem })
			end
			local stempos = vector.offset(blockpos, 0, 0, -1)
			if core.get_node(stempos).name == connected_stem_names[3] then
				core.swap_node(stempos, { name = full_unconnected_stem })
			end
			local stempos = vector.offset(blockpos, 0, 0, 1)
			if core.get_node(stempos).name == connected_stem_names[4] then
				core.swap_node(stempos, { name = full_unconnected_stem })
			end
		end
	end
	core.register_node(gourd_itemstring, gourd_def)

	-- Register unconnected stem

	-- Default values for the stem definition
	if not stem_def.selection_box then
		stem_def.selection_box = { type = "fixed", fixed = { { -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 } } }
	end
	stem_def.paramtype = stem_def.paramtype or "light"
	stem_def.drawtype = stem_def.drawtype or "plantlike"
	stem_def.walkable = stem_def.walkable or false
	stem_def.sunlight_propagates = stem_def.sunlight_propagates == nil or stem_def.sunlight_propagates
	stem_def.drop = stem_def.drop or stem_drop
	stem_def.groups = stem_def.groups or { dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow = 1 }
	stem_def.sounds = stem_def.sounds or mcl_sounds.node_sound_leaves_defaults()
	core.register_node(stem_itemstring, stem_def)
	plant_nodename_to_id[stem_itemstring] = stem_itemstring

	-- Register connected stems

	local connected_stem_tiles = {
		{ "blank.png", -- top
		  "blank.png", -- bottom
		  "blank.png", -- right
		  "blank.png", -- left
		  connected_stem_texture, -- back
		  connected_stem_texture .. "^[transformFX" -- front
		},
		{ "blank.png", -- top
		  "blank.png", -- bottom
		  "blank.png", -- right
		  "blank.png", -- left
		  connected_stem_texture .. "^[transformFX", -- back
		  connected_stem_texture, -- front
		},
		{ "blank.png", -- top
		  "blank.png", -- bottom
		  connected_stem_texture .. "^[transformFX", -- right
		  connected_stem_texture, -- left
		  "blank.png", -- back
		  "blank.png", -- front
		},
		{ "blank.png", -- top
		  "blank.png", -- bottom
		  connected_stem_texture, -- right
		  connected_stem_texture .. "^[transformFX", -- left
		  "blank.png", -- back
		  "blank.png", -- front
		}
	}
	local connected_stem_nodebox = {
		{ -0.5, -0.5, 0, 0.5, 0.5, 0 },
		{ -0.5, -0.5, 0, 0.5, 0.5, 0 },
		{ 0, -0.5, -0.5, 0, 0.5, 0.5 },
		{ 0, -0.5, -0.5, 0, 0.5, 0.5 },
	}
	local connected_stem_selectionbox = {
		{ -0.1, -0.5, -0.1, 0.5, 0.2, 0.1 },
		{ -0.5, -0.5, -0.1, 0.1, 0.2, 0.1 },
		{ -0.1, -0.5, -0.1, 0.1, 0.2, 0.5 },
		{ -0.1, -0.5, -0.5, 0.1, 0.2, 0.1 },
	}

	for i = 1, 4 do
		core.register_node(connected_stem_names[i], {
			_doc_items_create_entry = false,
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			drop = stem_drop,
			drawtype = "nodebox",
			node_box = { type = "fixed", fixed = connected_stem_nodebox[i] },
			selection_box = { type = "fixed", fixed = connected_stem_selectionbox[i] },
			tiles = connected_stem_tiles[i],
			use_texture_alpha = "clip",
			groups = { dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow = 1 },
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			_mcl_blast_resistance = 0,
		})
		plant_nodename_to_id[connected_stem_names[i]] = stem_itemstring

		if core.get_modpath("doc") then
			doc.add_entry_alias("nodes", full_unconnected_stem, "nodes", connected_stem_names[i])
		end
	end

	if grow_interval == 0 then return end
	core.register_abm({
		label = "Grow gourd stem to gourd (" .. full_unconnected_stem .. " → " .. gourd_itemstring .. ")",
		nodenames = { full_unconnected_stem },
		neighbors = { "air" },
		interval = grow_interval,
		chance = grow_chance,
		action = function(stempos)
			local light = core.get_node_light(stempos, 0.5)
			if not light or light < 9 then return end
			-- Pick one neighbor and check if it can be used to grow
			local dir = random(1, 4) -- pick direction at random
			local neighbor = (dir == 1 and vector.offset(stempos, 1, 0, 0))
				or (dir == 2 and vector.offset(stempos, -1, 0, 0))
				or (dir == 3 and vector.offset(stempos, 0, 0, 1))
				or  vector.offset(stempos, 0, 0, -1)
			if core.get_node(neighbor).name ~= "air" then return end -- occupied
			-- check for suitable floor -- in contrast to MC, we think everything solid is fine
			local floorpos = vector.offset(neighbor, 0, -1, 0)
			local floorname = core.get_node(floorpos).name
			local floordef = core.registered_nodes[floorname]
			if not floordef or not floordef.walkable then return end

			-- check moisture level
			local odds = floor(25 / (get_moisture_level(stempos) * get_same_crop_penalty(stempos))) + 1
			-- we triple the odds, and rather call the ABM less often
			if random() * odds >= 3 then return end

			core.swap_node(stempos, { name = connected_stem_names[dir] })
			if gourd_def.paramtype2 == "facedir" then
				local p2 = (dir == 1 and 3) or (dir == 2 and 1) or (dir == 3 and 2) or 0
				core.add_node(neighbor, { name = gourd_itemstring, param2 = p2 })
			else
				core.add_node(neighbor, { name = gourd_itemstring })
			end

			-- Reset farmland, etc. to dirt when the gourd grows on top
			if (floordef.groups.dirtifies_below_solid or 0) > 0 then
				core.set_node(floorpos, { name = "mcl_core:dirt" })
			end
		end,
	})
end

-- Used for growing gourd stems. Returns the intermediate color between startcolor and endcolor at a step
-- * startcolor: ColorSpec in table form for the stem in its lowest growing stage
-- * endcolor: ColorSpec in table form for the stem in its final growing stage
-- * step: The nth growth step. Counting starts at 1
-- * step_count: The number of total growth steps
function mcl_farming:stem_color(startcolor, endcolor, step, step_count)
	local mix = (step - 1) / (step_count - 1)
	return string.format("#%02X%02X%02X",
		math.max(0, math.min(255, math.round((1 - mix) * startcolor.r + mix * endcolor.r))),
		math.max(0, math.min(255, math.round((1 - mix) * startcolor.g + mix * endcolor.g))),
		math.max(0, math.min(255, math.round((1 - mix) * startcolor.b + mix * endcolor.b))))
end

--[[Get a callback that either eats the item or plants it.

Used for on_place callbacks for craft items which are seeds that can also be consumed.
]]
function mcl_farming:get_seed_or_eat_callback(plantname, hp_change)
	return function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)
		or core.do_item_eat(hp_change, nil, itemstack, placer, pointed_thing)
	end
end

core.register_lbm({
	label = "Add growth for unloaded farming plants",
	name = "mcl_farming:growth",
	nodenames = { "group:plant" },
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		local identifier = plant_nodename_to_id[node.name]
		if not identifier then return end

		local plant_info = plant_lists[identifier]
		if not plant_info then return end
		local rolls = floor(dtime_s / plant_info.interval)
		if rolls <= 0 then return end
		-- simulate how often the block will be ticked
		local stages = 0
		for i = 1,rolls do
			if random(1, plant_info.chance) == 1 then stages = stages + 1 end
		end
		if stages > 0 then
			mcl_farming:grow_plant(identifier, pos, node, stages, false)
		end
	end,
})

