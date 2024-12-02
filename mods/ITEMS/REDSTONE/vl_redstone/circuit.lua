local storage = core.get_mod_storage()
local mod = vl_redstone

function mod.get_power_level(pos)
	error("TODO: implement")
end

function mod.get_netlist(pos)
	return nil
end

function mod.build_netlist(pos)
	local wires = {}
	local sources= {}
	local sinks = {}
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
			local node = core.get_node(p)
			local def = core.registered_nodes[node.name]
			if def and def.groups.redstone_wire then
				wires[#wires + 1] = p

				-- TODO: check neighbors for wires
			end
			if def and def.mesecons.receptor then
				sources[#sources + 1] = p
			end
			if def and def.mesecons.effector then
				sinks[#sinks + 1] = p
			end
		end
	end

	core.log(dump(netlist))
end

