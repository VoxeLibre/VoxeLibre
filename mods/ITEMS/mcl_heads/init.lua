local S = minetest.get_translator(minetest.get_current_modname())

local mod_doc = minetest.get_modpath("doc")
local mod_screwdriver = minetest.get_modpath("screwdriver")

local equip_armor
if minetest.get_modpath("mcl_armor") then
	equip_armor = mcl_armor.equip_on_use
end

-- Heads system

local function addhead(name, texture, desc, longdesc, rangemob, rangefactor)
	local on_rotate_floor, on_rotate_wall
	if mod_screwdriver then
		on_rotate_floor = function(pos, node, user, mode, new_param2)
			if mode == screwdriver.ROTATE_AXIS then
				node.name = node.name .. "_wall"
				node.param2 = minetest.dir_to_wallmounted(minetest.facedir_to_dir(node.param2))
				minetest.set_node(pos, node)
				return true
			end
		end
		on_rotate_wall = function(pos, node, user, mode, new_param2)
			if mode == screwdriver.ROTATE_AXIS then
				node.name = string.sub(node.name, 1, string.len(node.name)-5)
				node.param2 = minetest.dir_to_facedir(minetest.wallmounted_to_dir(node.param2))
				minetest.set_node(pos, node)
				return true
			end
		end
	end

	minetest.register_node("mcl_heads:"..name, {
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
		groups = {handy = 1, armor = 1, armor_head = 1, non_combat_armor = 1, non_combat_armor_head = 1, head = 1, deco_block = 1, dig_by_piston = 1},
		-- The head textures are based off the textures of an actual mob.
		tiles = {
			-- Note: bottom texture is overlaid over top texture to get rid of possible transparency.
			-- This is required for skeleton skull and wither skeleton skull.
			"[combine:16x16:-4,4="..texture, -- top
			"([combine:16x16:-4,4="..texture..")^([combine:16x16:-12,4="..texture..")", -- bottom
			"[combine:16x16:-12,0="..texture, -- left
			"[combine:16x16:4,0="..texture, -- right
			"[combine:16x16:-20,0="..texture, -- back
			"[combine:16x16:-4,0="..texture, -- front
		},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
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
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities, for now.
				return itemstack
			end

			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if not def then return itemstack end

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(under, node, placer, itemstack) or itemstack
				end
			end

			local above = pointed_thing.above
			local diff = {x = under.x - above.x, y = under.y - above.y, z = under.z - above.z}
			local wdir = minetest.dir_to_wallmounted(diff)

			local itemstring = itemstack:get_name()
			local fakestack = ItemStack(itemstack)
			--local idef = fakestack:get_definition()
			local retval
			if wdir == 0 or wdir == 1 then
				return minetest.item_place(itemstack, placer, pointed_thing)
			else
				retval = fakestack:set_name("mcl_heads:"..name.."_wall")
			end
			if not retval then
				return itemstack
			end
			itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)
			return itemstack
		end,
		on_secondary_use = equip_armor,

		on_rotate = on_rotate_floor,

		_mcl_armor_mob_range_mob = rangemob,
		_mcl_armor_mob_range_factor = rangefactor,
		_mcl_armor_element = "head",
		_mcl_armor_texture = "mcl_heads_" .. name .. ".png",
		_mcl_blast_resistance = 1,
		_mcl_hardness = 1,
	})

	minetest.register_node("mcl_heads:"..name.."_wall", {
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		is_ground_content = false,
		node_box = {
			type = "wallmounted",
			wall_bottom = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
			wall_top = { -0.25, 0.0, -0.25, 0.25, 0.5, 0.25, },
			wall_side = { -0.5, -0.25, -0.25, 0.0, 0.25, 0.25, },
		},
		groups = {handy=1, head=1, deco_block=1, dig_by_piston=1, not_in_creative_inventory=1},
		-- The head textures are based off the textures of an actual mob.
		tiles = {
			{ name = "[combine:16x16:-4,-4="..texture, align_style = "world" }, -- front
			{ name = "[combine:16x16:-20,-4="..texture, align_style = "world" }, -- back
			{ name = "[combine:16x16:-8,-4="..texture, align_style = "world" }, -- left
			{ name = "[combine:16x16:0,-4="..texture, align_style = "world" }, -- right
			{ name = "([combine:16x16:-4,0="..texture..")^[transformR180", align_style = "node" }, -- top
			{ name = "([combine:16x16:-4,8="..texture..")^([combine:16x16:-12,8="..texture..")", align_style = "node" }, -- bottom
		},
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = true,
		sounds = mcl_sounds.node_sound_defaults({
			footstep = {name="default_hard_footstep", gain=0.3}
		}),
		drop = "mcl_heads:"..name,
		on_rotate = on_rotate_wall,
		_mcl_blast_resistance = 1,
		_mcl_hardness = 1,
	})

	if mod_doc then
		doc.add_entry_alias("nodes", "mcl_heads:" .. name, "nodes", "mcl_heads:" .. name .. "_wall")
	end
end

-- Add heads
addhead("zombie", "mcl_heads_zombie_node.png", S("Zombie Head"), S("A zombie head is a small decorative block which resembles the head of a zombie. It can also be worn as a helmet, which reduces the detection range of zombies by 50%."), "mobs_mc:zombie", 0.5)
addhead("creeper", "mcl_heads_creeper_node.png", S("Creeper Head"), S("A creeper head is a small decorative block which resembles the head of a creeper. It can also be worn as a helmet, which reduces the detection range of creepers by 50%."), "mobs_mc:creeper", 0.5)
-- Original Minecraft name: “Head”
addhead("steve", "mcl_heads_steve_node.png", S("Human Head"), S("A human head is a small decorative block which resembles the head of a human (i.e. a player character). It can also be worn as a helmet for fun, but does not offer any protection."))
addhead("skeleton", "mcl_heads_skeleton_node.png", S("Skeleton Skull"), S("A skeleton skull is a small decorative block which resembles the skull of a skeleton. It can also be worn as a helmet, which reduces the detection range of skeletons by 50%."), "mobs_mc:skeleton", 0.5)
addhead("wither_skeleton", "mcl_heads_wither_skeleton_node.png", S("Wither Skeleton Skull"), S("A wither skeleton skull is a small decorative block which resembles the skull of a wither skeleton. It can also be worn as a helmet for fun, but does not offer any protection."))
