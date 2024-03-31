local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
mod.RAIL_GROUPS = {
	STANDARD = 1,
	CURVES = 2,
}
local S = minetest.get_translator(modname)
local table_merge = mcl_util.table_merge
local check_connection_rules = mod.check_connection_rules
local update_rail_connections = mod.update_rail_connections
local north = mod.north
local south = mod.south
local east = mod.east
local west = mod.west

-- Setup shared text
local railuse = S(
	"Place them on the ground to build your railway, the rails will automatically connect to each other and will"..
	" turn into curves, T-junctions, crossings and slopes as needed."
)
mod.text = mod.text or {}
mod.text.railuse = railuse

local function drop_railcarts(pos)
	-- Scan for minecarts in this pos and force them to execute their "floating" check.
	-- Normally, this will make them drop.
	local objs = minetest.get_objects_inside_radius(pos, 1)
	for o=1, #objs do
		local le = objs[o]:get_luaentity()
		if le then
			-- All entities in this mod are minecarts, so this works
			if string.sub(le.name, 1, 14) == "mcl_minecarts:" then
				le._last_float_check = mcl_minecarts.check_float_time
			end
		end
	end
end

local RAIL_DEFAULTS = {
	is_ground_content = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	stack_max = 64,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
	after_destruct = drop_railcarts,
}
local RAIL_DEFAULT_GROUPS = {
	handy=1, pickaxey=1,
	attached_node=1,
	rail=1,
	connect_to_raillike=minetest.raillike_group("rail"),
	dig_by_water=0,destroy_by_lava_flow=0,
	transport=1
}

-- Template rail function
local function register_rail(itemstring, tiles, def_extras, creative)
	local groups = table.copy(RAIL_DEFAULT_GROUPS)
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local ndef = {
		drawtype = "raillike",
		tiles = tiles,
		inventory_image = tiles[1],
		wield_image = tiles[1],
		groups = groups,
	}
	table_merge(ndef, RAIL_DEFAULTS)
	ndef.walkable = false -- Old behavior
	table_merge(ndef, def_extras)
	minetest.register_node(itemstring, ndef)
end

-- Now get the translator after we have finished using S for other things
mod.text = mod.text or {}
mod.text.railuse = railuse
local BASE_DEF = {
	description = S("New Rail"), -- Temporary name to make debugging easier
	_tt_help = S("Track for minecarts"),
	_doc_items_usagehelp = railuse,
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction."),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		update_rail_connections(pos, true)
	end,
	drawtype = "nodebox",
	groups = RAIL_DEFAULT_GROUPS,
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/15}
		}
	},
	paramtype = "light",
	paramtype2 = "facedir",
}
table_merge(BASE_DEF, RAIL_DEFAULTS) -- Merge together old rail values

local SLOPED_RAIL_DEF = table.copy(BASE_DEF)
table_merge(SLOPED_RAIL_DEF,{
	drawtype = "mesh",
	mesh = "sloped_track.obj",
	collision_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5,  0.5,  0.0,  0.5 },
			{ -0.5,  0.0,  0.0,  0.5,  0.5,  0.5 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5,  0.5,  0.0,  0.5 },
			{ -0.5,  0.0,  0.0,  0.5,  0.5,  0.5 }
		}
	}
})

local function register_rail_v2(itemstring, ndef)
	assert(ndef.tiles)

	-- Extract out the craft recipe
	local craft = ndef.craft
	ndef.craft = nil

	-- Add sensible defaults
	if not ndef.inventory_image then ndef.inventory_image = ndef.tiles[1] end
	if not ndef.wield_image then ndef.wield_image = ndef.tiles[1] end

	print("registering rail "..itemstring.." with definition: "..dump(ndef))

	-- Make registrations
	minetest.register_node(itemstring, ndef)
	if craft then minetest.register_craft(craft) end
end
mod.register_rail = register_rail_v2

local function rail_dir_straight(pos, dir, node)
	local function inside(pos,dir,node)
		if node.param2 == 0 or node.param2 == 2 then
			if vector.equals(dir, north) then
				return north
			else
				return south
			end
		else
			if vector.equals(dir,east) then
				return east
			else
				return west
			end
		end
	end

	local raw_dir = inside(pos, dir, node)

	-- Handle reversing if there is a solid block in the next position
	-- Only do this for straight tracks
	local next_pos = vector.add(pos, raw_dir)
	local next_node = minetest.get_node(next_pos)
	local node_def = minetest.registered_nodes[next_node.name]
	if node_def and node_def.groups and node_def.groups.solid then
		-- Reverse the direction without giving -0 members
		return vector.direction(next_pos, pos)
	else
		return raw_dir
	end
