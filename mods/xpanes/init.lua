-- xPanes mod by xyz  custom by davedevils
function pane(node, desc, dropitem, recipeitem, color)
	local function rshift(x, by)
	  return math.floor(x / 2 ^ by)
	end

	local directions = {
		{x = 1, y = 0, z = 0},
		{x = 0, y = 0, z = 1},
		{x = -1, y = 0, z = 0},
		{x = 0, y = 0, z = -1},
	}

	local function update_pane(pos)
		if minetest.env:get_node(pos).name:find("xpanes:pane_"..node..""..color) == nil then
			return
		end
		local sum = 0
		for i = 1, 4 do
			local node = minetest.env:get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
			if minetest.registered_nodes[node.name].walkable ~= false then
				sum = sum + 2 ^ (i - 1)
			end
		end
		if sum == 0 then
			sum = 15
		end
		minetest.env:add_node(pos, {name = "xpanes:pane_"..node..""..color.."_"..sum})
	end

	local function update_nearby(pos)
		for i = 1,4 do
			update_pane({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
		end
	end

	local half_blocks = {
		{0, -0.5, -0.06, 0.5, 0.5, 0.06},
		{-0.06, -0.5, 0, 0.06, 0.5, 0.5},
		{-0.5, -0.5, -0.06, 0, 0.5, 0.06},
		{-0.06, -0.5, -0.5, 0.06, 0.5, 0}
	}

	local full_blocks = {
		{-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
		{-0.06, -0.5, -0.5, 0.06, 0.5, 0.5}
	}

	for i = 1, 15 do
		local need = {}
		local cnt = 0
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
				cnt = cnt + 1
			end
		end
		local take = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_blocks[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_blocks[2])
		end
		for k in pairs(need) do
			table.insert(take, half_blocks[k])
		end
		local texture = "xpanes_pane_"..node..""..color..".png"
		if cnt == 1 then
			texture = "xpanes_pane_half_"..node..""..color..".png"
		end
		minetest.register_node("xpanes:pane_"..node..""..color.."_"..i, {
			drawtype = "nodebox",
			tile_images = {"xpanes_top_"..node..""..color..".png", "xpanes_top_"..node..""..color..".png", texture},
			paramtype = "light",
			use_texture_alpha = true,
			groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
			drop = dropitem,
			node_box = {
				type = "fixed",
				fixed = take
			},
			selection_box = {
				type = "fixed",
				fixed = take
			}
		})
	end

	minetest.register_node("xpanes:pane_"..node..""..color, {
		description = desc,
		tile_images = {"xpanes_pane_"..node..""..color..".png"},
		inventory_image = "xpanes_pane_"..node..""..color..".png",
		paramtype = "light",
		stack_max = 64,
		use_texture_alpha = true,
		wield_image = "xpanes_pane_"..node..""..color..".png",
		node_placement_prediction = "",
		on_construct = update_pane,
		drop = "",
	})

	minetest.register_on_placenode(update_nearby)
	minetest.register_on_dignode(update_nearby)

	minetest.register_craft({
		output = 'xpanes:pane_'..node..''..color..' 16',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem}
		}
	})
end
-- Glass
pane("glass", "Glass Pane", "", "default:glass", "_natural")
pane("glass", "Glass Pane Red", "", "default:glass_red", "_red")
pane("glass", "Glass Pane Green", "", "default:glass_green", "_green")
pane("glass", "Glass Pane Blue", "", "default:glass_blue", "_blue")
pane("glass", "Glass Pane Light Blue", "", "default:glass_light_blue", "_light_blue")
pane("glass", "Glass Pane Black", "", "default:glass_black", "_black")
pane("glass", "Glass Pane White", "", "default:glass_white", "_white")
pane("glass", "Glass Pane Yellow", "", "default:glass_yellow", "_yellow")
pane("glass", "Glass Pane Brown", "", "default:glass_brown", "_brown")
pane("glass", "Glass Pane Orange", "", "default:glass_orange", "_orange")
pane("glass", "Glass Pane Pink", "", "default:glass_pink", "_pink")
pane("glass", "Glass Pane Gray", "", "default:glass_gray", "_gray")
pane("glass", "Glass Pane Lime", "", "default:glass_lime", "_lime")
pane("glass", "Glass Pane Silver", "", "default:glass_silver", "_silver")
pane("glass", "Glass Pane Magenta", "", "default:glass_magenta", "_magenta")
pane("glass", "Glass Pane Purple", "", "default:glass_purple", "_purple")


-- Iron
pane("iron", "Iron Fence", "xpanes:pane_iron", "default:steel_ingot", "")