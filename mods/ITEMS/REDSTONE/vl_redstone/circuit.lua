local storage = core.get_mod_storage()
local mod = vl_redstone

local pos_to_netlist_id_cache = {}
local netlist_cache = {}
local netlist_map_cache = {}
local pending_netlist_map_lookups = {}
local power_cache = {}
local power_source_cache = {}

-- Clear cache
vl_block_update.register_node_change(function(pos)
	local pos_hash = core.hash_node_position(pos)
	if power_source_cache[pos_hash] then
		--core.log("Reset power source cache for "..vector.to_string(pos))
		power_source_cache[pos_hash] = nil
	end
end)

local function get_node_power_source_level(pos_hash)
	local cache = power_source_cache[pos_hash]
	if cache then return cache end

	local power_source_level = 0
	local pos = core.get_position_from_hash(pos_hash)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name] or core.default_nodedef
	local receptor = def.mesecons and def.mesecons.receptor
	if receptor and receptor.state == mesecon.state.on then
		power_source_cache[pos_hash] = 16
		--core.log("Power source lv16 at "..vector.to_string(pos))
		return 16
	elseif def._vl_redstone then
		local power_source_level = def._vl_redstone.power_source_level
		if power_source_level then
			power_source_cache[pos_hash] = power_source_level
			--core.log("Power source lv"..power_source_level.." at "..vector.to_string(pos))
			return power_source_level
		end
	end

	return 0
end

function mod.get_power_level_from_hash(pos_hash)
	return math.max(power_cache[pos_hash] or 0, get_node_power_source_level(pos_hash))
end
function mod.get_power_level(pos)
	return mod.get_power_level_from_hash(core.hash_node_position(pos))
end

function mod.lookup_netlist_id(pos)
	-- TODO: lookup netlist id from mod storage
	return nil
end
function mod.load_netlist_data(id)
	-- TODO: load netlist data from mod storage
	return nil
end
function mod.get_netlist_id(pos)
	local pos_hash = core.hash_node_position(pos)
	local cache = pos_to_netlist_id_cache[pos_hash]
	if cache then return cache end

	local id = mod.lookup_netlist_id(pos)
	if id then
		pos_to_netlist_id_cache[pos_hash] = id
	end
	return id
end
function mod.get_netlist(pos)
	local netlist_id = mod.get_netlist_id(pos)
	if not netlist_id then return nil end

	local netlist = netlist_cache[netlist_id]
	if netlist then return netlist end

	netlist = mod.load_netlist_data(netlist_id)
	netlist_cache[netlist_id] = netlist

	return netlist
