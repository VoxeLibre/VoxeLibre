local S = minetest.get_translator(minetest.get_current_modname())

-- Core mcl_stairs API

-- Wrapper around mintest.pointed_thing_to_face_pos.
local function get_fpos(placer, pointed_thing)
	local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	return finepos.y % 1
end

local function place_slab_normal(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local p0 = pointed_thing.under
	local p1 = pointed_thing.above

	--local placer_pos = placer:get_pos()

	local fpos = get_fpos(placer, pointed_thing)

	local place = ItemStack(itemstack)
	local origname = itemstack:get_name()
	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		place:set_name(origname .. "_top")
	end
	local ret = minetest.item_place(place, placer, pointed_thing, 0)
	ret:set_name(origname)
	return ret
end

local function place_stair(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	local placer_pos = placer:get_pos()
	if placer_pos then
		param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
	end

	local fpos = get_fpos(placer, pointed_thing)

	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		param2 = param2 + 20
		if param2 == 21 then
			param2 = 23
		elseif param2 == 23 then
			param2 = 21
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

-- Register stairs.
-- Node will be called mcl_stairs:stair_<subname>

local function allow_attach(node, wdir)
	return wdir == 1 and math.floor(node.param2 / 4) == 5
end

function mcl_stairs.register_stair(subname, recipeitem, groups, images, description, sounds, blast_resistance, hardness, corner_stair_texture_override)

	if recipeitem then
		if not images then
			images = minetest.registered_items[recipeitem].tiles
		end
		if not groups then
			groups = minetest.registered_items[recipeitem].groups
		end
		if not sounds then
			sounds = minetest.registered_items[recipeitem].sounds
		end
		if not hardness then
			hardness = minetest.registered_items[recipeitem]._mcl_hardness
		end
		if not blast_resistance then
			blast_resistance = minetest.registered_items[recipeitem]._mcl_blast_resistance
		end
	end

	groups.stair = 1
	groups.building_block = 1

	local image_table = {}
	for i, image in ipairs(images) do
		image_table[i] = type(image) == "string" and { name = image } or table.copy(image)
		image_table[i].align_style = "world"
	end

	minetest.register_node(":mcl_stairs:stair_" .. subname, {
		description = description,
		_doc_items_longdesc = S("Stairs are useful to reach higher places by walking over them; jumping is not required. Placing stairs in a corner pattern will create corner stairs. Stairs placed on the ceiling or at the upper half of the side of a block will be placed upside down."),
		drawtype = "nodebox",
		tiles = image_table,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		_vl_allow_attach = {
			torch = allow_attach,
			button = allow_attach,
			lever = false,
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return place_stair(itemstack, placer, pointed_thing)
		end,
		on_rotate = function(pos, node, user, mode, param2)
			-- Flip stairs vertically
			if mode == screwdriver.ROTATE_AXIS then
				local minor = node.param2
				if node.param2 >= 20 then
					minor = node.param2 - 20
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
				else
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
					node.param2 = node.param2 + 20
				end
				minetest.set_node(pos, node)
				return true
			end
		end,
		_mcl_blast_resistance = blast_resistance,
		_mcl_hardness = hardness,
	})

	if recipeitem then
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{recipeitem, "", ""},
				{recipeitem, recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Flipped recipe
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{"", "", recipeitem},
				{"", recipeitem, recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Stonecutter recipe
		mcl_stonecutter.register_recipe(recipeitem, "mcl_stairs:stair_".. subname)
	end

	mcl_stairs.cornerstair.add("mcl_stairs:stair_"..subname, corner_stair_texture_override)
end


-- Slab facedir to placement 6d matching table
--local slab_trans_dir = {[0] = 8, 0, 2, 1, 3, 4}

-- Register slabs.
-- Node will be called mcl_stairs:slab_<subname>

-- double_description: NEW argument, not supported in Minetest Game
-- double_description: Description of double slab
function mcl_stairs.register_slab(subname, recipeitem, groups, images, description, sounds, blast_resistance, hardness, double_description)
	local lower_slab = "mcl_stairs:slab_"..subname
	local upper_slab = lower_slab.."_top"
	local double_slab = lower_slab.."_double"

	if recipeitem then
		if not images then
			images = minetest.registered_items[recipeitem].tiles
		end
		if not groups then
			groups = minetest.registered_items[recipeitem].groups
		end
		if not sounds then
			sounds = minetest.registered_items[recipeitem].sounds
		end
		if not hardness then
			hardness = minetest.registered_items[recipeitem]._mcl_hardness
		end
		if not blast_resistance then
			blast_resistance = minetest.registered_items[recipeitem]._mcl_blast_resistance
		end
	end

	-- Automatically generate double slab description
	if not double_description then
		double_description = S("Double @1", description)
	end

	groups.slab = 1
	groups.building_block = 1
	local longdesc = S("Slabs are half as high as their full block counterparts and occupy either the lower or upper part of a block, depending on how it was placed. Slabs can be easily stepped on without needing to jump. When a slab is placed on another slab of the same type, a double slab is created.")

	local slabdef = {
		description = description,
		_doc_items_longdesc = longdesc,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		-- Facedir intentionally left out (see below)
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if not placer then return end

			local above = pointed_thing.above
			local under = pointed_thing.under
			local anode = minetest.get_node(above)
			local unode = minetest.get_node(under)
			local adefs = minetest.registered_nodes[anode.name]
			local udefs = minetest.registered_nodes[unode.name]
			local wield_item = itemstack:get_name()
			local player_name = placer:get_player_name()
			local creative_enabled = minetest.is_creative_enabled(player_name)

			-- place slab using under node orientation
			local dir = vector.subtract(above, under)
			local p2 = unode.param2

			if minetest.is_protected(under, player_name) and not
				minetest.check_player_privs(placer, "protection_bypass") then
					minetest.record_protection_violation(under, player_name)
					return
			end

			-- combine two slabs if possible
			-- Requirements: Same slab material, must be placed on top of lower slab, or on bottom of upper slab
			if (wield_item == unode.name or (udefs and wield_item == udefs._mcl_other_slab_half)) and
					not ((dir.y >= 0 and minetest.get_item_group(unode.name, "slab_top") == 1) or
					(dir.y <= 0 and minetest.get_item_group(unode.name, "slab_top") == 0)) then

				minetest.set_node(under, {name = double_slab, param2 = p2})

				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			elseif (wield_item == anode.name or (adefs and wield_item == adefs._mcl_other_slab_half)) then
				minetest.set_node(above, {name = double_slab, param2 = p2})

				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			-- No combination possible: Place slab normally
			else
				return place_slab_normal(itemstack, placer, pointed_thing)
			end
		end,
		_mcl_hardness = hardness,
		_mcl_blast_resistance = blast_resistance,
		_mcl_other_slab_half = upper_slab,
		on_rotate = function(pos, node, user, mode, param2)
			-- Flip slab
			if mode == screwdriver.ROTATE_AXIS then
				node.name = upper_slab
				minetest.set_node(pos, node)
				return true
			end
			return false
		end,
	}

	minetest.register_node(":"..lower_slab, slabdef)

	-- Register the upper slab.
	-- Using facedir is not an option, as this would rotate the textures as well and would make
	-- e.g. upper sandstone slabs look completely wrong.
	local topdef = table.copy(slabdef)
	topdef.groups.slab = 1
	topdef.groups.slab_top = 1
	topdef.groups.not_in_creative_inventory = 1
	topdef.groups.not_in_craft_guide = 1
	topdef.description = S("Upper @1", description)
	topdef._doc_items_create_entry = false
	topdef._doc_items_longdesc = nil
	topdef._doc_items_usagehelp = nil
	topdef.drop = lower_slab
	topdef._mcl_other_slab_half = lower_slab
	function topdef.on_rotate(pos, node, user, mode, param2)
		-- Flip slab
		if mode == screwdriver.ROTATE_AXIS then
			node.name = lower_slab
			minetest.set_node(pos, node)
			return true
		end
		return false
	end
	topdef.node_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	topdef.selection_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	minetest.register_node(":"..upper_slab, topdef)


	-- Double slab node
	local dgroups = table.copy(groups)
	dgroups.not_in_creative_inventory = 1
	dgroups.not_in_craft_guide = 1
	dgroups.slab = nil
	dgroups.double_slab = 1
	minetest.register_node(":"..double_slab, {
		description = double_description,
		_doc_items_longdesc = S("Double slabs are full blocks which are created by placing two slabs of the same kind on each other."),
		tiles = images,
		is_ground_content = false,
		groups = dgroups,
		sounds = sounds,
		drop = lower_slab .. " 2",
		_mcl_hardness = hardness,
		_mcl_blast_resistance = blast_resistance,
	})

	if recipeitem then
		minetest.register_craft({
			output = lower_slab .. " 6",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})

		mcl_stonecutter.register_recipe(recipeitem, lower_slab, 2)

	end

	-- Help alias for the upper slab
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", lower_slab, "nodes", upper_slab)
	end
end


-- Stairs/slab registration function.
-- Nodes will be called mcl_stairs:{stair,slab}_<subname>

function mcl_stairs.register_stair_and_slab(subname, recipeitem,
		groups, images, desc_stair, desc_slab, sounds, blast_resistance, hardness,
		double_description, corner_stair_texture_override)
	mcl_stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds, blast_resistance, hardness, corner_stair_texture_override)
	mcl_stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds, blast_resistance, hardness, double_description)
end

-- Very simple registration function
-- Makes stair and slab out of a source node
function mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab, corner_stair_texture_override)
	local def = minetest.registered_nodes[sourcenode]
	local groups = {}
	-- Only allow a strict set of groups to be added to stairs and slabs for more predictable results
	local allowed_groups = { "dig_immediate", "handy", "pickaxey", "axey", "shovely", "shearsy", "shearsy_wool", "swordy", "swordy_wool" }
	for a=1, #allowed_groups do
		if def.groups[allowed_groups[a]] then
			groups[allowed_groups[a]] = def.groups[allowed_groups[a]]
		end
	end
	mcl_stairs.register_stair_and_slab(subname, sourcenode, groups, def.tiles, desc_stair, desc_slab, def.sounds, def._mcl_blast_resistance, def._mcl_hardness, desc_double_slab, corner_stair_texture_override)
end