end
local function rail_dir_curve(pos, dir, node)
	if node.param2 == 0 then
		-- South and East
		if vector.equals(dir, south) then return south end
		if vector.equals(dir, north) then return east end
		if vector.equals(dir, west) then return south end
		if vector.equals(dir, east) then return east end
	elseif node.param2 == 1 then
		-- South and West
		if vector.equals(dir, south) then return south end
		if vector.equals(dir, north) then return west end
		if vector.equals(dir, west) then return west end
		if vector.equals(dir, east) then return south end
	elseif node.param2 == 2 then
		-- North and West
		if vector.equals(dir, south) then return west end
		if vector.equals(dir, north) then return north end
		if vector.equals(dir, west) then return west end
		if vector.equals(dir, east) then return north end
	elseif node.param2 == 3 then
		-- North and East
		if vector.equals(dir, south) then return east end
		if vector.equals(dir, north) then return north end
		if vector.equals(dir, west) then return north end
		if vector.equals(dir, east) then return east end
	end
end

local function rail_dir_tee(pos, dir, node)
	-- TODO: implement
	return north
end

local function rail_dir_cross(pos, dir, node)
	-- Always continue in the same direction. No direction changes allowed
	return dir
end

local function register_straight_rail(base_name, tiles, def)
	def = def or {}
	local base_def = table.copy(BASE_DEF)
	table_merge(base_def,{
		tiles = { tiles[1] },
		_mcl_minecarts = { base_name = base_name },
		drop = base_name,
		groups = {
			rail = mod.RAIL_GROUPS.STRANDARD,
		},
		_mcl_minecarts = {
			base_name = base_name,
			get_next_dir = rail_dir_straight
		},
	})
	table_merge(base_def, def)

	-- Register the base node
	mod.register_rail(base_name, base_def)
	base_def.craft = false
	table_merge(base_def,{
		groups = {
			not_in_creative_inventory = 1,
		},
	})

	-- Sloped variant
	mod.register_rail_sloped(base_name.."_sloped", table_merge(table.copy(base_def),{
		description = S("Sloped Rail"), -- Temporary name to make debugging easier
		_mcl_minecarts = {
			get_next_dir = rail_dir_cross,
		},
		tiles = { tiles[1] },
	}))
end
mod.register_straight_rail = register_straight_rail

local function register_curves_rail(base_name, tiles, def)
	def = def or {}
	local base_def = table.copy(BASE_DEF)
	table_merge(base_def,{
		_mcl_minecarts = { base_name = base_name },
		groups = {
			rail = mod.RAIL_GROUPS.CURVES
		},
		drop = base_name,
	})
	table_merge(base_def, def)

	-- Register the base node
	mod.register_rail(base_name, table_merge(table.copy(base_def),{
		tiles = { tiles[1] },
		_mcl_minecarts = {
			get_next_dir = rail_dir_straight
		}
	}))

	-- Update for other variants
	base_def.craft = nil
	table_merge(base_def, {
		groups = {
			not_in_creative_inventory = 1
		}
	})

	-- Corner variants
	mod.register_rail(base_name.."_corner", table_merge(table.copy(base_def),{
		tiles = { tiles[2] },
		_mcl_minecarts = {
			get_next_dir = rail_dir_curve,
		},
	}))

	-- Tee variants
	mod.register_rail(base_name.."_tee_off", table_merge(table.copy(base_def),{
		tiles = { tiles[3] },
		groups = {
			not_in_creative_inventory = 1,
		},
		mesecons = {
			effector = {
				action_on = function(pos, node)
					local new_node = {name = base_name.."_tee_on", param2 = node.param2}
					minetest.swap_node(pos, new_node)
				end,
				rules = mesecon.rules.alldirs,
			}
		}
	}))
	mod.register_rail(base_name.."_tee_on", table_merge(table.copy(base_def),{
		tiles = { tiles[4] },
		_mcl_minecarts = {
			get_next_dir = rail_dir_tee,
		},
		mesecons = {
			effector = {
				action_off = function(pos, node)
					local new_node = {name = base_name.."_tee_off", param2 = node.param2}
					minetest.swap_node(pos, new_node)
				end,
				rules = mesecon.rules.alldirs,
			}
		}
	}))

	-- Sloped variant
	mod.register_rail_sloped(base_name.."_sloped", table_merge(table.copy(base_def),{
		description = S("Sloped Rail"), -- Temporary name to make debugging easier
		_mcl_minecarts = {
			get_next_dir = rail_dir_cross,
		},
		tiles = { tiles[1] },
	}))

	-- Cross variant
	mod.register_rail(base_name.."_cross", table_merge(table.copy(base_def),{
		tiles = { tiles[5] },
	}))
end
mod.register_curves_rail = register_curves_rail

