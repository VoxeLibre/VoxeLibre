local use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true

local box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/64, 1/16}
local nodebox_parts = {
	[0] = {1/16, -.5, -1/16, 8/16, -.5+1/64, 1/16}, -- x positive
	[1] = {-1/16, -.5, 1/16, 1/16, -.5+1/64, 8/16}, -- z positive
	[2] = {-8/16, -.5, -1/16, -1/16, -.5+1/64, 1/16}, -- x negative
	[3] = {-1/16, -.5, -8/16, 1/16, -.5+1/64, -1/16}, -- z negative

	[4] = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/64, 1/16}, -- x positive up
	[5] = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/64, .5}, -- z positive up
	[6] = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/64, 1/16}, -- x negative up
	[7] = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/64, -.5+1/16}  -- z negative up
}
local dust = "redstone_redstone_dust_dot.png"
local flat = "(redstone_redstone_dust_dot.png^redstone_redstone_dust_line0.png^(redstone_redstone_dust_line1.png^[transformR90))"
local line = "redstone_redstone_dust_line0.png"

local connection_table = {
	[  0] = {"vl_redstone:dust",      0},
	[  1] = {"vl_redstone:trail_0",   0},
	[  2] = {"vl_redstone:trail_0",   3},
	[  3] = {"vl_redstone:corner_00", 0},
	[  4] = {"vl_redstone:trail_0",   2},
	[  5] = {"vl_redstone:line_00",   0},
	[  6] = {"vl_redstone:corner_00", 3},
	[  7] = {"vl_redstone:tee_000",   0},
	[  8] = {"vl_redstone:trail_0",   1},
	[  9] = {"vl_redstone:corner_00", 1},
	[ 10] = {"vl_redstone:line_00",   1},
	[ 11] = {"vl_redstone:tee_000",   1},
	[ 12] = {"vl_redstone:corner_00", 2},
	[ 13] = {"vl_redstone:tee_000",   2},
	[ 14] = {"vl_redstone:tee_000",   3},
	[ 15] = {"vl_redstone:cross_0000",0},
	[ 16] = {"vl_redstone:trail_1",   0},
	[ 18] = {"vl_redstone:corner_10", 0},
	[ 20] = {"vl_redstone:line_01",   2},
	[ 22] = {"vl_redstone:tee_100",   0},
	[ 24] = {"vl_redstone:corner_01", 1},
	[ 28] = {"vl_redstone:tee_001",   2},
	[ 32] = {"vl_redstone:trail_1",   3},
	[ 33] = {"vl_redstone:corner_01", 0},
	[ 36] = {"vl_redstone:corner_10", 3},
	[ 41] = {"vl_redstone:tee_001",   1},
	[ 44] = {"vl_redstone:tee_100",   3},
	[ 48] = {"vl_redstone:corner_11", 0},
	[ 52] = {"vl_redstone:tee_110",   0},
	[ 56] = {"vl_redstone:tee_011",   1},
	[ 60] = {"vl_redstone:cross_0011",2},
	[ 64] = {"vl_redstone:trail_1",   2},
	[ 66] = {"vl_redstone:corner_01", 3},
	[ 72] = {"vl_redstone:corner_10", 2},
	[ 96] = {"vl_redstone:corner_11", 3},
	[ 97] = {"vl_redstone:tee_011",   0},
	[104] = {"vl_redstone:tee_110",   3},
	[105] = {"vl_redstone:cross_0011",1},
	[112] = {"vl_redstone:tee_111",   0},
	[128] = {"vl_redstone:trail_1",   1},
	[129] = {"vl_redstone:corner_10", 1},
	[131] = {"vl_redstone:tee_100",   1},
	[132] = {"vl_redstone:corner_01", 2},
	[134] = {"vl_redstone:tee_001",   3},
	[144] = {"vl_redstone:corner_11", 1},
	[146] = {"vl_redstone:tee_110",   1},
	[148] = {"vl_redstone:tee_011",   2},
	[150] = {"vl_redstone:cross_0011",3},
	[176] = {"vl_redstone:tee_111",   1},
	[180] = {"vl_redstone:cross_0111",2},
	[192] = {"vl_redstone:corner_11", 2},
	[194] = {"vl_redstone:tee_011",   3},
	[193] = {"vl_redstone:tee_110",   2},
	[195] = {"vl_redstone:cross_0011",0},
	[208] = {"vl_redstone:tee_111",   2},
	[224] = {"vl_redstone:tee_111",   3},
	[255] = {"vl_redstone:cross_1111",0},
}
print("#connection_table = "..#connection_table)
local parts = {
	[1] = { 1, 0, 0,   1},
	[2] = { 0, 0, 1,   2},
	[3] = {-1, 0, 0,   4},
	[4] = { 0, 0,-1,   8},
	[5] = { 1, 1, 0,  16},
	[6] = { 0, 1, 1,  32},
	[7] = {-1, 1, 0,  64},
	[8] = { 0, 1,-1, 128},
	[9] = { 1,-1, 0,   1},
	[10]= { 0,-1, 1,   2},
	[11]= {-1,-1, 0,   4},
	[12]= { 0,-1,-1,   8},
}
local function update_redstone_wire(orig, update_neighbor)
	local mask = 0
	for i = 1,12 do
		local part = parts[i]
		local pos = vector.offset(orig, part[1], part[2], part[3])
		local node = core.get_node(pos)
		local def = core.registered_nodes[node.name]
		if def.groups.redstone or 0 ~= 0 then
			mask = mask + part[4]
			if update_neighbor and def.groups.redstone_wire or 0 ~= 0 then
				update_redstone_wire(pos)
			end
		end
	end

	local connections = connection_table[mask]
	if not connections then
		print(dump{
			me = core.get_node(orig),
			mask = mask,
			node = node,
		})
		connections = {"vl_redstone:dust", 0}
	end
	local node = {
		name   = connections[1],
		param2 = connections[2],
	}
	core.set_node(orig, node)
end

local base_def = {
	use_texture_alpha = use_texture_alpha,
	type = "node",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "color4dir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}
	},
	walkable = false,

	inventory_image = "redstone_redstone_dust.png",
	wield_image = "redstone_redstone_dust.png",
	tiles = {dust, dust, line, line, line, line},
	drop = "vl_redstone:dust",

	is_ground_content = false,
	sunlight_propogate = true,

	groups = {
		dig_by_piston = 1,
		dig_immediate = 3,
		creative_breakable = 1,
		attached_node = 1,
		craftitem = 1,
		destroy_by_lava_flow = 1,
		dig_by_water = 1,
		redstone = 1,
		redstone_wire = 1,
	},

	vl_block_update = update_restone_wire,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		update_redstone_wire(pos, true)
	end,
	after_dig_node = function(orig, oldnode, oldmetadata, digger)
		for i = 1,12 do
			local part = parts[i]
			local pos = vector.offset(orig, part[1], part[2], part[3])
			local node = core.get_node(pos)
			if core.get_item_group(node.name, "redstone_wire") ~= 0 then
				update_redstone_wire(pos)
			end
		end
	end
}

