
local function is_pane(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "pane") > 0
end

local function connects_dir(pos, name, dir)
	local aside = vector.add(pos, minetest.facedir_to_dir(dir))
	if is_pane(aside) then
		return true
	end

	local connects_to = minetest.registered_nodes[name].connects_to
	if not connects_to then
		return false
	end
	local list = minetest.find_nodes_in_area(aside, aside, connects_to)

	if #list > 0 then
		return true
	end

	return false
end

local function swap(pos, node, name, param2)
	if node.name == name and node.param2 == param2 then
		return
	end

	minetest.set_node(pos, {name = name, param2 = param2})
end

local function update_pane(pos)
	if not is_pane(pos) then
		return
	end
	local node = minetest.get_node(pos)
	local name = node.name
	if name:sub(-5) == "_flat" then
		name = name:sub(1, -6)
	end

	local any = node.param2
	local c = {}
	local count = 0
	for dir = 0, 3 do
		c[dir] = connects_dir(pos, name, dir)
		if c[dir] then
			any = dir
			count = count + 1
		end
	end

	if count == 0 then
		swap(pos, node, name .. "_flat", any)
	elseif count == 1 then
		swap(pos, node, name .. "_flat", (any + 1) % 4)
	elseif count == 2 then
		if (c[0] and c[2]) or (c[1] and c[3]) then
			swap(pos, node, name .. "_flat", (any + 1) % 4)
		else
			swap(pos, node, name, 0)
		end
	else
		swap(pos, node, name, 0)
	end
end

minetest.register_on_placenode(function(pos, node)
	if minetest.get_item_group(node, "pane") then
		update_pane(pos)
	end
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

minetest.register_on_dignode(function(pos)
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

xpanes = {}
function xpanes.register_pane(name, def)
	for i = 1, 15 do
		minetest.register_alias("xpanes:" .. name .. "_" .. i, "xpanes:" .. name .. "_flat")
	end

	local flatgroups = table.copy(def.groups)
	flatgroups.pane = 1
	flatgroups.deco_block = 1
	minetest.register_node(":xpanes:" .. name .. "_flat", {
		description = def.description,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = flatgroups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connect_sides = { "left", "right" },
	})

	local groups = table.copy(def.groups)
	groups.pane = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":xpanes:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		description = def.description,
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = groups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		node_box = {
			type = "connected",
			fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
			connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
			connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
			connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
			connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connects_to = {"group:pane", "group:stone", "group:glass", "group:wood", "group:tree"},
	})

	minetest.register_craft({
		output = "xpanes:" .. name .. "_flat 16",
		recipe = def.recipe
	})
end

local pane = function(description, node, append)
	xpanes.register_pane("pane"..append, {
		description = description,
		textures = {"xpanes_pane_glass"..append..".png","xpanes_pane_half_glass"..append..".png","xpanes_top_glass"..append..".png"},
		inventory_image = "xpanes_pane_glass"..append..".png",
		wield_image = "xpanes_pane_glass"..append..".png",
		sounds = mcl_core.node_sound_glass_defaults(),
		groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
		recipe = {
			{node, node, node},
			{node, node, node},
		}
	})
end

-- Iron Bar
xpanes.register_pane("bar", {
	description = "Iron Bars",
	textures = {"xpanes_pane_iron.png","xpanes_pane_half_iron.png","xpanes_top_iron.png"},
	inventory_image = "xpanes_pane_iron.png",
	wield_image = "xpanes_pane_iron.png",
	groups = {cracky=2},
	sounds = mcl_core.node_sound_metal_defaults(),
	recipe = {
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot", "mcl_core:steel_ingot"},
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot", "mcl_core:steel_ingot"}
	}
})

-- Glass
pane("Glass Pane", "mcl_core:glass", "_natural")
pane("Red Stained Glass Pane", "mcl_core:glass_red", "_red")
pane("Green Stained Glass Pane", "mcl_core:glass_green", "_green")
pane("Blue Stained Glass Pane", "mcl_core:glass_blue", "_blue")
pane("Light Blue Stained Glass Pane", "mcl_core:glass_light_blue", "_light_blue")
pane("Black Stained Glass Pane", "mcl_core:glass_black", "_black")
pane("White Stained Glass Pane", "mcl_core:glass_white", "_white")
pane("Yellow Stained Glass Pane", "mcl_core:glass_yellow", "_yellow")
pane("Brown Stained Glass Pane", "mcl_core:glass_brown", "_brown")
pane("Orange Stained Glass Pane", "mcl_core:glass_orange", "_orange")
pane("Pink Stained Glass Pane", "mcl_core:glass_pink", "_pink")
pane("Gray Stained Glass Pane", "mcl_core:glass_gray", "_gray")
pane("Lime Stained Glass Pane", "mcl_core:glass_lime", "_lime")
pane("Light Gray Stained Glass Pane", "mcl_core:glass_silver", "_silver")
pane("Magenta Stained Glass Pane", "mcl_core:glass_magenta", "_magenta")
pane("Purple Stained Glass Pane", "mcl_core:glass_purple", "_purple")
pane("Cyan Stained Glass Pane", "mcl_core:glass_cyan", "_cyan")
