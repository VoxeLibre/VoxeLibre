local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local END_EXIT_PORTAL_POS_X = -3
local END_EXIT_PORTAL_POS_Y = -27003
local END_EXIT_PORTAL_POS_Z = -3
local p0 = {
	x = END_EXIT_PORTAL_POS_X,
	y = END_EXIT_PORTAL_POS_Y,
	z = END_EXIT_PORTAL_POS_Z,
}

local schematic = modpath .. "/schematics/mcl_structures_end_exit_portal.mts"

local dragon_spawn_pos = false
local dragon_spawned, portal_generated = false, false

local function spawn_ender_dragon()
	local obj = minetest.add_entity(dragon_spawn_pos, "mobs_mc:enderdragon")
	if not obj then return false end
	local dragon_entity = obj:get_luaentity()
	dragon_entity._initial = true
	dragon_entity._portal_pos = p0
	return obj
end

local function try_to_spawn_ender_dragon()
	if spawn_ender_dragon() then
		dragon_spawned = true
		return
	end
	minetest.after(2, try_to_spawn_ender_dragon)
	minetest.log("warning", "Ender dragon doesn't want to spawn at "..minetest.pos_to_string(dragon_spawn_pos))
end

if portal_generated and not dragon_spawned then
	minetest.after(10, try_to_spawn_ender_dragon)
end

local function place(pos, rotation, pr)
	mcl_structures.place_schematic({pos = pos, schematic = schematic, rotation = rotation, pr = pr})
end

mcl_mapgen.register_mapgen(function(minp, maxp, seed, vm_context)
	local minp = minp
	local y1 = minp.y
	if y1 > END_EXIT_PORTAL_POS_Y then return end
	local maxp = maxp
	local y2 = maxp.y
	if y2 < END_EXIT_PORTAL_POS_Y then return end
	if minp.x > END_EXIT_PORTAL_POS_X then return end
	if maxp.x < END_EXIT_PORTAL_POS_X then return end
	if minp.z > END_EXIT_PORTAL_POS_Z then return end
	if maxp.z < END_EXIT_PORTAL_POS_Z then return end

	dragon_spawn_pos = vector.add(p0, vector.new(3, 11, 3))
	portal_generated = true
	try_to_spawn_ender_dragon()

	local p = table.copy(p0)

	for y = y2, y1, -1 do
		p.y = y
		if minetest.get_node(p).name == "mcl_end:end_stone" then
			place(p, "0", PseudoRandom(vm_context.chunkseed))
			return
		end
	end

	for y = y2, y1, -1 do
		p.y = y
		if minetest.get_node(p).name ~= "air" then
			place(p, "0", PseudoRandom(vm_context.chunkseed))
			return
		end
	end

	place(p0, "0", PseudoRandom(vm_context.chunkseed))
end)

mcl_structures.register_structure({name = "end_exit_portal", place_function = place})