minetest.register_node("vl_redstone:dust", base_def)

base_def = table.copy(base_def)
base_def.tiles = {flat, flat, line, line, line, line}

for a=0,1 do
	local def = table.copy(base_def)
	local fixed = {
		box_center,
		nodebox_parts[0]
	}
	if a==1 then table.insert(fixed, nodebox_parts[4]) end

	def.node_box.fixed = fixed
	minetest.register_node("vl_redstone:trail_"..a, def)
end

for a=0,1 do
for b=0,1 do
	local def = table.copy(base_def)
	local fixed = {
		box_center,
		nodebox_parts[0],
		nodebox_parts[1]
	}
	if a==1 then table.insert(fixed, nodebox_parts[4]) end
	if b==1 then table.insert(fixed, nodebox_parts[5]) end

	def.node_box.fixed = fixed
	minetest.register_node("vl_redstone:corner_"..a..b, def)
end
end

local options = {{0,0}, {0,1}, {1,1}}
for i = 1,3 do
	a,b = unpack(options[i])
	local def = table.copy(base_def)
	local fixed = {
		box_center,
		nodebox_parts[0],
		nodebox_parts[2],
	}
	if a==1 then table.insert(fixed, nodebox_parts[4]) end
	if b==1 then table.insert(fixed, nodebox_parts[6]) end

	def.node_box.fixed = fixed
	minetest.register_node("vl_redstone:line_"..a..b, def)
end

for a=0,1 do
for b=0,1 do
for c=0,1 do
	local def = table.copy(base_def)
	local fixed = {
		box_center,
		nodebox_parts[0],
		nodebox_parts[1],
		nodebox_parts[2],
	}
	if a==1 then table.insert(fixed, nodebox_parts[4]) end
	if b==1 then table.insert(fixed, nodebox_parts[5]) end
	if c==1 then table.insert(fixed, nodebox_parts[6]) end

	def.node_box.fixed = fixed
	minetest.register_node("vl_redstone:tee_"..a..b..c, def)
end
end
end

local options = {{0,0,0,0}, {1,1,1,1}, {0,1,1,1}, {0,0,1,1}, {0,0,0,1}, {0,1,0,1}}
for i = 1,6 do
	a,b,c,d = unpack(options[i])
	local def = table.copy(base_def)
	local fixed = {
		box_center,
		nodebox_parts[0],
		nodebox_parts[1],
		nodebox_parts[2],
		nodebox_parts[3],
	}
	if a==1 then table.insert(fixed, nodebox_parts[4]) end
	if b==1 then table.insert(fixed, nodebox_parts[5]) end
	if c==1 then table.insert(fixed, nodebox_parts[6]) end
	if d==1 then table.insert(fixed, nodebox_parts[7]) end

	def.node_box.fixed = fixed
	minetest.register_node("vl_redstone:cross_"..a..b..c..d, def)
end