local function register_rail_sloped(itemstring, def)
	assert(def.tiles)

	-- Build rail groups
	local groups = table.copy(RAIL_DEFAULT_GROUPS)
	if def.groups then table_merge(groups, def.groups) end
	def.groups = groups

	-- Build the node definition
	local ndef = table.copy(SLOPED_RAIL_DEF)
	table_merge(ndef, def)

	-- Add sensible defaults
	if not ndef.inventory_image then ndef.inventory_image = ndef.tiles[1] end
	if not ndef.wield_image then ndef.wield_image = ndef.tiles[1] end

	--print("registering sloped rail "..itemstring.." with definition: "..dump(ndef))

	-- Make registrations
	minetest.register_node(itemstring, ndef)
	if craft then minetest.register_craft(craft) end
end
mod.register_rail_sloped = register_rail_sloped

-- Redstone rules
local rail_rules_long =
{{x=-1,  y= 0, z= 0, spread=true},
 {x= 1,  y= 0, z= 0, spread=true},
-- {x= 0,  y=-1, z= 0, spread=true},
 {x= 0,  y= 1, z= 0, spread=true},
 {x= 0,  y= 0, z=-1, spread=true},
 {x= 0,  y= 0, z= 1, spread=true},

 {x= 1, y= 1, z= 0},
 {x= 1, y=-1, z= 0},
 {x=-1, y= 1, z= 0},
 {x=-1, y=-1, z= 0},
 {x= 0, y= 1, z= 1},
 {x= 0, y=-1, z= 1},
 {x= 0, y= 1, z=-1},
 {x= 0, y=-1, z=-1}}

local rail_rules_short = mesecon.rules.pplate

-- Normal rail
mod.register_curves_rail("mcl_minecarts:rail_v2", {
	"default_rail.png", 
	"default_rail_curved.png",
	"default_rail_t_junction.png",
	"default_rail_t_junction_on.png",
	"default_rail_crossing.png"
},{
	description = S("Rail"),
	_tt_help = S("Track for minecarts"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction."),
	_doc_items_usagehelp = railuse,
	craft = {
		output = "mcl_minecarts:rail_v2 16",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		}
	},
})
register_rail("mcl_minecarts:rail", {"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"}, {}, false ) -- deprecated

-- Powered rail (off = brake mode)
mod.register_straight_rail("mcl_minecarts:golden_rail_v2",{ "mcl_minecarts_rail_golden.png" },{
	description = S("Powered Rail"),
	_tt_help = S("Track for minecarts").."\n"..S("Speed up when powered, slow down when not powered"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Powered rails are able to accelerate and brake minecarts."),
	_doc_items_usagehelp = railuse .. "\n" .. S("Without redstone power, the rail will brake minecarts. To make this rail accelerate"..
		" minecarts, power it with redstone power."),
	_doc_items_create_entry = false,
	_rail_acceleration = -3,
	_max_acceleration_velocity = 8,
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			offstate = "mcl_minecarts:golden_rail_v2",
			onstate = "mcl_minecarts:golden_rail_v2_on",
			rules = rail_rules_long,
		},
	},
	drop = "mcl_minecarts:golden_rail_v2",
	craft = {
		output = "mcl_minecarts:golden_rail_v2 6",
		recipe = {
			{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
			{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
			{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
		}
	}
})
register_rail("mcl_minecarts:golden_rail", {"mcl_minecarts_rail_golden.png", "mcl_minecarts_rail_golden_curved.png", "mcl_minecarts_rail_golden_t_junction.png", "mcl_minecarts_rail_golden_crossing.png"}, {}, false ) -- deprecated

-- Powered rail (on = acceleration mode)
mod.register_straight_rail("mcl_minecarts:golden_rail_v2_on",{ "mcl_minecarts_rail_golden_powered.png" },{
	_doc_items_create_entry = false,
	_rail_acceleration = 4,
	_max_acceleration_velocity = 8,
	groups = {
		not_in_creative_inventory = 1,
	},
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			offstate = "mcl_minecarts:golden_rail_v2",
			onstate = "mcl_minecarts:golden_rail_v2_on",
			rules = rail_rules_long,
		},
	},
	drop = "mcl_minecarts:golden_rail_v2",
})
register_rail("mcl_minecarts:golden_rail_on", {"mcl_minecarts_rail_golden_powered.png", "mcl_minecarts_rail_golden_curved_powered.png", "mcl_minecarts_rail_golden_t_junction_powered.png", "mcl_minecarts_rail_golden_crossing_powered.png"}, { }, false ) -- deprecated

