-- Nether Light:
mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local minp = vm_context.minp
	local miny = minp.y
	if miny > mcl_mapgen.nether.max then return end
	local maxp = vm_context.maxp
	local maxy = maxp.y
	if maxy < mcl_mapgen.nether.min then return end
	local p1 = {x = minp.x, y = math.max(miny, mcl_mapgen.nether.min), z = minp.z}
	local p2 = {x = maxp.x, y = math.min(maxy, mcl_mapgen.nether.max), z = maxp.z}
	vm_context.vm:set_lighting({day = 3, night = 4}, p1, p2)
	vm_context.write = true
end, 999999999)

-- Nether Roof Light:
mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local minp = vm_context.minp
	local miny = minp.y
	if miny > mcl_mapgen.nether.max+127 then return end
	local maxp = vm_context.maxp
	local maxy = maxp.y
	if maxy <= mcl_mapgen.nether.max then return end
	local p1 = {x = minp.x, y = math.max(miny, mcl_mapgen.nether.max + 1), z = minp.z}
	local p2 = {x = maxp.x, y = math.min(maxy, mcl_mapgen.nether.max + 127), z = maxp.z}
	vm_context.vm:set_lighting({day = 15, night = 15}, p1, p2)
	vm_context.write = true
end, 999999999)

-- End Light:
mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local minp = vm_context.minp
	local miny = minp.y
	if miny > mcl_mapgen.end_.max then return end
	local maxp = vm_context.maxp
	local maxy = maxp.y
	if maxy <= mcl_mapgen.end_.min then return end
	local p1 = {x = minp.x, y = math.max(miny, mcl_mapgen.end_.min), z = minp.z}
	local p2 = {x = maxp.x, y = math.min(maxy, mcl_mapgen.end_.max), z = maxp.z}
	vm_context.vm:set_lighting({day=15, night=15}, p1, p2)
	vm_context.write = true
end, 9999999999)
