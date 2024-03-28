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
	[N]       = "_ns",
	[S]       = "_ns",
	[N+S]     = "_ns",

	[E]       = "_ew",
	[W]       = "_ew",
	[E+W]     = "_ew",
}
local HORIZONTAL_CURVES_MAPPINGS = {
	[N+E]     = "_corner_ne",
	[N+W]     = "_corner_nw",
	[S+E]     = "_corner_se",
	[S+W]     = "_corner_sw",

	[N+E+W]   = "_tee_new_off",
	[S+E+W]   = "_tee_sew_off",
	[N+S+E]   = "_tee_nse_off",
	[N+S+W]   = "_tee_nsw_off",

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
		local new_name = nodedef._mcl_minecarts.base_name..mapping
		if new_name ~= node.name then
			print("swapping "..node.name.." for "..new_name.." at "..tostring(pos))
			node.name = new_name
			minetest.swap_node(pos, node)
		end
	end
end
mod.update_rail_connections = update_rail_connections

-- Now get the translator after we have finished using S for other things
local S = minetest.get_translator(modname)
local BASE_DEF = {
	description = S("Rail"),
	_tt_help = S("Track for minecarts"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction."),
	_doc_items_usagehelp = mod.text.railuse,
	groups = {
		rail = mod.RAIL_GROUPS.CURVES,
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		update_rail_connections(pos, true)
	end,
}
local CORNERS = {
	{ "nw", "I" },
	{ "ne", "R90" },
	{ "se", "R180" },
	{ "sw", "R270" },
}
local TEES = {
	{ "nse", "I", "FX" },
	{ "nsw", "R90", "FXR90" },
	{ "new", "R180", "FY" },
	{ "sew", "R270", "FYR90" },
}
local function register_curves_rail(base_name, tiles, def)
	def = def or {}
	local base_def = table.copy(BASE_DEF)
	table_merge(base_def,{
		_mcl_minecarts = { base_name = base_name },
		drop = base_name.."_ns",
	})
	table_merge(base_def, def)

	-- Register the base node
	mod.register_rail(base_name.."_ns", table_merge(table.copy(base_def),{
		tiles = {"default_gravel.png^"..tiles[1]},
	}))
	BASE_DEF.craft = nil

	-- East-west variant
	mod.register_rail(base_name.."_ew", table_merge(table.copy(base_def),{
		tiles = { "default_gravel.png^[transformR90:"..tiles[1].."" },
		groups = {
			not_in_creative_inventory = 1,
		},
	}))

	-- Corner variants
	for _,c in ipairs(CORNERS) do
		mod.register_rail(base_name.."_corner_"..c[1], table_merge(table.copy(base_def),{
			tiles = { "default_gravel.png^[transform"..c[2]..":"..tiles[2] },
			groups = {
				not_in_creative_inventory = 1,
			},
		}))
	end

	-- Tee variants
	for _,t in ipairs(TEES) do
		mod.register_rail(base_name.."_tee_"..t[1].."_off", table_merge(table.copy(base_def),{
			tiles = { "default_gravel.png^[transform"..t[2]..":"..tiles[3] },
			groups = {
				not_in_creative_inventory = 1,
			},
		}))
		mod.register_rail(base_name.."_tee_"..t[1].."_on", table_merge(table.copy(base_def),{
			tiles = { "default_gravel.png^[transform"..t[3]..":"..tiles[3] },
			groups = {
				not_in_creative_inventory = 1,
			},
		}))
	end

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
register_curves_rail("mcl_minecarts:rail", {"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},{
	craft = {
		output = "mcl_minecarts:rail_ns 16",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		}
	},
})

