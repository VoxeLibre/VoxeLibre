local use_texture_alpha = core.features.use_texture_alpha_string_modes and "clip" or true
local DEBUG = false
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
	[  0] = {"vl_redstone:dust",      0},	[  1] = {"vl_redstone:trail_0",   0},
	[  2] = {"vl_redstone:trail_0",   3},	[  3] = {"vl_redstone:corner_00", 0},
	[  4] = {"vl_redstone:trail_0",   2},	[  5] = {"vl_redstone:line_00",   0},
	[  6] = {"vl_redstone:corner_00", 3},	[  7] = {"vl_redstone:tee_000",   0},
	[  8] = {"vl_redstone:trail_0",   1},	[  9] = {"vl_redstone:corner_00", 1},
	[ 10] = {"vl_redstone:line_00",   1},	[ 11] = {"vl_redstone:tee_000",   1},
	[ 12] = {"vl_redstone:corner_00", 2},	[ 13] = {"vl_redstone:tee_000",   2},
	[ 14] = {"vl_redstone:tee_000",   3},	[ 15] = {"vl_redstone:cross_0000",0},
	[ 16] = {"vl_redstone:trail_1",   0},	[ 17] = {"vl_redstone:trail_1",   0},
	[ 18] = {"vl_redstone:corner_10", 0},	[ 19] = {"vl_redstone:corner_10", 0},
	[ 20] = {"vl_redstone:line_01",   2},	[ 21] = {"vl_redstone:line_01",   2},
	[ 22] = {"vl_redstone:tee_100",   0},	[ 23] = {"vl_redstone:tee_100",   0},
	[ 24] = {"vl_redstone:corner_01", 1},	[ 25] = {"vl_redstone:corner_01", 1},
	[ 26] = {"vl_redstone:tee_010",   1},	[ 27] = {"vl_redstone:tee_010",   1},
	[ 28] = {"vl_redstone:tee_001",   2},	[ 29] = {"vl_redstone:tee_001",   2},
	[ 30] = {"vl_redstone:cross_0001",3},	[ 31] = {"vl_redstone:cross_0001",3},
	[ 32] = {"vl_redstone:trail_1",   3},	[ 33] = {"vl_redstone:corner_01", 0},
	[ 34] = {"vl_redstone:trail_1",   3},	[ 35] = {"vl_redstone:corner_01", 0},
	[ 36] = {"vl_redstone:corner_10", 3},	[ 37] = {"vl_redstone:tee_010",   0},
	[ 38] = {"vl_redstone:corner_10", 3},	[ 39] = {"vl_redstone:tee_010",   0},
	[ 40] = {"vl_redstone:line_01",   1},	[ 41] = {"vl_redstone:tee_001",   1},
	[ 42] = {"vl_redstone:line_01",   1},	[ 43] = {"vl_redstone:tee_001",   1},
	[ 44] = {"vl_redstone:tee_100",   3},	[ 45] = {"vl_redstone:cross_0001",2},
	[ 46] = {"vl_redstone:tee_100",   3},	[ 47] = {"vl_redstone:cross_0001",2},
	[ 48] = {"vl_redstone:corner_11", 0},	[ 49] = {"vl_redstone:corner_11", 0},
	[ 50] = {"vl_redstone:corner_11", 0},	[ 51] = {"vl_redstone:corner_11", 0},
	[ 52] = {"vl_redstone:tee_110",   0},	[ 53] = {"vl_redstone:tee_110",   0},
	[ 54] = {"vl_redstone:tee_110",   0},	[ 55] = {"vl_redstone:tee_110",   0},
	[ 56] = {"vl_redstone:tee_011",   1},	[ 57] = {"vl_redstone:tee_011",   1},
	[ 58] = {"vl_redstone:tee_011",   1},	[ 59] = {"vl_redstone:tee_011",   1},
	[ 60] = {"vl_redstone:cross_0011",2},	[ 61] = {"vl_redstone:cross_0011",2},
	[ 62] = {"vl_redstone:cross_0011",2},	[ 63] = {"vl_redstone:cross_0011",2},
	[ 64] = {"vl_redstone:trail_1",   2},	[ 65] = {"vl_redstone:line_01",   0},
	[ 66] = {"vl_redstone:corner_01", 3},	[ 67] = {"vl_redstone:tee_001",   0},
	[ 68] = {"vl_redstone:trail_1",   2},	[ 69] = {"vl_redstone:line_01",   0},
	[ 70] = {"vl_redstone:corner_01", 3},	[ 71] = {"vl_redstone:tee_001",   0},
	[ 72] = {"vl_redstone:corner_10", 2},	[ 73] = {"vl_redstone:tee_100",   2},
	[ 74] = {"vl_redstone:tee_010",   3},	[ 75] = {"vl_redstone:cross_0001",1},
	[ 76] = {"vl_redstone:corner_10", 2},	[ 77] = {"vl_redstone:tee_100",   2},
	[ 78] = {"vl_redstone:tee_011",   3},	[ 79] = {"vl_redstone:cross_0001",1},
	[ 80] = {"vl_redstone:line_11",   0},	[ 81] = {"vl_redstone:line_11",   0},
	[ 82] = {"vl_redstone:tee_101",   0},	[ 83] = {"vl_redstone:tee_101",   0},
	[ 84] = {"vl_redstone:line_11",   0},	[ 85] = {"vl_redstone:line_11",   0},
	[ 86] = {"vl_redstone:tee_101",   0},	[ 87] = {"vl_redstone:tee_101",   0},
	[ 88] = {"vl_redstone:tee_101",   2},	[ 89] = {"vl_redstone:tee_101",   2},
	[ 90] = {"vl_redstone:cross_0101",3},	[ 91] = {"vl_redstone:cross_0101",1},
	[ 92] = {"vl_redstone:tee_101",   2},	[ 93] = {"vl_redstone:tee_101",   2},
	[ 94] = {"vl_redstone:cross_0101",3},	[ 95] = {"vl_redstone:cross_0101",1},
	[ 96] = {"vl_redstone:corner_11", 3},	[ 97] = {"vl_redstone:tee_011",   0},
	[ 98] = {"vl_redstone:corner_11", 3},	[ 99] = {"vl_redstone:tee_011",   0},
	[100] = {"vl_redstone:corner_11", 3},	[101] = {"vl_redstone:tee_011",   0},
	[102] = {"vl_redstone:corner_11", 3},	[103] = {"vl_redstone:tee_011",   0},
	[104] = {"vl_redstone:tee_110",   3},	[105] = {"vl_redstone:cross_0011",1},
	[106] = {"vl_redstone:tee_110",   3},	[107] = {"vl_redstone:cross_0011",1},
	[108] = {"vl_redstone:tee_110",   3},	[109] = {"vl_redstone:cross_0011",1},
	[110] = {"vl_redstone:tee_110",   3},	[111] = {"vl_redstone:cross_0011",1},
	[112] = {"vl_redstone:tee_111",   0},	[113] = {"vl_redstone:tee_111",   0},
	[114] = {"vl_redstone:tee_111",   0},	[115] = {"vl_redstone:tee_111",   0},
	[116] = {"vl_redstone:tee_111",   0},	[117] = {"vl_redstone:tee_111",   0},
	[118] = {"vl_redstone:tee_111",   0},	[119] = {"vl_redstone:tee_111",   0},
	[120] = {"vl_redstone:cross_0111",1},	[121] = {"vl_redstone:cross_0111",1},
	[122] = {"vl_redstone:cross_0111",1},	[123] = {"vl_redstone:cross_0111",1},
	[124] = {"vl_redstone:cross_0111",1},	[125] = {"vl_redstone:cross_0111",1},
	[126] = {"vl_redstone:cross_0111",1},	[127] = {"vl_redstone:cross_0111",1},
	[128] = {"vl_redstone:trail_1",   1},	[129] = {"vl_redstone:corner_10", 1},
	[130] = {"vl_redstone:line_01",   3},	[131] = {"vl_redstone:tee_100",   1},
	[132] = {"vl_redstone:corner_01", 2},	[133] = {"vl_redstone:tee_010",   2},
	[134] = {"vl_redstone:tee_001",   3},	[135] = {"vl_redstone:cross_0001",0},
	[136] = {"vl_redstone:trail_1",   1},	[137] = {"vl_redstone:corner_10", 1},
	[138] = {"vl_redstone:line_01",   3},	[139] = {"vl_redstone:tee_101",   1},
	[140] = {"vl_redstone:corner_01", 2},	[141] = {"vl_redstone:tee_010",   2},
	[142] = {"vl_redstone:tee_001",   3},	[143] = {"vl_redstone:cross_0001",0},
	[144] = {"vl_redstone:corner_11", 1},	[145] = {"vl_redstone:corner_11", 1},
	[146] = {"vl_redstone:tee_110",   1},	[147] = {"vl_redstone:tee_110",   1},
	[148] = {"vl_redstone:tee_011",   2},	[149] = {"vl_redstone:tee_011",   2},
	[150] = {"vl_redstone:cross_0011",3},	[151] = {"vl_redstone:cross_0011",3},
	[152] = {"vl_redstone:corner_11", 1},	[153] = {"vl_redstone:corner_11", 1},
	[154] = {"vl_redstone:tee_110",   1},	[155] = {"vl_redstone:tee_110",   1},
	[156] = {"vl_redstone:tee_011",   2},	[157] = {"vl_redstone:tee_011",   2},
	[158] = {"vl_redstone:cross_0011",3},	[159] = {"vl_redstone:cross_0011",3},
	[160] = {"vl_redstone:line_11",   1},	[161] = {"vl_redstone:tee_101",   1},
	[162] = {"vl_redstone:line_11",   1},	[163] = {"vl_redstone:tee_101",   1},
	[164] = {"vl_redstone:tee_101",   3},	[165] = {"vl_redstone:cross_0101",0},
	[166] = {"vl_redstone:tee_111",   3},	[167] = {"vl_redstone:cross_0101",0},
	[168] = {"vl_redstone:line_11",   1},	[169] = {"vl_redstone:tee_101",   1},
	[170] = {"vl_redstone:line_11",   1},	[171] = {"vl_redstone:tee_101",   1},
	[172] = {"vl_redstone:tee_101",   3},	[173] = {"vl_redstone:cross_0101",2},
	[174] = {"vl_redstone:tee_101",   3},	[175] = {"vl_redstone:cross_0101",0},
	[176] = {"vl_redstone:tee_111",   1},	[177] = {"vl_redstone:tee_111",   1},
	[178] = {"vl_redstone:tee_111",   1},	[179] = {"vl_redstone:tee_111",   1},
	[180] = {"vl_redstone:cross_0111",2},	[181] = {"vl_redstone:cross_0111",2},
	[182] = {"vl_redstone:cross_0111",2},	[183] = {"vl_redstone:cross_0111",2},
	[184] = {"vl_redstone:tee_111",   1},	[185] = {"vl_redstone:tee_111",   1},
	[186] = {"vl_redstone:tee_111",   1},	[187] = {"vl_redstone:tee_111",   1},
	[188] = {"vl_redstone:cross_0111",2},	[189] = {"vl_redstone:cross_0111",2},
	[190] = {"vl_redstone:cross_0111",2},	[191] = {"vl_redstone:cross_0111",2},
	[192] = {"vl_redstone:corner_11", 2},	[193] = {"vl_redstone:tee_110",   2},
	[194] = {"vl_redstone:tee_011",   3},	[195] = {"vl_redstone:cross_0011",0},
	[196] = {"vl_redstone:corner_11", 2},	[197] = {"vl_redstone:tee_110",   2},
	[198] = {"vl_redstone:tee_011",   3},	[199] = {"vl_redstone:cross_0011",0},
	[200] = {"vl_redstone:corner_11", 2},	[201] = {"vl_redstone:tee_110",   2},
	[202] = {"vl_redstone:tee_011",   3},	[203] = {"vl_redstone:cross_0011",0},
	[204] = {"vl_redstone:corner_11", 2},	[205] = {"vl_redstone:tee_110",   2},
	[206] = {"vl_redstone:tee_011",   3},	[207] = {"vl_redstone:cross_0011",0},
	[208] = {"vl_redstone:tee_111",   2},	[209] = {"vl_redstone:tee_111",   2},
	[210] = {"vl_redstone:cross_0111",3},	[211] = {"vl_redstone:cross_0111",3},
	[212] = {"vl_redstone:tee_111",   2},	[213] = {"vl_redstone:tee_111",   2},
	[214] = {"vl_redstone:cross_0111",3},	[215] = {"vl_redstone:cross_0111",3},
	[216] = {"vl_redstone:tee_111",   2},	[217] = {"vl_redstone:tee_111",   2},
	[218] = {"vl_redstone:cross_0111",3},	[219] = {"vl_redstone:cross_0111",3},
	[220] = {"vl_redstone:tee_111",   2},	[221] = {"vl_redstone:tee_111",   2},
	[222] = {"vl_redstone:cross_0111",3},	[223] = {"vl_redstone:cross_0111",3},
	[224] = {"vl_redstone:tee_111",   3},	[225] = {"vl_redstone:cross_0111",0},
	[226] = {"vl_redstone:tee_111",   3},	[227] = {"vl_redstone:cross_0111",0},
	[228] = {"vl_redstone:tee_111",   3},	[229] = {"vl_redstone:cross_0111",0},
	[230] = {"vl_redstone:tee_111",   3},	[231] = {"vl_redstone:cross_0111",0},
	[232] = {"vl_redstone:tee_111",   3},	[233] = {"vl_redstone:cross_0111",0},
	[234] = {"vl_redstone:tee_111",   3},	[235] = {"vl_redstone:cross_0111",0},
	[236] = {"vl_redstone:tee_111",   3},	[237] = {"vl_redstone:cross_0111",0},
	[238] = {"vl_redstone:tee_111",   3},	[239] = {"vl_redstone:cross_0111",0},
	[240] = {"vl_redstone:cross_1111",0},	[241] = {"vl_redstone:cross_1111",0},
	[242] = {"vl_redstone:cross_1111",0},	[243] = {"vl_redstone:cross_1111",0},
	[244] = {"vl_redstone:cross_1111",0},	[245] = {"vl_redstone:cross_1111",0},
	[246] = {"vl_redstone:cross_1111",0},	[247] = {"vl_redstone:cross_1111",0},
	[248] = {"vl_redstone:cross_1111",0},	[249] = {"vl_redstone:cross_1111",0},
	[250] = {"vl_redstone:cross_1111",0},	[251] = {"vl_redstone:cross_1111",0},
	[252] = {"vl_redstone:cross_1111",0},	[253] = {"vl_redstone:cross_1111",0},
	[254] = {"vl_redstone:cross_1111",0},	[255] = {"vl_redstone:cross_1111",0},
}
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
		if def and def.groups.redstone or 0 ~= 0 then
			mask = mask + part[4]
			if update_neighbor and def.groups.redstone_wire or 0 ~= 0 then
				update_redstone_wire(pos)
			end
		end
	end

	local connections = connection_table[mask]
	if not connections then
		core.log("missing connections for "..mask)
		connections = {"vl_redstone:dust", 0}
	end
	local node = core.get_node(orig)
	local power = math.floor(node.param2 / 4)
	if node.name ~= connections[1] or node.param2 ~= connections[2] + power * 16 then
		node.name = connections[1]
		node.param2 = connections[2] + power * 4
		core.set_node(orig, node)
	end
