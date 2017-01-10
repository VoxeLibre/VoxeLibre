-- head system

function addhead(node, desc)
	minetest.register_node("head:"..node, {
			description = ""..desc,
	    		drawtype = "nodebox",
			is_ground_content = false,
			node_box = {
				type = "fixed",
				fixed = {       
					{ -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },   			
				},
			},
			groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,head=1},
			tiles = {
				node.."_top.png",
				node.."_top.png",
				node.."_left.png",
				node.."_right.png",
				node.."_back.png",
				node.."_face.png",
			},	    
			paramtype = "light",
			stack_max = 16,
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = true,
			selection_box = {
				type = "fixed",
				fixed = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
			},
			
	})
end

--head add
addhead("zombie", "Zombie Head")
addhead("creeper", "Creeper Head")
addhead("steve", "Steve Head")
