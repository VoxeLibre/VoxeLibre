-- Red Nether Brick Fence

mcl_fences.register_fence_and_fence_gate(
	"red_nether_brick_fence",
	"Red Nether Brick Fence", "Red Nether Brick Fence Gate",
	"mcl_fences_fence_red_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1},
	minetest.registered_nodes["mcl_nether:red_nether_brick"]._mcl_hardness,
	minetest.registered_nodes["mcl_nether:red_nether_brick"]._mcl_blast_resistance,
	{"group:fence_nether_brick"},
	mcl_sounds.node_sound_stone_defaults(), "mcl_fences_nether_brick_fence_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1,
	"mcl_fences_fence_gate_red_nether_brick.png")

mcl_fences.register_fence_gate(
	"nether_brick_fence",
	"Nether Brick Fence Gate",
	"mcl_fences_fence_gate_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1},
	minetest.registered_nodes["mcl_nether:nether_brick"]._mcl_hardness,
	minetest.registered_nodes["mcl_nether:nether_brick"]._mcl_blast_resistance,
	mcl_sounds.node_sound_stone_defaults(), "mcl_fences_nether_brick_fence_gate_open", "mcl_fences_nether_brick_fence_gate_close", 1, 1)

minetest.register_craft({
	output = 'mclx_fences:red_nether_brick_fence 6',
	recipe = {
		{"mcl_nether:red_nether_brick", "mcl_nether:red_nether_brick", "mcl_nether:red_nether_brick"},
		{"mcl_nether:red_nether_brick", "mcl_nether:red_nether_brick", "mcl_nether:red_nether_brick"},
	}
})

minetest.register_craft({
	output = 'mclx_fences:red_nether_brick_fence_gate',
	recipe = {
		{"mcl_nether:nether_wart_item", "mcl_nether:red_nether_brick", "mcl_nether:netherbrick"},
		{"mcl_nether:netherbrick", "mcl_nether:red_nether_brick", "mcl_nether:nether_wart_item"},
	}
})
minetest.register_craft({
	output = 'mclx_fences:red_nether_brick_fence_gate',
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:red_nether_brick", "mcl_nether:nether_wart_item"},
		{"mcl_nether:nether_wart_item", "mcl_nether:red_nether_brick", "mcl_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = 'mclx_fences:nether_brick_fence_gate 2',
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:nether_brick", "mcl_nether:netherbrick"},
		{"mcl_nether:netherbrick", "mcl_nether:nether_brick", "mcl_nether:netherbrick"},
	}
})