end

local base_def = {
	use_texture_alpha = use_texture_alpha,
	type = "node",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "color4dir",
	palette = DEBUG and "vl_redstone_palette_debug.png" or "vl_redstone_palette.png",
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

	mesecons = {
		conductor = {
			rules = {
				{x=-1,  y= 0, z= 0, spread=true},
				{x= 1,  y= 0, z= 0, spread=true},
				{x= 0,  y=-1, z= 0, spread=true},
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
				{x= 0, y=-1, z=-1}
			},
			state = function(node)
				if node.param2 >= 4 then
					return mesecon.state.on
				else
					return mesecon.state.off
				end
			end,
			onstate = function(pos, node)
				return {node.name, node.param2 % 4 + 60}
			end,
			offstate = function(pos, node)
				return {node.name, node.param2 % 4}
			end,
		}
	},

	groups = {
		dig_by_piston = 1,
		dig_immediate = 3,
		creative_breakable = 1,
		attached_node = 3,
		craftitem = 1,
		destroy_by_lava_flow = 1,
		dig_by_water = 1,
		redstone = 1,
		redstone_wire = 1,
	},

	vl_block_update = update_redstone_wire,
}

core.register_node("vl_redstone:dust", base_def)

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
	core.register_node("vl_redstone:trail_"..a, def)
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
	core.register_node("vl_redstone:corner_"..a..b, def)
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
	core.register_node("vl_redstone:line_"..a..b, def)
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
	core.register_node("vl_redstone:tee_"..a..b..c, def)
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
	core.register_node("vl_redstone:cross_"..a..b..c..d, def)
end