-- Activator rail (off)
mod.register_straight_rail("mcl_minecarts:activator_rail_v2", {"mcl_minecarts_rail_activator.png"},{
	description = S("Activator Rail"),
	_tt_help = S("Track for minecarts").."\n"..S("Activates minecarts when powered"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Activator rails are used to activate special minecarts."),
	_doc_items_usagehelp = railuse .. "\n" .. S("To make this rail activate minecarts, power it with redstone power and send a minecart over this piece of rail."),
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			offstate = "mcl_minecarts:activator_rail_v2",
			onstate = "mcl_minecarts:activator_rail_v2_on",
			rules = rail_rules_long,
		},
	},
	craft = {
		output = "mcl_minecarts:activator_rail_v2 6",
		recipe = {
			{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mesecons_torch:mesecon_torch_on", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
		}
	},
})
register_rail("mcl_minecarts:activator_rail", {"mcl_minecarts_rail_activator.png", "mcl_minecarts_rail_activator_curved.png", "mcl_minecarts_rail_activator_t_junction.png", "mcl_minecarts_rail_activator_crossing.png"}, {} ) -- deprecated

-- Activator rail (on)
mod.register_straight_rail("mcl_minecarts:activator_rail_v2_on", {"mcl_minecarts_rail_activator_powered.png"},{
	_doc_items_create_entry = false,
	groups = {
		not_in_creative_inventory = 1,
	},
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			offstate = "mcl_minecarts:activator_rail_v2",
			onstate = "mcl_minecarts:activator_rail_v2_on",
			rules = rail_rules_long,
		},
		effector = {
			-- Activate minecarts
			action_on = function(pos, node)
				local pos2 = { x = pos.x, y =pos.y + 1, z = pos.z }
				local objs = minetest.get_objects_inside_radius(pos2, 1)
				for _, o in pairs(objs) do
					local l = o:get_luaentity()
					if l and string.sub(l.name, 1, 14) == "mcl_minecarts:" and l.on_activate_by_rail then
						l:on_activate_by_rail()
					end
				end
			end,
		},

	},
	_mcl_minecarts_on_enter = function(pos, cart)
		if cart.on_activate_by_rail then
			cart:on_activate_by_rail()
		end
	end,
	drop = "mcl_minecarts:activator_rail_v2",
})
register_rail("mcl_minecarts:activator_rail_on", {"mcl_minecarts_rail_activator_powered.png", "mcl_minecarts_rail_activator_curved_powered.png", "mcl_minecarts_rail_activator_t_junction_powered.png", "mcl_minecarts_rail_activator_crossing_powered.png"}, { }, false ) -- deprecated

-- Detector rail (off)
mod.register_straight_rail("mcl_minecarts:detector_rail_v2",{"mcl_minecarts_rail_detector.png"},{
	description = S("Detector Rail"),
	_tt_help = S("Track for minecarts").."\n"..S("Emits redstone power when a minecart is detected"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. A detector rail is able to detect a minecart above it and powers redstone mechanisms."),
	_doc_items_usagehelp = railuse .. "\n" .. S("To detect a minecart and provide redstone power, connect it to redstone trails or redstone mechanisms and send any minecart over the rail."),
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rail_rules_short,
		},
	},
	_mcl_minecarts_on_enter = function(pos, cart)
		local node = minetest.get_node(pos)

		local newnode = {
			name = "mcl_minecarts:detector_rail_v2_on",
			param2 = node.param2
		}
		minetest.swap_node( pos, newnode )
		mesecon.receptor_on(pos)
	end,
	craft = {
		output = "mcl_minecarts:detector_rail_v2 6",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mesecons_pressureplates:pressure_plate_stone_off", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mesecons:redstone", "mcl_core:iron_ingot"},
		}
	}
})
register_rail("mcl_minecarts:detector_rail", {"mcl_minecarts_rail_detector.png", "mcl_minecarts_rail_detector_curved.png", "mcl_minecarts_rail_detector_t_junction.png", "mcl_minecarts_rail_detector_crossing.png"}, {} ) -- deprecated

-- Detector rail (on)
mod.register_straight_rail("mcl_minecarts:detector_rail_v2_on",{"mcl_minecarts_rail_detector_powered.png"},{
	groups = {
		not_in_creative_inventory = 1,
	},
	_doc_items_create_entry = false,
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rail_rules_short,
		},
	},
	_mcl_minecarts_on_leave = function(pos, cart)
		local node = minetest.get_node(pos)

		local newnode = {
			name = "mcl_minecarts:detector_rail",
			param2 = node.param2
		}
		minetest.swap_node( pos, newnode )
		mesecon.receptor_off(pos)
	end,
	drop = "mcl_minecarts:detector_rail_v2",
})
register_rail("mcl_minecarts:detector_rail_on",	{"mcl_minecarts_rail_detector_powered.png", "mcl_minecarts_rail_detector_curved_powered.png", "mcl_minecarts_rail_detector_t_junction_powered.png", "mcl_minecarts_rail_detector_crossing_powered.png"}, { }, false ) -- deprecated

-- Aliases
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_minecarts:golden_rail", "nodes", "mcl_minecarts:golden_rail_on")
end

