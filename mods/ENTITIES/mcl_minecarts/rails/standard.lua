local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts

-- This is a candidate for adding to mcl_util
local function table_merge(base, overlay)
	for k,v in pairs(overlay) do
		if type(base[k]) == "table" then
			table_merge(base[k], v)
		else
			base[k] = v
		end
	end
	return base
end

local north = vector.new( 0, 0, 1); local N = 1
local south = vector.new( 0, 0,-1); local S = 2 -- Note: this is overwritten below
local east  = vector.new( 1, 0, 0); local E = 4
local west  = vector.new(-1, 0, 0); local W = 8

local HORIZONTAL_CONNECTIONS = { north, south, east, west }
local HORIZONTAL_STANDARD_MAPPINGS = {
	[N]       = { "", 0 },
	[S]       = { "", 0 },
	[N+S]     = { "", 0 },

	[E]       = { "", 1 },
	[W]       = { "", 1 },
	[E+W]     = { "", 1 },
}
local HORIZONTAL_CURVES_MAPPINGS = {
	[N+E]     = { "_corner", 3 },
	[N+W]     = { "_corner", 2 },
	[S+E]     = { "_corner", 0 },
	[S+W]     = { "_corner", 1 },

	[N+E+W]   = { "_tee_off", 3 },
	[S+E+W]   = { "_tee_off", 1 },
	[N+S+E]   = { "_tee_off", 0 },
	[N+S+W]   = { "_tee_off", 2 },

--	[N+S+E+W] = "_cross",
}
table_merge(HORIZONTAL_CURVES_MAPPINGS, HORIZONTAL_STANDARD_MAPPINGS)
local HORIZONTAL_MAPPINGS_BY_RAIL_GROUP = {
	[1] = HORIZONTAL_STANDARD_MAPPINGS,
	[2] = HORIZONTAL_CURVES_MAPPINGS,
}
print(dump(HORIZONTAL_MAPPINGS_BY_RAIL_GROUP))
local DIRECTION_BITS = {N, S, E, W}

local function update_rail_connections(pos, update_neighbors)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef._mcl_minecarts then
		minetest.log("warning", "attemting to rail connect "..node.name)
		return
	end

	-- Get the mappings to use
	local mappings = HORIZONTAL_MAPPINGS_BY_RAIL_GROUP[nodedef.groups.rail]
	if not mappings then return end

	-- Horizontal rules, Check for rails on each neighbor
	local connections = 0
	for i = 1,4 do
		local neighbor = vector.add(pos, HORIZONTAL_CONNECTIONS[i])
		local node = minetest.get_node(neighbor)
		local nodedef = minetest.registered_nodes[node.name]

		if nodedef.groups.rail then
			connections = connections + DIRECTION_BITS[i]
		end

		if update_neighbors then
			update_rail_connections(neighbor, false)
		end
	end

	local mapping = mappings[connections]
	if mapping then
		local new_name = nodedef._mcl_minecarts.base_name..mapping[1]
		if new_name ~= node.name or node.param2 ~= mapping[2] then
			print("swapping "..node.name.." for "..new_name..","..tostring(mapping[2]).." at "..tostring(pos))
			node.name = new_name
			node.param2 = mapping[2]
			minetest.swap_node(pos, node)
		end
	end
end
mod.update_rail_connections = update_rail_connections

-- Now get the translator after we have finished using S for other things
local S = minetest.get_translator(modname)
local BASE_DEF = {
	description = S("New Rail"), -- Temporary name to make debugging easier
	_tt_help = S("Track for minecarts"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction."),
	_doc_items_usagehelp = mod.text.railuse,
	groups = {
		rail = mod.RAIL_GROUPS.CURVES,
	},
	paramtype = "light",
	paramtype2 = "facedir",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		update_rail_connections(pos, true)
	end,
}
local function register_curves_rail(base_name, tiles, def)
	def = def or {}
	local base_def = table.copy(BASE_DEF)
	table_merge(base_def,{
		_mcl_minecarts = { base_name = base_name },
		drop = base_name,
	})
	table_merge(base_def, def)

	-- Register the base node
	mod.register_rail(base_name, table_merge(table.copy(base_def),{
		tiles = { tiles[1] },
	}))
	BASE_DEF.craft = nil

	-- Corner variants
	mod.register_rail(base_name.."_corner", table_merge(table.copy(base_def),{
		tiles = { tiles[2] },
		groups = {
			not_in_creative_inventory = 1,
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
		groups = {
			not_in_creative_inventory = 1,
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
	mod.register_rail_sloped(base_name.."_sloped", table_merge(table.copy(base_def),{
		description = S("Sloped Rail"), -- Temporary name to make debugging easier
		tiles = { tiles[1] },
	}))

	-- Cross variant
	--[[
	mod.register_rail(base_name.."_cross", table_merge(table.copy(base_def),{
		tiles = { tiles[4] },
		groups = {
			not_in_creative_inventory = 1,
		},
	}))
	]]
end
mod.register_curves_rail = register_curves_rail
register_curves_rail("mcl_minecarts:rail_v2", {
	"default_rail.png", 
	"default_rail_curved.png",
	"default_rail_t_junction.png",
	"default_rail_t_junction_on.png",
	"default_rail_crossing.png"
},{
	craft = {
		output = "mcl_minecarts:rail_v2 16",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		}
	},
})

