-- Heads system

local function addhead(node, desc, longdesc)
	minetest.register_node("mcl_heads:"..node, {
		description = desc,
		_doc_items_longdesc = longdesc,
    		drawtype = "nodebox",
		is_ground_content = false,
		node_box = {
			type = "fixed",
			fixed = {       
				{ -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },   			
			},
		},
		groups = {handy=1, armor_head=1, head=1, deco_block=1, dig_by_piston=1},
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
		sounds = mcl_sounds.node_sound_defaults({
			footstep = {name="default_hard_footstep", gain=0.3}
		}),
		_mcl_blast_resistance = 5,
		_mcl_hardness = 1,
	})
end

-- Add heads
addhead("zombie", "Zombie Head", "A zombie head is a small decorative block which resembles the head of a zombie.")
addhead("creeper", "Creeper Head", "A creeper head is a small decorative block which resembles the head of a creeper.")
-- Original Minecraft name: “Head”
addhead("steve", "Human Head", "A human head is a small decorative block which resembles the head of a human (i.e. a player character).")
addhead("skeleton", "Skeleton Skull", "A skeleton skull is a small decorative block which resembles the head of a skeleton.")
addhead("wither_skeleton", "Wither Skeleton Skull", "A wither skeleton skull is a small decorative block which resembles the head of a wither skeleton.")
