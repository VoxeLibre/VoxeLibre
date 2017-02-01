-- Heads system

local function addhead(node, desc)
	minetest.register_node("mcl_heads:"..node, {
		description = desc,
    		drawtype = "nodebox",
		is_ground_content = false,
		node_box = {
			type = "fixed",
			fixed = {       
				{ -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },   			
			},
		},
		groups = {oddly_breakable_by_hand=3, head=1, deco_block=1},
		tiles = {
			"head_"..node.."_top.png",
			"head_"..node.."_top.png",
			"head_"..node.."_left.png",
			"head_"..node.."_right.png",
			"head_"..node.."_back.png",
			"head_"..node.."_face.png",
		},	    
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = true,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
		},
		sounds = mcl_core.node_sound_defaults({
			footstep = {name="default_hard_footstep", gain=0.3}
		}),
	})
end

-- Add heads
addhead("zombie", "Zombie Head")
addhead("creeper", "Creeper Head")
addhead("steve", "Head")
addhead("skeleton", "Skeleton Skull")
addhead("wither_skeleton", "Wither Skeleton Skull")
