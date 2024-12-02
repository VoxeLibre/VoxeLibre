local storage = core.get_mod_storage()
local mod = vl_redstone

local pos_to_netlist_id_cache = {}
local netlist_cache = {}

function mod.get_power_level(pos)
	error("TODO: implement")
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

local function get_connected_nodes(pos, node, def, edges, sources, sinks)
	local res = {}

	local outputs = mesecon.flattenrules(mesecon.get_any_outputrules(node))
	for _,rule in pairs(outputs) do
		local neg_rule = vector.multiply(rule, -1)
		local p = vector.add(pos, rule)
		local p_node = core.get_node(p)
		local p_def = core.registered_nodes[p_node.name]

		local input_rules = mesecon.get_any_inputrules(p_node)
		if input_rules then
			--core.log("  considering "..p_node.name.." at "..vector.to_string(p)..". has "..#input_rules.." input rules")
			local inputs = mesecon.flattenrules(input_rules)
			for _,p_rule in pairs(inputs) do
				if vector.equals(p_rule, neg_rule) then
					if (p_def.groups.redstone_wire or 0) >= 1 then
						res[#res + 1] = p
					end
					edges[#edges + 1] = {pos, p}

					if p_def.mesecons.effector then
						--core.log("    is sink")
						sinks[#sinks + 1] = p
					end
				end
			end
		end

		local output_rules = mesecon.get_any_outputrules(p_node)
		if output_rules then
			--core.log("  considering "..p_node.name.." at "..vector.to_string(p)..". has "..#output_rules.." output rules")
			local outputs = mesecon.flattenrules(output_rules)
			for _,p_rule in pairs(outputs) do
				if vector.equals(p_rule, neg_rule) then
					if (p_def.groups.redstone_wire or 0) >= 1 then
						res[#res + 1] = p
					end
					edges[#edges + 1] = {p, pos}

					if p_def.mesecons.receptor then
						sources[#sources + 1] = p
						--core.log("    is source")
					end
				end
			end
		end
	end

	return res
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
			--core.log("processing "..node.name.." at "..vector.to_string(p))
			local def = core.registered_nodes[node.name]

			-- Only trace along wires
			if def and def.groups.redstone_wire then
				wires[#wires + 1] = p

				-- TODO: check neighbors for wires
				local connections = get_connected_nodes(p, node, def, edges, sources, sinks)
				for i = 1,#connections do
					queue[#queue + 1] = connections[i]
				end
			end
		end
	end

	-- TODO: serialize in a canonical manner so that we get the exact same netlist_id for the same redstone layout
	local netlist_data = core.compress(core.serialize(netlist))
	local netlist_id = core.sha256(netlist_data)

	if netlist_id ~= old_netlist_id then
		core.log("netlist change detected: "..tostring(old_netlist_id).." -> "..netlist_id)
		storage.set_string("netlist-"..old_netlist_id,"")
		storage.set_string("netlist-"..netlist_id, core.encode_base64(netlist_data))

		-- TODO: compute source->sink and source->wire distances (async?)

		for _,pos in pairs(netlist.wires) do
			pos_to_netlist_id_cache[core.hash_node_position(pos)] = netlist_id
		end
		for _,pos in pairs(netlist.sinks) do
			pos_to_netlist_id_cache[core.hash_node_position(pos)] = netlist_id
		end
		for _,pos in pairs(netlist.sources) do
			pos_to_netlist_id_cache[core.hash_node_position(pos)] = netlist_id
		end
	end
end

local function turn_on_source(pos, rules)
	local netlist_id = mod.get_netlist_id(pos)

	core.log(dump{
		pos = pos,
		rules = rules,
		netlist = netlist_id or "missing",
		cache = pos_to_netlist_id_cache,
	})
end
--vl_scheduler.register_serializable("vl_redstone:turn_on_source", turn_on_source)

local function turn_off_source(pos, rules)
	local netlist_id = mod.get_netlist_id(pos)

	core.log(dump{
		pos = pos,
		rules = rules,
		netlist = netlist_id or "missing",
	})
end
--vl_scheduler.register_serializable("vl_redstone:turn_off_source", turn_off_source)

-- Override mesecon.receptor_* functions
function mesecon.receptor_on(pos, rules)
	core.after(0,turn_on_source, pos, rules)
end
function mesecon.receptor_off(pos, rules)
	core.after(0,turn_off_source, pos, rules)
end