end
function mod.get_netlist_map(netlist_id, callback)
	local netlist_map = netlist_map_cache[netlist_id]
	if netlist_map then return callback(netlist_map) end

	-- Try to load from mod storage
	local mod_data = storage:get_string("netlist-map-"..netlist_id)
	if mod_data and mod_data ~= "" then
		local data = core.deserialize(core.decompress(core.decode_base64(mod_data)))
		netlist_map_cache[netlist_id] = data
		return callback(data)
	end

	-- Queue for when this data becomes available
	local pending = pending_netlist_map_lookups[netlist_id] or {}
	pending[#pending + 1] = callback
	pending_netlist_map_lookups[netlist_id] = pending
end

-- Can be run in Async Environment, can't use globals or local upvalues
local function compute_netlist_map(netlist, netlist_id, edges)
	--core.log(dump{netlist})
	local distance_map = {}

	-- Create the source->(wire/sink) distance maps and  the forward maps (source->sink and source->wire)
	local forward = {
		source = {},
		wire = {},
		sink = {},
		air = {},
	}
	local reverse = {
		source = {},
		wire = {},
		sink = {},
		air = {}
	}

	-- Create the pos-to-type map
	local pos_type = {}
	for _,pos in pairs(netlist.sources) do
		local pos_hash = core.hash_node_position(pos)
		pos_type[pos_hash] = "source"
		forward.source[pos_hash] = {}
	end
	for _,pos in pairs(netlist.sinks) do
		local pos_hash = core.hash_node_position(pos)
		pos_type[pos_hash] = "sink"
		reverse.sink[pos_hash] = {}
	end
	for _,pos in pairs(netlist.wires) do
		local pos_hash = core.hash_node_position(pos)
		pos_type[pos_hash] = "wire"
		reverse.wire[pos_hash] = {}
	end

	-- Walk edges from sources and build distance map
	for _,source_pos in pairs(netlist.sources) do
		local source_hash = core.hash_node_position(source_pos)
		local map = {}
		distance_map[source_hash] = map

		local queue = { {source_pos,0} }
		local processed = {}

		while #queue > 0 do
			local item = queue[#queue]
			queue[#queue] = nil
			local p,dist = item[1],item[2]

			local p_hash = core.hash_node_position(p)
			--core.log("  processing "..vector.to_string(p).." => "..pos_type[p_hash])
			if dist <= 15 and (map[p_hash] or 16) > dist then
				map[p_hash] = dist

				local p_type = pos_type[p_hash] or "air"

				-- Forward map
				local fwd_map = forward[p_type][source_hash] or {}
				forward[p_type][source_hash] = fwd_map
				fwd_map[p_hash] = dist

				-- Reverse map
				local rev_map = reverse[p_type][p_hash] or {}
				rev_map[source_hash] = dist

				-- Add adjacent nodes to processing queue
				for _,edge in pairs(edges) do
					if vector.equals(edge[1],p) then
						queue[#queue + 1] = {edge[2], dist + 1}
					end
				end
			end
		end
	end

	-- Drop identity data (source->source)
	forward.source = nil
	reverse.source = nil
	forward.air = nil
	reverse.air = nil

	-- Build the actual netlist map
	local netlist_map = {
		forward = forward,
		reverse = reverse,
	}

	-- Serialize and compress data in async thread
	local netlist_map_compressed = core.encode_base64(core.compress(core.serialize(netlist_map)))

	return netlist_id, netlist_map, netlist_map_compressed
end
local function netlist_map_finished(netlist_id, netlist_map, netlist_map_compressed)
	--[[
	core.log(dump{
		netlist_id = netlist_id,
		netlist_map = netlist_map,
	})--]]
	storage:set_string("netlist-map-"..netlist_id, netlist_map_compressed)
	netlist_map_cache[netlist_id] = netlist_map

	-- Dispatch pending requests
	local pending = pending_netlist_map_lookups[netlist_id]
	if pending then
		for i=1,#pending do
			pending[i](netlist_map)
		end
	end
	pending_netlist_map_lookups[netlist_id] = nil
end

local DEFAULT_NODE_OPTIONS = {}
local function get_connected_nodes(pos, node, def, netlist)
	local options = pos.options or DEFAULT_NODE_OPTIONS
	local edges = netlist.edges
	local sources = netlist.sources
	local sinks = netlist.sinks
	local strongly_powered = netlist.strongly_powered
	local res = {}

	local outputs = mesecon.flattenrules(mesecon.get_any_outputrules(node))
	for _,rule in pairs(outputs) do
		local neg_rule = vector.multiply(rule, -1)
		local p = vector.add(pos, rule)
		local p_node = core.get_node(p)
		local p_def = core.registered_nodes[p_node.name]
		local is_sink = false
		local is_source = false

		local connect = true

		if options.weak and p_def.groups.redstone_wire then
			connect = false
		end

		if connect then
			local input_rules = mesecon.get_any_inputrules(p_node)
			if input_rules then
				local inputs = mesecon.flattenrules(input_rules)
				for _,p_rule in pairs(inputs) do
					if vector.equals(p_rule, neg_rule) then
						if (p_def.groups.redstone_wire or 0) >= 1 then
							res[#res + 1] = p
						end
						edges[#edges + 1] = {pos, p}

						if p_def.mesecons and p_def.mesecons.effector then
							sinks[#sinks + 1] = p
							is_sink = true
						end
					end
				end
			end

			-- Opaque blocks weakly power (these nodes won't have input rules)
			if rule.weak and not is_sink and p_def.groups.opaque then
				edges[#edges + 1] = {pos, p}
				sinks[#sinks + 1] = p
				p.options = {weak=true}
				res[#res + 1] = p
			end

			local output_rules = mesecon.get_any_outputrules(p_node)
			if output_rules then
				local outputs = mesecon.flattenrules(output_rules)
				for _,p_rule in pairs(outputs) do
					if vector.equals(p_rule, neg_rule) then
						if (p_def.groups.redstone_wire or 0) >= 1 then
							res[#res + 1] = p
						end
						edges[#edges + 1] = {p, pos}
						if p_rule.strong then
							strongly_powered[#strongly_powered + 1] = p
						end

						if p_def.mesecons and p_def.mesecons.receptor then
							sources[#sources + 1] = p
							is_source = true
						end
					end
				end
			end

			-- Add strongly-powered opaque blocks to sources list (these nodes won't have output rules)
			if not is_source and p_def.groups.opaque then
				local is_strongly_powered = false
				for _,p in pairs(strongly_powered) do
					if vector.equals(p, pos) then
						is_strongly_powered = true
						break
					end
				end
				if is_strongly_powered then
					edges[#edges + 1] = {pos, p}
					sources[#sources + 1] = p
					p.options = {strong=true}
					res[#res + 1] = p
				end
			end
		end
	end

	return res
end
local function sort_position_hashes(a,b)
	return core.hash_node_position(a) < core.hash_node_position(b)
end

local function dispatch_power_changed(pos, old_power, new_power)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]

	local vl_redstone = def and def._vl_redstone
	if vl_redstone and vl_redstone.on_change then
		return vl_redstone.on_change(pos, node, old_power or 0, new_power)
	end

	local effector = def and def.mesecons and def.mesecons.effector
	if effector then
		local action_change = effector.action_change

		if action_change then
			action_change(pos, node)
		else
			if (not old_power or old_power == 0) and new_power ~= 0 then
				local action_on = effector.action_on
				if action_on then action_on(pos, node) end
			elseif new_power == 0 and (not old_power or old_power ~= 0) then
				--[[
				core.log(dump{
					node_name = node.name,
					pos = vector.to_string(pos),
					new_power = new_power,
					old_power = old_power,
				})--]]
				local action_off = effector.action_off
				if action_off then action_off(pos, node) end
			end
		end
	end
end

local function update_list_power_levels(reverse_list)
	for dst_hash,rev_map in pairs(reverse_list) do
		local new_power = 0
		for src_hash,dist in pairs(rev_map) do
			local src_power = mod.get_power_level_from_hash(src_hash) - dist
			if src_power > new_power then
				new_power = src_power
			end
		end

		-- Update power
		local old_power = power_cache[dst_hash]
		power_cache[dst_hash] = new_power

		-- Dispatch power change
		local dst = core.get_position_from_hash(dst_hash)
		dispatch_power_changed(dst, old_power, new_power)
		--core.log("update power: "..vector.to_string(dst).."  "..tostring(old_power).." => "..new_power)
	end
end

local function full_recompute_node_power_level(pos, pos_hash)
	-- TODO: account for a sink being powered from two separate netlist
	dispatch_power_changed(core.get_position_from_hash(pos_hash),power_cache[pos_hash], 0)
	power_cache[pos_hash] = nil
end

function mod.build_netlist(pos)
	local old_netlist_id = mod.get_netlist_id(pos)

	local wires = {}
	local sources= {}
	local sinks = {}
	local edges = {} -- Directed graph data
	local netlist = {
		wires = wires,
		sources = sources,
		sinks = sinks,
		strongly_powered = {},
		edges = edges,
	}

	local processed = {}
	local queue = {pos}
	while #queue > 0 do
		local p = queue[#queue]
		queue[#queue] = nil
		local p_hash = core.hash_node_position(p)
		if not processed[p_hash] then
			processed[p_hash] = true

			local node = core.get_node(p)
			local def = core.registered_nodes[node.name]
			local options = p.options or {}

			-- Only trace along wires, weakly and strongly powered nodes
			if def and def.groups.redstone_wire or options.weak or options.strong then
				wires[#wires + 1] = p

				-- check neighbors for connections
				local connections = get_connected_nodes(p, node, def, netlist)
				for i = 1,#connections do
					queue[#queue + 1] = connections[i]
				end
			end
		end
	end

	-- serialize in a canonical manner so that we get the exact same netlist_id for the same redstone layout
	table.sort(netlist.wires, sort_position_hashes)
	table.sort(netlist.sources, sort_position_hashes)
	table.sort(netlist.sinks, sort_position_hashes)
	local raw_netlist_data =  "{wires={"
	for i,p in ipairs(netlist.wires) do
		if i ~= 1 then
			raw_netlist_data = raw_netlist_data .. ","
		end
		raw_netlist_data = raw_netlist_data .. "{x="..p.x..",y="..p.y..",z="..p.z.."}"
	end
	raw_netlist_data = raw_netlist_data .. "},sources={"
	for i,p in ipairs(netlist.sources) do
		if i ~= 1 then
			raw_netlist_data = raw_netlist_data .. ","
		end
		raw_netlist_data = raw_netlist_data .. "{x="..p.x..",y="..p.y..",z="..p.z.."}"
	end
	raw_netlist_data = raw_netlist_data .. "},sink={"
	for i,p in ipairs(netlist.sinks) do
		if i ~= 1 then
			raw_netlist_data = raw_netlist_data .. ","
		end
		raw_netlist_data = raw_netlist_data .. "{x="..p.x..",y="..p.y..",z="..p.z.."}"
	end
	raw_netlist_data = raw_netlist_data .. "}}"
	local netlist_data = core.compress(raw_netlist_data)
	local netlist_id = core.sha256(netlist_data)
	--core.log(netlist_id.." = "..dump(netlist))
	--core.log(netlist_id.." => "..raw_netlist_data)

	local recompute_list = {}

	if netlist_id ~= old_netlist_id then
		--core.log("netlist change detected: "..tostring(old_netlist_id).." -> "..netlist_id)
		if old_netlist_id then
			storage:set_string("netlist-"..old_netlist_id,"")
			storage:set_string("netlist-map-"..old_netlist_id,"")

			--core.log("netlist_cache = "..dump(netlist_cache))

			-- Unset every position for the old netlist
			local old_netlist = netlist_cache[old_netlist_id]
			--core.log("clearing netlist "..old_netlist_id.." old_netlist="..dump(old_netlist))
			if old_netlist then
				for _,pos in pairs(old_netlist.wires) do
					local pos_hash = core.hash_node_position(pos)
					recompute_list[pos_hash] = old_netlist_id
					pos_to_netlist_id_cache[pos_hash] = nil
				end
				for _,pos in pairs(old_netlist.sinks) do
					local pos_hash = core.hash_node_position(pos)
					recompute_list[pos_hash] = old_netlist_id
					pos_to_netlist_id_cache[pos_hash] = nil
				end
				for _,pos in pairs(old_netlist.sources) do
					local pos_hash = core.hash_node_position(pos)
					recompute_list[pos_hash] = old_netlist_id
					pos_to_netlist_id_cache[pos_hash] = nil
				end
			end
			netlist_cache[old_netlist_id] = nil
			netlist_map_cache[old_netlist_id] = nil
		end

		-- Store new netlist information
		storage:set_string("netlist-"..netlist_id, core.encode_base64(netlist_data))
		netlist_cache[netlist_id] = netlist

		-- Compute source->sink and source->wire distances, using async processing where available
		--core.log(netlist_id.." => "..dump(netlist))
		core.handle_async(compute_netlist_map, netlist_map_finished, netlist, netlist_id, edges)

		for _,pos in pairs(netlist.wires) do
			local pos_hash = core.hash_node_position(pos)
			recompute_list[pos_hash] = netlist_id
			pos_to_netlist_id_cache[pos_hash] = netlist_id
		end
		for _,pos in pairs(netlist.sinks) do
			local pos_hash = core.hash_node_position(pos)
			recompute_list[pos_hash] = netlist_id
			pos_to_netlist_id_cache[pos_hash] = netlist_id
		end
		for _,pos in pairs(netlist.sources) do
			local pos_hash = core.hash_node_position(pos)
			recompute_list[pos_hash] = netlist_id
			pos_to_netlist_id_cache[pos_hash] = netlist_id
		end

		-- Recompute current power levels for all nodes that need it
		mod.get_netlist_map(netlist_id, function(netlist_map)
			update_list_power_levels(netlist_map.reverse.sink or {})
			update_list_power_levels(netlist_map.reverse.wire or {})
		end)

		-- unpower nodes that were in the old netlist but not the new netlist
		for pos_hash,nid in pairs(recompute_list) do
			if nid == old_netlist_id then
				local pos = core.get_position_from_hash(pos_hash)
				--core.log("recompute power for "..pos_hash.." "..vector.to_string(pos))
				full_recompute_node_power_level(pos, pos_hash)
			end
		end
	end
end

local function set_power_level(pos, rules, power_level)
	local netlists = {}
	local seen = {}
	local pos_hash = core.hash_node_position(pos)
	power_source_cache[pos_hash] = nil
	power_cache[pos_hash] = power_level
	--core.log("pos="..vector.to_string(pos)..", pos_hash="..pos_hash)

	for _,rule in pairs(rules) do
		local p = vector.add(pos, rule)
		local netlist_id = mod.get_netlist_id(pos)
		if netlist_id and not seen[netlist_id] then
			seen[netlist_id] = true
			netlists[#netlists + 1] = netlist_id
		end
	end

	for _,netlist_id in pairs(netlists) do
		mod.get_netlist_map(netlist_id, function(netlist_map)
			--core.log("Using netlist_map = "..dump(netlist_map))
			--core.log("Setting "..netlist_id.." to power level "..power_level.." from "..vector.to_string(pos).." hash="..pos_hash)

			-- Update sink nodes now
			update_list_power_levels(netlist_map.reverse.sink or {})

			-- Update wire nodes in the background when there's time
			vl_scheduler.after(0, 4, function(reverse_map)
				update_list_power_levels(reverse_map)
			end, netlist_map.reverse.wire or {})
		end)
	end
end
--vl_scheduler.register_serializable("vl_redstone:set_power_level", set_power_level)

-- Override mesecon.receptor_* functions
function mesecon.receptor_on(pos, rules)
	--core.log("receptor_on( "..vector.to_string(pos)..", ...) from"..dump(debug.traceback()))
	core.after(0, set_power_level, pos, rules, 16)
end
function mesecon.receptor_off(pos, rules)
	core.after(0, set_power_level, pos, rules, 0)
end
