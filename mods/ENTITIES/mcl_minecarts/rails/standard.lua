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
local south = vector.new( 0, 0,-1); local S = 2 -- Note: S is overwritten below with the translator
local east  = vector.new( 1, 0, 0); local E = 4
local west  = vector.new(-1, 0, 0); local W = 8

local CONNECTIONS = { north, south, east, west }
local HORIZONTAL_STANDARD_RULES = {
	[N]       = { "", 0, mask = N, score = 1 },
	[S]       = { "", 0, mask = S, score = 1 },
	[N+S]     = { "", 0, mask = N+S, score = 2 },

	[E]       = { "", 1, mask = E, score = 1 },
	[W]       = { "", 1, mask = W, score = 1 },
	[E+W]     = { "", 1, mask = E+W, score = 2 },
}

local HORIZONTAL_CURVES_RULES = {
	[N+E]     = { "_corner", 3, name = "ne corner", mask = N+E, score = 3 },
	[N+W]     = { "_corner", 2, name = "nw corner", mask = N+W, score = 3 },
	[S+E]     = { "_corner", 0, name = "se corner", mask = S+E, score = 3 },
	[S+W]     = { "_corner", 1, name = "sw corner", mask = S+W, score = 3 },

	[N+E+W]   = { "_tee_off", 3, mask = N+E+W, score = 4 },
	[S+E+W]   = { "_tee_off", 1, mask = S+E+W, score = 4 },
	[N+S+E]   = { "_tee_off", 0, mask = N+S+E, score = 4 },
	[N+S+W]   = { "_tee_off", 2, mask = N+S+W, score = 4 },

	[N+S+E+W] = { "_cross", 0, mask = N+S+E+W, score = 5 },
}

table_merge(HORIZONTAL_CURVES_RULES, HORIZONTAL_STANDARD_RULES)
local HORIZONTAL_RULES_BY_RAIL_GROUP = {
	[1] = HORIZONTAL_STANDARD_RULES,
	[2] = HORIZONTAL_CURVES_RULES,
}

local function check_connection_rule(pos, connections, rule)
	-- All bits in the mask must be set for the connection to be possible
	if bit.band(rule.mask,connections) ~= rule.mask then
		--print("Mask mismatch ("..tostring(rule.mask)..","..tostring(connections)..")")
		return false
	end

	-- If there is an allow filter, that mush also return true
	if rule.allow and rule.allow(rule, connections, pos) then
		return false
	end

	return true
end

local function update_rail_connections(pos, update_neighbors)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef._mcl_minecarts then
		minetest.log("warning", "attemting to rail connect "..node.name)
		return
	end

	-- Get the mappings to use
	local rules = HORIZONTAL_RULES_BY_RAIL_GROUP[nodedef.groups.rail]
	if nodedef._mcl_minecarts and nodedef._mcl_minecarts.connection_rules then -- Custom connection rules
		rules = nodedef._mcl_minecarts.connection_rules
	end
	if not rules then return end

	-- Horizontal rules, Check for rails on each neighbor
	local connections = 0
	for i,dir in ipairs(CONNECTIONS) do
		local neighbor = vector.add(pos, dir)
		local node = minetest.get_node(neighbor)
		local nodedef = minetest.registered_nodes[node.name]

		-- TODO: modify to only allow connections to the ends of rails (direction rules)
		if (nodedef.groups or {}).rail and nodedef._mcl_minecarts and nodedef._mcl_minecarts.get_next_dir then
			local diff = vector.direction(neighbor, pos)
			local next_dir = nodedef._mcl_minecarts.get_next_dir(neighbor, diff, node)
			if next_dir == diff then
				connections = connections + bit.lshift(1,i - 1)
			end
		end
	end

	-- Select the best allowed connection
	local rule = nil
	local score = 0
	for k,r in pairs(rules) do
		if check_connection_rule(pos, connections, r) then
			if r.score > score then
				--print("Best rule so far is "..dump(r))
				score = r.score
				rule = r
			end
		end
	end
	if not rule then return end

	-- Apply the mapping
	local new_name = nodedef._mcl_minecarts.base_name..rule[1]
	if new_name ~= node.name or node.param2 ~= rule[2] then
		print("swapping "..node.name.." for "..new_name..","..tostring(rule[2]).." at "..tostring(pos))
		node.name = new_name
		node.param2 = rule[2]
		minetest.swap_node(pos, node)
	end

	if rule.after then
		rule.after(rule, pos, connections)
	end
end
mod.update_rail_connections = update_rail_connections

local function rail_dir_straight(pos, dir, node)
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

local function rail_dir_cross(pos, dir, node)
	-- Always continue in the same direction. No direction changes allowed
	return dir
end
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
		_mcl_minecarts = {
			get_next_dir = rail_dir_straight
		}
	}))
	BASE_DEF.craft = nil

	-- Corner variants
	mod.register_rail(base_name.."_corner", table_merge(table.copy(base_def),{
		tiles = { tiles[2] },
		_mcl_minecarts = {
			get_next_dir = rail_dir_curve,
		},
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
		_mcl_minecarts = {
			get_next_dir = rail_dir_cross,
		},
		tiles = { tiles[1] },
	}))

	-- Cross variant
	mod.register_rail(base_name.."_cross", table_merge(table.copy(base_def),{
		tiles = { tiles[5] },
		groups = {
			not_in_creative_inventory = 1,
		},
	}))
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

